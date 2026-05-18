package mobile.backend;

import openfl.events.MouseEvent;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.Assets;
import openfl.Lib;

import flixel.FlxG;

/*
 * Originally made by: Dechis
 * 
 * Improved by: StarNova (Cream.BR)
 * ITS OUTSIDE THE VISIBLE SCREEN NOW YAY!!!! (TheLagKing)
 */

class PauseButton extends Sprite
{
	private static var instance:PauseButton;
	private var button:Bitmap;
	private var onClick:Void->Void;

	public static function getInstance():PauseButton
	{
		if (instance == null)
			instance = new PauseButton();

		return instance;
	}

	private function new()
	{
		super();

		button = new Bitmap(Assets.getBitmapData("assets/mobile/pauseButton.png"));
		addChild(button);

		alpha = 0.7;

		scaleX = scaleY = 0.8;
		
		button.addEventListener(MouseEvent.CLICK, function(_)
			{
				if (onClick != null) onClick();
			});
	}

	public static function show(?callback:Void->Void):Void
	{
		#if mobile
		var manager = getInstance();

		manager.onClick = callback;

		if (manager.parent == null)
			Lib.current.addChild(manager);

		PauseButton.updatePosition();
		#end
	}

	public static function hide():Void
	{
		#if mobile
		var manager = getInstance();

		if (manager.parent != null)
			manager.parent.removeChild(manager);
		#end
	}

	public static function updatePosition():Void
	{
		#if mobile
		var manager = getInstance();

		manager.x = FlxG.stage.stageWidth - (manager.width / 2) - 10;
		manager.y = -10;
		#end
	}
}
