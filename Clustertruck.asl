/*
 * GameManager : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14   * info : "mono.dll", 0x20B574, 0x10, 0x158
 * * 0x0, 0xC : static fields,                                   * * 0x4        : darkWorld (bool),
 *   * 0x0 : mapTime (float),                                    * * 0x10       : truckWidth (float),
 *   * 0x4 : totalTime (float),                                  * * 0x14       : drag (float),
 *   * 0x8 : mapDeaths (int),                                    * * 0x18       : speedMultiplier (float),
 *   * 0xC : totalDeaths (int)                                   * * 0x1C       : scoreMultiplier (float),
 * *                                                             * * 0x20, 0x14 : abilityName (string),
 * * 0x14 : player,                                              * * 0x24, 0x14 : utilityName (string),
 *   * 0x7C : canMove (bool),                                    * * 0x28       : levelLength (float),
 *   * 0x7D : dead (bool),                                       * * 0x2C       : lastPlayedLevel (int),
 *   * 0x7E : frozen (bool),                                     * * 0x30       : onLastLevel (bool),
 *   * 0x88 : framesSinceStart (float),                          * * 0x31       : playing (bool),
 *   * 0x90 : running (bool),                                    * * 0x34       : pauseFrames (int),
 *   * 0x91 : walking (bool),                                    * * 0x38       : paused (bool),
 *   * 0xD0 : boosting (bool),                                   * * 0x44       : currentChristmasLevel (int),
 * * 0x5C : done (bool),                                         * * 0x50       : currentHalloweenLevel (int),
 * * 0x5D : won (bool),                                          * * 0x54       : currentLevel (int),
 * * 0x68 : sinceWon (float)                                     * * 0x58       : currentWorld (int)
 *
 * steam_WorkshopHandler : "mono.dll", 0x20B574, 0x10, 0x130, 0x4
 * * 0x78, 0x14 : RealMapName (string),
 * * 0x90       : time (float),
 * * 0x94       : score (int),
 * * 0x98       : currentRetryCount (int)
 */

state("Clustertruck") {
	float workshopTime     : "mono.dll", 0x20B574, 0x10, 0x130, 0x4, 0x90;

	int level              : "mono.dll", 0x20B574, 0x10, 0x158, 0x54;
	int christmasLevel     : "mono.dll", 0x20B574, 0x10, 0x158, 0x44;
	int halloweenLevel     : "mono.dll", 0x20B574, 0x10, 0x158, 0x50; 
	int world              : "mono.dll", 0x20B574, 0x10, 0x158, 0x58;

	float gameTimer        : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x0, 0xC, 0x0; // mapTime
	bool isDead            : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x14, 0x7D; // dead
	float framesSinceStart : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x14, 0x88;

	int inMenuVal          : "mono.dll", 0x1F30AC, 0x7D4, 0xC, 0x40, 0x90;
}

startup {
	// Setting initialization
	Object[,] settingsArray = new Object[,] {
		{"reset", true, "Reset", "By itself does nothing, enable other reset options for it to do anything. False means other options are disabled", null},
		{"resetFirstLevel", true, "Reset First Level", "Autosplitter resets when you restart or die on the first level", "reset"},
		{"resetLevelBackwards", true, "Reset if Level Backwards", "Autosplitter resets if the level number decrements like if the player selects an earlier level", "reset"},
		{"resetOnDeath", true, "Reset on Death", "Autosplitter resets when the player dies", "reset"},
		{"resetInMenu", false, "Reset in Menu", "Autosplitter resets when going to the menu", "reset"},
		{"levelSplit", true, "Split by Level", "On splits per level, off splits per world.", null},
		{"onlyStartFromLoad", false, "Only Start From Level Load", "Results in the timer only starting when loading\na level from the level select screen", null},
		{"startEveryLevel", false, "Start on Every Level", "Use this if you want to time ILs (empty split file recommended)", null},
		{"devMode", false, "Developer Mode", "This enables developer mode, allowing for debugging", null}
	};
	for (int i = 0; i < settingsArray.GetLength(0); i++) {
		settings.Add((string)settingsArray[i, 0], (bool)settingsArray[i, 1], (string)settingsArray[i, 2], (string)settingsArray[i, 4]);
  		settings.SetToolTip((string)settingsArray[i, 0], (string)settingsArray[i, 3]);
	}

	refreshRate = 1000;
}

init {
	vars.lastPlayedLevel = 0;
	vars.lastPlayedChristmasLevel = 0;
	vars.levelsCompleted = 0;
}

update {
	// Don't run checking unless inMenuVal initialized
	if (current.inMenuVal == 0) {
		return false;	
	}

	// Set boolean for is in menu instead of random constant
	current.isInMenu = current.inMenuVal != 108 && current.inMenuVal != 109;
	vars.firstGameplayFrame = old.framesSinceStart == 0 && current.framesSinceStart > 0;
	vars.firstLevelCompleteFrame = old.workshopTime != current.workshopTime;

	// A player spawn happens when a player enters a level, dies, or restarts a level. Important for resetOnRestart
	if(current.level != old.level) {
		vars.lastPlayedLevel = old.level;	
		// Try removing this I dare you, the problem here is its not enough to just say current.christmasLevel = 5 because that never changes once you leave the world
		vars.lastPlayedChristmasLevel = old.christmasLevel;
	}

	if (settings["devMode"]) {
		print("------------------------------");
		print("Current Level: " + current.level);
		print("Current Christmas Level: " + current.christmasLevel);
		print("Current Halloween Level: " + current.halloweenLevel);
		print("Last Played Level: " + vars.lastPlayedLevel);
		print("Current World: " + current.world);
		print("Levels Completed: " + vars.levelsCompleted);
		print("Is In Menu: " + current.isInMenu);
		print("Game Timer: " + current.gameTimer);
		print("Frames Since Start: " + current.framesSinceStart);
		print("Is Dead: " + current.isDead);
	}
}

start {
	bool start = 	
		(!settings["onlyStartFromLoad"] || old.isInMenu) && 
		!current.isInMenu && 
		(settings["startEveryLevel"] ? true : current.level % 10 == 1) && 
		vars.firstGameplayFrame;

	if (start) {
		vars.levelsCompleted = 0;
		current.playerSpawns = 0;
		vars.lastPlayedLevel = current.level;
		vars.lastPlayedChristmasLevel = current.christmasLevel;
		return true;
	}
}

split {
	if(vars.firstLevelCompleteFrame)
	{
		vars.levelsCompleted++;
		return 
			settings["levelSplit"] ||
			current.level % 10 == 0 || 
			(current.christmasLevel == 5 && vars.lastPlayedChristmasLevel == 4);
	}
}

reset {
	// 0.01s, if the time is 0 again, then we want to reset
	bool resetInLevel = 
		settings["resetFirstLevel"] && 
		(settings["startEveryLevel"] ? true : vars.levelsCompleted == 0) && 
		current.gameTimer < 0.01 && 
		current.workshopTime != 0;

	bool resetBackwards = 
		settings["resetLevelBackwards"] && current.level - vars.lastPlayedLevel <= -1 && !current.isInMenu &&
		!(current.christmasLevel == 5 && current.halloweenLevel == 1) &&
		!(current.halloweenLevel == 10 && current.level == 1 && vars.levelsCompleted == 15);

	bool resetMenu = settings["resetInMenu"] && current.isInMenu && !old.isInMenu;
	bool resetOnDeath = settings["resetOnDeath"] && current.isDead;

	return resetInLevel || resetBackwards || resetMenu || resetOnDeath;
}

isLoading {
	bool isPlaying = vars.firstGameplayFrame || current.isInMenu;
	if (vars.firstLevelCompleteFrame) { return true; }
	if (isPlaying) { return false; }
}
