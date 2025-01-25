package moon.utilities;

import moon.obj.notes.Note.EntireNote;
import flixel.FlxSprite;
import moon.obj.notes.*;
import flixel.util.FlxColor;
import moon.shaders.RGBPallete.RGBShaderReference;
import moon.shaders.RGBPallete;

/**
    This class contains all utilities related to notes.
    It now also handles all the shader setup logic.
**/
class NoteUtils
{
    public static var rgbShaders:Array<RGBPalette> = [];

    /**
     * Convert number directions (0, 1, 2, 3) to string directions.
     */
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
     * Convert string directions (left, down, etc.) to numbers.
     */
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
     * Returns an angle value based on direction.
     */
    public static function angleFromDirection(direction:String):Float
    {
        return angles[directionToNumber(direction)];
    }

    /**
     * Initialize the RGB shader palette for a given direction (noteData).
     */
    public static function initializeGlobalRGBShader(noteData:Int, arrowRGB:Array<Array<FlxColor>>):RGBPalette
    {
        if (rgbShaders[noteData] == null) 
        {
            var newRGB:RGBPalette = new RGBPalette();
            rgbShaders[noteData] = newRGB;

            var arr:Array<FlxColor> = arrowRGB[noteData];
            if (noteData > -1 && noteData <= arr.length) 
            {
                newRGB.r = arr[0];
                newRGB.g = arr[1];
                newRGB.b = arr[2];
            }
        }
        return rgbShaders[noteData];
    }

    /**
     * Applies the RGB shader to a sprite based on its note direction and arrow colors.
     */
    public static function applyNoteShader(sprite:FlxSprite, noteDir:String, arrowRGB:Array<Array<FlxColor>>):RGBShaderReference
    {
        var noteData = directionToNumber(noteDir);
        var rgbShader = new RGBShaderReference(sprite, initializeGlobalRGBShader(noteData, arrowRGB));

        var colors = arrowRGB[noteData];
        if (noteData > -1 && noteData <= colors.length)
        {
            rgbShader.r = colors[0];
            rgbShader.g = colors[1];
            rgbShader.b = colors[2];
        }

        return rgbShader;
    }

    public static function killNote(entireNote:EntireNote, notesArray:Array<EntireNote>, killSustain:Bool = true):Void // Added killSustain parameter
    {
        entireNote.tapNote.active = false; // Always kill the tap note part
        entireNote.tapNote.visible = false;
        entireNote.tapNote.exists = false;
        entireNote.tapNote.kill();

        if (killSustain) // Conditionally kill sustain parts
        {
            if (entireNote.sustainStart != null)
            {
                entireNote.sustainStart.active = false;
                entireNote.sustainStart.visible = false;
                entireNote.sustainStart.exists = false;
                entireNote.sustainStart.kill();
            }
            if (entireNote.sustainTile != null)
            {
                entireNote.sustainTile.active = false;
                entireNote.sustainTile.visible = false;
                entireNote.sustainTile.exists = false;
                entireNote.sustainTile.kill();
            }
            if (entireNote.sustainEnd != null)
            {
                entireNote.sustainEnd.active = false;
                entireNote.sustainEnd.visible = false;
                entireNote.sustainEnd.exists = false;
                entireNote.sustainEnd.kill();
            }
            notesArray.remove(entireNote); // Remove the EntireNote group only when everything is killed (including sustain if killSustain is true)
        }
        else
        {
            // If !killSustain, only tapNote is killed, sustain parts remain for now.
            // You might want to handle sustain removal in a different part of your logic (e.g., based on sustain length and time).
        }
    }
}
