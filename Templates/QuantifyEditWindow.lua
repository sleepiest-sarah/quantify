local agui = LibStub("AceGUI-3.0", true)

function QuantifyEditWindow_Create(func, text, highlight, ...)
  local window = agui:Create("Window")
  window:SetLayout("Fill")
  window:SetWidth(300)
  window:SetHeight(150)
  window:SetCallback("OnClose", QuantifyEditWindow_OnClose)
  
  local editbox = agui:Create("EditBox")
  editbox:SetWidth(300)
  editbox:SetCallback("OnEnterPressed", QuantifyEditWindow_OnEnterPressed)
  
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
  window:AddChild(editbox)
  
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

function QuantifyEditWindow_OnClose(self)
  self:Release()
end