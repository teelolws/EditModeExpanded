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

local function getSelectedDB(selectedCategory, selectedSize, specid)
    if selectedCategory == 3 then
        return addon.db.char.AutoLayoutSwitching[specid.."raid"..selectedSize]
    else
        return addon.db.char.AutoLayoutSwitching[specid..categoryCodes[selectedCategory]]
    end
end

local function setSelectedDB(selectedCategory, selectedSize, specid, value)
    if selectedCategory == 3 then
        addon.db.char.AutoLayoutSwitching[specid.."raid"..selectedSize] = value
    else
        addon.db.char.AutoLayoutSwitching[specid..categoryCodes[selectedCategory]] = value
    end
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
        name = "Enabled",
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
        }
        local selectedCategory = 1
        local selectedSize = 1
        
        options["row"..specIndex].args["spec"..specIndex.."category"] = {
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
            set = function(_, value)
                selectedCategory = value
            end,
            get = function()
                return selectedCategory
            end,
            width = 0.8,
        }
        order = order + 1
        
        options["row"..specIndex].args["spec"..specIndex.."size"] = {
            name = "Group Size",
            desc = "You do not need to set a profile for every size, the next-smallest size will be used if nothing is set!",
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
            order = order,
        }
        order = order + 1
        
        options["row"..specIndex].args["spec"..specIndex.."layout"] = {
            name = "Selected Layout",
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
            set = function(_, value)
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                setSelectedDB(selectedCategory, selectedSize, specid, value)
            end,
            get = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                return getSelectedDB(selectedCategory, selectedSize, specid)
            end,
            width = 0.6,
        }
        order = order + 1
        
        options["row"..specIndex].args["spec"..specIndex.."redx"] = {
            name = "",
            type = "execute",
            func = function()
                local specid = C_SpecializationInfo.GetSpecializationInfo(specIndex)
                setSelectedDB(selectedCategory, selectedSize, specid)
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
    local raidSize = GetNumGroupMembers()
    
    if categoryIndex ==  3 then
        for i = raidSize, 1, -1 do
            local db = addon.db.char.AutoLayoutSwitching[specid..categoryCode..i]
            if db then return db end
        end
        return nil
    end
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