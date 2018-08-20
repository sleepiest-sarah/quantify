
function QuantifyStatRowTemplate_SetLabel(self,text)
  local label,value = self:GetChildren()
  label:SetText(text)
end

function QuantifyStatRowTemplate_SetValue(self,text)
  local label,value = self:GetChildren()
  value:SetText(text)
end

function QuantifyStatRowTemplate_SetText(self,item)
  self.dict_key = item.dict_key
  self.subkey = item.subkey
  self.segment = item.segment
  QuantifyStatRowTemplate_SetLabel(self,item.label)
  QuantifyStatRowTemplate_SetValue(self,item.value)
end

function QuantifyStatRowTemplate_OnDoubleClick(self)
  quantify:addWatchListItem(self.dict_key,self.subkey)
end

function QuantifyWatchListRowTemplate_OnDoubleClick(self)
  quantify:removeWatchListItem(self.dict_key,self.subkey,self.segment)
end