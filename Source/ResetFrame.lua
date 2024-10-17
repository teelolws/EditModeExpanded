local addonName, addon = ...

-- A simple wrapper for lib:RepositionFrame with additional protection against infinite loops

local lib = LibStub:GetLibrary("EditModeExpanded-1.0") 

local currentlyProcessing

function addon.ResetFrame(frame)
    if currentlyProcessing then return end
    currentlyProcessing = true
    lib:RepositionFrame(frame)
    currentlyProcessing = false
end