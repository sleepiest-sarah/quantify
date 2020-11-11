local agui = LibStub("AceGUI-3.0", true)

local qui = quantify_ui

qui.View = {}
local View = qui.View

function View:new(o)
  o = o or {}

  setmetatable(o, self)
  self.__index = self
  
  return o
end

function View:createWrapper(view)
  local wrapper = agui:Create("SimpleGroup")
  
  wrapper.gridPosition = view.grid_position or "0,0"
  wrapper.colspan = view.colspan or 1
  wrapper.rowspan = view.rowspan or 1
  
  self.widget = wrapper
  
  return wrapper
end

function View:fixWidgetHeight(widget)
  widget.OnHeightSet = function(self, height)
    local parent_height = self.parent.frame.height
    if (height ~= parent_height) then
      self:SetHeight(parent_height)
    end
  end
end