local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initStanceBar()
    local db = addon.db.global
    if db.EMEOptions.stanceBar then
        addon:registerSecureFrameHideable(StanceBar)
    end
end
