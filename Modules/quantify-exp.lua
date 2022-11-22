local q = quantify

quantify_exp = {}
quantify_exp.MODULE_KEY = "xp"

local player_kill = 0
local player_quest = 0
local pet_battle = 0
local gathering = 0

local previous_xp = nil
local previous_level = nil
local previous_max_xp = nil

local previous_max_azerite_xp

--other exp
local function playerExpUpdate(event, ...)
  local unitid = ...
  if unitid == "player" then
    local current_xp = UnitXP("player")
    local max_xp = UnitXPMax("player")

    local xp_gain = current_xp - previous_xp
    if (xp_gain < 0) then
      xp_gain = (previous_max_xp - previous_xp) + current_xp
      previous_max_xp = max_xp
    end
    q:incrementStat("XP", xp_gain)
    
    
    local xp_pct = xp_gain / max_xp
    q:incrementStat("PCT_LEVELS_GAINED", xp_pct)
    
    local curtime = GetTime()
    if (curtime - pet_battle < quantify.EVENT_WINDOW) then
      q:incrementStat("PET_BATTLE_XP", xp_gain)
    elseif (curtime - gathering < quantify.EVENT_WINDOW) then
      q:incrementStat("GATHERING_XP", xp_gain)
    elseif ((curtime - player_kill > quantify.EVENT_WINDOW) and (curtime - player_quest > quantify.EVENT_WINDOW)) then
      q:incrementStat("OTHER_XP", xp_gain)
    end
    
    previous_xp = current_xp
  end
end


local function playerQuestTurnedIn(event, ...)
  local questid, xp, money = unpack({...})

  if (xp) then
    q:incrementStat("QUEST_XP", xp)
  end
  
  player_quest = GetTime()
end

local function playerMsgCombatXpGain(event, ...)
  local msg = unpack({...})
  
  local xp_gain = string.match(msg, "dies, you gain (%d+) experience.")
  if (xp_gain ~= nil) then
    q:incrementStat("KILL_XP", xp_gain)
    player_kill = GetTime()
  end
  
  local rested_xp = string.match(msg, "%+(%d+) exp Rested bonus")
  if (rested_xp ~= nil) then
    q:incrementStat("RESTED_XP", tonumber(rested_xp))
  end
  
  local group_xp = string.match(msg, "%+(%d+) group bonus")
  if (group_xp ~= nil) then
    q:incrementStat("GROUP_XP", tonumber(group_xp))
  end
end

local function playerScenarioCompleted(event, ...)
  local questid, xp, money = unpack({...})
  
  if (xp ~= nil) then
    q:incrementStat("SCENARIO_XP", xp)
  end
  
  player_quest = GetTime()
end

local function petBattleClose()
  pet_battle = GetTime()
end

local function playerLevelUp(event, newLevel)
  if (newLevel ~= previous_level) then
    q:incrementStat("LEVELS_GAINED", 1)
    previous_level = newLevel
  end
end

local function chatMsgOpening(event, msg)
  local mining = string.match(msg, "You perform (Mining)") 
  local herbing = string.match(msg, "You perform (Herb Gathering)")
  
  if (mining or herbing) then
    gathering = GetTime()
  end
end

local function playerLogin(event, ...)
  previous_xp = UnitXP("player")
  previous_max_xp = UnitXPMax("player")
  previous_level = UnitLevel("player")
end

function quantify_exp:calculateDerivedStats(segment, fullSeg)
  local play_time = q:getStat(fullSeg, "PLAY_TIME")
  local rates = quantify:calculateSegmentRates(segment.stats, play_time)
  
  local session_xp_rate = rates.xp
  local stats = segment.stats
  
  stats.pet_battle_xp_rate = rates.pet_battle_xp
  stats.gathering_xp_rate = rates.gathering_xp
  stats.pct_levels_gained_rate = rates.pct_levels_gained
  stats.quest_xp_rate = rates.quest_xp
  stats.levels_gained_rate = rates.levels_gained
  stats.other_xp_rate = rates.other_xp
  stats.scenario_xp_rate = rates.scenario_xp
  stats.group_xp_rate = rates.group_xp
  stats.azerite_xp_rate = rates.azerite_xp
  stats.kill_xp_rate = rates.kill_xp

  stats.time_to_level = session_xp_rate == 0 and nil or ((UnitXPMax("player") - UnitXP("player")) / session_xp_rate) * 3600
  
  local time_sub_max_level = q:getStat(fullSeg, "TIME_SUB_MAX_LEVEL")
  local time_rested = q:getStat(fullSeg, "TIME_RESTED")
  local rate_max_level = quantify:calculateSegmentRates(stats, time_sub_max_level).xp or 0
  local rate_rested = quantify:calculateSegmentRates(stats, time_rested).rested_xp or 0
  
  stats.xp_rate_til_max = rate_max_level
  stats.bonus_rested_xp_rate = rate_rested

  local xp_rate_no_rested = rate_max_level - rate_rested --xp/hr
  local time_per_total_xp = stats.xp * 3600/(rate_max_level == 0 and 1 or rate_max_level)                                   --seconds
  local time_per_total_xp_no_rested = stats.xp * 3600/ (xp_rate_no_rested == 0 and 1 or xp_rate_no_rested)               --seconds

  stats.rested_xp_time_saved = time_per_total_xp_no_rested - time_per_total_xp
  
  local total_xp = stats.xp == 0 and 1 or stats.xp
  stats.pct_xp_kill = (stats.kill_xp / total_xp) * 100
  stats.pct_xp_pet_battle = (stats.pet_battle_xp / total_xp) * 100
  stats.pct_xp_quest = (stats.quest_xp / total_xp) * 100
  stats.pct_xp_other = (stats.other_xp / total_xp) * 100
  stats.pct_xp_gathering = (stats.gathering_xp / total_xp) * 100
end

function quantify_exp:updateStats(segment, fullSeg)
  quantify_exp:calculateDerivedStats(segment, fullSeg)
end

function quantify_exp:newSegment(segment)  
  
  segment.stats = q:addKeysLeft(segment.stats,
                 {xp = 0,
                  quest_xp = 0,
                  kill_xp = 0,
                  scenario_xp = 0,
                  other_xp = 0,
                  rested_xp = 0,
                  pct_levels_gained = 0,
                  levels_gained = 0,
                  group_xp = 0,
                  azerite_xp = 0,
                  pet_battle_xp = 0,
                  gathering_xp = 0})
  
  
  playerLogin()
end

table.insert(quantify.modules, quantify_exp)

quantify:registerEvent("PLAYER_XP_UPDATE", playerExpUpdate)
quantify:registerEvent("CHAT_MSG_COMBAT_XP_GAIN", playerMsgCombatXpGain)
quantify:registerEvent("QUEST_TURNED_IN", playerQuestTurnedIn)
quantify:registerEvent("PLAYER_LEVEL_UP", playerLevelUp)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)
quantify:registerEvent("CHAT_MSG_OPENING", chatMsgOpening)

if (q.isRetail) then
  quantify:registerEvent("SCENARIO_COMPLETED", playerScenarioCompleted)
  quantify:registerEvent("PET_BATTLE_CLOSE", petBattleClose)  
end