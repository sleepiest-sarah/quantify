local sframe = CreateFrame("FRAME")

sframe:RegisterEvent("ADDON_LOADED")
sframe:RegisterEvent("PLAYER_LOGOUT")
sframe:RegisterEvent("PLAYER_XP_UPDATE")
sframe:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")
sframe:RegisterEvent("PLAYER_REGEN_DISABLED")
sframe:RegisterEvent("PLAYER_REGEN_ENABLED")

local event_map = {}

--alias namespace
local q = quantify

function sframe:OnEvent(event, ...)
  if (event_map[event] ~= nil) then
    for _, f in pairs(event_map[event]) do
      f(event, ...)
    end
  end
end

function quantify:registerEvent(event, func)
  if (event_map[event] == nil) then
    event_map[event] = {}
  end
    
  table.insert(event_map[event], func)
end

local function init(event, ...)
  local addon = ...
  if event == "ADDON_LOADED" and addon == q.ADDON_NAME then
    print("quantify loaded.")
  end
end


quantify:registerEvent("ADDON_LOADED", init)

sframe:SetScript("OnEvent", sframe.OnEvent)