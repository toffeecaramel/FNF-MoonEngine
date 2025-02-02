package moon.obj.notes;

import backend.dependency.FNFSprite;

class StrumNote extends FNFSprite
{
    public var direction:String = 'left';

    public function new(skin:String = 'default', direction:String = 'left', isCPU:Bool = false)
    {
        super();
        this.direction = direction;
        //TODO: ADD A JSON (or hscript) FILE WITH PROPERTIES TO ALLOW THE MODDER TO MESS AROUND WITH ANIMATIONS.
        frames = Paths.getSparrowAtlas('UI/game-ui/notes/$skin/strumline');
        animation.addByPrefix('$direction-static', '$direction-static', 24, true);
        animation.addByPrefix('$direction-press', '$direction-press0', 24, false);
        animation.addByPrefix('$direction-confirm', '$direction-confirm', 32, false);
        updateHitbox();

        animation.onFinish.add(function(anim:String)
        {
            final confirmAnim = '$direction-confirm'; //gotta do it like this lol
            final pressAnim = '$direction-press';
            final staticAnim = '$direction-static';
            switch(anim)
            {
                // the curse of not being able to use $ here...
                case confirmAnim: playAnim((isCPU) ? staticAnim : pressAnim, true);
            }
        });

        playAnim('$direction-static', true);
    }

    override public function update(elapsed:Float)
    {super.update(elapsed);}

    override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
    {
        super.playAnim(AnimName, Force, Reversed, Frame);
        centerOffsets(); // - Did the override just for these, thanks sword :3
        centerOrigin();
    }
}