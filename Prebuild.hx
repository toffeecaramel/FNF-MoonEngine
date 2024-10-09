package;

import sys.io.File;

/**
 * A script which executes before the game is built.
 * Originally Made by Funkin' Crew.
 */
class Prebuild
{
    static inline final BUILD_TIME_FILE:String = '.build_time';

    /**
     * Just a few messages to keep your motivation up!
     * Don't ever give up on coding, it is hard! but with dedication, you'll get where you want <3
    **/
    
    /*public static final motivationMsgs = [
        "You are smart, I bet the game will compile just fine!",
        "You are handsome :3",
        "Time to get funky!",
        "Imagine a FNF VS You... I bet it'd be awesome.",
        "Imagine how happy BF/GF must be, knowing that soon they'll see you.",
        "Don't forget to drink some water!",
        "You're almost there, just a few more seconds...!",
        "How's your code going? Let's see...",
        "Why do we brainstorm with ideas only when we're not working?",
        "Ah would ya look at that. If it isn't my favorite coder.",
        "Your smile is just as bright as the sun, I love seeing it."
    ];*/
    // - I'm actually rlly sad, I didn't get this to work :(
    // - For some reason you can't use FlxG, or any other flixel lib here...
    // - If you could, please help me fix that, I really want to people see
    // - Those messages when trying to compile DX

    static function main():Void
    {
        saveBuildTime();
        traceMessage();
    }

    public static function traceMessage():Void
    {
        trace('Building game, this may take a while...\n');
    }

    static function saveBuildTime():Void
    {
        var fo:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
        var now:Float = Sys.time();
        fo.writeDouble(now);
        fo.close();
    }
}
