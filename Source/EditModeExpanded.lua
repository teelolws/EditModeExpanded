local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

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

        lib:RegisterFrame(MicroButtonAndBagsBar, "Micro Menu", db.MicroButtonAndBagsBar)
        lib:RegisterResizable(MicroButtonAndBagsBarMovable)
        lib:RegisterResizable(EditModeExpandedBackpackBar)
        
        lib:RegisterFrame(StatusTrackingBarManager, "Experience Bar", db.StatusTrackingBarManager)
        lib:RegisterResizable(StatusTrackingBarManager)
        
        QueueStatusButton:SetParent(UIParent)
        lib:RegisterFrame(QueueStatusButton, "LFG", db.QueueStatusButton)
        lib:RegisterResizable(QueueStatusButton)
        
        lib:RegisterFrame(TotemFrame, "Totem", db.TotemFrame)
        lib:SetDefaultSize(TotemFrame, 100, 40)

        DurabilityFrame:SetParent(UIParent)
        lib:RegisterFrame(DurabilityFrame, "Durability", db.DurabilityFrame)
        lib:RegisterResizable(DurabilityFrame)
        
        VehicleSeatIndicator:SetParent(UIParent)
        VehicleSeatIndicator:SetPoint("TOPLEFT", DurabilityFrame, "TOPLEFT")
        lib:RegisterFrame(VehicleSeatIndicator, "Vehicle Seats", db.VehicleSeatIndicator)
        lib:RegisterResizable(VehicleSeatIndicator)
        
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