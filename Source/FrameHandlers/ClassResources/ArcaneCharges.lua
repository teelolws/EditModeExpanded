local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initArcaneCharges()
    local db = addon.db.global
    if db.EMEOptions.arcaneCharges then
        lib:RegisterFrame(MageArcaneChargesFrame, POWER_TYPE_ARCANE_CHARGES, db.ArcaneCharges)
        lib:RegisterHideable(MageArcaneChargesFrame)
        lib:RegisterToggleInCombat(MageArcaneChargesFrame)
        lib:SetDontResize(MageArcaneChargesFrame)
        lib:RegisterResizable(MageArcaneChargesFrame)
        addon.registerAnchorToDropdown(MageArcaneChargesFrame)
        hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
            if GetSpecialization() ~= 1 then return end
            if not EditModeManagerFrame.editModeActive then
                addon.ResetFrame(MageArcaneChargesFrame)
            end
        end)
        hooksecurefunc(MageArcaneChargesFrame, "HandleBarSetup", function()
            if GetSpecialization() ~= 1 then return end
            if not EditModeManagerFrame.editModeActive then
                addon.ResetFrame(MageArcaneChargesFrame)
            end
        end)
        MageArcaneChargesFrame:HookScript("OnShow", function()
            if GetSpecialization() ~= 1 then return end
            addon.ResetFrame(MageArcaneChargesFrame)
        end)
    end
end
