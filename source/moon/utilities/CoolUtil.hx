package moon.utilities;

import lime.utils.Assets;

using StringTools;

#if sys
import sys.FileSystem;
#end

class CoolUtil
{
    public static inline function dashToSpace(string:String):String
    {
        return string.replace("-", " ");
    }

    public static inline function spaceToDash(string:String):String
    {
        return string.replace(" ", "-");
    }

    public static inline function swapSpaceDash(string:String):String
    {
        return string.contains('-') ? dashToSpace(string) : spaceToDash(string);
    }

    public static function getTextFromArray(p:String)
    {
        if (sys.FileSystem.exists(p))
        {
            var fileContent:String = sys.io.File.getContent(p);
            return fileContent.split("\n").map(function(line:String):String {
                return line.trim();
            });
        }
        else
            return ["File not found!"];
    }
}