local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initFocusCastBar()
    local db = addon.db.global
    if db.EMEOptions.focusCast then
        lib:RegisterFrame(FocusFrameSpellBar, L["Focus Cast Bar"], db.FocusSpellBar, FocusFrame, "TOPLEFT")
        lib:SetDontResize(FocusFrameSpellBar)
        hooksecurefunc(FocusFrameSpellBar, "AdjustPosition", function(self)
            if EditModeManagerFrame.editModeActive then
                FocusFrameSpellBar:Show()
            end
            addon.ResetFrame(FocusFrameSpellBar)
        end)
        FocusFrameSpellBar:HookScript("OnShow", function(self)
            addon.ResetFrame(FocusFrameSpellBar)
        end)
        lib:SetDontResize(FocusFrameSpellBar)
        lib:RegisterResizable(FocusFrameSpellBar)
        lib:RegisterHideable(FocusFrameSpellBar)
        addon.registerAnchorToDropdown(FocusFrameSpellBar)
    end
end
