local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTotemFrame()
    local db = addon.db.global
    if not db.EMEOptions.totem then return end
    
    TotemFrame:SetParent(UIParent)
    addon:registerFrame(TotemFrame, TUTORIAL_TITLE47, db.TotemFrame)
    lib:RegisterHideable(TotemFrame)
    lib:RegisterToggleInCombat(TotemFrame)
    lib:RegisterResizable(TotemFrame)
    
    EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_TOTEM_UPDATE", function()
        addon.ResetFrame(TotemFrame)
    end)
    
    -- TotemFrame now uses ResizeLayoutFrame, and becomes a 15x0 when no totems are active
    hooksecurefunc(TotemFrame, "Update", function()
        if InCombatLockdown() then return end
        if not EditModeManagerFrame.editModeActive then return end
        if not lib:IsFrameEnabled(TotemFrame) then return end
        
        TotemFrame:Show()
        local x, y = TotemFrame:GetSize()
        if (x < 5) or (y < 5) then
            TotemFrame:SetSize(52, 35)
        end
    end)
end
