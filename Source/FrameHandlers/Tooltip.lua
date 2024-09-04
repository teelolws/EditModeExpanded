local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTooltip()
    local db = addon.db.global
    if db.EMEOptions.gameTooltip then
        GameTooltipDefaultContainer:SetClampedToScreen(false)
        local isHidden = addon:registerSecureFrameHideable(GameTooltipDefaultContainer)
        hooksecurefunc(GameTooltip, "SetPoint", function(self, point, relativeTo, relativePoint)
            if isHidden() then
                GameTooltip:SetClampedToScreen(false)
                GameTooltip:ClearAllPoints()
            end
        end)
    end
end
