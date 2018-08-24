local agui = LibStub("AceGUI-3.0")
local q = quantify

local LibQTip = LibStub('LibQTip-1.0')

local watchlist_cb

local selected_module,selected_segment

local segment_list

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
  elseif (a_id ~= nil and b_id == nil) then   --segments should be last
    return false
  else                                        --sort character names alphabetically
    return a < b
  end
    
end

local function QuantifySegmentLabel_OnClick(self) 
  q:setViewingSegment(self.segment)
  
  selected_segment:SetColor(nil)
  selected_segment:SetFontObject(GameFontHighlightSmall)
  
  self:SetColor(1,.82,0)
  self:SetFontObject(AchievementPointsFontSmall)
  
  selected_segment = self
end

local function QuantifyModuleLabel_OnClick(self) 
  q:setCurrentViewModule(self.module)
  
  selected_module:SetColor(nil)
  selected_module:SetFontObject(GameFontHighlightSmall)
  
  self:SetColor(1,.82,0)
  self:SetFontObject(AchievementPointsFontSmall)
  
  selected_module = self
end

function QuantifySegmentList_Refresh(self)
  self = self or segment_list
  
  self:ReleaseChildren()
  
  local segments = quantify:getSegmentList()
  local keys_t = {}
  table.foreach(segments, function(k,v) table.insert(keys_t,k) end)
  table.sort(keys_t, segmentListComparator)
  for _,seg in ipairs(keys_t) do
    local label = agui:Create("InteractiveLabel")
    label:SetText(q:capitalizeString(seg))
    label.segment = seg
    
    if (seg == "Segment 1") then
      local separator = agui:Create("Label")
      separator:SetText("---")
      self:AddChild(separator)
    end
    
    if (seg == "Segment "..table.maxn(q.segments)) then 
      label:SetColor(1,.82,0)
      label:SetFontObject(AchievementPointsFontSmall)
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
  
  local label = agui:Create("InteractiveLabel")
  label:SetText("All")
  label.module = "All"
  label:SetCallback("OnClick", QuantifyModuleLabel_OnClick)
  label:SetColor(1,.82,0)
  label:SetFontObject(AchievementPointsFontSmall)
  c:AddChild(label)  
  
  selected_module = label
  
  for _,m in ipairs(modules) do
    label = agui:Create("InteractiveLabel")
    label:SetText(q:capitalizeString(m))
    label.module = m
    label:SetCallback("OnClick", QuantifyModuleLabel_OnClick)
    c:AddChild(label)
  end
  
  return scrollcontainer  
end

function QuantifyNewSegmentButton_OnClick(self)
  q.AddSegmentButton_OnClick()
  
  QuantifySegmentList_Refresh()
end

local function CreateSegmentControl()
  local container = agui:Create("SimpleGroup")
  container:SetLayout("Flow")
  container:SetFullWidth(true)
  
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

function QuantifyContainer_Initialize()
  local qcontainer = agui:Create("QuantifyContainerWrapper")
  qcontainer:SetQuantifyFrame(QuantifyContainer_Frame)
  qcontainer:SetLayout("Fill")
  
  local maincontainer = agui:Create("QuantifyContainerWrapper")
  maincontainer:SetQuantifyFrame(QuantifyMainPane)
  maincontainer:SetLayout("Fill")
  
  local statscontainer = agui:Create("QuantifyContainerWrapper")
  statscontainer:SetQuantifyFrame(ViewAllStats_Container)
  statscontainer:SetLayout("Fill")
  
  local tabgroup = agui:Create("TabGroup")
  tabgroup:SetLayout("Fill")
  tabgroup:SetWidth(470)
  tabgroup:SetTabs({
        {value = "all", text = "All"},
        {value = "summary", text = "Summary"},
        {value = "raw", text = "Raw"},
        {value = "rates", text = "Rates"},
        {value = "derived", text = "Complex"},
        {value = "graphs", text = "Graphs"},
        {value = "settings", text = "Settings"}
      })
  tabgroup:SelectTab("all")
  tabgroup:AddChild(statscontainer)
  
  
  maincontainer:AddChild(tabgroup)
  
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
  segmentlist:SetHeight(100)
  
  local modulelist = CreateModuleList()
  modulelist:SetHeight(140)

  local segment_group =  agui:Create("QuantifyInlineGroup")
  segment_group:SetBackdropColor(.1,.1,.1,.8)
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
  
end