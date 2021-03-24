![GitHub commit activity](https://img.shields.io/github/commit-activity/m/happyrobot33/Autosplitters?style=for-the-badge)
![GitHub contributors](https://img.shields.io/github/contributors/Happyrobot33/Autosplitters?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/Happyrobot33/Autosplitters?style=for-the-badge)
![GitHub issues](https://img.shields.io/github/issues-raw/Happyrobot33/Autosplitters?style=for-the-badge)
![GitHub closed issues](https://img.shields.io/github/issues-closed-raw/Happyrobot33/Autosplitters?style=for-the-badge)
---
# ClusterTruck
This is an autosplitter for Clustertruck and its Category extensions, fully integrated into Livesplit’s XML database.

## Warning
Programs that affect Clustertruck’s memory will break the autosplitter. If the game was patched by the old autosplitter be sure to reverify the integrity of files or reinstall the game to remove the patch. Eye-tracking has been known to cause issues too.

## Usage
To use, just go to Edit Splits, Ensure that the game dropdown is set to Clustertruck, and click Activate. From now on, once you start the first level of a world, splits will begin automatically. For a more detailed tutorial be sure to watch the [video guide](https://www.youtube.com/watch?v=_eWjOqOMwG0).

## Settings
In the settings you can change how you want the autosplitter to behave.

### Reset
<ul>

###### Default: On
Enables or disables all automatic reset functionality. This option has several sub-options for enabling or disabling specific automatic resetting:

#### In first level
<ul>

###### Default: On
Enabling this will reset the timer when you restart or die on the first level of any world. Enabling the *Start in any level* setting will change this to reset the timer when you restart or die on any level.
</ul>

#### On previous level
<ul>

###### Default: On
Enabling this will reset the timer when a previous level is selected in any of the level select screens.
</ul>

#### On death
<ul>

###### Default: Off
Enabling this will reset the timer any time the player dies. This would for example be used for deathless category attempts.
</ul>

#### In menu
<ul>

###### Default: Off
Enabling this will reset the timer when going back to the menu.
</ul></ul>

### Split by level
<ul>

###### Default: On
Enable this option if you want to use per level splits. Disable to use per world splits.
</ul>

### Start in level
<ul>

###### Default: On
Enable this to still start the timer when restarting in a level. Disable to only start the timer when entering a level from the level selection screen.
</ul>

### Start in any level
<ul>

###### Default: Off
Enable this to start the timer in any level. Disable to only start the timer on the first level of any world. This can be used when you want to use livesplit to time individual levels.
</ul>

### Debug mode
<ul>

###### Default: Off
Enable this to turn on debug logging. Use [DebugView](https://docs.microsoft.com/en-us/sysinternals/downloads/debugview) to view this output.
</ul>

## Bug reports & feature requests
If you find any bugs or have ideas for new features please submit them [here](https://github.com/Happyrobot33/Autosplitters/issues/new/choose). This project is opensource, so any feedback or contributions are always welcomed!
