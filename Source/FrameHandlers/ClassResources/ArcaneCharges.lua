local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initArcaneCharges()
    local db = addon.db.global
    if db.EMEOptions.arcaneCharges then
        lib:RegisterFrame(MageArcaneChargesFrame, "Arcane Charges", db.ArcaneCharges)
        lib:RegisterHideable(MageArcaneChargesFrame)
        lib:RegisterToggleInCombat(MageArcaneChargesFrame)
        lib:SetDontResize(MageArcaneChargesFrame)
        lib:RegisterResizable(MageArcaneChargesFrame)
        addon.registerAnchorToDropdown(MageArcaneChargesFrame)
        hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
            if not EditModeManagerFrame.editModeActive then
                lib:RepositionFrame(MageArcaneChargesFrame)
            end
        end)
        hooksecurefunc(MageArcaneChargesFrame, "HandleBarSetup", function()
            if not EditModeManagerFrame.editModeActive then
                lib:RepositionFrame(MageArcaneChargesFrame)
            end
        end)
        local noInfinite
        hooksecurefunc(MageArcaneChargesFrame, "Show", function()
            if noInfinite then return end
            noInfinite = true
            lib:RepositionFrame(MageArcaneChargesFrame)
            noInfinite = false
        end)
    end
end
