quantify_misc = {}

local q = quantify

quantify_misc.Session = {}

quantify_misc.MODULE_KEY = "miscellaneous"

function quantify_misc.Session:new(o)
  o = o or {jumps = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local function init()
  q.current_segment.stats.miscellaneous = {}
  q.current_segment.stats.miscellaneous.raw = quantify_misc.Session:new()
  q.current_segment.stats.miscellaneous.derived_stats = { }
  session = q.current_segment.stats.miscellaneous.raw
end

local function jump()
  if (quantify_state:CanPlayerJump()) then
    session.jumps = session.jumps + 1
  end
end

function quantify_misc:calculateDerivedStats(segment)
  local raw = segment.stats.miscellaneous.raw
  
  segment.stats.miscellaneous.session_rates = quantify:calculateSegmentRates(segment, segment.stats.miscellaneous.raw)
end

function quantify_misc:updateStats(segment)
  quantify_misc:calculateDerivedStats(segment)
end
 
function quantify_misc:newSegment(previous_seg,new_seg)
  init()
end

table.insert(quantify.modules, quantify_misc)

q:hookSecureFunc("JumpOrAscendStart", jump)