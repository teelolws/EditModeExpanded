local addonName, addon = ...
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTargetFrame()
    local db = addon.db.global
    if db.EMEOptions.targetFrame then
        addon:registerSecureFrameHideable(TargetFrame)
        
        if db.EMEOptions.targetFrameBuffs then
            local targetBuffsFrame = CreateFrame("Frame", "TargetFrameBuffs", TargetFrame)
            targetBuffsFrame:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", 5, -10)
            targetBuffsFrame:SetSize(100, 10)
            lib:RegisterFrame(targetBuffsFrame, "Target Buffs", db.TargetBuffs)
            lib:SetDontResize(targetBuffsFrame)
            
            hooksecurefunc("TargetFrame_UpdateDebuffAnchor", function(self, buff, index, numBuffs, anchorBuff, anchorIndex, size, offsetX, offsetY, mirrorVertically)
                if self ~= TargetFrame then return end
                local isFriend = UnitIsFriend("player", self.unit)
                local targetFrameContentContextual = self.TargetFrameContent.TargetFrameContentContextual
                
                local point, relativeTo, relativePoint, offsetX, offsetY = buff:GetPoint()
                
                -- original code from FrameXML\TargetFrame.lua:
                --[[
                if (index == 1) then
            		if (isFriend and numBuffs > 0) then
            			-- unit is friendly and there are buffs...debuffs start on bottom
            			buff:SetPoint(point.."LEFT", targetFrameContentContextual.buffs, relativePoint.."LEFT", 0, -offsetY);
            		else
            			-- unit is not friendly or there are no buffs...debuffs start on top
            			buff:SetPoint(point.."LEFT", self.TargetFrameContainer.FrameTexture, relativePoint.."LEFT", AURA_START_X, startY);
            		end
            		targetFrameContentContextual.debuffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
            		targetFrameContentContextual.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
            		if ( ( isFriend ) or ( not isFriend and numBuffs == 0) ) then
            			self.spellbarAnchor = buff;
            		end
            	elseif (anchorIndex ~= (index-1)) then
            		-- anchor index is not the previous index...must be a new row
            		buff:SetPoint(point.."LEFT", anchorBuff, relativePoint.."LEFT", 0, -offsetY);
            		targetFrameContentContextual.debuffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
            		if (( isFriend ) or ( not isFriend and numBuffs == 0)) then
            			self.spellbarAnchor = buff;
            		end
            	else
                	-- anchor index is the previous index
            		buff:SetPoint(point.."LEFT", anchorBuff, point.."RIGHT", offsetX, 0);
            	end
                ]]
                
                if (index == 1) then
                    if isFriend and (numBuffs > 0) then
                        --buff:SetPoint(point, targetFrameContentContextual.buffs, relativePoint, offsetX, offsetY)
                    else
                        buff:SetPoint(point, targetBuffsFrame, relativePoint, offsetX, offsetY)
                    end
                else
                    buff:SetPoint(point, targetBuffsFrame, relativePoint, offsetX, offsetY)
                end
            end)
            
            hooksecurefunc("TargetFrame_UpdateBuffAnchor", function(self, buff, index, numDebuffs, anchorBuff, anchorIndex, size, offsetX, offsetY, mirrorVertically)
                if self ~= TargetFrame then return end
                local targetFrameContentContextual = self.TargetFrameContent.TargetFrameContentContextual;
                
                local point, relativeTo, relativePoint, offsetX, offsetY = buff:GetPoint()
                
                --[[
                	if (index == 1) then
                		if (UnitIsFriend("player", self.unit) or numDebuffs == 0) then
                			-- unit is friendly or there are no debuffs...buffs start on top
                			buff:SetPoint(point.."LEFT", self.TargetFrameContainer.FrameTexture, relativePoint.."LEFT", AURA_START_X, startY);
                		else
                			-- unit is not friendly and we have debuffs...buffs start on bottom
                			buff:SetPoint(point.."LEFT", targetFrameContentContextual.debuffs, relativePoint.."LEFT", 0, -offsetY);
                		end
                		targetFrameContentContextual.buffs:SetPoint(point.."LEFT", buff, point.."LEFT", 0, 0);
                		targetFrameContentContextual.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
                		self.spellbarAnchor = buff;
                	elseif (anchorIndex ~= (index-1)) then
                		-- anchor index is not the previous index...must be a new row
                		buff:SetPoint(point.."LEFT", anchorBuff, relativePoint.."LEFT", 0, -offsetY);
                		targetFrameContentContextual.buffs:SetPoint(relativePoint.."LEFT", buff, relativePoint.."LEFT", 0, -auraOffsetY);
                		self.spellbarAnchor = buff;
                	else
                		-- anchor index is the previous index
                		buff:SetPoint(point.."LEFT", anchorBuff, point.."RIGHT", offsetX, 0);
                	end
                ]]
                
                
                if point and (self.TargetFrameContainer.FrameTexture == relativeTo) then
                    buff:SetPoint(point, targetBuffsFrame, relativePoint, offsetX, offsetY)
                end
            end)
        end
        
        local targetFrameWasHidden
        lib:RegisterCustomCheckbox(TargetFrame, "Hide Name",
            function()
                TargetFrame.name:Hide()
                targetFrameWasHidden = true
            end,
            function()
                if targetFrameWasHidden then
                    TargetFrame.name:Show()
                end
                targetFrameWasHidden = false
            end,
            "HideName"
        )
    end
end
