local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function addon:initTargetCastBar()
    local db = addon.db.global
    if db.EMEOptions.targetCast then
        lib:RegisterFrame(TargetFrameSpellBar, L["TARGET_CAST_BAR"], db.TargetSpellBar, TargetFrame, "TOPLEFT")
        hooksecurefunc(TargetFrameSpellBar, "AdjustPosition", function(self)
            addon.ResetFrame(TargetFrameSpellBar)
            if EditModeManagerFrame.editModeActive then
                TargetFrameSpellBar:Show()
            end
        end)
        TargetFrameSpellBar:HookScript("OnShow", function(self)
            addon.ResetFrame(TargetFrameSpellBar)
        end)
        lib:SetDontResize(TargetFrameSpellBar)
        lib:RegisterResizable(TargetFrameSpellBar, 10, 500)
        lib:RegisterHideable(TargetFrameSpellBar)
        addon.registerAnchorToDropdown(TargetFrameSpellBar)
        
        lib:RegisterSlider(TargetFrameSpellBar, "Width", "Width",
            function(newValue)
                TargetFrameSpellBar:SetWidth(newValue)
            end,
            10, 300, 1)
        lib:RegisterSlider(TargetFrameSpellBar, "Height", "Height",
            function(newValue)
                TargetFrameSpellBar:SetHeight(newValue)
            end,
            1, 50, 1)
    end
end
