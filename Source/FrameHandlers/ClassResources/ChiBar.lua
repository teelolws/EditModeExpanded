local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initChiBar()
    local db = addon.db.global
    if not db.EMEOptions.chi then return end
    addon:registerFrame(MonkHarmonyBarFrame, CHI_POWER, db.Chi)
    lib:SetDontResize(MonkHarmonyBarFrame)
    lib:RegisterHideable(MonkHarmonyBarFrame)
    lib:RegisterToggleInCombat(MonkHarmonyBarFrame)
    lib:RegisterResizable(MonkHarmonyBarFrame)
    addon.registerAnchorToDropdown(MonkHarmonyBarFrame)
    hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
        if not EditModeManagerFrame.editModeActive then
            addon.ResetFrame(MonkHarmonyBarFrame)
        end
    end)
    MonkHarmonyBarFrame:HookScript("OnShow", function()
        addon.ResetFrame(MonkHarmonyBarFrame)
    end)
    addon.unlinkClassResourceFrame(MonkHarmonyBarFrame)
end
