package backend.network;

import sys.net.Socket;
import sys.net.Host;
import sys.thread.Thread;
import sys.thread.Mutex;
import haxe.io.Bytes;

// self note: local ip is "127.0.0.1" and port is 8080

class ServerHost
{
    private var serverSocket:Socket;
    private var clients:Array<Socket>;
    private var thread:Mutex;
    private var messages:Array<String>;

    public function new()
    {
        clients = [];
        thread = new Mutex();
        
        messages = [];
        serverSocket = new Socket();
    }

    public function start(ip:String, port:Int = 8080):Void
    {
        try
        {
            serverSocket.bind(new Host(ip), port);
            serverSocket.listen(8);
            trace('Server started: $ip:$port');
            Thread.create(acceptClients);
        }
        catch (e:Dynamic)
        {
            trace('Failed to start server: $e', "ERROR");
        }
    }

    private function acceptClients():Void
    {
        while (true)
        {
            try
            {
                var newClient = serverSocket.accept();
                trace('A new client has connected on the server!');
                thread.acquire();
                clients.push(newClient);
                thread.release();
                handleClient(newClient);
            }
            catch (e:Dynamic)
            {
                trace('Error accepting client: $e', "ERROR");
                break;
            }
        }
    }

    private function handleClient(client:Socket):Void
    {
        Thread.create(() ->
        {
            final buffer = Bytes.alloc(1024);
            while (true)
            {
                try
                {
                    final len = client.input.readBytes(buffer, 0, buffer.length);
                    final message = buffer.sub(0, len).toString();
                    thread.acquire();
                    messages.push(message);
                    thread.release();
                }
                catch (e:Dynamic)
                {
                    trace('Client disconnected: $e', "ERROR");
                    break;
                }
            }
        });
    }

    public function broadcastMessage(message:String):Void
    {
        //trace('broadcasting this shit: $message', "DEBUG");
        for (client in clients)
        {
            try
            {
                client.output.writeString(message);
                client.output.flush();
            }
            catch (e:Dynamic)
            {
                trace('Error broadcasting to client: $e', "ERROR");
            }
        }

        addLocalMessage(message);
    }

    private function addLocalMessage(message:String):Void
    {
        thread.acquire();
        messages.push(message);
        thread.release();
    }


    public function processMessages(callback:String->Void):Void
    {
        thread.acquire();
        for (message in messages) callback(message);
        messages = [];
        thread.release();
    }
}
