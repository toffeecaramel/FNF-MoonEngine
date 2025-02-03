package moon.obj.notes;

import backend.dependency.MoonSprite;

class StrumNote extends MoonSprite
{
    public var direction:String = 'left';

    public function new(skin:String = 'default', direction:String = 'left', isCPU:Bool = false)
    {
        super();
        centerAnimations = true;

        this.direction = direction;
        //TODO: ADD A JSON (or hscript) FILE WITH PROPERTIES TO ALLOW THE MODDER TO MESS AROUND WITH ANIMATIONS.
        frames = Paths.getSparrowAtlas('UI/game-ui/notes/$skin/strumline');
        animation.addByPrefix('$direction-static', '$direction-static', 24, true);
        animation.addByPrefix('$direction-press', '$direction-press', 24, false);
        animation.addByPrefix('$direction-confirm', '$direction-confirm', 32, false);
        updateHitbox();

        animation.onFinish.add(function(anim:String)
        {
            if(anim =='$direction-confirm') playAnim((isCPU) ? '$direction-static' : '$direction-press', false);

            //if (anim == '$direction-press')
                //animation.stop(); // ugh
        });

        playAnim('$direction-static', true);
    }

    override public function update(elapsed:Float)
    {super.update(elapsed);}
}