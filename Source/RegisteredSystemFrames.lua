local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initSystemFrames()
    local db = addon.db.global
        
    for _, frame in ipairs(EditModeManagerFrame.registeredSystemFrames) do
        local name = frame:GetName()
        
        -- Backward compatibility: frame name was changed from MicroMenu to MicroMenuContainer in 10.1
        if name == "MicroMenuContainer" then
            if db["MicroMenu"] and (not db[name]) then
                db[name] = db["MicroMenu"]
                db["MicroMenu"] = nil
            end
        end
        
        if not db[name] then db[name] = {} end
        lib:RegisterFrame(frame, "", db[name])
    end
    
    -- The earlier RegisterFrame will :SetShown(true) the TalkingHeadFrame if it was set to Hide then unset.
    -- Since its actually not normally shown on login, we will immediately re-hide it again.
    TalkingHeadFrame:Hide()
end

local function getToggleInCombatText(hidden)
    if hidden then
        return L["Toggle(Show) During Combat"]
    else
        return L["Toggle(Hide) During Combat"]
    end
end
    
local actionbars = {[MainMenuBar]=true, [MultiBarBottomLeft]=true, [MultiBarBottomRight]=true, [MultiBarRight]=true, [MultiBarLeft]=true, [MultiBar5]=true, [MultiBar6]=true, [MultiBar7]=true}
function addon:registerSecureFrameHideable(frame)
    local hidden, toggleInCombat, x, y
    local override
    
    local function hide()
        if not x then
            x, y = frame:GetLeft(), frame:GetBottom()
        end
        frame:ClearAllPoints()
        frame:SetClampedToScreen(false)
        frame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", -1000, -1000)
    end
    
    local function show()
        if not x then return end
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
        x, y = nil, nil
    end
    
    EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_REGEN_ENABLED", function()
        if override then
            override = false
            if hidden then hide() end
        end
        
        if not toggleInCombat then return end
        if hidden then
            hide()
        else
            show()
        end
    end)
    EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_REGEN_DISABLED", function()
        if not toggleInCombat then return end
        if hidden then
            show()
        else
            hide()
        end
    end)
    
    -- The position of some frames reset to default when spec is changed
    -- Lets reset it back to the saved spot so we can shove it back off screen again
    EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_TALENT_UPDATE", function()
        RunNextFrame(function()
            if hidden then
                show()
                hide()
            end
        end)
    end)
    
    local onResetFunctionHide = lib:RegisterCustomCheckbox(frame, HIDE,
        function()
            hidden = true
            if not EditModeManagerFrame.editModeActive then
                hide()
            end
        end,
        function()
            hidden = false
            show()
        end,
        "HidePermanently")
    
    local onResetFunctionToggle = lib:RegisterCustomCheckbox(frame, function() return getToggleInCombatText(hidden) end,
        function()
            toggleInCombat = true
        end,
        function()
            toggleInCombat = false
        end,
        "ToggleInCombat")
    
    hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function()
        if InCombatLockdown() then return end
        show()
    end)
    
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
        if InCombatLockdown() then return end
        if hidden then
            hide()
        end
    end)
    
    hooksecurefunc(frame, "Show", function()
        if InCombatLockdown() then return end
        if EditModeManagerFrame.editModeActive then return end
        if override then return end
        if hidden then hide() end
    end)
    
    hooksecurefunc(frame, "SetShown", function()
        if InCombatLockdown() then return end
        if override then return end
        if hidden then hide() end
    end)
    
    if frame.EMEResetButton then
        frame.EMEResetButton:HookScript("OnClick", function()
            hidden = false
            toggleInCombat = false
            onResetFunctionHide()
            onResetFunctionToggle()
        end)
    end
    
    if actionbars[frame] then
        EventUtil.ContinueOnAddOnLoaded("Blizzard_PlayerSpells", function()
            hooksecurefunc(PlayerSpellsFrame, "Show", function()
                if InCombatLockdown() then return end
                if EditModeManagerFrame.editModeActive then return end
                override = true
                if hidden then show() end
            end)
            
            hooksecurefunc(PlayerSpellsFrame, "Hide", function()
                if InCombatLockdown() then return end
                if EditModeManagerFrame.editModeActive then return end
                override = false
                if hidden then hide() end
            end)
        end)
    end
    
    return function()
            return ( hidden and (not toggleInCombat) ) or ( hidden and toggleInCombat and (not InCombatLockdown()) ) or ( (not hidden) and toggleInCombat and InCombatLockdown() )
        end
end

-- Reparents the class resource to UIParent so player can move it independently of the player frame, and can hide the player frame without hiding the class resource

-- See ClassPowerBar.lua\ClassPowerBar:GetUnit() for why I do this parentparent nonsense:
local parentparent = CreateFrame("Frame", nil, UIParent)
local parent = CreateFrame("Frame", nil, parentparent)

function addon.unlinkClassResourceFrame(frame)
    lib:RegisterCustomCheckbox(frame, L["UNLINK_CLASS_RESOURCE_DESCRIPTION"], 
        --onChecked
        function()
            frame:SetParent(parent)
        end,
        --onUnchecked
        function()
            frame:SetParent(PlayerFrameBottomManagedFramesContainer)
        end
    )
end