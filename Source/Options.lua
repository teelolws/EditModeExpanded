local addonName, addon = ...

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local defaults = {
    global = {
        EMEOptions = {
            lfg = true,
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
            minimapHeader = true,
            uiWidgetTopCenterContainerFrame = false,
            UIWidgetBelowMinimapContainerFrame = false,
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
            comboPoints = true,
            bonusRoll = true,
            actionBars = false,
            groupLootContainer = true,
            auctionMultisell = true,
            chatButtons = true,
            backpack = true,
            targetFrame = true,
            focusFrame = true,
            buffFrame = true,
            debuffFrame = true,
            objectiveTrackerFrame = true,
        },
        QueueStatusButton = {},
        TotemFrame = {},
        HolyPower = {},
        Achievements = {},
        SoulShards = {},
        ToT = {},
        TargetSpellBar = {},
        FocusToT = {},
        FocusSpellBar = {},
        UIWidgetTopCenterContainerFrame = {},
        UIWidgetBelowMinimapContainerFrame = {},
        ArenaEnemyFramesContainer = {},
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
        ExpansionLandingPageMinimapButton = {},
        GroupLootContainer = {},
        AuctionHouseMultisellProgressFrame = {},
        QuickJoinToastButton = {},
        ChatFrameChannelButton = {},
        ChatFrameMenuButton = {},
        ContainerFrame1 = {},
        ContainerFrameCombinedBags = {},
        MinimapZoneName = {},
    }
}

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
        minimapHeader = {
            name = "Minimap Header",
            desc = "Enables / Disables Minimap Header support",
            type = "toggle",
        },
        uiWidgetTopCenterContainerFrame = {
            name = "Subzone Information",
            desc = "Enables / Disables top of screen subzone information widget support. This usually contains zone objectives such as number of flag captures in WSG. Be aware: this will not show anything if you are not in a zone that has an objective!",
            type = "toggle",
        },
        UIWidgetBelowMinimapContainerFrame = {
            name = "Below Minimap",
            desc = "Enables / Disables below minimap container support. This usually contains PvP objectives like flag carriers in WSG and base capture progress bars. Be aware: this will not show anything if you are not in an area that puts anything in the container!",
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
            desc = "Enables / Disables additional options for the Bag Bar",
            type = "toggle",
        },
        targetFrame = {
            name = "Target",
            desc = "Enables / Disables additional options for the Target Frame",
            type = "toggle",
        },
        focusFrame = {
            name = "Focus",
            desc = "Enables / Disables additional options for the Focus Frame",
            type = "toggle",
        },
        buffFrame = {
            name = "Buffs",
            desc = "Enables / Disables additional options for the Buff List",
            type = "toggle",
        },
        debuffFrame = {
            name = "Debuffs",
            desc = "Enables / Disables additional options for the Debuff List",
            type = "toggle",
        },
        menuResizable = {
            name = "Resize Menu Bar",
            desc = "Allows the Menu Bar to be resized, with more options than the default options. WARNING: this will override the resize slider provided by the base UI. If you try to use both sliders, unexpected things could happen!",
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
            desc = "Allows the action bars to have their padding set to zero. WARNING: you MUST move all your action bars from their default position AND disable 'magnetism', or you will get addon errors. You can even move the bars back to where they were originally!",
            type = "toggle",
        },
        groupLootContainer = {
            name = "Group Loot Container",
            desc = "Enables / Disables Group Loot Container support",
            type = "toggle",
        },
        auctionMultisell = {
            name = "Auction Multisell",
            desc = "Enables / Disables Auction Multisell support",
            type = "toggle",
        },
        chatButtons = {
            name = "Chat Buttons",
            desc = "Enables / Disables Chat Buttons support",
            type = "toggle",
        },
        backpack = {
            name = "Backpack",
            desc = "Enables / Disabled Backpack support",
            type = "toggle",
        },
    },
}

function addon:initOptions()
    addon.db = LibStub("AceDB-3.0"):New("EditModeExpandedADB", defaults)
            
    AceConfigRegistry:RegisterOptionsTable(addonName, options)
    AceConfigDialog:AddToBlizOptions(addonName)
end