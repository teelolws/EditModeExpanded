local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTargetCastBar()
    local db = addon.db.global
    if db.EMEOptions.targetCast then
        lib:RegisterFrame(TargetFrameSpellBar, "Target Cast Bar", db.TargetSpellBar, TargetFrame, "TOPLEFT")
        hooksecurefunc(TargetFrameSpellBar, "AdjustPosition", function(self)
            addon.ResetFrame(TargetFrameSpellBar)
            if EditModeManagerFrame.editModeActive then
                TargetFrameSpellBar:Show()
            end
        end)
        TargetFrameSpellBar:HookScript("OnShow", function(self)
            addon.ResetFrame(TargetFrameSpellBar)
        end)
        lib:SetDontResize(TargetFrameSpellBar)
        lib:RegisterResizable(TargetFrameSpellBar, 10, 500)
        lib:RegisterHideable(TargetFrameSpellBar)
        addon.registerAnchorToDropdown(TargetFrameSpellBar)            
    end
end
