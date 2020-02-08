state("Clustertruck")
{
	//AutoSplitter Made by Happyrobot33
	int level : "mono.dll", 0x020B574, 0x10, 0x158, 0x54; //what level we are on
	int inMenuValue : "mono.dll", 0x01F30AC, 0x7D4, 0xC, 0x40, 0x90; //if we are in level select
	float levelTime : "mono.dll", 0x020B574, 0x10, 0x13C, 0x0, 0x28, 0x7F8; //IGT
	float finishedLevelTime : "mono.dll", 0x020B574, 0x10, 0x130, 0x4, 0x90; // leaderboard time in level
}

init
{
	vars.split = 1;
	vars.loading = false;
	vars.finishedLevel = false;
}

update
{
	vars.inMenu = current.inMenuValue != 108;
	if (settings["devMode"]) // You can disable carriage returns in the options for the debug view to fix the debug being weird. You can also extend the debug print to show more and change the font.
	{
		print("Current Level: " + current.level);
		print("Current Level In World: " + vars.worldLevel);
		print("Current Split: " + vars.split);
		print("Are we in the menu?: " + vars.inMenu);
		print("Level Time: " + current.levelTime);
		print("Leaderboard Time: " + current.finishedLevelTime);
	}
	vars.worldLevel = Convert.ToInt32(current.level.ToString().Substring(current.level.ToString().Length-1, 1));
	if (vars.worldLevel == 0)
	{
		vars.worldLevel = 10;
	}
	return true;
}

startup
{
	settings.Add("levelSplit", true, "Full Game");
	settings.SetToolTip("levelSplit", "This is the default way to run the game from 1:1 to the end");
	//settings.Add("worldSplit", false, "Individual Worlds");
	//settings.SetToolTip("worldSplit", "This will allow you to run individual worlds instead of the whole game (Overides any%)");
	settings.Add("devMode", false, "Dev Mode");
	settings.SetToolTip("devMode", "This enables dev mode, allowing for debugging. Leave false if you dont know what you are doing");   
	vars.split = 1;
}

start
{
	if (!vars.inMenu && vars.worldLevel == 1 && old.levelTime == 0 && current.levelTime > 0)
	{
		vars.lastLevel = current.level;
	    return true;
	}
	vars.split = 1;
}

split
{	
	vars.newLevelStart = (vars.lastLevel != current.level && old.levelTime == 0 && current.levelTime > 0); // old.level does work alone, but in this scenario it updates too early so we have to manually update what the last level was in order for us to not be 300ms
	if (current.level == 90 && old.finishedLevelTime != current.finishedLevelTime && current.inMenuValue == 108) //make sure we are on the last level, make sure the leaderboard time updated, and make sure we are in the level
	{
		vars.split += 1;
		print("1 split");
		return true;
	}
	else if (vars.newLevelStart)
	{
		vars.split += 1;
		vars.lastLevel = current.level;
		print("2 split");
		return true;
	}
}

reset
{
	if (old.level > current.level)
	{
		vars.split = 1;
		return true;
	}
}

isLoading
{
	/*
	if(current.levelTime > 0 && !vars.finishedLevel){
		vars.loading = false;
	}
	if(old.finishedLevelTime != current.finishedLevelTime){
		vars.loading = true;
		vars.finishedLevel = true;
	}
	if(old.Level != current.Level){
		vars.finishedLevel = false;
	}
	return vars.loading;
	*/
}
