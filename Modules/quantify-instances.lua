quantify_instances = {}

local q = quantify

quantify_instances.Session = {}

quantify_instances.MODULE_KEY = "instances"
quantify_instances.RAW_DUNGEON_BOSS_KILL_PREFIX = "dungeon_boss_kill_*"
quantify_instances.RAW_RAID_BOSS_KILL_PREFIX = "raid_boss_kill_*"
quantify_instances.RAW_DUNGEON_BOSS_WIPE_PREFIX = "dungeon_boss_wipe_*"
quantify_instances.RAW_RAID_BOSS_WIPE_PREFIX = "raid_boss_wipe_*"
quantify_instances.BFA_DUNGEON_TIME_PREFIX = "bfa_dungeon_time_*"
quantify_instances.BFA_DUNGEON_COMPLETED_PREFIX = "bfa_dungeon_completed_*"

function quantify_instances.Session:new(o)
  o = o or {legion_raid_boss_kills = 0, legion_raid_boss_wipes = 0, legion_dungeon_boss_kills = 0, legion_dungeon_boss_wipes = 0, bfa_raid_boss_kills = 0, bfa_raid_boss_wipes = 0, bfa_dungeon_boss_kills = 0, bfa_dungeon_boss_wipes = 0, overall_raid_boss_kills = 0, overall_raid_boss_wipes = 0, overall_dungeon_boss_kills = 0, overall_dungeon_boss_wipes = 0, player_raid_deaths = 0, player_dungeon_deaths = 0, bfa_dungeon_time = {}, bfa_total_dungeon_completed = 0, party_members = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local function init()
  q.current_segment.stats[quantify_instances.MODULE_KEY] = {}
  q.current_segment.stats[quantify_instances.MODULE_KEY].raw = quantify_instances.Session:new()
  session = q.current_segment.stats[quantify_instances.MODULE_KEY].raw
end

local function incrementPrefix(prefix, instance, difficulty)
  local key = prefix .. instance
  if (difficulty ~= nil) then
    key = key.."-"..difficulty
  end
  if (session[key] == nil) then
    session[key] = 0
  end
  session[key] = session[key] + 1
end

local function updatePartyStats(kill, wipe, player_death, dungeon)
  local num_members = GetNumGroupMembers()
  
  for i=1,num_members do
    local mate = GetUnitName("party"..i, true)
    if (session.party_members[mate] == nil) then
      session.party_members[mate] = {dungeons_completed = 0, kills = 0, wipes = 0, player_deaths = 0}
    end
    
    dungeon = dungeon or 0
    kill = kill or 0
    wipe = wipe or 0
    player_death = player_death or 0
    
    session.party_members[mate].dungeons_completed = session.party_members[mate].dungeons_completed + dungeon
    session.party_members[mate].kills = session.party_members[mate].kills + kill
    session.party_members[mate].wipes = session.party_members[mate].wipes + wipe
    session.party_members[mate].player_deaths = session.party_members[mate].player_deaths + player_death
  end
  
end

local function encounterEnd(event, ...)
  local encounterID, encounterName, difficultyID, groupSize, success = unpack({...})
  --print("encounterId: ", encounterID)
  
  if quantify_state:isPlayerInLegionRaid() then
    if (success == 1) then
      session.legion_raid_boss_kills = session.legion_raid_boss_kills + 1
    else
      session.legion_raid_boss_wipes = session.legion_raid_boss_wipes + 1
    end
  elseif quantify_state:isPlayerInLegionDungeon() then
    if (success == 1) then
      session.legion_dungeon_boss_kills = session.legion_dungeon_boss_kills + 1
    else
      session.legion_dungeon_boss_wipes = session.legion_dungeon_boss_wipes + 1
    end    
  end
  
  if quantify_state:isPlayerInBfaRaid() then
    if (success == 1) then
      session.bfa_raid_boss_kills = session.bfa_raid_boss_kills + 1
    else
      session.bfa_raid_boss_wipes = session.bfa_raid_boss_wipes + 1
    end
  elseif quantify_state:isPlayerInBfaDungeon() then
    if (success == 1) then
      session.bfa_dungeon_boss_kills = session.bfa_dungeon_boss_kills + 1
      updatePartyStats(1,0,0,0)
    else
      session.bfa_dungeon_boss_wipes = session.bfa_dungeon_boss_wipes + 1
      updatePartyStats(0,1,0,0)
    end    
  end
  
  local instance_name = quantify_state:getInstanceName()
  if (success == 1 and quantify_state:getInstanceType() == "party") then
    incrementPrefix(quantify_instances.RAW_DUNGEON_BOSS_KILL_PREFIX,instance_name,quantify_state:getInstanceDifficulty())
    session.overall_dungeon_boss_kills = session.overall_dungeon_boss_kills + 1
  elseif (success == 1 and quantify_state:getInstanceType() == "raid") then
    incrementPrefix(quantify_instances.RAW_RAID_BOSS_KILL_PREFIX, instance_name, quantify_state:getInstanceDifficulty())
    session.overall_raid_boss_kills = session.overall_raid_boss_kills + 1
  elseif (success == 0 and quantify_state:getInstanceType() == "party") then
    incrementPrefix(quantify_instances.RAW_DUNGEON_BOSS_WIPE_PREFIX, instance_name,quantify_state:getInstanceDifficulty())
    session.overall_dungeon_boss_wipes = session.overall_dungeon_boss_wipes + 1
  elseif (success == 0 and quantify_state:getInstanceType() == "raid") then
    incrementPrefix(quantify_instances.RAW_RAID_BOSS_WIPE_PREFIX, instance_name,quantify_state:getInstanceDifficulty())
    session.overall_raid_boss_wipes = session.overall_raid_boss_wipes + 1
  end
  

end

local function playerDead(event, ...)
  if (quantify_state:isPlayerInInstance()) then
    if (quantify_state:getInstanceType() == "raid") then
      session.player_raid_deaths = session.player_raid_deaths + 1
    elseif (quantify_state:getInstanceType() == "party") then
      session.player_dungeon_deaths = session.player_dungeon_deaths + 1
      updatePartyStats(0,0,1,0)
    end
  end
end

local function bossKill(event, encounterId, encounterName)
  print(event, encounterId, encounterName)
  
  print(q:contains(q.BFA_END_BOSS_IDS, encounterId),quantify_state:isPlayerInBfaDungeon(),quantify_state:getInstanceStartTime() ~= nil)
  print(quantify_state.state.instance_map_id, quantify_state.state.instance_name, quantify_state.state.instance_type)
  if ((q:contains(q.BFA_END_BOSS_IDS, encounterId) or q:contains(q.BFA_END_BOSSES, encounterName)) and quantify_state:getInstanceStartTime() ~= nil) then
    session.bfa_total_dungeon_completed = session.bfa_total_dungeon_completed + 1
    
    local key = quantify_state:getInstanceName().."-"..quantify_state:getInstanceDifficulty()
    if (session.bfa_dungeon_time[key] == nil) then
      session.bfa_dungeon_time[key] = {n = 0, time = 0}
    end
    session.bfa_dungeon_time[key].n = session.bfa_dungeon_time[key].n + 1
    session.bfa_dungeon_time[key].time = session.bfa_dungeon_time[key].time + (GetTime() - quantify_state:getInstanceStartTime())
    
    updatePartyStats(0,0,0,1)
  end
  
end

local function getTopKda(party)
  
end

function quantify_instances:calculateDerivedStats(segment)
  local derived = {}
  
  if (segment.stats.instances.raw ~= nil and segment.stats.instances.raw.bfa_dungeon_time ~= nil) then
    for k,v in pairs(segment.stats.instances.raw.bfa_dungeon_time) do
      local time,completed = quantify_instances.BFA_DUNGEON_TIME_PREFIX..k, quantify_instances.BFA_DUNGEON_COMPLETED_PREFIX..k
      
      derived[time] = v.time / v.n
      derived[completed] = v.n
    end
  end
  
  if (segment.stats.instances.raw ~= nil and segment.stats.instances.raw.party_members ~= nil and q:length(segment.stats.instances.raw.party_members) > 0) then
    local party = segment.stats.instances.raw.party_members
    
    --superlatives
    local most_kills = q:getKeyForMaxValue(party,"kills")
    local most_player_deaths = q:getKeyForMaxValue(party,"player_deaths")
    local most_wipes = q:getKeyForMaxValue(party,"wipes")
    local most_completed_dungeons = q:getKeyForMaxValue(party,"dungeons_completed")
    local highest_kdr = getTopKda(party)
    
    
    derived["most_kills_*"..most_kills] = party[most_kills].kills
    derived["most_player_deaths_*"..most_player_deaths] = party[most_player_deaths].player_deaths
    derived["most_wipes_*"..most_wipes] = party[most_wipes].wipes
    derived["most_completed_dungeons_*"..most_completed_dungeons] = party[most_completed_dungeons].dungeons_completed
    
    local wipes = party[highest_kdr].wipes == 0 and 1 or party[highest_kdr].wipes
    derived["highest_kdr_*"..highest_kdr] = party[highest_kdr].kills / wipes
    
    --top 4 party members
    local party_keys = {}
    table.foreach(party, function(k,v) table.insert(party_keys,k); end)
    table.sort(party_keys,function(a,b) return party[a].dungeons_completed > party[b].dungeons_completed end)
    
    for i=1,4 do
      if (party_keys[i] ~= nil) then
        local key = party_keys[i]
        wipes = party[key].wipes == 0 and 1 or party[key].wipes
        derived["party_member_completed_dungeons_*"..key] = party[key].dungeons_completed
        derived["party_member_kdr_*"..key] = party[key].kills / wipes
      end
    end
    
  end
  
  segment.stats.instances.derived_stats = derived
end

function quantify_instances:updateStats(segment)
  quantify_instances:calculateDerivedStats(segment)
end
 
function quantify_instances:newSegment(previous_seg,new_seg)
  
  init()
  
end

init()

table.insert(quantify.modules, quantify_instances)
  
q:registerEvent("ENCOUNTER_END", encounterEnd)
q:registerEvent("PLAYER_DEAD", playerDead)
q:registerEvent("BOSS_KILL", bossKill)