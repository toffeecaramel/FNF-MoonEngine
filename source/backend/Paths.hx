package backend;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.utils.Assets;
import openfl.display.BitmapData;
import openfl.display3D.textures.Texture;
import flixel.system.FlxAssets;
import openfl.media.Sound;
import openfl.utils.AssetType;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFlAssets;
import openfl.display3D.textures.RectangleTexture;
import sys.FileSystem;
import sys.io.File;
import moon.utilities.CoolUtil;

class Paths
{
    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    public static var currentTrackedTextures:Map<String, Texture> = [];
    public static var currentTrackedSounds:Map<String, Sound> = [];
    private static var graphicCache:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
    public static var localTrackedAssets:Array<String> = [];

    public static function clearMemory():Void
    {
        for (key in graphicCache.keys())
        {
            var graphic = graphicCache.get(key);
            if (graphic != null) {
                graphic.destroy();
                graphicCache.remove(key);
            }
        }

        for (key in currentTrackedTextures.keys())
        {
            var texture = currentTrackedTextures.get(key);
            if (texture != null) {
                texture.dispose();
                currentTrackedTextures.remove(key);
            }
        }

        for (key in currentTrackedAssets.keys())
        {
            var graphic = currentTrackedAssets.get(key);
            if (graphic != null) {
                graphic.destroy();
                currentTrackedAssets.remove(key);
            }
        }

        for (key in currentTrackedSounds.keys())
        {
            var sound = currentTrackedSounds.get(key);
            if (sound != null) {
                sound.close();
                currentTrackedSounds.remove(key);
            }
        }

        localTrackedAssets = [];
        // FlxG.gc(); // Garbage Collector is very gay bruhh
    }

    inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
        return getPath(file, type, library);

    inline static public function sound(key:String)
        return 'assets/sounds/$key.ogg';

    inline static public function fonts(key:String)
        return 'assets/fonts/$key';

    inline static public function data(key:String)
        return 'assets/data/$key';

    inline static public function frag(key:String)
        return 'assets/shaders/$key.frag';

    inline static public function music(key:String)
        return 'assets/music/$key.ogg';

    static public function image(key:String, ?from:String = 'images', ?library:String = null, ?allowGPU:Bool = true):FlxGraphic 
    {
        var file:String = getPath('$from/$key.png', IMAGE, library);
        if (graphicCache.exists(file))
            return graphicCache.get(file);
        
        var bitmapData:BitmapData = BitmapData.fromFile(file);
        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmapData, allowGPU);
        graphicCache.set(file, graphic);
        
        return graphic;
    }

    inline static public function getSparrowAtlas(key:String, ?from:String = 'images', ?library:String = null):FlxAtlasFrames
    {
        var xmlPath:String = getPath('$from/$key.xml', TEXT, library);
        var pngPath:String = getPath('$from/$key.png', IMAGE, library);
        
        var xml = Assets.getText(xmlPath);
        var pngBitmapData:BitmapData = BitmapData.fromFile(pngPath);
        
        var atlasGraphic:FlxGraphic = FlxGraphic.fromBitmapData(pngBitmapData, true);
        var atlasFrames:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(atlasGraphic, xml);
    
        return atlasFrames;
    }

    static public function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true) 
    {
        if(bitmap == null) {
            if (OpenFlAssets.exists(file, IMAGE))
                bitmap = OpenFlAssets.getBitmapData(file);

            if(bitmap == null) return null;
        }

        localTrackedAssets.push(file);
        if (allowGPU)
        {
            var texture:RectangleTexture = FlxG.stage.context3D.createRectangleTexture(bitmap.width, bitmap.height, BGRA, true);
            texture.uploadFromBitmapData(bitmap);
            bitmap.image.data = null;
            bitmap.dispose();
            bitmap.disposeImage();
            bitmap = BitmapData.fromTexture(texture);
        }

        var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
        newGraphic.persist = true;
        newGraphic.destroyOnNoUse = false;
        currentTrackedAssets.set(file, newGraphic);

        return newGraphic;
    }

    public static function returnGraphic(key:String, ?from:String = 'images', ?library:String, ?textureCompression:Bool = false)
    {
        var path = getPath('$from/$key.png', IMAGE, library);
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
                    newGraphic = FlxGraphic.fromBitmapData(BitmapData.fromTexture(texture), false, key, false);
                }
                else
                {
                    newGraphic = FlxGraphic.fromBitmapData(bitmap, false, key, false);
                }
                currentTrackedAssets.set(key, newGraphic);
            }
            localTrackedAssets.push(key);
            return currentTrackedAssets.get(key);
        }
        trace('$key didn\'t load. Did you type the path correctly?', "ERROR");
        return null;
    }

    static public function getLibraryPath(file:String, library = "preload")
    {
        return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
    }

    inline static function getLibraryPathForce(file:String, library:String)
        return '$library/$file';

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