local q = quantify

qDA = {}

--- Dungeons ---

local function isDungeonApplicable(d, filter)
    return (filter.difficulties[d.difficulty] and filter.dungeons[d.name] 
        and (not d.keystone_level or d.keystone_level == 0 or (d.keystone_level <= filter.maxKeystoneLevel and d.keystone_level >= filter.minKeystoneLevel)))
end

function qDA:getDungeonData(filter, dungeon)
  local seg = q:getViewingSegment()
  
  local dungeons_data = seg.stats.instances.data and seg.stats.instances.data.dungeons or {}
  local filtered_list = {}
  for k,d in pairs(dungeons_data) do
    if (not dungeon or k == dungeon or d.name == dungeon) then
      if (isDungeonApplicable(d, filter)) then
        filtered_list[k] = d
      end
    end
  end
  
  return filtered_list
end

function qDA:getDungeonPlayers(filter, player)
  local seg = q:getViewingSegment()
  
  local players_data = seg.stats.instances.data and seg.stats.instances.data.players or {}
  local filtered_list = {}
  for player_name,p in pairs(players_data) do
    if (not player or player_name == player) then
      local player_res = {completed_runs = 0, party_deaths = 0, name = p.name, wipes = 0, boss_kills = 0, cumulative_time = 0, boss_wipes = 0}
      
      if (p.dungeons) then
        for k,d in pairs(p.dungeons) do
          if (isDungeonApplicable(d,filter)) then
            player_res.completed_runs = player_res.completed_runs + d.completed_runs
            player_res.party_deaths = player_res.party_deaths + d.party_deaths
            player_res.wipes = player_res.wipes + d.wipes
            player_res.boss_kills = player_res.boss_kills + d.boss_kills
            player_res.boss_wipes = player_res.boss_wipes + d.boss_wipes
            player_res.cumulative_time = player_res.cumulative_time + d.cumulative_time
          end
        end
      end
      
      if (player_res.completed_runs > 0) then
        player_res.ddr = player_res.party_deaths / player_res.completed_runs
        player_res.wdr = player_res.wipes / player_res.completed_runs
        player_res.kdr = (player_res.boss_wipes == 0 and player_res.boss_kills) or (player_res.boss_kills / player_res.boss_wipes)
        filtered_list[player_name] = player_res
      end
    end
  end
  
  return filtered_list
end

function qDA:getDungeonParties(filter, party)
  local seg = q:getViewingSegment()
   
  local party_data = seg.stats.instances.data and seg.stats.instances.data.parties or {}
  local filtered_list = {}
  for party_key,p in pairs(party_data) do
    if (not party or party_key == party) then
      local party_res = {completed_runs = 0, boss_kills = 0, boss_wipes = 0, members = p.members, party_deaths = 0, wipes = 0, cumulative_time = 0}
      
      for k,d in pairs(p.dungeons) do
        if (isDungeonApplicable(d,filter)) then
          party_res.completed_runs = party_res.completed_runs + d.completed_runs
          party_res.boss_kills = party_res.boss_kills + d.boss_kills
          party_res.boss_wipes = party_res.boss_wipes + d.boss_wipes
          party_res.cumulative_time = party_res.cumulative_time + d.cumulative_time
          party_res.wipes = party_res.wipes + d.wipes
          party_res.party_deaths = party_res.party_deaths + d.party_deaths
        end
      end
      
      if (party_res.completed_runs > 0) then
        party_res.kdr = (party_res.boss_wipes > 0 and party_res.boss_kills / party_res.boss_wipes) or party_res.boss_kills
        party_res.ddr = party_res.party_deaths / party_res.completed_runs
        party_res.wdr = party_res.wipes / party_res.completed_runs
        filtered_list[party_key] = party_res
      end
    end
  end
  
  return filtered_list
end

function qDA:getExpansionDungeons(expacIndex)
  local currentTier = EJ_GetCurrentTier()
  
  EJ_SelectTier(expacIndex)
  
  local dungeons = {}
  local i = 1
  local _,name = EJ_GetInstanceByIndex(i, false)
  while name do
    dungeons[i] = name
    
    i = i + 1
    _,name = EJ_GetInstanceByIndex(i, false)
  end
  
  EJ_SelectTier(currentTier)
  
  return dungeons
end

function qDA:getExpansions()
  local expansions = {}
  for i=1,EJ_GetNumTiers() do
     expansions[i] = EJ_GetTierInfo(i)
  end
  
  return expansions
end

function qDA:getDungeonHistory(data_type, data_key, filter)
  if (qDbData and qDbData.dungeon_history) then
    local seg = q:getViewingSegment()
  
    local data
    if (data_type == "players") then
      data = seg.stats.instances.data.players
    elseif (data_type == "parties") then
      data = seg.stats.instances.data.parties
    elseif (data_type == "dungeons") then
      data = seg.stats.instances.data.dungeons
    else 
      print("quantify: unimplemented data type")
      return nil
    end
    
    data = data and data[data_key]
    if (not data) then
      print("quantify: invalid data key")
      return nil
    end
    
    local res = {}
    if (data.history) then
      for i,history_guid in pairs(data.history) do
        local dungeon = qDbData.dungeon_history[history_guid]
        if (dungeon and isDungeonApplicable(dungeon, filter)) then
          table.insert(res, qDbData.dungeon_history[history_guid])
        end
      end
    end
    
    return res
  end
end

function qDA:getFactions()
  local factions = quantify_reputation.factions
  
  return q:getTableKeys(factions)
end

function qDA:getExpansionLootIds()
  return quantify.EXPAC_LOOT_IDS_TEXT
end