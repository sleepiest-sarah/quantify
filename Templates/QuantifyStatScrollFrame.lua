local agui = LibStub("AceGUI-3.0", true)

local function createStatRow(self,i)
  local wrapper = self.stats_buttons["ViewStatsButton"..tostring(i)]
  if (not wrapper) then
    local button = CreateFrame("Button", nil, nil, "QuantifyStatRowTemplate")
    
    wrapper = agui:Create("QuantifyContainerWrapper")
    wrapper:SetQuantifyFrame(button)
    wrapper:SetLayout("Fill")
    wrapper:SetFullWidth(true)
    
    wrapper.i = i

    self.stats_buttons["ViewStatsButton"..tostring(i)] = wrapper
    
    self:PauseLayout()
    self:AddChild(wrapper)
  end
  
  return wrapper
end

function QuantifyStatScrollFrame_Create(numPreInitializedButtons)
  local stats_scrollcontainer = agui:Create("SimpleGroup")
  stats_scrollcontainer:SetFullWidth(true)
  stats_scrollcontainer:SetLayout("Fill")
  
  local stats_scrollframe = agui:Create("ScrollFrame")
  stats_scrollcontainer.stats_scrollframe = stats_scrollframe
  stats_scrollframe:SetLayout("qList")
  
  stats_scrollframe.stats_buttons = {}
  
    --create some buttons ahead of time for performance
  if (qDbOptions.preload ~= false and (numPreInitializedButtons and numPreInitializedButtons > 0)) then
    stats_scrollframe:PauseLayout()
    for i=1,numPreInitializedButtons do
      createStatRow(stats_scrollframe,i)
    end
    stats_scrollframe:ResumeLayout()
  end
  
  stats_scrollcontainer:AddChild(stats_scrollframe)
  
  return stats_scrollcontainer
end

function QuantifyStatScrollFrame_Refresh(self, list, redoLayout)
  self = self.stats_scrollframe
  
  local listn = #list
  
  --reuse buttons for performance
  for i,item in ipairs(list) do
    local wrapper = createStatRow(self,i)
    
    QuantifyStatRowTemplate_SetText(wrapper.frame,item)
    
    wrapper.frame:Show()
  end

  local index = 1
  for _,b in pairs(self.stats_buttons) do
    if (b.i > listn) then
      b.frame:Hide()
    end
    
    index = index + 1
  end

  if (redoLayout or self.LayoutPaused) then
    self:ResumeLayout()
    self:DoLayout()
  end
end