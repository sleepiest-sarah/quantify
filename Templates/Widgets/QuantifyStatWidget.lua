local agui = LibStub("AceGUI-3.0", true)

local q = quantify
local qui = quantify_ui

qui.StatWidget = qui.Widget:new()
local StatWidget = qui.StatWidget
qui:RegisterWidget("StatWidget", StatWidget)

local function expandViewStats(view)
  local expanded_stat_keys = {}
  for _,stat_key in pairs(view.stats) do
    if (strfind(stat_key, "%*")) then
      local search_string = string.gsub(stat_key, "%*", ".*")
      for k,v in pairs(quantify.STATS) do
        if (strfind(k, search_string)) then
          table.insert(expanded_stat_keys, k)
        end
      end
    else
      table.insert(expanded_stat_keys, stat_key)
    end
  end
  
  view.stats = expanded_stat_keys
end



function StatWidget:create(data)
  local c = agui:Create("SimpleGroup")
  c.content.gridOptions = {
      rows = data.rows or 1,
      columns = data.columns or 1
  }
  
  c:SetFullWidth(true)
  c:SetFullHeight(true)
  c:SetLayout("qGrid")
  
  c:PauseLayout()
  
  self.views = {}
  for _,v in pairs(data.views) do
    local view_data = {}
    for i,view_data_key in ipairs(v.view_data) do
      view_data[i] = q.VIEWS[view_data_key]
    end

    local view_obj
    v.view_type = v.view_type or "table"
    if (v.view_type == "table") then
      view_obj = qui.StatView:new(v)
    elseif (v.view_type == "pie") then
      view_obj = qui.PieView:new(v)
    elseif (v.view_type == "multi") then
      view_obj = qui.MultiStatView:new(v)
    elseif (v.view_type == "filter") then
      view_obj = qui.FilterView:new(v)
    end
    
    for _,data in pairs(view_data) do
      expandViewStats(data)
    end
    table.insert(self.views, {view_data = view_data, view_obj = view_obj})
    
    c:AddChild(view_obj.widget)    
  end
  
  c:ResumeLayout()
  c:DoLayout()
  
  return self:registerWidget(c)
end

function StatWidget:refresh(redoLayout)
  for _,v in pairs(self.views) do
    local stats = {}
    for _,d in pairs(v.view_data) do
      table.insert(stats, q:buildStatsList(d))
    end
    v.view_obj:refresh(unpack(stats))
  end
end