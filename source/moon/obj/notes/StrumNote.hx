package moon.obj.notes;

import backend.dependency.FNFSprite;

class StrumNote extends FNFSprite
{
    public function new(skin:String = 'default', direction:String = 'left')
    {
        super();

        //TODO: ADD A JSON (or hscript) FILE WITH PROPERTIES TO ALLOW THE MODDER TO MESS AROUND WITH ANIMATIONS.
        frames = Paths.getSparrowAtlas('UI/game-ui/notes/$skin/strumline');
        animation.addByPrefix('$direction-static', '$direction-static', 24, true);
        animation.addByPrefix('$direction-press', '$direction-press', 24, false);
        animation.addByPrefix('$direction-confirm', '$direction-confirm', 24, false);
        updateHitbox();

        playAnim('$direction-static', true);
    }

    override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
    {
        super.playAnim(AnimName, Force, Reversed, Frame);
        centerOffsets(); // - Did the override just for these, thanks sword :3
        centerOrigin();
    }
}