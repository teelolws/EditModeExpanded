local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initLFG()
    local db = addon.db.global
    if db.EMEOptions.lfg then
        QueueStatusButton:SetParent(UIParent)
        lib:RegisterFrame(QueueStatusButton, L["LFG"], db.QueueStatusButton)
        hooksecurefunc(MicroMenu, "UpdateQueueStatusAnchors", function()
            if InCombatLockdown() then return end
            addon.ResetFrame(QueueStatusButton)
        end)
        hooksecurefunc(MicroMenuContainer, "Layout", function()
            if InCombatLockdown() then return end
            MicroMenuContainer:SetWidth(MicroMenu:GetWidth()*MicroMenu:GetScale())
        end)
        MicroMenuContainer:SetWidth(MicroMenu:GetWidth()*MicroMenu:GetScale())
        
        -- the wasVisible saved in the library when entering Edit Mode cannot be relied upon, as entering Edit Mode shows the queue status button even if its hidden
        hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
            if InCombatLockdown() then return end
            QueueStatusFrame:Update()
        end)
        
        addon:registerSecureFrameHideable(QueueStatusButton)
        
        C_Timer.After(1, function()
            addon.ResetFrame(QueueStatusButton)
        end)
    end
end
