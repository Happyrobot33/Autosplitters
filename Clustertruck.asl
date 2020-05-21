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
	vars.afterDeath = false;
	vars.afterDeathTimer = 0;
	vars.deathCounted = false; //determine if we have already counted a death. does work
	vars.newLevelStart = false; //determine if a new level was started
}

//triggers every livesplit tick
update
{
	vars.isDead = current.inDeathScreen != 0; //determine if the player is dead in the current tick
	vars.inMenu = current.inMenuValue != 108 && current.inMenuValue != 109; //determine if the player is in the menu in the current tick

	print("timer: " + vars.afterDeathTimer);
	print("afterDeath: " + vars.afterDeath);

	if (vars.afterDeath && current.inDeathScreen != 144) //add 1 to the timer if the player exited the death screen
	{
		vars.afterDeathTimer++;
	}

	if (vars.afterDeathTimer == 20) //if the timer reaches 20 reset the timer and afterDeath variable
	{
		vars.afterDeath = false;
		vars.afterDeathTimer = 0;
	}
	
	if (current.inDeathScreen == 144) //if the player is dead start the timer
	{
		vars.afterDeath = true;
	}
	
	//death counter logic.
	if (vars.isDead && !vars.deathCounted && !vars.inMenu)
	{
		vars.deathCounted = true; //block re execution of this logic
		vars.deaths++; //add one to deaths
	}
	else if(!vars.isDead)
	{
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
		print("Are we in the menu value?: " + current.inMenuValue);
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
	settings.Add("beta", false, "Beta Features");
	settings.SetToolTip("beta", "This is only used for beta testers to test features that aren't fully working or fully tested");
	settings.Add("noRestartAfterDeath", true, "Don't restart after death");
	settings.SetToolTip("noRestartAfterDeath", "Don't restart after pressing reset in a death screen on a starting level.");
	vars.split = 1;
}

//triggers at the start of every new run
start
{
	if (settings["noRestartAfterDeath"] && vars.afterDeath) //don't start right after a death screen
	{
		return false;
	}

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
	
	//if the leaderboard time updates and we are in the levelSplit setting then split
	if (old.finishedLevelTime != current.finishedLevelTime && settings["levelSplit"])
	{
		vars.split += 1;
		return true;
	}
	else if (old.finishedLevelTime != current.finishedLevelTime && vars.worldLevel == 10 && !settings["levelSplit"]) //split if we load a new world and are on the corresponding setting
    {
        vars.split += 1;
        vars.lastLevel = current.level;
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
isLoading
{
	//this code is garbage but works. keep in mind its not very accurate
	if(settings["beta"]){ //setup to allow beta testing without people complaining or using untested features
		//this resets the is loading toggle flag
		vars.newLevelStart = (vars.lastLevel != current.level && old.levelTime == 0 && current.levelTime > 0);
		if(vars.newLevelStart || vars.inMenu)
		{
			vars.finishedLevel = false;
			return false;
		}

		//this determines when to start returning true. this is only active for 1 tick
		if(old.finishedLevelTime != current.finishedLevelTime)
		{
			vars.loading = true;
			return true;
			vars.finishedLevel = true;
		}

		//this keeps isLoading active after the initial check above
		if(vars.finishedLevel)
		{
			return true;
		}
	}
}
