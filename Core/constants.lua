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

For issues, bugs, suggestions, or anything else please feel free to contact me.
  Discord: Aeroxis#2344 Twitch: quitesleepysarah
]]

quantify.HELP_TEXT =
[[
quantify command line options
  /qty show             -- show the UI
  /qty hide             -- hide the UI
  /qty debug            -- display debug options
]]

quantify.DEBUG_OPTIONS =
[[
debug options
  /qty segment new      -- create a new segment
  /qty segment <int>    -- print segment <int>
  /qty state            -- print state variables
]]

quantify.RESET_STAT_WARNING = 
[[
This is an advanced feature intended to allow repairing single stats without clearing an entire segment. Some statistic types such as overall play time, percentages, and superlatives can not be reset in this manner. Using this tool could cause percentages and other related statistics to appear incorrect. To reset all statistics, delete your quantify SavedVariable files or type "/qty debug" in the chat window to see options for resetting segments. 

As always please feel free to contact me or submit an issue if you are resetting stats due to a bug or other issue.
]]

quantify.DUNGEON_WIDGET_HIGHLIGHT_TEXT = "Double click to view details."

quantify.EJ_CLASSIC = 1
quantify.EJ_BC = 2
quantify.EJ_WOTLK = 3
quantify.EJ_CATACLYSM = 4
quantify.EJ_MOP = 5
quantify.EJ_WOD = 6
quantify.EJ_LEGION = 7
quantify.EJ_BFA = 8
quantify.EJ_SL = 9

quantify.EXPAC_LOOT_IDS_TEXT = {
  [0] = "Classic",
  [1] = "Burning Crusade",
  [2] = "Wrath of the Lich King",
  [3] = "Cataclysm",
  [4] = "Mists of Pandaria",
  [5] = "Warlords of Draenor",
  [6] = "Legion",
  [7] = "Battle for Azeroth",
  [8] = "Shadowlands",
  }