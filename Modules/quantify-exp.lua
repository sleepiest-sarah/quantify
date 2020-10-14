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
  
  if (xp ~= nil) then
    session.quest_xp = session.quest_xp + xp
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

local function playerEnteringWorld()
  if (quantify_state:getActiveAzeriteLocationTable() ~= nil) then
    _,previous_max_azerite_xp = C_AzeriteItem.GetAzeriteItemXPInfo(quantify_state:getActiveAzeriteLocationTable())
  end
end

local function azeriteChanged(event, azeriteItemLocation, oldExp, newExp)
  local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(quantify_state:getActiveAzeriteLocationTable())
  
  local delta = newExp - oldExp
  if (delta < 0) then
    delta = (previous_max_azerite_xp - oldExp) + xp
    previous_max_azerite_xp = totalLevelXP
  end

  q:incrementStat("AZERITE_XP", delta)
end

function quantify_exp:calculateDerivedStats(segment)
  --segment.stats.xp.session_rates = quantify:calculateSegmentRates(segment, segment.stats.xp.raw)
  
  --local session_xp_rate = segment.stats.xp.session_rates.xp
  
  local stats = segment.stats

  --stats.time_to_level = ((UnitXPMax("player") - UnitXP("player")) / session_xp_rate) * 3600
  
  --local rate_max_level = quantify:calculateSegmentRates(segment, segment.stats.xp.raw, 3600, segment.stats.time.raw.time_sub_max_level).xp or 0
  --local rate_rested = quantify:calculateSegmentRates(segment, segment.stats.xp.raw, 3600, segment.stats.time.raw.time_rested).rested_xp or 0
  
  --segment.stats.xp.session_rates.xp = rate_max_level
  --segment.stats.xp.session_rates.rested_xp = rate_rested

  --local xp_rate_no_rested = rate_max_level - rate_rested --xp/hr
  --local time_per_total_xp = segment.stats.xp.raw.xp * 3600/(rate_max_level )                                   --seconds
  --local time_per_total_xp_no_rested = segment.stats.xp.raw.xp * 3600/(xp_rate_no_rested )               --seconds

  --segment.stats.xp.derived_stats.rested_xp_time_saved = time_per_total_xp_no_rested - time_per_total_xp
  
  if (q.isRetail and quantify_state:hasAzeriteItem() and quantify_state:getActiveAzeriteLocationTable()) then
    local success,xp, totalLevelXP = pcall(C_AzeriteItem.GetAzeriteItemXPInfo,quantify_state:getActiveAzeriteLocationTable())
    if (success) then
      --segment.stats.xp.derived_stats.azerite_time_to_level = ((totalLevelXP - xp) / segment.stats.xp.session_rates.azerite_xp) * 3600
    end
  end
  
  stats.pct_xp_kill = (stats.kill_xp / stats.xp) * 100
  stats.pct_xp_pet_battle = (stats.pet_battle_xp / stats.xp) * 100
  stats.pct_xp_quest = (stats.quest_xp / stats.xp) * 100
  stats.pct_xp_other = (stats.other_xp / stats.xp) * 100
  stats.pct_xp_gathering = (stats.gathering_xp / stats.xp) * 100
end

function quantify_exp:updateStats(segment)
  quantify_exp:calculateDerivedStats(segment)
end

function quantify_exp:newSegment(segment)  
  
  segment.stats = segment.stats or 
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
                  gathering_xp = 0}  
  
  
  playerLogin()
end

table.insert(quantify.modules, quantify_exp)

quantify:registerEvent("PLAYER_XP_UPDATE", playerExpUpdate)
quantify:registerEvent("CHAT_MSG_COMBAT_XP_GAIN", playerMsgCombatXpGain)
quantify:registerEvent("QUEST_TURNED_IN", playerQuestTurnedIn)
quantify:registerEvent("PLAYER_LEVEL_UP", playerLevelUp)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)
quantify:registerEvent("PLAYER_ENTERING_WORLD", playerEnteringWorld)
quantify:registerEvent("CHAT_MSG_OPENING", chatMsgOpening)

if (q.isRetail) then
  quantify:registerEvent("SCENARIO_COMPLETED", playerScenarioCompleted)
  quantify:registerEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", azeriteChanged)
  quantify:registerEvent("PET_BATTLE_CLOSE", petBattleClose)  
end