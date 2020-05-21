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

init
{
	vars.split = 1;
	vars.loading = false;
	vars.finishedLevel = false;
	vars.deaths = 0;
	vars.afterDeath = false;
	vars.deathCounted = false;
	vars.newLevelStart = false;
	
	public static async Task deathAsync() {
		vars.afterDeath = true;
		await Task.Delay(200);
		vars.afterDeath = false;
	}
}

update
{
	vars.isDead = current.inDeathScreen != 0;
	vars.inMenu = current.inMenuValue != 108;
	if(vars.isDead && !vars.deathCounted && !vars.inMenu){
		deathAsync();
		vars.deathCounted = true;
		vars.deaths++;
	}
	else if(!vars.isDead){
		vars.deathCounted = false;
	}
	vars.worldLevel = Convert.ToInt32(current.level.ToString().Substring(current.level.ToString().Length-1, 1));
	if (vars.worldLevel == 0)
	{
		vars.worldLevel = 10;
	}
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
	settings.Add("beta", false, "Beta Features");
	settings.SetToolTip("beta", "This is only used for beta testers to test features that aren't fully working or fully tested");   
	settings.Add("ignoreDeath", false, "Ignore start after death");
	vars.split = 1;
}

start
{
	if (settings.ignoreDeath && vars.afterDeath) { 
		return false;
	}
	vars.deaths = 0;
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
	else if (vars.newLevelStart && settings["levelSplit"])
	{
		vars.split += 1;
		vars.lastLevel = current.level;
		print("2 split");
		return true;
	}
	else if (vars.newLevelStart && vars.worldLevel == 1 && !settings["levelSplit"]) // Split by world
    {
        vars.split += 1;
        vars.lastLevel = current.level;
        print("World split");
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
	//this code is garbage but works. keep in mind its not very accurate
	if(settings["beta"]){ //setup to allow beta testing without people complaining or using untested features
		//this resets the is loading toggle flag
		//if(old.level != current.level && current.levelTime > 0){
		if(vars.newLevelStart || vars.inMenu){
			vars.finishedLevel = false;
			return false;
		}

		//this determines when to start returning true. this is only active for 1 tick
		if(old.finishedLevelTime != current.finishedLevelTime){
			vars.loading = true;
			return true;
			vars.finishedLevel = true;
		}

		//this keeps isLoading active after the initial check above
		if(vars.finishedLevel){
			return true;
		}
	}
}
