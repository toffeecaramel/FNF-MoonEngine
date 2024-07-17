package gameObjects;

import data.depedency.FNFSprite;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import haxe.Json;

/**
    WIP
**/

typedef StageStructure = {
    var images:Array<StageData>;
}

typedef StageData = {
    var path:String;
    var x:Float;
    var y:Float;
    var antialiasing:Bool;
    var scale:Float;
    var parallaxx:Float;
    var parallaxy:Float;
}

class Stage extends FlxGroup
{
    public function new() 
    {
        super();

        var rawjson = sys.io.File.getContent('assets/data/stages/stage.json');
        var data:StageStructure = Json.parse(rawjson);
        
        for (image in data.images)
        {
            var img:FNFSprite = new FNFSprite(image.x, image.y).loadGraphic(Paths.image('stages/${image.path}'));
            img.scrollFactor.set(image.parallaxx, image.parallaxy);
            img.antialiasing = image.antialiasing;
            img.scale.set(image.scale, image.scale);
            img.x = image.x;
            img.y = image.y;
            add(img);
        }
    }
}