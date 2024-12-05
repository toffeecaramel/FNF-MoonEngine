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
	    if (host != null) host.broadcastMessage(message);
	    if (client != null) client.sendMessage(message);
	}

    public static function processMessages(callback:String->Void):Void
    {
        if (host != null) host.processMessages(callback);
        if (client != null) client.processMessages(callback);
    }
}
