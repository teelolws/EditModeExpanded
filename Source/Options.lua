local addonName, addon = ...

local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local defaults = {
    char = {
        EssentialCooldownViewerSpellIDs = {
            ["*"] = {},
        },
        UtilityCooldownViewerSpellIDs = {
            ["*"] = {},
        },
        BuffIconCooldownViewerSpellIDs = {
            ["*"] = {},
        },
        BuffBarCooldownViewerSpellIDs = {
            ["*"] = {},
        },
        AutoLayoutSwitching = {},
    },
    global = {
        EMEOptions = {
            lfg = true,
            holyPower = true,
            totem = true,
            soulShards = true,
            achievementAlert = true, -- alertFrame, using the name acheivement for backward compatibility
            targetOfTarget = true,
            targetCast = true,
            focusTargetOfTarget = true,
            focusCast = true,
            compactRaidFrameContainer = false,
            talkingHead = true,
            minimap = true,
            minimapHeader = false,
            minimapResize = false,
            uiWidgetTopCenterContainerFrame = false,
            UIWidgetBelowMinimapContainerFrame = false,
            stanceBar = true,
            runes = true,
            arcaneCharges = true,
            chi = true,
            evokerEssences = true,
            showCoordinates = false,
            playerFrame = true,
            playerFrameResize = false,
            mainStatusTrackingBarContainer = true,
            secondaryStatusTrackingBarContainer = true,
            menu = true,
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
            targetFrameBuffs = false,
            gameMenu = true,
            gameTooltip = true,
            lossOfControl = true,
            pet = true,
            extraActionButton = true,
            cooldownManager = true,
            durationBars = true,
            allowSetCoordinates = false,
            raidSizeLayoutSwitching = false,
            vigorBar = true,
            housingControlsFrame = true,
        },
        QueueStatusButton = {},
        TotemFrame = {},
        HolyPower = {},
        Achievements = {}, -- alertFrame, using Acheivements for backward compatibility
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
        MainActionBar = {},
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
        MinimapSeparated = {},
        TargetDebuffs = {},
        TargetBuffs = {},
        GameMenuFrame = {},
        LOC = {},
        PetFrame = {},
        ExtraActionButton = {},
        EssentialCooldownViewer = {},
        UtilityCooldownViewer = {},
        BuffIconCooldownViewer = {},
        BuffBarCooldownViewer = {},
        MirrorTimerContainer = {},
        VigorBar = {},
        HousingControlsFrame = {},
    }
}

local options = {
    type = "group",
    set = function(info, value) addon.db.global.EMEOptions[info[#info]] = value end,
    get = function(info) return addon.db.global.EMEOptions[info[#info]] end,
    args = {
        description = {
            name = L["OPTIONS_RELOAD_REQUIREMENT_WARNING"],
            type = "description",
            fontSize = "medium",
            order = 0,
        },
        classResourceGroup = {
            name = L["Class Resources"],
            type = "group",
            args = {
                holyPower = {
                    name = HOLY_POWER,
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], HOLY_POWER),
                    type = "toggle",
                },
                soulShards = {
                    name = SOUL_SHARDS_POWER,
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], SOUL_SHARDS_POWER),
                    type = "toggle",
                },
                runes = {
                    name = RUNES,
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], RUNES),
                    type = "toggle",
                },
                arcaneCharges = {
                    name = POWER_TYPE_ARCANE_CHARGES,
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], POWER_TYPE_ARCANE_CHARGES),
                    type = "toggle",
                },
                chi = {
                    name = CHI_POWER,
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], CHI_POWER),
                    type = "toggle",
                },
                evokerEssences = {
                    name = POWER_TYPE_ESSENCE,
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], POWER_TYPE_ESSENCE),
                    type = "toggle",
                },
                comboPoints = {
                    name = COMBO_POINTS_POWER,
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], COMBO_POINTS_POWER),
                    type = "toggle",
                },
            },
        },
        targetGroup = {
            name = HUD_EDIT_MODE_TARGET_AND_FOCUS,
            type = "group",
            args = {
                targetOfTarget = {
                    name = SHOW_TARGET_OF_TARGET_TEXT,
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], SHOW_TARGET_OF_TARGET_TEXT),
                    type = "toggle",
                },
                targetCast = {
                    name = TARGET.." "..HUD_EDIT_MODE_CAST_BAR_LABEL,
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], TARGET.." "..HUD_EDIT_MODE_CAST_BAR_LABEL),
                    type = "toggle",
                },
                focusTargetOfTarget = {
                    name = L["Focus ToT"],
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], L["Focus ToT"]),
                    type = "toggle",
                },
                focusCast = {
                    name = L["Focus Cast Bar"],
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], L["Focus Cast Bar"]),
                    type = "toggle",
                },
                targetFrame = {
                    name = TARGET,
                    desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], TARGET),
                    type = "toggle",
                },
                targetFrameBuffs = {
                    name = TARGET.." "..BUFFOPTIONS_LABEL,
                    desc = string.format(L["TOGGLE_SUPPORT_STRING"], TARGET.." "..BUFFOPTIONS_LABEL),
                    type = "toggle",
                },
                focusFrame = {
                    name = FOCUS,
                    desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], FOCUS),
                    type = "toggle",
                },
            },
        },
        totem = {
            name = UNIT_NAME_FRIENDLY_TOTEMS,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], UNIT_NAME_FRIENDLY_TOTEMS),
            type = "toggle",
        },
        achievementAlert = {
            name = L["Alert"],
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], L["Alert"]),
            type = "toggle",
        },
        compactRaidFrameContainer = {
            name = HUD_EDIT_MODE_RAID_FRAMES_LABEL,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], HUD_EDIT_MODE_RAID_FRAMES_LABEL),
            type = "toggle",
        },
        talkingHead = {
            name = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL),
            type = "toggle",
        },
        minimapGroup = {
            name = HUD_EDIT_MODE_MINIMAP_LABEL,
            type = "group",
            args = {
                minimap = {
                    name = HUD_EDIT_MODE_MINIMAP_LABEL,
                    desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], HUD_EDIT_MODE_MINIMAP_LABEL),
                    type = "toggle",
                },
                minimapHeader = {
                    name = L["Minimap Header"],
                    desc = L["MINIMAP_HEADER_DESCRIPTION"],
                    type = "toggle",
                },
                minimapResize = {
                    name = L["Resize Minimap Cluster"],
                    desc = L["RESIZE_MINIMAP_DESCRIPTION"],
                    type = "toggle",
                },
            },
        },
        uiWidgetTopCenterContainerFrame = {
            name = L["Subzone Information"],
            desc = L["SUBZONE_DESCRIPTION"],
            type = "toggle",
        },
        UIWidgetBelowMinimapContainerFrame = {
            name = L["Below Minimap"],
            desc = L["BELOW_MINIMAP_DESCRIPTION"],
            type = "toggle",
        },
        stanceBar = {
            name = HUD_EDIT_MODE_STANCE_BAR_LABEL,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], HUD_EDIT_MODE_STANCE_BAR_LABEL),
            type = "toggle",
        },
        showCoordinates = {
            name = L["Show Coordinates"],
            desc = L["SHOW_COORDINATES_DESCRIPTION"],
            type = "toggle",
        },
        allowSetCoordinates = {
            name = "Allow custom coordinates",
            desc = "Allows frames to be positioned using screen coordinates entered into text fields",
            type = "toggle",
        },
        playerFrame = {
            name = HUD_EDIT_MODE_PLAYER_FRAME_LABEL,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], HUD_EDIT_MODE_PLAYER_FRAME_LABEL),
            type = "toggle",
        },
        playerFrameResize = {
            name = L["Resize Player Frame"],
            desc = L["RESIZE_PLAYER_FRAME_DESCRIPTION"],
            type = "toggle",
        },
        mainStatusTrackingBarContainer = {
            name = HUD_EDIT_MODE_EXPERIENCE_BAR_LABEL,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], HUD_EDIT_MODE_EXPERIENCE_BAR_LABEL),
            type = "toggle",
        },
        secondaryStatusTrackingBarContainer = {
            name = HUD_EDIT_MODE_STATUS_TRACKING_BAR_LABEL:format(2),
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], HUD_EDIT_MODE_STATUS_TRACKING_BAR_LABEL:format(2)),
            type = "toggle",
        },
        menuGroup = {
            name = HUD_EDIT_MODE_MICRO_MENU_LABEL,
            type = "group",
            args = {
                menu = {
                    name = L["Menu Bar"],
                    desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], L["Menu Bar"]),
                    type = "toggle",
                },
                bags = {
                    name = BAGSLOTTEXT,
                    desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], BAGSLOTTEXT),
                    type = "toggle",
                },
                lfg = {
                    name = L["LFG Button"],
                    desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], L["LFG Button"]),
                    type = "toggle", 
                },
            },
        },
        buffFrame = {
            name = L["Buffs"],
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], L["Buffs"]),
            type = "toggle",
        },
        debuffFrame = {
            name = L["Debuffs"],
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], L["Debuffs"]),
            type = "toggle",
        },
        bonusRoll = {
            name = L["Bonus Roll"],
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], L["Bonus Roll"]),
            type = "toggle",
        },
        actionBars = {
            name = ACTIONBARS_LABEL,
            desc = L["ACTIONBARS_DESCRIPTION"],
            type = "toggle",
        },
        groupLootContainer = {
            name = L["Group Loot Container"],
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], L["Group Loot Container"]),
            type = "toggle",
        },
        auctionMultisell = {
            name = L["Auction Multisell"],
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], L["Auction Multisell"]),
            type = "toggle",
        },
        chatButtons = {
            name = L["Chat Buttons"],
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], L["Chat Buttons"]),
            type = "toggle",
        },
        backpack = {
            name = BAG_NAME_BACKPACK,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], BAG_NAME_BACKPACK),
            type = "toggle",
        },
        gameTooltip = {
            name = HUD_EDIT_MODE_HUD_TOOLTIP_LABEL,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], HUD_EDIT_MODE_HUD_TOOLTIP_LABEL),
            type = "toggle",
        },
        lossOfControl = {
            name = LOSS_OF_CONTROL,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], LOSS_OF_CONTROL),
            type = "toggle",
        },
        pet = {
            name = PET,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], PET),
            type = "toggle",
        },
        extraActionButton = {
            name = BINDING_NAME_EXTRAACTIONBUTTON1,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], BINDING_NAME_EXTRAACTIONBUTTON1),
            type = "toggle",
        },
        cooldownManager = {
            name = COOLDOWN_VIEWER_LABEL,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], COOLDOWN_VIEWER_LABEL),
            type = "toggle",
        },
        cooldownManagerReset = {
            type = "execute",
            name = L["Reset Cooldown Manager DB"],
            func = function()
                wipe(addon.db.char.EssentialCooldownViewerSpellIDs)
                wipe(addon.db.char.UtilityCooldownViewerSpellIDs)
                wipe(addon.db.char.BuffIconCooldownViewerSpellIDs)
                wipe(addon.db.char.BuffBarCooldownViewerSpellIDs)
                EssentialCooldownViewer:RefreshLayout()
                UtilityCooldownViewer:RefreshLayout()
                BuffIconCooldownViewer:RefreshLayout()
                BuffBarCooldownViewer:RefreshLayout()
            end,
        },
        durationBars = {
            name = HUD_EDIT_MODE_TIMER_BARS_LABEL,
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], HUD_EDIT_MODE_TIMER_BARS_LABEL),
            type = "toggle",
        },
        raidSizeLayoutSwitching = {
            name = "Layout Switching",
            type = "group",
            args = addon.GetLayoutChangeOptions(),
        },
        vigorBar = {
            name = "Vigor Bar",
            type = "toggle",
            desc = "Add the pre-11.2.7 Dragonriding Vigor bar"
        },
        housingControlsFrame = {
            name = BINDING_HEADER_HOUSING_SYSTEM,
            type = "toggle",
            desc = string.format(L["TOGGLE_ADDITIONAL_OPTIONS_SUPPORT_STRING"], BINDING_HEADER_HOUSING_SYSTEM),
        },
    },
}

function addon:initOptions()
    addon.db = LibStub("AceDB-3.0"):New("EditModeExpandedADB", defaults)
            
    AceConfigRegistry:RegisterOptionsTable(addonName, options)
    AceConfigDialog:AddToBlizOptions(addonName)
end
