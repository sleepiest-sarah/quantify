quantify_reputation = {}

local q = quantify

quantify_reputation.Session = {}

quantify_reputation.MODULE_KEY = "reputation"
quantify_reputation.FACTION_CHANGE_DELTA_PREFIX = "faction_delta_*"
quantify_reputation.FACTION_TIME_NEUTRAL_PREFIX = "faction_time_neutral_*"
quantify_reputation.FACTION_TIME_EXALTED_PREFIX = "faction_time_exalted_*"
quantify_reputation.FACTION_STANDING_REMAINING_EXALTED_PREFIX = "faction_remaining_exalted_*"

local qr = quantify_reputation

function quantify_reputation.Session:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session,tally
local dirty_factions

qr.factions = {}

qr.TOTAL_EXALTED_REP = 42000

local function init()
  q.current_segment.stats[qr.MODULE_KEY] = {}
  q.current_segment.stats[qr.MODULE_KEY].raw = qr.Session:new()
  q.current_segment.stats[qr.MODULE_KEY].tally = {hated = 0, hostile = 0, unfriendly = 0, neutral = 0, friendly = 0, honored = 0, revered = 0, exalted = 0}
  tally = q.current_segment.stats[qr.MODULE_KEY].tally
  session = q.current_segment.stats[qr.MODULE_KEY].raw
end

local function processFaction(id)
  local faction = q.Faction:new(GetFactionInfo(id))
  if (faction.name and not faction.isHeader or faction.hasRep) then
    qr.factions[faction.name] = faction
    if (faction.standingId == q.Faction.HATED) then
      tally.hated = tally.hated + 1
    elseif (faction.standingId == q.Faction.HOSTILE) then
      tally.hostile = tally.hostile + 1
    elseif (faction.standingId == q.Faction.UNFRIENDLY) then
      tally.unfriendly = tally.unfriendly + 1
    elseif (faction.standingId == q.Faction.NEUTRAL) then
      tally.neutral = tally.neutral + 1
    elseif (faction.standingId == q.Faction.FRIENDLY) then
      tally.friendly = tally.friendly + 1
    elseif (faction.standingId == q.Faction.HONORED) then
      tally.honored = tally.honored + 1
    elseif (faction.standingId == q.Faction.REVERED) then
      tally.revered = tally.revered + 1
    elseif (faction.standingId == q.Faction.EXALTED) then
      tally.exalted = tally.exalted + 1
    end
  end
end

local function processFactions()
  ExpandAllFactionHeaders()
  if (dirty_factions == nil) then
    for i=1,GetNumFactions() do
      processFaction(i)
    end    
  elseif (table.maxn(dirty_factions) >= 1) then
    for _,i in ipairs(dirty_factions) do
      processFaction(i)
    end
  end
end

local function combatFactionChange(event, msg)
  
  if (dirty_factions == nil) then
    dirty_factions = {}
  end
  
  local faction = string.match(msg, "Reputation with (.*) decreased")
  if (faction == nil) then
    faction = string.match(msg, "Reputation with (.*) increased")
  end
  
  if (faction == "Guild") then
    return
  end
  
  if (faction ~= nil) then
    if (qr.factions[faction] == nil) then --newly discovered faction so reprocess everything
      dirty_factions = nil
    else
      table.insert(dirty_factions, qr.factions[faction].factionId)
    end

    local amount = string.match(msg, "increased by (%d+)")
    if (amount == nil) then
      amount = string.match(msg, "decreased by (%d+)")
      amount = tonumber(amount) * -1
    end
    
    if (amount ~= nil) then
      local key = qr.FACTION_CHANGE_DELTA_PREFIX..faction
      if (session[key] == nil) then
        session[key] = 0
      end
      session[key] = session[key] + amount
    end
  end
end

local function playerLogin()
  processFactions()
end


function quantify_reputation:calculateDerivedStats(segment)
  --really shouldn't be checking the viewing segment but it's a quick workaround so we don't calculate these stats for the account
  if (segment == q.current_segment or q:getViewingSegmentKey() == quantify_state:getPlayerNameRealm()) then  
    local derived = {}
    local rates = q:calculateSegmentRates(segment, segment.stats.reputation.raw, 86400) --per day

    for k,r in pairs(rates) do
      local faction_key = string.sub(k,string.len(qr.FACTION_CHANGE_DELTA_PREFIX) + 1)
      local faction = qr.factions[faction_key]
      
      if (faction) then
      
        if (q:isInf(r) or q:isNan(r) or r <= 0) then
          rates[faction_key] = nil
        else
        
          --time until neutral
          if (not faction.atWarWith and faction.standingId < q.Faction.NEUTRAL) then
            derived[qr.FACTION_TIME_NEUTRAL_PREFIX..faction_key] = (math.abs(faction.barValue) / r) * 86400
          end
          
          
          if (not faction.atWarWith and faction.standingId >= q.Faction.NEUTRAL and faction.standingId < q.Faction.EXALTED) then
            --rep until exalted
            local remaining_rep = qr.TOTAL_EXALTED_REP - faction.barValue
            derived[qr.FACTION_STANDING_REMAINING_EXALTED_PREFIX..faction_key] = remaining_rep
            
            --time until exalted
            derived[qr.FACTION_TIME_EXALTED_PREFIX..faction_key] = (remaining_rep / r) * 86400

          end
        end
      end
      
    end
    
    segment.stats.reputation.derived_stats = derived
    segment.stats.reputation.session_rates = rates
  end
end

function quantify_reputation:updateStats(segment)
  processFactions()
  
  qr:calculateDerivedStats(segment)
end
 
function quantify_reputation:newSegment(previous_seg,new_seg)
  
  init()
  
end

init()

table.insert(quantify.modules, quantify_reputation)

quantify:registerEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", combatFactionChange)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)