local agui = LibStub("AceGUI-3.0", true)


--same as the ace List but doesn't show children frames that are hidden and doesn't consider hidden frames in the container height
--useful for redoing the layout when reusing widgets
agui:RegisterLayout("qList",
	function(content, children)
		local height = 0
		local width = content.width or content:GetWidth() or 0
		for i = 1, #children do
			local child = children[i]
			
			local frame = child.frame
			frame:ClearAllPoints()
			--frame:Show()
			if i == 1 then
				frame:SetPoint("TOPLEFT", content)
			else
				frame:SetPoint("TOPLEFT", children[i-1].frame, "BOTTOMLEFT")
			end
			
			if child.width == "fill" then
				child:SetWidth(width)
				frame:SetPoint("RIGHT", content)
				
				if child.DoLayout then
					child:DoLayout()
				end
			elseif child.width == "relative" then
				child:SetWidth(width * child.relWidth)
				
				if child.DoLayout then
					child:DoLayout()
				end
			end
			
      if (child:IsShown()) then
        height = height + (frame.height or frame:GetHeight() or 0)
      end
		end
    if (content.obj.LayoutFinished) then
      content.obj.LayoutFinished(content.obj,nil,height)
    end
	end)