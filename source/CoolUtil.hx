package;

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

    /**
		*Convert directions from the base game format.*
		`Basically, the format the moon engine uses is:`
		`direction: directionString (like left, right etc.)`
		`and the base game uses numbers to determine directions`
		`and here we adapt the system to work as strings instead of numbers!`
	**/
	public static function numberToDirection(direction:Int):String
	{
		switch (direction)
		{
			case 0 | 4:
				return "left";
			case 1 | 5:
				return "down";
			case 2 | 6:
				return "up";
			case 3 | 7:
				return "right";
			default:
				return "unknown";
		}
	}

	/**
		*Convert directions from the moon engine format.*
		`Same thing as` **numberToDirection();** 
		`but on a reverse way, as it returns a number.`
	**/
	public static function directionToNumber(direction:String):Int
	{
		switch (direction)
		{
			case "left":
				return 0;
			case "down":
				return 1;
			case "up":
				return 2;
			case "right":
				return 3;
			default:
				return 4;
		}
	}
}