package moon.states.editors.chart;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.util.FlxGradient;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.util.FlxColor;
import moon.obj.notes.*;
import moon.obj.editors.*;
import moon.utilities.NoteUtils;
import flixel.ui.FlxButton;

using StringTools;

/**
 * This chart editor was made with <3 by Toffee & LunaMyria
 **/

/**
 * Editor Actions!
 * Ok so basically, whenever you do a thing that can be undone (with CTRL + Z)
 * it stores in an array with "editor actions" so that way, you can undo any changes!
 **/
enum EditorAction {
    AddNote(noteData:Dynamic);
    DeleteNote(noteData:Dynamic);

    //AddEvent(data:Dynamic);
    //DeleteEvent(data:Dynamic);
}

enum GridType {
    NOTES;
    EVENTS;
}

// - And here we go with the editor itself :)
class ChartEditor extends MusicState
{
    final gridSize:Int = 50;
    final kAmmount:Int = 8;
    var curSection:Int = 0;
    public static var lastSection:Int = 0;

    public var minX:Float = 0;
    public var maxX:Float = 0;
    final minY:Float = 0;
    public var maxY:Float = 0;

    private var inst:FlxSound;
    private var voices:FlxSound;

    private var _chart:Chart;

    private var _renderedLanes:FlxTypedGroup<FlxSprite>;
    private var _notes:FlxTypedGroup<Note>;

    var strumline:FlxSprite;
    private var dummyArrow:FlxSprite;
    private var moonTabs:MoonTabs;
    private var selectedNote:Note;
    private var startHandle:FlxSprite;
    private var endHandle:FlxSprite;
    private var durationIndicator:FlxSprite;

    var strumLineCam:FlxObject;

    public var camGlobal:FlxCamera;
    public var camHUD:FlxCamera;

    public var song:String;
    public var difficulty:String;

    private var actions:Array<EditorAction> = [];
    private var gridType:GridType = NOTES;

    public function new(song:String, difficulty:String):Void
    {
        super();
        this.song = song;
        this.difficulty = difficulty;

        // - Load up the chart
        _chart = new Chart('assets/data/charts/$song/chart-$difficulty.json');
        Conductor.changeBPM(_chart.bpm, _chart.timeSignature[0] / _chart.timeSignature[1]);
    }

    override public function create():Void {
        super.create();
        curSection = lastSection;
        camGlobal = FlxG.camera;
        camHUD = new FlxCamera();
        camHUD.bgColor = 0x00000000;
        FlxG.cameras.add(camHUD, false);

        minX = FlxG.width - (gridSize * kAmmount) - gridSize * 4 - 30;
        maxX = minX + gridSize * kAmmount;

        inst = new FlxSound().loadEmbedded('assets/data/charts/$song/Inst.ogg', false, true);
        FlxG.sound.list.add(inst);
        
        final path = (_chart.hasVoices) ? 'assets/data/charts/$song/Voices.ogg' : 'assets/data/charts/nullVoices.ogg';
        voices = new FlxSound().loadEmbedded(path, false, true);
        FlxG.sound.list.add(voices);

        inst.time = 0;
        maxY = getYfromStrum(inst.length);

        makeBG();
        
        dummyArrow = new FlxSprite().makeGraphic(gridSize, gridSize, FlxColor.WHITE);
        add(dummyArrow);

        _renderedLanes = new FlxTypedGroup<FlxSprite>();
        add(_renderedLanes);

        _notes = new FlxTypedGroup<Note>();
        add(_notes);

        generateGrid();

        for(nData in _chart.notes)
            addNote(getNoteX(nData.direction, nData.lane), Math.floor(getYfromStrum(nData.time)) + 1, nData);

        strumLineCam = new FlxObject(0, 0);
        strumLineCam.screenCenter(X);

        strumline = new FlxSprite(650, 0).loadGraphic(Paths.image('editors/charter/strumline'));
        add(strumline);
        
        var bar = new FlxSprite().makeGraphic(FlxG.width, 70, FlxColor.fromRGB(80, 80, 80));
        bar.scrollFactor.set();
        bar.alpha = 0.3;
        add(bar);

        final okay = ['arrowFunk', 'eventsGrid'];
        for (i in 0...okay.length)
        {
            var spr = new WhiteButton(FlxG.width / 1 - 130, 100 + (50 * i), Paths.image('editors/charter/${okay[i]}'), () -> toggleGridType(okay[i] == 'arrowFunk' ? NOTES : EVENTS));
            spr.camera = camHUD;
            add(spr);
        }
        
        FlxG.camera.follow(strumLineCam);
        
        var tabs = [
            {name: "Characters", tag: "characters"},
            {name: "Edit Properties", tag: "editproperties",}
        ];
        
        moonTabs = new MoonTabs(100, 50, tabs);
        moonTabs.camera = camHUD;
        add(moonTabs);

        var test = new TooltipButton(250, 250, Paths.image('editors/bIcons/copy'), 'This is a description text whatever :V', function(){trace('click!', "DEBUG");});
        moonTabs.addToTab("editproperties", test);
        test.camera = camHUD;
    }

    private function makeBG():Void
    {
        var coolGradient = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(30, 29, 31));
        coolGradient.scrollFactor.set();
        add(coolGradient);
    }

    function generateGrid():Void
    {
        _renderedLanes.clear();
        final stepDuration:Float = Conductor.stepCrochet;
        final totalSteps:Int = Math.ceil(inst.length / stepDuration);
        
        for (i in 0...totalSteps)
        {
            final yPosition:Float = i * gridSize;

            _renderedLanes.recycle(FlxSprite, function():FlxSprite
            {
                var stepLine:FlxSprite = new FlxSprite().makeGraphic(Std.int(gridSize * kAmmount), 4, FlxColor.WHITE);
                stepLine.y = yPosition;
                stepLine.x = (FlxG.width - stepLine.width) - gridSize * 4 - 30;
                stepLine.alpha = 0.7;
                return stepLine;
            });
        }
    }

    private function toggleGridType(type:GridType):Void
    {
        gridType = type;
        switch(gridType) 
        {
            case NOTES:
            case EVENTS:
        }
        trace('congrats, you are at $gridType now.');
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
            changeSection(curSection + 1, false);

        checkMouseInteractions(elapsed);
        checkKeyboardInteractions(elapsed);

        Conductor.songPosition = inst.time;
        strumline.y = FlxMath.lerp(strumline.y, getYfromStrum(Conductor.songPosition), elapsed * 28);
        strumLineCam.y = strumline.y + (FlxG.height / 2.6) - 25;
    }

    private function checkMouseInteractions(elapsed:Float):Void
    {   
        if (FlxG.mouse.y >= minY && FlxG.mouse.y <= maxY)
        {
            final gridX = Math.floor(FlxG.mouse.x / gridSize) * gridSize;
            final curMouseX = FlxMath.bound(gridX, minX, maxX - gridSize);
            final curMouseY = Math.floor(FlxG.mouse.y / gridSize) * gridSize;
    
            dummyArrow.x = FlxMath.lerp(dummyArrow.x, curMouseX, elapsed * 32);
            dummyArrow.y = FlxMath.lerp(dummyArrow.y, curMouseY, elapsed * 32);
    
            if (FlxG.mouse.x >= minX && FlxG.mouse.x < maxX)
            {
                if (!FlxG.mouse.overlaps(_notes))
                {
                    if (FlxG.mouse.justPressed)
                        addNote(curMouseX, curMouseY, null, true);
                }
                else
                {
                    _notes.forEachAlive(function(note:Note)
                    {
                        if (FlxG.mouse.overlaps(note))
                        {
                            if (FlxG.mouse.justPressed) selectNote(note);
                            else if (FlxG.mouse.pressedRight) deleteNoteData(note);
                        }
                    });
                }
            }
        }
    }

    private function checkKeyboardInteractions(elapsed:Float):Void
    {
        if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.Z) {
            undoLastAction(); // Undo last action if CTRL + Z is pressed
        }

        if (FlxG.keys.justPressed.SPACE)
            (inst.playing) ? setAudioState('pause') : setAudioState('play');

        var shiftThing:Int = 1;
        if (FlxG.keys.pressed.SHIFT)
            shiftThing = 4;

        if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
            changeSection(curSection + shiftThing);
        if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
            changeSection(curSection - shiftThing);
    }

    private function addNote(x:Float, y:Float, ?noteData, addedByMouse:Bool = false):Void
    {
        final colIndex = Math.floor((x - minX) / gridSize);
        final lane = (colIndex >= 4) ? "P1" : "Opponent";
        final direction = NoteUtils.numberToDirection(colIndex % 4);

        if (noteData == null) 
        {
            noteData = {
                type: "DEFAULT",
                time: getStrumFromY(y),
                lane: lane,
                direction: direction,
                duration: 0.0,
            };
            _chart.notes.push(noteData);
        }
        final xVal = getNoteX(direction, lane);

        _notes.recycle(Note, function():Note
        {
            var note:Note = Note.returnDefaultNote(UserSettings.callSetting('Noteskin'), noteData.type, 
            noteData.time, noteData.direction, noteData.lane, false);

            note.setGraphicSize(gridSize - 2, gridSize - 2);
            note.antialiasing = true;
            note.updateHitbox();
            note.x = xVal;
            note.y = y;
            return note;

            if(addedByMouse) selectNote(note);

        });
        if(addedByMouse)
        {
            addAction(EditorAction.AddNote(noteData));
            playSFX('addNote');
        }
    }

    function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
    {
        curSection = sec;

        if (updateMusic) {
            inst.pause();
            voices.pause();
            inst.time = sectionStartTime();
            voices.time = inst.time;
            updateCurStep();
        }
    }

    private function setAudioState(st:String = 'play')
    {
        final audios = [inst, voices];
        for (yeah in audios) {
            if(yeah != null) {
                switch(st) {
                    case 'play': yeah.play(); yeah.volume = 1;
                    case 'pause': yeah.pause();
                    case 'stop': yeah.stop();
                    case 'kill': yeah.stop(); yeah.kill(); FlxG.sound.list.remove(yeah);
                }
            }
        }
    }

    private function getNoteX(direction:String, lane:String):Float
    {
        final baseX = (lane == 'P1') ? (minX + 4 * gridSize) : minX;
        final directionIndex = NoteUtils.directionToNumber(direction);
        return baseX + directionIndex * gridSize;
    }

    private function undoLastAction():Void
    {
        if (actions.length == 0) return;
        var lastAction = actions.pop();
        
        switch(lastAction)
        {
            case AddNote(noteData): removeActualNote(noteData);
            case DeleteNote(noteData): restoreNote(noteData);
        }

        playSFX('undo');
    }

    private function selectNote(note:Note):Void
    {
        selectedNote = note;
        playSFX('noteSelect');
    }

    private function deselectNote():Void
    {
        selectedNote = null;
        startHandle.visible = false;
        endHandle.visible = false;
        durationIndicator.visible = false;
    }

    private function deleteNoteData(note:Note):Void
    {
        addAction(EditorAction.DeleteNote({
            type: note.type,
            time: note.strumTime,
            lane: note.lane,
            direction: note.noteDir,
            duration: note.sustainLength
        }));
        removeActualNote(null, note);

        playSFX('deleteNote');
    }

    private function removeActualNote(?noteData:Dynamic, ?note:Note):Void
    {
        if (noteData != null)
        {
            _chart.notes = _chart.notes.filter(n -> n != noteData);
            
            _notes.forEachAlive(function(noteD:Note)
            {
                if (noteD != null && noteD.matchesData(noteData))
                {
                    noteD.kill();
                    _notes.remove(noteD);
                    noteD.destroy();
                }
            });
        }
        else if (note != null)
        {
            _chart.notes = _chart.notes.filter(n -> !note.matchesData(n));
            note.kill();
            _notes.remove(note);
            note.destroy();
        }
    }

    private function restoreNote(noteData:Dynamic):Void {
        _chart.notes.push(noteData); // Add back to chart data
        addNote(getNoteX(noteData.direction, noteData.lane), getYfromStrum(noteData.time), noteData, false); // Render note
    }
    
    private function addAction(action:EditorAction):Void {
        actions.push(action);
    }

    private function playSFX(name:String):Void
    {
        if(!inst.playing)
            FlxG.sound.play(Paths.sound('editors/chartEditor/$name'), UserSettings.callSetting('Editor Sounds') / 100);
    }

    private function getYfromStrum(strumTime:Float):Float
        return FlxMath.remapToRange(strumTime, 0, inst.length, 0, (inst.length / Conductor.stepCrochet) * gridSize);

    private function getStrumFromY(y:Float):Float
        return FlxMath.remapToRange(y, 0, (inst.length / Conductor.stepCrochet) * gridSize, 0, inst.length);

    function sectionStartTime():Float
    {
        var daBPM:Float = _chart.bpm;
        var daPos:Float = 0;
        for (i in 0...curSection)
            daPos += 4 * (1000 * 60 / daBPM);
        
        return daPos;
    }
}
