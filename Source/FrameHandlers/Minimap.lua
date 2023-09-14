local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initMinimap()
    local db = addon.db.global
    if db.EMEOptions.minimap then
        local isDefault = true
        lib:RegisterCustomCheckbox(MinimapCluster, "Square",
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
            lib:RegisterFrame(ExpansionLandingPageMinimapButton, "Expansion Button", db.ExpansionLandingPageMinimapButton)
            lib:RegisterResizable(ExpansionLandingPageMinimapButton)
            hooksecurefunc(ExpansionLandingPageMinimapButton, "UpdateIcon", function()
                lib:RepositionFrame(ExpansionLandingPageMinimapButton)
            end)
            Minimap:HookScript("OnHide", function()
                ExpansionLandingPageMinimapButton:Hide()
            end)
            Minimap:HookScript("OnShow", function()
                ExpansionLandingPageMinimapButton:Show()
            end)
            addon:registerSecureFrameHideable(ExpansionLandingPageMinimapButton)
        end
        
        lib:RegisterHideable(MinimapCluster)
        lib:RegisterToggleInCombat(MinimapCluster)
    end
    
    if db.EMEOptions.minimapHeader then
        MinimapCluster.BorderTop:SetParent(UIParent)
        lib:RegisterFrame(MinimapCluster.BorderTop, "Zone Name", db.MinimapZoneName)
        lib:SetDontResize(MinimapCluster.BorderTop)
        addon:registerSecureFrameHideable(MinimapCluster.BorderTop)
    end
end
