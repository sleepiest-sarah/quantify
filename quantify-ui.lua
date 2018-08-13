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
  

  
  FauxScrollFrame_Update(frame, numItems, num_buttons, button_height, button_prefix,270,500, ViewAllStats_Container, 270, 500, true)
  

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
      table.insert(ViewAllStats_List, readable_key..":"..tostring(readable_value))
    else  --just use the raw key and value if the text hasn't been initialized yet
      if (type(v) ~= "table") then
        table.insert(ViewAllStats_List, string.gsub(k,":","-")..":"..tostring(v))
      end
    end
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

local function SelectSegmentDropdown_Update(self)
  SelectSegmentDropdownSelected:SetText(viewing_segment_key)
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

local function SelectSegmentDropdown_Initialize()
  local info = UIDropDownMenu_CreateInfo()
  info.padding = 8
  info.checked = nil;
  info.notCheckable = 1
  info.func = q.setViewingSegment
  
  local segments = q:getSegmentList()
  for k,s in pairs(segments) do
    info.text = k
    info.arg1 = k
    UIDropDownMenu_AddButton(info)
  end
end

function q:SelectSegmentDropdown_OnLoad(frame)
  UIDropDownMenu_Initialize(frame, SelectSegmentDropdown_Initialize)
  UIDropDownMenu_SetWidth(frame, 100)
end

function q:SelectSegmentDropdown_OnShow(frame)
	UIDropDownMenu_Initialize(frame, SelectSegmentDropdown_Initialize);
	SelectSegmentDropdown_Update(frame);  
end

local function SelectModuleDropdown_Update(self)
  SelectModuleDropdownSelected:SetText(viewing_module_key)
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
  for _,m in ipairs(modules) do
    info.text = m
    info.arg1 = m
    UIDropDownMenu_AddButton(info)
  end
end

function q:SelectModuleDropdown_OnLoad(frame)
  UIDropDownMenu_Initialize(frame, SelectModuleDropdown_Initialize)
  UIDropDownMenu_SetWidth(frame, 50)
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

function q:updateUi()
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
  
  last_refresh = GetTime()
end

function q:viewingTotalSegment()
  return string.find(viewing_segment_key, "Segment %d+") == nil
end