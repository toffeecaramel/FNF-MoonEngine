package gameObjects;

import flixel.FlxG;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import data.*;
import data.depedency.*;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;
import sys.io.File;

using StringTools;

typedef CharacterData = {
    var isPlayer:Bool;
    var flipX:Bool;
    var objectOffsets:Array<Float>;
    var camOffsets:Array<Float>;
    var quickDancer:Bool;
    var healthbarColors:Array<Int>;
    var animations:Array<AnimationData>;
}

typedef AnimationData = {
    var name:String;
    var prefix:String;
    var x:Float;
    var y:Float;
    var fps:Int;
    var looped:Bool;
}

class Character extends FNFSprite {
    public var debugMode:Bool = false;

    public var isPlayer:Bool = false;
    public var curCharacter:String = 'bf';

    public var holdTimer:Float = 0;

    public var characterData:CharacterData;
    public var adjustPos:Bool = true;

    public function new() {
        super(x, y);
    }

    public function setCharacter(x:Float, y:Float, character:String):Character {
        curCharacter = character;
        antialiasing = true;

        trace(curCharacter);
        frames = FlxAtlasFrames.fromSparrow(Paths.character('$curCharacter/$curCharacter.png'), Paths.character('$curCharacter/$curCharacter.xml'));

        var rawjson:String = File.getContent('assets/data/characters/$curCharacter/$curCharacter.json');
        characterData = Json.parse(rawjson);

        isPlayer = characterData.isPlayer;
        flipX = characterData.flipX;

        for (anim in characterData.animations)
        {
            animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.looped);
            addOffset(anim.name, anim.x, anim.y);
        }

        playAnim('idle');

        if (isPlayer) {
            flipX = !flipX;
            if (!curCharacter.startsWith('bf'))
                flipLeftRight();
        } 
        else if (curCharacter.startsWith('bf')) 
            flipLeftRight();

        if (adjustPos) {
            x += characterData.objectOffsets[0];
            y += (characterData.objectOffsets[1] - (frameHeight * scale.y));
        }

        this.x = x;
        this.y = y;

        return this;
    }

    function flipLeftRight():Void 
    {
        var oldRight = animation.getByName('singRIGHT').frames;
        animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
        animation.getByName('singLEFT').frames = oldRight;

        if (animation.getByName('singRIGHTmiss') != null) 
        {
            var oldMiss = animation.getByName('singRIGHTmiss').frames;
            animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
            animation.getByName('singLEFTmiss').frames = oldMiss;
        }
    }

    override function update(elapsed:Float) 
    {
        if (!isPlayer)
        {
            if (animation.curAnim.name.startsWith('sing'))
                holdTimer += elapsed;

            var dadVar:Float = 4;
            if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001) 
            {
                dance();
                holdTimer = 0;
            }
        }

        var curCharSimplified:String = simplifyCharacter();
        switch (curCharSimplified) {
            case 'gf':
                if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
                    playAnim('danceRight');
                if (animation.curAnim.name.startsWith('sad') && animation.curAnim.finished)
                    playAnim('danceLeft');
        }

        if (animation.curAnim.finished && animation.curAnim.name == 'idle')
            if (animation.getByName('idlePost') != null)
                animation.play('idlePost', true, false, 0);

        super.update(elapsed);
    }

    private var danced:Bool = false;

    public function dance(?forced:Bool = false) 
    {
        if (!debugMode) 
        {
            var curCharSimplified:String = simplifyCharacter();
            switch (curCharSimplified) {
                case 'gf':
                    if (!animation.curAnim.name.startsWith('hair') && !animation.curAnim.name.startsWith('sad')) {
                        danced = !danced;

                        if (danced)
                            playAnim('danceRight', forced);
                        else
                            playAnim('danceLeft', forced);
                    }
                default:
                    if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null) {
                        danced = !danced;
                        if (danced)
                            playAnim('danceRight', forced);
                        else
                            playAnim('danceLeft', forced);
                    } else
                        playAnim('idle', forced);
            }
        }
    }

    override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
        try {
            if (animation.getByName(AnimName) != null)
                super.playAnim(AnimName, Force, Reversed, Frame);
        } catch (e:Dynamic) {
            trace("Ooop the character returned a null anim.");
        }

        if (curCharacter == 'gf') {
            if (AnimName == 'singLEFT')
                danced = true;
            else if (AnimName == 'singRIGHT')
                danced = false;

            if (AnimName == 'singUP' || AnimName == 'singDOWN')
                danced = !danced;
        }
    }

    public function simplifyCharacter():String {
        var base = curCharacter;
        if (base.contains('-'))
            base = base.substring(0, base.indexOf('-'));
        return base;
    }
}
