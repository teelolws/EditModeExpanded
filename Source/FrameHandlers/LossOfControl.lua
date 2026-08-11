local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initLossOfControl()
    local db = addon.db.global
    if not db.EMEOptions.lossOfControl then return end
    lib:RegisterCustomCheckbox(LossOfControlFrame, L["HIDE_GLOW_EFFECT"],
        function()
            LossOfControlFrame.RedLineBottom:Hide()
            LossOfControlFrame.RedLineTop:Hide()
            LossOfControlFrame.blackBg:Hide()
        end,
        function()
            LossOfControlFrame.RedLineBottom:Show()
            LossOfControlFrame.RedLineTop:Show()
            LossOfControlFrame.blackBg:Show()
        end,
        "HideIcons"
    )
end
