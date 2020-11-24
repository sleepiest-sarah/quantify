local agui = LibStub("AceGUI-3.0", true)

local q = quantify
local qui = quantify_ui

qui.MultiStatView = qui.View:new()
local MultiStatView = qui.MultiStatView

local function createSingleStatView(multiview)
  local views = {}
  for i,data in ipairs(multiview.view_data) do
    views[i] = {padding_x = multiview.padding_x, 
                padding_y = multiview.padding_y,
                view_options = {columns = multiview.view_options.columns[i]},
                view_data = {multiview.view_data[i]}
                }
  end
  
  return views
end

local function create(self,view)
  local wrapper = self:createWrapper(view)
  
  local stat_wrapper = agui:Create("SimpleGroup")
  self.stat_wrapper = stat_wrapper
  stat_wrapper:SetLayout("qFill")
  
  local single_views = createSingleStatView(view)
  local first_view = qui.StatView:new(single_views[1])
  local second_view = qui.StatView:new(single_views[2])
  
  stat_wrapper:AddChild(first_view.widget)
  stat_wrapper:AddChild(second_view.widget)
  
  second_view.widget.frame:Hide()
  self.active_view = first_view
  
  self.button_text = view.view_options.button_text
  
  local rate_button = agui:Create("Button")
  rate_button:SetText(self.button_text[2])
  rate_button:SetCallback("OnClick", self.rateButtonClick)
  rate_button:SetWidth(110)
  rate_button.view = self
  
  wrapper:AddChild(rate_button)
  wrapper:AddChild(stat_wrapper)
  
  wrapper:PauseLayout()
  
  rate_button:SetPoint("TOPLEFT", wrapper.frame, "TOPRIGHT", -190, 5)
  stat_wrapper:SetPoint("TOPLEFT", 0, 0)
  
  self:fixWidgetHeight(stat_wrapper)
  
  self.views = {first_view, second_view}
end

function MultiStatView:new(view)
  local o = {}

  setmetatable(o, self)
  self.__index = self
  
  create(o,view)
  
  return o
end

function MultiStatView:rateButtonClick()
  local multiview = self.view
  if (multiview.active_view == multiview.views[1]) then
    multiview.views[2].widget.frame:Show()
    multiview.views[1].widget.frame:Hide()
    multiview.active_view = multiview.views[2]
    self:SetText(multiview.button_text[1])
  else
    multiview.views[1].widget.frame:Show()
    multiview.views[2].widget.frame:Hide()
    multiview.active_view = multiview.views[1]
    self:SetText(multiview.button_text[2])
  end
  multiview.stat_wrapper:DoLayout()
end

function MultiStatView:refresh(stats, stats2)
  self.views[1]:refresh(stats)
  self.views[2]:refresh(stats2)
end
