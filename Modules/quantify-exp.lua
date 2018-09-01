local log = quantify.log
local session


local player_kill = 0
local player_quest = 0
local pet_battle = 0

local previous_xp = nil
local previous_level = nil
local previous_max_xp = nil

local previous_max_azerite_xp

quantify_exp = {}
quantify_exp.Session = {}

quantify_exp.MODULE_KEY = "xp"

function quantify_exp.Session:new(o)
  o = o or {xp = 0, quest_xp = 0, kill_xp = 0, scenario_xp = 0, other_xp = 0, rested_xp = 0, pct_levels_gained = 0, levels_gained = 0, group_xp = 0, azerite_xp = 0, pet_battle_xp = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end


local function init()
  quantify.current_segment.stats.xp = {} 
  quantify.current_segment.stats.xp.raw = quantify_exp.Session:new()
  quantify.current_segment.stats.xp.derived_stats = {time_to_level = 0}
  quantify.current_segment.stats.xp.session_rates = {}
  session = quantify.current_segment.stats.xp.raw
end

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
    session.xp = session.xp + xp_gain
    
    
    local xp_pct = xp_gain / max_xp
    session.pct_levels_gained = session.pct_levels_gained + xp_pct
    
    local curtime = GetTime()
    if (curtime - player_kill > quantify.EVENT_WINDOW) and (curtime - player_quest > quantify.EVENT_WINDOW and (curtime - pet_battle > quantify.EVENT_WINDOW)) then
      session.other_xp = session.other_xp + xp_gain
    elseif (curtime - pet_battle < quantify.EVENT_WINDOW) then
      session.pet_battle_xp = session.pet_battle_xp + xp_gain
    end
    
    previous_xp = current_xp
  end
end


local function playerQuestTurnedIn(event, ...)
  local questid, xp, money = unpack({...})
  
  if (xp ~= nil) then
    session.quest_xp = session.quest_xp + xp
  end
  
  player_quest = GetTime()
end

local function playerMsgCombatXpGain(event, ...)
  local msg = unpack({...})
  
  local xp_gain = string.match(msg, "dies, you gain (%d+) experience.")
  if (xp_gain ~= nil) then
    session.kill_xp = session.kill_xp + xp_gain
    player_kill = GetTime()
  end
  
  local rested_xp = string.match(msg, "%+(%d+) exp Rested bonus")
  if (rested_xp ~= nil) then
    session.rested_xp = session.rested_xp + tonumber(rested_xp)
  end
  
  local group_xp = string.match(msg, "%+(%d+) group bonus")
  if (group_xp ~= nil) then
    session.group_xp = session.group_xp + tonumber(group_xp)
  end
end

local function playerScenarioCompleted(event, ...)
  local questid, xp, money = unpack({...})
  
  if (xp ~= nil) then
    session.scenario_xp = session.scenario_xp + xp
  end
  
  player_quest = GetTime()
end

local function petBattleClose()
  pet_battle = GetTime()
end

local function playerLevelUp(event, newLevel)
  if (newLevel ~= previous_level) then
    session.levels_gained = session.levels_gained + 1
    previous_level = newLevel
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

  session.azerite_xp = session.azerite_xp + delta
end

function quantify_exp:calculateDerivedStats(segment)
  segment.stats.xp.session_rates = quantify:calculateSegmentRates(segment, segment.stats.xp.raw)
  
  local session_xp_rate = segment.stats.xp.session_rates.xp
  segment.stats.xp.derived_stats = {}
  segment.stats.xp.derived_stats.time_to_level = ((UnitXPMax("player") - UnitXP("player")) / session_xp_rate) * 3600
  
  local rate_max_level = quantify:calculateSegmentRates(segment, segment.stats.xp.raw, 3600, segment.stats.time.raw.time_sub_max_level).xp or 0
  local rate_rested = quantify:calculateSegmentRates(segment, segment.stats.xp.raw, 3600, segment.stats.time.raw.time_rested).rested_xp or 0
  
  segment.stats.xp.session_rates.xp = rate_max_level
  segment.stats.xp.session_rates.rested_xp = rate_rested

  local xp_rate_no_rested = rate_max_level - rate_rested --xp/hr
  local time_per_total_xp = segment.stats.xp.raw.xp * 3600/(rate_max_level )                                   --seconds
  local time_per_total_xp_no_rested = segment.stats.xp.raw.xp * 3600/(xp_rate_no_rested )               --seconds

  segment.stats.xp.derived_stats.rested_xp_time_saved = time_per_total_xp_no_rested - time_per_total_xp
  
  if (quantify_state:hasAzeriteItem() and quantify_state:getActiveAzeriteLocationTable()) then
    local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(quantify_state:getActiveAzeriteLocationTable())
    segment.stats.xp.derived_stats.azerite_time_to_level = ((totalLevelXP - xp) / segment.stats.xp.session_rates.azerite_xp) * 3600
  end
  
  local raw = segment.stats.xp.raw
  segment.stats.xp.derived_stats.pct_xp_kill = (raw.kill_xp / raw.xp) * 100
  segment.stats.xp.derived_stats.pct_xp_pet_battle = (raw.pet_battle_xp / raw.xp) * 100
  segment.stats.xp.derived_stats.pct_xp_quest = (raw.quest_xp / raw.xp) * 100
  segment.stats.xp.derived_stats.pct_xp_other = (raw.other_xp / raw.xp) * 100
end

function quantify_exp:updateStats(segment)
  quantify_exp:calculateDerivedStats(segment)
end

function quantify_exp:newSegment(previous_seg, new_seg)  
  init()
  
  playerLogin()
  
end

init()

table.insert(quantify.modules, quantify_exp)

quantify:registerEvent("PLAYER_XP_UPDATE", playerExpUpdate)
quantify:registerEvent("CHAT_MSG_COMBAT_XP_GAIN", playerMsgCombatXpGain)
quantify:registerEvent("QUEST_TURNED_IN", playerQuestTurnedIn)
quantify:registerEvent("SCENARIO_COMPLETED", playerScenarioCompleted)
quantify:registerEvent("PLAYER_LEVEL_UP", playerLevelUp)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)
quantify:registerEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", azeriteChanged)
quantify:registerEvent("PLAYER_ENTERING_WORLD", playerEnteringWorld)
quantify:registerEvent("PET_BATTLE_CLOSE", petBattleClose)