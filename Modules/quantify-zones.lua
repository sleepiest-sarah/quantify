quantify_zones = {}

local q = quantify
local s = quantify_state

quantify_zones.MODULE_KEY = "zones"

local zone_start_time

local function zoneChangedNewArea(event,...)
  local zone = s:getCurrentZoneName()
  if (zone ~= nil) then
    zone_start_time = zone_start_time or GetTime()
    local zone_duration = GetTime() - zone_start_time

    if (zone_duration > 0) then
      q:incrementStatByPath("zones/stats/zones/"..zone, zone_duration)
      
      zone_start_time = GetTime()
    end
  end
end

local function playerEnteringWorld()
  zoneChangedNewArea()
end

function quantify_zones:calculateDerivedStats(segment, completeSegment)
  local total_time = q:getStat(completeSegment, "PLAY_TIME")
  
  segment.stats.pct_zones = {}
  if (total_time ~= nil) then
    for k,v in pairs(segment.stats.zones) do
      segment.stats.pct_zones[k] = (v / total_time) * 100
    end
  end
end

function quantify_zones:updateStats(segment, completeSegment) --work around until I figure out a better way to access external stats from modules
  if (q.current_segment and segment == q.current_segment.stats.zones) then
    zoneChangedNewArea()
  end
  
  quantify_zones:calculateDerivedStats(segment, completeSegment)
end

 
function quantify_zones:newSegment(segment)
  
  segment.stats = q:addKeysLeft(segment.stats, { zones = {} }) 
end

table.insert(quantify.modules, quantify_zones)

quantify:registerEvent("ZONE_CHANGED_NEW_AREA", zoneChangedNewArea)
quantify:registerEvent("PLAYER_ENTERING_WORLD", playerEnteringWorld)
  
  