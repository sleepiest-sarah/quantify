local q = quantify

qDA = {}

--- Dungeons ---

local function isDungeonApplicable(d, filter)
    return (filter.difficulties[d.difficulty] and filter.dungeons[d.name] 
        and (d.keystone_level == 0 or (d.keystone_level <= filter.maxKeystoneLevel and d.keystone_level >= filter.minKeystoneLevel)))
end

function qDA:getDungeonData(filter)
  local seg = q:getViewingSegment()
  
  local dungeons_data = seg.stats.instances.data and seg.stats.instances.data.dungeons or {}
  local filtered_list = {}
  for k,d in pairs(dungeons_data) do
    if (isDungeonApplicable(d, filter)) then
      filtered_list[k] = d
    end
  end
  return filtered_list
end

function qDA:getDungeonPlayers(filter)
  local seg = q:getViewingSegment()
  
  local players_data = seg.stats.instances.data and seg.stats.instances.data.players or {}
  local filtered_list = {}
  for player_name,p in pairs(players_data) do
    local player_res = {completed_runs = 0, party_deaths = 0, name = p.name}
    
    for k,d in pairs(p.dungeons) do
      q:dump(d)
      print(isDungeonApplicable(d,filter))
      if (isDungeonApplicable(d,filter)) then
        player_res.completed_runs = player_res.completed_runs + d.completed_runs
        player_res.party_deaths = player_res.party_deaths + d.party_deaths
      end
    end
    
    if (player_res.completed_runs > 0) then
      player_res.ddr = player_res.party_deaths / player_res.completed_runs
      filtered_list[player_name] = player_res
    end
  end
  
  return filtered_list
end

function qDA:getDungeonParties(filter)
  local seg = q:getViewingSegment()
   
  local party_data = seg.stats.instances.data and seg.stats.instances.data.parties or {}
  local filtered_list = {}
  for party_key,p in pairs(party_data) do
    local party_res = {completed_runs = 0, boss_kills = 0, boss_wipes = 0, members = p.members}
    
    for k,d in pairs(p.dungeons) do
      if (isDungeonApplicable(d,filter)) then
        party_res.completed_runs = party_res.completed_runs + d.completed_runs
        party_res.boss_kills = party_res.boss_kills + d.boss_kills
        party_res.boss_wipes = party_res.boss_wipes + d.boss_wipes
      end
    end
    
    if (party_res.completed_runs > 0) then
      party_res.kdr = (party_res.boss_wipes > 0 and party_res.boss_kills / party_res.boss_wipes) or party_res.boss_kills
      filtered_list[party_key] = party_res
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

function qDA:getFactions()
  local factions = quantify_reputation.factions
  
  return q:getTableKeys(factions)
end