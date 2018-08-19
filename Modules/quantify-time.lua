quantify_time = {}

local q = quantify

quantify_time.Session = {}

quantify_time.MODULE_KEY = "time"

function quantify_time.Session:new(o)
  o = o or {time_combat = 0, play_time = 0, time_afk = 0, time_mounted = 0, time_fishing = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local combat_start = nil
local afk_start = nil
local mount_start = nil
local fishing_start = nil

local in_combat = false
local isAfk = false
local is_mounted = false

local function init()
  q.current_segment.stats.time = {}
  q.current_segment.stats.time.raw = quantify_time.Session:new()
  q.current_segment.stats.time.derived_stats = { pct_play_time_combat = 0, pct_play_time_afk = 0}
  session = q.current_segment.stats.time.raw
end

local function playerRegenDisabled()
  combat_start = GetTime()
  
  in_combat = true
end

local function playerRegenEnabled()
  in_combat = false
  
  local curtime = GetTime()
  combat_start = combat_start or curtime
  
  local combat_time = curtime - combat_start
  session.time_combat = session.time_combat + combat_time
end

local function playerAfk(event, ...)
  local msg = unpack({...})
  
  if (msg == string.format(MARKED_AFK_MESSAGE, "AFK")) then
    isAfk = true
    afk_start = GetTime()
  elseif (msg == CLEARED_AFK) then
    afk_start = afk_start or GetTime()
    isAfk = false
    session.time_afk = session.time_afk + (GetTime() - afk_start)
  end
    
end

local function playerMount(...)
  if (nil == unpack({...})) then
    if (is_mounted) then
      session.time_mounted = session.time_mounted + (GetTime() - mount_start)
    elseif (not is_mounted and quantify_state:isPlayerMounted()) then
      mount_start = GetTime()
    end
    is_mounted = quantify_state:isPlayerMounted()
  else
    q:registerNextFrame(playerMount)
  end
end

local function playerEnteringWorld()
  playerMount()
end

local function combatLog()
  local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()
  
  if (event == "SPELL_CAST_SUCCESS" and sourceGUID == UnitGUID("player") and spellName == "Fishing") then
    fishing_start = GetTime()
  elseif (event == "SPELL_AURA_REMOVED" and sourceGUID == UnitGUID("player") and spellName == "Fishing") then
    if (fishing_start ~= nil) then
      local duration = GetTime() - fishing_start
      if (duration < 23) then --sanity check
        session.time_fishing = session.time_fishing + duration
      end
    end
  end
end

function quantify_time:calculateDerivedStats(segment)
  local derived_stats = {}
  
  local raw = segment.stats.time.raw
  derived_stats.pct_play_time_combat = (raw.time_combat / raw.play_time) * 100
  derived_stats.pct_play_time_afk = (raw.time_afk / raw.play_time) * 100
  derived_stats.pct_time_mounted = (raw.time_mounted / raw.play_time) * 100
  derived_stats.pct_time_fishing = (raw.time_fishing / raw.play_time) * 100
  segment.stats.time.derived_stats = derived_stats
end

function quantify_time:updateStats(segment)
  if (segment == q.current_segment) then
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
    
    if q.current_segment.start_time ~= nil then
      session.play_time = GetTime() - q.current_segment.start_time
    end
  end
    
  quantify_time:calculateDerivedStats(segment)
end
 
function quantify_time:newSegment(previous_seg,new_seg)
  combat_start = GetTime()
  afk_start = GetTime()
  mount_start = GetTime()
  
  init()
  
end

init()

table.insert(quantify.modules, quantify_time)

quantify:registerEvent("PLAYER_REGEN_DISABLED", playerRegenDisabled)
quantify:registerEvent("PLAYER_REGEN_ENABLED", playerRegenEnabled)
quantify:registerEvent("CHAT_MSG_SYSTEM", playerAfk)
quantify:registerEvent("PLAYER_MOUNT_DISPLAY_CHANGED", playerMount)
quantify:registerEvent("PLAYER_ENTERING_WORLD", playerEnteringWorld)
quantify:registerEvent("COMBAT_LOG_EVENT_UNFILTERED", combatLog)
  
  