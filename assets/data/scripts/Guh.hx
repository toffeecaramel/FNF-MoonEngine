
function create()
{
    trace('wow, I just got here');
    var mum = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    //mum.camera = camHUD;
    add(mum);
}

function beatHit()
{
    trace('beathit');
}
