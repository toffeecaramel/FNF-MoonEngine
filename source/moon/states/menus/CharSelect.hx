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

typedef CharData = {
    var name:String;
    var partner:String;
    var gamePrefix:String;
};

typedef FullData = {
    var players:Array<CharData>;
};

class CharSelect extends MusicState
{
    private var itemSfx:FNFSound;
    private final funkinChars:Array<String> = [
        'locked', 'locked', 'locked',
        'pico',   'bf',     'locked',
        'locked', 'locked', 'locked'
    ];

    private var customChars:Array<String> = [];
    private var funkinCharsGrp:FlxTypedGroup<CharSelectIcon>;
    private var customCharsGrp:CharList;

    private var currentSelected:Int = 0; // - Tracks the current selected option
    private var selectionMode:String = "grid"; // - Tracks current selection mode: "grid" or "list"
    private final columns:Int = 3; // - Stuff for the grid
    private final spacing:Int = 150;

    private var follower:Follower; // - The lil' square that follows you :3

    private var canMove:Bool = false; // - Allows you to move or not

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

        funkinCharsGrp = new FlxTypedGroup<CharSelectIcon>();
        add(funkinCharsGrp);

        // Parse JSON data for custom characters.
        var customData = haxe.Json.parse(sys.io.File.getContent(Paths.data('playableChars/players.json'))).players;
        customCharsGrp = new CharList(customData, -200, 100); // Start offscreen
        add(customCharsGrp);

        setupGrid();
        initiateTransitions();
    }

    private function setupGrid():Void
    {
        final totalWidth = (columns - 1) * spacing;
        final startX = (FlxG.width - totalWidth) / 2 - 50;
        final startY = FlxG.height / 2 - spacing - 50;

        // Initialize grid items
        for (i in 0...funkinChars.length)
        {
            var row = Math.floor(i / columns);
            var col = i % columns;

            funkinCharsGrp.recycle(CharSelectIcon, function():CharSelectIcon
            {
                var item = new CharSelectIcon(funkinChars[i]);
                item.x = startX + col * spacing;
                item.y = startY + row * spacing;

                new FlxTimer().start(0.25 * i, function(tmr:FlxTimer)
                {
                    item.animation.play('idle');
                    itemSfx.pitch += 0.1;
                    if (itemSfx.playing) itemSfx.stop();
                    itemSfx.play();
                    item.introAnim();
                });
                
                return item;
            });
        }
    }

    private function initiateTransitions():Void
    {
        // Wait for animations to finish, then enable movement
        final totalDelay:Float = 0.25 * funkinChars.length + 0.2;
        new FlxTimer().start(totalDelay, function(_) { canMove = true; highlightSelectedItem(); });
    }

    /**
     * Creates the background elements.
     **/
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
            if (FlxG.keys.justPressed.TAB && canMove)
            {
                toggleSelectionMode();
                canMove = false;
            }

            (selectionMode == "grid") ? handleGridNavigation() : handleListNavigation();

            updateFollower(elapsed);
        }
    }

    /**
     * Toggle between grid and list selection modes.
     */
    private function toggleSelectionMode():Void
    {
        if (selectionMode == "grid") transitionToCustomList();
        else transitionToGrid();
    }

    private function transitionToCustomList():Void
    {
        selectionMode = "list";
        currentSelected = 0;
        canMove = false;

        // Animate grid items moving upward offscreen
        for (item in funkinCharsGrp.members)
            FlxTween.tween(item, {y: item.y - 700}, 0.6, {ease: FlxEase.circIn, onComplete: function(_){canMove = true;}});

        // Animate custom list appearing from the left
        customCharsGrp.enterTransition();
    }

    private function transitionToGrid():Void
    {
        selectionMode = "grid";
        currentSelected = 0;
        canMove = false;

        // Move grid items back to original position
        for (item in funkinCharsGrp.members)
            FlxTween.tween(item, {y: item.y + 700}, 0.6, {ease: FlxEase.circOut, onComplete: function(_){canMove = true;}});

        // Move custom list offscreen to the left
        customCharsGrp.exitTransition();
    }

    private function handleGridNavigation():Void
    {
        var oldIndex:Int = currentSelected;

        if (FlxG.keys.justPressed.LEFT)
        {
            if (currentSelected % columns != 0) currentSelected--;
            else currentSelected = currentSelected + (columns - 1);
        }
        else if (FlxG.keys.justPressed.RIGHT)
        {
            if ((currentSelected + 1) % columns != 0) currentSelected++;
            else currentSelected = currentSelected - (columns - 1);
        }

        if (FlxG.keys.justPressed.UP)
        {
            if (currentSelected - columns >= 0) currentSelected -= columns;
            else currentSelected = (funkinChars.length - columns + currentSelected) % funkinChars.length;
        }
        else if (FlxG.keys.justPressed.DOWN)
        {
            if (currentSelected + columns < funkinChars.length) currentSelected += columns;
            else currentSelected = (currentSelected % columns);
        }

        if (currentSelected != oldIndex) highlightSelectedItem();
    }

    private function handleListNavigation():Void
    {
        var oldIndex:Int = currentSelected;

        if (FlxG.keys.justPressed.UP)
            customCharsGrp.scroll(-1);
        else if (FlxG.keys.justPressed.DOWN)
            customCharsGrp.scroll(1);

        if (currentSelected != oldIndex) highlightSelectedItem();
    }

    private function highlightSelectedItem():Void
    {
        var group = funkinCharsGrp;
        for (i in 0...group.length)
        {
            var item = group.members[i];
            item.highlight(false);
        }

        var selectedItem = group.members[currentSelected];
        selectedItem.highlight(true);
    }

    private function updateFollower(elapsed:Float):Void
    {
        var selectedItem = (selectionMode == 'grid') ? 
            funkinCharsGrp.members[currentSelected] : customCharsGrp.items[currentSelected];
        var targetX = selectedItem.x + (selectedItem.frameWidth - follower.width) / 2;
        var targetY = selectedItem.y + (selectedItem.frameHeight - follower.height) / 2;

        follower.follow(targetX, targetY, elapsed);
    }
}
