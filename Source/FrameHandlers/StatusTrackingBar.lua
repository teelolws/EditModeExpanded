local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initStatusTrackingBar()
    local db = addon.db.global
    if db.EMEOptions.mainStatusTrackingBarContainer then
        lib:RegisterResizable(MainStatusTrackingBarContainer)
        lib:RegisterHideable(MainStatusTrackingBarContainer)
        lib:RegisterToggleInCombat(MainStatusTrackingBarContainer)
        C_Timer.After(1, function() lib:UpdateFrameResize(MainStatusTrackingBarContainer) end)
        hooksecurefunc(MainStatusTrackingBarContainer, "SetScale", function(frame, scale)
            for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                local _, anchor = bar:GetPoint(1)
                if anchor == MainStatusTrackingBarContainer then
                    bar:SetScale(scale) 
                end
            end
        end)
        hooksecurefunc(MainStatusTrackingBarContainer, "SetScaleOverride", function(frame, scale)
            for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                local _, anchor = bar:GetPoint(1)
                if anchor == MainStatusTrackingBarContainer then
                    bar:SetScale(scale) 
                end
            end
        end)
        
        hooksecurefunc(StatusTrackingBarManager, "UpdateBarsShown", function()
            for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                local _, anchor = bar:GetPoint(1)
                if anchor == MainStatusTrackingBarContainer then
                    bar:SetScale(MainStatusTrackingBarContainer:GetScale()) 
                end
            end
        end)
    end
    
    if db.EMEOptions.secondaryStatusTrackingBarContainer then
        lib:RegisterResizable(SecondaryStatusTrackingBarContainer)
        lib:RegisterHideable(SecondaryStatusTrackingBarContainer)
        lib:RegisterToggleInCombat(SecondaryStatusTrackingBarContainer)
        C_Timer.After(1, function() lib:UpdateFrameResize(SecondaryStatusTrackingBarContainer) end)
        hooksecurefunc(SecondaryStatusTrackingBarContainer, "SetScale", function(frame, scale)
            for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                local _, anchor = bar:GetPoint(1)
                if anchor == SecondaryStatusTrackingBarContainer then
                    bar:SetScale(scale) 
                end
            end
        end)
        hooksecurefunc(SecondaryStatusTrackingBarContainer, "SetScaleOverride", function(frame, scale)
            for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                local _, anchor = bar:GetPoint(1)
                if anchor == SecondaryStatusTrackingBarContainer then
                    bar:SetScale(scale) 
                end
            end
        end)
        
        hooksecurefunc(StatusTrackingBarManager, "UpdateBarsShown", function()
            for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                local _, anchor = bar:GetPoint(1)
                if anchor == SecondaryStatusTrackingBarContainer then
                    bar:SetScale(SecondaryStatusTrackingBarContainer:GetScale()) 
                end
            end
        end)
    end
end
