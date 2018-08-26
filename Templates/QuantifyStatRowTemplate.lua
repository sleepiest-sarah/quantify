local LibQTip = LibStub('LibQTip-1.0')

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

function QuantifyWatchListRowTemplate_OnEnter(self)
 local tooltip = LibQTip:Acquire("LabelTooltip", 3, "LEFT", "CENTER", "RIGHT")
 self.tooltip = tooltip 
 
 --tooltip:AddHeader('Segment', 'Stat', 'Value')
 
 local label,value = self:GetChildren()
 
 tooltip:AddLine(self.segment, label:GetText(), value:GetText())
 
 tooltip:SmartAnchorTo(self)
 
 tooltip:Show()  
end

function QuantifyWatchListRowTemplate_OnLeave(self)
 LibQTip:Release(self.tooltip)
 self.tooltip = nil
end