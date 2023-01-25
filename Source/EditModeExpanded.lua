local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local defaults = {
    global = {
        EMEOptions = {
            lfg = true,
            vehicle = true,
            holyPower = true,
            totem = true,
            soulShards = true,
            pet = true,
            achievementAlert = true,
            targetOfTarget = true,
            targetCast = true,
            focusCast = true,
            compactRaidFrameContainer = true,
            talkingHead = true,
            minimap = true,
            uiWidgetTopCenterContainerFrame = false,
            stanceBar = true,
            runes = true,
            arcaneCharges = true,
            chi = true,
            evokerEssences = true,
            showCoordinates = false,
            playerFrame = true,
            mainStatusTrackingBarContainer = true,
            menu = true,
            bags = true,
        },
        QueueStatusButton = {},
        TotemFrame = {},
        PetFrame = {},
        VehicleSeatIndicator = {},
        HolyPower = {},
        Achievements = {},
        SoulShards = {},
        ToT = {},
        TargetSpellBar = {},
        FocusSpellBar = {},
        UIWidgetTopCenterContainerFrame = {},
        StanceBar = {},
        Runes = {},
        ArcaneCharges = {},
        Chi = {},
        EvokerEssences = {},
        PlayerFrame = {},
        MainStatusTrackingBarContainer = {},
    }
}

local f = CreateFrame("Frame")

local options = {
    type = "group",
    set = function(info, value) f.db.global.EMEOptions[info[#info]] = value end,
    get = function(info) return f.db.global.EMEOptions[info[#info]] end,
    args = {
        description = {
            name = "All changes require a /reload to take effect! Uncheck if you don't want this addon to manage that frame.",
            type = "description",
            fontSize = "medium",
            order = 0,
        },
        lfg = {
            name = "LFG Button",
            desc = "Enables / Disables LFG Button support",
            type = "toggle", 
        },
        vehicle = {
            name = "Vehicle",
            desc = "Enables / Disables Vehicle Frame support",
            type = "toggle",
        },
        holyPower = {
            name = "Holy Power",
            desc = "Enables / Disables Holy Power support",
            type = "toggle",
        },
        totem = {
            name = "Totem",
            desc = "Enables / Disables Totem support",
            type = "toggle",
        },
        soulShards = {
            name = "Soul Shards",
            desc = "Enables / Disables Soul Shards support",
            type = "toggle",
        },
        pet = {
            name = "Pet Frame",
            desc = "Enables / Disables Pet Frame support",
            type = "toggle",
        },
        achievementAlert = {
            name = "Achievement",
            desc = "Enables / Disables Achievement Alert support",
            type = "toggle",
        },
        targetOfTarget = {
            name = "Target of Target",
            desc = "Enables / Disables Target of Target support",
            type = "toggle",
        },
        targetCast = {
            name = "Target Cast Bar",
            desc = "Enables / Disables Target Cast Bar support",
            type = "toggle",
        },
        focusCast = {
            name = "Focus Cast Bar",
            desc = "Enables / Disables Focus Cast Bar support",
            type = "toggle",
        },
        compactRaidFrameContainer = {
            name = "Compact Raid Frame Container",
            desc = "Enables / Disables additional options for the Compact Raid Frames",
            type = "toggle",
        },
        talkingHead = {
            name = "Talking Head",
            desc = "Enables / Disables additional options for the Talking Head",
            type = "toggle",
        },
        minimap = {
            name = "Minimap",
            desc = "Enables / Disables additional options for the Minimap",
            type = "toggle",
        },
        uiWidgetTopCenterContainerFrame = {
            name = "Subzone Information",
            desc = "Enables / Disables top of screen subzone information widget support. Be aware: this frame behaves... unusually... if you are not in an area that shows anything!",
            type = "toggle",
        },
        stanceBar = {
            name = "Stance Bar",
            desc = "Enables / Disables additional options for the Stance Bar",
            type = "toggle",
        },
        runes = {
            name = "Death Knight Runes",
            desc = "Enables / Disables Death Knight runes support",
            type = "toggle",
        },
        arcaneCharges = {
            name = "Mage Arcane Charges",
            desc = "Enables / Disables Mage arcane charges support",
            type = "toggle",
        },
        chi = {
            name = "Monk Chi",
            desc = "Enables / Disables Monk chi support",
            type = "toggle",
        },
        evokerEssences = {
            name = "Evoker Essences",
            desc = "Enables / Disables Evoker essences support",
            type = "toggle",
        },
        showCoordinates = {
            name = "Show Coordinates",
            type = "toggle",
            desc = "Show window coordinates of selected frame",
        },
        playerFrame = {
            name = "Player Frame",
            type = "toggle",
            desc = "Enables / Disables additional options for the Player Frame",
        },
        mainStatusTrackingBarContainer = {
            name = "Experience Bar",
            desc = "Enables / Disables additional options for the Experience Bar",
            type = "toggle",
        },
    },
}

local achievementFrameLoaded
local petFrameLoaded
local addonLoaded
local totemFrameLoaded

local function registerTotemFrame(db)
    TotemFrame:SetParent(UIParent)
    lib:RegisterFrame(TotemFrame, "Totem", db.TotemFrame)
    lib:SetDefaultSize(TotemFrame, 100, 40)
    lib:RegisterHideable(TotemFrame)
    totemFrameLoaded = true
end

f:SetScript("OnEvent", function(__, event, arg1)
    if (event == "ADDON_LOADED") and (arg1 == "EditModeExpanded") and (not addonLoaded) then
        f:UnregisterEvent("ADDON_LOADED")
        addonLoaded = true
        f.db = LibStub("AceDB-3.0"):New("EditModeExpandedADB", defaults)
        
        local db = f.db.global
        
        AceConfigRegistry:RegisterOptionsTable("EditModeExpanded", options)
        AceConfigDialog:AddToBlizOptions("EditModeExpanded")
        
        for _, frame in ipairs(EditModeManagerFrame.registeredSystemFrames) do
            local name = frame:GetName()
            if not db[name] then db[name] = {} end
            lib:RegisterFrame(frame, "", db[name])
        end
        
        if db.EMEOptions.compactRaidFrameContainer then
            local originalFrameManagerX, originalFrameManagerY = CompactRaidFrameManager:GetRect()
            local wasMoved = false
            lib:RegisterCustomCheckbox(CompactRaidFrameContainer, "Hide Frame Manager", 
                -- on checked
                function()
                    if wasMoved then return end
                    wasMoved = true
                    
                    -- this frame cannot be :Hide() hidden, as other frames are parented to it. Cannot change the parenting either, without causing other problems.
                    -- So, instead, lets shove it off the screen.
                    --local x, y = CompactRaidFrameContainer:GetRect()
                    originalFrameManagerX, originalFrameManagerY = CompactRaidFrameManager:GetRect()
                    CompactRaidFrameManager:ClearAllPoints()
                    CompactRaidFrameManager:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", 0, 0)
                    --CompactRaidFrameContainer:ClearAllPoints()
                    --CompactRaidFrameContainer:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
                end,
                
                -- on unchecked
                function()
                    if not wasMoved then return end
                    wasMoved = false
                    
                    local x, y = CompactRaidFrameContainer:GetRect()
                    CompactRaidFrameManager:ClearAllPoints()
                    CompactRaidFrameManager:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", originalFrameManagerX, originalFrameManagerY)
                    CompactRaidFrameContainer:ClearAllPoints()
                    CompactRaidFrameContainer:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
                end
            )
        end
        
        if db.EMEOptions.talkingHead then
            lib:RegisterHideable(TalkingHeadFrame)
            TalkingHeadFrame:HookScript("OnEvent", function(...)
                if lib:IsFrameMarkedHidden(TalkingHeadFrame) then
                    TalkingHeadFrame:Close()
                    TalkingHeadFrame:Hide()
                end
            end)
            lib:RegisterResizable(TalkingHeadFrame)
            -- should be moved to PLAYER_ENTERING_WORLD or something
            C_Timer.After(1, function()
                lib:UpdateFrameResize(TalkingHeadFrame)
            end)
        end
        
        local class = UnitClassBase("player")
        
        if class == "PALADIN" then
            if db.EMEOptions.holyPower then
                lib:RegisterFrame(PaladinPowerBarFrame, "Holy Power", db.HolyPower)
                C_Timer.After(4, function() lib:RepositionFrame(PaladinPowerBarFrame) end)
                lib:RegisterHideable(PaladinPowerBarFrame)
            end
            
            -- Totem Frame is used for Consecration
            if db.EMEOptions.totem then
                registerTotemFrame(db)
            end
        elseif class == "WARLOCK" then
            if db.EMEOptions.soulShards then
                lib:RegisterFrame(WarlockPowerFrame, "Soul Shards", db.SoulShards)
                lib:RegisterHideable(WarlockPowerFrame)
                lib:SetDontResize(WarlockPowerFrame)
                hooksecurefunc(WarlockPowerFrame, "IsDirty", function()
                    if not EditModeManagerFrame.editModeActive then
                        lib:RepositionFrame(WarlockPowerFrame)
                    end
                end)
                lib:RegisterResizable(WarlockPowerFrame)
            end
            
            -- Totem Frame is used for Summon Darkglare
            if db.EMEOptions.totem then
                registerTotemFrame(db)
            end
        elseif class == "SHAMAN" then
            if db.EMEOptions.totem then
                registerTotemFrame(db)
            end
        elseif class == "MONK" then
            -- Summon black ox uses totem frame
            if db.EMEOptions.totem then
                registerTotemFrame(db)
            end
            
            if db.EMEOptions.chi then
                lib:RegisterFrame(MonkHarmonyBarFrame, "Chi", db.Chi)
                lib:SetDontResize(MonkHarmonyBarFrame)
                lib:RegisterHideable(MonkHarmonyBarFrame)
                lib:RegisterResizable(MonkHarmonyBarFrame)
                hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
                    if not EditModeManagerFrame.editModeActive then
                        lib:RepositionFrame(MonkHarmonyBarFrame)
                    end
                end)
            end
        elseif class == "DEATHKNIGHT" then
            if db.EMEOptions.runes then
                lib:RegisterFrame(RuneFrame, "Runes", db.Runes)
                lib:RegisterHideable(RuneFrame)
                lib:SetDontResize(RuneFrame)
                lib:RegisterResizable(RuneFrame)
                hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
                    if not EditModeManagerFrame.editModeActive then
                        lib:RepositionFrame(RuneFrame)
                    end
                end)
                lib:RegisterCustomCheckbox(RuneFrame, "Unlink from Player Frame (may require reload)", 
                    --onChecked
                    function()
                        RuneFrame:SetParent(UIParent)
                    end,
                    --onUnchecked
                    function()
                        RuneFrame:SetParent(PlayerFrameBottomManagedFramesContainer)
                    end
                )
            end
        elseif class == "MAGE" then
            if db.EMEOptions.arcaneCharges then
                lib:RegisterFrame(MageArcaneChargesFrame, "Arcane Charges", db.ArcaneCharges)
                lib:RegisterHideable(MageArcaneChargesFrame)
                lib:SetDontResize(MageArcaneChargesFrame)
                lib:RegisterResizable(MageArcaneChargesFrame)
                hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
                    if not EditModeManagerFrame.editModeActive then
                        lib:RepositionFrame(MageArcaneChargesFrame)
                    end
                end)
                hooksecurefunc(MageArcaneChargesFrame, "HandleBarSetup", function()
                    if not EditModeManagerFrame.editModeActive then
                        lib:RepositionFrame(MageArcaneChargesFrame)
                    end
                end)
            end
        elseif class == "EVOKER" then
            if db.EMEOptions.evokerEssences then
                lib:RegisterFrame(EssencePlayerFrame, "Essences", db.EvokerEssences)
                lib:SetDontResize(EssencePlayerFrame)
                lib:RegisterHideable(EssencePlayerFrame)
                lib:RegisterResizable(EssencePlayerFrame)
                hooksecurefunc(EssencePowerBar, "UpdatePower", function()
                    if not EditModeManagerFrame.editModeActive then
                        lib:RepositionFrame(EssencePlayerFrame)
                    end
                end)
            end
        end
        
        
    elseif (event == "UNIT_PET") and (not petFrameLoaded) and (addonLoaded) then
        f:UnregisterEvent("UNIT_PET")
        if f.db.global.EMEOptions.pet then
            local function init()
                PetFrame:SetParent(UIParent)
                lib:RegisterFrame(PetFrame, "Pet", f.db.global.PetFrame)
            end
            
            if InCombatLockdown() then
                -- delay registering until combat ends
                local tempFrame = CreateFrame("Frame")
                tempFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
                local doOnce
                tempFrame:SetScript("OnEvent", function()
                    if doOnce then return end
                    doOnce = true
                    init()
                    tempFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
                    lib:RepositionFrame(PetFrame)
                end)
            else
                init()
            end
        end
    elseif (event == "PLAYER_ENTERING_WORLD") and (not achievementFrameLoaded) and (addonLoaded) then
        f:UnregisterEvent("PLAYER_ENTERING_WORLD")
        achievementFrameLoaded = true
        local db = f.db.global
        
        if db.EMEOptions.achievementAlert then
            if ( not AchievementFrame ) then
    			AchievementFrame_LoadUI()
            end
            lib:RegisterFrame(AlertFrame, "Achievements", f.db.global.Achievements)
            lib:SetDefaultSize(AlertFrame, 20, 20)
            AlertFrame.Selection:HookScript("OnMouseDown", function()
                AchievementAlertSystem:AddAlert(6)
            end)
            AlertFrame:HookScript("OnEvent", function()
                lib:RepositionFrame(AlertFrame)
            end)
        end
        
        if db.EMEOptions.targetOfTarget then
            lib:RegisterFrame(TargetFrameToT, "Target of Target", f.db.global.ToT)
            TargetFrameToT:HookScript("OnHide", function()
                if (not InCombatLockdown()) and EditModeManagerFrame.editModeActive and lib:IsFrameEnabled(TargetFrameToT) then
                    TargetFrameToT:Show()
                end
            end)
        end
        
        if db.EMEOptions.targetCast then
            lib:RegisterFrame(TargetFrameSpellBar, "Target Cast Bar", f.db.global.TargetSpellBar, TargetFrame, "TOPLEFT")
            hooksecurefunc(TargetFrameSpellBar, "AdjustPosition", function(self)
                lib:RepositionFrame(TargetFrameSpellBar)
                if EditModeManagerFrame.editModeActive then
                    TargetFrameSpellBar:Show()
                end
            end)
            TargetFrameSpellBar:HookScript("OnShow", function(self)
                lib:RepositionFrame(TargetFrameSpellBar)
            end)
            lib:SetDontResize(TargetFrameSpellBar)
            lib:RegisterResizable(TargetFrameSpellBar)            
        end
        
        if db.EMEOptions.focusCast then
            lib:RegisterFrame(FocusFrameSpellBar, "Focus Cast Bar", f.db.global.FocusSpellBar, FocusFrame, "TOPLEFT")
            lib:SetDontResize(FocusFrameSpellBar)
            hooksecurefunc(FocusFrameSpellBar, "AdjustPosition", function(self)
                if EditModeManagerFrame.editModeActive then
                    FocusFrameSpellBar:Show()
                end
                lib:RepositionFrame(FocusFrameSpellBar)
            end)
            FocusFrameSpellBar:HookScript("OnShow", function(self)
                lib:RepositionFrame(FocusFrameSpellBar)
            end)
        end
        
        if db.EMEOptions.lfg then
            QueueStatusButton:SetParent(UIParent)
            lib:RegisterFrame(QueueStatusButton, "LFG", db.QueueStatusButton)
            lib:RegisterResizable(QueueStatusButton)
            lib:RegisterMinimapPinnable(QueueStatusButton)
        end
        
        if db.EMEOptions.minimap then
            lib:RegisterResizable(MinimapCluster)
            C_Timer.After(1, function() lib:UpdateFrameResize(MinimapCluster) end)
        end
        
        if db.EMEOptions.uiWidgetTopCenterContainerFrame then
            lib:RegisterFrame(UIWidgetTopCenterContainerFrame, "Subzone Information", db.UIWidgetTopCenterContainerFrame)
            lib:SetDontResize(UIWidgetTopCenterContainerFrame)
        end
        
        if db.EMEOptions.stanceBar then
            lib:RegisterHideable(StanceBar)
            StanceBar:HookScript("OnEvent", function(...)
                if lib:IsFrameMarkedHidden(StanceBar) then
                    StanceBar:Hide()
                end
            end)
            C_Timer.After(1, function()
                if lib:IsFrameMarkedHidden(StanceBar) then
                    StanceBar:Hide()
                end
            end)
        end
        
        if db.EMEOptions.showCoordinates then 
            hooksecurefunc(EditModeExpandedSystemSettingsDialog, "AttachToSystemFrame", function(self, frame)
                self.Title:SetText(frame.systemName.." ("..math.floor(frame:GetLeft())..","..math.floor(frame:GetBottom())..")")
            end)
            hooksecurefunc(EditModeExpandedSystemSettingsDialog, "UpdateSettings", function(self, frame)
                self.Title:SetText(frame.systemName.." ("..math.floor(frame:GetLeft())..","..math.floor(frame:GetBottom())..")")
            end)
        end
        
        if db.EMEOptions.playerFrame then
            lib:RegisterHideable(PlayerFrame)
            local checked = false
            lib:RegisterCustomCheckbox(PlayerFrame, "Hide Resource Bar", 
                -- on checked
                function()
                    checked = true
                    PlayerFrame.manabar:Hide()
                end,
                
                -- on unchecked
                function()
                    checked = false
                    PlayerFrame.manabar:Show()
                end
            )
            PlayerFrame.manabar:HookScript("OnShow", function()
                if checked then
                    PlayerFrame.manabar:Hide()
                end
            end)
        end
        
        if db.EMEOptions.vehicle then
            VehicleSeatIndicator:SetPoint("TOPLEFT", DurabilityFrame, "TOPLEFT")
            lib:RegisterFrame(VehicleSeatIndicator, "Vehicle Seats", db.VehicleSeatIndicator)
            lib:RegisterResizable(VehicleSeatIndicator)
        end
        
        if db.EMEOptions.mainStatusTrackingBarContainer then
            lib:RegisterResizable(MainStatusTrackingBarContainer)
            lib:RegisterHideable(MainStatusTrackingBarContainer)
            C_Timer.After(1, function() lib:UpdateFrameResize(MainStatusTrackingBarContainer) end)
            hooksecurefunc(MainStatusTrackingBarContainer, "SetScale", function(frame, scale)
                StatusTrackingBarManager.bars[4]:SetScale(scale)
            end)
            hooksecurefunc(MainStatusTrackingBarContainer, "SetScaleOverride", function(frame, scale)
                StatusTrackingBarManager.bars[4]:SetScale(scale)
            end)
        end
    elseif (event == "PLAYER_TOTEM_UPDATE") then
        if totemFrameLoaded then
            lib:RepositionFrame(TotemFrame)
        end
    end
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("UNIT_PET")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_TOTEM_UPDATE")