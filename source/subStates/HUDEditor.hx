package subStates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import haxe.Json;
import gameObjects.interfaces.*;
import states.data.MusicState.MusicSubState;

typedef HUDPositions = {
    var strumlines:Array<Float>;

    var healthBar:Array<Float>;
    var combo:Array<Float>;
};

class HUDEditor extends MusicSubState
{
    private var _file:String = "assets/data/ui/HUDPositions.json";

    private var _hb:FlxSprite;

    public function new()
    {
        super();
        checkFile();
        //_hb = new FlxSprite().ma
        var placeholderBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
        add(placeholderBG);
        var button = new LabeledButton(30, 30, 'vai toma no cu');
        add(button);
    }

    override public function update(a:Float):Void
    {
        super.update(a);
    }

    private var _originalThings:HUDPositions = {
        strumlines: [],
        healthBar: [],
        combo: []
    };

    private function checkFile():Void
    {
        final _content = Json.stringify(_originalThings, "\t");

        if(!sys.FileSystem.exists(_file))
            sys.io.File.saveContent(_file, _content);
    }
}