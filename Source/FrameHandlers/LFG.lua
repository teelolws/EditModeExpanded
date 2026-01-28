local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function addon:initLFG()
    local db = addon.db.global
    if db.EMEOptions.lfg then
        addon:registerFrame(QueueStatusButton, L["LFG"], db.QueueStatusButton)
        hooksecurefunc(MicroMenu, "UpdateQueueStatusAnchors", function()
            if InCombatLockdown() then return end
            addon.ResetFrame(QueueStatusButton)
        end)
        hooksecurefunc(MicroMenuContainer, "Layout", function()
            if InCombatLockdown() then return end
            MicroMenuContainer:SetWidth(MicroMenu:GetWidth()*MicroMenu:GetScale())
            MicroMenuContainer:SetHeight(MicroMenu:GetHeight()*MicroMenu:GetScale())
        end)
        MicroMenuContainer:SetWidth(MicroMenu:GetWidth()*MicroMenu:GetScale())
        
        -- the wasVisible saved in the library when entering Edit Mode cannot be relied upon, as entering Edit Mode shows the queue status button even if its hidden
        hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
            if InCombatLockdown() then return end
            -- explanation: QueueStatusButton doesn't have an :Update function, but its subframe does
            QueueStatusFrame:Update()
        end)
        
        addon:registerSecureFrameHideable(QueueStatusButton)
        
        C_Timer.After(1, function()
            addon.ResetFrame(QueueStatusButton)
        end)
        
        local isDisconnected
        lib:RegisterCustomCheckbox(QueueStatusButton, "Disconnect from Menu Bar",
            function()
                QueueStatusButton:SetParent(UIParent)
                isDisconnected = true
            end,
            function()
                if not isDisconnected then return end
                isDisconnected = false
                QueueStatusButton:SetParent(MicroMenuContainer)
            end,
            "DisconnectFromMenuBar"
        )
    end
end
