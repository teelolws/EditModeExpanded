local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local libDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function addon.registerAnchorToDropdown(frame)        
    local dropdown, getSettingDB = lib:RegisterDropdown(frame, libDD, "AnchorToDropdown")
    
    local function updateFrameAnchor()
        if InCombatLockdown() then return end
        local db = getSettingDB()
        if db.checked then
            lib:ReanchorFrame(frame, _G[db.checked], "BOTTOMLEFT")
        end
    end
    
    libDD:UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local db = getSettingDB()
        local info = libDD:UIDropDownMenu_CreateInfo()        
        
        for _, f in ipairs(EditModeManagerFrame.registeredSystemFrames) do
            if frame ~= f then
                info.text = f:GetName()
                info.checked = db.checked == f:GetName()
                info.func = function()
                    if db.checked == f:GetName() then
                        db.checked = nil
                    else
                        db.checked = f:GetName()
                    end
                    updateFrameAnchor()
                end
                libDD:UIDropDownMenu_AddButton(info)
            end
        end
    end)
    libDD:UIDropDownMenu_SetWidth(dropdown, 100)
    libDD:UIDropDownMenu_SetText(dropdown, L["Anchor To:"])
    
    EventRegistry:RegisterCallback("EDIT_MODE_LAYOUTS_UPDATED", updateFrameAnchor)
    updateFrameAnchor()
    if frame.EMEResetButton then
        frame.EMEResetButton:HookScript("OnClick", function()
            local db = getSettingDB()
            db.checked = false
        end)
    end
end
