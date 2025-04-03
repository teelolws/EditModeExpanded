local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initExtraActionButton()
    local db = addon.db.global
    if not db.EMEOptions.extraActionButton then return end
    lib:RegisterResizable(ExtraAbilityContainer)
end

        
