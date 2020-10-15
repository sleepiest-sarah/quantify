quantify_instances = {}
local qi = quantify_instances

local q = quantify

quantify_instances.MODULE_KEY = "instances"

quantify_instances.keys = {
  DUNGEON = "instances/data/dungeons/",
  PARTY = "instances/data/parties/",
  PLAYER = "instances/data/players/",
  LEGION_RAID_BOSS_KILLS = "instances/stats/legion_raid_boss_kills",
  LEGION_DUNGEON_BOSS_KILLS = "instances/stats/legion_dungeon_boss_kills",
  LEGION_DUNGEON_BOSS_WIPES = "instances/stats/legion_dungeon_boss_wipes",
  OVERALL_RAID_BOSS_KILLS = "instances/stats/overall_raid_boss_kills",
  OVERALL_RAID_BOSS_WIPES = "instances/stats/overall_raid_boss_wipes",
  OVERALL_DUNGEON_BOSS_KILLS = "instances/stats/overall_dungeon_boss_kills",
  OVERALL_DUNGEON_BOSS_WIPES = "instances/stats/overall_dungeon_boss_wipes",  
  PLAYER_RAID_DEATHS = "instances/stats/player_raid_deaths",
  PLAYER_DUNGEON_DEATHS = "instances/stats/player_dungeon_deaths",
  SL_TOTAL_DUNGEON_COMPLETED = "instances/stats/sl_total_dungeon_completed"
}

local keys = qi.keys

quantify_instances.DUNGEON_TEMPLATE = {
    name = "",
    difficulty = "",
    instance_map_id = 0,
    keystone_level = 0,
    affixes = nil,
    party_deaths = 0,
    player_deaths = 0,
    boss_kills = 0,
    boss_wipes = 0,
    wipes = 0,
    cumulative_time = 0,
    completed_runs = 0,
    on_time_runs = 0,
    over_time_runs = 0,
    plus_1_runs = 0,
    plus_2_runs = 0,
    plus_3_runs = 0,
    kdr = 0, --boss kills to boss wipes ratio
    ddr = 0, --party deaths per completion
    wdr = 0, --wipes per completion
    avg_time = 0,
    affixes = nil,
    history = nil
  }
  
quantify_instances.PLAYER_TEMPLATE = {
  name = "",
  boss_kills = 0,
  boss_wipes = 0,
  wipes = 0,
  party_deaths = 0,
  deaths = 0,
  completed_runs = 0,
  kdr = 0,
  ddr = 0,
  wdr = 0,
  dungeons = nil,
  history = nil
}

quantify_instances.PARTY_TEMPLATE = {
  members = nil,
  boss_kills = 0,
  boss_wipes = 0,
  wipes = 0,
  party_deaths = 0,
  completed_runs = 0,
  kdr = 0,
  ddr = 0,
  wdr = 0,
  dungeons = nil,
  history = nil
}

local dead_time = 0

local current_dungeon_run = nil

local function initializeFromTemplate(obj, template)
  obj = obj or {}
    
  for k,v in pairs(template) do
    obj[k] = obj[k] or v
  end
end

local function getDungeonKey(name, difficulty, keystoneLevel)
  if (keystoneLevel and keystoneLevel > 0) then
    return name.."-"..difficulty.."-"..keystoneLevel
  else 
    return name.."-"..difficulty
  end
end

local function getAffixesKey(affixes)
  if (not affixes) then
    return nil
  end
  
  table.sort(affixes)
  
  local key = nil
  for id,affix in pairs(affixes) do
    if (key) then
      key = key.."-"..affix
    else
      key = affix
    end
  end
  
  return key
end

local function updateDungeonStats(dungeons, run, noHistory)
  local dungeon_key = getDungeonKey(run.name, run.difficulty, run.keystone_level)
  local dungeon = initializeFromTemplate(dungeons[dungeon_key], qi.DUNGEON_TEMPLATE)
  dungeons[dungeon_key] = dungeon
  
  dungeon.name = run.name
  dungeon.difficulty = run.difficulty
  dungeon.keystone_level = run.keystone_level
  
  dungeon.party_deaths = dungeon.party_deaths + run.party_deaths
  dungeon.player_deaths = dungeon.player_deaths + run.player_deaths
  dungeon.boss_kills = dungeon.boss_kills + run.boss_kills
  dungeon.boss_wipes = dungeon.boss_wipes + run.boss_wipes
  dungeon.wipes = dungeon.wipes + run.wipes
  dungeon.cumulative_time = dungeon.cumulative_time + (run.end_time - run.start_time)
  dungeon.completed_runs = dungeon.completed_runs + 1
  
  if (current_dungeon_run.keystone_level and run.keystone_level > 0) then
    dungeon.on_time_runs = dungeon.on_time_runs + (run.on_time and 1 or 0)
    dungeon.over_time_runs = dungeon.over_time_runs + (not run.on_time and 1 or 0)
    
    dungeon.plus_1_runs = dungeon.plus_1_runs + (run.keystone_upgrade_levels == 1 and 1 or 0)
    dungeon.plus_2_runs = dungeon.plus_2_runs + (run.keystone_upgrade_levels == 2 and 1 or 0)
    dungeon.plus_3_runs = dungeon.plus_3_runs + (run.keystone_upgrade_levels == 3 and 1 or 0)
    
    local affix_key = getAffixesKey(run.affixes)
    if (not dungeon.affixes[affix_key]) then
      dungeon.affixes[affix_key] = q:shallowCopy(qi.DUNGEON_TEMPLATE)
    end
    q:addTables(dungeon.affixes[affix_key],dungeon, true)
  end
  
  if (not noHistory) then
  
    if (not dungeon.history) then
      dungeon.history = {}
    end
    
    local r = {}
    r.date = GetTime()
    r.keystone_level = run.keystone_level
    r.affixes = getAffixesKey(run.affixes)
    r.party_deaths = run.party_deaths
    r.player_deaths = run.player_deaths
    r.boss_kills = run.boss_kills
    r.boss_wipes = run.boss_wipes
    r.wipes = run.wipes
    r.time = run.end_time - run.start_time
    r.on_time = run.on_time
    r.keystone_upgrade_levels = run.keystone_upgrade_levels
    r.kdr = run.boss_kills / (run.boss_wipes == 0 and 1 or run.boss_wipes)
    r.party = run.party:getPartyKey()
    
    run.history = r

    table.insert(dungeon.history,r)
  end
  
end

local function updatePlayerStats(players, run)
  run.party_members[quantify_state:getPlayerNameRealm()] = {deaths = run.player_deaths}
  
  for mate,v in pairs(run.party_members) do
    local player = initializeFromTemplate(players[mate], qi.PLAYER_TEMPLATE)
    players[mate] = player
    
    player.deaths = v.deaths
    player.party_deaths = player.party_deaths + run.party_deaths
    player.boss_kills = player.boss_kills + run.boss_kills
    player.boss_wipes = player.boss_wipes + run.boss_wipes
    player.wipes = player.wipes + run.wipes
    player.cumulative_time = player.cumulative_time + (run.end_time - run.start_time)
    player.completed_runs = player.completed_runs + 1

    if (current_dungeon_run.keystone_level and run.keystone_level > 0) then
      player.on_time_runs = player.on_time_runs + (run.on_time and 1 or 0)
      player.over_time_runs = player.over_time_runs + (not run.on_time and 1 or 0)
      
      player.plus_1_runs = player.plus_1_runs + (run.keystone_upgrade_levels == 1 and 1 or 0)
      player.plus_2_runs = player.plus_2_runs + (run.keystone_upgrade_levels == 2 and 1 or 0)
      player.plus_3_runs = player.plus_3_runs + (run.keystone_upgrade_levels == 3 and 1 or 0)
      
      local affix_key = getAffixesKey(run.affixes)
      if (not player.affixes[affix_key]) then
        player.affixes[affix_key] = q:shallowCopy(qi.DUNGEON_TEMPLATE)
      end
      q:addTables(player.affixes[affix_key],player, true)
    end 
    
    player.dungeons = player.dungeons or {}
    updateDungeonStats(player.dungeons, current_dungeon_run, true)
    
    player.history = player.history or {}
    table.insert(player.history, run.history)
  end
end

local function updatePartyStats(parties, run)
  local party_key = run.party:getPartyKey()
  local party = initializeFromTemplate(parties[party_key], qi.PARTY_TEMPLATE)
  party[party_key] = party
  
  party.party_deaths = party.party_deaths + run.party_deaths
  party.boss_kills = party.boss_kills + run.boss_kills
  party.boss_wipes = party.boss_wipes + run.boss_wipes
  party.wipes = party.wipes + run.wipes
  party.cumulative_time = party.cumulative_time + (run.end_time - run.start_time)
  party.completed_runs = party.completed_runs + 1

  if (current_dungeon_run.keystone_level and run.keystone_level > 0) then
    party.on_time_runs = party.on_time_runs + (run.on_time and 1 or 0)
    party.over_time_runs = party.over_time_runs + (not run.on_time and 1 or 0)
    
    party.plus_1_runs = party.plus_1_runs + (run.keystone_upgrade_levels == 1 and 1 or 0)
    party.plus_2_runs = party.plus_2_runs + (run.keystone_upgrade_levels == 2 and 1 or 0)
    party.plus_3_runs = party.plus_3_runs + (run.keystone_upgrade_levels == 3 and 1 or 0)
    
    local affix_key = getAffixesKey(run.affixes)
    if (not party.affixes[affix_key]) then
      party.affixes[affix_key] = q:shallowCopy(qi.DUNGEON_TEMPLATE)
    end
    q:addTables(party.affixes[affix_key],party, true)
  end 
  
  party.dungeons = party.dungeons or {}
  updateDungeonStats(party.dungeons, current_dungeon_run, true)
  
  party.history = party.history or {}
  table.insert(party.history, run.history)
end

local function dungeonCompleted()
  if (current_dungeon_run) then
    
    current_dungeon_run.end_time = GetTime()
    
    q:updateStatBlock(keys.DUNGEON, updateDungeonStats, current_dungeon_run)
    q:updateStatBlock(keys.PLAYER, updatePlayerStats, current_dungeon_run)
    q:updateStatBlock(keys.PARTY, updatePartyStats, current_dungeon_run)
    
    current_dungeon_run = nil
  end
end

local function encounterEnd(event, ...)
  local encounterID, encounterName, difficultyID, groupSize, success = unpack({...})
  
  if quantify_state:isPlayerInLegionRaid() then
    if (success == 1) then
      q:incrementStat("LEGION_RAID_BOSS_KILLS", 1)
    else
      q:incrementStat("LEGION_RAID_BOSS_WIPES",1)
    end
  elseif quantify_state:isPlayerInLegionDungeon() then
    if (success == 1) then
      q:incrementStat("LEGION_DUNGEON_BOSS_KILLS",1)
    else
      q:incrementStat("LEGION_DUNGEON_BOSS_WIPES", 1)
    end    
  end
  
  if quantify_state:isPlayerInBfaRaid() then
    if (success == 1) then
      q:incrementStat("BFA_RAID_BOSS_KILLS",1)
    else
      q:incrementStat("BFA_RAID_BOSS_WIPES",1)
    end
  elseif quantify_state:isPlayerInBfaDungeon() then
    if (success == 1) then
      q:incrementStat("BFA_DUNGEON_BOSS_KILLS",1)
    else
      q:incrementStat("BFA_DUNGEON_BOSS_WIPES",1)
    end    
  end
  
  local instance_name = quantify_state:getInstanceName()
  if (success == 1 and quantify_state:getInstanceType() == "party") then
    q:incrementStat("OVERALL_DUNGEON_BOSS_KILLS",1)
    
    current_dungeon_run.boss_kills = current_dungeon_run.boss_kills + 1
  elseif (success == 1 and quantify_state:getInstanceType() == "raid") then
    --incrementPrefix(quantify_instances.RAW_RAID_BOSS_KILL_PREFIX, instance_name, quantify_state:getInstanceDifficulty())
    q:incrementStat("OVERALL_RAID_BOSS_KILLS",1)
  elseif (success == 0 and quantify_state:getInstanceType() == "party") then
    q:incrementStat("OVERALL_DUNGEON_BOSS_WIPES",1)
    
    current_dungeon_run.boss_wipes = current_dungeon_run.boss_wipes + 1
  elseif (success == 0 and quantify_state:getInstanceType() == "raid") then
    --incrementPrefix(quantify_instances.RAW_RAID_BOSS_WIPE_PREFIX, instance_name,quantify_state:getInstanceDifficulty())
    q:incrementStat("OVERALL_RAID_BOSS_WIPES",1)
  end
  
  if (quantify_state:isCurrentDungeonComplete()) then
    dungeonCompleted()
  end
  
end

local function playerDead(event, ...)
  if (quantify_state:isPlayerInInstance() and (GetTime() - dead_time > quantify.EVENT_WINDOW)) then
    if (quantify_state:getInstanceType() == "raid") then
      q:incrementStat("PLAYER_RAID_DEATHS",1)
    elseif (quantify_state:getInstanceType() == "party") then
      q:incrementStat("PLAYER_DUNGEON_DEATHS",1)
    end
    
    dead_time = GetTime()
  end
end

local function bossKill(event, encounterId, encounterName)
  local sl_dungeon = q:contains(q.SL_END_BOSS_IDS, encounterId)
  local bfa_dungeon = q:contains(q.BFA_END_BOSS_IDS, encounterId) or q:contains(q.BFA_END_BOSSES, encounterName)
  
  if (sl_dungeon) then
    q:incrementStat("SL_TOTAL_DUNGEON_COMPLETED",1)
  end
  
  if (bfa_dungeon) then
    q:incrementStat("BFA_TOTAL_DUNGEON_COMPLETED",1)
  end
  
end

local function updatePartyStatus()
  local num_members = GetNumGroupMembers()
  local grouptype = q:getUnitGroupPrefix()
  
  local party = {}
  local wipe = UnitIsDeadOrGhost("player")
  for i=1,num_members-1 do
    party[i] = not UnitIsDeadOrGhost(grouptype..i)
    wipe = wipe and not party[i]                              --will set wipe to false if any members are alive
  end
  
  if (wipe) then
    current_dungeon_run.wipes = current_dungeon_run.wipes + 1
  end

end

local function playerRegen(event)
  
  if (event == "PLAYER_REGEN_DISABLED" and current_dungeon_run and current_dungeon_run.start_time == nil) then
    current_dungeon_run.start_time = GetTime()
  end
end

local function combatLog()
  local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()  
  
  if (event == "UNIT_DIED") then
    local affiliation = bit.band(destFlags, 0xf)
    local type_controller = bit.band(destFlags, 0xff00)

    if (type_controller == 0x0500 and (affiliation == 1 or affiliation == 2 or affiliation == 4)) then --player-controlled player and self/party/raid
      updatePartyStatus()
      
      current_dungeon_run.party_deaths = current_dungeon_run.party_deaths + 1
    end
  end
  
end

local function getTopKda(party)
  local max_kda = -math.huge
  local max_key = nil
  
  for k,v in pairs(party) do
    local wipes = v.wipes == 0 and 1 or v.wipes
    local kda = v.kills / wipes
    if (kda > max_kda) then
      max_kda = kda
      max_key = k
    end
  end
  
  return max_key
end

local function initializeParty()
  local num_members = GetNumGroupMembers()
  
  local grouptype = q:getUnitGroupPrefix()
  
  for i=1,num_members-1 do
    local mate = GetUnitName(grouptype..i, true)
    if (current_dungeon_run.party_members[mate] == nil) then
      current_dungeon_run.party_members[mate] = {deaths = 0}
    end
  end
  
  current_dungeon_run.party = quantify_state:GetPlayerParty()
end

local function enteredNewInstance(event, instance_map_id, instance_difficulty)
  if (quantify_state:getInstanceType() == "party") then
    current_dungeon_run = q:shallowCopy(qi.DUNGEON_TEMPLATE)
    current_dungeon_run.instance_map_id = instance_map_id
    current_dungeon_run.name = GetRealZoneText(instance_map_id)
    current_dungeon_run.difficulty = instance_difficulty
    
    initializeParty()
  end
end

local function keystoneStart(event, mapId)
  current_dungeon_run.start_time = GetTime()
  local activeKeystoneLevel, activeAffixIds = C_ChallengeMode.GetActiveKeystoneInfo()
  current_dungeon_run.keystone_level = activeKeystoneLevel
  
  local affixes = {}
  for i,id in pairs(activeAffixIds) do
    affixes[id] = C_ChallengeMode.GetAffixInfo(id)
  end
  
  current_dungeon_run.affixes = affixes
end

local function keystoneComplete(event, mapId)
  current_dungeon_run.end_time = GetTime()
  
  local mapChallengeModeID, level, time, onTime, keystoneUpgradeLevels, practiceRun = C_ChallengeMode.GetCompletionInfo()
  
  current_dungeon_run.on_time = onTime
  current_dungeon_run.keystone_level = level
  current_dungeon_run.keystone_upgrade_levels = keystoneUpgradeLevels
  
  dungeonCompleted()
end

function quantify_instances:calculateDerivedStats(segment)

end

local function setEmptyStats(o)
  o.party_deaths = o.party_deaths or 0
  o.completed_runs = o.completed_runs or 0
  o.boss_kills = o.boss_kills or 0
  o.boss_wipes = o.boss_wipes or 0
  o.wipes = o.wipes or 0
  o.cumulative_time = o.cumulative_time or 0
end

function quantify_instances:updateData(segment)
  if (segment.data and segment.data.players and segment.data.parties) then
    local data = segment.data
    
    for k,dungeon in pairs(data.dungeons) do
      setEmptyStats(dungeon)
      
      dungeon.ddr = dungeon.party_deaths / (dungeon.completed_runs == 0 and 1 or dungeon.completed_runs)
      dungeon.kdr = dungeon.boss_kills / (dungeon.boss_wipes == 0 and 1 or dungeon.boss_wipes)
      dungeon.wdr = dungeon.wipes / (dungeon.completed_runs == 0  and 1 or dungeon.completed_runs)
      dungeon.avg_time = dungeon.cumulative_time / (dungeon.completed_runs == 0 and 1 or dungeon.completed_runs)
    end
    
    for k,player in pairs(data.players) do
      setEmptyStats(player)
      
      player.kdr = player.boss_kills/  (player.boss_wipes == 0 and 1 or player.boss_wipes)
      player.ddr = player.party_deaths / (player.dungeons_completed == 0 and 1 or player.dungeons_completed)
      player.wdr = player.wipes / (player.completed_runs == 0 and 1 or player.completed_runs)
    end
    
    for k,party in pairs(data.parties) do
      setEmptyStats(party)
      
      party.kdr = party.boss_kills / (party.boss_wipes == 0 and 1 or party.boss_wipes)
      party.ddr = party.player_deaths / (party.dungeons_completed == 0 and 1 or party.dungeons_completed)
      party.wdr = party.wipes / (party.completed_runs == 0 and 1 or party.completed_runs)
    end
  end
end

function quantify_instances:updateStats(segment)
  quantify_instances:calculateDerivedStats(segment)
  
  quantify_instances:updateData(segment)
end
 
function quantify_instances:newSegment(segment)
  segment.data = segment.data or {}
  segment.data.players = segment.data.players or {}
  segment.data.raids = segment.data.raids or {}
  segment.data.dungeons = segment.data.dungeons or {}
  segment.data.parties = segment.data.parties or {}
  
  segment.stats = q:addKeysLeft(segment.stats,
            {legion_raid_boss_kills = 0,
              legion_raid_boss_wipes = 0, 
              legion_dungeon_boss_kills = 0, 
              legion_dungeon_boss_wipes = 0, 
              bfa_raid_boss_kills = 0, 
              bfa_raid_boss_wipes = 0, 
              bfa_dungeon_boss_kills = 0, 
              bfa_dungeon_boss_wipes = 0, 
              overall_raid_boss_kills = 0, 
              overall_raid_boss_wipes = 0, 
              overall_dungeon_boss_kills = 0, 
              overall_dungeon_boss_wipes = 0, 
              player_raid_deaths = 0, 
              player_dungeon_deaths = 0, 
              bfa_total_dungeon_completed = 0,
              sl_total_dungoen_completed = 0})
end

table.insert(quantify.modules, quantify_instances)
  

q:registerEvent("PLAYER_DEAD", playerDead)
q:registerEvent("PLAYER_REGEN_DISABLED", playerRegen)
q:registerEvent("PLAYER_REGEN_ENABLED", playerRegen)
q:registerEvent("COMBAT_LOG_EVENT_UNFILTERED", combatLog)

q:registerQEvent("ENTERED_NEW_INSTANCE", enteredNewInstance)
q:registerQEvent("LEFT_INSTANCE", leftInstance)

if (q.isRetail) then
  q:registerEvent("BOSS_KILL", bossKill)
  q:registerEvent("ENCOUNTER_END", encounterEnd)
  q:registerEvent("CHALLENGE_MODE_START", keystoneStart)
  q:registerEvent("CHALLENGE_MODE_RESET", keystoneStart)
  q:registerEvent("CHALLENGE_MODE_COMPLETED", keystoneComplete)
end