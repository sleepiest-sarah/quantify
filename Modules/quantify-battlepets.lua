quantify_bp = {}

local q = quantify

quantify_bp.Session = {}

quantify_bp.MODULE_KEY = "battlepets"

function quantify_bp.Session:new(o)
  o = o or {total_battles = 0, total_trainer_battles = 0, total_wild_battles = 0, total_battle_wins = 0, total_wild_battle_wins = 0, total_trainer_battle_wins = 0}
  setmetatable(o, self)
  self.__index = self
  return o
end

local session

local function init()
  q.current_segment.stats.battlepets = {}
  q.current_segment.stats.battlepets.raw = quantify_bp.Session:new()
  q.current_segment.stats.battlepets.derived_stats = { }
  session = q.current_segment.stats.battlepets.raw
end

local function petBattleStart()
  session.total_battles = session.total_battles + 1
  
  if (C_PetBattles.IsWildBattle()) then
    session.total_wild_battles = session.total_wild_battles + 1
  else
    session.total_trainer_battles = session.total_trainer_battles + 1
  end
end

local function petBattleEnd(owner)
  if (owner == 1) then
    session.total_battle_wins = session.total_battle_wins + 1
    
    if (C_PetBattles.IsWildBattle()) then
      session.total_wild_battle_wins = session.total_wild_battle_wins + 1
    else
      session.total_trainer_battle_wins = session.total_trainer_battle_wins + 1
    end
  end
end

function quantify_bp:calculateDerivedStats(segment)
  local derived_stats = {}
  
  local raw = segment.stats.battlepets.raw
  derived_stats.pct_battle_wins = (raw.total_battle_wins / raw.total_battles) * 100
  derived_stats.pct_trainer_battle_wins = (raw.total_trainer_battle_wins / raw.total_trainer_battles) * 100
  derived_stats.pct_wild_battle_wins = (raw.total_wild_battle_wins / raw.total_wild_battles) * 100
  segment.stats.battlepets.derived_stats = derived_stats
end

function quantify_bp:updateStats(segment)

end
 
function quantify_bp:newSegment(previous_seg,new_seg)
  init()
end

init()

if (q.isRetail) then
  table.insert(quantify.modules, quantify_bp)


  quantify:registerEvent("PET_BATTLE_OPENING_DONE", petBattleStart)
  quantify:registerEvent("PET_BATTLE_FINAL_ROUND", petBattleEnd)
end

