function create()
{
    trace('This is a warning test', 'WARNING');
    trace('And this is a error test', 'ERROR');
    trace('You are green now', 'DEBUG');
    trace('DAMN');
    //var tSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    //tSprite.camera = camHUD;
    //add(tSprite);

        //for (i in 0...game.playerStrumline.members.length)
        //FlxTween.tween(game.playerStrumline.members[i], {x: game.playerStrumline.members[i].x - 19},
         //   Conductor.crochet / 1000 - 0.01, {ease: FlxEase.circOut, type: PINGPONG});
}

function beatHit()
{
    //game.camHUD.zoom += 0.04;
    game.camGame.zoom += 0.03;

    //for (i in 0...game.playerStrumline.members.length)
    //    game.playerStrumline.members[i].y += 50;
}

function onNoteHit(note, character, judgement)
{

}
