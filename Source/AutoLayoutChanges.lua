local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local function getLayouts()
    local result = {}
    -- keep an eye on this function, its convenient for not needing to rebuild the entire GetLayouts, but does it spread taint?
    local layouts = EditModeManagerFrame:CreateLayoutTbls()
    for key, value in ipairs(layouts) do
        result[value.index] = value.layoutInfo.layoutName
    end
    return result
end

local categoryNames = {
    L["Solo"],
    L["Party"],
    L["Raid (5)"],
    L["Raid (10)"],
    L["Raid (25)"],
    L["Raid (40)"],
}

local categoryCodes = {
    "solo",
    "party",
    "raid5",
    "raid10",
    "raid25",
    "raid40",
}

function addon.GetLayoutChangeOptions()
    local options = {}
    options.description = {
        name = L["AUTO_LAYOUT_CHANGE_DESCRIPTION"],
        type = "description",
        fontSize = "medium",
        order = 0,
    }
    options.enabled = {
        name = "Enabled",
        type = "toggle",
        get = function(info) return addon.db.global.EMEOptions.raidSizeLayoutSwitching end,
        set = function(info, value) addon.db.global.EMEOptions.raidSizeLayoutSwitching = value end,
        order = 1,
        width = "full",
    }
    
    local order = 2
    for specIndex = 1, 4 do
        local selectedCategory = 1
        
        options["spec"..specIndex.."category"] = {
            name = function()
                local _, specName = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                if specName then
                    return specName .. " - Group Type"
                end
                return "N/A"
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
            order = order,
            set = function(info, value)
                selectedCategory = value
            end,
            get = function(info)
                return selectedCategory
            end,
        }
        order = order + 1
        
        options["spec"..specIndex.."layout"] = {
            name = function()
                return categoryNames[selectedCategory]
            end,
            type = "select",
            values = getLayouts,
            hidden = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                if specid and (specid ~= 0) then
                    return false
                end
                return true
            end,
            order = order,
            set = function(info, value)
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                addon.db.char.AutoLayoutSwitching[specid..categoryCodes[selectedCategory]] = value
            end,
            get = function(info)
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                return addon.db.char.AutoLayoutSwitching[specid..categoryCodes[selectedCategory]]
            end,
        }
        order = order + 1
        
        options["spec"..specIndex.."redx"] = {
            name = "",
            type = "execute",
            func = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                addon.db.char.AutoLayoutSwitching[specid..categoryCodes[selectedCategory]] = nil
            end,
            image = "interface/auctionframe/auctionhouse.blp",
            order = order,
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
        order = order + 1
    end
    return options
end

local function getCurrentSetting(categoryIndex)
    local specIndex = C_SpecializationInfo.GetSpecialization()
    local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
    local categoryCode = categoryCodes[categoryIndex]
    
    return addon.db.char.AutoLayoutSwitching[specid..categoryCode]
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
    
    local raidSize = GetNumGroupMembers()
    if raidSize < 6 then
        updateSetting(3)
        return
    end
    
    if raidSize < 11 then
        updateSetting(4)
        return
    end
    
    if raidSize < 26 then
        updateSetting(5)
        return
    end
    
    updateSetting(6)
end

local function updateLayoutChoiceDelayed()
    C_Timer.After(2, updateLayoutChoice)
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", updateLayoutChoice)
EventRegistry:RegisterFrameEventAndCallback("GROUP_ROSTER_UPDATE", updateLayoutChoice)
EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_ENABLED", updateLayoutChoice)
EventRegistry:RegisterFrameEventAndCallback("TRAIT_CONFIG_UPDATED", updateLayoutChoiceDelayed)
EventRegistry:RegisterFrameEventAndCallback("ACTIVE_TALENT_GROUP_CHANGED", updateLayoutChoiceDelayed)