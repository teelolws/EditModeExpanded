local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

-- MicroButtonAndBagsBar:GetTop gets checked by EditModeManager, setting the scale of the Right Action bars
-- to allow it to be moved, we need to duplicate the frame, hide the original, and make the duplicate the one being moved instead
local function duplicateMicroButtonAndBagsBar()
    MicroButtonAndBagsBar:Hide()
    local duplicate = CreateFrame("Frame", "MicroButtonAndBagsBarMovable", UIParent)
    duplicate:SetSize(232, 80)
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
    BagBarExpandToggle:SetParent(duplicate)
    CharacterBag0Slot:SetParent(duplicate)
    CharacterBag1Slot:SetParent(duplicate)
    CharacterBag2Slot:SetParent(duplicate)
    CharacterBag3Slot:SetParent(duplicate)
    CharacterReagentBag0Slot:SetParent(duplicate)
    
    QueueStatusButton:SetParent(duplicate)
    
    return duplicate
end

local petFrameLoaded
local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(__, event, arg1)
    if (event == "ADDON_LOADED" and arg1 == "EditModeExpanded") then
        if not EditModeExpandedDB then EditModeExpandedDB = {} end
        if not EditModeExpandedDB.MicroButtonAndBagsBar then EditModeExpandedDB.MicroButtonAndBagsBar = {} end
        if not EditModeExpandedDB.StatusTrackingBarManager then EditModeExpandedDB.StatusTrackingBarManager = {} end
        if not EditModeExpandedDB.QueueStatusButton then EditModeExpandedDB.QueueStatusButton = {} end
        if not EditModeExpandedDB.TotemFrame then EditModeExpandedDB.TotemFrame = {} end
        if not EditModeExpandedDB.PetFrame then EditModeExpandedDB.PetFrame = {} end
        if not EditModeExpandedDB.DurabilityFrame then EditModeExpandedDB.DurabilityFrame = {} end
        if not EditModeExpandedDB.VehicleSeatIndicator then EditModeExpandedDB.VehicleSeatIndicator = {} end

        duplicateMicroButtonAndBagsBar()
        lib:RegisterFrame(MicroButtonAndBagsBarMovable, "Micro Menu", EditModeExpandedDB.MicroButtonAndBagsBar)
        lib:RegisterFrame(StatusTrackingBarManager, "Experience Bar", EditModeExpandedDB.StatusTrackingBarManager)
        lib:RegisterFrame(QueueStatusButton, "LFG", EditModeExpandedDB.QueueStatusButton)
        
        lib:RegisterFrame(TotemFrame, "Totem", EditModeExpandedDB.TotemFrame)
        lib:SetDefaultSize(TotemFrame, 100, 40)

        DurabilityFrame:SetParent(UIParent)
        lib:RegisterFrame(DurabilityFrame, "Durability", EditModeExpandedDB.DurabilityFrame)
        
        VehicleSeatIndicator:SetParent(UIParent)
        VehicleSeatIndicator:SetPoint("TOPLEFT", DurabilityFrame, "TOPLEFT")
        lib:RegisterFrame(VehicleSeatIndicator, "Vehicle Seats", EditModeExpandedDB.VehicleSeatIndicator)
    elseif (event == "UNIT_PET") and (not petFrameLoaded) then
        petFrameLoaded = true
        lib:RegisterFrame(PetFrame, "Pet", EditModeExpandedDB.PetFrame)
    end
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("UNIT_PET")