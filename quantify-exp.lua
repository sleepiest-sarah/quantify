
local previous_xp = nil

local player_combat = false

local player_login_time = nil
local session = {xp = 0, quest_xp = 0, kill_xp = 0, other_xp = 0, levels_gained = 0}

local function playerExpUpdate(event, ...)
  local unitid = ...
  if unitid == "player" then
    local current_xp = UnitXP("player")
    if (previous_xp ~= nil) then
      local xp_gain = previous_xp - current_xp
      print("xp_gain ", xp_gain)
    end
  end
end

local function playerLogin(...)
  player_login_time = GetTime();
end

local function playerCombat(event, ...)
  player_combat = event == "PLAYER_REGEN_DISABLED"
end

local function playerQuestComplete(event, ...)
  
end

function playerMsgCombatXpGain(event, ...)
  print(...)
end

quantify:registerEvent("PLAYER_XP_UPDATE", playerExpUpdate)
quantify:registerEvent("PLAYER_REGEN_DISABLED", playerCombat)
quantify:registerEvent("PLAYER_REGEN_ENABLED", playerCombat)
quantify:registerEvent("CHAT_MSG_COMBAT_XP_GAIN", playerMsgCombatXpGain)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)
