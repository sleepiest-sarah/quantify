quantify_zones = {}

local q = quantify
local s = quantify_state

quantify_zones.Session = {}

quantify_zones.MODULE_KEY = "zones"
quantify_zones.RAW_ZONE_PREFIX = "zone_time_*"
quantify_zones.PCT_ZONE_PREFIX = "zone_pct_*"

function quantify_zones.Session:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local zone_start_time

local function getZoneKey(zone)
  return quantify_zones.RAW_ZONE_PREFIX..zone
end

local function zoneChangedNewArea(event,...)
  local zone = s:getCurrentZoneName()
  if (zone ~= nil) then
    zone_start_time = zone_start_time or GetTime()
    local zone_duration = GetTime() - zone_start_time
    
    local key = getZoneKey(zone)
    if (session[key] == nil) then
      session[key] = 0
    end
    
    session[key] = session[key] + zone_duration
    
    zone_start_time = GetTime()
  end
end

local function playerEnteringWorld()
  zoneChangedNewArea()
end

function quantify_zones:calculateDerivedStats(segment)
  local derived_stats = {}
  local total_time = segment.stats.time.raw.play_time
  if (total_time ~= nil) then
    for k,v in pairs(segment.stats.zones.raw) do
      if (string.sub(k,1,string.len(quantify_zones.RAW_ZONE_PREFIX)) == quantify_zones.RAW_ZONE_PREFIX) then
        local zone = string.sub(k, string.len(quantify_zones.RAW_ZONE_PREFIX) + 1)
        derived_stats[quantify_zones.PCT_ZONE_PREFIX..zone] = (v / total_time) * 100
      end
    end
  end
  
  segment.stats.zones.derived_stats = derived_stats
end

function quantify_zones:updateStats(segment)
  if (segment == q.current_segment) then
    zoneChangedNewArea()
  end
  
  quantify_zones:calculateDerivedStats(segment)
end

local function init()
  q.current_segment.stats.zones = {}
  q.current_segment.stats.zones.raw = quantify_zones.Session:new()
  q.current_segment.stats.zones.derived_stats = { }
  session = q.current_segment.stats.zones.raw
end

 
function quantify_zones:newSegment(previous_seg,new_seg)
  zone_start_time = GetTime()
  
  init()
end

table.insert(quantify.modules, quantify_zones)

quantify:registerEvent("ZONE_CHANGED_NEW_AREA", zoneChangedNewArea)
quantify:registerEvent("PLAYER_ENTERING_WORLD", playerEnteringWorld)
  
  