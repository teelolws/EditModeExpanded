local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initMinimap()
    local db = addon.db.global
    if db.EMEOptions.minimap then
        local isDefault = true
        lib:RegisterCustomCheckbox(MinimapCluster, RAID_TARGET_6,
            function()
                isDefault = false
                Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
                MinimapBackdrop:Hide()
            end,
            
            function()
                -- don't change it to circle if it is already a circle from the last login
                if isDefault then return end
                Minimap:SetMaskTexture("Interface\\Masks\\CircleMask")
                MinimapBackdrop:Show()
            end
        )
        
        if ExpansionLandingPageMinimapButton then
            ExpansionLandingPageMinimapButton:SetParent(UIParent)
            ExpansionLandingPageMinimapButton:SetFrameStrata("MEDIUM")
            lib:RegisterFrame(ExpansionLandingPageMinimapButton, L["Expansion Button"], db.ExpansionLandingPageMinimapButton)
            lib:RegisterResizable(ExpansionLandingPageMinimapButton)
            hooksecurefunc(ExpansionLandingPageMinimapButton, "UpdateIcon", function()
                addon.ResetFrame(ExpansionLandingPageMinimapButton)
            end)
            Minimap:HookScript("OnHide", function()
                ExpansionLandingPageMinimapButton:Hide()
            end)
            Minimap:HookScript("OnShow", function()
                ExpansionLandingPageMinimapButton:Show()
            end)
            addon:registerSecureFrameHideable(ExpansionLandingPageMinimapButton)
        end
        
        -- slightly simplified version of the code from addon:registerSecureFrameHideable
        local hidden, toggleInCombat
    
        local function hide()
            if(Minimap:IsShown()) then
                Minimap:Hide();
	        end
        end
    
        local function show()
            if not Minimap:IsShown() then
                Minimap:Show()
            end
            UpdateUIPanelPositions(MinimapCluster)
            UpdateUIPanelPositions(Minimap)
        end
    
        EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_REGEN_ENABLED", function()
            if not toggleInCombat then return end
            if hidden then
                hide()
            else
                show()
            end
        end)
        
        EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_REGEN_DISABLED", function()
            if not toggleInCombat then return end
            if hidden then
                show()
            else
                hide()
            end
        end)
    
        lib:RegisterCustomCheckbox(MinimapCluster, HIDE,
            function()
                hidden = true
                if not EditModeManagerFrame.editModeActive then
                    hide()
                end
            end,
            function()
                hidden = false
                show()
            end,
            "HidePermanently")
        
        lib:RegisterCustomCheckbox(MinimapCluster, L["Toggle In Combat"],
            function()
                toggleInCombat = true
            end,
            function()
                toggleInCombat = false
            end,
            "ToggleInCombat")
        
        hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function()
            show()
        end)
        
        hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
            if hidden then
                hide()
            end
        end)
    
        hooksecurefunc(MinimapCluster, "Show", function()
            if InCombatLockdown() then return end
            if hidden then hide() end
        end)
        
        hooksecurefunc(MinimapCluster, "SetShown", function()
            if InCombatLockdown() then return end
            if hidden then hide() end
        end)
    end
    
    if db.EMEOptions.minimapHeader then
        MinimapCluster.BorderTop:SetParent(UIParent)
        lib:RegisterFrame(MinimapCluster.BorderTop, L["Zone Name"], db.MinimapZoneName)
        lib:SetDontResize(MinimapCluster.BorderTop)
        addon:registerSecureFrameHideable(MinimapCluster.BorderTop)
        
        local function update()
            MinimapCluster:SetWidth(MinimapCluster.MinimapContainer:GetWidth()*MinimapCluster.MinimapContainer:GetScale())
            MinimapCluster:SetHeight(MinimapCluster.MinimapContainer:GetHeight()*MinimapCluster.MinimapContainer:GetScale())
        end
        MinimapCluster:HookScript("OnShow", update)
        hooksecurefunc(MinimapCluster.MinimapContainer, "SetScale", function() C_Timer.After(0.01, update) end)
        update()
        MinimapCluster:SetClampedToScreen(false)
    end
    
    if db.EMEOptions.minimapResize then
        lib:RegisterResizable(MinimapCluster)
    end
end
