local addonName, addon = ...

function addon:initPet()
    local db = addon.db.global
    if db.EMEOptions.pet then
        addon:registerSecureFrameHideable(PetFrame)
    end
end
