package moon.obj.font;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.display.BitmapData;
import openfl.geom.Matrix;

/**
 * A custom class for rendering texts.
 * 
 * by @toffeecaramel
 */

class MoonText extends FlxSprite
{
    // - The text field
    private var _textField:TextField;

    // - Array for the formats
    private var _formats:Array<{start:Int, end:Int, format:TextFormat}>;

    /**
     * Create a new text on-screen.
     * @param x    In-screen X position of the text.
     * @param y    In-screen Y position of the text.
     * @param text The text that will be displayed.
     */
    public function new(x:Float = 0, y:Float = 0, text:String)
    {
        super(x, y);
        
        // - Create the text field.
        _textField = new TextField();

        // - Set a format for default (Non-customizable for now).
        _textField.defaultTextFormat = new TextFormat(Paths.fonts('vcr.ttf'), 18, 0xFFFFFF);

        // - Set the orientation (Non-customizable for now).
        _textField.autoSize = TextFieldAutoSize.LEFT;

        // - Apply the text.
        _textField.text = text;

        // - Update the bitmap/formats.
        _formats = [];
        updateBitmap();
    }

    /**
     * Set formatting on the text, using `TextFormat` from OpenFL
     * @param start  The character number in which the TextFormat will start.
     * @param end    The character number in which the TextFormat will end.
     * @param format The TextFormat itself, check `TextFormat`'s docummentation on how to use.
     */
    public function setFormat(start:Int, end:Int, format:TextFormat):Void
    {
        // - Push the formats to the array.
        _formats.push({start: start, end: end, format: format});

        // - Apply all the formats.
        applyFormats();
    }

    /**
     * Applies the formats on the text.
     */
    private function applyFormats():Void
    {
        // - Set the default text format for the normal texts.
        _textField.defaultTextFormat = new TextFormat(Paths.fonts('vcr.ttf'), 18, 0xFFFFFF);
        
        // - Apply all the different formats.
        for (f in _formats)
            _textField.setTextFormat(f.format, f.start, f.end);

        // - Update the bitmap.
        updateBitmap();
    }

    /**
     * Updates the text's bitmap, basically, re-render it.
     */
    private function updateBitmap():Void
    {
        // - Create the bitmap data.
        var bitmapData:BitmapData = new BitmapData(Std.int(_textField.width), Std.int(_textField.height), true, 0x00000000);

        // - Draw it on the sprite.
        bitmapData.draw(_textField, new Matrix());

        // - Set the pixels.
        this.set_pixels(bitmapData);

        // - Resize it to the correct width.
        this.setGraphicSize(bitmapData.width, bitmapData.height);
    }

    /**
     * Changes the current text to a new one.
     * @param newText The text you want to apply.
     **/
    public function setText(newText:String):Void
    {
        _textField.text = newText;
        applyFormats();
    }
}