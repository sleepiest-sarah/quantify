quantify.Segment = {}

local Segment = quantify.Segment
function Segment:new(o)
  o = o or {start_time = nil, end_time = nil, _duration = nil, stats = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Segment:duration()
  if (self.end_time ~= nil and self.start_time ~= nil) then
    return self.end_time - self.start_time
  elseif (self.end_time == nil and self.start_time ~= nil) then
    return GetTime() - self.start_time
  else 
    return _duration
  end
end

quantify.TotalSegment = {}
local TotalSegment = quantify.TotalSegment
function TotalSegment:new(o)
  o = o or {time = 0, stats = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

function TotalSegment:characterKey()
  return GetUnitName("player", false).."-"..GetRealmName()
end
  