// Original script by Happyrobot33.
// Enhancements by Ero.

state("Clustertruck") {
	bool playing    : "mono.dll", 0x20B574, 0x10, 0x158, 0x31; // info
	bool paused     : "mono.dll", 0x20B574, 0x10, 0x158, 0x38; // info
	int level       : "mono.dll", 0x20B574, 0x10, 0x158, 0x54; // info
	int world       : "mono.dll", 0x20B574, 0x10, 0x158, 0x58; // info
	bool dead       : "mono.dll", 0x20B574, 0x10, 0x318, 0x0, 0x130, 0x7D; // player
	float mapTime   : "mono.dll", 0x20B574, 0x100, 0x310, 0xA4, 0x44, 0xC, 0x0; // GameManager
	float totalTime : "mono.dll", 0x20B574, 0x100, 0x310, 0xA4, 0x44, 0xC, 0x4; // GameManager
	int mapDeaths   : "mono.dll", 0x20B574, 0x100, 0x310, 0xA4, 0x44, 0xC, 0x8; // GameManager
	int totalDeaths : "mono.dll", 0x20B574, 0x100, 0x310, 0xA4, 0x44, 0xC, 0xC; // GameManager
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
