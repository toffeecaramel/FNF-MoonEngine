package util;

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
}