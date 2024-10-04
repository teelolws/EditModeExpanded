local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initRogueComboPoints()
    local db = addon.db.global
    if db.EMEOptions.comboPoints then
        lib:RegisterFrame(RogueComboPointBarFrame, COMBO_POINTS_POWER, db.ComboPoints)
        lib:SetDontResize(RogueComboPointBarFrame)
        lib:RegisterHideable(RogueComboPointBarFrame)
        lib:RegisterToggleInCombat(RogueComboPointBarFrame)
        lib:RegisterResizable(RogueComboPointBarFrame)
        addon.registerAnchorToDropdown(RogueComboPointBarFrame)
        hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
            if not EditModeManagerFrame.editModeActive then
                lib:RepositionFrame(RogueComboPointBarFrame)
            end
        end)
        local noInfinite
        hooksecurefunc(RogueComboPointBarFrame, "Show", function()
            if noInfinite then return end
            noInfinite = true
            lib:RepositionFrame(RogueComboPointBarFrame)
            noInfinite = false
        end)
    end
end

function addon:initDruidComboPoints()
    local db = addon.db.global
    if db.EMEOptions.comboPoints then
        lib:RegisterFrame(DruidComboPointBarFrame, COMBO_POINTS_POWER, db.ComboPoints)
        lib:SetDontResize(DruidComboPointBarFrame)
        lib:RegisterHideable(DruidComboPointBarFrame)
        lib:RegisterToggleInCombat(DruidComboPointBarFrame)
        lib:RegisterResizable(DruidComboPointBarFrame)
        addon.registerAnchorToDropdown(DruidComboPointBarFrame)
        hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
            if not DruidComboPointBarFrame:ShouldShowBar() then return end
            if not EditModeManagerFrame.editModeActive then
                lib:RepositionFrame(DruidComboPointBarFrame)
            end
        end)
        local noInfinite
        hooksecurefunc(DruidComboPointBarFrame, "Show", function()
            if noInfinite then return end
            if not DruidComboPointBarFrame:ShouldShowBar() then return end
            noInfinite = true
            lib:RepositionFrame(DruidComboPointBarFrame)
            noInfinite = false
        end)
    end
end
