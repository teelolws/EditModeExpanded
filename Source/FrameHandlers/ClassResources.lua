local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

local function shouldShow(classResourceFrame)
    if EditModeManagerFrame.editModeActive then
        return false
    elseif classResourceFrame.spec then
        -- shouldShow test adapted from Blizzard_UnitFrame/ClassPowerBar.lua
        local spec = C_SpecializationInfo.GetSpecialization()
        if spec == classResourceFrame.spec then
            return true
        end
        return false
    elseif classResourceFrame.ShouldShowBar then
        -- Druid combo points have a different test
        return classResourceFrame.ShouldShowBar
    end
    return true
end

local function initClassResource(classResourceFrame, localText, db)
    addon:registerFrame(classResourceFrame, localText, db)
    lib:RegisterHideable(classResourceFrame)
    lib:RegisterToggleInCombat(classResourceFrame)
    lib:SetDontResize(classResourceFrame)
    lib:RegisterResizable(classResourceFrame)
    addon.registerAnchorToDropdown(classResourceFrame)
    hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
        if not shouldShow(classResourceFrame) then return end
        addon.ResetFrame(classResourceFrame)
    end)
    if classResourceFrame.HandleBarSetup then
        hooksecurefunc(classResourceFrame, "HandleBarSetup", function()
            if not shouldShow(classResourceFrame) then return end
            addon.ResetFrame(classResourceFrame)
        end)
    end
    classResourceFrame:HookScript("OnShow", function()
        if not shouldShow(classResourceFrame) then return end
        addon.ResetFrame(classResourceFrame)
    end)
    addon.unlinkClassResourceFrame(classResourceFrame)
end

function addon:initArcaneCharges()
    local db = addon.db.global
    if not db.EMEOptions.arcaneCharges then return end
    initClassResource(MageArcaneChargesFrame, POWER_TYPE_ARCANE_CHARGES, db.ArcaneCharges)
end

function addon:initChiBar()
    local db = addon.db.global
    if not db.EMEOptions.chi then return end
    initClassResource(MonkHarmonyBarFrame, CHI_POWER, db.Chi)
end

function addon:initRogueComboPoints()
    local db = addon.db.global
    if not db.EMEOptions.comboPoints then return end
    initClassResource(RogueComboPointBarFrame, COMBO_POINTS_POWER, db.ComboPoints)
end

function addon:initDruidComboPoints()
    local db = addon.db.global
    if not db.EMEOptions.comboPoints then return end
    initClassResource(DruidComboPointBarFrame, COMBO_POINTS_POWER, db.ComboPoints)
end

function addon:initEssences()
    local db = addon.db.global
    if not db.EMEOptions.evokerEssences then return end
    initClassResource(EssencePlayerFrame, POWER_TYPE_ESSENCE, db.EvokerEssences)

    -- check Blizzard_UnitFrame\EssenceFramePlayer.xml for spacing defaults to -1
    local currentSpacing = -1
    lib:RegisterSlider(EssencePlayerFrame, "Spacing", "Spacing", function(value)
            if value == currentSpacing then return end
            EssencePlayerFrame.spacing = value
            EssencePlayerFrame:Layout()
        end, -10, 20, 1)
end

function addon:initHolyPower()
    local db = addon.db.global
    if not db.EMEOptions.holyPower then return end
    initClassResource(PaladinPowerBarFrame, HOLY_POWER, db.HolyPower)
end

function addon:initRunes()
    local db = addon.db.global
    if not db.EMEOptions.runes then return end
    initClassResource(RuneFrame, RUNES, db.Runes)
end

function addon:initSoulShards()
    local db = addon.db.global
    if not db.EMEOptions.soulShards then return end
    initClassResource(WarlockPowerFrame, SOUL_SHARDS_POWER, db.SoulShards)
end
