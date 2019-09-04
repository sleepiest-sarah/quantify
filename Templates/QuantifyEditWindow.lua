local agui = LibStub("AceGUI-3.0", true)

function QuantifyEditWindow_Create(func, text, highlight, ...)
  local window = agui:Create("Window")
  window:SetLayout("Flow")
  window:SetWidth(300)
  window:SetHeight(100)
  window:EnableResize(false)
  window:SetCallback("OnClose", QuantifyEditWindow_OnClose)
  
  local editbox = agui:Create("EditBox")
  editbox:SetFullWidth(true)
  editbox:SetCallback("OnEnterPressed", QuantifyEditWindow_OnEnterPressed)
  editbox:DisableButton(true)
  
  editbox.callback = func
  editbox.args = ...
  
  editbox.window = window
  
  if (text) then
    editbox:SetText(text)
    
    if (highlight and string.len(text) > 0) then
      editbox:HighlightText(0,string.len(text))
    end
  end
  
  window.editbox = editbox
  
  local okay_button = agui:Create("Button")
  okay_button:SetWidth(100)
  okay_button.paddingx = 10
  okay_button:SetText("Okay")
  okay_button:SetCallback("OnClick", QuantifyEditWindowOkay_OnClick)
  okay_button.editbox = editbox
  local cancel_button = agui:Create("Button")
  cancel_button:SetWidth(100)
  cancel_button:SetText("Cancel")
  cancel_button:SetCallback("OnClick", QuantifyEditWindowCancel_OnClick)
  cancel_button.window = window
  
  
  local button_group = agui:Create("SimpleGroup")
  button_group:SetLayout("qFlow")
  button_group.content.rowpadding = 40
  button_group:SetFullWidth(true)
  
  button_group:AddChild(okay_button)
  button_group:AddChild(cancel_button)
  
  window.button_group = button_group
  
  window:AddChild(editbox)
  window:AddChild(button_group)
  
  return window
end

function QuantifyEditWindow_Show(self, anchor)
  if (anchor) then
    self:SetPoint("CENTER", anchor, "CENTER")
  end
  self:Show()
  self.editbox:SetFocus()
end

function QuantifyEditWindow_OnEnterPressed(self,event,text)
  if (self.callback) then
    self:callback(text, self.args)
  end
  self.window:Release()
end

function QuantifyEditWindowOkay_OnClick(self, event)
  local text = self.editbox:GetText()
  QuantifyEditWindow_OnEnterPressed(self.editbox, event, text)
end

function QuantifyEditWindowCancel_OnClick(self)
  self.window:Release()
end

function QuantifyEditWindow_OnClose(self)
  --self:Release()
end