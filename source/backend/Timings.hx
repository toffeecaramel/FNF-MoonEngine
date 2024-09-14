package backend;

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
        /**
            ID (0) 
            max milliseconds (1)
            score from it (2)
            percentage (3)
            health gain (4)
            judgement color (5)
            accuracy tag (6)
        **/
        sick => [0,   45,      350,   100,   2,       0xFF2883ff,       "SFC"],
        good => [1,   90,      150,   75,    1,       0xFF44cd4d,       "GFC"],
        bad  => [2,   135,     0,     25,    0.7,     0xFFa8738a,        "FC"],
        shit => [3,   157.5,  -50,   -150,   0.5,     0xFF59443f,      "SDCB"],
        miss => [4,   180,    -100,  -175,    -4,     0xFF894331,      "SDCB"]
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

    public static var values(get, default):Array<JudgementsTiming>;

    public static function getParameters(jt:JudgementsTiming):Array<Dynamic>
        return judgementsMap.get(jt);

    @:noCompletion
    public static function get_values():Array<JudgementsTiming>
    {
        values = [sick, good, bad, shit, miss];
        return values;
    }
}