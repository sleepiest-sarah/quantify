local log = quantify.log
local session


local player_kill = 0
local player_quest = 0

local previous_xp = nil

local previous_max_xp = nil

quantify_exp = {}
quantify_exp.Session = {}

quantify_exp.MODULE_KEY = "xp"

function quantify_exp.Session:new(o)
  o = o or {xp = 0, quest_xp = 0, kill_xp = 0, scenario_xp = 0, other_xp = 0, rested_xp = 0, pct_levels_gained = 0, levels_gained = 0}
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
    if (curtime - player_kill > quantify.EVENT_WINDOW) and (curtime - player_quest > quantify.EVENT_WINDOW) then
      session.other_xp = session.other_xp + xp_gain
    end
    
    previous_xp = current_xp
  end
end


local function playerQuestTurnedIn(event, ...)
  local questid, xp, money = unpack({...})
  
  session.quest_xp = session.quest_xp + xp
  
  player_quest = GetTime()
end

local function playerMsgCombatXpGain(event, ...)
  local msg = unpack({...})
  
  local xp_gain = string.match(msg, "dies, you gain (%d+) experience.")
  if (xp_gain ~= nil) then
    session.kill_xp = session.kill_xp + xp_gain
    player_kill = GetTime()
  end
  
  local rested_xp = string.match(msg, "%+(%d+) Rested bonus")
  if (rested_xp ~= nil) then
    session.rested_xp = session.rested_xp + rested_xp
  end
end

local function playerScenarioCompleted(event, ...)
  local questid, xp, money = unpack({...})
  
  session.scenario_xp = session.scenario_xp + xp
  
  player_quest = GetTime()
end

local function playerLevelUp(event, ...)
  session.levels_gained = session.levels_gained + 1
end

local function playerLogin(event, ...)
  previous_xp = UnitXP("player")
  previous_max_xp = UnitXPMax("player")
end

function quantify_exp:calculateDerivedStats(segment)
  segment.stats.xp.session_rates = quantify:calculateSegmentRates(segment, segment.stats.xp.raw)
  
  local session_xp_rate = segment.stats.xp.session_rates.xp
  segment.stats.xp.derived_stats = {}
  segment.stats.xp.derived_stats.time_to_level = ((UnitXPMax("player") - UnitXP("player")) / session_xp_rate) * 3600
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