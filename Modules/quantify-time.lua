quantify_time = {}

local q = quantify

quantify_time.Session = {}

quantify_time.MODULE_KEY = "time"

function quantify_time.Session:new(o)
  o = o or {time_combat = 0, play_time = 0, time_afk = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local combat_start = nil
local afk_start = nil

local in_combat = false
local isAfk = false

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

function quantify_time:calculateDerivedStats(segment)
  local derived_stats = {}
  
  local raw = segment.stats.time.raw
  derived_stats.pct_play_time_combat = (raw.time_combat / raw.play_time) * 100
  derived_stats.pct_play_time_afk = (raw.time_afk / raw.play_time) * 100
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
    
    if q.current_segment.start_time ~= nil then
      session.play_time = GetTime() - q.current_segment.start_time
    end
  end
    
  quantify_time:calculateDerivedStats(segment)
end
 
function quantify_time:newSegment(previous_seg,new_seg)
  combat_start = GetTime()
  afk_start = GetTime()
  
  init()
  
end

init()

table.insert(quantify.modules, quantify_time)

quantify:registerEvent("PLAYER_REGEN_DISABLED", playerRegenDisabled)
quantify:registerEvent("PLAYER_REGEN_ENABLED", playerRegenEnabled)
quantify:registerEvent("CHAT_MSG_SYSTEM", playerAfk)
  
  