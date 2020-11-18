quantify_currency = {}

local q = quantify


quantify_currency.MODULE_KEY = "currency"


local qc = quantify_currency
qc.CURRENCY_GAINED_PREFIX = "currency_gained_*"
qc.CURRENCY_LOST_PREFIX = "currency_lost_*" 
qc.PICKPOCKET_THRESHOLD_TIME = 2
qc.DURABILITY_CHANGE_TOLERANCE = .5

local money = nil

local mailbox_open = false
local mailbox_items = nil

local auction_open = false
local vendor_open = false

local pickpocket_time = 0
local durability_change_time = 0
local money_change_time = 0
local last_delta_money = 0


qc.CURRENCY_TEMPLATE = {
    name = "",
    gained = 0,
    spent = 0,
    net = 0
  }

local function playerEnteringWorld()
  money = GetMoney()
end

local function updateInventoryDurability()
  durability_change_time = GetTime()
  
  --in retail the player money event fires first
  if (GetTime() - money_change_time < qc.DURABILITY_CHANGE_TOLERANCE) then
    money_change_time = 0
    q:incrementStat("REPAIR_MONEY", math.abs(last_delta_money))
    
    --subtract the repair amount from vendor money spent since it already got added to vendor money spent if we're in here
    q:decrementStat("VENDOR_MONEY_SPENT", math.abs(last_delta_money))
  end
end

local function playerMoney()
  local delta_money = GetMoney() - money
  
  last_delta_money = delta_money
  money_change_time = GetTime()
  
  if (auction_open and delta_money < 0) then
    q:incrementStat("AUCTION_MONEY_SPENT", math.abs(delta_money))
  end
  
  if (vendor_open) then
    if (delta_money > 0) then
      q:incrementStat("VENDOR_MONEY", delta_money)
    elseif (GetTime() - durability_change_time < qc.DURABILITY_CHANGE_TOLERANCE) then
      durability_change_time = 0
      q:incrementStat("REPAIR_MONEY", math.abs(delta_money))
    else
      q:incrementStat("VENDOR_MONEY_SPENT", math.abs(delta_money))
    end
  end
  
  if (mailbox_items ~= nil) then
    for _,item in ipairs(mailbox_items) do
      if (delta_money == item.money) then
        --if money came from one of the player's characters then ignore it
        if (qDb[item.sender]) then
          money = GetMoney()
          return
        end
        
        if (item.isAuction) then
          q:incrementStat("AUCTION_MONEY", delta_money)
        end
      end
    end
  end
  
  if (delta_money > 0) then
    q:incrementStat("TOTAL_MONEY_GAINED", delta_money)
  else
    q:incrementStat("TOTAL_MONEY_SPENT", math.abs(delta_money))
  end
  
  q:incrementStat("DELTA_MONEY", delta_money)

  money = GetMoney()
end

local function playerLootMoney(event, msg)
  local money_string = string.match(msg, "You loot ([%w, ]+)")
  if (money_string ~= nil) then
    local copper = q:getCoppersFromText(money_string)
    q:incrementStat("MONEY_LOOTED", copper)
    
    if (GetTime() - pickpocket_time < qc.PICKPOCKET_THRESHOLD_TIME) then
      q:incrementStat("MONEY_PICKPOCKETED", copper)
    end
  end
end

local function updatePlayerCurrencyData(currencies, name, amount)
  if (not currencies[name]) then
    currencies[name] = q:shallowCopy(qc.CURRENCY_TEMPLATE)
    currencies[name].name = name
  end
  currencies[name].gained = currencies[name].gained + tonumber(amount)
  
  currencies[name].net = currencies[name].gained - currencies[name].spent
end

local function playerCurrency(event, msg)
  local currency, amount = string.match(msg, "You receive currency: (.+) x(%d+).")
  if (currency == nil) then
    currency = string.match(msg, "You receive currency: (.+).")
    amount = 1
  end
  
  local currency_obj = C_CurrencyInfo.GetCurrencyInfoFromLink(currency)
  q:updateStatBlock("currency/data/currency/", updatePlayerCurrencyData, currency_obj.name, amount)

end

local function playerQuestTurnedIn(event, ...)
  local questid, xp, money = unpack({...})
  
  if (money and money > 0) then
    q:incrementStat("QUEST_MONEY", money)
  end
  
end

local function combatLog()
  local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool = CombatLogGetCurrentEventInfo()
  
  if ((event == "SPELL_CAST_SUCCESS" or event == "SPELL_CREATE") and sourceGUID == UnitGUID("player") and spellName == "Pick Pocket") then
    pickpocket_time = GetTime()
  end
end

local function mailbox(event)
  if (event == "MAIL_SHOW") then
    mailbox_open = true
    mailbox_items = {}
  elseif (event == "MAIL_CLOSED") then
    mailbox_open = false
    mailbox_items = nil
  elseif ((event == "MAIL_INBOX_UPDATE" and mailbox_open) or (event == "UPDATE_PENDING_MAIL" and mailbox_items ~= nil)) then
    mailbox_open = false
    local _,numitems = GetInboxNumItems()
    for i=1,numitems do
      local _, _, sender, subject, money, CODAmount, _, _, _, _, _, _, _ = GetInboxHeaderInfo(i)
      if (money > 0) then
        local item = {}
        item.money = money
        if (sender and subject) then
          item.isAuction = string.find(sender, "Auction House") ~= nil and string.find(subject, "Auction successful") ~= nil
        end
        item.sender = sender
        
        table.insert(mailbox_items, item)
      end
    end
  end
end

local function auctionhouse(event)
  if (event == "AUCTION_HOUSE_SHOW") then
    auction_open = true
  elseif (event == "AUCTION_HOUSE_CLOSED") then
    auction_open = false
  end
end

local function merchant(event) 
  if (event == "MERCHANT_SHOW") then
    vendor_open = true
  elseif (event == "MERCHANT_CLOSED") then
    vendor_open = false
  end
end

function quantify_currency:calculateDerivedStats(segment, fullSeg)
  local stats = segment.stats
  
  local play_time = q:getStat(fullSeg, "PLAY_TIME")
  local rates = quantify:calculateSegmentRates(stats, play_time)
  
  stats.quest_money_rate = rates.quest_money
  stats.money_pickpocketed_rate = rates.money_pickpocketed
  stats.repair_money_rate = rates.repair_money
  stats.auction_money_spent_rate = rates.auction_money_spent
  stats.vendor_money_spent_rate = rates.vendor_money_spent
  stats.delta_money_rate = rates.delta_money
  stats.total_money_gained_rate = rates.total_money_gained
  stats.total_money_spent_rate = rates.total_money_spent
  stats.money_looted_rate = rates.money_looted
  
  local currency_gained = {}
  for c,v in pairs(segment.data.currency) do
    currency_gained[c] = v.gained
  end
  stats.currency_gained_rates = quantify:calculateSegmentRates(currency_gained, play_time)
  
  local total_money_gained = stats.total_money_gained == 0 and 1 or stats.total_money_gained
  stats.pct_money_quest  = (stats.quest_money / total_money_gained) * 100
  stats.pct_money_auction = (stats.auction_money / total_money_gained) * 100
  stats.pct_money_loot = (stats.money_looted / total_money_gained) * 100
  stats.pct_money_vendor = (stats.vendor_money / total_money_gained) * 100
  
end

function quantify_currency:updateStats(segment, fullSeg)
  qc:calculateDerivedStats(segment, fullSeg)
end
 
function quantify_currency:newSegment(segment)
  
  segment.data = segment.data or {}
  segment.data.currency = segment.data.currency or {}
  
  segment.stats = q:addKeysLeft(segment.stats,
                 {total_money_gained = 0,
                  total_money_spent = 0,
                  delta_money = 0,
                  money_looted = 0,
                  quest_money = 0,
                  auction_money = 0,
                  auction_money_spent = 0,
                  vendor_money = 0,
                  vendor_money_spent = 0,
                  money_pickpocketed = 0,
                  repair_money = 0})
  
end

table.insert(quantify.modules, quantify_currency)
  
quantify:registerEvent("PLAYER_ENTERING_WORLD", playerEnteringWorld)
quantify:registerEvent("CHAT_MSG_MONEY", playerLootMoney)
quantify:registerEvent("CHAT_MSG_CURRENCY", playerCurrency)
quantify:registerEvent("PLAYER_MONEY", playerMoney)
quantify:registerEvent("QUEST_TURNED_IN", playerQuestTurnedIn)
quantify:registerEvent("MAIL_SHOW", mailbox)
quantify:registerEvent("MAIL_CLOSED", mailbox)
quantify:registerEvent("MAIL_INBOX_UPDATE", mailbox)
quantify:registerEvent("UPDATE_PENDING_MAIL", mailbox)
quantify:registerEvent("AUCTION_HOUSE_SHOW", auctionhouse)
quantify:registerEvent("AUCTION_HOUSE_CLOSED", auctionhouse)
quantify:registerEvent("MERCHANT_SHOW", merchant)
quantify:registerEvent("MERCHANT_CLOSED", merchant)
quantify:registerEvent("COMBAT_LOG_EVENT_UNFILTERED", combatLog)
quantify:registerEvent("UPDATE_INVENTORY_DURABILITY", updateInventoryDurability)