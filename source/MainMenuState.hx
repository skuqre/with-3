package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.net.oauth.OAuthToken.AccessToken;

using StringTools;

#if windows
import Discord.DiscordClient;
#end


class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var bg:FlxSprite;
	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'credits', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end
	
	public static var firstStart:Bool = true;

	public static var kadeEngineVer:String = "1.5.2";
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(102);
		}
		persistentUpdate = persistentDraw = true;
        // FlxG.mouse.visible = true;

		bg = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			switch (optionShit[i])
			{
				case 'credits':
					menuItem.frames = Paths.getSparrowAtlas('credits_assets');
				default:
					menuItem.frames = Paths.getSparrowAtlas('FNF_main_menu_assets');
			}
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.addByPrefix('tweakin', optionShit[i] + " basic", 24);
			menuItem.animation.play('tweakin');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.screenCenter(X);
			menuItem.y = 60 + (i * 160);
			fuckingStupid.push(menuItem.height);

			// TO DO: ADD MOUSE CONTROLS IN FULL RELEASE IT WOULD BE FUNNY
			/*
			FlxMouseEventManager.add(menuItem, 
			function(spr:FlxSprite)
			{
				if (!selectedSomethin)
					acceptItem();
			}, null,
			function(spr:FlxSprite)
			{
				if (!selectedSomethin)
				{
					curSelected = spr.ID;
					changeItem(0);
				}
			});
			*/
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, LOCKON, 9 / lime.app.Application.current.window.frameRate);

		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem(0);

		super.create();
	}

	var selectedSomethin:Bool = false;

	var fuckingStupid:Array<Float> = [];

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (!selectedSomethin)
		{
			if (controls.UP_P)
				changeItem(-1);

			if (controls.DOWN_P)
				changeItem(1);

			if (controls.BACK)
				FlxG.switchState(new TitleState());

			if (controls.ACCEPT)
				acceptItem();
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);

			if (spr.animation.curAnim.name.startsWith('selected'))
				spr.offset.set(0, Math.abs((fuckingStupid[curSelected] / 2) - (spr.height / 2)));
		});

		super.update(elapsed);
	}

	function acceptItem()
	{
		if (optionShit[curSelected] == 'donate')
		{
			fancyOpenURL("https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game");
		}
		/*
		else if (optionShit[curSelected] == 'extras' || optionShit[curSelected] == 'freeplay' && !FlxG.save.data.completedDaWeek)
		{
			FlxG.sound.play(Paths.sound('dialogueNoises/vineThud'));
		}
		*/
		else
		{
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			
			if (FlxG.save.data.flashing)
				FlxFlicker.flicker(magenta, 1.1, 0.15, false);

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 1.3, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					if (FlxG.save.data.flashing)
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							goToState();
						});
					}
					else
					{
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							goToState();
						});
					}
				}
			});
		}
	}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				FlxG.switchState(new FreeplayState());
				trace("Freeplay Menu Selected");
			case 'credits':
				FlxG.switchState(new CreditsState());
				trace("Credits Menu Selected");
			case 'options':
				FlxG.switchState(new OptionsMenu());
				trace("Options Menu Selected");
		}
	}

	var switching:Bool = false;

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('tweakin');

			if (spr.ID == curSelected)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}
				
			spr.updateHitbox();
		});
	}
}
