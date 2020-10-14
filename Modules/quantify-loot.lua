quantify_loot = {}

local q = quantify
local ql = quantify_loot

quantify_loot.MODULE_KEY = "loot"
quantify_loot.INV_TYPE_PREFIX = "inv_type_*"
quantify_loot.UPGRADE_PREFIX = "upgrade_received_*"

ql.POOR = 0
ql.COMMON = 1
ql.UNCOMMON = 2
ql.RARE = 3
ql.EPIC = 4

ql.VANILLA = 1
ql.BC = 2
ql.WOTLK = 3
ql.CATA = 4
ql.WOD = 5
ql.LEGION = 6
ql.BFA = 7
ql.CLASSIC = 254

function quantify_loot.Session:new(o)
  o = o or 
  setmetatable(o, self)
  self.__index = self
  return o
end

local session



local item_queue = {}


local function init()
  q.current_segment.stats[ql.MODULE_KEY] = {}
  q.current_segment.stats[ql.MODULE_KEY].raw = ql.Session:new()
  session = q.current_segment.stats[ql.MODULE_KEY].raw
end

local function processItem(item,amount) 
  if (item.isCraftingReagent) then
    return
  end
  
  --item types
  if (item.itemType == "Armor" or item.itemType == "Weapon") then
    session.gear_loot = session.gear_loot + amount
  
    --print(item:isEquippable(),item:isILevelUpgrade())
    if (item:isEquippable() and item:isILevelUpgrade()) then
      session.overall_ilevel_upgrades = session.overall_ilevel_upgrades + 1
      local k = ql.UPGRADE_PREFIX..quantify_state:getPlayerSpecClass()
      if (session[k] == nil) then
        session[k] = 0
      end
      session[k] = session[k] + 1
    end
    
    if (item.itemSubType == "Cloth") then
      session.cloth_gear_loot = session.cloth_gear_loot + amount
    elseif (item.itemSubType == "Leather") then
      session.leather_gear_loot = session.leather_gear_loot + amount
    elseif (item.itemSubType == "Mail") then
      session.mail_gear_loot = session.mail_gear_loot + amount
    elseif (item.itemSubType == "Plate") then
      session.plate_gear_loot = session.plate_gear_loot + amount
    end
  end
    
  --item subtypes
  if (item.itemSubType == "Junk") then
    session.junk_looted = session.junk_looted + amount
    session.junk_looted_value = session.junk_looted_value + (item.itemSellPrice * amount)
  end
  
  --item slots
  if (item.itemEquipLoc ~= nil and item.itemEquipLoc ~= "") then
    local key = ql.INV_TYPE_PREFIX..item:getLocalizedInvTypeString()
    if (session[key] == nil) then
      session[key] = 0
    end
    session[key] = session[key] + amount
  end
  
  --item quality
  if (item.itemRarity == ql.POOR) then
    session.poor_loot = session.poor_loot + amount
    if (item.expacID == ql.BFA) then
      session.bfa_poor_loot = session.bfa_poor_loot + amount
    end
  elseif (item.itemRarity == ql.UNCOMMON) then
    session.uncommon_loot = session.uncommon_loot + amount
    if (item.expacID == ql.BFA) then
      session.bfa_uncommon_loot = session.bfa_uncommon_loot + amount
    end
  elseif (item.itemRarity == ql.COMMON) then
    session.common_loot = session.common_loot + amount
    if (item.expacID == ql.BFA) then
      session.bfa_common_loot = session.bfa_common_loot + amount
    end
  elseif (item.itemRarity == ql.RARE) then
    session.rare_loot = session.rare_loot + amount
    if (item.expacID == ql.BFA) then
      session.bfa_rare_loot = session.bfa_rare_loot + amount
    end
  elseif (item.itemRarity == ql.EPIC) then
    session.epic_loot = session.epic_loot + amount
    if (item.expacID == ql.BFA) then
      session.bfa_epic_loot = session.bfa_epic_loot + amount
    end
  end
end

local function getItemInfoReceived(event, itemId)
  if (item_queue[itemId] ~= nil) then
    local item = q.Item:new(itemId)
    processItem(item,item_queue[itemId].amount)
    quantify_tradeskill:processItem(item,item_queue[itemId].amount)
    item_queue[itemId] = nil
  end
end

local function itemReceived(itemLink,amount)
  local item = q.Item:new(itemLink)
  if (item == nil) then
    local id = q:getItemId(itemLink)
    if (item_queue[id] == nil) then
      item_queue[id] = {link = itemLink, amount = 0}
    end
    item_queue[id].amount = item_queue[id].amount + amount
  else
    processItem(item,amount)
    quantify_tradeskill:processItem(item,amount)
  end   
end

local function chatMsgLoot(event, msg, player, chatLineId)
  local loot = string.match(msg,"You receive loot: (.+)x?(%d*).")
  local amount = string.match(msg, "You receive loot: .+x(%d+).")
  amount = tonumber(amount) or 1
  
  if (loot ~= nil) then
    session.total_items_looted = session.total_items_looted + 1
    
    itemReceived(loot,amount)
  end
end

local function questLootReceived(event, questID, itemLink, quantity)
  itemReceived(itemLink,quantity)
end

function quantify_loot:calculateDerivedStats(segment)
  local rates_to_calc = {}
  table.foreach(segment.stats.loot.raw,function(k,v) if (string.find(k,ql.UPGRADE_PREFIX)) then rates_to_calc[k] = v end end)
  
  segment.stats.loot.session_rates =  q:calculateSegmentRates(segment, rates_to_calc, 86400)
  
  local derived = {}
  local sum = segment.stats.loot.raw.poor_loot + segment.stats.loot.raw.uncommon_loot + segment.stats.loot.raw.common_loot + segment.stats.loot.raw.rare_loot + segment.stats.loot.raw.epic_loot
  derived["pct_loot_quality_*poor"] = (segment.stats.loot.raw.poor_loot / sum) * 100
  derived["pct_loot_quality_*common"] = (segment.stats.loot.raw.common_loot / sum) * 100
  derived["pct_loot_quality_*uncommon"] = (segment.stats.loot.raw.uncommon_loot / sum) * 100
  derived["pct_loot_quality_*rare"] = (segment.stats.loot.raw.rare_loot / sum) * 100
  derived["pct_loot_quality_*epic"] = (segment.stats.loot.raw.epic_loot / sum) * 100
  
  sum = segment.stats.loot.raw.cloth_gear_loot + segment.stats.loot.raw.leather_gear_loot + segment.stats.loot.raw.mail_gear_loot + segment.stats.loot.raw.plate_gear_loot
  derived["pct_armor_class_*Cloth"] = (segment.stats.loot.raw.cloth_gear_loot / sum) * 100
  derived["pct_armor_class_*Leather"] = (segment.stats.loot.raw.leather_gear_loot / sum) * 100
  derived["pct_armor_class_*Mail"] = (segment.stats.loot.raw.mail_gear_loot / sum) * 100
  derived["pct_armor_class_*Plate"] = (segment.stats.loot.raw.plate_gear_loot / sum) * 100
  
  segment.stats.loot.derived_stats = derived
end

function quantify_loot:updateStats(segment)
  ql:calculateDerivedStats(segment)
end
 
function quantify_loot:newSegment(segment)
  
  segment.stats = segment.stats or 
                   {total_items_looted = 0,
                    gear_loot = 0,
                    junk_looted = 0,
                    junk_looted_value = 0,
                    poor_loot = 0,
                    common_loot = 0,
                    uncommon_loot = 0,
                    rare_loot = 0,
                    epic_loot = 0,
                    bfa_poor_loot = 0,
                    bfa_common_loot = 0,
                    bfa_uncommon_loot = 0,
                    bfa_rare_loot = 0,
                    bfa_epic_loot = 0,
                    cloth_gear_loot = 0,
                    leather_gear_loot = 0,
                    mail_gear_loot = 0,
                    plate_gear_loot = 0,
                    overall_ilevel_upgrades = 0,
                    inv_type_looted = {},
                    pct_armor_class_looted = {},
                    pct_loot_quality = {},
                    upgrades_received = {}}
  
end

table.insert(quantify.modules, quantify_loot)
  
q:registerEvent("CHAT_MSG_LOOT", chatMsgLoot)
q:registerEvent("GET_ITEM_INFO_RECEIVED", getItemInfoReceived)

if (q.isRetail) then
  q:registerEvent("QUEST_LOOT_RECEIVED", questLootReceived)
end

function ql:tests()
  local axe = q.Item:new(13039)
  q:printTable(axe)
  processItem(axe,1)
end