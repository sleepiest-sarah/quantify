local agui = LibStub("AceGUI-3.0")
local q = quantify
local qui = quantify_ui

local LibQTip = LibStub('LibQTip-1.0')

local watchlist_cb

local selected_module,selected_segment

local segment_list

local stats_buttons = {}

local widgets = {}

local active_widget
local maincontainer

local function CreateWatchlistCheckbox(width)
  width = width or 200
  x = x or 0
  y = y or 0
  
  local cb = agui:Create("CheckBox")
  cb:SetLabel("Watchlist")
  cb:SetValue(false)
  
  cb:SetWidth(width)
  
  cb:SetCallback("OnValueChanged", quantify.toggleWatchlist)
  cb:SetCallback("OnEnter", QuantifyWatchListCheckbox_OnEnter)
  cb:SetCallback("OnLeave", QuantifyWatchListCheckbox_OnLeave)  
  
  return cb
end

local function segmentListComparator(a,b)
  local a_id = string.match(a, "Segment (%d+)")
  local b_id = string.match(b, "Segment (%d+)")
  if (a == "account" or b == "account") then  --account should always be first
    return a == "account"
  elseif (a_id ~= nil and b_id ~= nil) then   --sort segments according to id
    return a_id < b_id
  elseif ((a_id ~= nil and b_id == nil) or (a_id == nil and b_id ~= nil)) then   --segments should be last
    return a_id == nil
  else                                        --sort character names alphabetically
    return a < b
  end
    
end

local function QuantifySegmentLabel_OnClick(self) 
  q:setViewingSegment(self.segment)
  
  selected_segment:SetColor(nil)
  
  self:SetColor(1,.82,0)
  
  selected_segment = self
  
  qui:RefreshWidget(true, true, false, false)
end

local function QuantifyModuleLabel_OnClick(self) 
  if (active_widget) then
    active_widget:Hide()
  end
  self.module:Show()
  active_widget = self.module
  maincontainer:DoLayout()
  
  if (selected_module) then
    selected_module:SetColor(nil)
  end
  
  self:SetColor(1,.82,0)

  
  selected_module = self
  
  qui:RefreshWidget(true, false, true, false)

end

function QuantifySegmentList_Refresh(self)
  self = self or segment_list
  
  self:ReleaseChildren()
  
  local segments = quantify:getAllSegments()
  local keys_t = {}
  table.foreach(segments, function(k,v) table.insert(keys_t,k) end)
  table.sort(keys_t, segmentListComparator)
  for _,seg in ipairs(keys_t) do
    local label = agui:Create("InteractiveLabel")
    label:SetText(q:capitalizeString(seg))
    label:SetFontObject(AchievementPointsFontSmall)
    label.segment = seg
    
    if (seg == "Segment 1") then
      local separator = agui:Create("Label")
      separator:SetText("---")
      self:AddChild(separator)
    end
    
    if (seg == "Segment "..table.maxn(q.segments)) then 
      label:SetColor(1,.82,0)
      selected_segment = label
    end
    
    label:SetCallback("OnClick", QuantifySegmentLabel_OnClick)
    
    self:AddChild(label) 
  end
end

local function CreateSegmentList()
  local scrollcontainer = agui:Create("SimpleGroup")
  scrollcontainer:SetFullWidth(true)
  scrollcontainer:SetFullHeight(true)
  scrollcontainer:SetLayout("Fill")
  
  local c = agui:Create("ScrollFrame")
  c:SetLayout("Flow")
  segment_list = c
  
  scrollcontainer:AddChild(c)
  
  QuantifySegmentList_Refresh(c)
  
  return scrollcontainer
end

local function CreateModuleList()
  local modules = quantify:getModuleKeys()
  table.sort(modules)
  
  local scrollcontainer = agui:Create("SimpleGroup")
  scrollcontainer:SetFullWidth(true)
  scrollcontainer:SetFullHeight(true)
  scrollcontainer:SetLayout("Fill")
  
  local c = agui:Create("ScrollFrame")
  c:SetLayout("Flow")
  
  scrollcontainer:AddChild(c)
  
  local labels = {}
  
  maincontainer:PauseLayout()
  
  for k,w in pairs(QUANTIFY_WIDGETS) do
    local label
    label = agui:Create("InteractiveLabel")
    label:SetText(k)
    label.qText = k
    label.module = qui:CreateWidget(w.widget, w.data)
    label:SetCallback("OnClick", QuantifyModuleLabel_OnClick)
    label:SetFontObject(AchievementPointsFontSmall)
    table.insert(labels, label) 
  end
  
  table.sort(labels, function (a,b) 
        return a.qText < b.qText
      end)
  
  for _,label in pairs(labels) do
    c:AddChild(label)
    maincontainer:AddChild(label.module.widget)
    label.module:Hide()
  end
  
  maincontainer:ResumeLayout()
  maincontainer:DoLayout()
  
  QuantifyModuleLabel_OnClick(labels[1])
  
  return scrollcontainer  
end

function QuantifyNewSegmentButton_OnClick(self)
  q.AddSegmentButton_OnClick()
  
  QuantifySegmentList_Refresh()
end

local function CreateSegmentControl()
  local container = agui:Create("SimpleGroup")
  container:SetLayout("Flow")
  container:SetWidth(180)
  
  local new_seg_button = agui:Create("Button")
  new_seg_button:SetText("New Segment")
  new_seg_button:SetCallback("OnClick", QuantifyNewSegmentButton_OnClick)
  
  container:AddChild(new_seg_button)
  
  return container
end

function QuantifyWatchListCheckbox_Toggle(value)
  if (value) then
    watchlist_cb:SetValue(value)
  else
    watchlist_cb:ToggleChecked()
  end
end

function QuantifyWatchListCheckbox_OnEnter(self)
 local tooltip = LibQTip:Acquire("WatchlistCheckboxTooltip", 1, "LEFT")
 self.tooltip = tooltip 

 
 tooltip:AddLine("Double click to add or remove stats from the watchlist")
 
 tooltip:SmartAnchorTo(self.frame)
 
 tooltip:Show()  
end

function QuantifyWatchListCheckbox_OnLeave(self)
 LibQTip:Release(self.tooltip)
 self.tooltip = nil
end

function QuantifyTabGroup_OnGroupSelected(self,event,group)
  local selected = self:GetUserData("selected")
  if (self:GetUserData(selected)) then
    self:GetUserData(selected):Hide()
  end
  
  if (self:GetUserData(group)) then
    self:GetUserData(group):Show()
  end
  
  self:SetUserData("selected", group)
  
  if (group == "all" or group == "raw" or group == "session_rates" or group == "derived_stats") then
    quantify:setViewingSubkey(group)
    quantify:ViewAllStats_Update()
  end
  
  qui:RefreshWidget(true)
end

function qui:RefreshWidget(redoLayout, segmentUpdate, moduleUpdate, visiblityUpdate)
  if (active_widget and q.quantify_ui_shown) then
    active_widget:refresh(redoLayout, segmentUpdate, moduleUpdate, visiblityUpdate)
  end
end

function QuantifyContainer_Initialize()
  QuantifyContainer_Frame:SetBackdrop(BACKDROP_QUANTIFY_WINDOW)
  --QuantifyBottomBar:SetBackdrop(BACKDROP_QUANTIFY_BAR)
  
  local qcontainer = agui:Create("QuantifyContainerWrapper")
  qcontainer:SetQuantifyFrame(QuantifyContainer_Frame)
  qcontainer:SetLayout("Fill")
  
  maincontainer = agui:Create("QuantifyContainerWrapper")
  maincontainer:SetQuantifyFrame(QuantifyMainPane)
  maincontainer:SetLayout("qFill")
  maincontainer:SetWidth("780")
  maincontainer:SetHeight("630")
  
  local bottom_bar = agui:Create("QuantifyContainerWrapper")
  bottom_bar:SetQuantifyFrame(QuantifyBottomBar)
  bottom_bar:SetPadding(10,5)
  bottom_bar:SetLayout("List")
  
  watchlist_cb = CreateWatchlistCheckbox(100)
  
  bottom_bar:AddChild(watchlist_cb)
  
  local left_pane = agui:Create("QuantifyContainerWrapper")
  left_pane:SetQuantifyFrame(QuantifyLeftPane)
  left_pane:SetLayout("List")
  left_pane:SetPadding(10,-10)
  
  local segmentlist = CreateSegmentList()
  segmentlist:SetHeight(250)
  
  local modulelist = CreateModuleList()
  modulelist:SetHeight(240)

  local segment_group =  agui:Create("QuantifyInlineGroup")
  segment_group:SetWidth(180)
  segment_group:SetTitle("Segments")
  segment_group:AddChild(segmentlist)
  
  local module_group =  agui:Create("QuantifyInlineGroup")
  module_group:SetWidth(180)
  module_group:SetTitle("Modules")
  module_group:AddChild(modulelist)
  
  local segment_control_group = CreateSegmentControl()
  
  left_pane:AddChild(segment_group)
  left_pane:AddChild(segment_control_group)
  left_pane:AddChild(module_group)
  
  QuantifyContextMenu_Initialize()
end