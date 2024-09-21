#if !macro

#if (flixel > "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end

import backend.Conductor;
import backend.user.*;
import backend.*;
import backend.dependency.FNFSound;
import backend.dependency.MusicState;
import backend.dependency.MusicState.MusicSubState;
#end