local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initChiBar()
    local db = addon.db.global
    if db.EMEOptions.chi then
        lib:RegisterFrame(MonkHarmonyBarFrame, "Chi", db.Chi)
        lib:SetDontResize(MonkHarmonyBarFrame)
        lib:RegisterHideable(MonkHarmonyBarFrame)
        lib:RegisterToggleInCombat(MonkHarmonyBarFrame)
        lib:RegisterResizable(MonkHarmonyBarFrame)
        addon.registerAnchorToDropdown(MonkHarmonyBarFrame)
        hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
            if not EditModeManagerFrame.editModeActive then
                lib:RepositionFrame(MonkHarmonyBarFrame)
            end
        end)
        local noInfinite
        hooksecurefunc(MonkHarmonyBarFrame, "Show", function()
            if noInfinite then return end
            noInfinite = true
            lib:RepositionFrame(MonkHarmonyBarFrame)
            noInfinite = false
        end)
    end
end
