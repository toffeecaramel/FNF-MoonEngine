function create()
{
    trace('wow, I just got here');
    var duh = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
    add(duh);
}

function beatHit()
{
    var d = FlxG.random.int(0, 20);
    trace('beatii' + d);
}
