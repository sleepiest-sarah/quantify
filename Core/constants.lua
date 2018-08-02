--top level namespace
quantify = {}

quantify.ADDON_NAME = "quantify"

quantify.EVENT_WINDOW = 1

SLASH_quantify1 = "/quantify"
SLASH_quantify2 = "/qty"

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
  ["derived_stats:zone_pct_*"] = {text = "Zone %: *", units = "percentage"}
  }