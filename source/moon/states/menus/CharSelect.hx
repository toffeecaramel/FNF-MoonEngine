package moon.states.menus;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import backend.dependency.FNFSound;
import moon.obj.menus.charSelect.*;

using StringTools;

class CharSelect extends MusicState
{
    private var itemSfx:FNFSound;
    private final funkinChars:Array<String> = [
        'locked', 'locked', 'locked',
        'pico',   'bf',     'locked',
        'locked', 'locked', 'locked'
    ];

    private var charGrid:CharGrid; // Updated to use CharGrid
    private var follower:Follower; // The lil' square that follows you :3
    private var canMove:Bool = false; // Allows you to move or not

    override public function create():Void
    {
        super.create();

        DiscordRPC.changePresence("On Character Select Menu", "Selecting a character.");

        generateBackground();

        itemSfx = new FNFSound();
        itemSfx.loadEmbedded(Paths.sound('interfaces/charSelect/itemAppear'));
        itemSfx.pitch = 0.7;
        itemSfx.stop();
        FlxG.sound.list.add(itemSfx);

        follower = new Follower();
        add(follower);

        charGrid = new CharGrid(4, 150);
        charGrid.setupGrid(funkinChars);
        charGrid.screenCenter();
        add(charGrid);
        //charGrid.setPosition(FlxG.width/2, FlxG.height/2);

        //setupGrid();
        initiateTransitions();
    }

    private function initiateTransitions():Void
    {
        final totalDelay:Float = 0.25 * funkinChars.length + 0.2;
        new FlxTimer().start(totalDelay, function(_) 
        {
            canMove = true;
            charGrid.highlightSelectedItem();
        });
    }

    private function generateBackground():Void
    {
        var back = new FlxSprite(-150, -160).loadGraphic(Paths.image('menus/charSelect/BG'));
        back.scale.set(1.2, 1.2);
        add(back);

        var crowd = new FlxSprite(-75, FlxG.height / 2 - 130);
        crowd.frames = Paths.getSparrowAtlas('menus/charSelect/crowd');
        crowd.scale.set(0.8, 0.8);
        crowd.animation.addByPrefix('crowd', 'crowd', 24, true);
        crowd.animation.play('crowd');
        add(crowd);

        var stage = new FlxSprite(-20, FlxG.height / 2 + 20);
        stage.frames = Paths.getSparrowAtlas('menus/charSelect/stage');
        stage.animation.addByPrefix('loopy', 'stage full instance 1', 16, true);
        stage.animation.play('loopy');
        add(stage);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (canMove)
        {
            handleGridNavigation();
            updateFollower(elapsed);
        }
    }

    private function handleGridNavigation():Void
    {
        if (FlxG.keys.justPressed.LEFT) charGrid.scroll(-1);
        else if (FlxG.keys.justPressed.RIGHT) charGrid.scroll(1);
        else if (FlxG.keys.justPressed.UP) charGrid.scroll(-charGrid.columns);
        else if (FlxG.keys.justPressed.DOWN) charGrid.scroll(charGrid.columns);
    }

    private function updateFollower(elapsed:Float):Void
    {
        var selectedItem = cast charGrid.getSelected();
        var targetX = selectedItem.x + (selectedItem.frameWidth - follower.width) / 2;
        var targetY = selectedItem.y + (selectedItem.frameHeight - follower.height) / 2;

        follower.follow(targetX, targetY, elapsed);
    }
}