local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

-- MicroButtonAndBagsBar:GetTop gets checked by EditModeManager, setting the scale of the Right Action bars
-- to allow it to be moved, we need to duplicate the frame, hide the original, and make the duplicate the one being moved instead
local function duplicateMicroButtonAndBagsBar()
    MicroButtonAndBagsBar:Hide()
    local duplicate = CreateFrame("Frame", "MicroButtonAndBagsBarMovable", UIParent)
    duplicate:SetSize(232, 40)
    duplicate:SetPoint("BOTTOMRIGHT")
    duplicate.QuickKeybindsMicroBagBarGlow = duplicate:CreateTexture(nil, "BACKGROUND")
    duplicate.QuickKeybindsMicroBagBarGlow:SetAtlas("QuickKeybind_BagMicro_Glow", true)
    duplicate.QuickKeybindsMicroBagBarGlow:Hide()
    duplicate.QuickKeybindsMicroBagBarGlow:SetPoint("CENTER", duplicate, "CENTER", -30, 30)
    
    hooksecurefunc("MoveMicroButtons", function(anchor, anchorTo, relAnchor, x, y, isStacked)
        if anchorTo == MicroButtonAndBagsBar then
            anchorTo = duplicate
            CharacterMicroButton:ClearAllPoints();
            CharacterMicroButton:SetPoint(anchor, anchorTo, relAnchor, x, y);
        end
    end)
    
    hooksecurefunc(MicroButtonAndBagsBar.QuickKeybindsMicroBagBarGlow, "SetShown", function(self, showEffects)
        duplicate.QuickKeybindsMicroBagBarGlow:SetShown(showEffects)
    end)
    
    duplicate:Show()
    CharacterMicroButton:ClearAllPoints();
    CharacterMicroButton:SetPoint("BOTTOMLEFT", duplicate, "BOTTOMLEFT", 7, 6)
    CharacterMicroButton:SetParent(duplicate)
    SpellbookMicroButton:SetParent(duplicate)
    TalentMicroButton:SetParent(duplicate)
    AchievementMicroButton:SetParent(duplicate)
    QuestLogMicroButton:SetParent(duplicate)
    GuildMicroButton:SetParent(duplicate)
    LFDMicroButton:SetParent(duplicate)
    CollectionsMicroButton:SetParent(duplicate)
    EJMicroButton:SetParent(duplicate)
    StoreMicroButton:SetParent(duplicate)
    MainMenuMicroButton:SetParent(duplicate)
    HelpMicroButton:SetParent(duplicate)
    
    MainMenuBarBackpackButton:SetPoint("TOPRIGHT", duplicate, -4, 2)
    MainMenuBarBackpackButton:SetParent(duplicate)
    
    QueueStatusButton:SetParent(duplicate)
    
    -- Now split the Backpack section into its own bar
    local backpackBar = CreateFrame("Frame", "EditModeExpandedBackpackBar", UIParent)
    backpackBar:SetSize(232, 40)
    backpackBar:SetPoint("BOTTOMRIGHT", duplicate, "TOPRIGHT")
    MainMenuBarBackpackButton:ClearAllPoints()
    MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", backpackBar, "BOTTOMRIGHT")
    MainMenuBarBackpackButton:SetParent(backpackBar)
    BagBarExpandToggle:SetParent(backpackBar)
    CharacterBag0Slot:SetParent(backpackBar)
    CharacterBag1Slot:SetParent(backpackBar)
    CharacterBag2Slot:SetParent(backpackBar)
    CharacterBag3Slot:SetParent(backpackBar)
    CharacterReagentBag0Slot:SetParent(backpackBar)
end

local defaults = {
    profile = {
        MicroButtonAndBagsBar = {},
        BackpackBar = {},
        StatusTrackingBarManager = {},
        QueueStatusButton = {},
        TotemFrame = {},
        PetFrame = {},
        DurabilityFrame = {},
        VehicleSeatIndicator = {},
        HolyPower = {},
    }
}

local petFrameLoaded
local addonLoaded
local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(__, event, arg1)
    if (event == "ADDON_LOADED") and (arg1 == "EditModeExpanded") and (not addonLoaded) then
        addonLoaded = true
        f.db = LibStub("AceDB-3.0"):New("EditModeExpandedDB", defaults)
        
        local db = f.db.profile

        duplicateMicroButtonAndBagsBar()
        lib:RegisterFrame(MicroButtonAndBagsBarMovable, "Micro Menu", db.MicroButtonAndBagsBar)
        lib:RegisterFrame(EditModeExpandedBackpackBar, "Backpack", db.BackpackBar)
        
        lib:RegisterFrame(StatusTrackingBarManager, "Experience Bar", db.StatusTrackingBarManager)
        lib:RegisterFrame(QueueStatusButton, "LFG", db.QueueStatusButton)
        
        lib:RegisterFrame(TotemFrame, "Totem", db.TotemFrame)
        lib:SetDefaultSize(TotemFrame, 100, 40)

        DurabilityFrame:SetParent(UIParent)
        lib:RegisterFrame(DurabilityFrame, "Durability", db.DurabilityFrame)
        
        VehicleSeatIndicator:SetParent(UIParent)
        VehicleSeatIndicator:SetPoint("TOPLEFT", DurabilityFrame, "TOPLEFT")
        lib:RegisterFrame(VehicleSeatIndicator, "Vehicle Seats", db.VehicleSeatIndicator)
        
        if UnitClassBase("player") == "PALADIN" then
            lib:RegisterFrame(PaladinPowerBarFrame, "Holy Power", db.HolyPower)
        end
    elseif (event == "UNIT_PET") and (not petFrameLoaded) and (addonLoaded) then
        petFrameLoaded = true
        lib:RegisterFrame(PetFrame, "Pet", f.db.profile.PetFrame)
    end
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("UNIT_PET")