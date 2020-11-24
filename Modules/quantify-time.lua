quantify_time = {}

local q = quantify

quantify_time.MODULE_KEY = "time"

local combat_start = nil
local afk_start = nil
local mount_start = nil
local fishing_start = nil
local outdoors_start = nil
local indoors_start = nil
local rested_start = nil
local falling_start = nil
local play_time_start = nil
local pet_battle_start = nil

local in_combat = false
local isAfk = false
local is_mounted = false
local is_outdoors = false
local is_indoors = false
local is_rested = false
local is_falling = false
local in_pet_battle = false

local function playerRegenDisabled()
  combat_start = GetTime()
  
  in_combat = true
end

local function playerRegenEnabled()
  in_combat = false
  
  local curtime = GetTime()
  combat_start = combat_start or curtime
  
  local combat_time = curtime - combat_start
  q:incrementStat("TIME_COMBAT", combat_time)
end

local function playerAfk(event, ...)
  local msg = unpack({...})
  
  if (msg == string.format(MARKED_AFK_MESSAGE, "AFK")) then
    isAfk = true
    afk_start = GetTime()
  elseif (msg == CLEARED_AFK) then
    afk_start = afk_start or GetTime()
    isAfk = false
    q:incrementStat("TIME_AFK", (GetTime() - afk_start))
  end
    
end

local function playerMount(...)
  if (nil == unpack({...})) then
    if (is_mounted) then
      q:incrementStat("TIME_MOUNTED",(GetTime() - mount_start)) 
    elseif (not is_mounted and quantify_state:isPlayerMounted()) then
      mount_start = GetTime()
    end
    is_mounted = quantify_state:isPlayerMounted()
  else
    q:registerNextFrame(playerMount)
  end
end

local function combatLog()
  local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()

  if ((event == "SPELL_CAST_SUCCESS" or event == "SPELL_CREATE") and sourceGUID == UnitGUID("player") and spellName == "Fishing") then
    fishing_start = GetTime()
  elseif (event == "SPELL_AURA_REMOVED" and sourceGUID == UnitGUID("player") and spellName == "Fishing") then
    if (fishing_start ~= nil) then
      local duration = GetTime() - fishing_start
      if (duration < 23) then --sanity check
        q:incrementStat("TIME_FISHING",duration)
      end
    end
  end
end

local function zoneChanged()
  if (is_outdoors) then
    local duration = GetTime() - outdoors_start
    q:incrementStat("TIME_OUTDOORS", duration)
    outdoors_start = GetTime()
  elseif (IsOutdoors() and not is_outdoors) then
    outdoors_start = GetTime()
  end
  is_outdoors = IsOutdoors()
  
  if (is_indoors) then
    local duration = GetTime() - indoors_start
    q:incrementStat("TIME_INDOORS",duration)
    indoors_start = GetTime()
  elseif (IsIndoors() and not is_indoors) then
    indoors_start = GetTime()
  end
  is_indoors = IsIndoors()
end

local function updateExhaustion()
  if (GetXPExhaustion() and GetXPExhaustion() > 0 and not is_rested) then
    is_rested = true
    rested_start = GetTime()
  elseif (is_rested) then
    q:incrementStat("TIME_RESTED",(GetTime() - rested_start))
    rested_start = GetTime()
  end
  is_rested = GetXPExhaustion() and GetXPExhaustion() > 0
end

local function playerEnteringWorld()
  playerMount()
  zoneChanged()
  updateExhaustion()
  
  local duration = GetTime() - (play_time_start or GetTime())
  q:incrementStat("PLAY_TIME", duration)
  
  if (quantify_state:CanPlayerGainXp()) then
    q:incrementStat("TIME_SUB_MAX_LEVEL",duration)
  end
  
  play_time_start = GetTime()
end

local function airTime()
  if (is_falling) then
    local duration = GetTime() - falling_start
    q:incrementStat("AIR_TIME", duration)
    falling_start = GetTime()
  elseif (IsFalling() and not is_falling) then
    falling_start = GetTime()
  end
  is_falling = IsFalling()
  
  if (is_falling) then
    q:registerNextFrame(airTime)
  end
end

local function jump()
  if (quantify_state:CanPlayerJump()) then
    q:registerNextFrame(airTime)
  end
end

local function petBattleStart()
  pet_battle_start = GetTime()

  in_pet_battle = true
end

local function petBattleEnd()
  in_pet_battle = false

  local curtime = GetTime()
  pet_battle_start = pet_battle_start or curtime

  local combat_time = curtime - pet_battle_start
  q:incrementStat("TIME_PET_BATTLE", combat_start)
end

function quantify_time:calculateDerivedStats(segment)
  
  if (segment.stats and segment.stats.play_time) then
    local stats = segment.stats
    local play_time = stats.play_time > 0 and stats.play_time or 1
    stats.pct_play_time_combat = (stats.time_combat / play_time) * 100
    stats.pct_play_time_afk = (stats.time_afk / play_time) * 100
    stats.pct_time_mounted = (stats.time_mounted / play_time) * 100
    stats.pct_time_fishing = (stats.time_fishing / play_time) * 100
    stats.pct_time_indoors = (stats.time_indoors / play_time) * 100
    stats.pct_time_outdoors = (stats.time_outdoors / play_time) * 100
    stats.pct_time_jump = (stats.air_time / play_time) * 100
    stats.pct_time_rested = (stats.time_rested / play_time) * 100
    stats.pct_time_pet_battles = (stats.time_pet_battle / play_time) * 100
  end

end

function quantify_time:updateStats(segment)
  if (q.current_segment and segment == q.current_segment.stats.time) then
    if in_combat then
      playerRegenEnabled()
      in_combat = true
      combat_start = GetTime()
    end
    
    if isAfk then
      playerAfk(nil,CLEARED_AFK)
      isAfk = true
      afk_start = GetTime()
    end
    
    if is_mounted then
      playerMount()
      mount_start = GetTime()
    end
    
    if is_outdoors then
      zoneChanged()
      outdoors_start = GetTime()
    end
    
    if is_indoors then
      zoneChanged()
      indoors_start = GetTime()
    end
    
    if is_rested then
      updateExhaustion()
      rested_start = GetTime()
    end
    
    if in_pet_battle then
      petBattleEnd()
      in_pet_battle = true
      pet_battle_start = GetTime()
    end
    
    local duration = GetTime() - (play_time_start or GetTime())
    q:incrementStat("PLAY_TIME", duration)
  
    if (quantify_state:CanPlayerGainXp()) then
      q:incrementStat("TIME_SUB_MAX_LEVEL",duration)
    end
  
    play_time_start = GetTime()
    
  end
    
  quantify_time:calculateDerivedStats(segment)
end
 
function quantify_time:newSegment(segment)
  combat_start = GetTime()
  afk_start = GetTime()
  mount_start = GetTime()
  
  segment.stats = q:addKeysLeft(segment.stats,
                   {time_combat = 0,
                    play_time = 0, 
                    time_afk = 0, 
                    time_mounted = 0, 
                    time_fishing = 0, 
                    time_indoors = 0, 
                    time_outdoors = 0, 
                    time_sub_max_level = 0, 
                    time_rested = 0, 
                    air_time = 0,
                    time_pet_battle = 0})
  
end

table.insert(quantify.modules, quantify_time)

quantify:registerEvent("PLAYER_REGEN_DISABLED", playerRegenDisabled)
quantify:registerEvent("PLAYER_REGEN_ENABLED", playerRegenEnabled)
quantify:registerEvent("CHAT_MSG_SYSTEM", playerAfk)
quantify:registerEvent("PLAYER_MOUNT_DISPLAY_CHANGED", playerMount)
quantify:registerEvent("PLAYER_ENTERING_WORLD", playerEnteringWorld)
quantify:registerEvent("ZONE_CHANGED_INDOORS", zoneChanged)
quantify:registerEvent("ZONE_CHANGED_NEW_AREA", zoneChanged)
quantify:registerEvent("ZONE_CHANGED", zoneChanged)
quantify:registerEvent("UPDATE_EXHAUSTION", updateExhaustion)

q:hookSecureFunc("JumpOrAscendStart", jump)

if (q.isRetail) then
  quantify:registerEvent("COMBAT_LOG_EVENT_UNFILTERED", combatLog)
  quantify:registerEvent("PET_BATTLE_OPENING_DONE", petBattleStart)
  quantify:registerEvent("PET_BATTLE_FINAL_ROUND", petBattleEnd)
end
  
  