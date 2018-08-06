quantify_combat = {}

local q = quantify

quantify_combat.Session = {}

quantify_combat.MODULE_KEY = "combat"

function quantify_combat.Session:new(o)
  o = o or {num_kills = 0, num_deaths = 0, num_corpse_runs = 0, num_brez_accepted = 0, num_spirit_healer_rez = 0, num_rez_accepted = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local rez_request = false
local spirit_healer = false

local function init()
  quantify.current_segment.stats.combat = {} 
  quantify.current_segment.stats.combat.raw = quantify_combat.Session:new()
  quantify.current_segment.stats.combat.derived_stats = {}
  quantify.current_segment.stats.combat.session_rates = {}
  session = quantify.current_segment.stats.combat.raw
end

local function playerDead()
  session.num_deaths = session.num_deaths + 1
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

function quantify_combat:calculateDerivedStats(segment)

end

function quantify_combat:updateStats(segment)

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