local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initDurationBars()
    local db = addon.db.global
    if not db.EMEOptions.durationBars then return end
        
    lib:RegisterResizable(MirrorTimerContainer)
end
