local addonName, addon = ...

function addon:initFocusFrame()
    local db = addon.db.global
    if db.EMEOptions.focusFrame then
        addon:registerSecureFrameHideable(FocusFrame)
    end
end
