package backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

#if cpp
import sys.FileSystem;
import sys.io.File;
#end

import hscript.Parser;
import hscript.Expr;
import hscript.Interp;

using StringTools;

/**
    ScriptHandler class!
    This class will be used for handling all the scripts from `assets/data/scripts`
    I'm planning to easily add it to songs and such

    and I also plan to make something like `assets/data/states`
    so you can make custom states without needing to compile the game!
**/

class ScriptHandler
{
    private var interp:Interp;

    private var classes:Array<Dynamic> = [
        ["FlxG", FlxG],
        ["FlxSprite", FlxSprite],
        ["FlxTween", FlxTween],
        ["FlxEase", FlxEase],
        ["Conductor", Conductor],
        ["Paths", Paths],
        ["PlayState", moon.states.PlayState]
    ];
    
    public function new()
    {
        interp = new Interp();

        // - Setup all the libraries
        for(i in 0...classes.length)
            interp.variables.set(classes[i][0], classes[i][1]);
    }

    //load the file and parse
    public function loadScript(path:String):Void
    {
        var scriptContent:String = File.getContent(path);
        var parser:Parser = new Parser();
        var expr:Expr = parser.parseString(scriptContent);

        interp.execute(expr);
    }

    public function get(str:String):Dynamic
        return interp.variables.get(str);

    public function set(str:String, value:Dynamic)
		interp.variables.set(str, value);

    public function exists(str:String):Bool
		return interp.variables.exists(str);
}