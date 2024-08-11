package states.editors;

import flixel.FlxSprite;
import states.data.MusicState;
import haxe.Json;

typedef HUDPositions = {
    var strumlines:Array<Float>;

    var healthBar:Array<Float>;
    var combo:Array<Float>;
};

class HUDEditor extends MusicState
{
    private var _file:String = "assets/data/ui/HUDPositions.json";

    private var _hb:FlxSprite;

    override public function create():Void
    {
        super.create();
        checkFile();
        //_hb = new FlxSprite().ma
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