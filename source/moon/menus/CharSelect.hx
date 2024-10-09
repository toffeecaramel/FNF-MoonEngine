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
    // - Array containing playable characters from base funkin, so they are shown
    // on their own category separated from the custom ones.
    private var funkinChars:Array<String> = [
        '?',    '?',    '?',
        'pico', 'bf',   '?',
        '?',    '?',    '?'
    ];

    private var customChars:Array<String> = [];

    private var funkinCharsGrp:flixel.group.FlxGroup.FlxTypedGroup<CharSelectItem>;
    private var customCharsGrp:flixel.group.FlxGroup.FlxTypedGroup<CharSelectItem>;

    override public function create():Void
    {
        super.create();

        funkinCharsGrp = new flixel.group.FlxGroup.FlxTypedGroup<CharSelectItem>();
        add(funkinCharsGrp);

        customCharsGrp = new flixel.group.FlxGroup.FlxTypedGroup<CharSelectItem>();
        add(customCharsGrp);

        // - Parse the JSON data for playable characters.
        final jsonData:FullData = cast haxe.Json.parse(sys.io.File.getContent(Paths.data('playableChars/players.json')));

        // - Iterate over each character in the JSON data.
        for (i in 0...jsonData.players.length)
        {
            final char = jsonData.players[i];
            if (!funkinChars.contains(char.gamePrefix)) {addToGroup(customCharsGrp, char); customChars.push(char.gamePrefix);}
            else addToGroup(funkinCharsGrp, char);
        }

        trace('Custom Characters: $customChars', 'DEBUG');
    }

    private function addToGroup(group:flixel.group.FlxGroup.FlxTypedGroup<CharSelectItem>, info):Void
    {
        group.recycle(CharSelectItem, function():CharSelectItem
        {
            var item = new CharSelectItem('${info.gamePrefix}', '${info.partner}');
            return item;
        });
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}

class CharSelectItem extends backend.dependency.FNFSprite
{
    public var char:String;
    public var partner:String;

    public function new(char:String, partner:String):Void
    {
        super();

        this.char = char;
        this.partner = partner;
        trace('CHAR: $char and PARTNER: $partner', 'DEBUG');

        // - Now time to set-up some shit - //
        //loadGraphic(Paths.data());
    }
}
