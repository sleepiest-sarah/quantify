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

bp.PET_BATTLE_COUNT_PATH = "battlepets/data/pet_battle_counts/"

quantify_bp.MODULE_KEY = "battlepets"

local function initPetJournalStats()
  petJournalStats.numPets = 0
  petJournalStats.maxLevelPets = 0
  petJournalStats.numBattlePets = 0
  petJournalStats.numCaughtPets = 0
  petJournalStats.types = {}
  petJournalStats.rarity = {}
end

local function petBattleStart()
  q:incrementStat("TOTAL_BATTLES",1)
  
  if (C_PetBattles.IsWildBattle()) then
    q:incrementStat("TOTAL_WILD_BATTLES",1)
  else
    q:incrementStat("TOTAL_TRAINER_BATTLES",1)
  end
  
  for i=1,pb.GetNumPets(1) do
    local _,species = pb.GetName(1,i)
    
    q:incrementStatByPath(bp.PET_BATTLE_COUNT_PATH..species,1)
  end
end

local function petBattleEnd(event,owner)
  if (owner == 1) then
    q:incrementStat("TOTAL_BATTLE_WINS",1)
    
    if (C_PetBattles.IsWildBattle()) then
      q:incrementStat("TOTAL_WILD_BATTLE_WINS",1)
    else
      q:incrementStat("TOTAL_TRAINER_BATTLE_WINS",1)
    end
  end
end

local function forfeitBattle()
  q:incrementStat("TOTAL_FORFEITS",1)
  
  if (C_PetBattles.IsWildBattle()) then
    q:incrementStat("TOTAL_WILD_FORFEITS",1)
  else
    q:incrementStat("TOTAL_TRAINER_FORFEITS",1)
  end
end

local function petCaptured(owner, petindex)
  
end

local function petBattleRoundOver(event,roundNumber)
  --print("pet battle round over")
end

local function useTrap()
  --print("use trap")
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
  local stats = segment.stats

  stats.pct_battle_wins = stats.total_battles == 0 and 0 or (stats.total_battle_wins / stats.total_battles) * 100
  stats.pct_trainer_battle_wins = stats.total_trainer_battles == 0 and 0 or (stats.total_trainer_battle_wins / stats.total_trainer_battles) * 100
  stats.pct_wild_battle_wins = stats.total_wild_battles == 0 and 0 or (stats.total_wild_battle_wins / stats.total_wild_battles) * 100
  stats.pct_battle_wins_no_forfeits = stats.total_battles == 0 and 0 or (stats.total_battle_wins / (stats.total_battles - stats.total_forfeits)) * 100
  stats.pct_trainer_battle_wins_no_forfeits = (stats.total_trainer_battles - stats.total_trainer_forfeits) == 0 and 0 or (stats.total_trainer_battle_wins / (stats.total_trainer_battles - stats.total_trainer_forfeits)) * 100
  stats.pct_wild_battle_wins_no_forfeits = (stats.total_wild_battles - stats.total_wild_forfeits) == 0 and 0 or (stats.total_wild_battle_wins / (stats.total_wild_battles - stats.total_wild_forfeits)) * 100
  
  stats.total_pets = petJournalStats.numPets
  stats.max_level_pets = petJournalStats.maxLevelPets
  stats.combat_pets = petJournalStats.numBattlePets
  stats.wild_caught_pets = petJournalStats.numCaughtPets
  
  stats.pet_rarity = {}
  for rarity,n in pairs(petJournalStats.rarity) do
    stats.pet_rarity[rarity] = n
  end
  
  stats.pet_type = {}
  for pettype,n in pairs(petJournalStats.types) do
    stats.pet_type[pettype] = n
  end

end

function quantify_bp:updateStats(segment)
  
  quantify_bp:calculateDerivedStats(segment)
end
 
function quantify_bp:newSegment(segment)
  initPetJournalStats()
  
  segment.data = segment.data or {}
  segment.data.pet_battle_counts = segment.data.pet_battle_counts or {}
  
  segment.stats = q:addKeysLeft(segment.stats,
                         {total_battles = 0, 
                          total_trainer_battles = 0,
                          total_wild_battles = 0,
                          total_battle_wins = 0,
                          total_wild_battle_wins = 0,
                          total_trainer_battle_wins = 0,
                          total_forfeits = 0,
                          total_trainer_forfeits = 0,
                          total_wild_forfeits = 0})
end


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

