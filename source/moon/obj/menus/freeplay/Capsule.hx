package moon.obj.menus.freeplay;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import openfl.display.BlendMode;

import backend.dependency.FNFSprite;

class Capsule extends FlxSpriteGroup
{
    public var capsule:FlxSprite;
    public var songText:MP3Text;
    //public var pixelIcon:HealthIcon;
    //public var ranking:FreeplayRank;
    //public var blurredRanking:FreeplayRank;
    public var favIcon:FlxSprite;
    public var newText:FlxSprite;
    public var bigNumbers:Array<CapsuleNumber>;
    public var smallNumbers:Array<CapsuleNumber>;

    public var selected(default, set):Bool = false;
    public var songData:Dynamic;

    public var targetPos:FlxPoint = new FlxPoint();
    public var character:String;
    public var doLerp:Bool = false;
    public var doJumpIn:Bool = false;
    public var doJumpOut:Bool = false;

    public var selID:Int = 1;

    public function new(x:Float, y:Float)
    {
        super(x, y);
        // empty cause... it loads the graphics in a separate funct lol
    }

    public function loadGraphics():Void
    {
        capsule = new FNFSprite();
        capsule.frames = Paths.getSparrowAtlas('menus/freeplay/$character/capsule');
        capsule.animation.addByPrefix('selected', 'mp3 capsule w backing0', 24);
        capsule.animation.addByPrefix('unselected', 'mp3 capsule w backing NOT SELECTED', 24);
        add(capsule);

        songText = new MP3Text(0, 0, '', 48);
        add(songText);

        //pixelIcon = new HealthIcon();
        //add(pixelIcon);

        //ranking = new FreeplayRank(0, 0);
        //add(ranking);

        //blurredRanking = new FreeplayRank(0, 0);
        //blurredRanking.blend = BlendMode.ADD;
        //add(blurredRanking);

        favIcon = new FNFSprite();
        favIcon.frames = Paths.getSparrowAtlas('menus/freeplay/favHeart');
        favIcon.animation.addByPrefix('fav', 'favorite heart', 12, false);
        favIcon.animation.play('fav', true);
        favIcon.scale.set(1.1, 1.1);
        favIcon.updateHitbox();
        add(favIcon);

        newText = new FNFSprite();
        newText.frames = Paths.getSparrowAtlas('menus/freeplay/capsuleParts/new');
        newText.animation.addByPrefix('alert', 'NEW notif', 24, false);
        newText.animation.play('alert');
        newText.animation.finishCallback = function(_) {
            new FlxTimer().start(FlxG.random.float(0.8, 5),  function(_){
                newText.animation.play('alert', true);
                favIcon.animation.play('fav', true);
            });
        };
        add(newText);

        bigNumbers = [for (i in 0...2) new CapsuleNumber(0, 0, true)];
        smallNumbers = [for (i in 0...3) new CapsuleNumber(0, 0, false)];

        for (num in bigNumbers) add(num);
        for (num in smallNumbers) add(num);

        initPositions();
        new FlxTimer().start(FlxG.random.float(0.3, 2), (_) -> songText.initMove());
    }

    private function initPositions():Void
    {
        // - Separate function cause... meh q - q
        capsule.setPosition(30, 30);
        songText.setPosition(152, 70);
        //pixelIcon.setPosition(220, 10);
        //ranking.setPosition(260, 10);
        //blurredRanking.setPosition(260, 10);
        favIcon.setPosition(425, 69); // nice
        newText.setPosition(580, 45);

        var bigNumX = 535;
        for (num in bigNumbers)
        {
            num.setPosition(bigNumX, 60);
            bigNumX += 35;
        }

        var smallNumX = 185;
        for (num in smallNumbers)
        {
            num.setPosition(smallNumX, 123);
            smallNumX += 15;
        }
    }

    public function init(songData:Dynamic):Void
    {
        this.songData = songData;
        refreshDisplay();
    }

    public function refreshDisplay():Void
    {
        if (songData == null)
        {
            songText.text = 'Random';
            //pixelIcon.visible = false;
            //ranking.visible = false;
            //blurredRanking.visible = false;
            favIcon.visible = false;
            newText.visible = false;
        }
        else
        {
            songText.text = songData.fullSongName;
            //if (songData.songCharacter != null) pixelIcon.setCharacter(songData.songCharacter);
            //pixelIcon.visible = true;
            updateBPM(Std.int(songData.songStartingBpm) ?? 0);
            updateDifficultyRating(songData.difficultyRating ?? 0);
            //updateScoringRank(songData.scoringRank);
            newText.visible = songData.isNew;
            favIcon.visible = songData.isFavorite;
        }
        updateSelected();
    }

    function updateBPM(newBPM:Int):Void
    {
        for (i in 0...smallNumbers.length)
            smallNumbers[i].digit = Math.floor(newBPM / Math.pow(10, 2 - i)) % 10;
    }

    function updateDifficultyRating(newRating:Int):Void
    {
        for (i in 0...bigNumbers.length)
            bigNumbers[i].digit = Math.floor(newRating / Math.pow(10, 1 - i)) % 10;
    }

    /*function updateScoringRank(newRank:Null<ScoringRank>):Void
    {
        //ranking.rank = newRank;
        //blurredRanking.rank = newRank;
    }*/

    function set_selected(value:Bool):Bool
    {
        selected = value;
        updateSelected();
        return selected;
    }

    function updateSelected():Void
    {
        songText.alpha = selected ? 1 : 0.5;
        capsule.animation.play(selected ? "selected" : "unselected");
        //ranking.alpha = selected ? 1 : 0.7;
        favIcon.alpha = selected ? 1 : 0.6;
    }

    public function playSelectAnimation():Void
        FlxTween.tween(this.scale, {x: 1.1, y: 1.1}, 0.1, {ease: FlxEase.quadOut});

    public function playDeselectAnimation():Void
        FlxTween.tween(this.scale, {x: 1, y: 1}, 0.1, {ease: FlxEase.quadIn});

    override function update(elapsed:Float):Void
    {
        if (doLerp)
        {
            x = FlxMath.lerp(x, targetPos.x, 0.3);
            y = FlxMath.lerp(y, targetPos.y, 0.4);
        }

        super.update(elapsed);
    }

    public function updatePosition(targetX:Float, targetY:Float):Void
        targetPos.set(targetX, targetY);
}