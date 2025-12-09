local addonName, addon = ...

function addon:initStanceBar()
    local db = addon.db.global
    if db.EMEOptions.stanceBar then
        addon:registerSecureFrameHideable(StanceBar)
    end
end
