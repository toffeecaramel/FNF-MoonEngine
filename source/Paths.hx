package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import openfl.media.Sound;
import openfl.system.System;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem; // man the fucking vsc console wont shut up abt this
import sys.io.File;

// Also this is just forever engine's Paths so yea I didnt make this

class Paths
{

    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedTextures:Map<String, Texture> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

    public static var localTrackedAssets:Array<String> = [];
    inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
    {
        return getPath(file, type, library);
    }

    inline static public function image(key:String, ?library:String, ?textureCompression:Bool = false)
    {
        var returnAsset:FlxGraphic = returnGraphic(key, library, textureCompression);
        return returnAsset;
    }

    inline static public function getSparrowAtlas(key:String, ?library:String)
    {
        var graphic:FlxGraphic = returnGraphic(key, library);
        return (FlxAtlasFrames.fromSparrow(graphic, File.getContent(file('images/$key.xml', library))));
    }

    public static function returnGraphic(key:String, ?library:String, ?textureCompression:Bool = false)
    {
        var path = getPath('images/$key.png', IMAGE, library);
        if (FileSystem.exists(path))
        {
            if (!currentTrackedAssets.exists(key))
            {
                var bitmap = BitmapData.fromFile(path);
                var newGraphic:FlxGraphic;
                if (textureCompression)
                {
                    var texture = FlxG.stage.context3D.createTexture(bitmap.width, bitmap.height, BGRA, true, 0);
                    texture.uploadFromBitmapData(bitmap);
                    currentTrackedTextures.set(key, texture);
                    bitmap.dispose();
                    bitmap.disposeImage();
                    bitmap = null;
                    trace('new texture $key, bitmap is $bitmap');
                    newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);
                }
                else
                {
                    newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
                    trace('new bitmap $key, not textured');
                }
                currentTrackedAssets.set(key, newGraphic);
            }
            localTrackedAssets.push(key);
            return currentTrackedAssets.get(key);
        }
        trace('oh no ' + key + ' is returning null NOOOO');
        return null;
    }

    static public function getLibraryPath(file:String, library = "preload")
    {
        return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
    }

    inline static function getLibraryPathForce(file:String, library:String)
    {
        return '$library/$file';
    }

    inline public static function getPath(file:String, type:AssetType, ?library:Null<String>)
    {
        if (library != null)
            return getLibraryPath(file, library);

        var levelPath = getLibraryPathForce(file, "mods");
        if (OpenFlAssets.exists(levelPath, type))
            return levelPath;

        return getPreloadPath(file);
    }

    inline static function getPreloadPath(file:String)
    {
        var returnPath:String = 'assets/$file';
        if (!FileSystem.exists(returnPath))
            returnPath = CoolUtil.swapSpaceDash(returnPath);
        return returnPath;
    }
}