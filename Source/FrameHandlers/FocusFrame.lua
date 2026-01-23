local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initFocusFrame()
    local db = addon.db.global
    if not db.EMEOptions.focusFrame then return end
    
    addon:registerSecureFrameHideable(FocusFrame)
    
    local nameWasHidden
    lib:RegisterCustomCheckbox(FocusFrame, L["Hide Name"],
        function()
            FocusFrame.name:Hide()
            nameWasHidden = true
        end,
        function()
            if not nameWasHidden then return end
            FocusFrame.name:Show()
            nameWasHidden = false
        end,
        "HideName"
    )
    
    lib:RegisterResizable(FocusFrame)
    
    if db.EMEOptions.focusFrameBuffs then
        local focusBuffsFrame = CreateFrame("Frame", "FocusFrameBuffs", FocusFrame)
        focusBuffsFrame:SetPoint("TOPLEFT", FocusFrame, "BOTTOMLEFT", 5, -10)
        focusBuffsFrame:SetSize(100, 10)
        addon:registerFrame(focusBuffsFrame, "Focus Buffs", db.FocusBuffs)
        lib:SetDontResize(focusBuffsFrame)
        
        hooksecurefunc("TargetFrame_UpdateDebuffAnchor", function(self, buff)
            if self ~= FocusFrame then return end
            
            local point, relativeTo, relativePoint, offsetX, offsetY = buff:GetPoint()
            
            if point and (self.TargetFrameContainer.FrameTexture == relativeTo) then
                buff:SetPoint(point, focusBuffsFrame, relativePoint, offsetX, offsetY)
            end
        end)
        
        hooksecurefunc("TargetFrame_UpdateBuffAnchor", function(self, buff)
            if self ~= FocusFrame then return end
            
            local point, relativeTo, relativePoint, offsetX, offsetY = buff:GetPoint()
            
            if point and (self.TargetFrameContainer.FrameTexture == relativeTo) then
                buff:SetPoint(point, focusBuffsFrame, relativePoint, offsetX, offsetY)
            end
        end)
    end
end
