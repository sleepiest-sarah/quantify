
quantify.Item = {}
local Item = quantify.Item
function Item:new(arg1)
  local i
  if (type(arg1) ~= "table") then
    i = {GetItemInfo(arg1)}
  else
    i = arg1
  end
  if (i == nil) then
    return nil
  end
  local o = {}
  o.itemName, o.itemLink, o.itemRarity, o.itemLevel, o.itemMinLevel, o.itemType, o.itemSubType, o.itemStackCount,
  o.itemEquipLoc, o.itemIcon, o.itemSellPrice, o.itemClassID, o.itemSubClassID, o.bindType, o.expacID, o.itemSetID, 
  o.isCraftingReagent = unpack(i)
  setmetatable(o, self)
  self.__index = self
  return o
end

function Item:isEquippable()
  if (quantify_state:canPlayerEquipType(self.itemSubType) or self.itemSubType == "Miscellaneous") then
    return true
  end
  return false
end

function Item:getEffectiveILevel()
  return GetDetailedItemLevelInfo(self.itemLink)
end

function Item:isILevelUpgrade()
  local current1,current2 = self:getItemsInEquivalentSlot()
  
  local this_ilevel = self:getEffectiveILevel()
  local current1_ilevel = current1 and current1:getEffectiveILevel() or nil
  local current2_ilevel = current2 and current2:getEffectiveILevel() or nil
  
  return ((current1_ilevel and this_ilevel > current1_ilevel) or (current2_ilevel and this_ilevel > current2_ilevel))
end

function Item:getItemsInEquivalentSlot()
  local equipped_items = {}
  
  for _,slot in ipairs(Item[self.itemEquipLoc]) do
    local link = GetInventoryItemLink("player", slot)
    if (link) then
      table.insert(equipped_items, Item:new(link))
    end
  end
  
  return unpack(equipped_items)
end

function Item:getLocalizedInvTypeString()
  local loc = _G[self.itemEquipLoc]
  if (not loc and self.itemEquipLoc == "INVTYPE_RANGEDRIGHT") then
    loc = _G["INVTYPE_RANGED"]
  end
  return loc
end

Item.INVTYPE_AMMO = {0}
Item.INVTYPE_HEAD	=	{1}
Item.INVTYPE_NECK	=	{2}
Item.INVTYPE_SHOULDER	=	{3}
Item.INVTYPE_BODY	=	{4}
Item.INVTYPE_CHEST =	{5}
Item.INVTYPE_ROBE	=	{5}
Item.INVTYPE_WAIST	=	{6}
Item.INVTYPE_LEGS	=	{7}
Item.INVTYPE_FEET	=	{8}
Item.INVTYPE_WRIST	=	{9}
Item.INVTYPE_HAND	=	{10}
Item.INVTYPE_FINGER	=	{11,12}
Item.INVTYPE_TRINKET	=	{13,14}
Item.INVTYPE_CLOAK	=	{15}
Item.INVTYPE_WEAPON	= {16,17}
Item.INVTYPE_SHIELD	=	{17}
Item.INVTYPE_2HWEAPON	=	{16}
Item.INVTYPE_WEAPONMAINHAND	=	{16}
Item.INVTYPE_WEAPONOFFHAND	=	{17}
Item.INVTYPE_HOLDABLE =	{17}
Item.INVTYPE_RANGED	=	{18}
Item.INVTYPE_THROWN	=	{18}
Item.INVTYPE_RANGEDRIGHT=	{18}
Item.INVTYPE_RELIC =	{18}
Item.INVTYPE_TABARD	=	{19}

quantify.Faction = {}
local Faction = quantify.Faction
local function Faction_Init(self,...)
  local o = self or {}
  o.name, o.description, o.standingId, o.barMin, o.barMax, o.barValue, o.atWarWith, o.canToggleAtWar,
  o.isHeader, o.isCollapsed, o.hasRep, o.isWatched, o.isChild, o.factionId, o.hasBonusRepGain, o.hasBonusRepGain, 
  o.canBeLFGBonus = unpack({...})  
  return o
end

function Faction:new(...)
  local o = Faction_Init(nil,...)
  setmetatable(o, self)
  self.__index = self
  return o
end

function Faction:update()
  Faction_Init(self,GetFactionInfo(self.factionId))
end

Faction.HATED = 1
Faction.HOSTILE = 2
Faction.UNFRIENDLY = 3
Faction.NEUTRAL = 4
Faction.FRIENDLY = 5
Faction.HONORED = 6
Faction.REVERED = 7
Faction.EXALTED = 8

quantify.Party = {}
local Party = quantify.Party

function Party:new(o)
  o = o or {members = {}}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Party:addMember(name, role)
  self.members[name] = {name = name, role = role}
end

function Party:getPartyKey()
  local mates = {}
  for k,v in pairs(self.members) do
    table.insert(mates, v.name.."-"..v.role)
  end
  
  table.sort(mates)
  
  return strjoin("|", unpack(mates))
end