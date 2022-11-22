quantify_state = {}

local q = quantify


quantify_state.state = {
    current_zone_name = nil,
    UiMapDetails = nil,
    party = nil,
    player_combat = false,
    current_player_name = nil,
    player_name_realm = nil,
    player_in_instance = nil,
    player_alive = true,
    instance_type = nil,
    instance_map_id = nil,
    instance_name = nil,
    instance_journal_id = nil,
    keystone_completed = false,
    player_control = true,
    instance_difficulty_name = nil,
    instance_start_time = nil,
    player_mounted = false,
    player_armor_skills = nil,
    player_weapon_skills = nil,
    player_class = nil,
    player_spec = nil,
    player_role = nil,
    player_indoors = nil,
    player_outdoors = nil,
    player_can_gain_xp = true
}

local s = quantify_state.state

local function zoneChangedNewArea(event, ...)
  local map = C_Map.GetBestMapForUnit("player")
  if (map ~= nil) then
    s.UiMapDetails = C_Map.GetMapInfo(map)
    s.current_zone_name = s.UiMapDetails.name
  end
  
  local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize, lfgDungeonID = GetInstanceInfo()
  if (s.player_in_instance and instanceType == "none") then
    q:triggerQEvent("LEFT_INSTANCE")
  end
  
  s.player_in_instance = instanceType ~= "none"
  s.instance_type = instanceType
  s.instance_name = name
  if (s.player_in_instance and (s.instance_map_id ~= instanceMapID or s.instance_difficulty_name ~= difficultyName)) then
    s.instance_start_time = GetTime()
    s.instance_journal_id = EJ_GetInstanceForMap(s.UiMapDetails.mapID)
    if (s.instance_journal_id and s.instance_journal_id > 0) then
      EJ_SelectInstance(s.instance_journal_id)
    end
    
    s.keystone_completed = false
    
    q:triggerQEvent("ENTERED_NEW_INSTANCE", instanceMapID, difficultyName)
  end
  
  s.instance_map_id = instanceMapID
  s.instance_difficulty_name = difficultyName

  s.player_indoors = IsIndoors()
  s.player_outdoors = IsOutdoors()

end

local function playerMount(...)
  if (nil == unpack({...})) then
    s.player_mounted = IsMounted()
  else
    q:registerNextFrame(playerMount)
  end
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

local function initArmorWeaponSkills()
  if (s.player_armor_skills ~= nil) then
    return
  end
  
  s.player_armor_skills = {}
  s.player_weapon_skills = {}
  
  local _, _, _, _, _, _, armorSpellId = GetSpellInfo("Armor Skills")
  local _, _, _, _, _, _, weaponSpellId = GetSpellInfo("Weapon Skills")
  
  local armor_desc = armorSpellId and GetSpellDescription(armorSpellId) or nil
  local weapon_desc = weaponSpellId and GetSpellDescription(weaponSpellId) or nil
  
  if (armor_desc) then  -- only consider the "best" armor the class can use
    local plate = string.find(armor_desc,"plate")
    s.player_armor_skills["plate"] = plate and "plate" or nil
    if (not s.player_armor_skills["plate"]) then
      local mail = string.find(armor_desc,"mail")
      s.player_armor_skills["mail"] = mail and "mail" or nil
    end
    if (not s.player_armor_skills["plate"] and not s.player_armor_skills["mail"]) then
      local leather = string.find(armor_desc,"leather")
      s.player_armor_skills["leather"] = leather and "leather" or nil
    end
    if (not s.player_armor_skills["plate"] and not s.player_armor_skills["mail"] and not s.player_armor_skills["leather"]) then
      local cloth = string.find(armor_desc,"cloth")
      s.player_armor_skills["cloth"] = cloth and "cloth" or nil
    end
    
    local shields = string.find(armor_desc, "Shields")
    if (shields) then
      s.player_armor_skills["Shields"] = "Shields"
    end
  end
  
  if (weapon_desc) then
    for weapon,subtext in string.gmatch(weapon_desc, "\r\n(%a+)[ ]?%(?([A-Za-z%-]*)%)?") do
      if (subtext == "") then
        subtext = nil
      end
      local weapon_string = subtext and (subtext.." "..weapon) or weapon
      if (subtext == nil and (weapon == "Axes" or weapon == "Maces" or weapon == "Swords")) then  --for classes that can wield both varieties
        s.player_weapon_skills["One-Handed "..weapon] = "One-Handed "..weapon
        s.player_weapon_skills["Two-Handed "..weapon] = "Two-Handed "..weapon
      elseif (weapon == "Fist" and subtext == "Weapons") then                                     --fist weapons are formatted differently than other dual wield weapon types
        s.player_weapon_skills["Fist Weapons"] = "Fist Weapons"
      else
        s.player_weapon_skills[weapon_string] = weapon_string
      end
    end
  end
end

local function checkClassSpec()
  s.player_class = UnitClass("player")
  
  if (q.isRetail) then  --is there some way to get this info in classic?
    local spec_i = GetSpecialization()
    if (spec_i) then
      _,s.player_spec,_,_,s.player_role,_ = GetSpecializationInfo(spec_i)
    end
  end
  
  initArmorWeaponSkills()
end

local function playerLogin()
  s.current_player_name = GetUnitName("player", false)
  s.player_name_realm = GetUnitName("player", false).."-"..GetRealmName()
end

local function checkParty()
  if (IsInGroup() and not IsInRaid()) then
    local num_members = GetNumGroupMembers()
    local grouptype = q:getUnitGroupPrefix()
    
    if (grouptype == "party") then
      s.party = q.Party:new()
      
      s.party:addMember(s.current_player_name, s.player_role)
      
      for i=1,num_members-1 do
        local mate = GetUnitName(grouptype..i, true)
        local role = UnitGroupRolesAssigned(grouptype..i)
        s.party:addMember(mate, role)
      end
    end
  end
end

local function keystoneStart(event, mapId)
  s.keystone_completed = false
end

local function keystoneComplete(event)
  s.keystone_completed = true
end

local function playerEnteringWorld()
  zoneChangedNewArea()
  
  initArmorWeaponSkills()
  
  checkClassSpec()
  
  checkParty()
  
  s.player_mounted = IsMounted()
  s.player_indoors = IsIndoors()
  s.player_outdoors = IsOutdoors()
  
  
  s.player_can_gain_xp = not (UnitXP("player") == 0 or (q.isRetail and IsXPUserDisabled()))
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
quantify:registerEvent("PLAYER_MOUNT_DISPLAY_CHANGED", playerMount)

quantify:registerEvent("ROLE_CHANGED_INFORM", checkParty)
quantify:registerEvent("GROUP_ROSTER_UPDATE", checkParty)

if (q.isRetail) then
  q:registerEvent("CHALLENGE_MODE_START", keystoneStart)
  q:registerEvent("CHALLENGE_MODE_RESET", keystoneStart)
  q:registerEvent("CHALLENGE_MODE_COMPLETED", keystoneComplete)
  
  quantify:registerEvent("PLAYER_SPECIALIZATION_CHANGED", checkClassSpec)  
end

quantify:registerEvent("ZONE_CHANGED_INDOORS", zoneChangedNewArea)
quantify:registerEvent("ZONE_CHANGED", zoneChangedNewArea)

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

function quantify_state:isPlayerInBfaRaid()
  return q:contains(quantify.BFA_RAID_IDS,s.instance_map_id)
end

function quantify_state:isPlayerInBfaDungeon()
  return q:contains(quantify.BFA_DUNGEON_IDS,s.instance_map_id)  
end


function quantify_state:isPlayerInClassicRaid()
  return q:contains(quantify.CLASSIC_RAID_IDS,s.instance_map_id)
end

function quantify_state:isPlayerInClassicDungeon()
  return q:contains(quantify.CLASSIC_DUNGEON_IDS,s.instance_map_id)  
end

function quantify_state:getInstanceName()
  return s.instance_name
end

function quantify_state:getInstanceType()
  return s.instance_type
end

function quantify_state:getCurrentClassicDungeon()
  return q.CLASSIC_DUNGEONS[s.instance_map_id]
end

function quantify_state:playerHasControl()
  return s.player_control
end

function quantify_state:playerCrowdControlled()
  return not s.player_control and s.player_combat
end

function quantify_state:getCurrentMapId()
  return s.UiMapDetails.mapID
end

function quantify_state:getInstanceDifficulty()
  return s.instance_difficulty_name
end

function quantify_state:isMythicPlus()
  return s.instance_difficulty_name == "Mythic Keystone"
end

function quantify_state:getInstanceStartTime()
  return s.instance_start_time
end

function quantify_state:isPlayerMounted()
  return s.player_mounted
end

function quantify_state:canPlayerEquipType(equip_type)
  return s.player_armor_skills[string.lower(equip_type)] or s.player_weapon_skills[equip_type]
end

function quantify_state:getPlayerSpecClass()
  if (s.player_spec) then --this will always be null in Classic
    return s.player_spec.." "..s.player_class
  else
    return s.player_class
  end
end

function quantify_state:IsIndoors()
  return s.player_indoors
end

function quantify_state:IsOutdoors()
  return s.player_outdoors
end

function quantify_state:CanPlayerGainXp()
  return s.player_can_gain_xp
end

function quantify_state:CanPlayerJump()
  return not IsSubmerged() and not IsFalling() and (q.isClassic or (q.isRetail and not IsFlying()))
end

function quantify_state:GetPlayerParty()
  return s.party
end

function quantify_state:isCurrentDungeonComplete()
  if (not s.player_in_instance or not s.instance_journal_id) then
    return false
  end
  
  if (s.instance_journal_id == 0) then
    s.instance_journal_id = EJ_GetInstanceForMap(s.UiMapDetails.mapID)
    if (s.instance_journal_id == 0) then
      return false
    end
  end
  
  if (IsLFGComplete()) then
    return true
  end
  
  EJ_SelectInstance(s.instance_journal_id)
  
  if (not quantify_state:isMythicPlus()) then
    local i = 1
    repeat
      local _,_,bossId,_,_,_,encounterId = EJ_GetEncounterInfoByIndex(i, s.instance_journal_id)
      if (bossId and not C_EncounterJournal.IsEncounterComplete(bossId)) then
        return false
      end
      i = i + 1
    until bossId == nil
    return true
  else
    return s.keystone_completed
  end
  
end