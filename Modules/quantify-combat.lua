quantify_combat = {}

local q = quantify

quantify_combat.Session = {}

quantify_combat.MODULE_KEY = "combat"

function quantify_combat.Session:new(o)
  o = o or {num_deaths = 0, num_corpse_runs = 0, num_brez_accepted = 0, num_spirit_healer_rez = 0, num_rez_accepted = 0, time_crowd_controlled = 0, player_kills = 0, player_actual_kills = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local rez_request = false
local spirit_healer = false

local combat_cc = false
local cc_start_time = 0

local CC_WINDOW = 30

local dead_time = 0

local function init()
  quantify.current_segment.stats.combat = {} 
  quantify.current_segment.stats.combat.raw = quantify_combat.Session:new()
  quantify.current_segment.stats.combat.derived_stats = {}
  quantify.current_segment.stats.combat.session_rates = {}
  session = quantify.current_segment.stats.combat.raw
end

local function playerDead()
  if (GetTime() - dead_time > quantify.EVENT_WINDOW) then --getting occasional double death events
    session.num_deaths = session.num_deaths + 1
    dead_time = GetTime()
  end
end

local function playerAlive()
  if (rez_request and quantify_state:isPlayerInCombat()) then
    session.num_brez_accepted = session.num_brez_accepted + 1
  elseif (rez_request and not quantify_state:isPlayerInCombat()) then
    session.num_rez_accepted = session.num_rez_accepted + 1
  end
  
  rez_request = false
end

local function playerUnghost()
  if (not spirit_healer) then
    session.num_corpse_runs = session.num_corpse_runs + 1
  end
  
  rez_request = false
  spirit_healer = false
end

local function playerSpiritHealer()
  session.num_spirit_healer_rez = session.num_spirit_healer_rez + 1
  
  spirit_healer = true
  rez_request = false
end

local function resurrectRequest()
  rez_request = true
end

local function playerControl(event)

  
  if (quantify_state:isPlayerInCombat()) then
    if (event == "PLAYER_CONTROL_LOST") then
      combat_cc = true
      cc_start_time = GetTime()
    elseif (event == "PLAYER_CONTROL_GAINED") then
      local duration = GetTime() - cc_start_time
      if (combat_cc and duration < CC_WINDOW) then
        session.time_crowd_controlled = session.time_crowd_controlled + duration
      end
      
      combat_cc = false
    end
  else
    combat_cc = false
  end
  
end

local function combatLog()
  local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
  
  if (event == "PARTY_KILL") then
    if (sourceGUID == UnitGUID("player")) then
      session.player_actual_kills = session.player_actual_kills + 1
    end
    
    local source_affiliation = bit.band(sourceFlags, 0xf) --only keep affiliation bits
    if (source_affiliation == 1 or source_affiliation == 2 or source_affiliation == 4) then --self,party,raid
      session.player_kills = session.player_kills + 1
    end
  end
end

function quantify_combat:calculateDerivedStats(segment)
  local derived = {}
  
  local raw = segment.stats.combat.raw
  
  local deaths = raw.num_deaths == 0 and 1 or raw.num_deaths
  derived.kd_ratio = raw.player_kills / deaths
  
  segment.stats.combat.derived_stats = derived
end

function quantify_combat:updateStats(segment)
  quantify_combat:calculateDerivedStats(segment)
end
 
function quantify_combat:newSegment(previous_seg,new_seg)
  
  init()
  
end

init()

table.insert(quantify.modules, quantify_combat)
  
quantify:registerEvent("PLAYER_DEAD", playerDead)
quantify:registerEvent("PLAYER_ALIVE", playerAlive)
quantify:registerEvent("PLAYER_UNGHOST", playerUnghost)
quantify:registerEvent("CONFIRM_XP_LOSS", playerSpiritHealer)
quantify:registerEvent("RESURRECT_REQUEST", resurrectRequest)
quantify:registerEvent("PLAYER_CONTROL_GAINED", playerControl)
quantify:registerEvent("PLAYER_CONTROL_LOST", playerControl)
quantify:registerEvent("COMBAT_LOG_EVENT_UNFILTERED", combatLog)