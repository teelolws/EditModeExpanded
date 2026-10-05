-- MultiCastActionBarFrame

local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTotemBar()
    local db = addon.db.global
    if not db.EMEOptions.totemBar then return end
    
    addon:registerFrame(MultiCastActionBarFrame, HUD_EDIT_MODE_TOTEM_ACTION_BAR_LABEL, db.MultiCastActionBarFrame)
    lib:RegisterHideable(MultiCastActionBarFrame, nil, MultiCastActionBarFrame_OnUpdate)
    lib:RegisterToggleInCombat(MultiCastActionBarFrame)
    lib:RegisterResizable(MultiCastActionBarFrame)
    lib:RegisterHiddenUntilMouseover(MultiCastActionBarFrame, L["HIDE_WHEN_NOT_MOUSEOVER_DESCRIPTION"])
end
