local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

-- A simple wrapper for lib:RegisterFrame to also call RegisterCoordinates if that option is enabled

function addon:registerFrame(frame, ...)
    lib:RegisterFrame(frame, ...)
    if addon.db.global.EMEOptions.allowSetCoordinates then
        lib:RegisterCoordinates(frame)
    end
end