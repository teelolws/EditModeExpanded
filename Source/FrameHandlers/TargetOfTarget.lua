local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTargetOfTarget()
    local db = addon.db.global
    if db.EMEOptions.targetOfTarget then
        TargetFrameToT:SetUserPlaced(false)
        lib:RegisterFrame(TargetFrameToT, "Target of Target", db.ToT)
        lib:RegisterResizable(TargetFrameToT)
        TargetFrameToT:HookScript("OnHide", function()
            if (not InCombatLockdown()) and EditModeManagerFrame.editModeActive and lib:IsFrameEnabled(TargetFrameToT) then
                TargetFrameToT:Show()
            end
        end)
        addon:registerSecureFrameHideable(TargetFrameToT)
        addon.registerAnchorToDropdown(TargetFrameToT)
    end
end
