local agui = LibStub("AceGUI-3.0")
local q = quantify

local LibQTip = LibStub('LibQTip-1.0')

local watchlist_cb

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

local function CreateSegmentList()
  local segments = quantify:getSegmentList()
  local keys_t = {}
  table.foreach(segments, function(k,v) table.insert(keys_t,k) end)
  table.sort(keys_t, segmentListComparator)
  
  local scrollcontainer = agui:Create("SimpleGroup")
  scrollcontainer:SetFullWidth(true)
  scrollcontainer:SetFullHeight(true)
  scrollcontainer:SetLayout("Fill")
  
  local c = agui:Create("ScrollFrame")
  c:SetLayout("Flow")
  
  scrollcontainer:AddChild(c)
  
  for _,seg in ipairs(keys_t) do
    local label = agui:Create("InteractiveLabel")
    label:SetText(q:capitalizeString(seg))
    label:SetHighlight(.5,.7,.3,.4)
    c:AddChild(label)
  end
  
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
  label:SetHighlight(.5,.7,.3,.4)
  c:AddChild(label)  
  
  for _,m in ipairs(modules) do
    label = agui:Create("InteractiveLabel")
    label:SetText(q:capitalizeString(m))
    label:SetHighlight(.5,.7,.3,.4)
    c:AddChild(label)
  end
  
  return scrollcontainer  
end

local function WidgetifyContainer(frame)
  local inherit_frame = agui:Create("SimpleGroup")
  
  local content = CreateFrame("Frame",nil,frame)
  content:SetPoint("TOPLEFT")
  content:SetPoint("BOTTOMRIGHT")
  
  frame["OnAcquire"] = inherit_frame["OnAcquire"]
  frame["LayoutFinished"] = inherit_frame["LayoutFinished"]
  frame["OnWidthSet"] = inherit_frame["OnWidthSet"]
  frame["OnHeightSet"] = inherit_frame["OnHeightSet"]
  
  local widget = {
      frame = frame,
      content = content,
      type = inherit_frame.type,
      ["SetPadding"] = function(self,x,y) self.content:SetPoint("TOPLEFT",x,y) end
    }
    
    return agui:RegisterAsContainer(widget)
end

function QuantifyContainer_Initialize()
  local bottom_bar = WidgetifyContainer(QuantifyBottomBar)
  bottom_bar:SetPadding(10,0)
  bottom_bar:SetLayout("List")
  
  watchlist_cb = CreateWatchlistCheckbox(100)
  
  bottom_bar:AddChild(watchlist_cb)
  
  local left_pane = WidgetifyContainer(QuantifyLeftPane)
  left_pane:SetLayout("List")
  left_pane:SetPadding(0,-10)
  
  local segmentlist = CreateSegmentList()
  segmentlist:SetHeight(100)
  
  local modulelist = CreateModuleList()
  modulelist:SetHeight(140)
  
  local segment_group =  agui:Create("InlineGroup")
  segment_group:SetFullWidth(true)
  segment_group:SetTitle("Segments")
  segment_group:AddChild(segmentlist)
  
  local module_group =  agui:Create("InlineGroup")
  module_group:SetFullWidth(true)
  module_group:SetTitle("Modules")
  module_group:AddChild(modulelist)
  
  
  
  left_pane:AddChild(segment_group)
  left_pane:AddChild(module_group)
  
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