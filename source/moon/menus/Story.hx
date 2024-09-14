package moon.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

import moon.utilities.CoolUtil;

class Story extends MusicSubState
{
    private var weekData:Array<Dynamic> = [];

    private var weekGrp:FlxTypedGroup<FlxSprite>;

    public function new()
    {
        super();

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFe5d571);
        bg.scrollFactor.set();
        add(bg);

        weekGrp = new FlxTypedGroup<FlxSprite>();
        add(weekGrp);

        final wArray = CoolUtil.getTextFromArray(Paths.data('weeks/weekList.txt'));
        for (i in 0...wArray.length)
            addWeek(wArray[i]);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    private function addWeek(week:String)
    {
        var data = WeekData.getData(week);
        weekData.push(data);
        trace('added ${data.displayName}, songs being ${data.tracks}');

        weekGrp.recycle(FlxSprite, function():FlxSprite
        {
            var spr = new FlxSprite(0, 80).loadGraphic(Paths.dataImg('weeks/$week/${data.weekImage}'));
            spr.y += 60;
            return spr;
        });
    }
}