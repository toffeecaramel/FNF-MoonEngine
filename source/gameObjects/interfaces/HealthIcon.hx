package gameObjects.interfaces;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
    public function new(char:String = 'bf', isPlayer:Bool = false)
    {
        super();
        changeIcon(char, isPlayer);
        animation.add("neutral", [0], 0, false);
        animation.add("losing", [1], 0, false);
        animation.add("winning", [2], 0, false);
        animation.play("neutral");
    }

    public function changeIcon(char:String = 'bf', isPlayer:Bool = false)
    {
        loadGraphic('assets/data/characters/$char/icon.png', true, 150, 150);
        flipX = (isPlayer)?true:false;
        updateHitbox();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }
}