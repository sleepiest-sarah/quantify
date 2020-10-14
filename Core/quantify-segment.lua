local q = quantify

local stats = q.STATS

function q:getStat(segment, path)
  local pieces = {strsplit("/", path)}
  
  local obj = segment.stats
  for i,p in ipairs(pieces) do
    if (type(obj) == "table" and p ~= "") then
      obj = obj[p]
    end
  end
  
  return obj
end

function q:setStat(segment, path, value)
  local pieces = {strsplit("/", path)}
  
  local obj = segment.stats
  for i,p in ipairs(pieces) do
    
    if (type(obj[p]) ~= "table") then
      obj[p] = value
    else
      obj = obj[p]
    end
  end
end

function q:getAllSegments()
  local segments = {}
  if (qDb ~= nil) then
    for k,v in pairs(qDb) do
      if (type(v) == "table" and k ~= "data") then
        segments[k] = v
      end
    end
  end
  
  for i,v in ipairs(q.segments) do
    segments["Segment "..i] = v
  end
  
  return segments
end

function q:getAllActiveSegments()
  local segments = {}
  if (qDb ~= nil) then
    segments[q.TotalSegment:characterKey()] = qDb[q.TotalSegment:characterKey()]
    segments.account = qDb.account
  end
  
  segments.current = q.current_segment
  
  return segments  
end

function q:incrementStat(key, increment)
  q:incrementStatByPath(stats[key].path,increment)
end

function q:incrementStatByPath(path, increment)
  local segments = q:getAllActiveSegments()
  
  for k,seg in pairs(segments) do
    local stat = q:getStat(seg, path)
    q:setStat(seg, path, (stat or 0) + increment)
  end
end

function q:decrementStat(key, decrement)
  q:incrementStat(key, decrement * -1)
end

--callback signature: callback(blockToUpdate, ...)
function q:updateStatBlock(path,callback, ...)
  local segments = q:getAllActiveSegments()
  
  for k,seg in pairs(segments) do
    local stat_block = q:getStat(seg, path)
    callback(stat_block, ...)
  end
end

function q:convertSavedSegment(segment)
  local cseg = q.Segment:new()
  cseg._duration = segment.time
  
  for k,v in pairs(segment.stats) do
    cseg.stats[k] = v
  end
  
  for _,m in ipairs(q.modules) do
    if (cseg.stats[m.MODULE_KEY] == nil) then
      cseg.stats[m.MODULE_KEY] = {}
      --cseg.stats[m.MODULE_KEY].raw = m.Session:new()
    end
    
    --add any stats that are missing from the saved segment
--    local empty_stats = m.Session:new()
--    for s,v in pairs(empty_stats) do
--      if (cseg.stats[m.MODULE_KEY].raw[s] == nil) then
--        cseg.stats[m.MODULE_KEY].raw[s] = v
--      end
--    end

    m:newSegment(cseg.stats[m.MODULE_KEY])
    m:updateStats(cseg.stats[m.MODULE_KEY])
  end
  
  return cseg
end