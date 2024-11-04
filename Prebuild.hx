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
     * some of these are so silly lol
    **/
    
    public static var motivationMsgs:Array<String> = [
        "You are smart, I bet the game will compile just fine!",
        "You are handsome :3",
        "Time to get funky!",
        "Imagine a FNF VS You... I bet it'd be awesome.",
        "Imagine how happy BF/GF must be, knowing that soon they'll see you.",
        "Don't forget to drink some water!",
        "You're almost there!",
        "How's your code going? We'll see...",
        "Why do we brainstorm with ideas only when we're not working?",
        "Ah would ya look at that. If it isn't my favorite coder.",
        "Your smile is just as bright as the sun, I love seeing it.",
        "It'll be neat to see your great ideas come to life."
    ];

    static function main():Void
    {
        saveBuildTime();
        traceMessage();
    }

    public static function traceMessage():Void
    {
        final message = motivationMsgs[Std.random(motivationMsgs.length)];
        Sys.println('\n[ $message ]' + "\n\n[ Anyways, the game is buildin' up just now. ]\n[ Please wait... :3 ]\n");
    }

    static function saveBuildTime():Void
    {
        var fo:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
        var now:Float = Sys.time();
        fo.writeDouble(now);
        fo.close();
    }
}
