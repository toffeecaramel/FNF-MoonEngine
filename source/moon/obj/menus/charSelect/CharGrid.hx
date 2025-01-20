package moon.obj.menus.charSelect;

import flixel.group.FlxSpriteGroup;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class CharGrid extends FlxSpriteGroup
{
    public var columns:Int;
    public var spacing:Int;
    public var currentSelected:Int = 0;

    public function new(columns:Int, spacing:Int)
    {
        super();
        this.columns = columns;
        this.spacing = spacing;
    }

    public function setupGrid(items:Array<String>):Void
    {
        clear();
        for (i in 0...items.length)
        {
            final row = Math.floor(i / columns);
            final col = i % columns;

            var item = new CharSelectIcon(items[i]);
            item.x = col * spacing;
            item.y = row * spacing;
            item.introAnim();
            add(item);
        }
    }

    public function scroll(direction:Int):Void
    {
        currentSelected += direction;

        if (currentSelected < 0)
            currentSelected = length - 1;
        else if (currentSelected >= length)
            currentSelected = 0;

        highlightSelectedItem();
    }

    public function getSelected()
        return members[currentSelected];

    public function highlightSelectedItem():Void
    {
        for (i in 0...length)
        {
            var item = cast members[i];
            item.highlight(i == currentSelected);
        }
    }

    public function enterTransition():Void
    {
        for (item in members)
        {
            item.x -= 700; // Example transition
            FlxTween.tween(item, {x: item.x + 700}, 0.6, {ease: FlxEase.circOut});
        }
    }

    public function exitTransition():Void
    {
        for (item in members)
        {
            FlxTween.tween(item, {x: item.x - 700}, 0.6, {ease: FlxEase.circIn});
        }
    }
}
