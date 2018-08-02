
function QuantifyStatRowTemplate_SetLabel(self,text)
  local label,value = self:GetChildren()
  label:SetText(text)
end

function QuantifyStatRowTemplate_SetValue(self,text)
  local label,value = self:GetChildren()
  value:SetText(text)
end

function QuantifyStatRowTemplate_SetText(self,text)
  local label,value = string.match(text,"(.+):(.+)")
  QuantifyStatRowTemplate_SetLabel(self,label)
  QuantifyStatRowTemplate_SetValue(self,value)
end