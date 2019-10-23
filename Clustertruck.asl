state("Clustertruck")
{
	//AutoSplitter Made by Happyrobot33
	byte level : "mono.dll", 0x020B574, 0x10, 0x194, 0x0, 0x5C;
	int levelSelect : "mono.dll", 0x01F30AC, 0x7D4, 0xC, 0x40, 0x90;
	float Zcoord : "Clustertruck.exe", 0x0C54ECC, 0x634, 0x730, 0x2DC, 0x7B8, 0x35C;
}

init
{
	vars.split = 1;
}

update
{
	//print(current.level.ToString());
	//print(((current.level % 11) + 1).ToString());
	//print(vars.split.ToString());
	//print(vars.split.ToString());
	//print(current.levelSelect.ToString());
	//print(((float)(current.level - 1) / 10).ToString());
	//print(current.Zcoord.ToString());
	return true;
}

startup
{
	settings.Add("levelSplit", true, "Split Every Level");
	settings.SetToolTip("levelSplit", "This will configure the autosplitter to split on every level instead of splitting for each area.");
	settings.Add("areaSplit", false, "Single Area Splits");
	settings.SetToolTip("areaSplit", "This will configure the autosplitter to split for only individual areas instead of the whole game.");
    vars.split = 1;
}

start
{
	if (current.levelSelect == 108)
	{
		return true;
	}
	vars.split = 1;
}

split
{	
	if (current.level == 90 && current.Zcoord >= 200)
	{
		vars.split += 1;
		return true;
	}
	else if (((current.level % 11) + 1) > vars.split && settings["areaSplit"])
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
	if (current.levelSelect != 107 && ((current.level % 11) + 1) < vars.split && settings["areaSplit"])
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
