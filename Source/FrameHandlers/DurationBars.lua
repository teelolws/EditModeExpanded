local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initDurationBars()
    local db = addon.db.global
    if not db.EMEOptions.durationBars then return end
        
    lib:RegisterResizable(MirrorTimerContainer)
    
    -- Workaround for bug in base UI
    -- If player enters then leaves edit mode, the entire container will no longer show until the next reload
    MirrorTimerContainer:HookScript("OnEvent", function(self)
        self:SetShown(self:ShouldShow())
    end)
end
