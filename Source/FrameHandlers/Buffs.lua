local addonName, addon = ...

function addon:initBuffs()
    local db = addon.db.global
    if db.EMEOptions.buffFrame then
        addon:registerSecureFrameHideable(BuffFrame)
    end
    
    if db.EMEOptions.debuffFrame then
        addon:registerSecureFrameHideable(DebuffFrame)
    end
end
