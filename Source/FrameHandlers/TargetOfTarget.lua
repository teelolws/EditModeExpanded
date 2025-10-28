local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTargetOfTarget()
    local db = addon.db.global
    if db.EMEOptions.targetOfTarget then
        TargetFrameToT:SetUserPlaced(false)
        addon:registerFrame(TargetFrameToT, SHOW_TARGET_OF_TARGET_TEXT, db.ToT)
        lib:RegisterResizable(TargetFrameToT)
        TargetFrameToT:HookScript("OnHide", function()
            if (not InCombatLockdown()) and EditModeManagerFrame.editModeActive and lib:IsFrameEnabled(TargetFrameToT) then
                if C_CVar.GetCVar("showTargetOfTarget") == "1" then
                    TargetFrameToT:Show()
                end
            end
        end)
        addon:registerSecureFrameHideable(TargetFrameToT)
        addon.registerAnchorToDropdown(TargetFrameToT)
    end
end
