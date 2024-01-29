local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initSoulShards()
    local db = addon.db.global
    if db.EMEOptions.soulShards then
        lib:RegisterFrame(WarlockPowerFrame, "Soul Shards", db.SoulShards)
        lib:RegisterHideable(WarlockPowerFrame)
        lib:RegisterToggleInCombat(WarlockPowerFrame)
        lib:SetDontResize(WarlockPowerFrame)
        lib:RegisterResizable(WarlockPowerFrame)
        addon.registerAnchorToDropdown(WarlockPowerFrame)
        hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
            if not EditModeManagerFrame.editModeActive then
                lib:RepositionFrame(WarlockPowerFrame)
            end
        end)
        local noInfinite
        hooksecurefunc(WarlockPowerFrame, "Show", function()
            if noInfinite then return end
            noInfinite = true
            lib:RepositionFrame(WarlockPowerFrame)
            noInfinite = false
        end)
    end
end
