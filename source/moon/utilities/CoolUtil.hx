package moon.utilities;

import lime.utils.Assets;

using StringTools;

#if sys
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

class CoolUtil
{
    public static inline function dashToSpace(string:String):String
        return string.replace("-", " ");

    public static inline function spaceToDash(string:String):String
        return string.replace(" ", "-");

    public static inline function swapSpaceDash(string:String):String
        return string.contains('-') ? dashToSpace(string) : spaceToDash(string);

    public static function getTextArray(path:String)
    {
        if (#if sys sys.FileSystem.exists(path) #else Assets.exists(path) #end)
        {
            final fileContent:String = #if sys sys.io.File.getContent(path); #else Assets.getText(path); #end
            return fileContent.split("\n").map(function(line:String):String {
                return line.trim();
            });
        }
        else return ["File not found!"];
    }
}