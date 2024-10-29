local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initEssences()
    local db = addon.db.global
    if not db.EMEOptions.evokerEssences then return end
    lib:RegisterFrame(EssencePlayerFrame, POWER_TYPE_ESSENCE, db.EvokerEssences)
    lib:SetDontResize(EssencePlayerFrame)
    lib:RegisterHideable(EssencePlayerFrame)
    lib:RegisterToggleInCombat(EssencePlayerFrame)
    lib:RegisterResizable(EssencePlayerFrame)
    addon.registerAnchorToDropdown(EssencePlayerFrame)
    hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
        if not EditModeManagerFrame.editModeActive then
            addon.ResetFrame(EssencePlayerFrame)
        end
    end)
    EssencePlayerFrame:HookScript("OnShow", function()
        addon.ResetFrame(EssencePlayerFrame)
    end)
    addon.unlinkClassResourceFrame(EssencePlayerFrame)
end
