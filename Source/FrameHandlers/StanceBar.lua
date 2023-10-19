local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initStanceBar()
    local db = addon.db.global
    if db.EMEOptions.stanceBar then
        lib:RegisterHideable(StanceBar)
        lib:RegisterToggleInCombat(StanceBar)
        hooksecurefunc(StanceBar, "Show", function()
            if InCombatLockdown() then return end
            if lib:IsFrameMarkedHidden(StanceBar) then
                StanceBar:Hide()
            end
        end)
        hooksecurefunc(StanceBar, "SetShown", function()
            if InCombatLockdown() then return end
            if lib:IsFrameMarkedHidden(StanceBar) then
                StanceBar:Hide()
            end
        end)
        
        C_Timer.After(1, function()
            if InCombatLockdown() then return end
            if lib:IsFrameMarkedHidden(StanceBar) then
                StanceBar:Hide()
            end
        end)
    end
end
