quantify_loot = {}

local q = quantify
local ql = quantify_loot

quantify_loot.MODULE_KEY = "loot"

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


local item_queue = {}

local function processItem(item,amount) 
  if (item.isCraftingReagent) then
    return
  end
  
  --item types
  if (item.itemType == "Armor" or item.itemType == "Weapon") then
    q:incrementStat("GEAR_LOOT", amount)
  
    if (item:isEquippable() and item:isILevelUpgrade()) then
      q:incrementStat("OVERALL_ILEVEL_UPGRADES", 1)
      local k = quantify_state:getPlayerSpecClass()
      q:incrementStatByPath("loot/stats/upgrades_received/"..k,1)
    end
    
    if (item.itemSubType == "Cloth") then
      q:incrementStat("CLOTH_GEAR_LOOT",amount)
    elseif (item.itemSubType == "Leather") then
      q:incrementStat("LEATHER_GEAR_LOOT",amount)
    elseif (item.itemSubType == "Mail") then
      q:incrementStat("MAIL_GEAR_LOOT",amount)
    elseif (item.itemSubType == "Plate") then
      q:incrementStat("PLATE_GEAR_LOOT",amount)
    end
  end
    
  --item subtypes
  if (item.itemSubType == "Junk") then
    q:incrementStat("JUNK_LOOTED",amount)
    q:incrementStat("JUNK_LOOTED_VALUE",(item.itemSellPrice * amount))
  end
  
  --item slots
  if (item.itemEquipLoc ~= nil and item.itemEquipLoc ~= "") then
    local key = item:getLocalizedInvTypeString()
    q:incrementStatByPath("loot/stats/inv_type_looted/"..key,amount)
  end
  
  --item quality
  if (item.itemRarity == ql.POOR) then
    q:incrementStat("POOR_LOOT",amount)
    if (item.expacID == ql.BFA) then
      q:incrementStat("BFA_POOR_LOOTED",amount)
    end
  elseif (item.itemRarity == ql.UNCOMMON) then
    q:incrementStat("UNCOMMON_LOOT",amount)
    if (item.expacID == ql.BFA) then
      q:incrementStat("BFA_UNCOMMON_LOOT",amount)
    end
  elseif (item.itemRarity == ql.COMMON) then
    session.common_loot = session.common_loot + amount
    q:incrementStat("COMMON_LOOT",amount)
    if (item.expacID == ql.BFA) then
      q:incrementStat("BFA_COMMON_LOOT",amount)
    end
  elseif (item.itemRarity == ql.RARE) then
    q:incrementStat("RARE_LOOT",amount)
    if (item.expacID == ql.BFA) then
      q:incrementStat("BFA_RARE_LOOT",amount)
    end
  elseif (item.itemRarity == ql.EPIC) then
    q:incrementStat("EPIC_LOOT",amount)
    if (item.expacID == ql.BFA) then
      q:incrementStat("BFA_EPIC_LOOT",amount)
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
    q:incrementStat("TOTAL_ITEMS_LOOTED",amount)
    
    itemReceived(loot,amount)
  end
end

local function questLootReceived(event, questID, itemLink, quantity)
  itemReceived(itemLink,quantity)
end

function quantify_loot:calculateDerivedStats(segment, fullSeg)
  local play_time = q:getStat(fullSeg, "PLAY_TIME")
  segment.stats.upgrades_received_rates =  q:calculateSegmentRates(segment.stats.upgrades_received, play_time, 86400)
  
  local sum = segment.stats.poor_loot + segment.stats.uncommon_loot + segment.stats.common_loot + segment.stats.rare_loot + segment.stats.epic_loot
  sum = sum == 0 and 1 or sum
  segment.stats.pct_loot_quality = {}
  segment.stats.pct_loot_quality["poor"] = (segment.stats.poor_loot / sum) * 100
  segment.stats.pct_loot_quality["common"] = (segment.stats.common_loot / sum) * 100
  segment.stats.pct_loot_quality["uncommon"] = (segment.stats.uncommon_loot / sum) * 100
  segment.stats.pct_loot_quality["rare"] = (segment.stats.rare_loot / sum) * 100
  segment.stats.pct_loot_quality["epic"] = (segment.stats.epic_loot / sum) * 100
  
  sum = segment.stats.cloth_gear_loot + segment.stats.leather_gear_loot + segment.stats.mail_gear_loot + segment.stats.plate_gear_loot
  sum = sum == 0 and 1 or sum
  segment.stats.pct_armor_class_looted = {}
  segment.stats.pct_armor_class_looted["Cloth"] = (segment.stats.cloth_gear_loot / sum) * 100
  segment.stats.pct_armor_class_looted["Leather"] = (segment.stats.leather_gear_loot / sum) * 100
  segment.stats.pct_armor_class_looted["Mail"] = (segment.stats.mail_gear_loot / sum) * 100
  segment.stats.pct_armor_class_looted["Plate"] = (segment.stats.plate_gear_loot / sum) * 100
  
end

function quantify_loot:updateStats(segment, fullSeg)
  ql:calculateDerivedStats(segment, fullSeg)
end
 
function quantify_loot:newSegment(segment)
  
  segment.stats = q:addKeysLeft(segment.stats,
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
                    upgrades_received = {}})
  
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