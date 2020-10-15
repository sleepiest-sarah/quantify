local q = quantify

function q:printTable(t, depth)
  depth = depth or 0
  
  if (not t or depth > 5) then
    return
  end
  
  for k,v in pairs(t) do
    if (type(v) == "table") then
      print(string.format("%s:", tostring(k)))
      q:printTable(v, depth + 1)
    else
      print(string.format("%s: %s", tostring(k), tostring(v)))
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

function q:addKeysLeft(a,b)
  a = a or {}
  for k,v in pairs(b) do
    if (not a[k]) then
      a[k] = type(v) == "table" and {} or v
    end
  end
  
  return a
end

function q:calculateSegmentRates(segment, segment_stats, period, duration)
  period = period or 3600
  
  if (segment ~= nil and segment:duration() ~= nil) then
    duration = segment:duration()
  elseif (segment ~= nil) then
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

function q:addTables(a,b,shallow)
  --b expected to be the most up to date in the case of missing keys
  for k,v in pairs(b) do
    if (type(v) == "table" and not shallow) then
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
        setmetatable(copy, q:shallowCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--flattens stat table
function q:getAllStats(segment, type)
  local stats = {}
  for _,module in pairs(segment.stats) do
    for stattype_k,stattype in pairs(module) do
      if (not type or (type and type == stattype_k)) then
        for k,v in pairs(stattype) do
          stats[stattype_k..":"..k] = v
        end
      end
    end
  end
     
  return stats
end

function q:getSingleModuleSegment(key,segment,type)
  local new_seg = q:shallowCopy(segment)
  
  new_seg.stats = {}
  new_seg.stats[key] = {}
  if (type and new_seg.stats[key][type]) then
    new_seg.stats[key][type] = segment.stats[key][type]
  else
    new_seg.stats[key] = segment.stats[key]
  end
  
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
    if (abbr and (n > 10000 or q.isRetail)) then  --remove copper in Retail or if it's more than 1g
      local copper = math.floor(n) % 100
      n = n - copper
    end
    local negative = n < 0
    res = GetCoinTextureString(math.abs(n))
    if (negative) then
      res = "-"..res
    end
  elseif (units == "money/hour") then
    if (abbr and (n > 10000 or q.isRetail)) then  --remove copper in Retail or if it's more than 1g
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

function q:getKeyForMaxValue(t,subkey)
  local max = -math.huge
  local max_key = nil
  
  for k,v in pairs(t) do
    if (subkey and v[subkey] > max) then
      max_key = k
      max = v[subkey]
    elseif (not subkey and v > max) then
      max_key = k
      max = v
    end
  end
  
  return max_key
end

function q:getKeyForMinValue(t,subkey)
  local min = math.huge
  local min_key = nil
  
  for k,v in pairs(t) do
    if (subkey and v[subkey] < min) then
      min_key = k
      min = v[subkey]
    elseif (not subkey and v < min) then
      min_key = k
      min = v
    end
  end
  
  return min_key
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

function q:doesStatApplyToVersion(key)
  local stat = q.STATS[key]
  
  if (stat) then
    return not stat.version or (q.isRetail and stat.version == "retail") or (q.isClassic and stat.version == "classic")
  end
end

function q:getSegmentId(segmentLabel)
  local id = string.match(segmentLabel, "Segment (%d+)")
  return tonumber(id)
end

function q:getGroupConcatKey(key,subkey)
  local group = string.sub(key, 1, string.find(key, ":") - 1)
      
  local keynogroup = string.sub(key,string.len(group) + 2)
      
  local concat_key_no_group = subkey and keynogroup..subkey or keynogroup
  
  return group,concat_key_no_group
end

function q:generateUUID()
  local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function (c)
      local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
      return string.format('%x', v)
  end)
end

function q:storeData(key,data)
  if (not qDb.data) then
    qDb.data = {}
  end
  
  qDb.data[key] = data
end

function q:getData(key)
  if (qDb and qDb.data and qDb.data[key]) then
    return qDb.data[key]
  end
end

function q:getUnitGroupPrefix()
  return IsInRaid() and "raid" or "party"
end

function q:buildDisplayTable(data, ...)
  local rows = {}
  local data_keys = {...}
  local num_columns = #data_keys
  
  for _,d in pairs(data) do
    local r = {}
    for i,data_key in ipairs({...}) do
      --if (d[data_key]) then
        table.insert(r, d[data_key])
      --end
    end
    
    --if (#r == num_columns) then
      table.insert(rows, r)
    --end
  end
    
  return rows
end

function q:getRoleIcon(role)
  if (role == "TANK") then
    return INLINE_TANK_ICON
  elseif (role == "HEALER") then
    return INLINE_HEALER_ICON
  elseif (role == "DAMAGER") then
    return INLINE_DAMAGER_ICON
  end
  
  return ""
end

function q:keyTable(t)
  local res = {}
  for i,v in pairs(t) do
    res[v] = v
  end
  
  return res
end