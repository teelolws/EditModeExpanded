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
            achievementAlert = true,
            targetOfTarget = true,
            targetCast = true,
            focusTargetOfTarget = true,
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
            secondaryStatusTrackingBarContainer = true,
            menu = true,
            menuResizable = false,
            bags = true,
            bagsResizable = false,
            comboPoints = true,
            bonusRoll = true,
            actionBars = false,
        },
        QueueStatusButton = {},
        TotemFrame = {},
        VehicleSeatIndicator = {},
        HolyPower = {},
        Achievements = {},
        SoulShards = {},
        ToT = {},
        TargetSpellBar = {},
        FocusToT = {},
        FocusSpellBar = {},
        UIWidgetTopCenterContainerFrame = {},
        StanceBar = {},
        Runes = {},
        ArcaneCharges = {},
        Chi = {},
        EvokerEssences = {},
        PlayerFrame = {},
        MainStatusTrackingBarContainer = {},
        SecondaryStatusTrackingBarContainer = {},
        MicroMenu = {},
        ComboPoints = {},
        BonusRoll = {},
        MainMenuBar = {},
        MultiBarBottomLeft = {},
        MultiBarBottomRight = {},
        MultiBarRight = {},
        MultiBarLeft = {},
        MultiBar5 = {},
        MultiBar6 = {},
        MultiBar7 = {},
        CompactRaidFrameManager = {},
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
        focusTargetOfTarget = {
            name = "Focus Target of Target",
            desc = "Enables / Disables Focus Target of Target support",
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
        secondaryStatusTrackingBarContainer = {
            name = "Reputation Bar",
            desc = "Enables / Disables additional options for the Reputation Bar",
            type = "toggle",
        },
        menu = {
            name = "Menu Bar",
            desc = "Enables / Disables additional options for the Menu Bar",
            type = "toggle",
        },
        bags = {
            name = "Bag Bar",
            desc = "Enables / Disables additional options for the Bag Bag",
            type = "toggle",
        },
        menuResizable = {
            name = "Resize Menu Bar",
            desc = "Allows the Menu Bar to be resized, with more options than the default options. WARNING: this will override the resize slider provided by the base UI. If you try to use both sliders, unexpected things could happen!",
            type = "toggle",
        },
        bagsResizable = {
            name = "Resize Bags Bar",
            desc = "Allows the Bags Bar to be resized, with more options than the default options. WARNING: this will override the resize slider provided by the base UI. If you try to use both sliders, unexpected things could happen!",
            type = "toggle",
        },
        comboPoints = {
            name = "Combo Ponts",
            desc = "Enables / Disables Combo Points support",
            type = "toggle",
        },
        bonusRoll = {
            name = "Bonus Roll",
            desc = "Enables / Disables Bonus Roll support",
            type = "toggle",
        },
        actionBars = {
            name = "Action Bars",
            desc = "Allows the action bars to have their padding set to zero. WARNING: you MUST move all your action bars from their default position, or you will get addon errors. You can even move the bars back to where they were originally!",
            type = "toggle",
        },
    },
}

local achievementFrameLoaded
local addonLoaded
local totemFrameLoaded

local function registerTotemFrame(db)
    TotemFrame:SetParent(UIParent)
    lib:RegisterFrame(TotemFrame, "Totem", db.TotemFrame)
    lib:SetDefaultSize(TotemFrame, 100, 40)
    lib:RegisterHideable(TotemFrame)
    lib:RegisterResizable(TotemFrame)
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
            
            -- was changed from MicroMenu to MicroMenuContainer in 10.1
            if name == "MicroMenuContainer" then
                name = "MicroMenu"
            end
            
            if not db[name] then db[name] = {} end
            lib:RegisterFrame(frame, "", db[name])
        end
        
        if db.EMEOptions.compactRaidFrameContainer then
            lib:RegisterFrame(CompactRaidFrameManager, "Raid Manager", db.CompactRaidFrameManager)
            local expanded
            hooksecurefunc("CompactRaidFrameManager_Expand", function()
                if expanded then return end
                expanded = true
                CompactRaidFrameManager:ClearPoint("TOPLEFT")
                lib:RepositionFrame(CompactRaidFrameManager)
                for i = 1, CompactRaidFrameManager:GetNumPoints() do
                    local a, b, c, x, e = CompactRaidFrameManager:GetPoint(i)
                    x = x + 175
                    CompactRaidFrameManager:SetPoint(a,b,c,x,e)
                end
            end)
            hooksecurefunc("CompactRaidFrameManager_Collapse", function()
                if not expanded then return end
                expanded = false
                CompactRaidFrameManager:ClearPoint("TOPLEFT")
                lib:RepositionFrame(CompactRaidFrameManager)
            end)
            lib:RegisterHideable(CompactRaidFrameManager)
            
            -- the wasVisible saved in the library when entering Edit Mode cannot be relied upon, as entering Edit Mode shows the raid manager in some situations, before we can detect if it was already visible
            hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
                CompactRaidFrameManager:SetShown(IsInGroup() or IsInRaid())
            end)
            
            do
                local noInfinite
                hooksecurefunc(CompactRaidFrameManager, "SetShown", function()
                    if noInfinite then return end
                    if EditModeManagerFrame.editModeActive then
                        CompactRaidFrameManager:Show()
                    else
                        noInfinite = true
                        lib:RepositionFrame(CompactRaidFrameManager)
                        noInfinite = false
                    end
                end)
            end
                
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
            lib:RegisterResizable(TargetFrameToT)
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
        
        if db.EMEOptions.focusTargetOfTarget then
            FocusFrameToT:SetUserPlaced(false) -- bug with frame being saved in layout cache leading to errors in TargetFrame.lua
            lib:RegisterFrame(FocusFrameToT, "Focus Target of Target", f.db.global.FocusToT, FocusFrame, "TOPRIGHT")
            lib:RegisterResizable(FocusFrameToT)
            FocusFrameToT:HookScript("OnHide", function()
                if (not InCombatLockdown()) and EditModeManagerFrame.editModeActive and lib:IsFrameEnabled(FocusFrameToT) then
                    FocusFrameToT:Show()
                end
            end)
            hooksecurefunc(FocusFrameToT, "SetPoint", function()
                if FocusFrameToT:IsUserPlaced() then
                    FocusFrameToT:SetUserPlaced(false)
                end
            end)
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
            hooksecurefunc(MicroMenu, "UpdateQueueStatusAnchors", function()
                lib:RepositionFrame(QueueStatusButton)
            end)
            hooksecurefunc(MicroMenuContainer, "Layout", function()
                MicroMenuContainer:SetWidth(MicroMenu:GetWidth()*MicroMenu:GetScale())
            end)
        end
        
        if db.EMEOptions.minimap then
            lib:RegisterResizable(MinimapCluster)
            C_Timer.After(1, function() lib:UpdateFrameResize(MinimapCluster) end)
            
            local isDefault = true
            local elpA, elpB, elpC, elpD, elpE = ExpansionLandingPageMinimapButton:GetPoint(1)
            lib:RegisterCustomCheckbox(MinimapCluster, "Square",
                function()
                    isDefault = false
                    Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
                    ExpansionLandingPageMinimapButton:SetParent(MinimapCluster.MinimapContainer)
                    MinimapBackdrop:Hide()
                    ExpansionLandingPageMinimapButton:ClearAllPoints()
                    ExpansionLandingPageMinimapButton:SetPoint("BOTTOMLEFT", MinimapCluster.MinimapContainer, "BOTTOMLEFT", -10, 0)
                end,
                
                function()
                    -- don't change it to circle if it is already a circle from the last login
                    if isDefault then return end
                    Minimap:SetMaskTexture("Interface\\Masks\\CircleMask")
                    MinimapBackdrop:Show()
                    ExpansionLandingPageMinimapButton:SetParent(MinimapBackdrop)
                    ExpansionLandingPageMinimapButton:ClearAllPoints()
                    ExpansionLandingPageMinimapButton:SetPoint(elpA, elpB, elpC, elpD, elpE)
                end
            )
        end
        
        if db.EMEOptions.uiWidgetTopCenterContainerFrame then
            lib:RegisterFrame(UIWidgetTopCenterContainerFrame, "Subzone Information", db.UIWidgetTopCenterContainerFrame)
            lib:SetDontResize(UIWidgetTopCenterContainerFrame)
        end
        
        if db.EMEOptions.stanceBar then
            lib:RegisterHideable(StanceBar)
            hooksecurefunc(StanceBar, "Show", function()
                if lib:IsFrameMarkedHidden(StanceBar) then
                    StanceBar:Hide()
                end
            end)
            hooksecurefunc(StanceBar, "SetShown", function()
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
                self.Title:SetText(frame:GetSystemName().." ("..math.floor(frame:GetLeft())..","..math.floor(frame:GetBottom())..")")
            end)
            hooksecurefunc(EditModeExpandedSystemSettingsDialog, "UpdateSettings", function(self, frame)
                self.Title:SetText(frame:GetSystemName().." ("..math.floor(frame:GetLeft())..","..math.floor(frame:GetBottom())..")")
            end)
        end
        
        if db.EMEOptions.playerFrame then
            lib:RegisterHideable(PlayerFrame)
            C_Timer.After(4, function()
                if lib:IsFrameMarkedHidden(PlayerFrame) then
                    PlayerFrame:Hide()
                end
            end)
            
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
            VehicleSeatIndicator:SetParent(UIParent)
            VehicleSeatIndicator:SetPoint("TOPLEFT", DurabilityFrame, "TOPLEFT")
            lib:RegisterFrame(VehicleSeatIndicator, "Vehicle Seats", db.VehicleSeatIndicator)
            lib:RegisterResizable(VehicleSeatIndicator)
            VehicleSeatIndicator:HookScript("OnEvent", function()
                lib:RepositionFrame(VehicleSeatIndicator)
            end)
        end
        
        if db.EMEOptions.mainStatusTrackingBarContainer then
            lib:RegisterResizable(MainStatusTrackingBarContainer)
            lib:RegisterHideable(MainStatusTrackingBarContainer)
            C_Timer.After(1, function() lib:UpdateFrameResize(MainStatusTrackingBarContainer) end)
            hooksecurefunc(MainStatusTrackingBarContainer, "SetScale", function(frame, scale)
                for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                    local _, anchor = bar:GetPoint(1)
                    if anchor == MainStatusTrackingBarContainer then
                        bar:SetScale(scale) 
                    end
                end
            end)
            hooksecurefunc(MainStatusTrackingBarContainer, "SetScaleOverride", function(frame, scale)
                for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                    local _, anchor = bar:GetPoint(1)
                    if anchor == MainStatusTrackingBarContainer then
                        bar:SetScale(scale) 
                    end
                end
            end)
            
            hooksecurefunc(StatusTrackingBarManager, "UpdateBarsShown", function()
                for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                    local _, anchor = bar:GetPoint(1)
                    if anchor == MainStatusTrackingBarContainer then
                        bar:SetScale(MainStatusTrackingBarContainer:GetScale()) 
                    end
                end
            end)
        end
        
        if db.EMEOptions.secondaryStatusTrackingBarContainer then
            lib:RegisterResizable(SecondaryStatusTrackingBarContainer)
            lib:RegisterHideable(SecondaryStatusTrackingBarContainer)
            C_Timer.After(1, function() lib:UpdateFrameResize(SecondaryStatusTrackingBarContainer) end)
            hooksecurefunc(SecondaryStatusTrackingBarContainer, "SetScale", function(frame, scale)
                for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                    local _, anchor = bar:GetPoint(1)
                    if anchor == SecondaryStatusTrackingBarContainer then
                        bar:SetScale(scale) 
                    end
                end
            end)
            hooksecurefunc(SecondaryStatusTrackingBarContainer, "SetScaleOverride", function(frame, scale)
                for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                    local _, anchor = bar:GetPoint(1)
                    if anchor == SecondaryStatusTrackingBarContainer then
                        bar:SetScale(scale) 
                    end
                end
            end)
            
            hooksecurefunc(StatusTrackingBarManager, "UpdateBarsShown", function()
                for _, bar in ipairs(StatusTrackingBarManager.barContainers) do
                    local _, anchor = bar:GetPoint(1)
                    if anchor == SecondaryStatusTrackingBarContainer then
                        bar:SetScale(SecondaryStatusTrackingBarContainer:GetScale()) 
                    end
                end
            end)
        end
        
        if db.EMEOptions.menu then
            lib:RegisterHideable(MicroMenuContainer)
            C_Timer.After(1, function()
                if lib:IsFrameMarkedHidden(MicroMenuContainer) then
                    MicroMenuContainer:Hide()
                end
            end)
            local enabled = false
            local padding
            lib:RegisterCustomCheckbox(MicroMenuContainer, "Set padding to zero",
                function()
                    enabled = true
                    for key, button in ipairs(MicroMenu:GetLayoutChildren()) do
                        if key ~= 1 then
                            local a, b, c, d, e = button:GetPoint(1)
                            if (key == 2) and (not padding) then
                                padding = d
                            end
                            button:ClearAllPoints()
                            button:SetPoint(a, b, c, d-(3*(key-1)), e)
                        end
                    end
                    MicroMenu:SetWidth(MicroMenu:GetWidth() - 30)
                end,
                
                function(init)
                    if not init then
                        enabled = false
                        for key, button in ipairs(MicroMenu:GetLayoutChildren()) do
                            if key ~= 1 then
                                local a, b, c, d, e = button:GetPoint(1)
                                button:ClearAllPoints()
                                button:SetPoint(a, b, c, d+(3*(key-1)), e)
                            end
                        end
                        MicroMenu:SetWidth(MicroMenu:GetWidth() + 30)
                    end
                end
            )
            hooksecurefunc(MicroMenuContainer, "Layout", function(...)
                if OverrideActionBar.isShown then return end
                if PetBattleFrame and PetBattleFrame:IsShown() then return end

                if enabled and padding and ((math.floor((select(4, MicroMenu:GetLayoutChildren()[2]:GetPoint(1))*100) + 0.5)/100) == (math.floor((padding*100) + 0.5)/100)) then
                    for key, button in ipairs(MicroMenu:GetLayoutChildren()) do
                        if key ~= 1 then
                            local a, b, c, d, e = button:GetPoint(1)
                            button:ClearAllPoints()
                            button:SetPoint(a, b, c, d-(3*(key-1)), e)
                        end
                    end
                    MicroMenu:SetWidth(MicroMenu:GetWidth() - 30)
                end
            end)
        end
        
        if db.EMEOptions.menuResizable then
            lib:RegisterResizable(MicroMenuContainer)
            C_Timer.After(1, function()
                lib:UpdateFrameResize(MicroMenuContainer)
            end)
            
            -- triggers when player leaves a vehicle or pet battle
            hooksecurefunc("ResetMicroMenuPosition", function(...)
                lib:UpdateFrameResize(MicroMenuContainer)
            end)
        end
        
        if db.EMEOptions.bags then
            lib:RegisterHideable(BagsBar)
            C_Timer.After(1, function()
                if lib:IsFrameMarkedHidden(BagsBar) then
                    BagsBar:Hide()
                end
            end)
        end
        
        if db.EMEOptions.bagsResizable then
            lib:RegisterResizable(BagsBar)
            C_Timer.After(1, function()
                lib:UpdateFrameResize(BagsBar)
            end)
        end
        
        if db.EMEOptions.bonusRoll then
            local alreadyInitialized
            
            BonusRollFrame:HookScript("OnShow", function()
                if alreadyInitialized then
                    lib:RepositionFrame(BonusRollFrame)
                    return
                end
                alreadyInitialized = true
                lib:RegisterFrame(BonusRollFrame, "Bonus Roll", db.BonusRoll)
                lib:HideByDefault(BonusRollFrame)
                BonusRollFrame.Selection:SetFrameStrata("TOOLTIP")
            end)
        end
        
        if db.EMEOptions.actionBars then
            C_Timer.After(10, function()
                if InCombatLockdown() then return end 
                local bars = {MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarRight, MultiBarLeft, MultiBar5, MultiBar6, MultiBar7}

                for _, bar in ipairs(bars) do
                    lib:RegisterCustomCheckbox(bar, "Override Icon Padding to Zero", 
                        -- on checked
                        function()
                            bar.minButtonPadding = 0
                            bar.buttonPadding = 0
                            bar:UpdateGridLayout()
                        end,
                        
                        -- on unchecked
                        function()
                            bar.minButtonPadding = 2
                            bar.buttonPadding = 2
                            bar:UpdateGridLayout()
                        end,
                        
                        "OverrideIconPadding"
                    )
                end
            end)
        end
        
        local class = UnitClassBase("player")
        
        if class == "PALADIN" then
            if db.EMEOptions.holyPower then
                lib:RegisterFrame(PaladinPowerBarFrame, "Holy Power", db.HolyPower)
                C_Timer.After(4, function() lib:RepositionFrame(PaladinPowerBarFrame) end)
                lib:RegisterHideable(PaladinPowerBarFrame)
                hooksecurefunc(PaladinPowerBarFrame, "Setup", function()
                    if not EditModeManagerFrame.editModeActive then
                        lib:RepositionFrame(PaladinPowerBarFrame)
                        if lib:IsFrameMarkedHidden(PaladinPowerBarFrame) then
                            PaladinPowerBarFrame:Hide()
                        end
                    end
                end)
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
                local a = 0
                lib:RegisterFrame(EssencePlayerFrame, "Essences", db.EvokerEssences)
                lib:SetDontResize(EssencePlayerFrame)
                lib:RegisterHideable(EssencePlayerFrame)
                lib:RegisterResizable(EssencePlayerFrame)
                hooksecurefunc(EssencePlayerFrame, "UpdatePower", function()
                    if not EditModeManagerFrame.editModeActive then
                        a = a + 1
                        lib:RepositionFrame(EssencePlayerFrame)
                        a = a - 1
                    end
                end)
                hooksecurefunc(EssencePlayerFrame, "SetPoint", function()
                    if a > 0 then return end
                    a = a + 1
                    lib:RepositionFrame(EssencePlayerFrame)
                    a = a - 1
                end)
            end
            
        elseif class == "ROGUE" then
            if db.EMEOptions.comboPoints then
                lib:RegisterFrame(RogueComboPointBarFrame, "Combo Points", db.ComboPoints)
                lib:SetDontResize(RogueComboPointBarFrame)
                lib:RegisterHideable(RogueComboPointBarFrame)
                lib:RegisterResizable(RogueComboPointBarFrame)
                hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
                    if not EditModeManagerFrame.editModeActive then
                        lib:RepositionFrame(RogueComboPointBarFrame)
                    end
                end)
            end
        elseif class == "PRIEST" then
            -- shadowfiend uses totem frame
            if db.EMEOptions.totem then
                registerTotemFrame(db)
            end
        elseif class == "DRUID" then
            if db.EMEOptions.comboPoints then
                lib:RegisterFrame(DruidComboPointBarFrame, "Combo Points", db.ComboPoints)
                lib:SetDontResize(DruidComboPointBarFrame)
                lib:RegisterHideable(DruidComboPointBarFrame)
                lib:RegisterResizable(DruidComboPointBarFrame)
                hooksecurefunc(PlayerFrameBottomManagedFramesContainer, "Layout", function()
                    if not EditModeManagerFrame.editModeActive then
                        lib:RepositionFrame(DruidComboPointBarFrame)
                    end
                end)
            end
        end
    elseif (event == "PLAYER_TOTEM_UPDATE") and addonLoaded then
        if totemFrameLoaded then
            lib:RepositionFrame(TotemFrame)
        end
    end
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_TOTEM_UPDATE")
