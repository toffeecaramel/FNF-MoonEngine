package;

import flixel.FlxG;
import flixel.FlxSprite;
import sys.net.Host;
import sys.net.Socket;
import sys.thread.Mutex;
import sys.thread.Thread;
import haxe.io.Bytes;

import flixel.util.FlxColor;

import backend.network.*;

using StringTools;

class TestState extends MusicState
{
    // this was a fun server test >:3
    final ip:String = '127.0.0.1';
    final port:Int = 8080;

    override public function create():Void
    {
        super.create();
        FlxG.autoPause = false;
        trace("Press 'H' to host or 'J' to join.");
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.H) Server.startHost(ip, port);
        if (FlxG.keys.justPressed.J) Server.joinServer(ip, port);

        if (FlxG.keys.justPressed.S) {
            final x = FlxG.random.float(0, 900);
            final y = FlxG.random.float(0, 900);
            addObject(x, y);

            Server.sendMessage('ADD_OBJECT:$x,$y');
        }

        Server.processMessages(handleMessage);
    }

    private function handleMessage(message:String):Void
    {
        //trace('Received message: $message');
        final parts = message.split(':');

        if (parts[0] == "ADD_OBJECT")
        {
            final coords = parts[1].split(',');
            final x = Std.parseFloat(coords[0]);
            final y = Std.parseFloat(coords[1]);
            addObject(x, y);
        }
    }

    private function addObject(x:Float, y:Float):Void
    {
        var obj = new FlxSprite(x, y).makeGraphic(10, 10, FlxColor.RED);
        add(obj);
        //trace('Object added at ($x, $y)');
    }
}
