local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

-- A simple wrapper for lib:RegisterFrame to also call RegisterCoordinates if that option is enabled

function addon:registerFrame(frame, ...)
    local system = frame.system
    lib:RegisterFrame(frame, ...)
    if addon.db.global.EMEOptions.allowSetCoordinates then
        lib:RegisterCoordinates(frame)
    end
    -- don't apply anchor to, to system frames
    if (not system) and addon.db.global.EMEOptions.anchorToEnabled then
        addon.registerAnchorToDropdown(frame)
    end
end