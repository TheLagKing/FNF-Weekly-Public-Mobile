package meta.data;

import gameObjects.animateatlas.AtlasFrameMaker;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.media.Sound;
import haxe.Json;
import haxe.io.Path;

import meta.data.FunkinAssets;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	#if ASSET_REDIRECT
	public static inline final trail = #if macos '../../../../../../../' #else '../../../../' #end;
	#end

	public static inline final CORE_DIRECTORY = #if ASSET_REDIRECT trail + 'assets/game' #else 'assets' #end;
	public static inline final MODS_DIRECTORY = #if ASSET_REDIRECT trail + 'content' #else 'content' #end;

	#if MODS_ALLOWED
	public static var ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'noteskins',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];
	#end

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static var localTrackedAssets:Array<String> = [];
	public static var globalMods:Array<String> = [];

	static public var currentModDirectory:String = '';
	static public var currentLevel:String;

	public static var dumpExclusions:Array<String> =
	[
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/shared/music/breakfast.$SOUND_EXT',
		'assets/shared/music/tea-time.$SOUND_EXT',
	];

	public static function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static inline function getCorePath(file:String = ''):String
	{
		return '$CORE_DIRECTORY/$file';
	}

	public static inline function mods(key:String = ''):String
	{
		return '$MODS_DIRECTORY/$key';
	}

	public static function getPath(file:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		if (parentFolder != null)
			file = '$parentFolder/$file';

		#if MODS_ALLOWED
		if (checkMods)
		{
			final modPath:String = modFolders(file);

			if (FunkinAssets.exists(modPath) || FunkinAssets.isDirectory(modPath))
				return modPath;
		}
		#end

		#if ASSET_REDIRECT
		final embedPath = getCorePath().replace(CORE_DIRECTORY, trail + 'assets/embeds') + file;

		if (FunkinAssets.exists(embedPath) || FunkinAssets.isDirectory(embedPath))
			return embedPath;
		#end

		return getCorePath(file);
	}

	inline static public function txt(key:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		return getPath('data/$key.txt', parentFolder, checkMods);
	}

	inline static public function xml(key:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		return getPath('data/$key.xml', parentFolder, checkMods);
	}

	inline static public function json(key:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		return getPath('data/$key.json', parentFolder, checkMods);
	}

	inline static public function shaderFragment(key:String, checkMods:Bool = true):String
	{
		return getPath('shaders/$key.frag', null, checkMods);
	}

	inline static public function shaderVertex(key:String, checkMods:Bool = true):String
	{
		return getPath('shaders/$key.vert', null, checkMods);
	}

	public static function video(key:String, checkMods:Bool = true):String
	{
		return findFileWithExts('videos/$key', ['mp4', 'mov'], null, checkMods);
	}

	public static function sound(key:String, ?parentFolder:String, checkMods:Bool = true):Sound
	{
		final path = findFileWithExts('sounds/$key', ['ogg', 'wav'], parentFolder, checkMods);
		return FunkinAssets.getSound(path);
	}

	public static function music(key:String, ?parentFolder:String, checkMods:Bool = true):Sound
	{
		final path = findFileWithExts('music/$key', ['ogg', 'wav'], parentFolder, checkMods);
		return FunkinAssets.getSound(path);
	}

	inline static public function voices(song:String):Null<Sound>
	{
		return returnSound('songs', '${formatToSongPath(song)}/Voices');
	}

	inline static public function inst(song:String):Null<Sound>
	{
		return returnSound('songs', '${formatToSongPath(song)}/Inst');
	}

	inline static public function image(key:String, ?parentFolder:String):FlxGraphic
	{
		return returnGraphic(key, parentFolder);
	}

	inline static public function font(key:String):String
	{
		return findFileWithExts('fonts/$key', ['ttf', 'otf']);
	}

	inline static public function exists(asset:String):Bool
	{
		return FunkinAssets.exists(asset);
	}

	inline static public function getContent(asset:String):Null<String>
	{
		return FunkinAssets.exists(asset) ? FunkinAssets.getContent(asset) : null;
	}

	public static function getTextFromFile(key:String, ?parentFolder:String, checkMods:Bool = true):String
	{
		final path = getPath(key, parentFolder, checkMods);

		if (FunkinAssets.exists(path))
			return FunkinAssets.getContent(path);

		return '';
	}

	inline static public function fileExists(key:String, ?parentFolder:String, checkMods:Bool = true):Bool
	{
		return FunkinAssets.exists(getPath(key, parentFolder, checkMods));
	}

	inline static public function getSparrowAtlas(key:String, ?parentFolder:String):FlxAtlasFrames
	{
		final imagePath = getPath('images/$key.png', parentFolder);
		final xmlPath = getPath('images/$key.xml', parentFolder);

		return FlxAtlasFrames.fromSparrow(
			returnGraphic(key, parentFolder),
			FunkinAssets.getContent(xmlPath)
		);
	}

	inline static public function getPackerAtlas(key:String, ?parentFolder:String):FlxAtlasFrames
	{
		final imagePath = getPath('images/$key.png', parentFolder);
		final txtPath = getPath('images/$key.txt', parentFolder);

		return FlxAtlasFrames.fromSpriteSheetPacker(
			returnGraphic(key, parentFolder),
			FunkinAssets.getContent(txtPath)
		);
	}

	inline static public function formatToSongPath(path:String)
	{
		return path.toLowerCase().replace(' ', '-');
	}

	public static function returnGraphic(key:String, ?parentFolder:String, allowGPU:Bool = true):FlxGraphic
	{
		final file = getPath('images/$key.png', parentFolder);

		if (currentTrackedAssets.exists(file))
		{
			localTrackedAssets.push(file);
			return currentTrackedAssets.get(file);
		}

		if (!FunkinAssets.exists(file))
			return null;

		final graphic = FunkinAssets.getGraphic(file, true, allowGPU);

		if (graphic != null)
		{
			localTrackedAssets.push(file);
			currentTrackedAssets.set(file, graphic);
		}

		return graphic;
	}

	public static function returnSound(path:String, key:String):Null<Sound>
	{
		final file = findFileWithExts('$path/$key', ['ogg', 'wav']);

		if (!currentTrackedSounds.exists(file))
		{
			currentTrackedSounds.set(file, FunkinAssets.getSound(file));
		}

		localTrackedAssets.push(file);

		return currentTrackedSounds.get(file);
	}

	public static function clearUnusedMemory()
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				final obj = currentTrackedAssets.get(key);

				@:privateAccess
				if (obj != null)
				{
					if (obj.bitmap != null && obj.bitmap.__texture != null)
						obj.bitmap.__texture.dispose();

					FlxG.bitmap._cache.remove(key);

					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}

		System.gc();

		#if cpp
		cpp.vm.Gc.compact();
		#end
	}

	public static function clearStoredMemory()
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			final obj = FlxG.bitmap._cache.get(key);

			if (obj != null && !currentTrackedAssets.exists(key))
			{
				if (obj.bitmap != null && obj.bitmap.__texture != null)
					obj.bitmap.__texture.dispose();

				FlxG.bitmap._cache.remove(key);

				obj.destroy();
			}
		}

		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				currentTrackedSounds.remove(key);
			}
		}

		localTrackedAssets = [];
	}

	public static function findFileWithExts(key:String, exts:Array<String>, ?parentFolder:String, checkMods:Bool = true):String
	{
		for (ext in exts)
		{
			final joined = getPath('$key.$ext', parentFolder, checkMods);

			if (FunkinAssets.exists(joined))
				return joined;
		}

		return getPath(key, parentFolder, checkMods);
	}

	#if MODS_ALLOWED

	inline static public function modsFont(key:String)
	{
		return modFolders('fonts/$key');
	}

	inline static public function modsImages(key:String)
	{
		return modFolders('images/$key.png');
	}

	inline static public function modsXml(key:String)
	{
		return modFolders('images/$key.xml');
	}

	inline static public function modsTxt(key:String)
	{
		return modFolders('images/$key.txt');
	}

	static public function modFolders(key:String):String
	{
		if (currentModDirectory != null && currentModDirectory.length > 0)
		{
			final fileToCheck:String = mods(currentModDirectory + '/' + key);

			if (FunkinAssets.exists(fileToCheck) || FunkinAssets.isDirectory(fileToCheck))
				return fileToCheck;
		}

		for (mod in globalMods)
		{
			final fileToCheck:String = mods(mod + '/' + key);

			if (FunkinAssets.exists(fileToCheck) || FunkinAssets.isDirectory(fileToCheck))
				return fileToCheck;
		}

		return mods(key);
	}

	static public function getGlobalMods()
	{
		return globalMods;
	}

	static public function getModDirectories():Array<String>
	{
		var list:Array<String> = [];
		var modsFolder:String = mods();

		if (FunkinAssets.isDirectory(modsFolder))
		{
			for (folder in FunkinAssets.readDirectory(modsFolder))
			{
				var path = Path.join([modsFolder, folder]);

				if (FunkinAssets.isDirectory(path)
					&& !ignoreModFolders.contains(folder)
					&& !list.contains(folder))
				{
					list.push(folder);
				}
			}
		}

		return list;
	}

	#end
}
