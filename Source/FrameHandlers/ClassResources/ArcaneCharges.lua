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
                lib:RepositionFrame(MageArcaneChargesFrame)
            end
        end)
        hooksecurefunc(MageArcaneChargesFrame, "HandleBarSetup", function()
            if GetSpecialization() ~= 1 then return end
            if not EditModeManagerFrame.editModeActive then
                lib:RepositionFrame(MageArcaneChargesFrame)
            end
        end)
        local noInfinite
        hooksecurefunc(MageArcaneChargesFrame, "Show", function()
            if GetSpecialization() ~= 1 then return end
            if noInfinite then return end
            noInfinite = true
            lib:RepositionFrame(MageArcaneChargesFrame)
            noInfinite = false
        end)
    end
end
