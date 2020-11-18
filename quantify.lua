local sframe = CreateFrame("FRAME")

local event_map = {}
local secure_hooks = {}
local next_frame_callbacks = {}
local timer_callbacks = {}

local next_frame_queued = false
local timer_running = false

local qevent_map = {}

--alias namespace
local q = quantify

q.modules = {}

--copying here to make sure the version flags are declared when the modules load
--should rework the addon loading a bit so that sort of stuff always runs after the ADDON_LOADED event
local clientVersion,_,_,tocVersion = GetBuildInfo()
q.isClassic = tocVersion < 80000
q.isRetail = not q.isClassic --just for more readable checks

q.player_login_time = nil
q.segments = {}
q.current_segment = nil

q.stats_dirty = false
q.last_update_timestamp = 0

local AUTO_UPDATE_INTERVAL = 60
local time_module_last_update = 0

function sframe:OnEvent(event, ...)
  if (event_map[event]) then
    for _, f in pairs(event_map[event]) do
      f(event, ...)
    end
  end
  
  if (q.last_update_timestamp > time_module_last_update) then
    time_module_last_update = q.last_update_timestamp
  end
  
  --this is only for updating the time module; everything else is entirely event based
  if (GetTime() - time_module_last_update > AUTO_UPDATE_INTERVAL) then
    quantify_time:updateStats(q.current_segment)
    
    time_module_last_update = GetTime()
  end
end

local function nextFrame()
  next_frame_queued = false
  
  local callbacks = {}
  
  --add currently registered callbacks to local list so callbacks can register new next frame callbacks without being affected by this function
  for id,c in pairs(next_frame_callbacks) do
    callbacks[id] = c
  end
  
  next_frame_callbacks = {}
  
  for id,c in pairs(callbacks) do
    c.callback(unpack(c.args))
  end
end

function quantify:registerNextFrame(callback, ...)
  local uuid = q:generateUUID()
  next_frame_callbacks[uuid] = {callback = callback, args = {...}}
  
  if (not next_frame_queued) then
    next_frame_queued = true
    C_Timer.After(0, nextFrame)
  end
end

local function timerFired()
  timer_running = false
  
  local exhausted = {}
  for id,c in pairs(timer_callbacks) do
    if (GetTime() - c.start > c.seconds) then
      table.insert(exhausted,id)            --remove after loop so iterator isn't affected
      c.callback(unpack(c.args))
    end
  end
  
  --remove expired timers
  for _,id in pairs(exhausted) do
    timer_callbacks[id] = nil
  end
  
end

function quantify:registerTimer(callback, seconds, ...)
  local uuid = q:generateUUID()  --for random access deletes
  timer_callbacks[uuid] = {callback = callback, seconds = seconds, args = {...}, start = GetTime()}
  
  if (not timer_running) then
    timer_running = true
    C_Timer.After(1, timerFired)
  end
end

function quantify:registerQEvent(event,func)
  if (qevent_map[event] == nil) then
    qevent_map[event] = {}
  end
    
  table.insert(qevent_map[event], func)  
end

function quantify:triggerQEvent(event, ...)
  if (qevent_map[event] ~= nil) then
    for _, f in pairs(qevent_map[event]) do
      f(event, ...)
    end
  end  
end

function q:getSnapshotSegment()
  return segment_snapshot
end

function quantify:registerEvent(event, func)
  if not sframe:IsEventRegistered(event) then
    sframe:RegisterEvent(event)
  end
  
  if (event_map[event] == nil) then
    event_map[event] = {}
  end
    
  table.insert(event_map[event], func)
end

function quantify:unregisterEvent(event, func)
  if (event_map[event] ~= nil) then
    for i,f in ipairs(event_map[event]) do
      if (f == func) then
        event_map[event][i] = nil
        break
      end
    end
  end
end

function quantify:hookSecureFunc(func, callback, t)
  if (not secure_hooks[func]) then
    t = t or _G
    
    secure_hooks[func] = {}
    hooksecurefunc(t, func, function (...)
                          for _,cb in pairs(secure_hooks[func]) do
                            cb(...)
                          end
                         end)
  end
  
  table.insert(secure_hooks[func], callback)
end

local function initDateSegments()
  local character_key = q:getCharacterKey()
  local cur_date = date("%b%d")
  
  for seg_key, seg in pairs(qDb) do
    if (seg.date and seg.date ~= cur_date) then
      qDb[seg_key] = nil
    end
  end
  
  local today_seg_key = character_key.."_"..cur_date
  qDb[today_seg_key] = qDb[today_seg_key] or q:createNewSegment()
  qDb[today_seg_key].date = cur_date
end

local function init(event, ...)
  local addon = ...
  if (event == "ADDON_LOADED" and addon == q.ADDON_NAME) then
    print(quantify.LOADED_TEXT)
    
    local character_key = q:getCharacterKey()
    
    if (not qDbOptions) then
      qDbOptions = {profile = {minimap = {hide = false}}}
    end
    
    if (not qDbData) then
      qDbData = {}
    end
    
    if (qDb) then
      q:runMigrations()
    else
      qDb = {account = q:createNewSegment(), [character_key] = q:createNewSegment()}
    end
    
    if (not qDb[character_key]) then
      qDb[character_key] = q:createNewSegment()
    end
    
    qDbOptions.version = GetAddOnMetadata("quantify", "Version")
    
    local classicDebugMode = GetAddOnMetadata("quantify", "X-Classic")
    
    local clientVersion,_,_,tocVersion = GetBuildInfo()
    qDbOptions.clientVersion = clientVersion
    q.isClassic = tocVersion < 80000 or classicDebugMode
    q.isRetail = not q.isClassic --just for more readable checks
    
    local addon = LibStub("AceAddon-3.0"):NewAddon("quantify")
    local bunnyLDB = LibStub("LibDataBroker-1.1"):NewDataObject("quantify", {
      type = "data source",
      text = "quantify",
      icon = "Interface\\addons\\quantify\\Textures\\noun_calculate.tga",
      OnClick = function() q:toggleUi() end,
      OnTooltipShow = function(tooltip) tooltip:SetText("quantify\n\n|cFFFFFF00Click |cFFFFFFFFto toggle UI") end
    })
    local icon = LibStub("LibDBIcon-1.0")
    icon:Register("quantify", bunnyLDB, qDbOptions.profile.minimap)
    
    q:createNewCurrentSegment()
    table.insert(q.segments, q.current_segment)
    
    initDateSegments()
    
    --this will set any new stats the segment might be missing
    for seg_key, seg in pairs(qDb) do
      q:updateSegment(seg, true)
    end
    
    quantify:initializeUi()
  end
end

local function logout(event, ...)
  q:updateSegment(q.current_segment)
end

local function playerLogin(event, ...)
  q.player_login_time = GetTime()
end

function q:createNewCurrentSegment()
  if (q.current_segment) then
    q:updateSegment(q.current_segment)
  end
  
  q.current_segment = q:createNewSegment()
end

local function qtySlashCmd(msg, editbox)
  local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
  
  if (cmd == "mod" and args ~= nil) then
    q:updateSegment(q.current_segment)
    q:printModule(args, q.current_segment)
  elseif (cmd == "segment" and args =="new") then
    q:createNewCurrentSegment()
    print("Created new segment", table.maxn(q.segments))
  elseif (cmd == "segment" and tonumber(args) ~= nil) then
    q:printSegment(q.segments[tonumber(args)])
  elseif (cmd == "show" or cmd == "hide") then
    q:showUi(cmd == "show")
  elseif (cmd == "state")  then
    q:printTable(quantify_state.state)
  elseif (cmd == "debug") then
    print(quantify.DEBUG_OPTIONS)
  else
    print(quantify.HELP_TEXT)
  end
end

quantify:registerEvent("ADDON_LOADED", init)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)
quantify:registerEvent("PLAYER_LEAVING_WORLD", logout)

sframe:SetScript("OnEvent", sframe.OnEvent)
SlashCmdList["quantify"] = qtySlashCmd