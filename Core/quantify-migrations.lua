local q = quantify

local DELETED_STATS = {
  ["word_cloud"] = true,
  ["whispers_received_from"] = true,
  ["pet_battle_counts"] = true,
  ["whispers_sent_to"] = true,
  ["emotes_used"] = true,
  ["party_members"] = true,
  ["bfa_dungeon_time"] = true
}

local DELETED_DATA_ENTRIES = {
  
  
}

local function setTimeSubMax(event)
  if (event == nil) then
    q:registerEvent("PLAYER_ENTERING_WORLD",setTimeSubMax)
    return
  else
    q:unregisterEvent("PLAYER_ENTERING_WORLD", setTimeSubMax)
  end
  
  local seg = qDb[q:getCharacterKey()]
  local play_time = seg and q:getStat(seg,"PLAY_TIME")
  if (seg and play_time) then
    if (not (UnitXP("player") == 0 or pcall(IsXPUserDisabled))) then
      qDb[q:getCharacterKey()].stats.time.stats.time_sub_max_level = qDb[q:getCharacterKey()].stats.time.stats.play_time
    end
    
    local xp = seg.stats.xp.stats
    local time = seg.stats.time.stats
    if (time.time_rested == 0 and xp.rested_xp and time.time_sub_max_level and xp.kill_xp > 0) then
      time.time_rested = math.floor((xp.rested_xp * 2 / xp.kill_xp) * time.time_sub_max_level)
    end    
  end
  
end

local function sanityCheckTimes()
  for seg_k,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats ~= nil and seg.stats.time ~= nil and seg.stats.time.stats.play_time ~= nil) then
      local play_time = seg.stats.time.stats.play_time
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

local function restructureInstancesData(seg)
  local qi = quantify_instances
  
  if (seg.stats[quantify_instances.MODULE_KEY]) then
    local instances = seg.stats[quantify_instances.MODULE_KEY]
    
    instances.data.raids = instances.data.raids or {}
    instances.data.dungeons = instances.data.dungeons or {}
    instances.data.players = instances.data.players or instances.stats.party_members or {}
    instances.stats.party_members = nil

    for name, value in pairs(instances.data.players) do
      if (value.kills or value.wipes or value.player_deaths) then
        value.name = name
        value.boss_kills = value.kills
        value.boss_wipes = value.wipes
        value.party_deaths = value.player_deaths
        
        value.kills = nil
        value.wipes = nil
        value.player_deaths = nil
      end
    end
    
    for name,value in pairs(instances.stats) do
      if (strfind(name, "%*")) then
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
            
            if (strfind(name, "raid_boss_kill_%*")) then
              instance.boss_kills = value
            elseif (strfind(name, "raid_boss_wipe_%*")) then
              instance.boss_wipes = value
            end
          else
            if (strfind(name, "dungeon_boss_kill_%*")) then
              instance.boss_kills = value
            elseif (strfind(name, "dungeon_boss_wipe_%*")) then
              instance.boss_wipes = value
            elseif (strfind(name, "dungeon_deaths_%*")) then
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
      
      instances.bfa_dungeon_time = nil
    end
    
  end
end

local function restructureChatData(seg)
  if (seg.stats[quantify_chat.MODULE_KEY]) then
    local chat = seg.stats[quantify_chat.MODULE_KEY]
    
    chat.data.whispers_received_from = chat.data.whispers_received_from or chat.stats.whispers_received_from or {}
    chat.data.whispers_sent_to = chat.data.whispers_sent_to or chat.stats.whispers_sent_to or {}
    chat.data.emotes_used = chat.data.emotes_used or chat.stats.emotes_used or {}
  
    for player, ct in pairs(chat.data.whispers_received_from) do
      if (strfind(player, "|")) then
        chat.data.whispers_received_from[player] = nil
      end
    end
    
    for player, ct in pairs(chat.data.whispers_sent_to) do
      if (strfind(player, "|")) then
        chat.data.whispers_sent_to[player] = nil
      end
    end
    
    chat.stats.whispers_received_from = nil
    chat.stats.whispers_sent_to = nil
    chat.stats.emotes_used = nil
  end
end

local function restructureCurrencyData(seg)
  if (seg.stats[quantify_currency.MODULE_KEY]) then
    local currency = seg.stats[quantify_currency.MODULE_KEY]
    
    currency.data.currency = currency.data.currency or {}
    for k,v in pairs(currency.stats) do
      if (strfind(k,"currency_gained_%*")) then
        local prefix,name = strsplit("*",k)
        currency.data.currency[name] = q:shallowCopy(quantify_currency.CURRENCY_TEMPLATE)
        currency.data.currency[name].name = name
        currency.data.currency[name].gained = v
        currency.data.currency[name].net = v
      end
    end

  end 
end

local function restructureLootData(seg)
  if (seg.stats[quantify_loot.MODULE_KEY]) then
    local loot = seg.stats[quantify_loot.MODULE_KEY]
    
    loot.stats.inv_type_looted = loot.stats.inv_type_looted or {}
    loot.stats.upgrades_received = loot.stats.upgrades_received or {} 
    
    for k,v in pairs(loot.stats) do
      if (strfind(k,"inv_type_%*")) then
        local prefix,name = strsplit("*",k)
        loot.stats.inv_type_looted[name] = v
      elseif (strfind(k, "upgrade_received_%*")) then
        local prefix,name = strsplit("*",k)
        loot.stats.upgrades_received[name] = v
      end
    end
  end 
end

local function restructureZoneData(seg)
  if (seg.stats[quantify_zones.MODULE_KEY]) then
    local mod = seg.stats[quantify_zones.MODULE_KEY]
    
    mod.stats.zones = mod.stats.zones or {}
    local zones = mod.stats.zones
    for k,v in pairs(mod.stats) do
      if (strfind(k,"zone_time_%*")) then
        local prefix,name = strsplit("*",k)
        zones[name] = v
      end
    end
  end
end

local function restructureTradeskillData(seg)
  if (seg.stats[quantify_tradeskill.MODULE_KEY]) then
    local mod = seg.stats[quantify_tradeskill.MODULE_KEY]
    
    mod.stats.bfa_trade_good_collected = mod.stats.bfa_trade_good_collected or {}
    local bfa_trade_good_collected = mod.stats.bfa_trade_good_collected
    for k,v in pairs(mod.stats) do
      if (strfind(k,"bfa_trade_good_%*")) then
        local prefix,name = strsplit("*",k)
        bfa_trade_good_collected[name] = v
      end
    end
  end
end

local function restructureBattlePetsData(seg)
  if (seg.stats[quantify_bp.MODULE_KEY]) then
    local mod = seg.stats[quantify_bp.MODULE_KEY]
    
    mod.data.pet_battle_counts = mod.stats.pet_battle_counts
    mod.stats.pet_battle_counts = nil
  end
end

local function deleteRemovedStats()
    for seg_name,seg in pairs(qDb) do
      seg.time = nil
      
      if (seg.stats) then
        
        for mod_key,mod in pairs(seg.stats) do
          for mod_sub_key, mod_sub in pairs(mod) do
              if (mod_sub_key ~= "stats" and mod_sub_key ~= "data") then
                mod[mod_sub_key] = nil
              end
          end
          
          for stat_key,stat in pairs(mod.stats) do
            if (DELETED_STATS[stat_key] or strfind(stat_key, "%*")) then
              mod.stats[stat_key] = nil
            end
          end
          
          for data_key,data in pairs(mod.data) do
            if (DELETED_DATA_ENTRIES[data_key]) then
              mod.data[data_key] = nil
            end
          end          
        end
        
      end
    end
    
    qDb.data = nil
    
    if (qDbOptions) then
      qDbOptions.preload = nil
    end
end

local function restructureStats()
  for seg_name,seg in pairs(qDb) do
    if (type(seg) == "table" and seg.stats) then

      for mod_name, mod in pairs(seg.stats) do
        mod.stats = mod.stats or q:shallowCopy(mod)
        mod.data = mod.data or {}
      end
      
      restructureChatData(seg)
      restructureCurrencyData(seg)
      restructureLootData(seg)
      restructureInstancesData(seg)
      restructureZoneData(seg)
      restructureTradeskillData(seg)
    end
  end
end

local function clearWatchlists()
  local bad_data = false
  
  if (qDbOptions.watchlist) then
    for k,v in pairs(qDbOptions.watchlist) do
      if (strfind(k,":")) then
        bad_data = true
        break
      end
    end
  end
  
  if (not bad_data and qDbOptions.saved_watchlists) then
    for saved_watchlist_key,saved_watchlist in pairs(qDbOptions.saved_watchlists) do
      for k,v in pairs(saved_watchlist) do
        if (strfind(k,":")) then
          bad_data = true
          break
        end
      end
    end
  end
  
  if (bad_data) then
    qDbOptions.saved_watchlists = nil
    qDbOptions.watchlist = nil
    qDbOptions.watchlist_enabled = nil
  end
end

local function validateSegmentName(seg_name)
  if (strfind(seg_name, "-")) then
    local character,server = strsplit("-",seg_name)
    
    return (character and #character > 0) and (server and #server > 0)
  elseif (seg_name == "account") then
    return true
  end
  
  return false
end

local function verifySavedData()
  local repair = false
  for seg_name,seg in pairs(qDb) do
    if (not validateSegmentName(seg_name) or type(seg) ~= "table" or not seg.stats) then
      qDb[seg_name] = nil
    else
      if (seg.time) then
        repair = true
        break
      end
      
      for mod_name, mod in pairs(seg.stats) do
        if (not (mod.stats and mod.data) or q:length(mod) > 2) then
          repair = true
          break
        end
        
        for stat_key,stat in pairs(mod.stats) do
          if (DELETED_STATS[stat_key] or strfind(stat_key, "%*")) then
            repair = true
            break
          end

        end
        
        for data_key,data in pairs(mod.data) do
          if (DELETED_DATA_ENTRIES[data_key]) then
            repair = true
            break
          end
          
          if (mod_name == quantify_chat.MODULE_KEY and (data_key == "whispers_received_from" or data_key == "whispers_sent_to")) then
            for player, ct in pairs(data) do
              if (strfind(player, "|")) then
                repair = true
                break
              end
            end
          end          
        end
      end
    end
  end
  
  if (repair) then
    restructureStats()
    deleteRemovedStats()
  end
end

local function isPreReleaseVersion(v)
  return string.find(v, "alpha") or string.find(v, "beta")
end

function q:runMigrations()
  local installed_version = GetAddOnMetadata("quantify", "Version")
  
  verifySavedData()
  
  --always run all migrations if the current version or data is an alpha or beta release
  if (qDbOptions.version == nil or installed_version == nil or isPreReleaseVersion(installed_version) or isPreReleaseVersion(qDbOptions.version)) then
    clearWatchlists()
    setTimeSubMax()
    sanityCheckTimes()
  else
      
    if (qDbOptions.version < "1.1") then
      setTimeSubMax()    
      sanityCheckTimes()
    end
    
    if (qDbOptions.version < "1.3") then
      clearNegativeCurrencies()
      clearWatchlists()
    end
    
  end
end
