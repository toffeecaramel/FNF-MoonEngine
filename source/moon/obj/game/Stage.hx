package moon.obj.game;

import backend.dependency.FNFSprite;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import haxe.Json;

/**
    WIP
**/

//heh, so proud of these :3
typedef StageStructure = {
    var zoom:Float;
    var oppPos:Array<Float>;
    var playerPos:Array<Float>;
    var images:Array<StageData>;
}

typedef StageData = {
    var name:String;
    var pos:Array<Float>;
    var parallax:Array<Float>;
    var antialiasing:Bool;
    var scale:Float;
}

class Stage extends FlxGroup
{
    public var zoom:Float;
    public var oppPos:Array<Float>;
    public var playerPos:Array<Float>;
    public function new(curStage:String = "stage") 
    {
        super();

        var rawjson = sys.io.File.getContent('assets/data/stages/$curStage/$curStage.json');
        var data:StageStructure = Json.parse(rawjson);
        this.zoom = data.zoom;
        this.oppPos = data.oppPos;
        this.playerPos = data.playerPos;
        
        for (image in data.images)
        {
            var img:FNFSprite = new FNFSprite().loadGraphic('assets/data/stages/$curStage/${image.name}.png');
            img.scrollFactor.set(image.parallax[0], image.parallax[1]);
            img.antialiasing = image.antialiasing;
            img.scale.set(image.scale, image.scale);
            img.x = image.pos[0];
            img.y = image.pos[1];
            add(img);
        }
    }
}