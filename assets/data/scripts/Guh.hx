function create()
{
    trace('wow, I just got here');
    var tSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    //tSprite.camera = camHUD;
    add(tSprite);
}

function beatHit()
{
    trace('beathit');
}
