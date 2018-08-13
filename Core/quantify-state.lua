quantify_state = {}

local q = quantify


quantify_state.state = {
    current_zone_name = nil,
    UiMapDetails = nil,
    player_combat = false,
    current_player_name = nil,
    player_name_realm = nil,
    player_in_instance = nil,
    player_alive = true,
    instance_type = nil,
    instance_map_id = nil,
    instance_name = nil,
    player_control = true
}

local s = quantify_state.state

local function zoneChangedNewArea(event, ...)
  s.UiMapDetails = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player"))
  s.current_zone_name = s.UiMapDetails.name
  
  local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
  s.player_in_instance = instanceType ~= "none"
  s.instance_type = instanceType
  s.instance_map_id = instanceMapID
  s.instance_name = name
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

local function playerControlLost()
  s.player_control = false
end

local function playerControlGained()
  s.player_control = true
end

local function playerLogin()
  s.current_player_name = GetUnitName("player", false)
  s.player_name_realm = GetUnitName("player", false).."-"..GetRealmName()
end

local function playerEnteringWorld()
  zoneChangedNewArea()
end
  
quantify:registerEvent("ZONE_CHANGED_NEW_AREA", zoneChangedNewArea)   --this event does not fire on /reload
quantify:registerEvent("PLAYER_REGEN_DISABLED", playerRegenDisabled)
quantify:registerEvent("PLAYER_REGEN_ENABLED", playerRegenEnabled)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)
quantify:registerEvent("PLAYER_DEAD", playerDead)
quantify:registerEvent("PLAYER_ALIVE", playerAlive)
quantify:registerEvent("PLAYER_CONTROL_GAINED", playerControlGained)
quantify:registerEvent("PLAYER_CONTROL_LOST", playerControlLost)
quantify:registerEvent("PLAYER_ENTERING_WORLD", playerEnteringWorld)


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

function quantify_state:isPlayerInLegionRaid()
  return q:contains(quantify.LEGION_RAID_IDS,s.instance_map_id)
end

function quantify_state:isPlayerInLegionDungeon()
  return q:contains(quantify.LEGION_DUNGEON_IDS,s.instance_map_id)  
end

function quantify_state:getInstanceName()
  return s.instance_name
end

function quantify_state:getInstanceType()
  return s.instance_type
end

function quantify_state:playerHasControl()
  return s.player_control
end

function quantify_state:playerCrowdControlled()
  return not s.player_control and s.player_combat
end