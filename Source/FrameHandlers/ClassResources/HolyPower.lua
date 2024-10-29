local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initHolyPower()
    local db = addon.db.global
    if not db.EMEOptions.holyPower then return end
    lib:RegisterFrame(PaladinPowerBarFrame, HOLY_POWER, db.HolyPower)
    C_Timer.After(4, function() addon.ResetFrame(PaladinPowerBarFrame) end)
    lib:RegisterHideable(PaladinPowerBarFrame)
    lib:RegisterToggleInCombat(PaladinPowerBarFrame)
    addon.registerAnchorToDropdown(PaladinPowerBarFrame)
    hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
        if not EditModeManagerFrame.editModeActive then
            addon.ResetFrame(PaladinPowerBarFrame)
            if lib:IsFrameMarkedHidden(PaladinPowerBarFrame) then
                PaladinPowerBarFrame:Hide()
            end
        end
    end)
    PaladinPowerBarFrame:HookScript("OnShow", function()
        addon.ResetFrame(PaladinPowerBarFrame)
    end)
    addon.unlinkClassResourceFrame(PaladinPowerBarFrame)
end
