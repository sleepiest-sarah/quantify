quantify_state = {}

local q = quantify
local s = quantify_state

quantify_state.state = {
    current_zone_name = nil,
    UiMapDetails = nil,
    player_combat = nil
}


local function zoneChangedNewArea(event, ...)
   quantify_state.state.UiMapDetails = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))
   quantify_state.state.current_zone_name = quantify_state.state.UiMapDetails.name
end

local function playerRegenDisabled()
  s.state.player_combat = true
end

local function playerRegenEnabled()
  s.state.player_combat = false
end
  
quantify:registerEvent("ZONE_CHANGED_NEW_AREA", zoneChangedNewArea)
quantify:registerEvent("PLAYER_REGEN_DISABLED", playerRegenDisabled)
quantify:registerEvent("PLAYER_REGEN_ENABLED", playerRegenEnabled)


--getters
function s:getCurrentZoneName()
  return s.state.current_zone_name
end

function s:isPlayerInCombat()
  return s.state.player_combat
end