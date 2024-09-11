package source.subStates;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import sys.thread.Mutex;
import sys.thread.Thread;
import gameObjects.notes.Note;
import states.data.MusicState.MusicSubState;
import states.*;
import data.chart.Chart;
import UserSettings;

class LoadingSubState extends MusicSubState
{
    var nSkin:String = UserSettings.callSetting('Noteskin');
    var lilmutex:Mutex;
	
	var loader:FlxGroup;
    var chart:Chart;

	public function new()
	{
		super();
        lilmutex = new Mutex();
		
		loader = new FlxGroup();
		add(loader);

        var preloadThread = Thread.create(function()
        {
            lilmutex.acquire();
            chart = new Chart('assets/data/charts/${PlayState.song}/chart-${PlayState.difficulty}.json');

            var notesThing = [];
            for (noteData in chart.notes) 
            {
                var note:Note = Note.returnDefaultNote(nSkin, 
                    noteData.type, noteData.time, 
                    noteData.direction, true, false);
                note.setup(note);
                note.updateHitbox();
                notesThing.push(note);
            
                var susLength:Float = noteData.duration / Conductor.stepCrochet;
            
                for (susNote in 0...Math.floor(susLength)) {
                    var oldNote:Note = notesThing[Std.int(notesThing.length - 1)];
                    var sustainNote:Note = Note.returnDefaultNote(nSkin, 
                        noteData.type,
                        noteData.time + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet,
                        noteData.direction, noteData.mustHit, true, oldNote);
                    sustainNote.scrollFactor.set();
                    sustainNote.setup(sustainNote);
                    sustainNote.updateHitbox();
                    notesThing.push(sustainNote);
                    load(sustainNote);
                }
            
                note.scrollFactor.set();
                load(note);
            }

            FlxG.switchState(new PlayState());
            lilmutex.release();
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

    function load(item:FlxBasic)
    {
        loader.add(item);
        loader.remove(item);
    }
}