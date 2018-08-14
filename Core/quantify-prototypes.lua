quantify.Segment = {}

local Segment = quantify.Segment
function Segment:new(o)
  o = o or {start_time = nil, end_time = nil, total_start_time = nil, _duration = nil, stats = {}}
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
    return self._duration
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
  
quantify.Item = {}
local Item = quantify.Item
function Item:new(arg1)
  local i
  if (type(arg1) ~= "table") then
    i = {GetItemInfo(arg1)}
  else
    i = arg1
  end
  if (i == nil) then
    return nil
  end
  local o = {}
  o.itemName, o.itemLink, o.itemRarity, o.itemLevel, o.itemMinLevel, o.itemType, o.itemSubType, o.itemStackCount,
o.itemEquipLoc, o.itemIcon, o.itemSellPrice, o.itemClassID, o.itemSubClassID, o.bindType, o.expacID, o.itemSetID, 
o.isCraftingReagent = unpack(i)
  setmetatable(o, self)
  self.__index = self
  return o
end