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

local segment_snapshot = nil

local scroll_frame_initialized = false

local watchlist_enabled = false
local watchlist = {}



function q:FauxScrollFrame_OnLoad(frame, button_height, num_buttons, button_prefix, update_func)
  for i = 1, num_buttons do
    local button = CreateFrame("Button", nil, frame:GetParent(), "QuantifyStatRowTemplate")
    if i == 1 then
      button:SetPoint("TOP", frame)
    else
      button:SetPoint("TOP", _G[button_prefix..tostring(i-1)], "BOTTOM")
    end
    _G[button_prefix..tostring(i)] = button
  end
  
  FauxScrollFrame_SetOffset(frame, 0);

  local scrollbar = _G[frame:GetName().."ScrollBar"];
  scrollbar:SetWidth(9);
  scrollbar:SetMinMaxValues(0, 100);
	scrollbar:SetValue(0);
  
  update_func()
end

local function updateFauxScrollFrame(frame, list, num_buttons, button_height, button_prefix)
 	local numItems = #list
	
	local offset = FauxScrollFrame_GetOffset(frame)
	for line = 1, num_buttons do
		local lineplusoffset = line + offset
		local button = _G[button_prefix..tostring(line)]
		if lineplusoffset > numItems then
			button:Hide()
		else
      QuantifyStatRowTemplate_SetText(button,list[lineplusoffset])
			button:Show()
		end
	end 
  

  
  FauxScrollFrame_Update(frame, numItems, num_buttons, button_height, button_prefix,470,500, ViewAllStats_Container, 470, 500, true)
  

end

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
    stats = q:getAllStats(viewing_segment)
  else
    stats = q:getSingleModuleSegment(viewing_module_key,viewing_segment)
    stats = q:getAllStats(stats)
  end
  ViewAllStats_List = {}
  
  for k,v in pairs(stats) do
    local star_index = string.find(k, "*")
    local star_string
    if (star_index ~= nil) then
      star_string = string.sub(k,star_index + 1)
      k = string.sub(k,1,star_index) 
    end
    if (q.STATS[k] ~= nil) then
      local readable_key = q.STATS[k].text
      if (star_string ~= nil and string.find(readable_key,"*") ~= nil) then
        readable_key = string.gsub(readable_key,"*",star_string)
      end
      local readable_value = q:getFormattedUnit(v,q.STATS[k].units)
      table.insert(ViewAllStats_List, {label =  readable_key, value = tostring(readable_value), order = (q.STATS[k].order or 500), dict_key = k, subkey = star_string})
    else  --just use the raw key and value if the text hasn't been initialized yet
      if (type(v) ~= "table") then
        --table.insert(ViewAllStats_List, string.gsub(k,":","-")..":"..tostring(v))
      end
    end
  end
  
  if (viewing_module_key == "All") then                   --sort alphabetically
    table.sort(ViewAllStats_List, function(a,b) return a.label < b.label end)
  else                                                    --sort according to order
    table.sort(ViewAllStats_List, function(a,b) return (a.order == b.order and a.label < b.label) or (a.order < b.order) end)
  end
  
  updateFauxScrollFrame(ViewAllStats_Frame, ViewAllStats_List, q.NUM_STAT_ROWS, q.STAT_ROW_HEIGHT,q.VIEW_STATS_BUTTON_PREFIX)
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

local function SelectSegmentDropdown_Update(self)
  SelectSegmentDropdownSelected:SetText(q:capitalizeString(viewing_segment_key))
end

function q:setViewingSegment(text)
  viewing_segment_key = text
  
  local seg_id = string.match(text, "Segment (%d+)")
  if (seg_id ~= nil) then
    viewing_segment = q.segments[tonumber(seg_id)]
  else
    viewing_segment = q:convertSavedSegment(qDb[text])
  end
  
  SelectSegmentDropdown_Update(SelectSegmentDropdown)
  
  q:ViewAllStats_Update()
end

local function segmentListComparator(a,b)
  local a_id = string.match(a, "Segment (%d+)")
  local b_id = string.match(a, "Segment (%d+)")
  if (a == "account" or b == "account") then  --account should always be first
    return a == "account"
  elseif (a_id ~= nil and b_id ~= nil) then   --sort segments according to id
    return a_id < b_id
  elseif (a_id ~= nil and b_id == nil) then   --segments should be last
    return false
  else                                        --sort character names alphabetically
    return a < b
  end
    
end

local function SelectSegmentDropdown_Initialize()
  local info = UIDropDownMenu_CreateInfo()
  info.padding = 8
  info.checked = nil;
  info.notCheckable = true
  info.notClickable = false
  info.func = q.setViewingSegment
  
  local segments = q:getSegmentList()
  local keys_t = {}
  table.foreach(segments, function(k,v) table.insert(keys_t,k) end)
  table.sort(keys_t, segmentListComparator)
  for _,k in ipairs(keys_t) do
    info.text = q:capitalizeString(k)
    info.arg1 = k
    UIDropDownMenu_AddButton(info)
  end
end

function q:SelectSegmentDropdown_OnLoad(frame)
  UIDropDownMenu_Initialize(frame, SelectSegmentDropdown_Initialize)
  UIDropDownMenu_SetWidth(frame, 200)
end

function q:SelectSegmentDropdown_OnShow(frame)
	UIDropDownMenu_Initialize(frame, SelectSegmentDropdown_Initialize);
	SelectSegmentDropdown_Update(frame);  
end

local function SelectModuleDropdown_Update(self)
  SelectModuleDropdownSelected:SetText(q:capitalizeString(viewing_module_key))
end

function q:setCurrentViewModule(text)
  viewing_module_key = text
  
  SelectModuleDropdown_Update(SelectModuleDropdown)
  
  q:ViewAllStats_Update()
end

local function SelectModuleDropdown_Initialize()
  local info = UIDropDownMenu_CreateInfo()
  info.padding = 8
  info.checked = nil;
  info.notCheckable = 1
  info.func = q.setCurrentViewModule
  
  info.text = "All"
  info.arg1 = "All"
  UIDropDownMenu_AddButton(info)
  
  local modules = q:getModuleKeys()
  table.sort(modules)
  for _,m in ipairs(modules) do
    info.text = q:capitalizeString(m)
    info.arg1 = m
    UIDropDownMenu_AddButton(info)
  end
end

function q:SelectModuleDropdown_OnLoad(frame)
  UIDropDownMenu_Initialize(frame, SelectModuleDropdown_Initialize)
  UIDropDownMenu_SetWidth(frame, 100)
end

function q:SelectModuleDropdown_OnShow(frame)
	UIDropDownMenu_Initialize(frame, SelectModuleDropdown_Initialize);
	SelectModuleDropdown_Update(frame);  
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
    if (segment_snapshot == nil) then
      q:updateTotals(q.current_segment)
    else
      for k, statgroup in pairs(q.current_segment.stats) do
        if (segment_snapshot.stats[k] == nil) then
          segment_snapshot.stats[k] = {}
          segment_snapshot.stats[k].raw = {}
        end
        segment_snapshot.stats[k].raw = q:subtractTables(statgroup.raw,segment_snapshot.stats[k].raw)
      end
      q:updateTotals(segment_snapshot)
    end
    segment_snapshot = q:createSegmentSnapshot(q.current_segment)
    
    viewing_segment = q:convertSavedSegment(qDb[viewing_segment_key])
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
      for _,mod in pairs(seg.stats) do
        if (mod[group] ~= nil) then
          for k,v in pairs(mod[group]) do
            if (k == concat_key_no_group) then
              local readable_key, readable_value = getReadableKeyValue(group..":"..k,v, true)
              QuantifyWatchList_Add(frame, {label = readable_key, value = tostring(readable_value), dict_key = item.key, subkey = item.subkey, segment = item.segment})
            end
          end
        end
      end
    end
  end

  QuantifyWatchList_Update(frame)
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

function q:viewingTotalSegment()
  local res = nil
  
  if (q.quantify_ui_shown) then
    res = string.find(viewing_segment_key, "Segment %d+") == nil
  end
  
  if (not res and watchlist_enabled) then
    for k,item in pairs(watchlist) do
      res = string.find(item.segment, "Segment %d+") == true
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

function quantify:uiCloseButton()
  q.quantify_ui_shown = false
end

function q:test_ui()
  local key = "raw:xp"
  
  print(getReadableKeyValue(key, 0))
end

function q:initializeUi()
  QuantifyContainer_Initialize()
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

quantify:registerEvent("PLAYER_LOGOUT",saveUiState)
quantify:registerEvent("PLAYER_LOGIN",loadUiState)