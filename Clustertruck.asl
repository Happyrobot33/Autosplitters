state("Clustertruck")
{
	//AutoSplitter Made my Happyrobot33
	byte level : "mono.dll", 0x020B574, 0x10, 0x194, 0x0, 0x5C;
	int levelSelect : "Clustertruck.exe", 0x0F38EDC, 0x28;
}

init
{
	vars.split = 1;
}

update
{
	//print(current.level.ToString());
	//print(vars.split.ToString());
	//print(current.levelSelect.ToString());
	//print(((float)(current.level - 1) / 10).ToString());
	return true;
}

startup
{
	settings.Add("splitType", true, "Split Every Level");
	settings.SetToolTip("splitType", "This will configure the autosplitter to split on every level instead of splitting for each area.");
    vars.split = 1;
}

start
{
	if (current.levelSelect != 0)
	{
		return true;
	}
	vars.split = 1;
}

split
{	
    if (current.level > vars.split && settings["splitType"])
	{
		vars.split += 1;
		return true;
	}
	else if (((float)current.level / 10) > vars.split)
	{
		vars.split += 1;
		return true;
	}
}

reset
{
	if (current.levelSelect == 0)
	{
		vars.split = 1;
		return true;
	}
}
