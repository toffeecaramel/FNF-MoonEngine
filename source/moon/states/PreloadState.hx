package moon.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import moon.obj.*;
import sys.FileSystem;
import sys.io.File;

import openfl.display.BitmapData;

/**
    This state will be used for preloading all the assets
    from the menus, them being titlescreen, main menu,
    story menu, freeplay, options etcetera.
**/

using StringTools;

class PreloadState extends FlxTransitionableState
{
    //stuff for the percentage
    private var loadedFiles:Int = 0;

    private final transitionDuration:Float = 0.4;
    private final tWidth:Int = 38;
    private final tHeight:Int = 32;

    static var initialized:Bool = false;
    override public function create():Void
    {
        super.create();

        // - Setup the transition cause its huge
        setupTransition();

        // - The game will load only these so it
        // - won't explode your ram lolll...
        // - But! if you want to change the path it loads
        // - just change this lolz! - Toffee
        final loadPaths = [
            'assets/images/menus/main',
        ];

        for (i in 0...loadPaths.length)
            loadAssets(loadPaths[i]);
    }

    private function setupTransition()
    {
        if (!initialized)
        {
            initialized = true;

            // Initialize TransitionData
            var transitionGraphic:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
            transitionGraphic.persist = true;
            transitionGraphic.destroyOnNoUse = false;

            var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, transitionDuration, 
                new FlxPoint(-2, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-1, 0, FlxG.width, FlxG.height));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, transitionDuration, 
                new FlxPoint(2, -1), {asset: diamond, width: 32, height: 32}, 
                new FlxRect(-1, 0, FlxG.width, FlxG.height));
                
            FlxTransitionableState.defaultTransIn.cameraMode = NEW;
            FlxTransitionableState.defaultTransOut.cameraMode = NEW;

            transIn = FlxTransitionableState.defaultTransIn;
            transOut = FlxTransitionableState.defaultTransOut;
        }
    }

    private function loadAssets(path:String):Void
    {
        final files = FileSystem.readDirectory(path);
        for (file in files)
        {
            final filePath = '$path/$file';
                        
            if(FileSystem.isDirectory(filePath))
                loadAssets(filePath); //incase theres subfolders!!
            else
            {
                if(file.endsWith('.png'))
                {
                    var spr = new FlxSprite().loadGraphic(filePath);
                    spr.screenCenter();
                    add(spr);
                    loadedFiles++;
                }
            }
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ANY)
            FlxG.switchState(new moon.states.menus.Title());
    }
}