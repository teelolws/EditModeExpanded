local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTotemFrame()
    local db = addon.db.global
    if not db.EMEOptions.totem then return end
    
    TotemFrame:SetParent(UIParent)
    lib:RegisterFrame(TotemFrame, TUTORIAL_TITLE47, db.TotemFrame)
    lib:SetDefaultSize(TotemFrame, 100, 40)
    lib:RegisterHideable(TotemFrame)
    lib:RegisterToggleInCombat(TotemFrame)
    lib:RegisterResizable(TotemFrame)
    
    EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_TOTEM_UPDATE", function()
        addon.ResetFrame(TotemFrame)
    end)
end
