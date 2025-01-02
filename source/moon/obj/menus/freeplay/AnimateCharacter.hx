package moon.obj.menus.freeplay;

import flxanimate.FlxAnimate;
import moon.states.menus.Freeplay.FreeplayCharacter;
import moon.states.menus.Freeplay.FreeplayAFKAnims;

class AnimateCharacter extends FlxAnimate
{
    /**
     * Contains all the character's data from the json.
     */
    public var charData:FreeplayCharacter;

    public var curAfkAnim:String;
    public var canBop:Bool = false;
    /**
     * Timer used for playing AFK Animations.
     */
    private var AFK_TIMER:Float = 0;

    public function new(x:Float, y:Float, charData:FreeplayCharacter)
    {
        super(x, y);
        if(charData != null)
        {
            this.charData = charData;
            loadAtlas('assets/images/menus/freeplay/${charData.name}/${charData.folderName}');
        }
        else throw 'Character Data not found. Are you sure the path is correct?';
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        AFK_TIMER += elapsed;

        if(charData.afkAnims != null)
        {
            for (i in 0...charData.afkAnims.length)
            {
                final _time = charData.afkAnims[i].time;
                if(_time > AFK_TIMER)
                {
                    curAfkAnim = charData.afkAnims[i].anim;
                    canBop = false;
                }
            }
        }
    }
}