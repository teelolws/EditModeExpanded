local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initSoulShards()
    local db = addon.db.global
    if not db.EMEOptions.soulShards then return end
    lib:RegisterFrame(WarlockPowerFrame, SOUL_SHARDS_POWER, db.SoulShards)
    lib:RegisterHideable(WarlockPowerFrame)
    lib:RegisterToggleInCombat(WarlockPowerFrame)
    lib:SetDontResize(WarlockPowerFrame)
    lib:RegisterResizable(WarlockPowerFrame)
    addon.registerAnchorToDropdown(WarlockPowerFrame)
    hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
        if not EditModeManagerFrame.editModeActive then
            addon.ResetFrame(WarlockPowerFrame)
        end
    end)
    hooksecurefunc(WarlockPowerFrame, "Show", function()
        addon.ResetFrame(WarlockPowerFrame)
    end)
    addon.unlinkClassResourceFrame(WarlockPowerFrame)
end
