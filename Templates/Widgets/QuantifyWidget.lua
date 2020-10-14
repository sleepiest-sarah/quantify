local agui = LibStub("AceGUI-3.0", true)

local qui = quantify_ui

local widgets = {}

function qui:RegisterWidget(name, class)
  widgets[name] = class
end

function qui:CreateWidget(name)
  local widget = widgets[name]:new()
  return widget:create()
end

qui.Widget = {}
local Widget = qui.Widget 

function Widget:new(o)
  o = o or {}
  
  setmetatable(o, self)
  self.__index = self
  
  return o
end

function Widget:registerWidget(content, layout)
  local widget = agui:Create("SimpleGroup")
  
  widget:SetFullWidth(true)
  widget:SetFullHeight(true)
  widget:SetLayout(layout or "Fill")
  
  widget:AddChild(content)
  
  self.widget = widget
  
  return self
end

function Widget:Hide()
  self.widget.frame:Hide()
end

function Widget:Show()
  self.widget.frame:Show()
end

function Widget:checkAllDropdownValues(dropdown)
  for k,v in pairs(dropdown.list) do
    dropdown:SetItemValue(k,v)
  end
end