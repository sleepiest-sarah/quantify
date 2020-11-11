local Type, Version = "QuantifyTableWrapper", 1
local agui = LibStub("AceGUI-3.0", true)

local methods = {
  
  ["SetPadding"] = function(self,x,y,x2,y2)
    self.content:SetPoint("TOPLEFT", self.parent.frame, "TOPLEFT", x,y) 
    if (x2 and y2) then
      self.content:SetPoint("BOTTOMRIGHT",x2,y2)
    end
  end,
  
  ["SetTable"] = function(self, scrolling_table)
    --self.frame = scrolling_table.frame
    --self.content = scrolling_table.frame
    
    self.table = scrolling_table
  end,
  
  ["OnHeightSet"] = function(self, height)
    if (self.table) then
      local parent_height = self.parent.frame.height
      local height_pct = self.height_pct or 1
      height = height_pct * parent_height
      
      local st = self.table
      local display_rows = math.floor(height / st.rowHeight)
      st:SetDisplayRows(display_rows, st.rowHeight)
    end
  end,
  
  ["OnWidthSet"] = function(self, width)
    if (self.table) then
      width = self.parent.frame.width
      local st = self.table
      for i,col in pairs(st.cols) do
        local pct = col.width / st.frame:GetWidth()
        col.width = pct * st.frame:GetWidth()
      end
      st:SetDisplayCols(st.cols)
    end
  end,
  
  ["SetHeightPercent"] = function(self, pct)
    if (self.table) then
      self.height_pct = pct
      self:OnHeightSet()
    end
  end,  
}

local function Constructor()
	local baseframe = agui:Create("SimpleGroup")

	local widget = baseframe
  widget.type = baseframe.type
  
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return agui:RegisterAsContainer(widget)
end

agui:RegisterWidgetType(Type, Constructor, Version)
