local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initBuffs()
    local db = addon.db.global
    if db.EMEOptions.buffFrame then
        addon:registerSecureFrameHideable(BuffFrame)
    end
    
    if db.EMEOptions.debuffFrame then
        addon:registerSecureFrameHideable(DebuffFrame)
    end
end
