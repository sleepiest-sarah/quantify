local q = quantify

local function correctBnAccountNames()
  for seg_k,seg in pairs(qDb) do
    local new_whispers_stat = {}
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats.chat ~= nil and seg.stats.chat.whispers_received_from ~= nil) then
      for player,v in pairs(seg.stats.chat.whispers_received_from) do
        local id = string.match(player, "|K[gsf]([0-9]+)|")
        if (id == nil) then
          new_whispers_stat[player] = v
        else
          local _,_,bnname = BNGetFriendInfoByID(id)
          if (bnname) then					--friend could have been removed
            new_whispers_stat[bnname] = v
          end
        end
      end
      seg.stats.chat.whispers_received_from = new_whispers_stat
    end
  end
end

local function setTimeSubMax(event)
  if (event == nil) then
    q:registerEvent("PLAYER_ENTERING_WORLD",setTimeSubMax)
    return
  else
    q:unregisterEvent("PLAYER_ENTERING_WORLD", setTimeSubMax)
  end
  
  if (qDb[q.TotalSegment:characterKey()] ~= nil and qDb[q.TotalSegment:characterKey()].stats.time ~= nil) then
    if (not (UnitXP("player") == 0 or pcall(IsXPUserDisabled))) then
      qDb[quantify.TotalSegment:characterKey()].stats.time.time_sub_max_level = qDb[q.TotalSegment:characterKey()].stats.time.play_time
    end
  end
  
  if (qDb[q.TotalSegment:characterKey()] ~= nil and qDb[q.TotalSegment:characterKey()].stats.time ~= nil) then
    local xp = qDb[quantify.TotalSegment:characterKey()].stats.xp
    qDb[quantify.TotalSegment:characterKey()].stats.time.time_rested =  math.floor((xp.rested_xp * 2 / xp.kill_xp) * qDb[q.TotalSegment:characterKey()].stats.time.time_sub_max_level)
  end
end

local function sanityCheckTimes()
  for seg_k,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats.time ~= nil and seg.stats.time.play_time ~= nil) then
      local play_time = seg.stats.time.play_time
      seg.time = play_time
      for k,v in pairs(seg.stats.time) do
        if (v > play_time) then
          seg.stats.time[k] = play_time
        end
      end
    end
  end 
end
  

local function isPreReleaseVersion(v)
  return string.find(v, "alpha") or string.find(v, "beta")
end

function q:runMigrations()
  local installed_version = GetAddOnMetadata("quantify", "Version")
  
  --always run all migrations if the current version or data is an alpha or beta release
  if (qDbOptions.version == nil or installed_version == nil or isPreReleaseVersion(installed_version) or isPreReleaseVersion(qDbOptions.version)) then
    correctBnAccountNames()
    setTimeSubMax()
    sanityCheckTimes()
  else
    
    if (qDbOptions.version < "1.0") then
      correctBnAccountNames()
    end
      
    if (qDbOptions.version < "1.1") then
      setTimeSubMax()    
      sanityCheckTimes()
    end
    
    if (qDbOptions.version < "1.2") then
    end
    
  end
  
end
