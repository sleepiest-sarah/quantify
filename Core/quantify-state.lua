quantify_state = {}

local q = quantify


quantify_state.state = {
    current_zone_name = nil,
    UiMapDetails = nil,
    player_combat = false,
    current_player_name = nil,
    player_name_realm = nil,
    player_in_instance = nil,
    player_alive = true
}

local s = quantify_state.state

local function zoneChangedNewArea(event, ...)
  s.UiMapDetails = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))
  s.current_zone_name = s.UiMapDetails.name
  
  local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
  s.player_in_instance = instanceType ~= "none"
end

local function playerRegenDisabled()
  s.player_combat = true
end

local function playerRegenEnabled()
  s.player_combat = false
end

local function playerDead()
  s.player_alive = false
end

local function playerAlive()
  s.player_alive = true
end

local function playerLogin()
  s.current_player_name = GetUnitName("player", false)
  s.player_name_realm = GetUnitName("player", false).."-"..GetRealmName()
end
  
quantify:registerEvent("ZONE_CHANGED_NEW_AREA", zoneChangedNewArea)   --this event does not fire on /reload
quantify:registerEvent("PLAYER_REGEN_DISABLED", playerRegenDisabled)
quantify:registerEvent("PLAYER_REGEN_ENABLED", playerRegenEnabled)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)
quantify:registerEvent("PLAYER_DEAD", playerDead)
quantify:registerEvent("PLAYER_ALIVE", playerAlive)


--getters
function quantify_state:getCurrentZoneName()
  return s.current_zone_name
end

function quantify_state:isPlayerInCombat()
  return s.player_combat
end

function quantify_state:getPlayerName()
  return s.current_player_name
end

function quantify_state:getPlayerNameRealm()
  return s.player_name_realm
end

function quantify_state:isPlayerAlive()
  return s.player_alive
end

function quantify_state:isPlayerInInstance()
  return s.player_in_instance
end