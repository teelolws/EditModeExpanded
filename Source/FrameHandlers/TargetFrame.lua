local addonName, addon = ...
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTargetFrame()
    local db = addon.db.global
    if db.EMEOptions.targetFrame then
        addon:registerSecureFrameHideable(TargetFrame)
        
        if db.EMEOptions.targetFrameBuffs then
            local targetDebuffsFrame = CreateFrame("Frame", "TargetFrameDebuffs", TargetFrame)
            local targetBuffsFrame = CreateFrame("Frame", "TargetFrameBuffs", TargetFrame)
            
            targetBuffsFrame:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", 5, -10)
            targetDebuffsFrame:SetPoint("TOPLEFT", targetBuffsFrame, "BOTTOMLEFT", 0, -5)
            
            targetDebuffsFrame:SetSize(100, 10)
            targetBuffsFrame:SetSize(100, 10)
            
            lib:RegisterFrame(targetDebuffsFrame, "Target Debuffs", db.TargetDebuffs)
            lib:RegisterFrame(targetBuffsFrame, "Target Buffs", db.TargetBuffs)
            
            lib:SetDontResize(targetDebuffsFrame)
            lib:SetDontResize(targetBuffsFrame)
            
            hooksecurefunc("TargetFrame_UpdateDebuffAnchor", function(self, buff, index, numBuffs, anchorBuff, anchorIndex, size, offsetX, offsetY, mirrorVertically)
                if self ~= TargetFrame then return end
                
                local point, relativeTo, relativePoint, offsetX, offsetY = buff:GetPoint()
                
                if point and (anchorBuff ~= relativeTo) then
                    buff:SetPoint(point, targetDebuffsFrame, relativePoint, offsetX, offsetY)
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
