package moon.utilities;

import flixel.math.FlxMath;
import backend.dependency.FNFSound;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class AudioUtils
{
    public static var songInFocus:String;
    public static var songList:Array<FNFSound> = [];

    /**
     * Creates a song list, used for mainly fading them out and more.
     * @param list The song list, make sure it follows `{path:String, strId:String}` format.
     */
     public static function createSongList(list:Array<{path:String, strId:String}>)
    {
        for (i in 0...list.length)
        {
            var exists = false;
            for (existingSong in songList)
                if (existingSong.strID == list[i].strId)
                {
                    exists = true;
                    break;
                }
    
            if (!exists)
            {
                var song = cast new FNFSound().loadEmbedded(Paths.music(list[i].path), true);
                song.ID = i;
                song.strID = list[i].strId;
                songList.push(song);
            }
        }
    
        for (i in 0...songList.length)
        {
            FlxG.sound.list.add(songList[i]);
            songList[i].volume = (i == 0) ? 1 : 0;
            songList[i].play();
        }
    
        songInFocus = songList[0].strID;

        trace('Created song list! length is ${songList.length}', "DEBUG");
    }

    /**
     * Checks whenever the songs are not in sync.
     * Make sure to call this on stepHit.
     */
    public static function checkSongsDesync():Void
    {
        for (i in 0...songList.length)
        {
            if(i!=0&&(songList[i].time >= Conductor.songPosition + 25 || songList[i].time <= Conductor.songPosition - 25))
            {
                songList[i].pause();
                songList[i].time = songList[0].time;
                songList[i].play();
            }
        }
    }

    /**
     * Call this on update, it will do all checks for all audios.
     * @param elapsed 
     */
    public static function updateChecks(elapsed:Float)
    {
        for (song in songList)
        {
            if(song != null)
            {
                song.volume = FlxMath.lerp(song.volume, (song.strID == songInFocus) ? 1 : 0, elapsed * 8);
            }
        }
    }

    /**
     * This will kill any audio instance in the songList.
     */
    public static function killSongs()
    {
        for (i in 0...songList.length)
        {
            songList[i].stop();
            songList[i].kill();
            FlxG.sound.list.remove(songList[i]);
        }

        songInFocus = null;
        songList = [];
    }
}