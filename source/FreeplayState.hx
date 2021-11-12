package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.utils.Assets;

using StringTools;
#if sys
import sys.FileSystem;
import sys.io.File;
#end


#if windows
import Discord.DiscordClient;
#end


class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	
	// difficulty checking stuff
	var registeredSongs:Array<String> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	// var metaShit:FlxText;
	var rankImage:FlxSprite;
	var ratingText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var bg:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var grpIcons:FlxTypedGroup<HealthIcon>;

	override function create()
	{

		persistentUpdate = persistentDraw = true;

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{	
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1], Std.parseFloat(data[3])));
		}

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFF9271FD;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		grpIcons = new FlxTypedGroup<HealthIcon>();
		add(grpIcons);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName.replace("-", " "), true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			songText.x = -songText.width;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			grpIcons.add(icon);
		}

		var scoreBG:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 0.4), 76, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.x = FlxG.width * 0.6;
		add(scoreBG);
		
		rankImage = new FlxSprite(0, 0).loadGraphic(Paths.image('ranks/NA'));
		rankImage.scale.set(0.35, 0.35);
		rankImage.updateHitbox();
		rankImage.antialiasing = true;
		add(rankImage);

		scoreText = new FlxText(0, 0, FlxG.width * 0.4 - 4, "", 48);
		scoreText.x = scoreBG.x + 2;
		scoreText.y = 2;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);

		diffText = new FlxText(0, 0, FlxG.width * 0.4 - 4, "", 24);
		diffText.alignment = CENTER;
		diffText.x = scoreBG.x;
		diffText.y = scoreBG.y + scoreBG.height - 26;
		diffText.font = scoreText.font;

		add(diffText);
		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		// selector = new FlxText();

		// selector.size = 40;
		// selector.text = ">";
		// add(selector);

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, bpm:Float = 102)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, bpm));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var tweensPlayed:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		rankImage.x = FlxG.width - rankImage.width - 25;
		rankImage.y = FlxG.height - rankImage.height - 25;

		if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;
			pastPosition = FlxG.sound.music.time;
		}

		if (FlxG.sound.music.volume < 0.7)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		for (songLabel in grpSongs)
			songLabel.x = FlxMath.lerp(songLabel.x, (songLabel.targetY * 20) + 90, 9 / lime.app.Application.current.window.frameRate);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST: " + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.V)
			playMusic(false);

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
			FlxG.switchState(new MainMenuState());

		if (accepted)
		{	
			var songLowercase = songs[curSelected].songName.toLowerCase();
			var poop:String = Highscore.formatSong(StringTools.replace(songLowercase, " ", "-"), curDifficulty);
			var songPath = 'assets/data/' + songLowercase + '/' + poop + ".json";
			
			#if sys
			if (FileSystem.exists(Sys.getCwd() + songPath))
			#else
			if (Assets.exists(songPath))
			#end
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				LoadingState.loadAndSwitchState(new PlayState());
			}
			else
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3, "shared"), 0.7);
		}
	}

	override function beatHit() 
	{
		super.beatHit();
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);

		rankImage.alpha = 0;
		FlxTween.tween(rankImage, {alpha: 1}, 0.125);
		rankImage.loadGraphic(Paths.image('ranks/' + Ratings.ranks[Highscore.getRank(songHighscore, curDifficulty)]));
		rankImage.scale.set(0.35, 0.35);
		rankImage.updateHitbox();

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "< EASY >";
			case 1:
				diffText.text = '< NORMAL >';
			case 2:
				diffText.text = "< HARD >";
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		
		rankImage.alpha = 0;
		FlxTween.tween(rankImage, {alpha: 1}, 0.125);
		rankImage.loadGraphic(Paths.image('ranks/' + Ratings.ranks[Highscore.getRank(songHighscore, curDifficulty)]));
		rankImage.scale.set(0.35, 0.35);
		rankImage.updateHitbox();

		if (FlxG.save.data.flashing)
		{
			FlxTween.cancelTweensOf(bg, ["color"]);
			FlxTween.color(bg, 0.5, bg.color, getColor(songs[curSelected].songCharacter));
		}

		Conductor.changeBPM(songs[curSelected].bpm);

		#if PRELOAD_ALL
		FlxG.sound.music.stop();
		playMusic(true);
		#end
		

		var bullShit:Int = 0;

		for (i in 0...grpSongs.members.length)
		{
			var item = grpSongs.members[i];
			var icon = grpIcons.members[i];

			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = icon.alpha =  0.6;
			
			if (item.targetY == 0)
				item.alpha = icon.alpha = 1;
		}
	}

	var vocalsPlaying:Bool = false;
	var pastPosition:Float = 0.00;

	// VOCAL SWITCHING BULLSHIT
	function playMusic(justPlayIt:Bool = false)
	{
		if (!justPlayIt)
			vocalsPlaying = !vocalsPlaying;
		else
			pastPosition = 0.00;

		if (vocalsPlaying)
		{
			FlxG.sound.playMusic(Paths.voices(songs[curSelected].songName), 0);
			FlxG.sound.music.time = pastPosition;
		}
		else
		{
			FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
			FlxG.sound.music.time = pastPosition;
		}
	}

	function getColor(char:String = "bf")
	{
		var daColor:String = "a1a1a1";

		for (key in Reflect.fields(Character.colors))
		{
			if (char.startsWith(key))
				daColor = Reflect.field(Character.colors, key);
		}

		return FlxColor.fromString("#" + daColor);
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var bpm:Float = 0;

	public function new(song:String, week:Int, songCharacter:String, bpm:Float)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.bpm = bpm;
	}
}
