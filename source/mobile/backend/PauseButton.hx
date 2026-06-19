package mobile.backend;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

/*
* shit im ass at this (TheLagKing)
*/

class PauseButton extends PlayState {

	private var _lastTouchId:Int = -1;
	public var pauseButton:FlxSprite;
	public var pauseCircle:FlxSprite;

	override public function create() {
		super();

		#if mobile
			if (!ClientPrefs.pauseButton) return;
		pauseButton = new FlxSprite ();
		pauseButton.loadGraphic(Paths.image('assets/mobile/pauseButton'));
		pauseButton.cameras = [camOther];
		pauseButton.scale.set(0.8, 0.8);
		pauseButton.updateHitbox();
		pauseButton.setPosition((FlxG.width - pauseButton.width) - 35, 35);

		pauseCircle = new FlxSprite ();
		pauseCircle.loadGraphic(Paths.image('assets/mobile/pauseCircle'));
		pauseCircle.cameras = [camOther];
		pauseCircle.scale.set(0.84, 0.8);
		pauseCircle.updateHitbox();
		pauseCircle.x = ((pauseButton.x + (pauseButton.width / 2)) - (pauseCircle.width / 2));
		pauseCircle.y = ((pauseButton.y + (pauseButton.height / 2)) - (pauseCircle.height / 2));
		pauseCircle.alpha = 0.1;

		add(pauseCircle);
		add(pauseButton);
		#end

	}

	override public function endSong():Void {
		#if mobile
			if (!ClientPrefs.pauseButton)
				pauseButton.visible = pauseCircle.visible = false;
		#end
	}



	override function update(elapsed:Float)

	{

		super.update(elapsed);



		#if mobile

		if (!ClientPrefs.pauseButton) return;

		

		for (touch in FlxG.touches.list)

		{

			if (_lastTouchId == -1)

			{

				if (touch.justPressed && touch.overlaps(pauseButton) && startedCountdown && canPause && !paused)

				{

					_lastTouchId = touch.touchPointID;

					openPauseMenu();

					break;

				}

			}

			else if (_lastTouchId == touch.touchPointID && !touch.pressed)

			{

				_lastTouchId = -1;

			}

		}

		#end

	}

}
