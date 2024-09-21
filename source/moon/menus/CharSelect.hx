package moon.menus;

using StringTools;

typedef CharData = {
    var name:String;
    var partner:String;
    var gamePrefix:String;
};

// - Maybe I'll add more into this :P
typedef FullData = {
    var players:Array<CharData>;
};

class CharSelect extends MusicState
{
    override public function create():Void
    {
        super.create();

        final jsonData = haxe.Json.parse(sys.io.File.getContent(Paths.data('playableChars/players.json')));
        //trace(jsonData);

        for (i in 0...jsonData.players.length)
            trace('${jsonData.players[i]} is on my ass');
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}