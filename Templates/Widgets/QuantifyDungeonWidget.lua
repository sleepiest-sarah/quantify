local agui = LibStub("AceGUI-3.0", true)
local st = LibStub("ScrollingTable")

local q = quantify
local qui = quantify_ui

qui.DungeonWidget = qui.Widget:new()
local DungeonWidget = qui.DungeonWidget
qui:RegisterWidget("DungeonWidget", DungeonWidget)

local DUNGEONS_TABLE_COLS = 
{
    {
      ["name"] = "Dungeon",
      ["width"] = 220
    },
    {
      ["name"] = "Difficulty",
      ["width"] = 80
    },
    {
      ["name"] = "Runs",
      ["width"] = 30
    },  
    {
      ["name"] = "Avg. Comp. Time",
      ["width"] = 120
    },  
    {
      ["name"] = "Kill-to-Wipe Ratio",
      ["width"] = 120
    },
    {
      ["name"] = "Deaths-to-Clear Ratio",
      ["width"] = 120,
    }
  }
  
local PLAYER_TABLE_COLS =
{
    {
      ["name"] = "Name",
      ["width"] = 150,
      
    },
    {
      ["name"] = "Runs",
      ["width"] = 60
    },
    {
      ["name"] = "Deaths-to-Clear Ratio",
      ["width"] = 110
    }
}

local PARTY_TABLE_COLS =
{
    {
      ["name"] = "Party",
      ["width"] = 150
    },
    {
      ["name"] = "Runs",
      ["width"] = 60
    },
    {
      ["name"] = "Kill-to-Wipe Ratio",
      ["width"] = 110
    }
}

DungeonWidget.filter = {
  dungeons = {},
  expansion = "Shadowlands",
  difficulties = {},
  minKeystoneLevel = 1,
  maxKeystoneLevel = 99
}

local function createKeystoneFilter(self)
  local keystone_wrapper = agui:Create("QuantifyContainerWrapper")
  keystone_wrapper:SetLayout("Flow")
  keystone_wrapper.gridPosition = "3,0"
  keystone_wrapper:SetPadding(10,0)
  
  local keystone_level_label = agui:Create("Label")
  keystone_level_label:SetText("Keystone Level:")
  keystone_level_label:SetWidth(60)
  
  local keystone_to_level_label = agui:Create("Label")
  keystone_to_level_label:SetText(" —")
  keystone_to_level_label:SetWidth(14)
  
  local min_level_box = agui:Create("EditBox")
  local max_level_box = agui:Create("EditBox")
  min_level_box:SetWidth(30)
  max_level_box:SetWidth(30)
  min_level_box:SetMaxLetters(2)
  max_level_box:SetMaxLetters(2)
  min_level_box:SetCallback("OnTextChanged", self.validateKeystoneLevelInput)
  max_level_box:SetCallback("OnTextChanged", self.validateKeystoneLevelInput)
  min_level_box:DisableButton(true)
  max_level_box:DisableButton(true)
  min_level_box.editbox:SetScript("OnEditFocusLost", self.minKeystoneLevelEditFinished)
  min_level_box:SetCallback("OnEnterPressed", self.minKeystoneLevelEditFinished)
  max_level_box.editbox:SetScript("OnEditFocusLost", self.maxKeystoneLevelEditFinished)
  max_level_box:SetCallback("OnEnterPressed", self.maxKeystoneLevelEditFinished)
  
  min_level_box:SetText("1")
  max_level_box:SetText("99")
  
  keystone_wrapper:AddChild(keystone_level_label)
  keystone_wrapper:AddChild(min_level_box)
  keystone_wrapper:AddChild(keystone_to_level_label)
  keystone_wrapper:AddChild(max_level_box)
  
  return keystone_wrapper
end


function DungeonWidget:create()
  local c = agui:Create("SimpleGroup")
  c.content.gridOptions = {
    rows = 11,
    columns = 4
  }
  c:SetFullWidth(true)
  c:SetFullHeight(true)
  c:SetLayout("qGrid")
  
  c:PauseLayout()
  
  --expansion dropdown
  local expansion_dropdown = agui:Create("Dropdown")
  expansion_dropdown.gridPosition = "0,0"
  expansion_dropdown:SetMultiselect(false)
  expansion_dropdown:SetCallback("OnValueChanged", self.expansionValueChanged)
  expansion_dropdown:SetList(qDA:getExpansions())
  
  self.expansion_dropdown = expansion_dropdown
  expansion_dropdown.parentWidget = self
  c:AddChild(expansion_dropdown)
  
  --dungeon filter
  local dungeon_dropdown = agui:Create("Dropdown")
  dungeon_dropdown.gridPosition = "1,0"
  dungeon_dropdown:SetMultiselect(true)
  dungeon_dropdown:SetCallback("OnValueChanged", self.dungeonValueChanged)
  dungeon_dropdown:SetText("Filter Dungeons")
  
  self.dungeon_dropdown = dungeon_dropdown
  dungeon_dropdown.parentWidget = self
  c:AddChild(dungeon_dropdown)
  
  --difficulty dropdown
  local difficulty_dropdown = agui:Create("Dropdown")
  difficulty_dropdown.gridPosition = "2,0"
  difficulty_dropdown:SetMultiselect(true)
  self.filter.difficulties = {["Mythic+"] = true, ["Mythic"] = true, ["Heroic"] = true, ["Normal"] = true, ["Timewalking"] = true}
  difficulty_dropdown:SetList({["Mythic+"] = "Mythic+",["Mythic"] = "Mythic",["Heroic"] = "Heroic",["Normal"] = "Normal",["Timewalking"] = "Timewalking"}, {"Mythic+","Mythic","Heroic","Normal","Timewalking"})
  self:checkAllDropdownValues(difficulty_dropdown)
  difficulty_dropdown:SetCallback("OnValueChanged", self.difficultyValueChanged)
  
  self.difficulty_dropdown = difficulty_dropdown
  difficulty_dropdown.parentWidget = self
  c:AddChild(difficulty_dropdown)
  
  --keystone level filter
  local keystone_wrapper = createKeystoneFilter(self)
  c:AddChild(keystone_wrapper)
  
  --players table
  local players_frame = agui:Create("SimpleGroup")
  players_frame.gridPosition = "0,1"
  players_frame.colspan = 2
  players_frame.rowspan = 2
  players_frame:SetLayout("Fill")
  local player_table_wrapper = agui:Create("SimpleGroup")
  player_table_wrapper:PauseLayout()
  player_table_wrapper:SetHeight(170)
  player_table_wrapper:SetFullWidth(true)
  local players_table = st:CreateST(PLAYER_TABLE_COLS,7,20,nil,player_table_wrapper.frame)
  players_table.frame:SetPoint("TOPLEFT", 0, -5)
  self.player_table = players_table
  players_frame:AddChild(player_table_wrapper)
  
  c:AddChild(players_frame)
  
  --party table
  local party_frame = agui:Create("SimpleGroup")
  party_frame.gridPosition = "2,1"
  party_frame.colspan = 2
  party_frame.rowspan = 2
  party_frame:SetLayout("Fill")
  local party_table_wrapper = agui:Create("SimpleGroup")
  party_table_wrapper:PauseLayout()
  party_table_wrapper:SetHeight(170)
  party_table_wrapper:SetWidth(300)
  local party_table = st:CreateST(PARTY_TABLE_COLS,5,28,nil,party_table_wrapper.frame)
  party_table.frame:SetPoint("TOPLEFT", 0, -5)
  self.party_table = party_table
  party_frame:AddChild(party_table_wrapper)
  
  c:AddChild(party_frame)
  
  local dungeonsTableWrapper = agui:Create("SimpleGroup")
  dungeonsTableWrapper:PauseLayout()
  local dungeons_table = st:CreateST(DUNGEONS_TABLE_COLS,nil,30,nil,dungeonsTableWrapper.frame)
  dungeons_table.frame:SetPoint("TOPLEFT", 10, 25)
  self.dungeons_table = dungeons_table
  dungeonsTableWrapper.gridPosition = "0,5"
  dungeonsTableWrapper.colspan = 3
  dungeonsTableWrapper.rowspan = 5
  c:AddChild(dungeonsTableWrapper)
  
  c:ResumeLayout()
  c:DoLayout()
  
  expansion_dropdown.pullout.items[q.EJ_SL]:Fire("OnValueChanged",q.EJ_SL)
  
  return self:registerWidget(c)
end

function DungeonWidget:refresh(redoLayout, segmentUpdate, moduleUpdate, visibilityUpdate, filterUpdate)
  if (segmentUpdate or moduleUpdate or visibilityUpdate or filterUpdate) then
    
    local dungeons = qDA:getDungeonData(self.filter)
    local dungeons_list = q:buildDisplayTable(dungeons, "name", "difficulty", "completed_runs", "avg_time", "kdr", "ddr")
    self.dungeons_table:SetData(dungeons_list,true)
    self.dungeons_table:SortData();
    
    local players = qDA:getDungeonPlayers(self.filter)
    local player_rows = q:buildDisplayTable(players, "name", "dungeons_completed", "ddr")
    self.player_table:SetData(player_rows, true)
    self.player_table:SortData()
    
    local parties = qDA:getDungeonParties(self.filter)
    for _,p in pairs(parties) do
      local party_string = ""
      for _,m in pairs(p.members) do
        party_string = party_string .. q:getRoleIcon(m.role) .. m.name .. "\n"
      end
      p.party_display_string = party_string
    end
    local party_rows = q:buildDisplayTable(parties, "party_display_string", "dungeons_completed", "kdr")
    self.party_table:SetData(party_rows, true)
    self.party_table:SortData()
  end
end

function DungeonWidget:expansionValueChanged(event, key)
  local filter = self.parentWidget.filter
  filter.expansion = key
  
  local dungeons = qDA:getExpansionDungeons(key)
  filter.dungeons = {}
  for id,d in pairs(dungeons) do
    filter.dungeons[d] = true
  end
  
  local dungeon_dropdown = self.parentWidget.dungeon_dropdown
  dungeon_dropdown:SetList(q:keyTable(dungeons))
  self.parentWidget:checkAllDropdownValues(dungeon_dropdown)
  
  self.parentWidget:refresh(false,false,false,false,true)
end

function DungeonWidget:dungeonValueChanged(event, key, checked)
  local filter = self.parentWidget.filter
  filter.dungeons[key] = checked
  self.parentWidget:refresh(false,false,false,false,true)
end

function DungeonWidget:difficultyValueChanged(event, key, checked)
  local filter = self.parentWidget.filter
  filter.difficulties[key] = checked
  self.parentWidget:refresh(false,false,false,false,true)
end

function DungeonWidget:validateKeystoneLevelInput(event, text)
  if (not tonumber(text)) then
    self:SetText("")
  end
end

function DungeonWidget:minKeystoneLevelEditFinished()
  local filter = self.parentWidget.filter
  filter.minKeystoneLevel = tonumber(self:GetText()) or 1
  
    if (filter.difficulties["Mythic+"]) then
    self.parentWidget:refresh(false,false,false,false,true)
  end
end

function DungeonWidget:maxKeystoneLevelEditFinished()
  local filter = self.parentWidget.filter
  filter.maxKeystoneLevel = tonumber(self:GetText()) or 99
  
  if (filter.difficulties["Mythic+"]) then
    self.parentWidget:refresh(false,false,false,false,true)
  end
end