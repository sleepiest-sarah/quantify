quantify_bp = {}

local q = quantify
local bp = quantify_bp
local pj = C_PetJournal
local pb = C_PetBattles

local MAX_PET_LEVEL = 25

local petJournalStats = {}

local noFilterSettings = {}
noFilterSettings.Text = ""
noFilterSettings.CollectedChecked = true
noFilterSettings.NotCollectedChecked = false
noFilterSettings.types = nil
noFilterSettings.sources = nil

local userFilterSettings = {}

bp.TYPES = {}
bp.TYPES[1] = "Humanoid" 
bp.TYPES[2] = "Dragonkin" 
bp.TYPES[3] = "Flying" 
bp.TYPES[4] = "Undead" 
bp.TYPES[5] = "Critter" 
bp.TYPES[6] = "Magic" 
bp.TYPES[7] = "Elemental" 
bp.TYPES[8] = "Beast" 
bp.TYPES[9] = "Aquatic" 
bp.TYPES[10] = "Mechanical" 

quantify_bp.MOST_USED_PETS_PREFIX = "most_used_pets_*"

quantify_bp.Session = {}

quantify_bp.MODULE_KEY = "battlepets"

function quantify_bp.Session:new(o)
  o = o or {total_battles = 0, total_trainer_battles = 0, total_wild_battles = 0, total_battle_wins = 0, total_wild_battle_wins = 0, total_trainer_battle_wins = 0, total_forfeits = 0, total_trainer_forfeits = 0, total_wild_forfeits = 0, pet_battle_counts = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local function initPetJournalStats()
  petJournalStats.numPets = 0
  petJournalStats.maxLevelPets = 0
  petJournalStats.numBattlePets = 0
  petJournalStats.numCaughtPets = 0
  petJournalStats.types = {}
  petJournalStats.rarity = {}
end

local function init()
  q.current_segment.stats.battlepets = {}
  q.current_segment.stats.battlepets.raw = quantify_bp.Session:new()
  q.current_segment.stats.battlepets.derived_stats = { }
  session = q.current_segment.stats.battlepets.raw
  
  initPetJournalStats()
end

local function petBattleStart()
  session.total_battles = session.total_battles + 1
  
  if (C_PetBattles.IsWildBattle()) then
    session.total_wild_battles = session.total_wild_battles + 1
  else
    session.total_trainer_battles = session.total_trainer_battles + 1
  end
  
  for i=1,pb.GetNumPets(1) do
    local _,species = pb.GetName(1,i)
    
    if (not session.pet_battle_counts[species]) then
      session.pet_battle_counts[species] = 0
    end
    
    session.pet_battle_counts[species] = session.pet_battle_counts[species] + 1
  end
end

local function petBattleEnd(event,owner)
  if (owner == 1) then
    session.total_battle_wins = session.total_battle_wins + 1
    
    if (C_PetBattles.IsWildBattle()) then
      session.total_wild_battle_wins = session.total_wild_battle_wins + 1
    else
      session.total_trainer_battle_wins = session.total_trainer_battle_wins + 1
    end
  end
end

local function forfeitBattle()
  session.total_forfeits = session.total_forfeits + 1
  
  if (C_PetBattles.IsWildBattle()) then
    session.total_wild_forfeits = session.total_wild_forfeits + 1
  else
    session.total_trainer_forfeits = session.total_trainer_forfeits + 1
  end
end

local function petCaptured(owner, petindex)
  
end

local function petBattleRoundOver(event,roundNumber)
  print("pet battle round over")
end

local function useTrap()
  print("use trap")
end

local function storeFilterSettings()
  userFilterSettings.Text = "" --can't figure how to get the current value for the search box text but have to clear it
  
  userFilterSettings.CollectedChecked = pj.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED)
  userFilterSettings.NotCollectedChecked = pj.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED)
  
  userFilterSettings.types = {}
  for i=1,pj.GetNumPetTypes() do
    userFilterSettings.types[i] = pj.IsPetTypeChecked(i)
  end
  
  userFilterSettings.sources = {}
  for i=1,pj.GetNumPetSources() do
    userFilterSettings.sources[i] = pj.IsPetSourceChecked(i)
  end
end

local function restoreFilterSettings(settings)
  pj.SetSearchFilter(settings.Text) 
  
  pj.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, settings.CollectedChecked)
  pj.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, settings.NotCollectedChecked)
  
  if (settings.types == nil) then
    pj.SetAllPetTypesChecked(true)
  else
    for i,value in pairs(settings.types) do
      pj.SetPetTypeFilter(i,value)
    end
  end
  
  if (settings.types == nil) then
    pj.SetAllPetSourcesChecked(true)
  else
    for i,value in pairs(settings.sources) do
      pj.SetPetSourceChecked(i,value)
    end
  end
end

local function processPetJournal()
  initPetJournalStats()
  
  storeFilterSettings()
  restoreFilterSettings(noFilterSettings)
  
  _,petJournalStats.numPets = pj:GetNumPets()

  for i=1,petJournalStats.numPets do
    local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = pj.GetPetInfoByIndex(i)
    
    if level == MAX_PET_LEVEL then
      petJournalStats.maxLevelPets = petJournalStats.maxLevelPets + 1
    end
    
    if canBattle then
      petJournalStats.numBattlePets = petJournalStats.numBattlePets + 1
    end
    
    if isWild then
      petJournalStats.numCaughtPets = petJournalStats.numCaughtPets + 1
    end
    
    local petTypeString = bp.TYPES[petType]
    local numType = petJournalStats.types[petTypeString] or 0
    petJournalStats.types[petTypeString] = numType + 1
    
    local health, maxHealth, power, speed, rarity = pj.GetPetStats(petID)
    local rarityString = _G["BATTLE_PET_BREED_QUALITY"..rarity]
    local numRarity = petJournalStats.rarity[rarityString] or 0
    petJournalStats.rarity[rarityString] = numRarity + 1
  end
  
  restoreFilterSettings(userFilterSettings)
end

local function sortPetCounts(pet_counts)
  local keys = {}
  table.foreach(pet_counts, function(k,v) table.insert(keys,k); end)
  table.sort(keys,function(a,b) return pet_counts[a] > pet_counts[b] end)
  
  return keys
end

local function petJournalUpdate(event)
  processPetJournal()
end

function quantify_bp:calculateDerivedStats(segment)
  local derived_stats = {}
  
  local raw = segment.stats.battlepets.raw
  derived_stats.pct_battle_wins = (raw.total_battle_wins / raw.total_battles) * 100
  derived_stats.pct_trainer_battle_wins = (raw.total_trainer_battle_wins / raw.total_trainer_battles) * 100
  derived_stats.pct_wild_battle_wins = (raw.total_wild_battle_wins / raw.total_wild_battles) * 100
  derived_stats.pct_battle_wins_no_forfeits = (raw.total_battle_wins / (raw.total_battles - raw.total_forfeits)) * 100
  derived_stats.pct_trainer_battle_wins_no_forfeits = (raw.total_trainer_battle_wins / (raw.total_trainer_battles - raw.total_trainer_forfeits)) * 100
  derived_stats.pct_wild_battle_wins_no_forfeits = (raw.total_wild_battle_wins / (raw.total_wild_battles - raw.total_wild_forfeits)) * 100
  
  derived_stats.total_pets = petJournalStats.numPets
  derived_stats.max_level_pets = petJournalStats.maxLevelPets
  derived_stats.combat_pets = petJournalStats.numBattlePets
  derived_stats.wild_caught_pets = petJournalStats.numCaughtPets
  
  for rarity,n in pairs(petJournalStats.rarity) do
    derived_stats["num_rarity_*"..rarity] = n
  end
  
  for pettype,n in pairs(petJournalStats.types) do
    derived_stats["num_type_*"..pettype] = n
  end
  
  local sorted_pet_keys = sortPetCounts(raw.pet_battle_counts)
  for i=1,3 do
    if (sorted_pet_keys[i]) then
      derived_stats[bp.MOST_USED_PETS_PREFIX..sorted_pet_keys[i]] = raw.pet_battle_counts[sorted_pet_keys[i]]
    end
  end
  
  segment.stats.battlepets.derived_stats = derived_stats
end

function quantify_bp:updateStats(segment)
  quantify_bp:calculateDerivedStats(segment)
end
 
function quantify_bp:newSegment(previous_seg,new_seg)
  init()
end

init()

if (q.isRetail) then
  table.insert(quantify.modules, quantify_bp)

  quantify:registerEvent("PET_BATTLE_OPENING_DONE", petBattleStart)
  quantify:registerEvent("PET_BATTLE_FINAL_ROUND", petBattleEnd)
  quantify:registerEvent("PET_BATTLE_CAPTURED", petCaptured)
  quantify:registerEvent("PET_BATTLE_PET_ROUND_RESULTS", petBattleRoundOver)
  quantify:registerEvent("UPDATE_SUMMONPETS_ACTION", petJournalUpdate)  --initial load and adding
  quantify:registerEvent("PET_JOURNAL_PET_DELETED", petJournalUpdate) --cage
  
  q:hookSecureFunc("ForfeitGame", forfeitBattle, C_PetBattles)
  q:hookSecureFunc("UseTrap", useTrap, C_PetBattles)
  q:hookSecureFunc("ReleasePetByID", petJournalUpdate, C_PetJournal)    --release
end

