package backend.user;

import flixel.util.FlxSave;

typedef Data = {
    var score:Int;
    var rank:String;
    var difficulty:Int;
    var isUnlocked:Bool;
    var isNew:Bool;
    var isFavorite:Bool;
}

class SongData
{
    public static var save:FlxSave = new FlxSave();
    public static var songDataMap:Map<String, Data>;

    public static function init()
    {
    	save.bind("ME-SongData");
        loadData();
        trace(songDataMap, "DEBUG");
    }

    /**
     * Adds a new song data entry or updates an existing one.
     */
    public static function updateData(song:String, score:Int, rank:String, difficulty:Int, isUnlocked:Bool, isNew:Bool, isFavorite:Bool):Void
    {
        songDataMap.set(song, {score: score, rank: rank, difficulty: difficulty, isUnlocked: isUnlocked, isNew: isNew, isFavorite: isFavorite});
        saveData();
    }

    /**
     * Returns the data for a specific song.
     */
    public static function getSongData(song:String):Null<Data>
        return songDataMap.get(song);

    /**
     * Checks if a song is unlocked.
     */
    public static function isSongUnlocked(song:String):Bool
        return songDataMap.exists(song) ? songDataMap.get(song).isUnlocked : false;

    /**
     * Updates the score and rank for a specific song.
     */
    public static function updateScore(song:String, newScore:Int, newRank:String):Void
    {
        if (songDataMap.exists(song))
        {
            final data = songDataMap.get(song);
            if (newScore > data.score)
            {
                data.score = newScore;
                data.rank = newRank;
                saveData();
            }
        }
        else
            trace('Song $song does not exist.', "ERROR");
    }

    /**
     * Marks a song as unlocked.
     */
    public static function unlockSong(song:String):Void
    {
        if (songDataMap.exists(song))
        {
            songDataMap.get(song).isUnlocked = true;
            saveData();
        }
        else
            trace('Song $song does not exist.', "ERROR");
    }

    public static function loadData():Void
    {
   		songDataMap = save.data.songDataMap ?? new Map<String, Data>();
   		saveData();
    }

    /**
     * Saves all song data to the save.
     */
    public static function saveData():Void
    {
        save.data.songDataMap = songDataMap;
        save.flush();
    }

    /**
     * Clears the save data for all songs (for resetting).
     */
    public static function clearData():Void
    {
        songDataMap = new Map<String, Data>();
        save.data.songDataMap = songDataMap;
        save.flush();
    }
}
