local q = quantify

local function correctBnAccountNames()
  for seg_k,seg in pairs(qDb) do
    local new_whispers_stat = {}
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats.chat ~= nil and seg.stats.chat.data and seg.stats.chat.data.whispers_received_from ~= nil) then
      for player,v in pairs(seg.stats.chat.data.whispers_received_from) do
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
      seg.stats.chat.data.whispers_received_from = new_whispers_stat
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
      qDb[quantify.TotalSegment:characterKey()].stats.time.stats.time_sub_max_level = qDb[q.TotalSegment:characterKey()].stats.time.stats.play_time
    end
  end
  
  if (qDb[q.TotalSegment:characterKey()] ~= nil and qDb[q.TotalSegment:characterKey()].stats.time ~= nil) then
    local xp = qDb[quantify.TotalSegment:characterKey()].stats.xp.stats
    local time = qDb[quantify.TotalSegment:characterKey()].stats.time.stats
    if (time.time_rested == 0 and xp.rested_xp and time.time_sub_max_level) then
      time.time_rested = math.floor((xp.rested_xp * 2 / xp.kill_xp) * time.time_sub_max_level)
    end
  end
end

local function sanityCheckTimes()
  for seg_k,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats.time ~= nil and seg.stats.time.stats.play_time ~= nil) then
      local play_time = seg.stats.time.stats.play_time
      seg.time = play_time
      for k,v in pairs(seg.stats.time.stats) do
        if (v > play_time) then
          seg.stats.time.stats[k] = play_time
        end
      end
    end
  end 
end

local function clearNegativeCurrencies()
  for seg_k,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats[quantify_currency.MODULE_KEY] ~= nil) then
      local stats = seg.stats[quantify_currency.MODULE_KEY]
      if (stats.quest_money and stats.quest_money < 0) then
        stats.quest_money = 0
      end
      
      if (stats.auction_money and stats.auction_money < 0) then
        stats.auction_money = 0
      end
      
      if (stats.vendor_money and stats.vendor_money < 0) then
        stats.vendor_money = 0
      end
      
      if (stats.money_looted and stats.money_looted < 0) then
        stats.money_looted = 0
      end      
    end
  end 
end

local function restructureInstancesData()
  local qi = quantify_instances
  
  for seg_k,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats[quantify_instances.MODULE_KEY] ~= nil) then
      local instances = seg.stats[quantify_instances.MODULE_KEY]
      if (not instances.data) then
        instances.data = {}
      end
      
        instances.data.raids = {}
        instances.data.dungeons = {}
        instances.data.players = instances.stats.party_members

      for name, value in pairs(instances.data.players) do
        value.name = name
        value.boss_kills = value.kills
        value.boss_wipes = value.wipes
        value.party_deaths = value.player_deaths
      end
      
      for name,value in pairs(instances.stats) do
        if (strfind(name, "*")) then
          local stat_string, instance_string = strsplit("*", name)
          
          local d
          if (strfind(stat_string,"raid")) then
            d = instances.data.raids
          else
            d = instances.data.dungeons
          end
          
          if (not d[instance_string])  then
            local instance,difficulty = strsplit("-", instance_string)
            if (difficulty) then
              d[instance_string] = {}
              d[instance_string].name = instance
              d[instance_string].difficulty = difficulty == "Mythic Keystone" and "Mythic+" or difficulty
            end
          end
          
          if (d[instance_string]) then
            local instance = d[instance_string]     
            if (strfind(stat_string,"raid")) then
              
              if (strfind(name, "raid_boss_kill_*")) then
                instance.boss_kills = value
              elseif (strfind(name, "raid_boss_wipe_*")) then
                instance.boss_wipes = value
              end
            else
              if (strfind(name, "dungeon_boss_kill_*")) then
                instance.boss_kills = value
              elseif (strfind(name, "dungeon_boss_wipe_*")) then
                instance.boss_wipes = value
              elseif (strfind(name, "dungeon_deaths_*")) then
                instance.party_deaths = value
              end
            end
          end
        end
      end
      
      if (instances.bfa_dungeon_time) then
        for k,v in pairs(instances.bfa_dungeon_time) do
          if (instances.data.dungeons[k]) then
            instances.data.dungeons[k].completed_runs = v.n
            instances.data.dungeons[k].cumulative_time = v.time
          end
        end
      end
      
    end
  end
end

local function restructureChatData()
  for seg_k,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats[quantify_chat.MODULE_KEY] ~= nil) then
      local chat = seg.stats[quantify_chat.MODULE_KEY]
      chat.data = {}
      chat.data.whispers_received_from = chat.whispers_received_from
      chat.data.whispers_sent_to = chat.whispers_sent_to
      chat.data.emotes_used = chat.data.emotes_used
      
      chat.stats.whispers_received_from = nil
      chat.stats.whispers_sent_to = nil
      chat.stats.emotes_used = nil
    end
    
  end
end

local function restructureCurrencyData()
  for seg_k,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats[quantify_currency.MODULE_KEY] ~= nil) then
      local currency = seg.stats[quantify_currency.MODULE_KEY]
      currency.data = {}
      
      for k,v in pairs(currency.stats) do
        if (strfind(k,"currency_gained_*")) then
          local prefix,name = strsplit("*",k)
          currency.data[name] = q:shallowCopy(quantify_currency.CURRENCY_TEMPLATE)
          currency.data[name].name = name
          currency.data[name].gained = v
          currency.data[name].net = v
        end
      end

    end 
    
  end
end

local function restructureLootData()
  for seg_k,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats[quantify_loot.MODULE_KEY] ~= nil) then
      local loot = seg.stats[quantify_loot.MODULE_KEY]
      
      loot.stats.inv_type_looted = {}
      loot.stats.upgrades_received = {} 
      
      for k,v in pairs(loot.stats) do
        if (strfind(k,"inv_type_*")) then
          local prefix,name = strsplit("*",k)
          loot.stats.inv_type_looted[name] = v
        elseif (strfind(k, "upgrade_received_*")) then
          local prefix,name = strsplit("*",k)
          loot.stats.upgrades_received[name] = v
        end
      end
    end 
  end
end

local function deleteRemovedStats()
    for seg_name,seg in pairs(qDb) do
      if (seg.stats) then
        
        if (seg.stats[quantify_chat.MODULE_KEY]) then
          seg.stats[quantify_chat.MODULE_KEY].word_cloud = nil
        end
        
        for k,v in pairs(seg.stats) do
          if (k ~= "stats" and k ~= "data") then
            v[k] = nil
          end
        end
        
      end
    end
    
    if (qDb.data) then
      qDb.data.word_cloud_timestamps = nil
      qDb.data.instances_party_member_timestamp_ = nil
    end
  
end

local function restructureStats()
  for seg_name,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats) then

      for mod_name, mod in pairs(seg.stats) do
        mod.stats = mod.stats or q:shallowCopy(mod)
        mod.data = mod.stats.data or {}
        mod.stats.data = nil
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
    restructureStats()
    restructureInstancesData()
    restructureChatData()
    deleteRemovedStats()
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
    
    if (qDbOptions.version < "1.3") then
      clearNegativeCurrencies()
      restructureStats()
      restructureInstancesData()
      restructureChatData()
      deleteRemovedStats()
    end
    
  end
  
end
