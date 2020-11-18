local agui = LibStub("AceGUI-3.0", true)
local lg = LibStub("LibGraph-2.0")
local LibQTip = LibStub('LibQTip-1.0')

local qui = quantify_ui

qui.PieView = qui.View:new()
local PieView = qui.PieView

local function pieSliceSelected(graph, section)
  LibQTip:Release(graph.tooltip)
  graph.tooltip = nil
  
  if (section) then
   local tooltip = LibQTip:Acquire("LabelTooltip", 2, "LEFT", "CENTER", "RIGHT")
   graph.tooltip = tooltip 
   
   tooltip:AddLine(graph.pie_labels[section][1], graph.pie_labels[section][2])
   
   tooltip:SmartAnchorTo(graph)
   
   tooltip:Show()  
  end
end

local function create(self, view)
  local chart_wrapper = self:createWrapper(view)
  local options = view.view_options or {}
  
  local label = agui:Create("Label")
  label:SetText(options.label or view.view_data[1])
  label:SetFontObject(AchievementPointsFontSmall)
  
  chart_wrapper:AddChild(label)
  
  chart_wrapper:PauseLayout()
  
  local chart = lg:CreateGraphPieChart("test", chart_wrapper.frame, "TOPLEFT", "TOPLEFT", view.padding_x, view.padding_y, 250, 250)
  chart:SetSelectionFunc(pieSliceSelected)
  
  self.chart = chart
end

function PieView:new(view)
  local o = {}

  setmetatable(o, self)
  self.__index = self
  
  create(o,view)
  
  return o  
end

function PieView:refresh(stats)
  self.chart:ResetPie()
  local pie_labels = {}
  for i,pct in ipairs(stats) do
    local t = string.gsub(pct[2], "%%", "")
    local num = tonumber(t)
    if (num > 0) then
      table.insert(pie_labels,pct)
      self.chart:AddPie(tonumber(t))
    end
  end

  if (#pie_labels == 1) then
    self.chart:ResetPie()
    self.chart:CompletePie()
  else
    table.insert(pie_labels,{"% Other", tostring(math.floor(100 - self.chart.PercentOn)).."%"})
    self.chart:CompletePie()
  end
  
  self.chart.pie_labels = pie_labels
end

