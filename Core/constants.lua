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

quantify.STATS = {
  ["raw:kill_xp"] = {text = "Total XP from Kills", units = "integer"},
  ["raw:quest_xp"] = {text = "Total XP from Quests", units = "integer"},
  ["raw:rested_xp"] = { text = "Bonus Rested XP", units ="integer"},
  ["session_rates:pct_levels_gained"] = {text = "Fractional Levels Earned Per Hour", units = "decimal/hour"},
  ["raw:time_combat"] = { text = "Total Time in Combat", units = "time"},
  ["raw:levels_gained"] = { text = "Total Levels Earned", units = "integer"},
  ["raw:xp"] = { text = "Total XP", units = "integer"},
  ["session_rates:quest_xp"] = { text = "Quest XP Per Hour", units = "integer/hour"},
  ["raw:pct_levels_gained"] = {text = "Total Fractional Levels Earned", units="decimal"},
  ["raw:scenario_xp"] = {text = "Total XP from Scenarios", units="integer"},
  ["session_rates:kill_xp"] = {text = "Kill XP Per Hour", units = "integer/hour"},
  ["session_rates:rested_xp"] = {text = "Bonus Rested XP Per Hour", units = "integer/hour"},
  ["derived_stats:time_to_level"] = {text = "Est. Time to Next Level", units = "time"},
  ["session_rates:levels_gained"] = {text = "Total Levels Earned Per Hour", units = "integer/hour"},
  ["session_rates:xp"] = {text = "Total XP Per Hour", units = "integer/hour"},
  ["session_rates:other_xp"] = {text = "Misc. XP Per Hour", units = "integer/hour"},
  ["raw:other_xp"] = {text = "Total Misc. XP", units = "integer"},
  ["session_rates:scenario_xp"] = {text = "Scenario XP Per Hour", units = "integer/hour"},
  ["derived_stats:pct_play_time_afk"] = {text="% Play Time: AFK", units = "percentage"},
  ["derived_stats:pct_play_time_combat"] = {text = "% Play Time: Combat", units = "percentage"},
  ["raw:time_afk"] = {text = "Total Time AFK", units = "time"},
  ["raw:play_time"] = {text = "Total Play Time", units = "time"},
  ["raw:zone_time_*"] = {text = "*", units ="time"},
  ["derived_stats:zone_pct_*"] = {text = "Zone %: *", units = "percentage"},
  ["derived_stats:word_cloud_*"] = {text = "Word Count: *", units = "integer"},
  ["raw:whispers_sent"] = {text = "Whispers Sent", units = "integer"},
  ["raw:say_sent"] = {text = "Say Sent", units = "integer"},
  ["raw:yell_sent"] = {text = "Yell Sent", units = "integer"},
  ["raw:party_sent"] = {text = "Party Sent", units = "integer"},
  ["raw:raid_sent"] = {text = "Raid Sent", units = "integer"},
  ["raw:guild_sent"] = {text = "Guild Sent", units = "integer"},
  ["raw:combat_messages"] = {text = "Combat Messages Sent", units = "integer"},
  ["raw:mentions"] = {text = "Times Mentioned", units = "integer"},
  ["raw:emotes_sent"] = {text = "Emotes Used", units = "integer"},
  ["raw:whispers_received"] = {text = "Whispers Received", units = "integer"},
  ["raw:channel_sent_*"] = {text = "Channel Sent: *", units = "integer"},
  ["derived_stats:bff_sent"] = {text = "Top Recipient", units = "string"},
  ["derived_stats:bff_received"] = {text = "Top Sender", units = "string"},
  ["raw:num_rez_accepted"] = {text = "Rezes Accepted", units = "integer"},
  ["raw:num_spirit_healer_rez"] = {text = "Rezs by Spirit Healer", units = "integer"},
  ["raw:num_deaths"] = {text = "Deaths", units = "integer"},
  ["raw:num_kills"] = {text = "Kills", units = "integer"},
  ["raw:num_brez_accepted"] = {text = "Battle Rezes Accepted", units = "integer"},
  ["raw:num_corpse_runs"] = {text = "Corpse Runs", units = "integer"},
  ["raw:overall_raid_boss_kills"] = {text = "Raid Boss Kills", units = "integer"},
  ["raw:legion_dungeon_boss_kills"] = {text = "Legion Dungeon Boss Kills", units = "integer"},
  ["raw:player_raid_deaths"] = {text = "Players Deaths in Raids", units = "integer"},
  ["raw:player_dungeon_deaths"] = {text = "Player Deaths in Dungeons", units = "integer"},
  ["raw:legion_raid_boss_kills"] = {text = "Legion Raid Boss Kills", units = "integer"},
  ["raw:legion_dungeon_boss_wipes"] = {text = "Legion Dungeon Boss Wipes", units = "integer"},
  ["raw:overall_dungeon_boss_wipes"] = {text = "Dungeon Boss Wipes", units = "integer"},
  ["raw:overall_dungeon_boss_kills"] = {text = "Dungeon Boss Kills", units = "integer"},
  ["raw:dungeon_boss_kill_*"] = {text = "Boss Kills: *", units = "integer"},
  ["raw:overall_raid_boss_wipes"] = {text = "Raid Boss Wipes", units = "integer"},
  ["raw:legion_raid_boss_wipes"] = {text = "Legion Raid Boss Wipes", units = "integer"},
  ["raw:dungeon_boss_wipe_*"] = {text = "Dungeon Boss Wipes: *", units = "integer"},
  ["raw:raid_boss_wipe_*"] = {text = "Raid Boss Wipes: *", units = "integer"},
  ["raw:raid_boss_kill_*"] = {text = "Raid Boss Kills: *", units = "integer"},
  ["raw:time_crowd_controlled"] = {text = "Time Spent CC'd", units = "time"},
  ["raw:player_actual_kills"] = {text = "Killing Blows", units = "integer"},
  ["raw:player_kills"] = {text = "Total Kills", units = "integer"},
  ["raw:currency_gained_*"] = {text = "* Gained", units="integer"},
  ["raw:currency_lost_*"] = {text = "* Spent", units="integer"},
  ["raw:delta_money"] = {text = "Net Money Earned", units="money"},
  ["raw:total_money_gained"] = {text = "Money Earned", units="money"},
  ["raw:total_money_spent"] = {text = "Money Spent", units="money"},
  ["raw:money_looted"] = {text = "Money Looted", units="money"},
  ["raw:guild_tax"] = {text = "Guild Tax", units="money"},
  ["session_rates:currency_gained_*"] = {text = "* Gained Per Hour", units="integer/hour"},
  ["session_rates:currency_lost_*"] = {text = "* Spent Per Hour", units="integer/hour"},
  ["session_rates:delta_money"] = {text = "Net Money Earned Per Hour", units="money/hour"},
  ["session_rates:total_money_gained"] = {text = "Money Earned Per Hour", units="money/hour"},
  ["session_rates:total_money_spent"] = {text = "Money Spent Per Hour", units="money/hour"},
  ["session_rates:money_looted"] = {text = "Money Looted Per Hour", units="money/hour"},
  ["session_rates:guild_tax"] = {text = "Guild Tax Per Hour", units="money/hour"},
  ["raw:inv_type_*"] = {text = "* Items Looted", units = "integer"},
  ["raw:junk_looted_value"] = {text = "Value of Junk Looted", units = "money"},
  ["raw:bfa_dungeon_boss_kills"] = {text = "BFA Dungeon Boss Kills", units = "integer"},
  ["raw:bfa_dungeon_boss_wipes"] = {text = "BFA Dungeon Boss Wipes", units = "integer"},
  ["raw:bfa_raid_boss_kills"] = {text = "BFA Raid Boss Kills", units = "integer"},
  ["raw:bfa_raid_boss_wipes"] = {text = "BFA Raid Boss Wipes", units = "integer"},
  ["raw:total_items_looted"] = {text = "BFA Dungeon Boss Kills", units = "integer"},
  ["raw:gear_loot"] = {text = "Gear Looted", units = "integer"},
  ["raw:cloth_looted"] = {text = "Cloth Gathered", units = "integer"},
  ["raw:tradeskill_looted"] = {text = "Tradeskill Items Looted", units = "integer"},
  ["raw:enchanting_looted"] = {text = "Enchanting Items Gathered", units = "integer"},
  ["raw:herb_looted"] = {text = "Herbs Gathered", units = "integer"},
  ["raw:jewelcrafting_looted"] = {text = "Jewelcrafting Items Gathered", units = "integer"},
  ["raw:meat_looted"] = {text = "Meat Gathered", units = "integer"},
  ["raw:leather_looted"] = {text = "Leather Gathered", units = "integer"},
  ["raw:metal_looted"] = {text = "Ore Gathered", units = "integer"},
  ["raw:junk_looted"] = {text = "Junk Items Looted", units = "integer"},
  ["raw:poor_loot"] = {text = "Greys Looted", units = "integer"},
  ["raw:common_loot"] = {text = "Common Items Looted", units = "integer"},
  ["raw:uncommon_loot"] = {text = "Greens Looted", units = "integer"},
  ["raw:rare_loot"] = {text = "Blues Looted", units = "integer"},
  ["raw:epic_loot"] = {text = "Purples Looted", units = "integer"},
  ["raw:bfa_poor_loot"] = {text = "BFA Greys Looted", units = "integer"},
  ["raw:bfa_common_loot"] = {text = "BFA Common Items Looted", units = "integer"},
  ["raw:bfa_uncommon_loot"] = {text = "BFA Greens Looted", units = "integer"},
  ["raw:bfa_rare_loot"] = {text = "BFA Blues Looted", units = "integer"},
  ["raw:bfa_epic_loot"] = {text = "BFA Purples Looted", units = "integer"},
  ["raw:cloth_gear_loot"] = {text = "Cloth Pieces Looted", units = "integer"},
  ["raw:leather_gear_loot"] = {text = "Mail Pieces Looted", units = "integer"},
  ["raw:mail_gear_loot"] = {text = "Mail Pieces Looted", units = "integer"},
  ["raw:plate_gear_loot"] = {text = "Plate Gear Looted", units = "integer"},
  ["raw:bfa_dungeon_boss_kills"] = {text = "BFA Dungeon Boss Kills", units = "integer"},
  ["raw:bfa_dungeon_boss_kills"] = {text = "BFA Dungeon Boss Kills", units = "integer"},
  ["raw:bfa_dungeon_boss_kills"] = {text = "BFA Dungeon Boss Kills", units = "integer"},
  ["raw:bfa_dungeon_boss_kills"] = {text = "BFA Dungeon Boss Kills", units = "integer"},
  ["raw:bfa_dungeon_boss_kills"] = {text = "BFA Dungeon Boss Kills", units = "integer"},
  ["raw:bfa_dungeon_boss_kills"] = {text = "BFA Dungeon Boss Kills", units = "integer"},
  ["raw:bfa_dungeon_boss_kills"] = {text = "BFA Dungeon Boss Kills", units = "integer"},
  
}

quantify.LEGION_DUNGEON_IDS = {1501, 1677, 1571, 1466, 1456, 1477, 1492, 1458, 1651, 1753, 1516, 1493, 1544}
quantify.LEGION_RAID_IDS = {1520,1648,1530,1676,1712}
quantify.BFA_DUNGEON_IDS = {1763,1754,1762,1864,1822,1877,1594,1841,1771,1862}
quantify.BFA_RAID_IDS = {1861}
quantify.BFA_END_BOSSES = {}