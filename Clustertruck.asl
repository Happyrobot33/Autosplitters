state("Clustertruck")
{
	//AutoSplitter Made by Happyrobot33
	int level : "mono.dll", 0x020B574, 0x10, 0x194, 0x0, 0x5C; //what level we are on
	int levelSelect : "mono.dll", 0x01F30AC, 0x7D4, 0xC, 0x40, 0x90; //if we are in level select
	float LevelTime : "mono.dll", 0x02048D0, 0x10, 0x110; //rta time
	float FinishedLevelTime : "mono.dll", 0x020B574, 0x10, 0x130, 0x4, 0x90; // leaderboard time in level
}

init
{
	vars.split = 1;
}

update
{
	if (settings["devMode"])
	{
		print(current.level.ToString());
		print(((current.level % 11) + 1).ToString());
		print(vars.split.ToString());
		print(current.levelSelect.ToString());
	}
	vars.areaLevel = Convert.ToInt32(current.level.ToString().Substring(current.level.ToString().Length-1, 1));
	if (vars.areaLevel == 0)
	{
		vars.areaLevel = 10;
	}
	return true;
}

startup
{
	settings.Add("levelSplit", true, "Split Every Level");
	settings.SetToolTip("levelSplit", "This will configure the autosplitter to split on every level instead of splitting for each area.");
	settings.Add("areaSplit", false, "Single Area Splits");
	settings.SetToolTip("areaSplit", "This will configure the autosplitter to split for only individual areas instead of the whole game.");
	settings.Add("devMode", false, "Dev Mode");
	settings.SetToolTip("devMode", "This enables dev mode, allowing for debugging. Leave false if you dont know what you are doing");   
	vars.split = 1;
}

start
{
	if (current.levelSelect == 108 && vars.areaLevel == 1 && old.LevelTime == 0 && current.LevelTime <= 1)
	{
	        return true;
	}
	vars.split = 1;
}

split
{	
	if (current.level == 90 && old.FinishedLevelTime != current.FinishedLevelTime && current.levelSelect == 108) //make sure we are on the last level, make sure the leaderboard time updated, and make sure we are in the level
	{
		vars.split += 1;
		print("1 split");
		return true;
	}
	else if (vars.areaLevel > vars.split && settings["areaSplit"])
	{
		vars.split += 1;
		print("2 split");
		return true;
	}
    else if (current.level > vars.split && settings["levelSplit"] && !settings["areaSplit"])
	{
		vars.split += 1;
		print("3 split");
		return true;
	}
	else if (((float)current.level / 10) > vars.split && !settings["areaSplit"])
	{
		vars.split += 1;
		print("4 split");
		return true;
	}
}

reset
{
	if (vars.areaLevel < vars.split && settings["areaSplit"])
	{
		vars.split = 1;
		return true;
	}
	else if (current.levelSelect != 108 && current.level < vars.split)
	{
		vars.split = 1;
		return true;
	}
}

isLoading
{
	if(old.LevelTime == current.LevelTime){
		return true;
	}
	else
	{
		return false;
	}
}
