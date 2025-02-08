package backend.user;

#if DISCORD_RPC
import discord_rpc.DiscordRpc;
#end
import lime.app.Application;

class DiscordRPC
{
    public static var gameStartTimestamp:Int = 0;

    public static function initRPC()
    {
        #if DISCORD_RPC
        gameStartTimestamp = Math.floor(Date.now().getTime() / 1000);

        DiscordRpc.start({
			clientID: "1297678826809200720",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		Application.current.window.onClose.add(shutdownRPC);
        #end
    }

    static function onReady()
    {
        #if DISCORD_RPC
        DiscordRpc.presence({
            details : 'Moon Engine',
            state   : 'Initializing...',
            largeImageKey  : 'moonengine-logo',
            largeImageText : 'Moon Engine',
            startTimestamp : gameStartTimestamp
        });
        #end
    }

    public static function changePresence(details:String = '', state:Null<String> = '', ?smallImageKey:String)
    {
        #if DISCORD_RPC
        DiscordRpc.presence({
            details: details,
            state: state,
            largeImageKey: 'moonengine-logo',
            largeImageText: 'Moon Engine v.${Constants.VERSION}',
            smallImageKey: smallImageKey,
            startTimestamp : gameStartTimestamp
        });
        #end
    }

    static function onError(_code : Int, _message : String)
    {
        trace('$_code : $_message', "ERROR");
    }

    static function onDisconnected(_code : Int, _message : String)
    {
        trace('Disconnected! $_code : $_message', "ERROR");
    }

    public static function shutdownRPC()
    {
        #if DISCORD_RPC
        DiscordRpc.shutdown();
        #end
    }
}