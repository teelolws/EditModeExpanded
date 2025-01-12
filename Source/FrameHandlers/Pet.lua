local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initPet()
    local db = addon.db.global
    if db.EMEOptions.pet then
        addon:registerSecureFrameHideable(PetFrame)
    end
end
