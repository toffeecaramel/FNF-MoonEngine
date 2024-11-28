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
	public var pitch(default, set):Float = 1;

	public var curState(default, set):SongState = PLAY;

	public function new(audios:Array<{song:String, type:MusicType, ?charPath:String}>)
	{
		super();

		for (i in 0...audios.length)
		{
			recycle(FNFSound, function():FNFSound
			{
				final extPath = (audios[i].charPath != null) ? audios[i].charPath : 'default';
				var music = cast new FNFSound().loadEmbedded('assets/data/charts/${audios[i].song}/$extPath/${audios[i].type}.ogg', false, true);
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

	public function checkDesync():Void
	{
		for (i in 0...members.length)
			if ((members[i].musicID == Inst) &&
			(members[i].time >= Conductor.songPosition + 25 || members[i].time <= Conductor.songPosition - 25)) 
				resync();
	}

	public function resync():Void
	{
		for(i in 0...members.length)
		{
			//trace('Music is resyncing! from ${members[i].time} to ${Conductor.songPosition}', 'WARNING');
			curState = PAUSE;
			(members[i].musicID == Inst) ? Conductor.songPosition = members[i].time : members[i].time = Conductor.songPosition;
			curState = PLAY;
		}
	}

	@:noCompletion
	public function set_pitch(value:Float):Float
	{
		pitch = value;

		for (i in 0...members.length)
			members[i].pitch = pitch;

		return value;
	}

	@:noCompletion
	public function set_curState(state:SongState = PLAY):SongState
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
		return state;
	}
}