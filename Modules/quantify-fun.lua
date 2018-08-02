quantify_fun = {}

local q = quantify

quantify_fun.Session = {}

quantify_fun.MODULE_KEY = "fun"

function quantify_fun.Session:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local function init()

end



function quantify_fun:calculateDerivedStats(segment)

end

function quantify_fun:updateStats(segment)

end
 
function quantify_fun:newSegment(previous_seg,new_seg)
  
  init()
  
end

init()

table.insert(quantify.modules, quantify_fun)
  
  