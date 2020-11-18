quantify_reputation = {}

local q = quantify

quantify_reputation.MODULE_KEY = "reputation"

quantify_reputation.FACTION_CHANGE_DELTA_PATH = "reputation/data/faction_change_delta/"
quantify_reputation.FACTION_TIME_NEUTRAL_PATH = "reputation/stats/faction_time_neutral/"
quantify_reputation.FACTION_TIME_EXALTED_PATH = "reputation/stats/faction_time_exalted/"
quantify_reputation.FACTION_STANDING_REMAINING_EXALTED_PATH = "reputation/stats/faction_remaining_exalted/"
quantify_reputation.FACTION_STANDING_REMAINING_NEXT_RANK_PATH = "reputation/stats/faction_remaining/"
quantify_reputation.FACTION_STANDING_REMAINING_TIME_PATH = "reputation/stats/faction_remaining_time/"

local qr = quantify_reputation

local initialized = false
local dirty_factions = {}

qr.factions = {}

qr.TOTAL_EXALTED_REP = 42000
qr.TOTAL_REVERED_REP = 21000
qr.TOTAL_HONORED_REP = 9000
qr.TOTAL_FRIENDLY_REP = 3000

local function processFaction(id)
  local faction = q.Faction:new(GetFactionInfoByID(id))
  if (faction.name and not faction.isHeader or faction.hasRep) then
    qr.factions[faction.name] = faction
  end
end

local function processFactions()
  if (not initialized) then
    ExpandAllFactionHeaders()
    for i=1,GetNumFactions() do
      local name, _, _, _, _, _, _, _, _,_, _, _, _, factionID = GetFactionInfo(i)
      if (factionID) then
        processFaction(factionID)
      end
    end
    initialized = GetNumFactions() > 0
    dirty_factions = {}
  elseif (table.maxn(dirty_factions) >= 1) then
    for i,id in ipairs(dirty_factions) do
      processFaction(id)
    end
    dirty_factions = {}
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
      q:incrementStatByPath(qr.FACTION_CHANGE_DELTA_PATH..faction, amount)
    end
  end
end

local function playerLogin()
  processFactions()
end


function quantify_reputation:calculateDerivedStats(segment, fullSeg)
    local stats = segment.stats
    local play_time = q:getStat(fullSeg, "PLAY_TIME")
    local rates = q:calculateSegmentRates(segment.data.faction_change_delta, play_time, 86400) --per day
    segment.stats.faction_change_delta_rate = rates
    
    for faction_key, faction in pairs(qr.factions) do
      local r = rates[faction_key]
      local valid_r = r and (q:isInf(r) or q:isNan(r) or r <= 0)
      
      --time until neutral
      if (not faction.atWarWith and faction.standingId < q.Faction.NEUTRAL) then
        stats.faction_time_neutral[faction_key] = valid_r and (math.abs(faction.barValue) / r) * 86400 or math.huge
      else
        stats.faction_time_neutral[faction_key] = nil
      end
      
      if (not faction.atWarWith and faction.standingId >= q.Faction.NEUTRAL and faction.standingId < q.Faction.EXALTED) then
        
        --rep until exalted
        local remaining_rep = qr.TOTAL_EXALTED_REP - faction.barValue
        stats.faction_remaining_exalted[faction_key] = remaining_rep
        
        --time until exalted
        stats.faction_time_exalted[faction_key] = valid_r and (remaining_rep / r) * 86400 or math.huge

        if (valid_r and faction.standingId == q.Faction.NEUTRAL) then
          remaining_rep = qr.TOTAL_FRIENDLY_REP - faction.barValue
          stats.faction_remaining[faction_key] = remaining_rep
          stats.faction_remaining_time[faction_key] = (remaining_rep / r) * 86400
        elseif (valid_r and faction.standingId == q.Faction.FRIENDLY) then
          remaining_rep = qr.TOTAL_HONORED_REP - faction.barValue
          stats.faction_remaining[faction_key] = remaining_rep
          stats.faction_remaining_time[faction_key] = (remaining_rep / r) * 86400
        elseif (valid_r and faction.standingId == q.Faction.HONORED) then
          remaining_rep = qr.TOTAL_REVERED_REP - faction.barValue
          stats.faction_remaining[faction_key] = remaining_rep
          stats.faction_remaining_time[faction_key] = (remaining_rep / r) * 86400
        else
          stats.faction_remaining[faction_key] = nil
          stats.faction_remaining_time[faction_key] = nil
        end
      else
        stats.faction_remaining_exalted[faction_key] = nil
        stats.faction_remaining[faction_key] = nil
        stats.faction_remaining_time[faction_key] = nil
      end
    end
end

function quantify_reputation:updateStats(segment, fullSeg)
  processFactions()
  
  qr:calculateDerivedStats(segment, fullSeg)
end
 
function quantify_reputation:newSegment(segment)
  segment.data = segment.data or {}
  segment.data.faction_change_delta = segment.data.faction_change_delta or {}
  
  segment.stats = q:addKeysLeft(segment.stats,
                     {faction_remaining = {},
                      faction_remaining_time = {},
                      faction_time_neutral = {},
                      faction_time_exalted = {},
                      faction_remaining_exalted = {}
                      })
end

table.insert(quantify.modules, quantify_reputation)

quantify:registerEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", combatFactionChange)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)