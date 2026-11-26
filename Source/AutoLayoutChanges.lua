local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local function getLayouts()
    local result = {}
    -- keep an eye on this function, its convenient for not needing to rebuild the entire GetLayouts, but does it spread taint?
    local layouts = EditModeManagerFrame:CreateLayoutTbls()
    for _, value in ipairs(layouts) do
        result[value.index] = value.layoutInfo.layoutName
    end
    return result
end

local categoryNames = {
    L["Solo"],
    L["Party"],
    RAID,
}

local categoryCodes = {
    "solo",
    "party",
    "raid",
}

local function getSelectedDB(selectedCategory, selectedSize, selectedResolution, specid)
    if selectedResolution == 0 then
        if selectedCategory == 3 then
            return addon.db.char.AutoLayoutSwitching[specid.."raid"..selectedSize]
        else
            return addon.db.char.AutoLayoutSwitching[specid..categoryCodes[selectedCategory]]
        end
    else
        if selectedCategory == 3 then
            return addon.db.char.AutoLayoutSwitching[specid.."res"..selectedResolution.."raid"..selectedSize]
        else
            return addon.db.char.AutoLayoutSwitching[specid.."res"..selectedResolution..categoryCodes[selectedCategory]]
        end
    end
end

local function setSelectedDB(selectedCategory, selectedSize, selectedResolution, specid, value)
    if selectedResolution == 0 then
        if selectedCategory == 3 then
            addon.db.char.AutoLayoutSwitching[specid.."raid"..selectedSize] = value
        else
            addon.db.char.AutoLayoutSwitching[specid..categoryCodes[selectedCategory]] = value
        end
    else
        if selectedCategory == 3 then
            addon.db.char.AutoLayoutSwitching[specid.."res"..selectedResolution.."raid"..selectedSize] = value
        else
            addon.db.char.AutoLayoutSwitching[specid.."res"..selectedResolution..categoryCodes[selectedCategory]] = value
        end
    end
end

local function getResolution()
    local x, y = GetCurrentScaledResolution()
    if issecretvalue(x) then return end
    if not x then return end
    return x.."x"..y
end

local function getResolutions()
    return {
        [0] = ALL,
        [getResolution()] = getResolution(),
    }
end

function addon.GetLayoutChangeOptions()
    local options = {}
    options.description = {
        name = L["AUTO_LAYOUT_CHANGE_DESCRIPTION"],
        type = "description",
        fontSize = "medium",
        order = 0,
    }
    options.enabled = {
        name = VIDEO_OPTIONS_ENABLED,
        type = "toggle",
        get = function(_) return addon.db.global.EMEOptions.raidSizeLayoutSwitching end,
        set = function(_, value) addon.db.global.EMEOptions.raidSizeLayoutSwitching = value end,
        order = 1,
        width = "full",
    }
    
    local order = 2
    for specIndex = 1, 4 do
        options["row"..specIndex] = {
            type = "group",
            args = {},
            width = "full",
            inline = true,
            name = "",
            hidden = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                if specid and (specid ~= 0) then
                    return false
                end
                return true
            end,
            order = order,
        }
        order = order + 1
        local selectedCategory = 1
        local selectedSize = 1
        local selectedResolution = 0
        
        options["row"..specIndex].args["spec"..specIndex.."category"] = {
            name = function()
                local _, specName = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                if specName then
                    return L["AUTO_LAYOUT_CHANGES_SPECNAME_GROUP_TYPE"]:format(specName)
                end
                return NOT_APPLICABLE
            end,
            type = "select",
            values = categoryNames,
            hidden = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                if specid and (specid ~= 0) then
                    return false
                end
                return true
            end,
            set = function(_, value)
                selectedCategory = value
            end,
            get = function()
                return selectedCategory
            end,
            width = 0.8,
            order = 1,
        }
        
        options["row"..specIndex].args["spec"..specIndex.."size"] = {
            name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_RAID_SIZE,
            desc = L["AUTO_LAYOUT_CHANGES_RAID_SIZE_OPTION_DESC"],
            type = "range",
            min = 1,
            max = 40,
            step = 1,
            set = function(_, value)
                selectedSize = value
            end,
            get = function()
                return selectedSize
            end,
            width = 0.9,
            disabled = function()
                return selectedCategory ~= 3
            end,
            hidden = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                if specid and (specid ~= 0) then
                    return false
                end
                return true
            end,
            order = 2,
        }
        
        options["row"..specIndex].args["spec"..specIndex.."resolution"] = {
            name = RESOLUTION,
            type = "select",
            values = getResolutions,
            hidden = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                if specid and (specid ~= 0) then
                    return false
                end
                return true
            end,
            order = 3,
            set = function(_, value)
                selectedResolution = value
            end,
            get = function()
                return selectedResolution
            end,
            width = 0.6,
        }
        
        options["row"..specIndex].args["spec"..specIndex.."layout"] = {
            name = HUD_EDIT_MODE_LAYOUT,
            type = "select",
            values = getLayouts,
            hidden = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                if specid and (specid ~= 0) then
                    return false
                end
                return true
            end,
            order = 4,
            set = function(_, value)
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                setSelectedDB(selectedCategory, selectedSize, selectedResolution, specid, value)
            end,
            get = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                return getSelectedDB(selectedCategory, selectedSize, selectedResolution, specid)
            end,
            width = 0.6,
        }
        
        options["row"..specIndex].args["spec"..specIndex.."redx"] = {
            name = "",
            type = "execute",
            func = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                setSelectedDB(selectedCategory, selectedSize, selectedResolution, specid)
            end,
            image = "interface/auctionframe/auctionhouse.blp",
            order = 5,
            width = 0.2,
            imageCoords = {963/1024, 1009/1024, 1/1024, 47/1024},
            imageWidth = 23,
            imageHeight = 23,
            hidden = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                if specid and (specid ~= 0) then
                    return false
                end
                return true
            end,
        }
    end
    
    options.resolutionDescription = {
        name = L["AUTO_LAYOUT_CHANGE_RESOLUTION_DESCRIPTION"],
        type = "description",
        fontSize = "medium",
        order = order,
    }
    order = order + 1
    
    local selectedResolution = getResolution()
    options.resolutionGenericCategory = {
        name = RESOLUTION,
        type = "select",
        values = function()
            local db = addon.db.char.AutoLayoutSwitching
            local result = {
                [getResolution()] = getResolution()
            }
            if db then
                for key in pairs(db) do
                    local resolution = string.match(key, "^res(.+)")
                    if resolution and (resolution ~= getResolution()) then
                        result[resolution] = resolution
                    end
                end
            end
            return result
        end,
        order = order,
        set = function(_, value)
            selectedResolution = value
        end,
        get = function()
            return selectedResolution
        end,
        width = 1,
    }
    order = order + 1
    
    options.resolutionGenericValue = {
        name = HUD_EDIT_MODE_LAYOUT,
        type = "select",
        values = getLayouts,
        order = order,
        set = function(_, value)
            addon.db.char.AutoLayoutSwitching["res"..selectedResolution] = value
        end,
        get = function()
            return addon.db.char.AutoLayoutSwitching["res"..selectedResolution]
        end,
        width = 1,
    }
    order = order + 1
    
    options.resolutionGenericRedX = {
        name = "",
        type = "execute",
        func = function()
            addon.db.char.AutoLayoutSwitching["res"..selectedResolution] = nil
        end,
        image = "interface/auctionframe/auctionhouse.blp",
        order = order,
        width = 0.2,
        imageCoords = {963/1024, 1009/1024, 1/1024, 47/1024},
        imageWidth = 23,
        imageHeight = 23,
    }
    
    return options
end

local function getCurrentSetting(categoryIndex)
    local specIndex = C_SpecializationInfo.GetSpecialization()
    local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
    local categoryCode = categoryCodes[categoryIndex]
    local raidSize = GetNumGroupMembers()
    local resolution = getResolution()
    
    if categoryIndex == 3 then
        for i = raidSize, 1, -1 do
            local db = addon.db.char.AutoLayoutSwitching[specid.."res"..resolution..categoryCode..i]
            if db then return db end
            db = addon.db.char.AutoLayoutSwitching[specid..categoryCode..i]
            if db then return db end
        end
        return addon.db.char.AutoLayoutSwitching["res"..resolution]
    end
    return addon.db.char.AutoLayoutSwitching[specid.."res"..resolution..categoryCode] or addon.db.char.AutoLayoutSwitching[specid..categoryCode] or addon.db.char.AutoLayoutSwitching["res"..resolution]
end

local function updateSetting(categoryIndex)
    local currentSetting = getCurrentSetting(categoryIndex)
    if currentSetting then
        if C_EditMode.GetLayouts().activeLayout == currentSetting then return end
        C_EditMode.SetActiveLayout(currentSetting)
    end
end

local function updateLayoutChoice()
    if not addon.db.global.EMEOptions.raidSizeLayoutSwitching then return end
    if C_SpecializationInfo.GetSpecialization() == 0 then return end
    
    if not IsInGroup() then
        updateSetting(1)
        return
    end
    
    if not IsInRaid() then
        updateSetting(2)
        return
    end
    
    updateSetting(3)
end

local function updateLayoutChoiceDelayed()
    C_Timer.After(2, updateLayoutChoice)
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", updateLayoutChoice)
EventRegistry:RegisterFrameEventAndCallback("GROUP_ROSTER_UPDATE", updateLayoutChoice)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", updateLayoutChoice)
EventRegistry:RegisterFrameEventAndCallback("TRAIT_CONFIG_UPDATED", updateLayoutChoiceDelayed)
EventRegistry:RegisterFrameEventAndCallback("ACTIVE_TALENT_GROUP_CHANGED", updateLayoutChoiceDelayed)
EventRegistry:RegisterFrameEventAndCallback("DISPLAY_SIZE_CHANGED", updateLayoutChoice)