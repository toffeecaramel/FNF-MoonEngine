package moon.obj.font;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.display.BitmapData;
import openfl.geom.Matrix;

using StringTools;

class MoonText extends FlxSprite
{
    private var _textField:TextField;
    private var _formats:Array<{start:Int, end:Int, format:TextFormat}>;
    private var _plainText:String;

    public function new(x:Float = 0, y:Float = 0, text:String)
    {
        super(x, y);

        _textField = new TextField();
        _textField.defaultTextFormat = new TextFormat(Paths.fonts('vcr.ttf'), 18, 0xFFFFFF);
        _textField.autoSize = TextFieldAutoSize.LEFT;

        _formats = [];
        setText(text);
    }

    public function setText(text:String):Void
    {
        _formats = [];
        _plainText = parseTags(text);
        _textField.text = _plainText;
        applyFormats();
    }

    /**
     * Parse inline tags to extract plain text and formatting ranges.
     * @param text Text with inline tags.
     */
    private function parseTags(text:String):String
    {
        var result = "";
        var index = 0;

        var tagRegex = ~/<(color|font)=([^>]+)>(.*?)<\/\1>/g;

        while (tagRegex.match(text))
        {
            var matchPos = tagRegex.matchedPos();
            var fullMatch = tagRegex.matched(0);
            var tag = tagRegex.matched(1);
            var value = tagRegex.matched(2);
            var innerText = tagRegex.matched(3);

            result += text.substr(0, matchPos.pos);

            // - Calculates start and end positions for the inner text
            var start = index + result.length;
            var end = start + innerText.length;

            // - Alright so here it's the variables for the formatting stuff.
            // - They're null at first, but it'll atribute a value down below if used.
            // - It's just so I don't need to do "new TextFormat" for each format :V
            var color:Dynamic = null;
            var font:String = null;

            // - Adds formatting based on the tag
            switch(tag)
            {
                case "color": color = Std.parseInt(value.startsWith("0x") ? value : "0x" + value);
                case "font": font = Paths.fonts(value);
                default: null;
            }

            var format = new TextFormat(font, null, color);

            if (format != null)
                _formats.push({start: start, end: end, format: format});

            // - Appends inner text and adjust the remaining input
            result += innerText;
            text = text.substr(matchPos.pos + fullMatch.length);
        }

        result += text;

        return result;
    }

    /**
     * Apply the stored formats to the text field.
     */
    private function applyFormats():Void
    {
        for (format in _formats)
            _textField.setTextFormat(format.format, format.start, format.end);

        updateBitmap();
    }

    /**
     * Updates the bitmap with the current text field content.
     */
    private function updateBitmap():Void
    {
        var bitmapData = new BitmapData(Std.int(_textField.width), Std.int(_textField.height), true, 0x00000000);
        bitmapData.draw(_textField, new Matrix());
        set_pixels(bitmapData);
    }
}