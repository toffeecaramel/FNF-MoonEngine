package data;

import gameObjects.notes.*;
import states.PlayState;

/****/

class Timings
{
    public static var accuracy:Float;
    public static var trueAccuracy:Float;
    public static var judgementRates:Array<Float>;
    public static var msThreshold:Float = 0;

    public static var scoreRating:Array<ScoreRating> = [
        new ScoreRating("S+", 100),
        new ScoreRating("S", 95),
        new ScoreRating("A", 90),
        new ScoreRating("B", 85),
        new ScoreRating("C", 80),
        new ScoreRating("D", 75),
        new ScoreRating("E", 70),
        new ScoreRating("F", 65)
    ];

    public static var judgements:Array<Judgement> = [
        new Judgement("sick", 0, 45, 100, 'SFC'),
        new Judgement("good", 1, 90, 75, 'GFC'),
        new Judgement("bad", 2, 135, 25, 'FC'),
        new Judgement("shit", 3, 157.5, -50, 'SDCB'),
        new Judgement("miss", 4, 180, -100)
    ];

    public static var ratingFinal:String = "N/A";
    public static var notesHit:Int = 0;
    public static var segmentsHit:Int = 0;
    public static var comboDisplay:String = '';

    public static var gottenJudgements:Map<String, Int> = new Map<String, Int>();
    public static var smallestRating:String;

    public static function callAccuracy()
    {
        accuracy = 0.001;
        trueAccuracy = 0;
        judgementRates = new Array<Float>();

        var biggestThreshold:Float = 0;
        for (judgement in judgements) 
        {
            if (judgement.threshold > biggestThreshold)
                biggestThreshold = judgement.threshold;
        }
        msThreshold = biggestThreshold;

        for (judgement in judgements)
        {
            gottenJudgements.set(judgement.name, 0);
        }

        smallestRating = 'sick';
        notesHit = 0;
        segmentsHit = 0;

        ratingFinal = "N/A";
        comboDisplay = '';
    }

    public static function updateAccuracy(judgement:Int, ?isSustain:Bool = false, ?segmentCount:Int = 1)
    {
        if (!isSustain) 
        {
            notesHit++;
            accuracy += Math.max(0, judgement);
        }
        else
            accuracy += Math.max(0, judgement) / segmentCount;

        trueAccuracy = accuracy / notesHit;
        updateFCDisplay();
        updateScoreRating();
    }

    public static function updateFCDisplay()
    {
        comboDisplay = '';
        for (judgement in judgements) 
        {
            if (judgement.name == smallestRating && judgement.comboDisplay != null)
                comboDisplay = judgement.comboDisplay;
        }
        if (comboDisplay == '' && PlayState.misses < 10)
            comboDisplay = 'SDCB';
    }

    public static function getAccuracy():Float
        return trueAccuracy;

    public static function updateScoreRating() 
    {
        var biggest:Int = 0;
        for (score in scoreRating)
        {
            if (score.threshold <= trueAccuracy && score.threshold >= biggest)
            {
                biggest = score.threshold;
                ratingFinal = score.name;
            }
        }
    }

    public static function returnScoreRating():String
        return ratingFinal;
}

class Judgement
{
    public var name:String;
    public var id:Int;
    public var threshold:Float;
    public var score:Int;
    public var comboDisplay:String;

    public function new(name:String, id:Int, threshold:Float, score:Int, ?comboDisplay:String = "???")
    {
        this.name = name;
        this.id = id;
        this.threshold = threshold;
        this.score = score;
        this.comboDisplay = comboDisplay;
    }
}

class ScoreRating
{
    public var name:String;
    public var threshold:Int;

    public function new(name:String, threshold:Int)
    {
        this.name = name;
        this.threshold = threshold;
    }
}
