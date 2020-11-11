local q = quantify

qDA = {}

--- Dungeons ---

function qDA:getDungeonData(filter)
  local seg = q:getViewingSegment()
  
  local dungeons_data = seg.stats.instances.data and seg.stats.instances.data.dungeons or {}
  local filtered_list = {}
  for k,d in pairs(dungeons_data) do
    if (filter.difficulties[d.difficulty] and filter.dungeons[d.name]) then
      filtered_list[k] = d
    end
  end
  return filtered_list
end

function qDA:getDungeonPlayers(filter)
  local seg = q:getViewingSegment()
  
  return seg.stats.instances.data and seg.stats.instances.data.players or {}
end

function qDA:getDungeonParties(filter)
  local seg = q:getViewingSegment()
   
  return seg.stats.instances.data and seg.stats.instances.data.parties or {}
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