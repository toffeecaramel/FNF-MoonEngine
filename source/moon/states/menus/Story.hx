package moon.states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;

import moon.obj.menus.TextScroll;
import moon.utilities.CoolUtil;

class Story extends MusicSubState
{
    private var weekData:Array<Dynamic> = [];
    private var weekGrp:FlxTypedGroup<FlxSprite>;

    private var tBool:Bool = false;

    public function new()
    {
        super();

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFFe5d571);
        bg.scrollFactor.set();
        add(bg);

        final textsArray:Array<Dynamic> = [
            ["feel the rhythm", 0xffe4b660],
            ["stay funky", 0xffd8af63],
            ["rhythm excellence", 0xffe4b661],
            ["protect yo nuts", 0xffd8a341],
            ["hot blooded in more ways than one", 0xffcc9837],
            ["drop the beat", 0xffc49031]
        ];

        for (i in 0...20)
        {
            tBool = !tBool;

            var text = new TextScroll(0, -90 + (50 * i), textsArray[Std.int(i % textsArray.length)][0]);
            text.speed = FlxG.random.float(Conductor.crochet / 1000, Conductor.crochet / 1000 * 4);
            text.tColor = textsArray[Std.int(i % textsArray.length)][1];
            add(text);
        }

        var panel = new FlxSprite().loadGraphic(Paths.image('menus/story/UI'));
        add(panel);

        weekGrp = new FlxTypedGroup<FlxSprite>();
        add(weekGrp);
        
        addWeeks();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    private function addWeeks()
    {
        final wArray = CoolUtil.getTextArray(Paths.data('weeks/weekList.txt'));
        for (i in 0...wArray.length)
        {
            var data = WeekData.getData(wArray[i]);
            weekData.push(data);
            trace('added ${data.displayName}, songs being ${data.tracks}');
    
            weekGrp.recycle(FlxSprite, function():FlxSprite
            {
                var spr = new FlxSprite(100, 170).loadGraphic(Paths.data('weeks/${wArray[i]}/${data.weekImage}.png'));
                spr.y += 100 * i;
                return spr;
            });
        }
    }
}