local agui = LibStub("AceGUI-3.0", true)

local q = quantify
local qui = quantify_ui

qui.FilterView = qui.View:new()
local FilterView = qui.FilterView

local function create(self,view)
  local wrapper = self:createWrapper(view)
  local options = view.view_options
  
  self.filter_method = options.filter_method
  
  local filter_widget
  if (options.filter_type == "dropdown") then
    filter_widget = agui:Create("Dropdown")
    filter_widget.parentWidget = self
    filter_widget:SetCallback("OnValueChanged", self.filterValueChanged)
    if (options and options.dropdown_values) then
      local dropdown_values = options.dropdown_values
      if (type(dropdown_values) == "function") then
        dropdown_values = dropdown_values()
      end
      
      if (options.filter_method ~= "table") then
        dropdown_values = q:keyTable(dropdown_values)
      end
      
      dropdown_values[""] = ""
      filter_widget:SetList(dropdown_values)
    end
  elseif (options.filter_type == "text") then
    filter_widget = agui:Create("EditBox")
    filter_widget.parentWidget = self
    filter_widget:DisableButton(true)
    filter_widget:SetCallback("OnTextChanged", self.textFilterValueChanged)
    filter_widget:SetLabel(options.filter_label or "Filter Stats")
  end
  
  local statview = qui.StatView:new(view)
  self.statview = statview
  
  wrapper:AddChild(filter_widget)
  wrapper:AddChild(statview.widget)
  
  wrapper:PauseLayout()
  
  filter_widget:SetPoint("TOPLEFT", wrapper.frame, "TOPRIGHT", -210, 5)
  statview.widget:SetPoint("TOPLEFT", 0, 0)
  
  self:fixWidgetHeight(statview.widget)
  
end

function FilterView:new(view)
  local o = {}

  setmetatable(o, self)
  self.__index = self
  
  create(o,view)
  
  return o
end

function FilterView:filterValueChanged(event, key)
  local filter_view = self.parentWidget
  
  filter_view.filterValue = key == "" and nil or key
  
  qui:RefreshWidget()
end

function FilterView:textFilterValueChanged(event, text)
  if (#text >= 3) then
    self.parentWidget.filterValue = self:GetText()
    self.filterDirty = true
    
    qui:RefreshWidget()
  elseif (text == "" and self.filterDirty) then
    self.filterDirty = false
    self.parentWidget.filterValue = self:GetText()
    
    qui:RefreshWidget()
  end
end

function FilterView:refresh(stats)
  local filtered_stats
  if (self.filterValue and self.filterValue ~= "") then
    filtered_stats = {}
    for i,s in ipairs(stats) do
      if ((not self.filter_method or self.filter_method == "text") and strfind(strlower(s[1]), strlower(self.filterValue))) then
        table.insert(filtered_stats,s)
      elseif (self.filter_method == "table" and s.filter and s.filter[self.filterValue] == s.stat_key) then
        table.insert(filtered_stats,s)
      end
    end
  end
  filtered_stats = filtered_stats or stats
  
  self.statview:refresh(filtered_stats)
end