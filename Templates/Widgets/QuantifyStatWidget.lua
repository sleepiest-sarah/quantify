local agui = LibStub("AceGUI-3.0", true)

local qui = quantify_ui

qui.StatWidget = qui.Widget:new()
local StatWidget = qui.StatWidget
qui:RegisterWidget("StatWidget", StatWidget)

local PRE_INITIALIZED_BUTTONS = 350

function StatWidget:create()  
  local stats_scrollcontainer = QuantifyStatScrollFrame_Create(PRE_INITIALIZED_BUTTONS)
  self.stats_scrollcontainer = stats_scrollcontainer
  
  local tabgroup = agui:Create("TabGroup")
  tabgroup:SetLayout("Fill")
  tabgroup:SetWidth(470)
  tabgroup:SetTabs({
        {value = "all", text = "All"},
        --{value = "summary", text = "Summary"},
        {value = "raw", text = "Totals"},
        {value = "session_rates", text = "Rates"},
        {value = "derived_stats", text = "Complex"},
        ---{value = "graphs", text = "Graphs"},
        --{value = "settings", text = "Settings"}
      })
  tabgroup:SetUserData("all",stats_scrollcontainer.frame)
  tabgroup:SetUserData("raw",stats_scrollcontainer.frame)
  tabgroup:SetUserData("session_rates",stats_scrollcontainer.frame)
  tabgroup:SetUserData("derived_stats",stats_scrollcontainer.frame)
  tabgroup:SetUserData("selected","all")
  tabgroup:SetCallback("OnGroupSelected", QuantifyTabGroup_OnGroupSelected)
  tabgroup:SelectTab("all")
  tabgroup:AddChild(stats_scrollcontainer)
  
  return self:registerWidget(tabgroup)
end

function StatWidget:refresh(redoLayout)
  local list = quantify:getStatsList()
  QuantifyStatScrollFrame_Refresh(self.stats_scrollcontainer, list, redoLayout)
end