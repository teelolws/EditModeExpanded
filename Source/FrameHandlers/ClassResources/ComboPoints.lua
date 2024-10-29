local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initRogueComboPoints()
    local db = addon.db.global
    if not db.EMEOptions.comboPoints then return end
    lib:RegisterFrame(RogueComboPointBarFrame, COMBO_POINTS_POWER, db.ComboPoints)
    lib:SetDontResize(RogueComboPointBarFrame)
    lib:RegisterHideable(RogueComboPointBarFrame)
    lib:RegisterToggleInCombat(RogueComboPointBarFrame)
    lib:RegisterResizable(RogueComboPointBarFrame)
    addon.registerAnchorToDropdown(RogueComboPointBarFrame)
    hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
        if not EditModeManagerFrame.editModeActive then
            addon.ResetFrame(RogueComboPointBarFrame)
        end
    end)
    hooksecurefunc(RogueComboPointBarFrame, "Show", function()
        addon.ResetFrame(RogueComboPointBarFrame)
    end)
    addon.unlinkClassResourceFrame(RogueComboPointBarFrame)
end

function addon:initDruidComboPoints()
    local db = addon.db.global
    if not db.EMEOptions.comboPoints then return end
    lib:RegisterFrame(DruidComboPointBarFrame, COMBO_POINTS_POWER, db.ComboPoints)
    lib:SetDontResize(DruidComboPointBarFrame)
    lib:RegisterHideable(DruidComboPointBarFrame)
    lib:RegisterToggleInCombat(DruidComboPointBarFrame)
    lib:RegisterResizable(DruidComboPointBarFrame)
    addon.registerAnchorToDropdown(DruidComboPointBarFrame)
    hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
        if not DruidComboPointBarFrame:ShouldShowBar() then return end
        if not EditModeManagerFrame.editModeActive then
            addon.ResetFrame(DruidComboPointBarFrame)
        end
    end)
    hooksecurefunc(DruidComboPointBarFrame, "Show", function()
        if not DruidComboPointBarFrame:ShouldShowBar() then return end
        addon.ResetFrame(DruidComboPointBarFrame)
    end)
    addon.unlinkClassResourceFrame(DruidComboPointBarFrame)
end
