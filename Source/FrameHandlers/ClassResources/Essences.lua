local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initEssences()
    local db = addon.db.global
    if db.EMEOptions.evokerEssences then
        lib:RegisterFrame(EssencePlayerFrame, POWER_TYPE_ESSENCE, db.EvokerEssences)
        lib:SetDontResize(EssencePlayerFrame)
        lib:RegisterHideable(EssencePlayerFrame)
        lib:RegisterToggleInCombat(EssencePlayerFrame)
        lib:RegisterResizable(EssencePlayerFrame)
        addon.registerAnchorToDropdown(EssencePlayerFrame)
        hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
            if not EditModeManagerFrame.editModeActive then
                lib:RepositionFrame(EssencePlayerFrame)
            end
        end)
        local noInfinite
        hooksecurefunc(EssencePlayerFrame, "Show", function()
            if noInfinite then return end
            noInfinite = true
            lib:RepositionFrame(EssencePlayerFrame)
            noInfinite = false
        end)
    end
end
