local agui = LibStub("AceGUI-3.0", true)

function QuantifyConfirmWindow_Create(func, text, ...)
  local window = agui:Create("Window")
  window:SetLayout("Flow")
  window:SetWidth(300)
  window:SetHeight(220)
  window:EnableResize(false)
  window:SetCallback("OnClose", QuantifyConfirmWindow_OnClose)
  
  local confirmText = agui:Create("Label")
  confirmText:SetFullWidth(true)
  confirmText:SetText(text)
  
  window.callback = func
  window.args = ...
  
  local okay_button = agui:Create("Button")
  okay_button:SetWidth(100)
  okay_button.paddingx = 10
  okay_button:SetText("Okay")
  okay_button:SetCallback("OnClick", QuantifyConfirmWindowOkay_OnClick)
  okay_button.window = window
  local cancel_button = agui:Create("Button")
  cancel_button:SetWidth(100)
  cancel_button:SetText("Cancel")
  cancel_button:SetCallback("OnClick", QuantifyConfirmWindowCancel_OnClick)
  cancel_button.window = window
  
  
  local button_group = agui:Create("SimpleGroup")
  button_group:SetLayout("qFlow")
  button_group.content.rowpadding = 40
  button_group:SetFullWidth(true)
  
  button_group:AddChild(okay_button)
  button_group:AddChild(cancel_button)
  
  window.button_group = button_group
  
  window:AddChild(confirmText)
  window:AddChild(button_group)
  
  return window
end

function QuantifyConfirmWindow_Show(self, anchor)
  if (anchor) then
    self:SetPoint("CENTER", anchor, "CENTER")
  end
  self:Show()
end

function QuantifyConfirmWindowOkay_OnClick(self, event)
  self.window:callback(self.window.args)
  self.window:Release()
end

function QuantifyConfirmWindowCancel_OnClick(self)
  self.window:Release()
end

function QuantifyConfirmWindow_OnClose(self)
  --self:Release()
end