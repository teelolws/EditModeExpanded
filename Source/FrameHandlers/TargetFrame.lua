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
            addon:registerFrame(targetBuffsFrame, "Target Buffs", db.TargetBuffs)
            lib:SetDontResize(targetBuffsFrame)
            
            hooksecurefunc("TargetFrame_UpdateDebuffAnchor", function(self, buff)
                if self ~= TargetFrame then return end
                
                local point, relativeTo, relativePoint, offsetX, offsetY = buff:GetPoint()
                
                if point and (self.TargetFrameContainer.FrameTexture == relativeTo) then
                    buff:SetPoint(point, targetBuffsFrame, relativePoint, offsetX, offsetY)
                end
            end)
            
            hooksecurefunc("TargetFrame_UpdateBuffAnchor", function(self, buff)
                if self ~= TargetFrame then return end
                
                local point, relativeTo, relativePoint, offsetX, offsetY = buff:GetPoint()
                
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
