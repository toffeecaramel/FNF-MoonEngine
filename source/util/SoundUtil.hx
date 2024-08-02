package util;

import flixel.FlxG;
import haxe.ds.StringMap;

/**
    This class is used for utilities related to sounds, mostly used for
    gameplay since they have vocals and inst separated, I'm not really
    good with this buut lets see how this goes lol.
**/

/**
    Also this **enum** is just for separating the logic for gameplay song
    and interface song, that way it only applies the sync logic if
    its a gameplay type-of-song :D 

    ok im adding support to normal sounds too lmao
    I'm just so excited to use more enums because thanks
    to *@crowplexus* I now know how to use them!!

    and I might use them alot now lmao
**/

enum AudioType {
    INTERFACE;
    GAMEPLAY;
    SFX;
}

/**
    **enum** for setting the audio state, to any of these
    below.
**/

enum AudioState {
    PAUSE;
    STOP;
    PLAY;
}

class SoundUtil
{
    /**
        Initialize the audios array.
    **/
    public var audios:Array<{sound:FlxSound, type:AudioType}>;

    public function new()
    {
        audios = [];
    }

    /**
        Adds a sound to the audios array.
    **/
    public function addSound(sound:FlxSound, audType:AudioType):Void
    {
        audios.push({sound: sound, type: audType});
        //trace(audios);
    }

    /**
        Sets the state of a specific sound identified by its index.
    **/
    public function setStateByIndex(index:Int, sState:AudioState):Void
    {
        if (index >= 0 && index < audios.length)
        {
            var audio = audios[index].sound;
            switch (sState)
            {
                case PAUSE:
                    audio.pause();
                case STOP:
                    audio.stop();
                case PLAY:
                    audio.play();
            }
        }
    }

    /**
        Sets the state of a specific sound identified by its instance.
    **/
    public function setStateBySound(sound:FlxSound, sState:AudioState):Void
    {
        for (entry in audios)
        {
            if (entry.sound == sound)
            {
                switch (sState)
                {
                    case PAUSE:
                        sound.pause();
                    case STOP:
                        sound.stop();
                    case PLAY:
                        sound.play();
                }
                return;
            }
        }
    }

    public function pauseAudios():Void
    {
        for (entry in audios)
            if(entry.sound != null)
                entry.sound.pause();
    }

    public function playAudios():Void
    {
        for (entry in audios)
            if(!entry.sound.playing && entry.sound != null)
                entry.sound.play();
    }

    /**
        Syncs all GAMEPLAY sounds to the baseTime.
        TODO: FIX THIS CAUSE ITS JANKYYY EUGH
        lol i suck at this :sob:
    **/
    public function syncAll(baseTime:Float):Void
    {
        for (entry in audios)
        {
            if (entry.type == GAMEPLAY)
            {
                
            }
        }
    }
}