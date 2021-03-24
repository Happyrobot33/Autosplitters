/* MEMORY POINTERS TREE FROM THE SOURCE CODE, * are already in use

GameManager: "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14    info : "mono.dll", 0x20B574, 0x10, 0x158
│                                                             │
├─── 0x0, 0xC : static fields                                 ├─── 0x4        : darkWorld (bool)
│    ├─── 0x0 : mapTime (float)                               ├─── 0x10       : truckWidth (float)
│    ├─── 0x4 : totalTime (float)                             ├─── 0x14       : drag (float)
│    ├─── 0x8 : mapDeaths (int)                               ├─── 0x18       : speedMultiplier (float)
│    └─── 0xC : totalDeaths (int)                             ├─── 0x1C       : scoreMultiplier (float)
│                                                             ├─── 0x20, 0x14 : abilityName (string)
├─── 0x14 : player                                            ├─── 0x24, 0x14 : utilityName (string)
│    ├─── 0x7C : canMove (bool)                               ├─── 0x28       : levelLength (float)
│    ├─── 0x7D : dead (bool)                                  ├─── 0x2C       : previousLevel (int)
│    ├─── 0x7E : frozen (bool)                                ├─── 0x30       : onLastLevel (bool)
│    ├─── 0x88 : framesSinceStart (float)                     ├─── 0x31       : playing (bool)
│    ├─── 0x90 : running (bool)                               ├─── 0x34       : pauseFrames (int)
│    ├─── 0x91 : walking (bool)                               ├─── 0x38       : paused (bool)
│    └─── 0xD0 : boosting (bool)                              ├─── 0x44       : currentChristmasLevel (int)
│                                                             ├─── 0x50       : currentHalloweenLevel (int)
├─── 0x5C : done (bool)                                       ├─── 0x54       : currentLevel (int)
├─── 0x5D : won (bool)                                        └─── 0x58       : currentWorld (int)
└─── 0x68 : sinceWon (float)

steam_WorkshopHandler : "mono.dll", 0x20B574, 0x10, 0x130, 0x4
│
├─── 0x78, 0x14 : RealMapName (string)
├─── 0x90       : time (float)
├─── 0x94       : score (int)
└─── 0x98       : currentRetryCount (int)
*/

state("Clustertruck", "v1.1") {
	float levelTime         : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x0, 0xC, 0x0; // Pointer: GameManager > static fields > mapTime (float) 
	float framesSinceStart  : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x14, 0x88;    // Pointer: GameManager > player > framesSinceStart (float) 
	float levelCompleteTime : "mono.dll", 0x20B574, 0x10, 0x130, 0x4, 0x90;                 // Pointer: steam_WorkshopHandler > time (float)
	
	bool isDead    : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x14, 0x7D; // Pointer: GameManager > player > dead (bool) 
	int  inMenuVal : "mono.dll", 0x1F30AC, 0x7D4, 0xC, 0x40, 0x90;              // Why is inMenuVal not in the pointertree?
	
	int christmasLevel : "mono.dll", 0x20B574, 0x10, 0x158, 0x44; // Pointer: info > currentChristmasLevel (int)
	int halloweenLevel : "mono.dll", 0x20B574, 0x10, 0x158, 0x50; // Pointer: info > currentHalloweenLevel (int)
	int level          : "mono.dll", 0x20B574, 0x10, 0x158, 0x54; // Pointer: info > currentLevel (int)
	int world          : "mono.dll", 0x20B574, 0x10, 0x158, 0x58; // Pointer: info > currentWorld (int)
}


// Runs when the script is first loaded
startup {
	// Settings initialisation
	Object[,] settingsArray = new Object[,] { // trademark Noah :)
	//	| ID                   | Dflt  | Name                 | Parent  | Description                                                                 |
		{ "reset"              , true  , "Reset"              , null    , "Disable or enable all automatic reset functionality."                      },
		{ "resetFirstLevel"    , true  , "In first level"     , "reset" , "Reset the timer when you restart or die on the first level."               },
		{ "resetPreviousLevel" , true  , "On previous level"  , "reset" , "Reset the timer when a previous level is selected."                        },
		{ "resetOnDeath"       , false , "On death"           , "reset" , "Reset the timer when the player dies."                                     },
		{ "resetInMenu"        , false , "In menu"            , "reset" , "Reset the timer when going to the menu."                                   },
		{ "splitByLevel"       , true  , "Split by level"     , null    , "Enable to use level splits, disable to use world splits."                  },
		{ "startInLevel"       , true  , "Start in level"     , null    , "Start the timer when restarting in a level."                               },
		{ "startAnyLevel"      , false , "Start in any level" , null    , "Start the timer in any level, instead of only the first (useful for ILs)." },
		{ "debugMode"          , false , "Debug mode"         , null    , "Enables debugging logging. Use debugview to view output."                  }
	};
	
	for (int i = 0; i < settingsArray.GetLength(0); i++) {
		string setId          = settingsArray[i, 0];
		bool   setDefault     = settingsArray[i, 1];
		string setName        = settingsArray[i, 2]; // Called description by livesplit.
		string setParent      = settingsArray[i, 3]; // appending ``?? null`` to this removes the need to have null specified in the above settings array.
		string setDescription = settingsArray[i, 4]; // Called tooltip by livesplit.

		settings.Add(setId, setDefault, setName, setParent);
		settings.SetToolTip(setId, setDescription);
	}

	refreshRate = 1000; // Change in future? 1000 is a bit much when the default is 60.
}


// Runs when the game process is found.
init {
	version = "v1.1"; // We only support the latest version of the game.
	vars.previousLevel = 0;
	vars.previousChristmasLevel = 0;
	vars.levelsCompleted = 0;
}


// The update action always runs first.
update {
	if (current.inMenuVal == 0) { return false; } // Don't run the next actions unless inMenuVal initialized.

	current.isInMenu = (current.inMenuVal != 108 && current.inMenuVal != 109); // Set boolean for is in menu instead of random constant.
	vars.firstGameplayFrame = (old.framesSinceStart == 0 && current.framesSinceStart > 0);
	vars.firstLevelCompleteFrame = (old.levelCompleteTime != current.levelCompleteTime);


	// Surely this entire (indented) section could be put in the split action? Also keep in mind restarting is allowed for the first 2 seconds of a level for deathless categories.
		if (current.level != old.level) { // A player spawn happens when a player enters a level, dies, or restarts a level. Important for resetOnRestart.
			vars.previousLevel = old.level;
			vars.previousChristmasLevel = old.christmasLevel; // Try removing this I dare you, the problem here is it's not enough to just say current.christmasLevel = 5 because that never changes once you leave the world.
		}

	if (settings["debugMode"]) {
		print("------------------------------");
		print("World:              " + current.world);
		print("Level:              " + current.level);
		print("Christmas Level:    " + current.christmasLevel);
		print("Halloween Level:    " + current.halloweenLevel);
		print("Last Played Level:  " + vars.previousLevel);
		print("Levels Completed:   " + vars.levelsCompleted);
		print("Is In Menu:         " + current.isInMenu);
		print("Level Time:         " + current.levelTime);
		print("Frames Since Start: " + current.framesSinceStart);
		print("Is Dead:            " + current.isDead);
	}
}


// Doesn't run if the update action returns false OR the timer has already been started.
start {
	bool start = ( 
		(settings["startInLevel"] || old.isInMenu) &&
		!current.isInMenu &&
		(settings["startAnyLevel"] || current.level % 10 == 1) &&
		vars.firstGameplayFrame
	);

	if (start) {
		vars.levelsCompleted = 0;
		current.playerSpawns = 0; // Unused, I'll assume you were doing something with it :P
		vars.previousLevel = current.level;
		vars.previousChristmasLevel = current.christmasLevel;
		return true;
	}
}


// Doesn't run if the update action returns false.
isLoading {
	bool isPlaying = (vars.firstGameplayFrame || current.isInMenu);
	if (vars.firstLevelCompleteFrame) { return true; }
	if (isPlaying) { return false; }
}


// Doesn't run if the update action returns false.
reset {
	bool resetFirstLevel = (
		settings["resetFirstLevel"] && 
		(settings["startAnyLevel"] || vars.levelsCompleted == 0) &&
		current.levelTime < 0.01 && 
		current.levelCompleteTime != 0
	);

	bool resetPreviousLevel = (
		settings["resetPreviousLevel"] && 
		(current.level - vars.previousLevel <= -1 && !current.isInMenu) && 
		!(current.christmasLevel == 5 && current.halloweenLevel == 1) &&                    // Don't reset when going from Holidays:5 to Halloween:1
		!(current.halloweenLevel == 10 && current.level == 1 && vars.levelsCompleted == 15) // Don't reset when going from Halloween:10 to 1:1
	);

	bool resetInMenu  = (settings["resetInMenu"] && current.isInMenu && !old.isInMenu);
	bool resetOnDeath = (settings["resetOnDeath"] && current.isDead);

	return resetFirstLevel || resetPreviousLevel || resetInMenu || resetOnDeath;
}


// Doesn't run if the reset action returns true
split {
	if (vars.firstLevelCompleteFrame) {
		vars.levelsCompleted++;
		return (
			settings["splitByLevel"] || 
			current.level % 10 == 0 || 
			(current.christmasLevel == 5 && vars.previousChristmasLevel == 4) // Split on Christmas:5 for split by world because christmas only goes to 5.
		);
	}
}
