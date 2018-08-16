quantify_reputation = {}

local q = quantify

quantify_reputation.Session = {}

quantify_reputation.MODULE_KEY = "reputation"

local qr = quantify_reputation

function quantify_reputation.Session:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session


local function init()
  q.current_segment.stats[qr.MODULE_KEY] = {}
  q.current_segment.stats[qr.MODULE_KEY].raw = qr.Session:new()
  session = q.current_segment.stats[qr.MODULE_KEY].raw
end

local function combatFactionChange(event, msg)
  
end


function quantify_reputation:calculateDerivedStats(segment)

end

function quantify_reputation:updateStats(segment)

end
 
function quantify_reputation:newSegment(previous_seg,new_seg)
  
  init()
  
end

init()

table.insert(quantify.modules, quantify_reputation)

quantify:registerEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", combatFactionChange)