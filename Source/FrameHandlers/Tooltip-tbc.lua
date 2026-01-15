local addonName, addon = ...

function addon:initTooltip()
    local db = addon.db.global
    if db.EMEOptions.gameTooltip then
        local isHidden = addon:registerSecureFrameHideable(GameTooltip, true, function()
                local _, relativeTo = GameTooltip:GetPoint(1)
                if relativeTo == UIParent then
                    GameTooltip:SetClampedToScreen(false)
                end
            end,
            function()
                GameTooltip:SetClampedToScreen(true)
            end)
        
        hooksecurefunc(GameTooltip, "SetPoint", function(self)
            local _, relativeTo = GameTooltip:GetPoint(1)
            if isHidden() and (relativeTo == UIParent) then
                self:SetClampedToScreen(false)
                self:ClearAllPoints()
            end
        end)
        
        hooksecurefunc(GameTooltip, "SetOwner", function(self, anchorTo)
            if isHidden() then
                if anchorTo ~= UIParent then
                    self:SetClampedToScreen(true)
                end
            end
        end)
    end
end
