
function QuantifyStatRowTemplate_SetLabel(self,text)
  local label,value = self:GetChildren()
  label:SetText(text)
end

function QuantifyStatRowTemplate_SetValue(self,text)
  local label,value = self:GetChildren()
  value:SetText(text)
end

function QuantifyStatRowTemplate_SetText(self,item)
  QuantifyStatRowTemplate_SetLabel(self,item.label)
  QuantifyStatRowTemplate_SetValue(self,item.value)
end