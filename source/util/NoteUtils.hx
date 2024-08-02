package util;

using StringTools;

/**
    This class contains all utilities related to notes.
    some of them being used by the chart converter
    or by the notes class itself.
**/
class NoteUtils
{
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
    
    public static var angles = [-90, 180, 0, 90];
    /**
        Returns an *angle* value from a *direction* 
        `(left, right, etc...)`
    **/
    public static function angleFromDirection(direction:String):Float
        return angles[directionToNumber(direction)];
}