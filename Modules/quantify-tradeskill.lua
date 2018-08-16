quantify_tradeskill = {}

local q = quantify

quantify_tradeskill.Session = {}

quantify_tradeskill.MODULE_KEY = "tradeskill"
quantify_tradeskill.BFA_TRADE_GOOD_PREFIX = "bfa_trade_good_*"

local qt = quantify_tradeskill

function quantify_tradeskill.Session:new(o)
  o = o or {cloth_looted = 0, tradeskill_looted = 0, enchanting_looted = 0, herb_looted = 0, jewelcrafting_looted = 0, meat_looted = 0, leather_looted = 0, metal_looted = 0 }
  setmetatable(o, self)
  self.__index = self
  return o
end

local session


local function init()
  q.current_segment.stats[qt.MODULE_KEY] = {}
  q.current_segment.stats[qt.MODULE_KEY].raw = qt.Session:new()
  session = q.current_segment.stats[qt.MODULE_KEY].raw
end

function qt:processItem(item,amount) 
  
  if (item.itemType == "Tradeskill") then
    session.tradeskill_looted = session.tradeskill_looted + amount  
    if (item.itemSubType == "Cloth") then
      session.cloth_looted = session.cloth_looted + amount
    elseif (item.itemSubType == "Enchanting") then
      session.enchanting_looted = session.enchanting_looted + amount
    elseif (item.itemSubType == "Herb") then
      session.herb_looted = session.herb_looted + amount
    elseif (item.itemSubType == "Jewelcrafting") then
      session.jewelcrafting_loot = session.jewelcrafting_loot + amount
    elseif (item.itemSubType == "Leather") then
      session.leather_looted = session.leather_looted + amount
    elseif (item.itemSubType == "Meat") then
      session.meat_looted = session.meat_looted + amount
    elseif (item.itemSubType == "Metal & Stone") then
      session.metal_looted = session.metal_looted + amount
    end
  end
  
  if (item.isCraftingReagent and item.expacID == quantify_loot.BFA) then
    local key = qt.BFA_TRADE_GOOD_PREFIX..item.itemName
    if (session[key] == nil) then
      session[key] = 0
    end
    session[key] = session[key] + amount
  end
    
end


function quantify_tradeskill:calculateDerivedStats(segment)

end

function quantify_tradeskill:updateStats(segment)

end
 
function quantify_tradeskill:newSegment(previous_seg,new_seg)
  
  init()
  
end

init()

table.insert(quantify.modules, quantify_tradeskill)