quantify_coll = {}

local q = quantify

quantify_coll.Session = {}

quantify_coll.MODULE_KEY = "collections"

function quantify_coll.Session:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local function init()
  q.current_segment.stats.collections = {}
  q.current_segment.stats.collections.raw = quantify_coll.Session:new()
  q.current_segment.stats.collections.derived_stats = { }
  session = q.current_segment.stats.collections.raw
end

function quantify_coll:calculateDerivedStats(segment)

end

function quantify_coll:updateStats(segment)

end
 
function quantify_coll:newSegment(previous_seg,new_seg)
  init()
end

init()

table.insert(quantify.modules, quantify_coll)