local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initLossOfControl()
    local db = addon.db.global
    if not db.EMEOptions.lossOfControl then return end
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
    
    lib:RegisterCustomCheckbox(LossOfControlFrame, "Hide Glow Effect",
        function()
            LossOfControlFrame.RedLineBottom:Hide()
            LossOfControlFrame.RedLineTop:Hide()
            LossOfControlFrame.blackBg:Hide()
        end,
        function()
            LossOfControlFrame.RedLineBottom:Show()
            LossOfControlFrame.RedLineTop:Show()
            LossOfControlFrame.blackBg:Show()
        end,
        "HideIcons"
    )
end
