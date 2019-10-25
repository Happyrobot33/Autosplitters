state("Clustertruck")
{
	//AutoSplitter Made by Happyrobot33
	int level : "mono.dll", 0x020B574, 0x10, 0x194, 0x0, 0x5C;
	int levelSelect : "mono.dll", 0x01F30AC, 0x7D4, 0xC, 0x40, 0x90;
	int bossButtonStatus : "mono.dll", 0x020B574, 0x10, 0x33C, 0x14; // 1 if boss beaten
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
	if (current.levelSelect == 108 && vars.areaLevel == 1)
	{
	        return true;
	}
	vars.split = 1;
}

split
{	
	if (current.level == 90 && current.bossButtonStatus == 1 && current.levelSelect == 108)
	{
		vars.split += 1;
		return true;
	}
	else if (vars.areaLevel > vars.split && settings["areaSplit"])
	{
		vars.split += 1;
		return true;
	}
    else if (current.level > vars.split && settings["levelSplit"] && !settings["areaSplit"])
	{
		vars.split += 1;
		return true;
	}
	else if (((float)current.level / 10) > vars.split && !settings["areaSplit"])
	{
		vars.split += 1;
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
