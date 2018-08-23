local agui = LibStub("AceGUI-3.0")

local function CreateWatchlistCheckbox(width, x, y)
  width = width or 200
  x = x or 0
  y = y or 0
  
  local cb = agui:Create("CheckBox")
  cb:SetLabel("Watchlist")
  cb:SetValue(false)
  
  --cb:SetPoint("TOPLEFT",x,y)
  cb:SetWidth(width)
  
  cb:SetCallback("OnValueChanged", quantify.toggleWatchlist)
  
  return cb
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

function QuantifyContainer_Initialize(self)
  local bottom_bar = WidgetifyContainer(QuantifyBottomBar)
  bottom_bar:SetPadding(10,0)
  bottom_bar:SetLayout("List")
  
  local watchlist_cb = CreateWatchlistCheckbox(200)
  
  bottom_bar:AddChild(watchlist_cb)
  
end