local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initFocusCastBar()
    local db = addon.db.global
    if db.EMEOptions.focusCast then
        lib:RegisterFrame(FocusFrameSpellBar, "Focus Cast Bar", db.FocusSpellBar, FocusFrame, "TOPLEFT")
        lib:SetDontResize(FocusFrameSpellBar)
        hooksecurefunc(FocusFrameSpellBar, "AdjustPosition", function(self)
            if EditModeManagerFrame.editModeActive then
                FocusFrameSpellBar:Show()
            end
            lib:RepositionFrame(FocusFrameSpellBar)
        end)
        FocusFrameSpellBar:HookScript("OnShow", function(self)
            lib:RepositionFrame(FocusFrameSpellBar)
        end)
        lib:SetDontResize(FocusFrameSpellBar)
        lib:RegisterResizable(FocusFrameSpellBar)
        lib:RegisterHideable(FocusFrameSpellBar)
        addon.registerAnchorToDropdown(FocusFrameSpellBar)
    end
end
