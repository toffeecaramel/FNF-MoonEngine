package backend.network;

import backend.network.*;

class Server
{
    public static var host:ServerHost;
    public static var client:ServerClient;

    public static function startHost(ip:String, port:Int):Void
    {
    	host = new ServerHost();
        host.start(ip, port);
    }

    public static function joinServer(ip:String, port:Int):Void
    {
    	client = new ServerClient();
        client.connect(ip, port);
    }

	public static function sendMessage(message:String):Void
	{
	    if (host != null) {
	        //trace('Host cutely sending message: $message', "DEBUG");
	        host.broadcastMessage(message);
	    }
	    if (client != null) {
	        //trace('Client cutely sending message: $message', "DEBUG");
	        client.sendMessage(message);
	    }
	}

    public static function processMessages(callback:String->Void):Void
    {
        if (host != null) host.processMessages(callback);
        if (client != null) client.processMessages(callback);
    }
}
