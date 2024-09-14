package backend;

import haxe.Json;

using StringTools;

typedef WeekFile = {
    var displayName:String;
    var description:String;
    var rate:Int;
    var tracks:Array<String>;

    var colors:Array<Int>;
    var weekImage:String;
    var bgImage:String;
};

class WeekData
{
    public static function getData(wName:String)
    {
        final content = sys.io.File.getContent(Paths.data('weeks/$wName/$wName.json'));
        final parsedContent = Json.parse(content);
        
        return parsedContent;
    }
}