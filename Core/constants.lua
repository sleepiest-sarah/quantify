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
  
  This addon is still very much a work-in-progress. I'll be updating frequently.
  For issues, bugs, suggestions, or anything else please feel free to contact me.
  Discord: Aeroxis#2344
  Twitch: therealaeroxis
]]

quantify.HELP_TEXT =
[[
quantify command line options
  /qty show   -- show the UI
  /qty hide   -- hide the UI

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
  ["derived_stats:bff_received"] = {text = "Top Sender", units = "string"}

  }