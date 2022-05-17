package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.1'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	//var bg:FlxSprite;
	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	public static var finishedFunnyMove:Bool = false;
	
	var optionShit:Array<String> = [
		'story_mode',
		'credits',
		'options'
	];

	var bg:FlxSprite;

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var amongusTro:FlxSprite;
	var pipdied:FlxSprite;
	var blackBar:FlxSprite;
	public static var isReseting:Bool = false;

	var descText:FlxText;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		isReseting = false;
		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;


		if (FlxG.save.data.PipModWeekCompleted == 1)
			optionShit = [
				'story_mode',
				'freeplay',
				'credits',
				'options'
			];
			var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

		bg = new FlxSprite(0, -9.95).loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(Std.int(1286 * 1.175));
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.x -= 70;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		pipdied = new FlxSprite(0, -9.95);
		pipdied.frames = Paths.getSparrowAtlas('MenuShitAssets');
		pipdied.setGraphicSize(203, 360);
		pipdied.setPosition(1024.45, 339.1);
		// pipdied.y -= 300;
		// pipdied.x -= 180;
		pipdied.animation.addByPrefix('idleGold', 'C-goldpip', 24, true);
		pipdied.animation.addByPrefix('idleStone', 'StonePip', 24, true);
		pipdied.animation.addByPrefix('idle', 'A-lockedtrophy', 24, true);
		pipdied.animation.addByPrefix('select', 'B-lockedtrophyselect instance', 24, true);

		pipdied.scrollFactor.set();
		pipdied.antialiasing = ClientPrefs.globalAntialiasing;
		pipdied.updateHitbox();


		amongusTro = new FlxSprite(0, -9.95);
		amongusTro.frames = Paths.getSparrowAtlas('MenuShitAssets');
		amongusTro.setGraphicSize(203, 360);
		amongusTro.setPosition(1024.45, 339.1);
		amongusTro.y -= 205;
		amongusTro.x -= 1150;
		amongusTro.flipX = true;
		amongusTro.antialiasing = ClientPrefs.globalAntialiasing;
		amongusTro.animation.addByPrefix('idle', 'StonePussy', 24);
		amongusTro.animation.addByPrefix('Gold', 'D-goldpussy instance', 24, true);
		amongusTro.visible = false;
		amongusTro.scrollFactor.set();

		blackBar = new FlxSprite(0,0).loadGraphic(Paths.image('frame'));
		blackBar.setGraphicSize(1286,830);
		blackBar.screenCenter();
		blackBar.scrollFactor.set();
		blackBar.antialiasing = ClientPrefs.globalAntialiasing;
		
		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuBGMagenta'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(1286 * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.x -= 70;
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

	

		var menuId = 1;
		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.updateHitbox();
			menuId += 1;
		}
		finishedFunnyMove = true; 
		changeItem();

		add(bg);
		add(menuItems);
		add(blackBar);
		add(amongusTro);
		add(pipdied);
		
		if (FlxG.save.data.PipModWeekCompleted == 1)
			pipdied.animation.play('idleStone');
		else
			pipdied.animation.play('idle');
		
		if (FlxG.save.data.PipModWeekCompleted == 1 && FlxG.save.data.PipModFC == 3)
			pipdied.animation.play('idleGold', true);

		if (FlxG.save.data.PussyModWeekCompleted == 1){
			amongusTro.visible = true;
			amongusTro.animation.play('idle', true);
		}

		if (FlxG.save.data.PussyModWeekCompleted == 2){
			amongusTro.visible = true;
			amongusTro.animation.stop();
			amongusTro.animation.play('Gold', true);
		}
		
		FlxG.camera.follow(camFollowPos, null, 1);

		var resetTxt = new FlxText(0, FlxG.height * 0.89 + 25, FlxG.width, "PUSH RESET TO CLEAR GAME PROGRESS", 20);
		resetTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resetTxt.scrollFactor.set();
		resetTxt.borderSize = 1.25;
		add(resetTxt);
	
		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);
		descText.visible = false;

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end
		FlxG.mouse.visible = true;


		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{

		if (FlxG.mouse.overlaps(pipdied) && FlxG.save.data.PipModWeekCompleted != 1) 
			{
				descText.visible = true;

				descText.text = "You need to complete WeekPi first \nto unlock this and freeplay!";
				descText.screenCenter(Y);
				descText.y += 270;

				pipdied.animation.play('select');

			}
		else
			{
				if (pipdied.animation.curAnim.name == "select")
					pipdied.animation.play('idle');

				descText.visible = false;
			}


		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin && !isReseting)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(magenta, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(magenta, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.RESET)
				{
					isReseting = true;
					openSubState(new RemoveDataSubState());
				}

			if (controls.ACCEPT)
			{
				FlxG.mouse.visible = false;
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);


					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
						FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(magenta, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
						FlxTween.tween(magenta, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			
			#if debug
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}
