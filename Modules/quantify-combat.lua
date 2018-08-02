quantify_combat = {}

local q = quantify

quantify_combat.Session = {}

quantify_combat.MODULE_KEY = "combat"

function quantify_combat.Session:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local function init()

end



function quantify_combat:calculateDerivedStats(segment)

end

function quantify_combat:updateStats(segment)

end
 
function quantify_combat:newSegment(previous_seg,new_seg)
  
  init()
  
end

init()

table.insert(quantify.modules, quantify_combat)
  
  