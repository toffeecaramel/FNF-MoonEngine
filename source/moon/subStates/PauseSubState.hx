package moon.subStates;

import flixel.FlxCamera;
import moon.states.PlayState.GameMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import moon.states.menus.*;
import moon.states.PlayState;

using StringTools;

class PauseSubState extends MusicSubState
{
    private var optionsList:Array<Dynamic> = [
        ['Resume', 'Continue playing right where you paused at.'],
        ['Restart Song', 'Re-play the song from the beginning.'],
        ['Change Difficulty', 'Adjust the difficulty according to your gameplay.'],
        ['Practice Mode', "If on, will remove punishments for the health bar."],
        ['Settings', 'Change your settings.']
    ];

    private var descText:FlxText;

    private var curSelected:Int = 0;
    private var textGrp:FlxTypedGroup<FlxText>;

    public var cam:FlxCamera;
    
    var game(get, never):PlayState;

    public function new(gamemode:GameMode, cam:FlxCamera)
    {
        super();
        this.cam = cam;

        switch(gamemode)
        {
            case STORY: optionsList.push(['Exit to Menu', 'Exit back to the Story Mode menu.']);
            case FREEPLAY: optionsList.push(['Exit to Freeplay', 'Exit back to the Freeplay menu.']);
            case DEBUG: optionsList.push(['Exit to Editor', 'Exit back to the Editor you were using.']);
            case ONLINE: optionsList.push(['Leave Match', 'Exit the match you\'re playing. (YOU WILL LOSE YOUR SCORE!)']);
        }

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0.0001;
        add(bg);

        var paused = new FlxText(0, 10, 0, "PAUSED!");
        paused.setFormat(Paths.fonts('vcr.ttf'), 48, CENTER, FlxColor.GRAY);
        paused.screenCenter(X);
        paused.alpha = 0.6;
        add(paused);
        paused.scale.set(1.3, 0.7);

        FlxTween.tween(paused, {"scale.x": 1, "scale.y": 1}, 1.3, {ease: FlxEase.elasticOut});

        FlxTween.tween(bg, {alpha: 0.75}, 0.2);

        textGrp = new FlxTypedGroup<FlxText>();
        for (i in 0...optionsList.length)
        {
            final spacing = 36;
            final totalHeight = optionsList.length * (32 + spacing) - spacing;
            final startY = (FlxG.height - totalHeight) / 2;

            var txt = new FlxText(320, 50, 0, optionsList[i][0]);
            txt.setFormat(Paths.fonts('vcr.ttf'), 42, CENTER);
            txt.alpha = 0.0001;
            txt.screenCenter();
            txt.ID = i;
            textGrp.add(txt);

            FlxTween.tween(txt, {alpha: 1, y: startY + i * (32 + spacing)}, 
            0.4, {startDelay: 0.07 * i, ease: FlxEase.expoOut});
        }
        add(textGrp);

        var descBG = new FlxSprite().makeGraphic(FlxG.width, 70, FlxColor.BLACK);
        descBG.y = FlxG.height - descBG.height;
        descBG.alpha = 0.0001;
        add(descBG);

        FlxTween.tween(descBG, {alpha: 0.5}, 0.2);

        descText = new FlxText();
        descText.setFormat(Paths.fonts('vcr.ttf'), 32, CENTER);
        descText.y = FlxG.height - descText.height + 150;
        add(descText);

        FlxTween.tween(descText, {y: descText.y - 170}, 1, {ease: FlxEase.expoOut});

        changeSelection();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        final up = FlxG.keys.justPressed.UP;
		final down = FlxG.keys.justPressed.DOWN;
		final accepted = FlxG.keys.justPressed.ENTER;

        if (up) changeSelection(-1);
        if (down) changeSelection(1);

        if(accepted)
        {
            switch(optionsList[curSelected][0])
            {
                case 'Resume':
                    game.camGame.filters = [];
                    close();
                case 'Restart Song':
                    PlayState.playback.curState = KILL;
                    FlxG.switchState(new PlayState());
                case 'Settings':
                    close();
                    game.openSubState(new moon.states.menus.Options(true, game.camOther));
                case 'Exit to Freeplay':
                    FlxG.switchState(new Freeplay());
            }
        }
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 0, optionsList.length - 1);
        FlxG.sound.play(Paths.sound('interfaces/scroll'), 0.8);

        for(txt in textGrp)
        {
            txt.text = (curSelected == txt.ID) ? '> ${optionsList[curSelected][0]} <' : '${optionsList[txt.ID][0]}';
            txt.color = (curSelected == txt.ID) ? FlxColor.CYAN : FlxColor.WHITE;
            txt.screenCenter(X);

            descText.text = optionsList[curSelected][1];
            descText.screenCenter(X);
        }
    }

    override function add(Object:FlxBasic):FlxBasic
    {
        cast(Object, FlxSprite).camera = cam;
        return super.add(Object);
    }

    @:noCompletion
    function get_game():PlayState
        return PlayState.curPlaystate;
}