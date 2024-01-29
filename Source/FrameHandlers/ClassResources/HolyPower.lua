local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initHolyPower()
    local db = addon.db.global
    if db.EMEOptions.holyPower then
        lib:RegisterFrame(PaladinPowerBarFrame, "Holy Power", db.HolyPower)
        C_Timer.After(4, function() lib:RepositionFrame(PaladinPowerBarFrame) end)
        lib:RegisterHideable(PaladinPowerBarFrame)
        lib:RegisterToggleInCombat(PaladinPowerBarFrame)
        addon.registerAnchorToDropdown(PaladinPowerBarFrame)
        hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
            if not EditModeManagerFrame.editModeActive then
                lib:RepositionFrame(PaladinPowerBarFrame)
                if lib:IsFrameMarkedHidden(PaladinPowerBarFrame) then
                    PaladinPowerBarFrame:Hide()
                end
            end
        end)
        local noInfinite
        hooksecurefunc(PaladinPowerBarFrame, "Show", function()
            if noInfinite then return end
            noInfinite = true
            lib:RepositionFrame(PaladinPowerBarFrame)
            noInfinite = false
        end)
    end
end
