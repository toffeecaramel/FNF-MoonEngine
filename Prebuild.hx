package;

import sys.io.File;

/**
 * A script which executes before the game is built.
 * Made by Funkin' Crew.
 */
class Prebuild
{
    static inline final BUILD_TIME_FILE:String = '.build_time';

    static function main():Void
    {
        saveBuildTime();
        trace('Building game, this may take a while...');
    }

    static function saveBuildTime():Void
    {
        var fo:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
        var now:Float = Sys.time();
        fo.writeDouble(now);
        fo.close();
    }
}
