package moon.obj.menus.charSelect;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import moon.obj.menus.charSelect.CharSelectIcon;
import moon.states.menus.CharSelect.CharData;

class CharList extends FlxGroup
{
    public var items:Array<CharSelectIcon> = [];
    private var labels:Array<FlxText> = [];
    private var selectedIndex:Int = 0;

    private var startX:Float;
    private var startY:Float;

    public function new(chars:Array<CharData>, x:Float, y:Float)
    {
        super();
        startX = x;
        startY = y;
        
        for (i in 0...chars.length)
        {
            var item = new CharSelectIcon(chars[i].gamePrefix);
            item.setPosition(x, y + i * 70);
            item.introAnim();
            add(item);
            items.push(item);

            var label = new FlxText(x + item.width + 10, y + i * 70, 150, chars[i].name.toUpperCase());
            label.setFormat(null, 16, FlxColor.WHITE, LEFT);
            labels.push(label);
            add(label);
        }
        
        highlightSelectedItem();
    }

    public function highlightSelectedItem():Void
    {
        for (i in 0...items.length)
        {
            items[i].highlight(i == selectedIndex);
            labels[i].color = i == selectedIndex ? FlxColor.YELLOW : FlxColor.WHITE;
        }
    }

    public function scroll(direction:Int):Void
    {
        selectedIndex = FlxMath.wrap(selectedIndex + direction, 0, items.length - 1);
        highlightSelectedItem();
    }

    public function enterTransition():Void
    {
        final multiply = 8;
        for (i in 0...items.length)
        {
            var item = items[i];
            var label = labels[i];
            FlxTween.tween(item, {x: startX + 30 * multiply}, 0.6, {ease: FlxEase.circOut});
            FlxTween.tween(label, {x: startX + 80 * multiply}, 0.6, {ease: FlxEase.circOut});
        }
    }

    public function exitTransition():Void
    {
        for (i in 0...items.length)
        {
            var item = items[i];
            var label = labels[i];
            FlxTween.tween(item, {x: -item.width}, 0.6, {ease: FlxEase.circIn});
            FlxTween.tween(label, {x: -label.width}, 0.6, {ease: FlxEase.circIn});
        }
    }
}