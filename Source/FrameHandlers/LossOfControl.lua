local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initLossOfControl()
    local db = addon.db.global
    if db.EMEOptions.lossOfControl then
        lib:RegisterFrame(LossOfControlFrame, LOSS_OF_CONTROL, db.LOC)
        lib:HideByDefault(LossOfControlFrame)
        hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function(self)
            if InCombatLockdown() then return end
            LossOfControlFrame:SetScript("OnUpdate", nop)
        end)
        hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function(self)
            if InCombatLockdown() then return end
            LossOfControlFrame:SetScript("OnUpdate", LossOfControlFrame_OnUpdate)
        end)
    end
end
