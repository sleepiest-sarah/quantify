quantify_chat = {}

local q = quantify

quantify_chat.Session = {}

quantify_chat.MODULE_KEY = "chat"

function quantify_chat.Session:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local function init()

end



function quantify_chat:calculateDerivedStats(segment)

end

function quantify_chat:updateStats(segment)

end
 
function quantify_chat:newSegment(previous_seg,new_seg)
  
  init()
  
end

init()

table.insert(quantify.modules, quantify_chat)
  
  