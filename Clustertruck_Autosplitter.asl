state("Clustertruck")
{
	//AutoSplitter Made my Happyrobot33
	byte level : "mono.dll", 0x020B574, 0x10, 0x194, 0x0, 0x5C;
	int levelSelect : "mono.dll", 0x00531A4, 0x8, 0x8, 0x0, 0x7A0;
}

init
{
	vars.split = 1;
}

update
{
	//print(current.level.ToString());
	//print(vars.split.ToString());
	print(current.levelSelect.ToString());
	return true;
}

startup
{
    vars.split = 1;
}

start
{
	//9 is when we are in the main game.
	if (current.levelSelect != 0)
	{
		return true;
	}
	vars.split = 1;
}

split
{	
    if (current.level > vars.split)
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