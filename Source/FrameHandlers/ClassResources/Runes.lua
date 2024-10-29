local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initRunes()
    local db = addon.db.global
    if not db.EMEOptions.runes then return end
    lib:RegisterFrame(RuneFrame, RUNES, db.Runes)
    lib:RegisterHideable(RuneFrame)
    lib:RegisterToggleInCombat(RuneFrame)
    lib:SetDontResize(RuneFrame)
    lib:RegisterResizable(RuneFrame)
    addon.registerAnchorToDropdown(RuneFrame)
    hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
        if not EditModeManagerFrame.editModeActive then
            addon.ResetFrame(RuneFrame)
        end
    end)
    RuneFrame:HookScript("OnShow", function()
        addon.ResetFrame(RuneFrame)
    end)
    addon.unlinkClassResourceFrame(RuneFrame)
end
