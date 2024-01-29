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
                
                local point, relativeTo, relativePoint, offsetX, offsetY = buff:GetPoint()
                
                if (index == 1) and (numBuffs > 0) then
                    buff:SetPoint(point, self.TargetFrameContent.TargetFrameContentContextual.buffs, relativePoint, offsetX, offsetY)
                else
                    buff:SetPoint(point, targetBuffsFrame, relativePoint, offsetX, offsetY)
                end
                -- From FrameXML\TargetFrame.lua:
                -- TargetFrameMixin:UpdateAuraFrames(auraList, numAuras, numOppositeAuras, setupFunc, anchorFunc, maxRowWidth, offsetX, mirrorAurasVertically, template)
                -- TargetFrame_UpdateDebuffAnchor(self, buff, index, numBuffs, anchorBuff, anchorIndex, size, offsetX, offsetY, mirrorVertically)
                -- anchorFunc(self, frame, i, numOppositeAuras, firstBuffOnRow, firstIndexOnRow, size, offsetX, offsetY, mirrorAurasVertically)
            end)
            
            hooksecurefunc("TargetFrame_UpdateBuffAnchor", function(self, buff, index, numDebuffs, anchorBuff, anchorIndex, size, offsetX, offsetY, mirrorVertically)
                if self ~= TargetFrame then return end
                
                local point, relativeTo, relativePoint, offsetX, offsetY = buff:GetPoint()
                
                if point and (anchorBuff ~= relativeTo) then
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
