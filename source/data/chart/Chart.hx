package data.chart;

import haxe.Json;
import sys.io.File;

typedef NoteData = {
    var direction:String;
    var mustHit:Bool;
    var time:Float;
}

typedef ChartData = {
    var bpm:Float;
    var notes:Array<NoteData>;
}

class Chart
{
    public var bpm:Float;
    public var notes:Array<NoteData>;

    public function new(jsonPath:String)
    {
        var jsonString = File.getContent(jsonPath);
        var chartData:ChartData = Json.parse(jsonString);
        this.bpm = chartData.bpm;
        this.notes = chartData.notes;
    }
}
