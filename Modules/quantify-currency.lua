quantify_currency = {}

local q = quantify

quantify_currency.Session = {}

quantify_currency.MODULE_KEY = "currency"


local qc = quantify_currency
qc.CURRENCY_GAINED_PREFIX = "currency_gained_*"
qc.CURRENCY_LOST_PREFIX = "currency_lost_*"

function quantify_currency.Session:new(o)
  o = o or {total_money_gained = 0, total_money_spent = 0, delta_money = 0, money_looted = 0, guild_tax = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local money = nil

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

function quantify_currency:calculateDerivedStats(segment)
  segment.stats.currency.session_rates = quantify:calculateSegmentRates(segment, segment.stats.currency.raw)
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