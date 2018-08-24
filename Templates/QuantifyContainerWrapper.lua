
local Type, Version = "QuantifyContainerWrapper", 1
local agui = LibStub("AceGUI-3.0", true)

local methods = {

	["SetQuantifyFrame"] = function(self, qframe)
    local content = CreateFrame("Frame",nil,qframe)
    content:SetPoint("TOPLEFT")
    content:SetPoint("BOTTOMRIGHT")    
    
		self.frame = qframe
    self.content = content
    
    agui:RegisterAsContainer(self)
	end,
  
  ["SetPadding"] = function(self,x,y)
    self.content:SetPoint("TOPLEFT",x,y) 
  end
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
