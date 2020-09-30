quantify_tradeskill = {}

local qt = quantify_tradeskill

local q = quantify

qt.Session = {}

qt.MODULE_KEY = "tradeskill"
qt.BFA_TRADE_GOOD_PREFIX = "bfa_trade_good_*"
qt.CLASSIC_TRADE_GOOD_PREFIX = "classic_trade_good_*"



function quantify_tradeskill.Session:new(o)
  o = o or {cloth_looted = 0, tradeskill_looted = 0, enchanting_looted = 0, herb_looted = 0, jewelcrafting_looted = 0, meat_looted = 0, leather_looted = 0, metal_looted = 0, cooking_looted = 0, classic_fish_looted = 0}
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
  --q:printTable(item)
  
  --Tradeskill item type and subtypes are not in Classic
  if (item.itemType == "Tradeskill" or item.itemType == "Trade Goods") then
    session.tradeskill_looted = session.tradeskill_looted + amount  
    if (item.itemSubType == "Cloth") then
      session.cloth_looted = session.cloth_looted + amount
    elseif (item.itemSubType == "Enchanting") then
      session.enchanting_looted = session.enchanting_looted + amount
    elseif (item.itemSubType == "Herb") then
      session.herb_looted = session.herb_looted + amount
    elseif (item.itemSubType == "Jewelcrafting") then
      session.jewelcrafting_looted = session.jewelcrafting_looted + amount
    elseif (item.itemSubType == "Leather") then
      session.leather_looted = session.leather_looted + amountw
    elseif (item.itemSubType == "Meat") then
      session.meat_looted = session.meat_looted + amount
    elseif (item.itemSubType == "Metal & Stone") then
      session.metal_looted = session.metal_looted + amount
    elseif (item.itemSubType == "Cooking") then
      session.cooking_looted = session.cooking_looted + amount
    end
  end
  
  if (item.itemType == "Consumable" and q.isClassic and string.find(item.itemName, "Raw")) then
    session.classic_fish_looted = session.classic_fish_looted + amount
    session.tradeskill_looted = session.tradeskill_looted + amount  
  end
  
  if (item.isCraftingReagent or (q.isClassic and item.itemType == "Trade Goods")) then
    local key = nil
    if (item.expacID == quantify_loot.BFA) then
      key = qt.BFA_TRADE_GOOD_PREFIX..item.itemName
    elseif (item.expacID == quantify_loot.CLASSIC) then
      key = qt.CLASSIC_TRADE_GOOD_PREFIX..item.itemName
    end
    
    if (key) then
      if (session[key] == nil) then
        session[key] = 0
      end
      session[key] = session[key] + amount
    end
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