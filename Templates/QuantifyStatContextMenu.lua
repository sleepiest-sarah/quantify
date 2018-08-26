local menu

function QuantifyStatContextMenu_Create()
  menu = CreateFrame("Frame", "QuantifyStatContextMenu", UIParent, "UIDropDownMenuTemplate")
  UIDropDownMenu_Initialize(menu, QuantifyStatContextMenu_Load, "MENU")
  menu:SetWidth(100)
  menu:SetPoint("BOTTOMRIGHT")
  --menu:Hide()
end

function QuantifyStatContextMenu_Load()
  local add = {
      text = "Add to Watchlist",
      value = "add",
      notCheckable = true,
      func = quantify.copyToClipboard
    }
  
  local copy = {
      text = "Copy to Clipboard",
      value = "copy",
      notCheckable = true,
      func = quantify.copyToClipboard
    }
    
  local share = {
      text = "Share",
      value = "share",
      notCheckable = true,
      func = quantify.shareStat
    }
    
  local reset = {
      text = "Reset",
      value = "reset",
      notCheckable = true,
      func = quantify.resetStat
    }

  
  UIDropDownMenu_AddButton(add)
  UIDropDownMenu_AddButton(copy)
  UIDropDownMenu_AddButton(share)
  UIDropDownMenu_AddButton(reset)
end

function QuantifyStatContextMenu_Toggle(anchor, x, y)
  ToggleDropDownMenu(1, nil, menu, anchor or "cursor", x or -80, y or 60)
end