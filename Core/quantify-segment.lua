local q = quantify

local stats = q.STATS

local function searchPath(obj, path)
  local pieces = {strsplit("/", path)}  
  
  for i,p in ipairs(pieces) do
    if (type(obj) == "table" and p ~= "") then
      obj = obj[p]
    end
  end
  
  return obj
end

function q:getStatByPath(segment, path, data_key)
  local paths = q:evaluatePath(segment, path, data_key)
  
  if (type(paths) == "table") then
    local stats = {}
    for k,p in pairs(paths) do
      stats[k] = searchPath(segment.stats, p)
    end
    return stats
  else
    return searchPath(segment.stats, paths)
  end
end

function q:getStat(segment, key, data_key)
  local stat = q.STATS[key]
  if (not stat or not stat.path) then
    print(key.." is not a valid key")
  end
  return q:getStatByPath(segment, stat.path, data_key)
end

function q:evaluatePath(segment, path, data_key)
  local wildcard = strfind(path, "%*")
  if (wildcard and data_key) then
    return string.gsub(path, "*", data_key, 1)
  elseif (not wildcard) then
    return path
  end
  
  local pieces = {strsplit("/", path)}
  
  local paths = {}
  local obj = segment.stats
  for i,p in pairs(pieces) do
    if (not obj) then
      print(p.." in "..path.." not valid")
    end    
    
    if (p == "*") then
      local stats = {}

      for k,v in pairs(obj) do
        local new_path = string.gsub(path,"*",k,1)

        paths[k] = string.gsub(path,"*",k,1)
      end
      
      return paths
    elseif (type(obj) == "table" and p ~= "") then
      obj = obj[p]
    end
  end
end

function q:setStat(segment, stat_key, value, data_key)
  local stat = q.STATS[stat_key]
  if (not stat or not stat.path) then
    print(stat_key.." is not a valid key")
  end
  q:setStatByPath(segment, stat.path, value, data_key)
end

local function setAtPath(obj, path, value)
  local pieces = {strsplit("/", path)}
  
  local key = nil
  for i,p in ipairs(pieces) do
    key = p
    if (i == #pieces) then
      break
    elseif (not obj[key]) then
      obj[key] = {}
    end
    obj = obj[key]
  end
  obj[key] = value  
end

function q:setStatByPath(segment, path, value, data_key)
  local paths = q:evaluatePath(segment, path, data_key)
  
  if (type(paths) == "table") then
    local stats = {}
    for k,p in pairs(paths) do
      setAtPath(segment.stats, p, value)
    end
  else
    return setAtPath(segment.stats, paths, value)
  end  
  
  q.stats_dirty = true
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
    segments[q:getCharacterKey()] = qDb[q:getCharacterKey()]
    segments[q:getCharacterKey(true)] = qDb[q:getCharacterKey(true)]
    segments.account = qDb.account
  end
  
  segments.current = q.current_segment
  
  return segments  
end

function q:getSegment(segment_key)
  local seg
  
  local seg_id = string.match(segment_key, "Segment (%d+)")
  if (seg_id ~= nil) then
    seg = q.segments[tonumber(seg_id)]
  else
    seg = qDb[segment_key]
  end
  
  return seg
end

function q:incrementStat(key, increment)
  if (not stats[key]) then
    print("not valid stat key: "..key)
  end
  q:incrementStatByPath(stats[key].path,increment)
end

function q:incrementStatByPath(path, increment)
  local segments = q:getAllActiveSegments()
  
  for k,seg in pairs(segments) do
    local stat = q:getStatByPath(seg, path)
    q:setStatByPath(seg, path, (stat or 0) + increment)
  end
end

function q:decrementStat(key, decrement)
  q:incrementStat(key, decrement * -1)
end

--callback signature: callback(blockToUpdate, ...)
function q:updateStatBlock(path,callback, ...)
  local segments = q:getAllActiveSegments()
  
  for k,seg in pairs(segments) do
    local stat_block = q:getStatByPath(seg, path)
    callback(stat_block, ...)
  end
end

function q:createNewSegment()
  local seg = {}
  seg.stats = {}

  for _,m in ipairs(q.modules) do
    seg.stats[m.MODULE_KEY] = {}
    seg.stats[m.MODULE_KEY].stats = {}
    seg.stats[m.MODULE_KEY].data = {}
    
    m:newSegment(seg.stats[m.MODULE_KEY])
    m:updateStats(seg.stats[m.MODULE_KEY], seg)
  end
  
  return seg
end

function q:updateSegment(segment, init)
  if (segment == q.current_segment) then
    q.stats_dirty = false
  end
  
  for _,m in ipairs(q.modules) do
    if (init) then
      segment.stats[m.MODULE_KEY] = segment.stats[m.MODULE_KEY] or {}
      m:newSegment(segment.stats[m.MODULE_KEY])  
    end
    
    m:updateStats(segment.stats[m.MODULE_KEY], segment)
  end  
end