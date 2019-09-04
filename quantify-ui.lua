local q = quantify
local _G = _G

q.STAT_ROW_HEIGHT = 30
q.NUM_STAT_ROWS = 10
q.VIEW_STATS_BUTTON_PREFIX = "ViewStatsButton"

q.quantify_ui_shown = false

q.UI_REFRESH_RATE = 5

local last_refresh = 0

local ViewAllStats_List = {}

local viewing_segment = nil
local viewing_segment_key = "Segment 1"
local viewing_module_key = "All"
local viewing_module_subkey = "all"

local scroll_frame_initialized = false

local watchlist_enabled = false
local watchlist = {}

local function getReadableKeyValue(k,v,abbr)
  local star_index = string.find(k, "*")
  local star_string
  if (star_index ~= nil) then
    star_string = string.sub(k,star_index + 1)
    k = string.sub(k,1,star_index) 
  end
  if (q.STATS[k] ~= nil) then
    
    local readable_key = abbr and q.STATS[k].abbr or q.STATS[k].text
    if (star_string ~= nil and string.find(readable_key,"*") ~= nil) then
      readable_key = string.gsub(readable_key,"*",star_string)
    end
    local readable_value = q:getFormattedUnit(v,q.STATS[k].units,abbr)
    
    return readable_key,readable_value
  end  
end

function q:ViewAllStats_Update()
  if (viewing_segment == nil) then
    viewing_segment = q.current_segment
  end
  
  local stats
  if viewing_module_key == "All" then
    if (viewing_module_subkey == "all" or viewing_module_subkey == nil) then
      stats = q:getAllStats(viewing_segment)
    else
      stats = q:getAllStats(viewing_segment,viewing_module_subkey)
    end
  else
    if (viewing_module_subkey == "all" or viewing_module_subkey == nil) then
      stats = q:getSingleModuleSegment(viewing_module_key,viewing_segment)
      stats = q:getAllStats(stats)
    else
      stats = q:getSingleModuleSegment(viewing_module_key,viewing_segment,viewing_module_subkey)
      stats = q:getAllStats(stats,viewing_module_subkey)
    end
  end
  ViewAllStats_List = {}
  
  for k,v in pairs(stats) do
    local star_index = string.find(k, "*")
    local star_string
    if (star_index ~= nil) then
      star_string = string.sub(k,star_index + 1)
      k = string.sub(k,1,star_index) 
    end
    
    if (q.STATS[k] ~= nil and q:doesStatApplyToVersion(k) and not (q:viewingTotalSegmentUi() and q.STATS[k].exclude_total)) then
      local readable_key = q.STATS[k].text
      if (star_string ~= nil and string.find(readable_key,"*") ~= nil) then
        readable_key = string.gsub(readable_key,"*",star_string)
      end
      local readable_value = q:getFormattedUnit(v,q.STATS[k].units)
      table.insert(ViewAllStats_List, 
                  {label =  readable_key
                    , value = tostring(readable_value)
                    , order = (q.STATS[k].order or 500)
                    , dict_key = k
                    , subkey = star_string
                    , segment =  viewing_segment_key})
    end
  end
  
  if (viewing_module_key == "All") then                   --sort alphabetically
    table.sort(ViewAllStats_List, function(a,b) return a.label < b.label end)
  else                                                    --sort according to order
    table.sort(ViewAllStats_List, function(a,b) return (a.order == b.order and a.label < b.label) or (a.order < b.order) end)
  end
  
  QuantifyStatsScrollFrame_Refresh(false)
end

function q:showUi(bool)
  q.quantify_ui_shown = bool
  if (bool) then
    QuantifyContainer_Frame:Show()
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
    viewing_segment = q:convertSavedSegment(qDb[text])
  end
  
  q:ViewAllStats_Update()
end


function q:setCurrentViewModule(text)
  viewing_module_key = text
  
  q:ViewAllStats_Update()
end

function q:AddSegmentButton_initialize(self)
  self:SetWidth(20)
  --self:SetText("+")
end

function q:AddSegmentButton_OnClick(self)
  q:createNewSegment()
  
  q:setViewingSegment("Segment "..table.maxn(q.segments))
end

function q:updateUi(watchlist)
  if (GetTime() - last_refresh < q.UI_REFRESH_RATE) then
    return
  end
  
  for _,m in ipairs(q.modules) do
    m:updateStats(q.current_segment)
  end
  
  if (q.viewingTotalSegment()) then
    q:updateTotals(q.current_segment)
    
    local total_seg = qDb[viewing_segment_key]
    if (total_seg) then
      viewing_segment = q:convertSavedSegment(total_seg)
    end
  end
  
  q:ViewAllStats_Update()
  
  if (not watchlist) then
    last_refresh = GetTime()
  end
end

function q:updateWatchlist(frame)
  local segments = {}
  if (q:viewingTotalSegment()) then
    q:updateUi(true)
  else
   for _,m in ipairs(q.modules) do
     m:updateStats(q.current_segment)
    end 
  end
  
  frame.items = {}
  
  for watchlist_key,item in pairs(watchlist) do
    if (segments[item.segment] == nil) then
      local seg_id = string.match(item.segment, "Segment (%d+)")
      if (seg_id ~= nil) then
        segments[item.segment] = q.segments[tonumber(seg_id)]
      else
        segments[item.segment] = q:convertSavedSegment(qDb[item.segment])
      end
    end
    
    local seg = segments[item.segment]
    if (seg)  then
    
      local group = string.sub(item.key, 1, string.find(item.key, ":") - 1)
      
      local keynogroup = string.sub(item.key,string.len(group) + 2)
      
      local concat_key_no_group = item.subkey and keynogroup..item.subkey or keynogroup
      local found = false
      for _,mod in pairs(seg.stats) do
        if (mod[group] ~= nil) then
          for k,v in pairs(mod[group]) do
            if (k == concat_key_no_group) then
              found = true
              local readable_key, readable_value = getReadableKeyValue(group..":"..k,v, true)
              QuantifyWatchList_Add(frame, {label = readable_key, value = tostring(readable_value), dict_key = item.key, subkey = item.subkey, segment = item.segment})
            end
          end
        end
      end
      
      if (not found) then
        local readable_key, readable_value = getReadableKeyValue(group..":"..concat_key_no_group,0, true)
        QuantifyWatchList_Add(frame, {label = readable_key, value = tostring(readable_value), dict_key = item.key, subkey = item.subkey, segment = item.segment})
      end
    end
  end

  QuantifyWatchList_Update(frame)
end

function q:addWatchlistItemMenu(menu)
  q:addWatchListItem(menu.userdata.dict_key, menu.userdata.subkey)
end

function q:removeWatchlistItemMenu(menu)
  q:removeWatchListItem(menu.userdata.dict_key, menu.userdata.subkey, menu.userdata.segment)
end

function q:addWatchListItem(key, subkey)
  local concat_key = subkey and viewing_segment_key..key..subkey or viewing_segment_key..key
  watchlist[concat_key] = {key = key, subkey = subkey, segment = viewing_segment_key}
end

function q:removeWatchListItem(key,subkey,segment)
  local concat_key = subkey and segment..key..subkey or segment..key
  watchlist[concat_key] = nil
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

--mainly for checking whether to live update certain stats
function q:viewingTotalSegment()
  local res = nil
  
  res = q:viewingTotalSegmentUi()
  

  if (not res and watchlist_enabled) then
    for k,item in pairs(watchlist) do
      res = string.find(item.segment, "Segment %d+") == nil
      if (res) then
        break
      end
    end
  end
    
  return res
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

function quantify:getStatsList()
  return ViewAllStats_List
end

function q:test_ui()
  local key = "raw:xp"
  
  print(getReadableKeyValue(key, 0))
end

function q:initializeUi()
  QuantifyContainer_Initialize()
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
  local seg = id and q.segments[id]
  if (seg) then
    seg:resetStat(userdata.dict_key,userdata.subkey)
  else
    q.TotalSegment:resetStat(qDb[userdata.segment],userdata.dict_key, userdata.subkey)
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
  if (qDbOptions.watchlist ~= nil and qDbOptions.watchlist_enabled ~= nil) then
    watchlist = qDbOptions.watchlist
    if (qDbOptions.watchlist_enabled) then
      q:toggleWatchlist(nil,true)
      QuantifyWatchListCheckbox_Toggle(true)
    end
  end
end

quantify:registerEvent("PLAYER_LEAVING_WORLD",saveUiState)
quantify:registerEvent("PLAYER_LOGIN",loadUiState)