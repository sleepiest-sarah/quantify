--top level namespace
quantify = {}

quantify.ADDON_NAME = "quantify"

quantify.EVENT_WINDOW = 1

SLASH_quantify1 = "/quantify"
SLASH_quantify2 = "/qty"

quantify.LOADED_TEXT = 
[[
quantify loaded :)
  use /qty or /quantify to see options
  
This is the first release for WoW Classic. Nothing new yet while I focus on ironing out the issues with the port from Retail to Classic. New Classic-focused stats and features are on the way though. Thank you for your support!

Tips
  1) Double-click to add/remove stats to/from the watchlist
  2) Right click the watchlist to save presets
  3) Watchlist stats can be mixed and matched between the current, account, and character view.
  4) Right-clicking a stat opens a menu with additional options.

For issues, bugs, suggestions, or anything else please feel free to contact me.
  Discord: Aeroxis#2344 Twitch: quitesleepysarah
]]

quantify.HELP_TEXT =
[[
quantify command line options
  /qty show   -- show the UI
  /qty hide   -- hide the UI
  /qty debug  -- display debug options
]]

quantify.DEBUG_OPTIONS =
[[
debug options
  /qty segment new      -- create a new segment
  /qty segment <int>    -- print segment <int>
  /qty state            -- print state variables
  /qty log <1 or 0>     -- enable advanced event logging
  /qty clear all        -- clear all addon saved data
  /qty clear <segment>  -- clear all saved data for <segment>
  /qty classic          -- force Classic behavior to run in Retail version
]]

quantify.RESET_STAT_WARNING = 
[[
This is an advanced feature intended to allow repairing single stats without clearing an entire segment. Some statistic types such as overall play time, percentages, and superlatives can not be reset in this manner. Using this tool could cause percentages and other related statistics to appear incorrect. To reset all statistics, delete your quantify SavedVariable files or type "/qty debug" in the chat window to see options for resetting segments. 

As always please feel free to contact me or submit an issue if you are resetting stats due to a bug or other issue.
]]
