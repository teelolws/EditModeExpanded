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
    
    if db.EMEOptions.focusCast then
        local fakeFrame = CreateFrame("Frame", "EMEFocusFrameCastbar", FocusFrame)
        fakeFrame:SetPoint("TOPLEFT", FocusFrame, "BOTTOMLEFT", 5, -40)
        fakeFrame:SetSize(150, 30)
        lib:SetDontResize(fakeFrame)
        addon:registerFrame(fakeFrame, L["Focus Cast Bar"], db.FocusSpellBar, FocusFrame, "TOPLEFT")
        
        local realFrame = FocusFrameSpellBar
        
        addon:registerSecureFrameHideable(fakeFrame)
        lib:RegisterResizable(fakeFrame)
        
        hooksecurefunc(realFrame, "AdjustPosition", function(self)
            realFrame:ClearAllPoints()
            realFrame:SetPoint("TOPLEFT", fakeFrame, "TOPLEFT")
            if EditModeManagerFrame.editModeActive then
                realFrame:Show()
            end
        end)
        realFrame:HookScript("OnShow", function(self)
            realFrame:ClearAllPoints()
            realFrame:SetPoint("TOPLEFT", fakeFrame, "TOPLEFT")
        end)
    end
    
    if db.EMEOptions.focusFrameBuffs then
        local fakeFrame = CreateFrame("Frame", "EMEFocusFrameBuffs", FocusFrame)
        fakeFrame:SetPoint("TOPLEFT", FocusFrame, "BOTTOMLEFT", 5, -10)
        fakeFrame:SetSize(100, 70)
        addon:registerFrame(fakeFrame, "Focus Buffs", db.FocusBuffs, FocusFrame, "TOPLEFT")
        
        local realFrame = FocusFrame:GetAuraContainer()
        realFrame:ClearAllPoints()
        realFrame:SetPoint("TOPLEFT", fakeFrame, "TOPLEFT")
        
        hooksecurefunc(FocusFrame, "AnchorAuraContainer", function()
            realFrame:ClearAllPoints()
            realFrame:SetPoint("TOPLEFT", fakeFrame, "TOPLEFT")
        end)
        
        addon:registerSecureFrameHideable(fakeFrame)
    end
end
