local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTooltip()
    local db = addon.db.global
    if db.EMEOptions.gameTooltip then
        GameTooltipDefaultContainer:SetClampedToScreen(false)
        
        local isHidden = addon:registerSecureFrameHideable(GameTooltipDefaultContainer, true, function()
                local _, relativeTo = GameTooltip:GetPoint(1)
                if relativeTo == GameTooltipDefaultContainer then
                    GameTooltip:SetClampedToScreen(false)
                end
            end,
            function()
                local _, relativeTo = GameTooltip:GetPoint(1)
                if relativeTo == GameTooltipDefaultContainer then
                    GameTooltip:SetClampedToScreen(true)
                end
            end)
        
        hooksecurefunc(GameTooltip, "SetPoint", function(self, point, relativeTo, relativePoint)
            if isHidden() then
                self:SetClampedToScreen(false)
                self:ClearAllPoints()
            end
        end)
        
        hooksecurefunc(GameTooltip, "SetOwner", function(self, anchorTo, anchorPoint)
            if isHidden() then
                if anchorTo ~= UIParent then
                    self:SetClampedToScreen(true)
                end
            end
        end)
    end
end
