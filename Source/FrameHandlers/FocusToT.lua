local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initFocusToT()
    local db = addon.db.global
    if db.EMEOptions.focusTargetOfTarget then
        FocusFrameToT:SetUserPlaced(false) -- bug with frame being saved in layout cache leading to errors in TargetFrame.lua
        lib:RegisterFrame(FocusFrameToT, L["Focus ToT"], db.FocusToT)
        lib:RegisterResizable(FocusFrameToT)
        FocusFrameToT:HookScript("OnHide", function()
            if (not InCombatLockdown()) and EditModeManagerFrame.editModeActive and lib:IsFrameEnabled(FocusFrameToT) then
                FocusFrameToT:Show()
            end
        end)
        hooksecurefunc(FocusFrameToT, "SetPoint", function()
            if FocusFrameToT:IsUserPlaced() then
                FocusFrameToT:SetUserPlaced(false)
            end
        end)
        addon:registerSecureFrameHideable(FocusFrameToT)
        addon.registerAnchorToDropdown(FocusFrameToT)
    end
end

        
