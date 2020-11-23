local statmenu,watchlistmenu

function QuantifyContextMenu_Initialize()
  statmenu = QuantifyContextMenu_Create(QuantifyStatContextMenu_Load)
  watchlistmenu = QuantifyContextMenu_Create(QuantifyWatchlistContextMenu_Load)
end

function QuantifyContextMenu_Create(func)
  local menu = CreateFrame("Frame", "QuantifyStatContextMenu", UIParent, "UIDropDownMenuTemplate")
  UIDropDownMenu_Initialize(menu, func, "MENU")
  menu:SetWidth(100)
  menu:SetPoint("BOTTOMRIGHT")
  
  return menu
end

function QuantifyStatContextMenu_Load(self)
  local add = {
      text = "Add to Watchlist",
      value = "add",
      notCheckable = true,
      arg1 = self,
      func = quantify.addWatchlistItemMenu
    }
  
  local copy = {
      text = "Copy to Clipboard",
      value = "copy",
      notCheckable = true,
      arg1 = self,
      func = quantify.copyToClipboard
    }
    
  local share = {
      text = "Share",
      value = "share",
      notCheckable = true,
      func = quantify.shareStat
    }
    
  local reset = {
      text = "Reset Stat",
      value = "reset",
      notCheckable = true,
      arg1 = self,
      func = quantify.resetStatMenu
    }

  
  UIDropDownMenu_AddButton(add)
  UIDropDownMenu_AddButton(copy)
  --UIDropDownMenu_AddButton(share)
  UIDropDownMenu_AddButton(reset)
end

local function createSaveWatchListMenu(self)
  
  local save = {
    text = "Save",
    value = "save",
    notCheckable = true,
    arg1 = self,
    func = quantify.saveWatchlist
  }
  
  local new = {
    text = "Save As...",
    value = "new",
    notCheckable = true,
    func = quantify.saveWatchlist
  }
  
  local delete = {
    text = "Delete",
    value = "delete",
    notCheckable = true,
    arg1 = self,
    func = quantify.deleteSavedWatchlist
  }
    
  UIDropDownMenu_AddButton(save,2)
  --UIDropDownMenu_AddButton(new,2)
  UIDropDownMenu_AddButton(delete,2)
end

local function createLoadWatchListMenu(self)
  local watchlists = quantify:getSavedWatchlists()
  
  for k,watchlist in pairs(watchlists) do
    local info = {
      text = k,
      value = k,
      arg1 = self,
      arg2 = k,
      notCheckable = true,
      func = quantify.loadWatchlist
    }
    
    UIDropDownMenu_AddButton(info,2)
  end
  
end

function QuantifyWatchlistContextMenu_Load(self,level)
  if (level == 1) then
    local remove = {
        text = "Remove from Watchlist",
        value = "remove",
        notCheckable = true,
        arg1 = self,
        func = quantify.removeWatchlistItemMenu
      }
      
    local load = {
        text = "Load Watchlist",
        value = "load",
        notCheckable = true,
        hasArrow = true
      }
      
    local save = {
        text = "Save Watchlist",
        value = "save",
        notCheckable = true,
        hasArrow = true
      }
    
    local copy = {
        text = "Copy to Clipboard",
        value = "copy",
        notCheckable = true,
        arg1 = self,
        func = quantify.copyToClipboard
      }
      
    local share = {
        text = "Share",
        value = "share",
        notCheckable = true,
        func = quantify.shareStat
      }
      
    local reset = {
        text = "Reset Stat",
        value = "reset",
        notCheckable = true,
        arg1 = self,
        func = quantify.resetStatMenu
      }
    
    UIDropDownMenu_AddButton(remove)
    UIDropDownMenu_AddButton(copy)
    UIDropDownMenu_AddButton(load)
    UIDropDownMenu_AddButton(save)
    --UIDropDownMenu_AddButton(share)
    UIDropDownMenu_AddButton(reset)
  elseif (level == 2 and UIDROPDOWNMENU_MENU_VALUE == "save") then
    createSaveWatchListMenu(self)
  elseif (level == 2 and UIDROPDOWNMENU_MENU_VALUE == "load") then
    createLoadWatchListMenu(self)
  end
end

function QuantifyStatContextMenu_Toggle(type, userdata, anchor, x, y)
  local menu
  if (type == nil or type == "stat") then
    menu = statmenu
  else
    menu = watchlistmenu
  end
  
  menu.userdata = userdata
  
  ToggleDropDownMenu(1, nil, menu, anchor or "cursor", x or -80, y or 60)
end