local q = quantify

function q:printTable(t)
  for k,v in pairs(t) do
    if (type(v) == "table") then
      print(string.format("%s:", k))
      q:printTable(v)
    else
      print(string.format("%s: %s", k, tostring(v)))
    end
  end
end

function q:printModule(mod, segment)
  local m = segment.stats[mod]
  print(mod)
  for statgrouptitle,statgroup in pairs(m) do
    print(string.format("    %s", statgrouptitle))
    for k,v in pairs(statgroup) do
      if (type(v) == "number") then
        print(string.format("        %s: %f", k, v))
      end
    end
  end
end

function q:printSegment(segment)
  for title, m in pairs(segment.stats) do
    print(title)
    for statgrouptitle,statgroup in pairs(m) do
      print(string.format("    %s", statgrouptitle))
      for k,v in pairs(statgroup) do
        if (type(v) == "table") then
          print(k)
          q:printTable(v)
        else
          print(string.format("        %s: %f", k, v))
        end
      end
    end
  end
end

function q:calculateSegmentRates(segment, segment_stats, period)
  period = period or 3600
  
  local duration
  if (segment:duration() ~= nil) then
    duration = segment:duration()
  else
    local start = segment.start_time or GetTime()
    local endt = segment.end_time or GetTime()
    duration = endt - start
  end
  
  local session_rates = {}
  for k,v in pairs(segment_stats) do
    if (type(v) == "number") then
      session_rates[k] = (v/duration) * period
    end
  end
  
  return session_rates
end

function q:addTables(a,b)
  --b expected to be the most up to date in the case of missing keys
  for k,v in pairs(b) do
    if (type(v) == "table") then
      if (a[k] == nil) then
        a[k] = {}
      end
      q:addTables(a[k], v)
    elseif (tonumber(v) ~= nil) then
      if (a[k] == nil) then
        a[k] = 0
      end
      a[k] = a[k] + tonumber(v)
    end
  end
  
  return a
end

function q:subtractTables(b,a)
  for k,v in pairs(b) do
    if (type(v) == "table") then
      if (a[k] == nil) then
        a[k] = {}
      end
      q:subtractTables(v,a[k])
    elseif (tonumber(v) ~= nil) then
      if (a[k] == nil) then
        a[k] = 0
      end
      a[k] = tonumber(v) - a[k]
    end
  end
  
  return a  
end


function q:shallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--doesn't handle metadata
function q:deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[q:deepcopy(orig_key)] = q:deepcopy(orig_value)
        end
        --setmetatable(copy, q:deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function q:getSegmentList()
  local segments = {}
  if (qDb ~= nil) then
    for k,v in pairs(qDb) do
      if (type(v) == "table") then
        segments[k] = v
      end
    end
  end
  
  for i,v in ipairs(q.segments) do
    segments["Segment "..i] = v
  end
  
  return segments
end

--flattens stat table
function q:getAllStats(segment)
  local stats = {}
  for _,group in pairs(segment.stats) do
    for stattypek,stattype in pairs(group) do
      for k,v in pairs(stattype) do
        stats[stattypek..":"..k] = v
      end
    end
  end
     
  return stats
end

function q:convertSavedSegment(segment)
  local cseg = q.Segment:new()
  cseg._duration = segment.time
  
  for k,v in pairs(segment.stats) do
    cseg.stats[k] = {}
    cseg.stats[k].raw = v
  end
  
  for _,m in ipairs(q.modules) do
    if (cseg.stats[m.MODULE_KEY] == nil) then
      cseg.stats[m.MODULE_KEY] = {}
      cseg.stats[m.MODULE_KEY].raw = m.Session:new()
    end
    
    --add any stats that are missing from the saved segment
    local empty_stats = m.Session:new()
    for s,v in pairs(empty_stats) do
      if (cseg.stats[m.MODULE_KEY].raw[s] == nil) then
        cseg.stats[m.MODULE_KEY].raw[s] = v
      end
    end
    
    m:updateStats(cseg)
  end
  
  return cseg
end

function q:getSingleModuleSegment(key,segment)
  local new_seg = q:shallowCopy(segment)
  
  new_seg.stats = {}
  new_seg.stats[key] = segment.stats[key]
  
  return new_seg 
end

function q:getModuleKeys()
  local keys = {}
  
  for _,m in ipairs(q.modules) do
    table.insert(keys, m.MODULE_KEY)
  end
  
  return keys
end

function q:getShorthandInteger(n,precision,decimal)
  precision = precision or 1
  
  local format = "%." .. tostring(precision) .. "f"
  
  local res
  if (not decimal) then
    n = math.floor(n)
  end
  if (n > 1000 and n < 1000000) then
    n = (n * 1.0) / 1000
    res = string.format(format,n).."k"
  elseif (n > 1000000) then
    n = (n * 1.0) / 1000000
    res = string.format(format,n).."m"
  elseif (decimal) then
    res = string.format(format,n)
  else
    res = n
  end  
  
  return res
end

function q:getCurrencyString(n)
    local copper,silver, gold,res
    if (math.abs(n) > 10000) then
      gold = math.floor(n/10000)
      silver = math.floor((n % 10000) / 100)
      copper = math.floor(n) % 100
      res = tostring(gold).."g"..tostring(silver).."s"..tostring(copper).."c"
    elseif (math.abs(n) > 1000) then
      silver = math.floor(n/100)
      copper = math.floor(n) % 100
      res = tostring(silver).."s"..tostring(copper).."c"
    else
      res = tostring(math.floor(n)).."c"
    end
    
    return res
end

function q:getFormattedUnit(n,units,abbr)
  if (units == "string") then
    return n
  end
  
  if (q:isInf(n) or q:isNan(n)) then
    n = 0
  end
  
  local res
  if (units == "integer") then
    res = q:getShorthandInteger(n)
  elseif (units == "time") then
    local min,sec,hour
    if (n < 60) then
      n = math.floor(n)
      res = tostring(n).."s"
    elseif (n >= 60 and n < 3600) then
      min = math.floor(n/60)
      sec = math.floor(n) % 60
      res = tostring(min).."m"..tostring(sec).."s"
    elseif (n >= 3600) then
      hour = math.floor(n/3600)
      min = math.floor((n % 3600)/60)
      sec = math.floor(n) % 60
      res = tostring(hour).."h"..tostring(min).."m"..tostring(sec).."s"
    end
    
    if (abbr and hour) then
      res = tostring(hour).."h"..tostring(min).."m"
    end
  elseif (units == "decimal") then
    res = string.format("%.2f",n)
  elseif (units == "integer/hour" or units == "integer/day") then
    res = q:getShorthandInteger(n)
  elseif (units == "decimal/hour") then
    res = q:getShorthandInteger(n,2,true)
  elseif (units == "percentage") then
    res = tostring(math.floor(n)).."%"
  elseif (units == "money") then 
    if (abbr) then
      local copper = math.floor(n) % 100
      n = n - copper
    end
    local negative = n < 0
    res = GetCoinTextureString(math.abs(n))
    if (negative) then
      res = "-"..res
    end
  elseif (units == "money/hour") then
    if (abbr) then
      local copper = math.floor(n) % 100
      n = n - copper
    end
    local negative = n < 0
    res = GetCoinTextureString(math.abs(n))
    if (negative) then
      res = "-"..res
    end
  end
    
  return res
end

function q:isInf(n)
  return n == math.huge or n == -math.huge
end

function q:isNan(n)
  return n ~= n
end

function q:getKeyForMaxValue(t)
  local max = -math.huge
  local max_key = nil
  
  for k,v in pairs(t) do
    if (v > max) then
      max_key = k
      max = v
    end
  end
  
  return max_key
end

function q:length(t)
  local count = 0
  for _,_ in pairs(t) do
    count = count + 1
  end
  
  return count
end

function q:createSegmentSnapshot(segment)
  segment.total_start_time = GetTime()
  local snapshot = q:deepcopy(segment)
  
  return snapshot
end

function q:contains(t,value)
  for _,v in ipairs(t) do
    if (v == value) then
      return true
    end
  end
  return false
end

function q:getCoppersFromText(text)
  local copper = 0
  for n,currency in string.gmatch(text, "(%d+) (%w+)") do
    if (currency == "Gold") then
      copper = copper + (n * 10000)
    elseif (currency == "Silver") then
      copper = copper + (n * 100)
    else
      copper = copper + n
    end
  end
  
  return copper
end

function q:getItemId(itemLink)
  local id = string.match(itemLink, "item:(%d+):")
  return tonumber(id)
end

function q:getJournalIdFromLink(journalLink)
  local id = string.match(journalLink, "HJournal:%d?:(%d+):")
  return tonumber(id)
end

function q:capitalizeString(str)
  local res
  
  if (str ~= nil and string.len(str) > 0) then
    local c = string.sub(str,0,1)
    c = string.upper(c)
    res = c..string.sub(str,2)
  end
  
  return res
end

function q:getBnAccountNameFromChatString(str)
  local id = string.match(str, "|K[gsf]([0-9]+)|")
  local bn_name
  if (id ~= nil) then
    local _,_,bn_name = BNGetFriendInfoByID(id)
  end
  
  return bn_name
end