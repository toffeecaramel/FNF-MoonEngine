package backend.network;

import sys.net.Socket;
import sys.net.Host;
import sys.thread.Thread;
import haxe.io.Bytes;

class ServerClient
{
    private var socket:Socket;
    private var messages:Array<String>;
    private var connected:Bool = false;

    // - Success Callbacks.

    // - Errors Callbacks.
    public var onConnectionFail:Void->Void;
    public var onLostConnection:Void->Void;

    public function new()
    {
    	connected = false;
    	messages = [];
        socket = new Socket();
    }

    public function connect(ip:String, port:Int):Bool
    {
        try
        {
            socket.connect(new Host(ip), port);
            connected = true;

            trace('Connected to server at $ip:$port');

            Thread.create(receiveMessages);
            return true;
        }
        catch (e:Dynamic)
        {
            trace('Failed to connect. $e', "ERROR");

            if(onConnectionFail != null) onConnectionFail();
            return false;
        }
    }

    private function receiveMessages():Void
    {
        final buffer = Bytes.alloc(1024);
        while (connected)
        {
            try
            {
                final len = socket.input.readBytes(buffer, 0, buffer.length);
                final message = buffer.sub(0, len).toString();
                messages.push(message);
            }
            catch (e:Dynamic)
            {
                trace('Connection lost.', "ERROR");
				if(onLostConnection != null) onLostConnection();

                connected = false;
                break;
            }
        }
    }

    public function sendMessage(message:String):Void
    {
        if (connected)
        {
            try
            {
                socket.output.writeString(message);
                socket.output.flush();
            }
            catch (e:Dynamic)
            {
                trace('Failed to send server message: $e', "ERROR");
            }
        }
    }

	public function processMessages(callback:String->Void):Void
	{
	    for (message in messages)
	        callback(message);
	    messages = [];
	}
}
