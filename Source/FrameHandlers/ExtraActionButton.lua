local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initExtraActionButton()
    local db = addon.db.global
    if not db.EMEOptions.extraActionButton then return end
    lib:RegisterResizable(ExtraAbilityContainer)
end

        
