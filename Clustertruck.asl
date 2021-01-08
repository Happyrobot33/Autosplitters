// Original script by Happyrobot33.
// Enhancements by Ero.

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
 * * 0x5C : won (bool),                                          * * 0x54       : currentLevel (int),
 * * 0x68 : sinceWon (float)                                     * * 0x58       : currentWorld (int)
 */

state("Clustertruck") {
	bool playing    : "mono.dll", 0x20B574, 0x10, 0x158, 0x31;
	bool paused     : "mono.dll", 0x20B574, 0x10, 0x158, 0x38;
	int level       : "mono.dll", 0x20B574, 0x10, 0x158, 0x54;
	int world       : "mono.dll", 0x20B574, 0x10, 0x158, 0x58;
	bool dead       : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x14, 0x7D;
	float mapTime   : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x0, 0xC, 0x0;
	float totalTime : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x0, 0xC, 0x4;
	int mapDeaths   : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x0, 0xC, 0x8;
	int totalDeaths : "mono.dll", 0x1F36AC, 0x20, 0xE80, 0x1C, 0x14, 0x0, 0xC, 0xC;
	int inMenuVal   : "mono.dll", 0x1F30AC, 0x7D4, 0xC, 0x40, 0x90;
}

startup {
	var tB = (Func<string, bool, string, string, Tuple<string, bool, string, string>>) ((elmt1, elmt2, elmt3, elmt4) => { return Tuple.Create(elmt1, elmt2, elmt3, elmt4); });
	var sB = new List<Tuple<string, bool, string, string>> {
		tB("levelSplit", true, "Split by Level", "On splits per level, off splits per world."),
		tB("onlyStartFromLoad", false, "Only Start from Level Load", "Results in the timer only starting when loading\na level from the level select screen."),
		tB("devMode", false, "Developer Mode", "This enables dev mode, allowing for debugging.")
	};

	foreach (var s in sB) {
		settings.Add(s.Item1, s.Item2, s.Item3);
		settings.SetToolTip(s.Item1, s.Item4);
	}
}

init {
	vars.inMenu = true;
	vars.deaths = 0;
	vars.startTime = 0;
}

update {
	if (current.inMenuVal == 0) return false;

	vars.inMenu = current.inMenuVal != 108 && current.inMenuVal != 109;
	if (!old.dead && current.dead) vars.deaths++;

	if (settings["devMode"])
		print(
			"Current Level: " + current.level + "\n" +
			"Current World: " + current.world + "\n" +
			"Current Level in World:" + current.world + ":" + (current.level % 10) + "\n\n" +
			"Level Time: " + current.mapTime + "\n" +
			"Total Time: " + (current.totalTime + current.mapTime - vars.startTime) + "\n" +
			"Dead: " + current.dead + "\n" +
			"Deaths: " + vars.deaths + "\n\n" +
			"Are we in the menu?: " + vars.inMenu + "(" + current.inMenuVal + ")"
		);
}

start {
	current.isInMenu = vars.inMenu;
	bool inLevel = settings["onlyStartFromLoad"] ? old.isInMenu && !current.isInMenu : true;
	if (!current.isInMenu && inLevel && current.level % 10 == 1 && old.mapTime == 0 && current.mapTime > 0) {
		vars.deaths = 0;
		vars.startTime = current.totalTime;
		return true;
	}
}

split {
	if (old.totalTime != current.totalTime) return settings["levelSplit"] ? true : current.level % 10 == 0;
}

reset {
	current.isInMenu = vars.inMenu;
	return !old.isInMenu && current.isInMenu;
}

gameTime {
	var timePlaying = TimeSpan.FromSeconds(current.totalTime + current.mapTime - vars.startTime);
	var timeScore = TimeSpan.FromSeconds(current.totalTime - vars.startTime);
	return current.playing ? timePlaying : timeScore;
}

isLoading {
	return true;
}
