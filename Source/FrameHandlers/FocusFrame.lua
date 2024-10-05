local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initFocusFrame()
    local db = addon.db.global
    if db.EMEOptions.focusFrame then
        addon:registerSecureFrameHideable(FocusFrame)
    end
    
    local nameWasHidden
    lib:RegisterCustomCheckbox(FocusFrame, L["Hide Name"],
        function()
            FocusFrame.name:Hide()
            nameWasHidden = true
        end,
        function()
            if not nameWasHidden then return end
            FocusFrame.name:Show()
            nameWasHidden = false
        end,
        "HideName"
    )
end
