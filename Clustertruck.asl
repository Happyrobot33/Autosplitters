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
	int world              : "mono.dll", 0x20B574, 0x10, 0x158, 0x58;

	float mapTime          : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x0, 0xC, 0x0;
	float totalTime        : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x0, 0xC, 0x4;
	bool dead              : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x14, 0x7D;
	float framesSinceStart : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x14, 0x88;

	int inMenuVal          : "mono.dll", 0x1F30AC, 0x7D4, 0xC, 0x40, 0x90;
}

startup {
	var tB = (Func<string, bool, string, string, Tuple<string, bool, string, string>>) ((elmt1, elmt2, elmt3, elmt4) => { return Tuple.Create(elmt1, elmt2, elmt3, elmt4); });
	var sB = new List<Tuple<string, bool, string, string>> {
		tB("levelSplit", true, "Split by Level", "On splits per level, off splits per world."),
		tB("resetInMenu", true, "Reset In Menu", "Autosplitter resets when going to the menu"),
		tB("onlyStartFromLoad", false, "Only Start from Level Load", "Results in the timer only starting when loading\na level from the level select screen."),
		tB("splitByWorldHolidays", false, "Split By World Holidays", "First 5 levels autosplitter will split for Holidays, afterwards split by world is every 10 levels"),
		tB("devMode", false, "Developer Mode", "This enables dev mode, allowing for debugging."),
		tB("startEveryLevel", false, "Start on every level", "Use this if you want to time ILs (empty split file recommended).")
	};

	foreach (var s in sB) {
		settings.Add(s.Item1, s.Item2, s.Item3);
		settings.SetToolTip(s.Item1, s.Item4);
	}

	refreshRate = 1000;
}

init {
	current.isInLevel = true;
	vars.loadedIn = false;
	vars.deaths = 0;
	vars.startTime = 0;
	vars.currentSplit = 0;
}

update {
	if (current.inMenuVal == 0) return false;

	current.isInMenu = current.inMenuVal != 108 && current.inMenuVal != 109;
	if (old.workshopTime != current.workshopTime) current.isInLevel = false;
	if (old.framesSinceStart == 0.0 && current.framesSinceStart > 0.0) current.isInLevel = true;

	if (settings["devMode"]) {
		if (!old.dead && current.dead) vars.deaths++;
		print("Current Level: " + current.level);
		print("Current World: " + current.world);
		print("Current Level in World: " + current.world + ":" + current.level % 10);
		print("Level Time: " + current.mapTime);
		print("Total Time: " + (current.totalTime + current.mapTime - vars.startTime));
		print("Dead: " + current.dead);
		print("Deaths: " + vars.deaths);
		print("Are we in the menu?: " + current.isInMenu + " (" + current.inMenuVal + ")");
		print("Are we in level?: " + current.isInLevel);
	}
}

start {
	vars.currentSplit = 0;
	if (settings["onlyStartFromLoad"]) {
		if (old.isInMenu && !current.isInMenu) vars.loadedIn = true;
	} else vars.loadedIn = true;

	if (vars.loadedIn && !current.isInMenu && (settings["startEveryLevel"] ? true : current.level % 10 == 1) && old.framesSinceStart == 0.0 && current.framesSinceStart > 0.0) {
		vars.deaths = 0;
		vars.startTime = current.totalTime;
		vars.loadedIn = false;
		return true;
	}
}

split {
	if (old.workshopTime != current.workshopTime)
	{
		vars.currentSplit++;
		if(settings["levelSplit"])
		{
			return true;
		}
		else
		{
			if(current.level % 10 == 0)
			{
				return true;
			}
			if(vars.currentSplit == 5 && settings["splitByWorldHolidays"])
			{
				return true;
			}
		}
	}
		
}

reset {
	// If in menu or reset in first level, restart the timer if reset option is on
	// Adjust current.mapTime <= 0.01 if there are any issues with it not resetting
	return (!old.isInMenu && current.isInMenu && settings["resetInMenu"]) || ((settings["startEveryLevel"] ? true : current.level % 10 == 1) && vars.currentSplit == 0 && current.mapTime <= 0.01 && current.workshopTime != 0);
}

isLoading {
	return !current.isInLevel && !current.isInMenu;
}
