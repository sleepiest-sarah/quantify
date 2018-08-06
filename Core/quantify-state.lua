quantify_state = {}

local q = quantify


quantify_state.state = {
    current_zone_name = nil,
    UiMapDetails = nil,
    player_combat = nil,
    current_player_name = nil,
    player_name_realm = nil
}

local s = quantify_state.state

local function zoneChangedNewArea(event, ...)
  s.UiMapDetails = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))
  s.current_zone_name = s.UiMapDetails.name
end

local function playerRegenDisabled()
  s.player_combat = true
end

local function playerRegenEnabled()
  s.player_combat = false
end

local function playerLogin()
  s.current_player_name = GetUnitName("player", false)
  s.player_name_realm = GetUnitName("player", false).."-"..GetRealmName()
end
  
quantify:registerEvent("ZONE_CHANGED_NEW_AREA", zoneChangedNewArea)   --this event does not fire on /reload
quantify:registerEvent("PLAYER_REGEN_DISABLED", playerRegenDisabled)
quantify:registerEvent("PLAYER_REGEN_ENABLED", playerRegenEnabled)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)


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