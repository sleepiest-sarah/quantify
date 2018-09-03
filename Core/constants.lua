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
  
This addon is still very much a work-in-progress. I'll be updating frequently. For issues, bugs, suggestions, or anything else please feel free to contact me.
  Discord: Aeroxis#2344 Twitch: therealaeroxis
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
]]


quantify.LEGION_DUNGEON_IDS = {1501, 1677, 1571, 1466, 1456, 1477, 1492, 1458, 1651, 1753, 1516, 1493, 1544}
quantify.LEGION_RAID_IDS = {1520,1648,1530,1676,1712}
quantify.BFA_DUNGEON_IDS = {1877,1862,1763,1754,1762,1864,1822,1594,1841,1771}
--quantify.BFA_DUNGEON_IDS = {1001,968,1041,1036,1023,1030,1012,1022,1002,1021}
quantify.BFA_RAID_IDS = {1861}
--quantify.BFA_RAID_IDS = {1031}
quantify.BFA_END_BOSSES = {"Yazma", "Lord Harlan Sweete", "Dazar, The First King", "Vol'zith the Whisperer", "Viq'Goth", "Avatar of Sethraliss", "Mogul Razdunk", "Unbound Abomination", "Overseer Korgus", "Gorak Tul"}
quantify.BFA_END_BOSS_IDS = {2108,2117,2087,2127,2123,2096}