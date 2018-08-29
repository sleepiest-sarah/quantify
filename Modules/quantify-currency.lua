quantify_currency = {}

local q = quantify

quantify_currency.Session = {}

quantify_currency.MODULE_KEY = "currency"


local qc = quantify_currency
qc.CURRENCY_GAINED_PREFIX = "currency_gained_*"
qc.CURRENCY_LOST_PREFIX = "currency_lost_*"

function quantify_currency.Session:new(o)
  o = o or {total_money_gained = 0, total_money_spent = 0, delta_money = 0, money_looted = 0, guild_tax = 0, quest_money = 0, auction_money = 0, auction_money_spent = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local money = nil

local mailbox_open = false
local mailbox_items = nil

local auction_open = false

local function init()
  q.current_segment.stats.currency = {}
  q.current_segment.stats.currency.raw = quantify_currency.Session:new()
  q.current_segment.stats.currency.derived_stats = { }
  session = q.current_segment.stats.currency.raw
end

local function playerEnteringWorld()
  money = GetMoney()
end

local function playerMoney()
  local delta_money = GetMoney() - money
  
  if (auction_open and delta_money < 0) then
    session.auction_money_spent = session.auction_money_spent + math.abs(delta_money)
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
          session.auction_money = session.auction_money + delta_money
        end
      end
    end
  end
  
  if (delta_money > 0) then
    session.total_money_gained = session.total_money_gained + delta_money
  else
    session.total_money_spent = session.total_money_spent + math.abs(delta_money)
  end
  
  session.delta_money = session.delta_money + delta_money
  

  
  money = GetMoney()
end

local function playerLootMoney(event, msg)
  local money_string,guild_tax = string.match(msg, "You loot ([%w, ]+) (([%w, ]+) deposited to guild bank)")
  if (guild_tax ~= nil and money_string ~= nil) then
    session.guild_tax =  session.guild_tax + q:getCoppersFromText(guild_tax)
    session.money_looted = session.money_looted + q:getCoppersFromText(money_string)
  else
    money_string = string.match(msg, "You loot ([%w, ]+)")
    if (money_string ~= nil) then
      session.money_looted = session.money_looted + q:getCoppersFromText(money_string)
    end
  end
end

local function playerCurrency(event, msg)
  local currency, amount = string.match(msg, "You receive currency: (.+) x(%d+).")
  if (currency == nil) then
    currency = string.match(msg, "You receive currency: (.+).")
    amount = 1
  end
  
  local name, currentAmount, texture, earnedThisWeek, weeklyMax, totalMax, isDiscovered, rarity = GetCurrencyInfo(currency)
  if (session[qc.CURRENCY_GAINED_PREFIX..name] == nil) then
    session[qc.CURRENCY_GAINED_PREFIX..name] = 0
  end
  session[qc.CURRENCY_GAINED_PREFIX..name] = session[qc.CURRENCY_GAINED_PREFIX..name] + tonumber(amount)
end

local function playerQuestTurnedIn(event, ...)
  local questid, xp, money = unpack({...})
  
  if (money ~= nil) then
    session.quest_money = session.quest_money + money
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
      local _, _, sender, subject, money, CODAmount, _, _, _, _, _, _, _ = GetInboxHeaderInfo(index)
      if (money > 0) then
        local item = {}
        item.money = money
        item.isAuction = string.find(sender, "Auction House") ~= nil and string.find(subject, "Auction successful") ~= nil
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

function quantify_currency:calculateDerivedStats(segment)
  local raw = segment.stats.currency.raw
  
  segment.stats.currency.session_rates = quantify:calculateSegmentRates(segment, segment.stats.currency.raw)
  
  local derived = {}
  derived.pct_money_quest  = (raw.quest_money / raw.total_money_gained) * 100
  derived.pct_money_auction = (raw.auction_money / raw.total_money_gained) * 100
  derived.pct_money_loot = (raw.money_looted / raw.total_money_gained) * 100
  
  segment.stats.currency.derived_stats = derived
end

function quantify_currency:updateStats(segment)
  qc:calculateDerivedStats(segment)
end
 
function quantify_currency:newSegment(previous_seg,new_seg)
  
  init()
  
end

init()

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