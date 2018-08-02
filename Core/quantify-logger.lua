local logframe = CreateFrame("FRAME")

logframe:RegisterEvent("ADDON_LOADED")
logframe:RegisterEvent("PLAYER_LOGOUT")
logframe:RegisterEvent("PLAYER_XP_UPDATE")
logframe:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
logframe:RegisterEvent("PLAYER_REGEN_DISABLED")
logframe:RegisterEvent("PLAYER_REGEN_ENABLED")
logframe:RegisterEvent("QUEST_TURNED_IN")
logframe:RegisterEvent("PLAYER_LOGIN")
logframe:RegisterEvent("ACHIEVEMENT_EARNED")
logframe:RegisterEvent("BAG_UPDATE")
logframe:RegisterEvent("BOSS_KILL")
logframe:RegisterEvent("CHAT_MSG_ACHIEVEMENT")
logframe:RegisterEvent("CHAT_MSG_AFK")
logframe:RegisterEvent("CHAT_MSG_LOOT")
logframe:RegisterEvent("CHAT_MSG_MONEY")
logframe:RegisterEvent("CHAT_MSG_CURRENCY")
logframe:RegisterEvent("CHAT_MSG_COMBAT_MISC_INFO")
logframe:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
logframe:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
logframe:RegisterEvent("CHAT_MSG_SKILL")
logframe:RegisterEvent("CINEMATIC_START")
logframe:RegisterEvent("CINEMATIC_STOP")
logframe:RegisterEvent("ENCOUNTER_START")
logframe:RegisterEvent("ENCOUNTER_END")
logframe:RegisterEvent("NEW_PET_ADDED")
logframe:RegisterEvent("NEW_MOUNT_ADDED")
logframe:RegisterEvent("NEW_RECIPE_LEARNED")
logframe:RegisterEvent("PET_BATTLE_CAPTURED")
logframe:RegisterEvent("PET_BATTLE_FINAL_ROUND")
logframe:RegisterEvent("PET_BATTLE_XP_CHANGED")
logframe:RegisterEvent("PLAYER_ALIVE")
logframe:RegisterEvent("PLAYER_DEAD")
logframe:RegisterEvent("PLAYER_ENTERING_WORLD")
logframe:RegisterEvent("PLAYER_LEAVING_WORLD")
logframe:RegisterEvent("PLAYER_MONEY")
logframe:RegisterEvent("PLAYER_LEVEL_UP")
logframe:RegisterEvent("PLAYER_PVP_KILLS_CHANGED")
logframe:RegisterEvent("PLAYER_UNGHOST")
logframe:RegisterEvent("QUEST_FINISHED")
logframe:RegisterEvent("QUEST_ACCEPTED")
logframe:RegisterEvent("QUEST_COMPLETE")
logframe:RegisterEvent("QUEST_LOOT_RECEIVED")
logframe:RegisterEvent("ZONE_CHANGED")
logframe:RegisterEvent("ZONE_CHANGED_INDOORS")
logframe:RegisterEvent("ZONE_CHANGED_NEW_AREA")
logframe:RegisterEvent("SCENARIO_COMPLETED")
logframe:RegisterEvent("CHAT_MSG_SYSTEM")

local t = time()
local d = date("*t", t)

local log_file = nil

quantify.log = {}

local log = quantify.log

function log:getLogFileName()
  local filename = d.year .. "_" .. d.month .. "_" .. d.day
  return filename
end

function log:initializeLogFile()
  local filename = log:getLogFileName()
  if (qLog == nil) then
    qLog = {}
  end
  
  if (qLog[filename] == nil) then
    qLog[filename] = {}
  end
  
  log_file = qLog[filename]
end

function log:logEvent(...)
  log:initializeLogFile()
  local r = ""
  for i,v in ipairs({...}) do
    if i ~= 1 then
      r = r .. ":"
    end
    r = r .. tostring(v)
  end
  
  --local r = table.concat({...}, ":")
  table.insert(log_file, r)
end

function log:logEventToConsole(...)
  local r = ""
  for i,v in ipairs({...}) do
    if i ~= 1 then
      r = r .. ":"
    end
    r = r .. tostring(v)
  end
  
  print(r)
end

function logframe:OnEvent(event, ...)
  log:logEvent(event, ...)
end

logframe:SetScript("OnEvent", logframe.OnEvent)