package backend.user;

#if DISCORD_RPC
import discord_rpc.DiscordRpc;
#end
import lime.app.Application;

class DiscordRPC
{
    #if DISCORD_RPC
    public static var gameStartTimestamp:Int = 0;

    public static function initRPC()
    {
        gameStartTimestamp = Math.floor(Date.now().getTime() / 1000);

        DiscordRpc.start({
			clientID: "1297678826809200720",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		Application.current.window.onClose.add(shutdownRPC);
    }

    static function onReady()
    {
        DiscordRpc.presence({
            details : 'Moon Engine',
            state   : 'Initializing...',
            largeImageKey  : 'moonengine-logo',
            largeImageText : 'Moon Engine',
            startTimestamp : gameStartTimestamp
        });
    }

    public static function changePresence(details:String = '', state:Null<String> = '', ?smallImageKey:String)
    {
        DiscordRpc.presence({
            details: details,
            state: state,
            largeImageKey: 'moonengine-logo',
            largeImageText: 'Moon Engine v.${Main.gameVersion}',
            smallImageKey: smallImageKey,
            startTimestamp : gameStartTimestamp
        });
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
        DiscordRpc.shutdown();
    }
    #end
}