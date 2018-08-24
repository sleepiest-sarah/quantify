
local Type, Version = "QuantifyInlineGroup", 1
local agui = LibStub("AceGUI-3.0", true)


local methods = {

	["SetBorderColor"] = function(self, r,g,b,a)
		self.border:SetBackdropBorderColor(r,g,b,a or 1.0)
	end,

	["SetBackdropColor"] = function(self, r,g,b,a)
    self.border:SetBackdropColor(r,g,b,a or 1.0)
	end,

	["SetBackdrop"] = function(self, PaneBackdrop)
		self.border:SetBackdrop(PaneBackdrop)
	end
}

local PaneBackdrop  = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local function Constructor()
	local basegroup = agui:Create("InlineGroup")
  
  for i,c in ipairs(basegroup.frame:GetChildren()) do
    c:SetBackdrop(nil)
  end

	local border = CreateFrame("Frame", nil, basegroup.frame)
	border:SetPoint("TOPLEFT", 0, -17)
	border:SetPoint("BOTTOMRIGHT", -1, 3)
	border:SetBackdrop(PaneBackdrop)
	border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	border:SetBackdropBorderColor(0.4, 0.4, 0.4)

	local widget = basegroup
  widget.border = border
  widget.type = Type
	
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return agui:RegisterAsContainer(widget)
end

agui:RegisterWidgetType(Type, Constructor, Version)
