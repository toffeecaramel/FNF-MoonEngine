package moon.obj.game;

import flixel.FlxG;
import flixel.group.FlxGroup;
import backend.dependency.FNFSound;

using StringTools;

enum SongState {
	PLAY;
	PAUSE;
	STOP;
	KILL;
}

/**
 * Class meant to handle over gameplay's Inst and Voices.
 **/
class Song extends FlxTypedGroup<FNFSound>
{
	/**
	 * Sets the song's state, those being: `PLAY`, `PAUSE`, `STOP` & `KILL`.
	 */
	public var curState(default, set):SongState = PLAY;

	/**
	 * Set the song's pitch.
	 */
	public var pitch(default, set):Float = 1;

	/**
	 * The song's current time.
	 */
	@:isVar public var time(get, set):Float = 0;

	/**
	 * Get the song's full time.
	 */
	@:isVar public var fullLength(get, never):Float = 0;

	/**
	 * Get whether or not the song is playing.
	 */
	@:isVar public var playing(get, never):Bool = true;

	/**
	 * Creates the gameplay's song.
	 * @param audios The array containing audio info.
	 * Array example: `[{song: "tutorial", type: Inst, charPath: "pico"}]`
	 */
	public function new(audios:Array<{song:String, type:MusicType, ?charPath:String}>)
	{
		super();

		for (i in 0...audios.length)
		{
			recycle(FNFSound, function():FNFSound
			{
				final extPath = (audios[i].charPath != null) ? audios[i].charPath : 'default';
				var music = cast new FNFSound().loadEmbedded('assets/charts/${audios[i].song}/$extPath/${audios[i].type}.ogg', false, true);
				music.musicID = audios[i].type;
				FlxG.sound.list.add(cast music); // - I hate the fact that I have to cast it
				return music;
			});
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	/**
	 * Checks if any audio is out of sync, then re-syncs them by calling `resync()`.
	 * It is recommended that this function is called on every step hit.
	 */
	public function checkDesync():Void
	{
		for (i in 0...members.length)
			if ((members[i].musicID == Inst) &&
			(members[i].time >= Conductor.songPosition + 25 || members[i].time <= Conductor.songPosition - 25)) 
				resync();
	}

	/**
	 * Pauses all the songs playing and syncs their time.
	 */
	public function resync():Void
	{
		for(i in 0...members.length)
		{
			if(members[i] != null)
			{
				trace('Music is resyncing! from ${members[i].time} to ${Conductor.songPosition}', 'WARNING');

				curState = PAUSE;
				(members[i].musicID == Inst) ? Conductor.songPosition = members[i].time : members[i].time = Conductor.songPosition;
				curState = PLAY;
			}
		}
	}

	////////////////////////////////////////////////////////////////////////////////////

	@:noCompletion public function set_curState(state:SongState = PLAY):SongState
	{
		curState = state;
		for (i in 0...members.length)
		{
			switch(state)
			{
				case PLAY: members[i].play();
				case PAUSE: members[i].pause();
				case STOP: members[i].stop();
				case KILL: 
					FlxG.sound.list.remove(members[i]);
					members[i].kill();
			}
		}
		(state == PLAY) ? checkDesync() : null;
		return state;
	}

	@:noCompletion public function get_time():Float
	{
		var lastTime:Float = 0;
		for (i in 0...members.length)
			lastTime = members[i].time;

		return lastTime;
	}		

	@:noCompletion public function set_time(value:Float):Float
	{
		time = value;
		for(i in 0...members.length)
			members[i].time = value;

		return value;
	}

	@:noCompletion public function set_pitch(value:Float):Float
	{
		pitch = value;

		for (i in 0...members.length)
			members[i].pitch = pitch;

		return value;
	}

	@:noCompletion public function get_fullLength():Float
	{
		var lastLength:Float = 0;
		for (i in 0...members.length)
			lastLength = members[i].length;

		return lastLength;
	}		

	@:noCompletion public function get_playing():Bool
	{
		var isPlaying:Bool = false;
		for (i in 0...members.length)
			isPlaying = members[i].playing;

		return isPlaying;
	}		
}