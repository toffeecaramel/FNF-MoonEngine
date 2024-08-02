package data;

enum JudgementsTiming
{
    sick;
    good;
    bad;
    shit;
    miss;
}

class Timings
{
    public static var judgementsMap:Map<JudgementsTiming, Array<Dynamic>> = [
        sick => ["sick", 0, 45, 350, 100, "SFC"],
        good => ["good", 1, 90, 150, 75, "GFC"],
        bad => ["bad", 2, 135, 0, 25, "FC"],
        shit => ["shit", 3, 157.5, -50, -150, "SDCB"],
        miss => ["miss", 4, 180, -100, -175, "SDCB"]
    ];

    public static var accRanks:Map<String, Int> = [
        "S+" => 100,
        "S" => 97,
        "A" => 92,
        "B" => 85,
        "C" => 72,
        "D" => 65,
        "E" => 57,
        "F" => 50
    ];

    public static var msThreshold:Float = 0;

    public static function getParameters(jt:JudgementsTiming):Array<Dynamic>
    {
        return judgementsMap.get(jt);
    }
}