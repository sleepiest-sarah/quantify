quantify_combat = {}

local q = quantify


quantify_combat.MODULE_KEY = "combat"

local rez_request = false
local spirit_healer = false

local combat_cc = false
local cc_start_time = 0

local CC_WINDOW = 30

local dead_time = 0

local function playerDead()
  if (GetTime() - dead_time > quantify.EVENT_WINDOW) then --getting occasional double death events
    q:incrementStat("NUM_DEATHS", 1)
    dead_time = GetTime()
  end
end

local function playerAlive()
  if (rez_request and quantify_state:isPlayerInCombat()) then
    q:incrementStat("NUM_BREZ_ACCEPTED",1)
  elseif (rez_request and not quantify_state:isPlayerInCombat()) then
    q:incrementStat("NUM_REZ_ACCEPTED",1)
  end
  
  rez_request = false
end

local function playerUnghost()
  if (not spirit_healer) then
    q:incrementStat("NUM_CORPSE_RUNS",1)
  end
  
  rez_request = false
  spirit_healer = false
end

local function playerSpiritHealer()
  q:incrementStat("NUM_SPIRIT_HEALER_REZ",1)
  
  spirit_healer = true
  rez_request = false
end

local function resurrectRequest()
  rez_request = true
end

local function playerAura(event, unit)
  
  if (unit == "player") then
    
    local buff = {UnitBuff("player", 1)}
    local debuff = {UnitDebuff("player", 1)}
    --q:printTable(buff)
    --q:printTable(debuff)
  
    if (quantify_state:isPlayerInCombat()) then
      
      if (event == "PLAYER_CONTROL_LOST") then
        combat_cc = true
        cc_start_time = GetTime()
      elseif (event == "PLAYER_CONTROL_GAINED") then
        local duration = GetTime() - cc_start_time
        if (combat_cc and duration < CC_WINDOW) then
          q:incrementStat("TIME_CROWD_CONTROLLED", duration)
        end
        
        combat_cc = false
      end
    else
      combat_cc = false
    end
  end
  
end

local function combatLog()
  local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
  
  if (event == "PARTY_KILL") then
    if (sourceGUID == UnitGUID("player")) then
      q:incrementStat("PLAYER_ACTUAL_KILLS",1)
    end
    
    local source_affiliation = bit.band(sourceFlags, 0xf) --only keep affiliation bits
    if (source_affiliation == 1 or source_affiliation == 2 or source_affiliation == 4) then --self,party,raid
      q:incrementStat("PLAYER_KILLS",1)
    end
  end
end

function quantify_combat:calculateDerivedStats(segment)
  
  local stats = segment.stats
  
  local deaths = stats.num_deaths == 0 and 1 or stats.num_deaths
  stats.kd_ratio = stats.player_kills / deaths
  
end

function quantify_combat:updateStats(segment)
  quantify_combat:calculateDerivedStats(segment)
end
 
function quantify_combat:newSegment(segment)
  
  segment.stats = segment.stats or 
                         {num_deaths = 0,
                          num_corpse_runs = 0,
                          num_brez_accepted = 0,
                          num_spirit_healer_rez = 0,
                          num_rez_accepted = 0,
                          time_crowd_controlled = 0,
                          player_kills = 0,
                          player_actual_kills = 0}
  
end

table.insert(quantify.modules, quantify_combat)
  
quantify:registerEvent("PLAYER_DEAD", playerDead)
quantify:registerEvent("PLAYER_ALIVE", playerAlive)
quantify:registerEvent("PLAYER_UNGHOST", playerUnghost)
quantify:registerEvent("CONFIRM_XP_LOSS", playerSpiritHealer)
quantify:registerEvent("RESURRECT_REQUEST", resurrectRequest)
quantify:registerEvent("UNIT_AURA", playerAura)
quantify:registerEvent("LOSS_OF_CONTROL_ADDED", playerAura)
quantify:registerEvent("COMBAT_LOG_EVENT_UNFILTERED", combatLog)