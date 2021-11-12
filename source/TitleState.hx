package;

import DialogueSubstate.DialogueStyle;
import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileSquare;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
#if windows
import Discord.DiscordClient;
#end

#if cpp
import sys.FileSystem;
import sys.io.File;
import sys.thread.Thread;
#end


class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup = new FlxGroup();
	var credTextShit:Alphabet;

	var whyDoesThis:FlxParticle;
	var haveToBeThisComplicated:FlxEmitter;

	var particleFront:FlxParticle;
	var particleFrontEmitter:FlxEmitter;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{	
		FlxG.fixedTimestep = false;
		
		#if sys
		if (!FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		if (!FileSystem.exists(Sys.getCwd() + "/assets/skins"))
			FileSystem.createDirectory(Sys.getCwd() + "/assets/skins");

		NoteSkinSelection.refreshSkins();
		#else
		FlxG.save.bind('save', 'caret3saves');

        PlayerSettings.init();
		Data.initSave();

        FlxG.mouse.visible = false;
		#end

		FlxG.autoPause = false;

		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}
		
		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});
		#end

		Highscore.load();

		// Feeling dumb today
		Application.current.onExit.add(function(exitCode)
		{
			FlxG.save.flush();
		});

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			startIntro();
		});
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var titleTextTest:FlxText;
	var fnfLogo:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileSquare);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;
			
			FlxTransitionableState.defaultTransIn =  new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, -1), 
				{asset: diamond, width: 32, height: 32}, new FlxRect(FlxG.width * -2, FlxG.height * -1, FlxG.width * 5, FlxG.height * 2));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(FlxG.width * -2, FlxG.height * -1, FlxG.width * 5, FlxG.height * 2));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			
			// FlxTransitionableState.defaultTransIn.tweenOptions = {onStart: function(twn:FlxTween) {
			// 	trace("YOU'RE IN");
			// }};

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// I, have no clue where to put this.
			// If you know where, please tell me.
			if (Reflect.fields(Character.colors).length == 0)
			{
				var colorsText = CoolUtil.coolTextFile(Paths.txt('characterColors'));
	
				for (color in colorsText)
				{
					var split:Array<String> = color.split(":");
					Reflect.setField(Character.colors, split[0], split[1]);
				}
			}

			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			Conductor.changeBPM(102);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
		persistentUpdate = true;

		var funnyParticleSwitch = FlxG.random.bool(0.69);
		var funnyParticleNumber = funnyParticleSwitch ? FlxG.random.int(2, 3) : 1;

		haveToBeThisComplicated = new FlxEmitter(0, FlxG.height + 50);
		haveToBeThisComplicated.launchMode = SQUARE;
		haveToBeThisComplicated.width = FlxG.width;

		for (fuck in 0...40)
		{
			whyDoesThis = new FlxParticle();
			whyDoesThis.loadGraphic(Paths.image('funnyparticles/particle-' + funnyParticleNumber));
			whyDoesThis.lifespan = 200;
			whyDoesThis.exists = false;
			haveToBeThisComplicated.add(whyDoesThis); 
		}

		add(haveToBeThisComplicated);
		haveToBeThisComplicated.start(false, 0.75, 0);
		haveToBeThisComplicated.velocity.set(-50, -100, 50, -100);
		haveToBeThisComplicated.scale.set(0.5);
		haveToBeThisComplicated.color.set(0xad34ff);
		haveToBeThisComplicated.alpha.set(1, 1, 0, 0);

		// front
		particleFrontEmitter = new FlxEmitter(0, FlxG.height + 50);
		particleFrontEmitter.launchMode = SQUARE;
		particleFrontEmitter.width = FlxG.width;

		for (fuck in 0...40)
		{
			particleFront = new FlxParticle();
			particleFront.loadGraphic(Paths.image('funnyparticles/particle-' + funnyParticleNumber));
			particleFront.lifespan = 200;
			particleFront.exists = false;
			particleFrontEmitter.add(particleFront); 
		}

		particleFrontEmitter.start(false, 1, 0);
		particleFrontEmitter.velocity.set(-25, -50, 25, -50);
		particleFrontEmitter.scale.set(0.5);
		particleFrontEmitter.color.set(0xad34ff);
		particleFrontEmitter.alpha.set(1, 1, 0, 0);

		var bg:FlxSprite = FlxGradient.createGradientFlxSprite(Std.int(FlxG.width * 1.5), Std.int(FlxG.height * 1.5), [0xFFad34ff, 0xFF000000], 1, -90);
		bg.alpha = 0;
		bg.screenCenter();
		add(bg);

		FlxTween.tween(bg, {alpha: 0.25}, 2.7);

		logoBl = new FlxSprite(25, 25).loadGraphic(Paths.image('YEAHHH WE FUNKIN'));
		logoBl.scale.set(0.75, 0.75);
		logoBl.angle = -5;
		logoBl.antialiasing = true;
		logoBl.visible = false;
		logoBl.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		gfDance.visible = false;
		add(gfDance);
		add(particleFrontEmitter);
		add(logoBl);

		fnfLogo = new FlxSprite(0, 0).loadGraphic(Paths.image((FlxG.random.bool(10) ? 'logo' : 'logoNew')));
		fnfLogo.setGraphicSize(0, 350);
		fnfLogo.updateHitbox();
		fnfLogo.screenCenter(X);
		fnfLogo.antialiasing = true;
		fnfLogo.visible = false;
		add(fnfLogo);

		titleText = new FlxSprite(0, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		titleText.screenCenter(X);
		titleText.visible = false;
		add(titleText);

		// titleTextTest = new FlxText(0, FlxG.height * 0.8, FlxG.width, "Press Enter to Begin", 64);
		// titleTextTest.color = FlxColor.WHITE;
		// titleTextTest.alignment = CENTER;
		// titleTextTest.shadowOffset.set(0.5, 0.5);
		// titleTextTest.screenCenter(X);
		// titleTextTest.visible = false;
		// add(titleTextTest);
		

		// var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		// logo.screenCenter();
		// logo.antialiasing = true;

		credGroup = new FlxGroup();
		add(credGroup);

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;
			

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
			FlxG.fullscreen = !FlxG.fullscreen;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
				pressedEnter = true;
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			FlxTween.tween(logoBl, {y: 2000}, 3, {ease: FlxEase.quadInOut, startDelay: 0.5});
			FlxTween.tween(titleText, {y: 2000}, 3, {ease: FlxEase.quadInOut, startDelay: 0.5});
			FlxTween.tween(gfDance, {y: 2000}, 3, {ease: FlxEase.quadInOut, startDelay: 0.5});

			if (FlxG.save.data.flashing)
			{
				titleText.animation.play('press');
				titleText.centerOffsets;
			}

			transitioning = true;
			// FlxG.sound.music.stop();

			MainMenuState.firstStart = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();
		
		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (credGroup.length * 60) + 200;
		credGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (credGroup.members.length > 0)
		{
			credGroup.remove(credGroup.members[0], true);
		}
	}

	var canBop:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		danceLeft = !danceLeft;

		if (canBop)
		{
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		switch (curBeat)
		{
			case 1:
				createCoolText(['skuqre']);
			case 3:
				addMoreText('presents');
			case 4:
				deleteCoolText();
			case 5:
				addMoreText('A mod for');
			case 7:
				if (!skippedIntro)
				{
					fnfLogo.y = FlxG.height * 0.45;
					fnfLogo.visible = true;
				}
			case 8:
				deleteCoolText();
				fnfLogo.visible = false;
			case 9:
				createCoolText([curWacky[0]]);
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('W Slash');
			case 14:
				addMoreText('Caret');
			case 15:
				addMoreText('Three');
			case 16:
				skipIntro();
				
		}

		if (canBop == true)
		{
			logoBl.scale.set(0.85, 0.85);
			FlxTween.tween(logoBl, {"scale.x": 0.75, "scale.y": 0.75}, Conductor.crochet / 1500, {ease: FlxEase.quadOut});
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			titleText.visible = true;
			logoBl.visible = true;
			gfDance.visible = true;
			skippedIntro = true;
		}

		new FlxTimer().start(1.25, function(tmr:FlxTimer)
		{
			canBop = true;
		});
	}
}