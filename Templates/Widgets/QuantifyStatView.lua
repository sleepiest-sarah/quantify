local st = LibStub("ScrollingTable")
local agui = LibStub("AceGUI-3.0", true)

local q = quantify
local qui = quantify_ui

local DEFAULT_TABLE_COLUMNS = 
{
  {
    ["name"] = "Name",
    ["width"] = 200
  },
  {
    ["name"] = "Value",
    ["width"] = 100,
    ["sortnext"] = 1
  },
  {
    ["name"] = "Value2",
    ["width"] = 100,
    ["sortnext"] = 1
  }
}

qui.StatView = qui.View:new()
local StatView = qui.StatView

local function stDoubleClick(rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, button)
  if (button == "LeftButton") then
    local datarow = data[realrow]
    
    local stat_key = type(datarow.stat_key) == "table" and datarow.stat_key[1] or datarow.stat_key
    local data_key = type(datarow.data_key) ~= "table" and datarow.data_key or (datarow.data_key and datarow.data_key[1])

    q:addWatchListItem(stat_key, data_key)
  end
end

local function stRightClick(rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, button)
  if (button == "RightButton") then
    local datarow = data[realrow]
    local userdata = {}
    
    userdata.stat_key = type(datarow.stat_key) == "table" and datarow.stat_key[1] or datarow.stat_key
    userdata.data_key = type(datarow.data_key) ~= "table" and datarow.data_key or (datarow.data_key and datarow.data_key[1])
    userdata.segment = datarow.viewing_segment_key
    userdata.label = datarow[1]
    userdata.value = datarow[2] .. " " .. (datarow[3] or "")
    QuantifyStatContextMenu_Toggle("stat", userdata)
  end
end

local function create(self,view)
  local view_options = view.view_options or {}
  
  local view_wrapper = self:createWrapper(view)
  local table_wrapper = agui:Create("QuantifyTableWrapper")
  table_wrapper:PauseLayout()
  

  self.columns = {}
  for i=1,#view.view_data+1 do
    self.columns[i] = {name = view_options.columns and view_options.columns[i] or DEFAULT_TABLE_COLUMNS[i].name,
                       width = view_options.col_widths and view_options.col_widths[i] or DEFAULT_TABLE_COLUMNS[i].width,
                       sortnext = view_options.sort_next and view_options.sort_next[i] or DEFAULT_TABLE_COLUMNS[i].sortnext} 
  end
  self.columns[1].defaultsort = st.SORT_ASC
  self.sorted = false

  local stat_table = st:CreateST(self.columns, 16, 30, nil, table_wrapper.content)
  stat_table:RegisterEvents({["OnDoubleClick"] = stDoubleClick, ["OnClick"] = stRightClick})
  table_wrapper:SetTable(stat_table)
  
  local label = agui:Create("Label")
  label:SetText(view_options.label or view.view_data[1])
  label:SetFontObject(AchievementPointsFontSmall)
  
  view_wrapper:AddChild(label)
  view_wrapper:AddChild(table_wrapper)
  
  view_wrapper:PauseLayout()
  
  table_wrapper:SetHeightPercent(.8)
  table_wrapper:SetPadding(view.padding_x or 0, view.padding_y or 0)
  
  self.stat_table = stat_table
end

function StatView:new(view)
  local o = {}

  setmetatable(o, self)
  self.__index = self
  
  create(o,view)
  
  return o
end

function StatView:refresh(...)
  local stats = {...}
  
  local formatted_stats = stats[1]
  if (#stats > 1) then
    formatted_stats = {}
    for i,row in ipairs(stats[1]) do
      formatted_stats[i] = q:shallowCopy(row)
      formatted_stats[i].stat_key = {formatted_stats[i].stat_key}
      formatted_stats[i].data_key = {formatted_stats[i].data_key}
      if (stats[2]) then
        for j=3,#self.columns do
          if (stats[j-1] and stats[j-1][i]) then
            formatted_stats[i][j] = stats[j-1][i][2]
            formatted_stats[i].stat_key[j-1] = stats[j-1][i].stat_key
            formatted_stats[i].data_key[j-1] = stats[j-1][i].data_keyy
          else
            formatted_stats[i][j] = "-"
          end
        end
      end
    end
  end
  
  if (not self.sorted) then
    self.stat_table.cols[1].sort = st.SORT_ASC
    self.sorted = true
  end
  self.stat_table:SetData(formatted_stats, true)
  self.stat_table:SortData()
end
