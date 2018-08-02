local sframe = CreateFrame("FRAME")

local event_map = {}

--alias namespace
local q = quantify

q.modules = {}

q.player_login_time = nil
q.segments = {q.Segment:new()}
q.current_segment = q.segments[1]



function sframe:OnEvent(event, ...)
  if (event_map[event] ~= nil) then
    for _, f in pairs(event_map[event]) do
      f(event, ...)
    end
  end
end

function q:updateTotals(segment)
  local duration
  if (segment.start_time == nil and segment.end_time == nil) then
    duration = 0
  elseif (segment.end_time ~= nil) then
    duration = segment:duration()
  else
    duration = GetTime() - segment.start_time
  end
  
  qDb.account.time = qDb.account.time + duration
  qDb[q.TotalSegment:characterKey()].time = qDb[q.TotalSegment:characterKey()].time + duration
  
  for k, statgroup in pairs(segment.stats) do
    if (qDb.account.stats[k] == nil) then
      qDb.account.stats[k] = statgroup.raw
    else
      q:addTables(qDb.account.stats[k], statgroup.raw)
    end
    
    if (qDb[q.TotalSegment:characterKey()].stats[k] == nil) then
      qDb[q.TotalSegment:characterKey()].stats[k] = statgroup.raw
    else
      q:addTables(qDb[q.TotalSegment:characterKey()].stats[k], statgroup.raw)
    end
  end
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

local function init(event, ...)
  local addon = ...
  if (event == "ADDON_LOADED" and addon == q.ADDON_NAME) then
    --q:showUi(true)
    if (qDb == nil) then
      qDb = {account = q.TotalSegment:new(), [q.TotalSegment:characterKey()] = q.TotalSegment:new()}
    elseif (qDb[q.TotalSegment:characterKey()] == nil) then
      qDb[q.TotalSegment:characterKey()] = q.TotalSegment:new()
    end
  end
end

local function logout(event, ...)
  q:updateTotals(q.current_segment)
end

local function playerLogin(event, ...)
  q.player_login_time = GetTime()
  q.current_segment.start_time = q.player_login_time
end

function q:createNewSegment()
  local new_segment = q.Segment:new()
  new_segment.start_time = GetTime()
  q.current_segment.end_time = GetTime()
  
  
  --process any rates or derived stats
  for _,m in ipairs(q.modules) do
    m:updateStats(q.current_segment)
  end
  
  q:updateTotals(q.current_segment)
  
  q.current_segment = new_segment
  
  --initialize modules for the new segment
  for _,m in ipairs(q.modules) do
    m.newSegment()
  end

  table.insert(q.segments, q.current_segment)
end

local function qtySlashCmd(msg, editbox)
  local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
  
  if (cmd == "mod" and args ~= nil) then
    for _,m in ipairs(q.modules) do
      m:updateStats(q.current_segment)
    end
    q:printModule(args, q.current_segment)
  elseif (cmd == "segment" and args =="new") then
    createNewSegment()
    print("Created new segment", table.maxn(q.segments))
  elseif (cmd == "segment" and tonumber(args) ~= nil) then
    q:printSegment(q.segments[tonumber(args)])
  elseif (cmd == "show" or cmd == "hide") then
    q:showUi(cmd == "show")
  elseif (cmd == "state")  then
    q:printTable(quantify_state.state)
  end
end


quantify:registerEvent("ADDON_LOADED", init)
quantify:registerEvent("PLAYER_LOGIN", playerLogin)
quantify:registerEvent("PLAYER_LOGOUT", logout)

sframe:SetScript("OnEvent", sframe.OnEvent)
SlashCmdList["quantify"] = qtySlashCmd
