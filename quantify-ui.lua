local q = quantify
local _G = _G

quantify_ui = {}
local qui = quantify_ui

q.STAT_ROW_HEIGHT = 30
q.NUM_STAT_ROWS = 10
q.VIEW_STATS_BUTTON_PREFIX = "ViewStatsButton"

q.quantify_ui_shown = false

q.UI_REFRESH_RATE = 10
q.WATCHLIST_REFRESH_RATE = 1

local last_watchlist_refresh = 0

local ui_initialized = false

local viewing_segment = nil
local viewing_segment_key = "Segment 1"

local watchlist_enabled = false
local watchlist = {}

local function expandViewStats(segment, view, data_key, abbr)
  local stats = {}
  
  if (view.stats) then
    for i,stat_key in ipairs(view.stats) do
      local stat = q.STATS[stat_key]
      if (not stat or not stat.path) then
        print(stat_key.." is not a valid")
      end
      local current_stat_value = q:getStat(segment, stat_key)
      if (type(current_stat_value) == "table") then
        for k,v in pairs(current_stat_value) do
          if (not data_key or data_key and k == data_key) then
            local formatted_value = q:getFormattedUnit(v,stat.units, abbr)
            local formatted_name = string.gsub(stat.text,"*",k)
            
            local statobj = {}
            statobj.text = formatted_name
            statobj.stat_key = stat_key
            statobj.value = formatted_value
            statobj.data_key = k
            table.insert(stats, statobj)
          end
        end
      else
        local formatted_value = q:getFormattedUnit(current_stat_value,stat.units, abbr)
        local statobj = {}
        statobj.text = stat.text
        statobj.stat_key = stat_key
        statobj.value = formatted_value
        table.insert(stats, statobj)
      end

    end
  end
  
  return stats
end

function q:buildStatsList(view)
  if (viewing_segment == nil) then
    viewing_segment = q.current_segment
  end
  
  local stats = expandViewStats(viewing_segment, view)
  
  local stats_list = {}
  
  for _,statobj in ipairs(stats) do
    local row = {statobj.text,statobj.value}
    row.stat_key = statobj.stat_key
    row.data_key = statobj.data_key
    row.viewing_segment_key = viewing_segment_key
    row.filter = view.filter
    table.insert(stats_list, row)
  end
  
                        --sort according to order
  --table.sort(stats_list, function(a,b) return (a.order == b.order and a.label < b.label) or (a.order < b.order) end)
  
  return stats_list
end

function q:showUi(bool)
  q.quantify_ui_shown = bool
  if (bool) then
    QuantifyContainer_Frame:Show()
    qui:RefreshWidget(true, false, false, true)
  else
    QuantifyContainer_Frame:Hide()
  end
end

function q:toggleUi()
  q:showUi(not q.quantify_ui_shown)
end

function q:setViewingSegment(text)
  viewing_segment_key = text
  
  local seg_id = string.match(text, "Segment (%d+)")
  if (seg_id ~= nil) then
    viewing_segment = q.segments[tonumber(seg_id)]
  else
    viewing_segment = qDb[text]
  end
  
  qui:RefreshWidget(false, true, false, false)
end

function q:AddSegmentButton_initialize(self)
  self:SetWidth(20)
  --self:SetText("+")
end

function q:AddSegmentButton_OnClick(self)
  q:createNewCurrentSegment()
  
  q:setViewingSegment("Segment "..table.maxn(q.segments))
end

function q:refreshUi()
  q:updateSegment(q.current_segment)
  
  if (q.viewingTotalSegmentUi()) then
    q:updateSegment(viewing_segment)
  end
  
  qui:RefreshWidget(false)  
end

function q:updateUi()
  if (not ui_initialized or (not q.stats_dirty and GetTime() - q.last_update_timestamp < q.UI_REFRESH_RATE)) then
    return
  end

  q.last_update_timestamp = GetTime()
  
  q:refreshUi()
end

function q:refreshWatchlist(frame)
  frame = frame or QuantifyWatchList
  
  local segments = {}  
  frame.items = {}
  for watchlist_key,item in pairs(watchlist) do
    if (not segments[item.segment]) then
      segments[item.segment] = q:getSegment(item.segment)
      if (segments[item.segment]) then
        q:updateSegment(segments[item.segment])
      else
        watchlist[watchlist_key] = nil
      end
    end
    
    local seg = segments[item.segment]

    if (seg)  then
      local view = {stats = {item.stat_key}}
      local stat = expandViewStats(seg, view, item.data_key, true)[1]
    
      if (stat) then
        QuantifyWatchList_Add(frame, {label = stat.text, value = stat.value, stat_key = item.stat_key, data_key = item.data_key, segment = item.segment})
      end
    end
  end

  QuantifyWatchList_Update(frame)  
end

function q:updateWatchlist(frame)
  if (not ui_initialized or (not q.stats_dirty and GetTime() - last_watchlist_refresh < q.WATCHLIST_REFRESH_RATE)) then
    return
  end
  
  last_watchlist_refresh = GetTime()

  q:refreshWatchlist(frame)
end

function q:addWatchlistItemMenu(menu)
  q:addWatchListItem(menu.userdata.stat_key, menu.userdata.data_key)
end

function q:removeWatchlistItemMenu(menu)
  q:removeWatchListItem(menu.userdata.stat_key, menu.userdata.data_key, menu.userdata.segment)
end

function q:addWatchListItem(stat_key, data_key)
  local concat_key = viewing_segment_key .. stat_key .. (data_key or "")
  watchlist[concat_key] = {stat_key = stat_key, data_key = data_key, segment = viewing_segment_key}
  
  q:refreshWatchlist()
end

function q:removeWatchListItem(stat_key,data_key,segment)
  local concat_key = segment .. stat_key .. (data_key or "")
  watchlist[concat_key] = nil
  
  q:refreshWatchlist()
end

function q:toggleWatchlist(button,value)
  watchlist_enabled = value
  if (value) then
    QuantifyWatchList:Show()
  else
    QuantifyWatchList:Hide()
  end
end

--mainly for filtering stat lists in UI
function q:viewingTotalSegmentUi()
  if (q.quantify_ui_shown) then
    return string.find(viewing_segment_key, "Segment %d+") == nil
  end
end

function q:getViewingSegmentKey()
  return viewing_segment_key
end

function q:getViewingSegment()
  return viewing_segment
end

function quantify:uiCloseButton()
  q.quantify_ui_shown = false
end

function quantify:setViewingSubkey(subkey)
  viewing_module_subkey = subkey
end

function q:initializeUi()
  viewing_segment = q.current_segment
  QuantifyContainer_Initialize()
  ui_initialized = true
end

function q:copyToClipboard(menu)
  local window = QuantifyEditWindow_Create(nil, "("..menu.userdata.segment..") "..menu.userdata.label.."\t"..menu.userdata.value, true)
  window.button_group:Release()
  QuantifyEditWindow_Show(window)
end

function q:shareStat()
  print("share")
end

function q:resetStat(userdata)
  local id = q:getSegmentId(userdata.segment)
  local seg = id and q.segments[id] or qDb[userdata.segment]
  if (seg) then
    q:setStat(seg, userdata.stat_key, nil, userdata.data_key)
    q:refreshUi()
  end
end

function q:resetStatMenu(menu)
  local window = QuantifyConfirmWindow_Create(q.resetStat, q.RESET_STAT_WARNING, menu.userdata)
  QuantifyConfirmWindow_Show(window)
end

function q:freezeStat(menu)
  
end

function quantify:getSavedWatchlists()
  local res = {}
  if (qDbOptions.saved_watchlists ~= nil) then
    res = qDbOptions.saved_watchlists
  end
  
  return res
end

function quantify:saveWatchlist(self)
  local window = QuantifyEditWindow_Create(quantify.saveWatchlistConfirm, self.watchlist_key or "", false, self.userdata)
  QuantifyEditWindow_Show(window)
end 

function quantify:saveWatchlistConfirm(text, userdata)
  if (qDbOptions.saved_watchlists == nil) then
    qDbOptions.saved_watchlists = {}
  end
  
  if (text ~= nil and text ~= "") then
    qDbOptions.saved_watchlists[text] = q:deepcopy(watchlist)
    
    self.watchlist_key = text
  end
end

function quantify:deleteSavedWatchlist(self)
  if (self.watchlist_key) then
    qDbOptions.saved_watchlists[self.watchlist_key] = nil
  end
end

function quantify:loadWatchlist(self,key)
  self.watchlist_key = key
  
  if (qDbOptions.saved_watchlists ~= nil and qDbOptions.saved_watchlists[key] ~= nil) then
    watchlist = q:deepcopy(qDbOptions.saved_watchlists[key])
  end
end

local function saveUiState()
  qDbOptions.watchlist = watchlist
  qDbOptions.watchlist_enabled = watchlist_enabled
end

local function loadUiState()
  if (qDbOptions and qDbOptions.watchlist ~= nil and qDbOptions.watchlist_enabled ~= nil) then
    watchlist = qDbOptions.watchlist
    if (qDbOptions.watchlist_enabled) then
      q:toggleWatchlist(nil,true)
      QuantifyWatchListCheckbox_Toggle(true)
    end
  end
end

quantify:registerEvent("PLAYER_LEAVING_WORLD",saveUiState)
quantify:registerEvent("PLAYER_LOGIN",loadUiState)