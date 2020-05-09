//defines pointers to be pulling variables from
state("Clustertruck")
{
	//AutoSplitter Made by Happyrobot33
	int level : "mono.dll", 0x020B574, 0x10, 0x158, 0x54; //what level we are on
	int inMenuValue : "mono.dll", 0x01F30AC, 0x7D4, 0xC, 0x40, 0x90; //if we are in level select
	//float levelTime : "mono.dll", 0x020B574, 0x10, 0x13C, 0x0, 0x28, 0x7F8; //IGT (Backup as new address might not be full fix)
	float levelTime : "Clustertruck.exe", 0x00F6B420, 0x20, 0x1C, 0x48, 0x30, 0x14, 0x0, 0x38; //new HOTFIX for some users, might need better solution
	float finishedLevelTime : "mono.dll", 0x020B574, 0x10, 0x130, 0x4, 0x90; // leaderboard time in level
	int inDeathScreen : "Clustertruck.exe", 0x0F4CAB0, 0x0, 0x4, 0xAC, 0xB4, 0x654; //Death info. goes from 0 to 144 when in death screen
}

//triggers upon the game being found
init
{
	vars.split = 1; //set our current split to the first split. this variable is only used internally to determine where we are, although this should be correct under normal conditions
	vars.loading = false; //determine if we are currently loading or not. this helps with IGT which is not fully completed yet
	vars.finishedLevel = false; //determine if we completed a level. Helps with IGT which is not fully completed
	vars.deaths = 0; //reset the death count. Currently not fully functional
	vars.deathCounted = false; //determine if we have already counted a death. does work
}

//triggers every livesplit tick
update
{
	vars.isDead = current.inDeathScreen != 0; //determine if the player is dead in the current tick
	vars.inMenu = current.inMenuValue != 108; //determine if the player is in the menu in the current tick
	
	//death counter logic.
	if(vars.isDead && !vars.deathCounted && !vars.inMenu){
		vars.deathCounted = true; //block re execution of this logic
		vars.deaths++; //add one to deaths
	}
	else if(!vars.isDead){
		vars.deathCounted = false; //unlock execution if alive again
	}

	vars.worldLevel = Convert.ToInt32(current.level.ToString().Substring(current.level.ToString().Length-1, 1)); //determine what level in a world you are currently in IE 5:4 would make this 4
	
	//if we are on Desert, the above code doesnt get the right value, so this overides the value to what we need
	if (vars.worldLevel == 0)
	{
		vars.worldLevel = 10;
	}
	
	//print a bunch of debug info
	if (settings["devMode"]) // You can disable carriage returns in the options for the debug view to fix the debug being weird. You can also extend the debug print to show more and change the font.
	{
		print("Current Level: " + current.level);
		print("Current Level In World: " + vars.worldLevel);
		print("Current Split: " + vars.split);
		print("Are we in the menu?: " + vars.inMenu);
		print("Level Time: " + current.levelTime);
		print("Leaderboard Time: " + current.finishedLevelTime);
		print("Dead: " + vars.isDead);
		print("Deaths: " + vars.deaths);
	}

	return true; //return true to allow the script to continue
}

//triggers when the script first loads
startup
{
	settings.Add("levelSplit", true, "Split by Level");
	settings.SetToolTip("levelSplit", "True splits per level, false splits per world.");
	//settings.Add("worldSplit", false, "Individual Worlds");
	//settings.SetToolTip("worldSplit", "This will allow you to run individual worlds instead of the whole game (Overides any%)");
	settings.Add("devMode", false, "Dev Mode");
	settings.SetToolTip("devMode", "This enables dev mode, allowing for debugging. Leave false if you dont know what you are doing");   
	vars.split = 1;
}

//triggers at the start of every new run
start
{
	vars.deaths = 0; //reset deaths

	//if we are in the first level of a world and the level time has begun, start the timer
	if (!vars.inMenu && vars.worldLevel == 1 && old.levelTime == 0 && current.levelTime > 0)
	{
		vars.lastLevel = current.level; //reset what the last level was. used for splitting
	    return true;
	}
	vars.split = 1; //reset splits
}

//determines when to split. runs every livesplit tick
split
{	
	vars.newLevelStart = (vars.lastLevel != current.level && old.levelTime == 0 && current.levelTime > 0); // old.level does work alone, but in this scenario it updates too early so we have to manually update what the last level was in order for us to not be 300ms out of sync
	
	//if the current level is the boss, then only split if the leaderboard time has changed from level load
	if (current.level == 90 && old.finishedLevelTime != current.finishedLevelTime && current.inMenuValue == 108)
	{
		vars.split += 1;
		print("1 split");
		return true;
	}
	else if (vars.newLevelStart && settings["levelSplit"]) //split if we have entered a new level
	{
		vars.split += 1;
		vars.lastLevel = current.level;
		print("2 split");
		return true;
	}
	else if (vars.newLevelStart && vars.worldLevel == 1 && !settings["levelSplit"]) //split if we load a new world and are on the corresponding setting
    {
        vars.split += 1;
        vars.lastLevel = current.level;
        print("World split");
        return true;
    }
}

//determine when to reset the timer
reset
{
	//if the previous ticks level is ahead of the current one, reset
	if (old.level > current.level)
	{
		vars.split = 1;
		return true;
	}
}

//pause timer when game is loading
//IN PROGGRESS, NO COMMENTS WILL BE MADE
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
