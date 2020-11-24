local agui = LibStub("AceGUI-3.0", true)
local st = LibStub("ScrollingTable")

local q = quantify
local qui = quantify_ui

qui.DungeonDetailsWidget = qui.Widget:new()
local DungeonDetailsWidget = qui.DungeonDetailsWidget
qui:RegisterWidget("DungeonDetailsWidget", DungeonDetailsWidget)

local HISTORY_TABLE_COLS = {
    {
      ["name"] = "Date",
      ["width"] = 140
    },
    {
      ["name"] = "Dungeon",
      ["width"] = 140
    },
    {
      ["name"] = "Difficulty",
      ["width"] = 100
    },  
    {
      ["name"] = "Completion Time",
      ["width"] = 100
    },  
    {
      ["name"] = "Wipes",
      ["width"] = 60
    },
    {
      ["name"] = "Party Deaths",
      ["width"] = 60,
    }  
  }

local function backButtonOnClick(button)
  qui:SetActiveWidget(button.parent_widget.dungeon_widget)
end

function DungeonDetailsWidget:create(dungeon_widget)
  local c = agui:Create("SimpleGroup")
  c.content.gridOptions = {
    rows = 20,
    columns = 20
  }
  c:SetFullWidth(true)
  c:SetFullHeight(true)
  c:SetLayout("qGrid")  
  
  c:PauseLayout()
  
  self.dungeon_widget = dungeon_widget
  
  local back_button = agui:Create("Button")
  back_button.parent_widget = self
  back_button:SetText("Back")
  back_button:SetCallback("OnClick", backButtonOnClick)
  back_button.gridPosition = "0,0"
  back_button.colspan = 2
  c:AddChild(back_button)
  
  local filter_details = agui:Create("InlineGroup")
  self.filter_group = filter_details
  filter_details:SetTitle("Applied Filters")
  filter_details.gridPosition = "0,1"
  filter_details.colspan = 5
  filter_details.rowspan = 10
  
  c:AddChild(filter_details)
  
  --player/party/dungeon stats
  local entity_data_group = agui:Create("InlineGroup")
  entity_data_group:SetLayout("qFlow")
  entity_data_group:SetAutoAdjustHeight(false)
  self.entity_data_group = entity_data_group
  entity_data_group.gridPosition = "7,1"
  entity_data_group.rowspan = 10
  entity_data_group.colspan = 10
  
  local key_list = agui:Create("SimpleGroup")
  self.entity_key_list = key_list
  key_list:SetLayout("qList")
  key_list:SetFullHeight(true)
  key_list:SetRelativeWidth(.49)
  entity_data_group:AddChild(key_list)
  
  local value_list = agui:Create("SimpleGroup")
  self.entity_value_list = value_list
  value_list:SetLayout("qList")
  value_list:SetFullHeight(true)
  value_list:SetRelativeWidth(.49)
  entity_data_group:AddChild(value_list)
  
  c:AddChild(entity_data_group)
  
  --history table
  local history_table_wrapper = agui:Create("SimpleGroup")
  history_table_wrapper.gridPosition = "0,11"
  history_table_wrapper.colspan = 20
  history_table_wrapper.rowspan = 10
  history_table_wrapper:PauseLayout()

  local history_table = st:CreateST(HISTORY_TABLE_COLS,7,30,nil,history_table_wrapper.frame)
  self.history_table = history_table
  
  c:AddChild(history_table_wrapper)
  
  c:ResumeLayout()
  c:DoLayout()
  
  return self:registerWidget(c)
end

function DungeonDetailsWidget:update(data_type, data_key, data, filter)
  self.filter = filter
  self.data_type = data_type
  self.data = data
  self.data_key = data_key
  
  self.filter_group:ReleaseChildren()
  
  local expansion_label = agui:Create("Label")
  expansion_label:SetText("Expansion: "..filter.expansion_name)
  expansion_label:SetFontObject(AchievementPointsFontSmall)
  self.filter_group:AddChild(expansion_label)
  
  local keystone_label = agui:Create("Label")
  keystone_label:SetText("Keystone Level: "..filter.minKeystoneLevel.."-"..filter.maxKeystoneLevel)
  keystone_label:SetFontObject(AchievementPointsFontSmall)
  self.filter_group:AddChild(keystone_label)
  
  local dungeon_separator = agui:Create("Label")
  dungeon_separator:SetText("---Dungeons---")
  dungeon_separator:SetFontObject(AchievementPointsFontSmall)
  
  self.filter_group:AddChild(dungeon_separator)
  
  for dungeon, included in pairs(filter.dungeons) do
    if (included) then
      local label = agui:Create("Label")
      label:SetText(dungeon)
      self.filter_group:AddChild(label)
    end
  end
  
  local difficulty_separator = agui:Create("Label")
  difficulty_separator:SetText("---Difficulties---")
  difficulty_separator:SetFontObject(AchievementPointsFontSmall)
  
  self.filter_group:AddChild(difficulty_separator)
  
  for difficulty, included in pairs(filter.difficulties) do
    if (included) then
      local label = agui:Create("Label")
      label:SetText(difficulty)
      self.filter_group:AddChild(label)
    end
  end
  
  self.entity_data_group:PauseLayout()
  
  self.entity_key_list:ReleaseChildren()
  self.entity_value_list:ReleaseChildren()
  
  if (data_type == "players" or data_type == "dungeons") then
    self.entity_data_group:SetTitle(data[1])
  elseif (data_type == "parties") then
    local title = string.gsub(data[1], "\n", " ")
    self.entity_data_group:SetTitle(title)
  end
  
  self.completed_runs_label = agui:Create("Label")
  self.cumulative_time_label = agui:Create("Label")
  self.ddr_label = agui:Create("Label")
  self.wdr_label = agui:Create("Label")
  self.kdr_label = agui:Create("Label")
  
  self.completed_runs_key_label = agui:Create("Label")
  self.cumulative_time_key_label = agui:Create("Label")
  self.ddr_key_label = agui:Create("Label")
  self.wdr_key_label = agui:Create("Label")
  self.kdr_key_label = agui:Create("Label")
  
  self.completed_runs_key_label:SetFontObject(AchievementPointsFontSmall)
  self.cumulative_time_key_label:SetFontObject(AchievementPointsFontSmall)
  self.ddr_key_label:SetFontObject(AchievementPointsFontSmall)
  self.wdr_key_label:SetFontObject(AchievementPointsFontSmall)
  self.kdr_key_label:SetFontObject(AchievementPointsFontSmall)
  
  self.completed_runs_label:SetFontObject(StatRowValueFont)
  self.cumulative_time_label:SetFontObject(StatRowValueFont)
  self.ddr_label:SetFontObject(StatRowValueFont)
  self.wdr_label:SetFontObject(StatRowValueFont)
  self.kdr_label:SetFontObject(StatRowValueFont)
  
  self.entity_key_list:AddChild(self.completed_runs_key_label)
  self.entity_key_list:AddChild(self.cumulative_time_key_label)
  self.entity_key_list:AddChild(self.ddr_key_label)
  self.entity_key_list:AddChild(self.wdr_key_label)
  self.entity_key_list:AddChild(self.kdr_key_label)
  
  self.entity_value_list:AddChild(self.completed_runs_label)
  self.entity_value_list:AddChild(self.cumulative_time_label)
  self.entity_value_list:AddChild(self.ddr_label)
  self.entity_value_list:AddChild(self.wdr_label)
  self.entity_value_list:AddChild(self.kdr_label)
  
end

local function formatEntityData(data)
  data.cumulative_time = q:getFormattedUnit(data.cumulative_time,"time")
  data.ddr = q:getFormattedUnit(data.ddr,"decimal")
  data.wdr = q:getFormattedUnit(data.wdr,"decimal")
  data.kdr = q:getFormattedUnit(data.kdr,"decimal")
end

local function formatHistoryData(key, data)
  if (key == "date") then
    return date("%b-%d-%y %X", data)
  elseif (key == "time") then
    return q:getFormattedUnit(data,"time")
  else
    return data
  end
  
end

function DungeonDetailsWidget:refresh(redoLayout, segmentUpdate, moduleUpdate, visibilityUpdate, filterUpdate)
  local history = qDA:getDungeonHistory(self.data_type, self.data_key, self.filter)
  local history_list = q:buildDisplayTable(history, formatHistoryData, "date", "name", "difficulty", "time", "wipes", "party_deaths")
  self.history_table:SetData(history_list,true)
  self.history_table:SortData();
  
  local entity_data
  if (self.data_type == "players") then
    entity_data = qDA:getDungeonPlayers(self.filter, self.data_key)[self.data_key]
  elseif (self.data_type == "parties") then
    entity_data = qDA:getDungeonParties(self.filter, self.data_key)[self.data_key]
  elseif (self.data_type == "dungeons") then
    entity_data = qDA:getDungeonData(self.filter, self.data_key)[self.data_key]    
    entity_data = q:shallowCopy(entity_data)
  end
  
  formatEntityData(entity_data)
  
  self.completed_runs_key_label:SetText("Completed Runs: ")
  self.cumulative_time_key_label:SetText("Cumulative Time: ")
  self.ddr_key_label:SetText("Death-to-Completion Ratio: ")
  self.wdr_key_label:SetText("Wipe-to-Completion Ratio: ")
  self.kdr_key_label:SetText("Boss Kill-to-Wipe Ratio: ")

  self.completed_runs_label:SetText(entity_data.completed_runs)
  self.cumulative_time_label:SetText(entity_data.cumulative_time)
  self.ddr_label:SetText(entity_data.ddr)
  self.wdr_label:SetText(entity_data.wdr)
  self.kdr_label:SetText(entity_data.kdr)
  
  self.entity_data_group:ResumeLayout()
  self.entity_data_group:DoLayout()
end