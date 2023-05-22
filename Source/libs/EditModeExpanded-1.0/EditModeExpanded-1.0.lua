--
-- Internal variables
--

local MAJOR, MINOR = "EditModeExpanded-1.0", 66
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

-- the internal frames provided by Blizzard go up to index 16. They reference Enum.EditModeSystem, which starts from index 0
local STARTING_INDEX = 17
local index = STARTING_INDEX
local frames = {}
local baseFramesDB = {} -- the base db that includes all profiles inside
local framesDB = {} -- the currently selected db inside the profile
local framesDialogs = {}
local framesDialogsKeys = {}
local existingFrames = {} -- frames already part of Edit Mode where we are adding more options
local firstCheckButtonPlaced = false

local ENUM_EDITMODEACTIONBARSETTING_HIDEABLE = 10 -- Enum.EditModeActionBarSetting.Hideable = 10
local ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED = 11
local ENUM_EDITMODEACTIONBARSETTING_CUSTOM = 12
local ENUM_EDITMODEACTIONBARSETTING_CLAMPED = 13
local ENUM_EDITMODEACTIONBARSETTING_HIDDENINCOMBAT = 14

-- run OnLoad the first time RegisterFrame is called by an addon
local f = lib.internalOnLoadFrame or {}
lib.internalOnLoadFrame = f
function f.OnLoad() f.OnLoad = nil end

-- some caching tables, save the state of frames just before entering Edit Mode
local wasVisible = {}
local originalSize = {}
local defaultSize = {}

local profilesInitialised

-- Custom version of FrameXML\Mixin.lua where I instead do *not* overwrite existing functions 
local function Mixin(object, ...)
    for i = 1, select("#", ...) do
        local mixin = select(i, ...);
        for k, v in pairs(mixin) do
            if not object[k] then
                object[k] = v;
            end
        end
    end

    return object;
end

-- functions declared further down
local pinToMinimap
local unpinFromMinimap
local getOffsetXY
local registerFrameMovableWithArrowKeys

local function getSystemID(frame)
    if not frame.system then return false end
    if frame.system < STARTING_INDEX then
        return frame.EMESystemID
    end
    return frame.system
end

--
-- Code to deal with splitting the Main Menu Bar from the Backpack bar
--

-- from FrameXML\MainMenuBarMicroButtons.lua 
local MICRO_BUTTONS = {
    "CharacterMicroButton",
    "SpellbookMicroButton",
    "TalentMicroButton",
    "AchievementMicroButton",
    "QuestLogMicroButton",
    "GuildMicroButton",
    "LFDMicroButton",
    "EJMicroButton",
    "CollectionsMicroButton",
    "MainMenuMicroButton",
    "HelpMicroButton",
    "StoreMicroButton",
    }

--
-- Public API
--

-- Call this on a frame to register it for capture during Edit Mode
-- param1: frame, the Frame to register
-- param2: name, localized name to appear when the frame is selected during Edit Mode
-- param3: db, a table in your saved variables to save the frame position in
-- param4: frame to anchor to, default is UIParent
-- param5: point to anchor, default is BOTTOMLEFT
function lib:RegisterFrame(frame, name, db, anchorTo, anchorPoint)
    assert(type(frame) == "table")
    assert(type(name) == "string")
    assert(type(db) == "table")
    
    if not anchorTo then anchorTo = UIParent end
    if not anchorPoint then anchorPoint = "BOTTOMLEFT" end
    frame.EMEanchorTo = anchorTo
    frame.EMEanchorPoint = anchorPoint
    
    -- if this is the first frame being registered, load the other parts of this library
    if f.OnLoad then f.OnLoad() end
    
    local baseDB = db
    
    -- If the frame was already registered (perhaps by another addon that uses this library), don't register it again
    for _, f in ipairs(frames) do
        if frame == f then
            if (not framesDB[f.system].x) and (not framesDB[f.system].y) then
                -- import new db settings if there are none saved in the existing db
                framesDB[f.system].x = db.x
                framesDB[f.system].y = db.y
                local x, y = getOffsetXY(frame, db.x, db.y)
                f:SetPoint(anchorPoint, anchorTo, anchorPoint, x, y)
            end
            return
        end
    end
    
    local systemID = frame.system
    
    -- frame is an existing Edit Mode frame by Blizzard, handle it differently
    if systemID then
        if existingFrames[frame:GetName()] then return end
        existingFrames[frame:GetName()] = true
        
        systemID = index
        index = index + 1
        frame.EMESystemID = systemID
        baseFramesDB[systemID] = baseDB
        framesDB[systemID] = db
        hooksecurefunc(frame, "SelectSystem", function()
            if framesDialogs[systemID] then
                EditModeExpandedSystemSettingsDialog:AttachToSystemFrame(frame)
            end
        end)
        registerFrameMovableWithArrowKeys(frame, anchorPoint, anchorTo)
        
        frame.Selection:HookScript("OnDragStop", function(self)
            EditModeExpandedSystemSettingsDialog:UpdateSettings(frame)
        end)
        
        return
    end
    
    if profilesInitialised then
        local layoutInfo = EditModeManagerFrame:GetActiveLayoutInfo()
        local profileName = layoutInfo.layoutType.."-"..layoutInfo.layoutName
        if layoutInfo.layoutType == Enum.EditModeLayoutType.Character then
            local unitName, unitRealm = UnitFullName("player")
            profileName = layoutInfo.layoutType.."-"..unitName.."-"..unitRealm.."-"..layoutInfo.layoutName
        end
        
        if not db.profiles then db.profiles = {} end
        if not db.profiles[profileName] then
            db.profiles[profileName] = {}
            db.profiles[profileName].x = db.x
            db.profiles[profileName].y = db.y
            db.profiles[profileName].enabled = db.enabled
            db.profiles[profileName].settings = db.settings
            db.profiles[profileName].defaultX = db.defaultX
            db.profiles[profileName].defaultY = db.defaultY
            
            db.x = nil
            db.y = nil
            db.enabled = nil
            db.settings = nil
        end
        
        db = db.profiles[profileName]
    end
     
    table.insert(frames, frame)
    
    Mixin(frame, EditModeSystemMixin)
    
    frame.system = index
    index = index + 1
    baseFramesDB[frame.system] = baseDB 
    framesDB[frame.system] = db

    db.defaultScale = frame:GetScale()
    db.defaultX, db.defaultY = frame:GetRect()
    
    -- needs investigation: why does this frame behave 'weirdly' if default scale 1 is not set?
    if frame == FocusFrameSpellBar then
        if not db.settings then db.settings = {} end
        if not db.settings[Enum.EditModeUnitFrameSetting.FrameSize] then
            db.settings[Enum.EditModeUnitFrameSetting.FrameSize] = 100
        end
    end

    frame.Selection = CreateFrame("Frame", nil, frame, "EditModeSystemSelectionTemplate")
    frame.Selection:SetAllPoints(frame)
    frame.defaultHideSelection = true
    frame.Selection:Hide()
    
    frame.systemNameString = name
    frame.Selection:SetGetLabelTextFunction(function() return name end)
    frame:SetupSettingsDialogAnchor();
    frame.snappedFrames = {};
    registerFrameMovableWithArrowKeys(frame, anchorPoint, anchorTo)
    
    -- prevent the frame from going outside the screen boundaries
    if db.clamped == nil then db.clamped = 1 end
    if profilesInitialised and (db.clamped == 1) then
        frame:SetClampedToScreen(true)
    elseif profilesInitialised then
        frame:SetClampedToScreen(false)
    end
    if not framesDialogs[frame.system] then framesDialogs[frame.system] = {} end
    if not framesDialogsKeys[frame.system] then framesDialogsKeys[frame.system] = {} end
    framesDialogsKeys[frame.system][ENUM_EDITMODEACTIONBARSETTING_CLAMPED] = true
    table.insert(framesDialogs[frame.system],
        {
            setting = ENUM_EDITMODEACTIONBARSETTING_CLAMPED,
            name = "Clamp to Screen",
            type = Enum.EditModeSettingDisplayType.Checkbox,
        }
    )
    
    function frame.UpdateMagnetismRegistration() end

    frame.Selection:SetScript("OnMouseDown", function()
        frame:SelectSystem()
    end)
    
    function frame:SelectSystem()
        if not self.isSelected then
            self:SetMovable(true);
            self.Selection:ShowSelected();
            self.isSelected = true;
            if framesDialogs[self.system] then
                EditModeManagerFrame:ClearSelectedSystem()  -- needs further taint testing; disable if there are issues
                EditModeExpandedSystemSettingsDialog:AttachToSystemFrame(self)
            else
                EditModeExpandedSystemSettingsDialog:Hide()
            end
        end
        for _, f in ipairs(frames) do
            if f ~= frame then
                f:HighlightSystem()
            end
        end
    end
    
    frame.Selection:SetScript("OnDragStop", function(self)
        if frame:CanBeMoved() then
            frame:StopMovingOrSizing();
        end
        local db = framesDB[frame.system]
        db.x, db.y = self:GetRect()
        
        local x, y = getOffsetXY(frame, db.x, db.y)
        frame:ClearAllPoints()
        frame:SetPoint(anchorPoint, anchorTo, anchorPoint, x, y)
        
        EditModeExpandedSystemSettingsDialog:UpdateSettings(frame)
    end)
    
    function frame:ClearHighlight()
        if self.isSelected then
            self.isSelected = false;
        end
    
        self.Selection:Hide();
        self.isHighlighted = false;
    end
    
    function frame:SetHasActiveChanges(hasActiveChanges)
        self.hasActiveChanges = hasActiveChanges;
    end

    EditModeManagerExpandedFrame.AccountSettings[frame.system] = CreateFrame("CheckButton", nil, EditModeManagerExpandedFrame.AccountSettings, "UICheckButtonTemplate")
    local checkButtonFrame = EditModeManagerExpandedFrame.AccountSettings[frame.system]
    frame.EMECheckButtonFrame = checkButtonFrame
    local resetButton = CreateFrame("Button", nil, EditModeManagerFrame, "UIPanelButtonTemplate")
    resetButton:SetText(RESET)
    resetButton:SetPoint("TOPLEFT", checkButtonFrame.Text, "TOPRIGHT", 20, 2)
    resetButton:SetScript("OnClick", function()
        local db = framesDB[frame.system]
        frame:ClearAllPoints()
        frame:SetScaleOverride(1)
        if not db.defaultX then db.defaultX = 0 end
        if not db.defaultY then db.defaultY = 0 end
        local x, y = getOffsetXY(frame, db.defaultX, db.defaultY)
        if not pcall( function() frame:SetPoint(anchorPoint, anchorTo, anchorPoint, x, y) end ) then
            -- need a better solution here
            frame:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", x, y)
        end
        
        db.x = db.defaultX
        db.y = db.defaultY
        if not db.settings then db.settings = {} end
        db.settings[Enum.EditModeUnitFrameSetting.FrameSize] = 100
        EditModeExpandedSystemSettingsDialog:Hide()
        frame:HighlightSystem()
    end)
    
    EditModeManagerExpandedFrame:HookScript("OnHide", function()
        resetButton:Hide()
    end)
    
    EditModeManagerExpandedFrame:HookScript("OnShow", function()
        resetButton:Show()
    end)
    
    checkButtonFrame:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        local db = framesDB[frame.system]
        db.enabled = isChecked
        frame:SetShown(isChecked)
    end)
    
    checkButtonFrame.Text:SetText(name)
    checkButtonFrame.Text:SetFontObject(GameFontHighlightMedium)
    
    checkButtonFrame.index = frame.system
    if not firstCheckButtonPlaced then
        firstCheckButtonPlaced = true
        checkButtonFrame:SetPoint("TOPLEFT", EditModeManagerExpandedFrame.AccountSettings, "TOPLEFT", 20, 0)
        checkButtonFrame:SetSize(32, 32)
    else
        -- some system IDs may be existing edit mode frames which were not assigned a checkbox
        local previousSystemID = frame.system - 1
        local i = 1
        while not EditModeManagerExpandedFrame.AccountSettings[previousSystemID] do
            i = i + 1
            previousSystemID = frame.system - i
        end
        checkButtonFrame:SetPoint("TOPLEFT", EditModeManagerExpandedFrame.AccountSettings[previousSystemID], "BOTTOMLEFT", 0, 10)
        checkButtonFrame:SetSize(32, 32)
    end
    
    if db.enabled == nil then db.enabled = true end
    checkButtonFrame:SetChecked(db.enabled)
    
    function frame:GetSettingValue(setting, useRawValue)
        local db = framesDB[frame.system]
        if (not self:IsInitialized()) or (not db.settings) or (not db.settings[setting]) then
            return 0;
        end
        return db.settings[setting]
    end
    
    function frame:SetScaleOverride(newScale)
        local oldScale = self:GetScale();
    
        self:SetScale(newScale);
    
        if oldScale == newScale then
            return;
        end
    
        -- Update position to try and keep the system frame in the same position since scale changes how offsets work
        local numPoints = self:GetNumPoints();
        for i = 1, numPoints do
            local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint(i);
    
            -- Undo old scale adjustment so we're working with 1.0 scale offsets
            -- Then apply the newScale adjustment
            offsetX = offsetX * oldScale / newScale;
            offsetY = offsetY * oldScale / newScale;
            self:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
        end
    end
    
    if db.settings and db.settings[Enum.EditModeUnitFrameSetting.FrameSize] then
        frame:SetScaleOverride(db.settings[Enum.EditModeUnitFrameSetting.FrameSize]/100)
    end
    
    if db.x and db.y then
        if (frame:GetScale() == 1) and (anchorTo == UIParent) and (anchorPoint == "TOPLEFT") then
            -- if stored coordinates are outside the screen resolution, reset them back to defaults
            local _, _, screenX, screenY = UIParent:GetRect()
            if (db.x < 0) or (db.x >= screenX) or (db.y < 0) or (db.y > screenY) then
                db.x, db.y = frame:GetRect()
            end
        end 
        frame:ClearAllPoints()
        local x, y = getOffsetXY(frame, db.x, db.y)
        frame:SetPoint(anchorPoint, anchorTo, anchorPoint, x, y)
    else
        db.x, db.y = frame:GetRect()
    end
    
    if db.settings and (db.settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= nil) then
        frame:SetShown(framesDB[frame.system].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= 1)
    end
    
    hooksecurefunc(frame, "AddExtraButtons", function(self)
        self.resetToDefaultPositionButton:SetOnClickHandler(function()
            resetButton:Click()
        end)
    end)
end

-- use this if a frame by default doesn't have a size set yet
function lib:SetDefaultSize(frame, x, y)
    assert(type(frame) == "table")
    assert(type(x) == "number")
    assert(type(y) == "number")
    
    defaultSize[frame.system] = {["x"] = x, ["y"] = y}
end

-- use this for small frames - frames that have a dimension < 40, that you don't want to be bumped up to 40 during Edit Mode
function lib:SetDontResize(frame)
    assert(type(frame) == "table")
    
    frame.EMEDontResize = true
end

-- call this if the frame needs to be moved back into position at some point after ADDON_LOADED
function lib:RepositionFrame(frame)
    assert(type(frame) == "table")
    assert(frame.system > 12)
    
    local systemID = getSystemID(frame)
    local db = framesDB[systemID]
    
    if (not (db.x or db.defaultX)) or (not (db.y or db.defaultY)) or (not frame.EMEanchorTo) or (not frame.EMEanchorTo:GetRect()) then
        return
    end
    
    frame:ClearAllPoints()
    
    if db.settings and (db.settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] == 1) then
        frame:Hide()
        return
    end
    
    if db.settings and (db.settings[ENUM_EDITMODEACTIONBARSETTING_HIDDENINCOMBAT] == 1) and InCombatLockdown() then
        frame:Hide()
        return
    end
    
    local x, y = getOffsetXY(frame, db.x or db.defaultX, db.y or db.defaultY)
    local anchorPoint = frame.EMEanchorPoint
    if not pcall( function() frame:SetPoint(anchorPoint, frame.EMEanchorTo, anchorPoint, x, y) end ) then
        frame:SetPoint(anchorPoint, nil, anchorPoint, x, y)
    end
end

-- Call this to add a slider to the frames dialog box, allowing is to be resized using frame:SetScale
-- param1: an edit mode registered frame, either one already registered by Blizz, or a custom one you have registered with lib:RegisterFrame
function lib:RegisterResizable(frame)
    local systemID = getSystemID(frame)
    
    if not framesDialogs[systemID] then framesDialogs[systemID] = {} end
    if framesDialogsKeys[systemID] and framesDialogsKeys[systemID][Enum.EditModeUnitFrameSetting.FrameSize] then return end
    if not framesDialogsKeys[systemID] then framesDialogsKeys[systemID] = {} end
    framesDialogsKeys[systemID][Enum.EditModeUnitFrameSetting.FrameSize] = true
    table.insert(framesDialogs[systemID],
        {
            setting = Enum.EditModeUnitFrameSetting.FrameSize,
            name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_FRAME_SIZE,
            type = Enum.EditModeSettingDisplayType.Slider,
            minValue = 10,
            maxValue = 200,
            stepSize = 5,
            ConvertValue = ConvertValueDefault,
            formatter = showAsPercentage,
        })
end

function lib:UpdateFrameResize(frame)
    local systemID = getSystemID(frame)
    local db = framesDB[systemID]
    
    if not db.settings then db.settings = {} end
    if db.settings[Enum.EditModeUnitFrameSetting.FrameSize] ~= nil then
        frame:SetScale(db.settings[Enum.EditModeUnitFrameSetting.FrameSize]/100)
    end
end
 
-- Call this to add a checkbox to the frames dialog box, allowing the frame to be permanently hidden outside of Edit Mode
-- param1: an edit mode registered frame, either one already registered by Blizz, or a custom one you have registered with lib:RegisterFrame
function lib:RegisterHideable(frame)
    local systemID = getSystemID(frame)
    
    if not framesDialogs[systemID] then framesDialogs[systemID] = {} end
    if framesDialogsKeys[systemID] and framesDialogsKeys[systemID][ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] then return end
    if not framesDialogsKeys[systemID] then framesDialogsKeys[systemID] = {} end
    framesDialogsKeys[systemID][ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] = true
    table.insert(framesDialogs[systemID],
        {
            setting = ENUM_EDITMODEACTIONBARSETTING_HIDEABLE,
            name = "Hide",
            type = Enum.EditModeSettingDisplayType.Checkbox,
    })
end

function lib:IsFrameMarkedHidden(frame)
    local systemID = getSystemID(frame)
    
    if not framesDB[systemID].settings then framesDB[systemID].settings = {} end
    return framesDB[systemID].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] == 1
end

-- implemented further down the file
-- param1: custom system frame
--function lib:RegisterMinimapPinnable(frame)

-- a simple check of "has this frame been registered with EME" - maybe you want to test if another addon registered it already?
function lib:IsRegistered(frame)
    local systemID = getSystemID(frame)
    if not systemID or not framesDB[systemID] then return false end
    
    return true
end

-- Is the Expanded frame checkbox checked for this frame?
function lib:IsFrameEnabled(frame)
    local db = framesDB[frame.system]
    return db.enabled
end

local customCheckboxCallDuringProfileInit = {}
-- call this to register a custom checkbox where you're providing the handler
-- internalName is a name to use in the database to identify this checkbox
-- for backwards compatibility, internalName defaults to "1"
function lib:RegisterCustomCheckbox(frame, name, onChecked, onUnchecked, internalName)
    if not internalName then
        internalName = 1
    end
    
    local systemID = getSystemID(frame)
    
    if not framesDialogs[systemID] then framesDialogs[systemID] = {} end
    if not framesDialogsKeys[systemID] then framesDialogsKeys[systemID] = {} end
    if not framesDialogsKeys[systemID][ENUM_EDITMODEACTIONSBARSETTING_CUSTOM] then framesDialogsKeys[systemID][ENUM_EDITMODEACTIONBARSETTING_CUSTOM] = {} end 
    framesDialogsKeys[systemID][ENUM_EDITMODEACTIONBARSETTING_CUSTOM][internalName] = true
    
    table.insert(framesDialogs[systemID],
        {
            setting = ENUM_EDITMODEACTIONBARSETTING_CUSTOM,
            name = name,
            type = Enum.EditModeSettingDisplayType.Checkbox,
            onChecked = onChecked,
            onUnchecked = onUnchecked,
            customCheckBoxID = internalName,
    })
    
    local function callLater()
        local db = framesDB[systemID]
        if not db.settings then db.settings = {} end
        if not db.settings[ENUM_EDITMODEACTIONBARSETTING_CUSTOM] then db.settings[ENUM_EDITMODEACTIONBARSETTING_CUSTOM] = {} end
        
        -- backward compatibility
        if type(db.settings[ENUM_EDITMODEACTIONBARSETTING_CUSTOM]) == "number" then
            local old = db.settings[ENUM_EDITMODEACTIONBARSETTING_CUSTOM]
            db.settings[ENUM_EDITMODEACTIONBARSETTING_CUSTOM] = {}
            db.settings[ENUM_EDITMODEACTIONBARSETTING_CUSTOM][internalName] = old
        end
        
        if db.settings[ENUM_EDITMODEACTIONBARSETTING_CUSTOM][internalName] == 1 then
            onChecked()
        else
            onUnchecked(true)
        end
    end
    
    if profilesInitialised then
        callLater()
    else
        table.insert(customCheckboxCallDuringProfileInit, callLater)
    end
end

--
-- Code for Expanded Manager Frame here
-- This is a frame that will show checkboxes, to turn on/off all custom frames during Edit Mode
--

local function clearSelectedSystem(index, systemFrame)
    -- Only highlight a system if it was already highlighted
    if systemFrame.isHighlighted then
        systemFrame:HighlightSystem();
    end
end

hooksecurefunc(f, "OnLoad", function()
    CreateFrame("Frame", "EditModeManagerExpandedFrame", nil, UIParent)
    EditModeManagerExpandedFrame:Hide();
    EditModeManagerExpandedFrame:SetScale(UIParent:GetScale());
    EditModeManagerExpandedFrame:SetPoint("TOPLEFT", EditModeManagerFrame, "TOPRIGHT", 2, 0)
    EditModeManagerExpandedFrame:SetPoint("BOTTOMLEFT", EditModeManagerFrame, "BOTTOMRIGHT", 2, 0)
    EditModeManagerExpandedFrame:SetWidth(300)
    EditModeManagerExpandedFrame.Title = EditModeManagerExpandedFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    EditModeManagerExpandedFrame.Title:SetPoint("TOP", 0, -15)
    EditModeManagerExpandedFrame.Title:SetText("Expanded")
    EditModeManagerExpandedFrame.Border = CreateFrame("Frame", nil, EditModeManagerExpandedFrame, "DialogBorderTranslucentTemplate")
    EditModeManagerExpandedFrame.AccountSettings = CreateFrame("Frame", nil, EditModeManagerExpandedFrame)
    EditModeManagerExpandedFrame.AccountSettings:SetPoint("TOPLEFT", 0, -35)
    EditModeManagerExpandedFrame.AccountSettings:SetPoint("BOTTOMLEFT", 10, 10)
    EditModeManagerExpandedFrame.AccountSettings:SetWidth(200)
    EditModeManagerExpandedFrame.CloseButton = CreateFrame("Button", nil, EditModeManagerExpandedFrame, "UIPanelCloseButton")
    EditModeManagerExpandedFrame.CloseButton:SetPoint("TOPRIGHT")
    
    EditModeManagerFrame:HookScript("OnShow", function()
        EditModeManagerExpandedFrame:Show()
    end)
    
    EditModeManagerFrame:HookScript("OnHide", function()
        EditModeManagerExpandedFrame:Hide()
    end)
    
    function EditModeManagerExpandedFrame:ClearSelectedSystem()
        secureexecuterange(frames, clearSelectedSystem)
        EditModeExpandedSystemSettingsDialog:Hide()
    end

    hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function(self)
        -- can cause errors if the player is in combat - eg trying to move or show/hide protected frames
        if InCombatLockdown() then return end
        if not EditModeManagerExpandedFrame then return end -- happens if library is embedded but nothing has been registered
        
        if #frames <= 0 then EditModeManagerExpandedFrame:Hide() end
        for _, frame in ipairs(frames) do
            frame:SetHasActiveChanges(false)
            frame:HighlightSystem();
            wasVisible[frame.system] = frame:IsShown()
            frame:SetShown(framesDB[frame.system].enabled)
            local x, y = frame:GetSize()
            if (not frame.EMEDontResize) and ((x < 40) or (y < 40)) then
                originalSize[frame.system] = {["x"] = x, ["y"] = y}
                if defaultSize[frame.system] then
                    frame:SetSize(defaultSize[frame.system].x, defaultSize[frame.system].y)
                elseif (x < 40) and (y > 0) then
                    frame:SetSize(40, y)
                elseif (x > 0) and (y < 40) then
                    frame:SetSize(x, 40)
                else
                    frame:SetSize(40, 40)
                end
            end
        end
        
        for frameName in pairs(existingFrames) do
            local frame = _G[frameName]
            local systemID = getSystemID(frame)
            if framesDB[systemID] and framesDB[systemID].settings and (framesDB[systemID].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= nil) then
                if (framesDB[systemID].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] == 1) then
                    frame:Show()
                end
            end
        end
    end)

    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
        if InCombatLockdown() then
            print("EditModeExpanded Error: could not hide Edit Mode properly - you were in combat!")
            return
        end
        if not EditModeManagerExpandedFrame then return end -- happens if library is embedded but nothing has been registered
        
        for _, frame in ipairs(frames) do
            frame:ClearHighlight();
            frame:StopMovingOrSizing();
            
            if framesDB[frame.system] and framesDB[frame.system].settings and (framesDB[frame.system].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= nil) then
                if (framesDB[frame.system].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] == 1) then
                    frame:Hide()
                else
                    frame:SetShown(wasVisible[frame.system])
                end
            else
                frame:SetShown(wasVisible[frame.system])
            end
            
            if originalSize[frame.system] then
                frame:SetSize(originalSize[frame.system].x, originalSize[frame.system].y)
            end
        end
        
        for frameName in pairs(existingFrames) do
            local frame = _G[frameName]
            local systemID = getSystemID(frame)
            if framesDB[systemID] and framesDB[systemID].settings and (framesDB[systemID].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= nil) then
                if (framesDB[systemID].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] == 1) then
                    frame:Hide()
                end
            end
        end
        
        wipe(wasVisible)
        wipe(originalSize)
        EditModeExpandedSystemSettingsDialog:Hide()
    end)

    hooksecurefunc(EditModeManagerFrame, "SelectSystem", function(self, systemFrame)
        if EditModeExpandedSystemSettingsDialog and EditModeExpandedSystemSettingsDialog.attachedToSystem ~= systemFrame then
            EditModeExpandedSystemSettingsDialog:Hide()
        end
        
        for _, frame in ipairs(frames) do
            if systemFrame ~= frame then
                frame:HighlightSystem()
            end
        end
    end)

    --
    -- Edit Mode Dialog Box code
    --
    local frame = CreateFrame("Frame", nil, UIParent, "ResizeLayoutFrame")
    EditModeExpandedSystemSettingsDialog = frame
    Mixin(frame, EditModeSystemSettingsDialogMixin)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetDontSavePosition(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(200)
    frame:Hide()
    frame:SetSize(300, 350)
    frame:SetPoint("TOPLEFT")
    frame.widthPadding = 40
    frame.heightPadding = 40
    frame.Title = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    frame.Title:SetPoint("TOP", 0, -15)
    frame.Border = CreateFrame("Frame", nil, frame, "DialogBorderTranslucentTemplate")
    frame.Border.ignoreInLayout = true
    frame.CloseButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.CloseButton.ignoreInLayout = true
    frame.CloseButton:SetPoint("TOPRIGHT")
    frame.Settings = CreateFrame("Frame", nil, frame, "VerticalLayoutFrame")
    frame.Settings:SetSize(1, 1)
    frame.Settings.spacing = 2
    frame.Settings:SetPoint("TOP", frame.Title, "BOTTOM", 0, -12)
    frame.Buttons = CreateFrame("Frame", nil, frame, "VerticalLayoutFrame")
    frame.Buttons.spacing = 2
    frame.Buttons:SetPoint("TOPLEFT", frame.Settings, "BOTTOMLEFT", 0, -12)
    frame.Buttons.RevertChangesButton = CreateFrame("Button", nil, frame.Buttons, "EditModeSystemSettingsDialogButtonTemplate")
    frame.Buttons.RevertChangesButton:SetText(HUD_EDIT_MODE_REVERT_CHANGES)
    frame.Buttons.RevertChangesButton.layoutIndex = 1
    frame.Buttons.Divider = frame.Buttons:CreateTexture(nil, "ARTWORK")
    frame.Buttons.Divider:SetMask("Interface\FriendsFrame\UI-FriendsFrame-OnlineDivider")
    frame.Buttons.Divider:Hide()
    frame.Buttons.Divider:SetSize(330, 16)
    frame.Buttons.Divider.layoutIndex = 2
    frame:SetScript("OnLoad", frame.OnLoad)
    frame:SetScript("OnHide", frame.OnHide)
    frame:SetScript("OnDragStart", frame.OnDragStart)
    frame:SetScript("OnDragStop", frame.OnDragStop)
    frame:OnLoad()
    function frame:UpdateSizeAndAnchors(systemFrame)
        if systemFrame == self.attachedToSystem then
            frame:ClearAllPoints()
            frame:SetPoint("TOP", EditModeSystemSettingsDialog, "BOTTOM")
            self:Layout()
        else
            frame:Hide()
        end
    end
    
    -- hide the duplicate buttons we won't ever need
    frame.Buttons.RevertChangesButton:Hide()
    function frame:UpdateExtraButtons(systemFrame) -- from EditModeDialogs.lua function EditModeSystemSettingsDialogMixin:UpdateExtraButtons
        if systemFrame == self.attachedToSystem then
            self.pools:ReleaseAllByTemplate("EditModeSystemSettingsDialogExtraButtonTemplate");
            self.Buttons.Divider:SetShown(true)
        end
    end
end)

local function GetSystemSettingDisplayInfo(dialogs)
    return dialogs
end

local function showAsPercentage(value)
    local roundToNearestInteger = true;
    return FormatPercentage(value / 100, roundToNearestInteger);
end

local function ConvertValueDefault(self, value, forDisplay)
    if forDisplay then
        return self:ClampValue((value * self.stepSize) + self.minValue);
    else
        return (value - self.minValue) / self.stepSize;
    end
end

hooksecurefunc(f, "OnLoad", function()
    function EditModeExpandedSystemSettingsDialog:UpdateSettings(systemFrame)
        if systemFrame == self.attachedToSystem then
            self:ReleaseAllNonSliders();
            local draggingSlider = self:ReleaseNonDraggingSliders();
    
            local settingsToSetup = {};
            local systemID = getSystemID(self.attachedToSystem)
            
            local systemSettingDisplayInfo = GetSystemSettingDisplayInfo(framesDialogs[systemID]);
            if systemSettingDisplayInfo then
                for index, displayInfo in ipairs(systemSettingDisplayInfo) do
                      local settingPool = self:GetSettingPool(displayInfo.type);
                    if settingPool then
                        local settingFrame;
    
                        if draggingSlider and draggingSlider.setting == displayInfo.setting then
                            -- This is a slider that is being interacted with and so was not released.
                            settingFrame = draggingSlider;
                        else
                            settingFrame = settingPool:Acquire();
                        end
    
                        settingFrame:SetPoint("TOPLEFT");
                          settingFrame.layoutIndex = index;
                        
                        local settingName = (self.attachedToSystem:UseSettingAltName(displayInfo.setting) and displayInfo.altName) and displayInfo.altName or displayInfo.name;
                          local updatedDisplayInfo = self.attachedToSystem:UpdateDisplayInfoOptions(displayInfo);
                        if not framesDB[systemID].settings then framesDB[systemID].settings = {} end
                          
                        local savedValue = framesDB[systemID].settings[updatedDisplayInfo.setting]
                        
                        if displayInfo.setting == Enum.EditModeUnitFrameSetting.FrameSize then
                            savedValue = savedValue or 100
                            
                            CallbackRegistryMixin.OnLoad(settingFrame)
                
                          	local function OnValueChanged(self, value)
                                if not self.initInProgress then
                                    EditModeExpandedSystemSettingsDialog:OnSettingValueChanged(self.setting, value);
                                end
                            end
                              
                            settingFrame.cbrHandles = EventUtil.CreateCallbackHandleContainer()
                          	settingFrame.cbrHandles:RegisterCallback(settingFrame.Slider, MinimalSliderWithSteppersMixin.Event.OnValueChanged, OnValueChanged, settingFrame)
                        end
                        
                        if displayInfo.setting == ENUM_EDITMODEACTIONBARSETTING_HIDEABLE then
                            savedValue = framesDB[systemID].settings[displayInfo.setting]
                            if savedValue == nil then savedValue = 0 end
                            settingFrame.Button:SetChecked(savedValue)
                            settingFrame.Button:SetScript("OnClick", function()
                                if settingFrame.Button:GetChecked() then
                                    framesDB[systemID].settings[displayInfo.setting] = 1
                                    EditModeExpandedSystemSettingsDialog.attachedToSystem:Hide()
                                    wasVisible[systemID] = false
                                else
                                    framesDB[systemID].settings[displayInfo.setting] = 0
                                    EditModeExpandedSystemSettingsDialog.attachedToSystem:Show()
                                    wasVisible[systemID] = true
                                end
                            end)
                        end
                        
                        if displayInfo.setting == ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED then
                            savedValue = framesDB[systemID].settings[displayInfo.setting]
                            if savedValue == nil then savedValue = 0 end
                            settingFrame.Button:SetChecked(savedValue)
                            settingFrame.Button:SetScript("OnClick", function()
                                if settingFrame.Button:GetChecked() then
                                    framesDB[systemID].settings[displayInfo.setting] = 1
                                    pinToMinimap(EditModeExpandedSystemSettingsDialog.attachedToSystem)
                                else
                                    framesDB[systemID].settings[displayInfo.setting] = 0
                                    unpinFromMinimap(EditModeExpandedSystemSettingsDialog.attachedToSystem)
                                end
                            end)
                        end
                        
                        if displayInfo.setting == ENUM_EDITMODEACTIONBARSETTING_CUSTOM then
                            savedValue = framesDB[systemID].settings[displayInfo.setting][displayInfo.customCheckBoxID]
                            if savedValue == nil then savedValue = 0 end
                            settingFrame.Button:SetChecked(savedValue)
                            settingFrame.Button:SetScript("OnClick", function()
                                if settingFrame.Button:GetChecked() then
                                    framesDB[systemID].settings[displayInfo.setting][displayInfo.customCheckBoxID] = 1
                                    displayInfo.onChecked()
                                else
                                    framesDB[systemID].settings[displayInfo.setting][displayInfo.customCheckBoxID] = 0
                                    displayInfo.onUnchecked(false)
                                end
                            end)
                        end
                        
                        if displayInfo.setting == ENUM_EDITMODEACTIONBARSETTING_CLAMPED then
                            savedValue = framesDB[systemID].clamped
                            if savedValue == nil then savedValue = 1 end
                            settingFrame.Button:SetChecked(savedValue)
                            settingFrame.Button:SetScript("OnClick", function()
                                if settingFrame.Button:GetChecked() then
                                    framesDB[systemID].clamped = 1
                                    systemFrame:SetClampedToScreen(true)
                                else
                                    framesDB[systemID].clamped = 0
                                    systemFrame:SetClampedToScreen(false)
                                end
                            end)
                        end
                        
                        if displayInfo.setting == ENUM_EDITMODEACTIONBARSETTING_HIDDENINCOMBAT then
                            savedValue = framesDB[systemID].settings[displayInfo.setting]
                            if savedValue == nil then savedValue = 0 end
                            settingFrame.Button:SetChecked(savedValue)
                            settingFrame.Button:SetScript("OnClick", function()
                                if settingFrame.Button:GetChecked() then
                                    framesDB[systemID].settings[displayInfo.setting] = 1
                                else
                                    framesDB[systemID].settings[displayInfo.setting] = 0
                                end
                            end)
                        end
                        
                          settingsToSetup[settingFrame] = { displayInfo = updatedDisplayInfo, currentValue = savedValue, settingName = settingName }
                          settingFrame:Show();
                      end
                end
        
                self.Buttons:ClearAllPoints();
        
                if not next(settingsToSetup) then
                    self.Settings:Hide();
                    self.Buttons:SetPoint("TOP", self.Title, "BOTTOM", 0, -12);
                else
                    self.Settings:Show();
                    self.Settings:Layout();
                    for settingFrame, settingData in pairs(settingsToSetup) do
                        settingFrame:SetupSetting(settingData);
                    end
                    self.Buttons:SetPoint("TOPLEFT", self.Settings, "BOTTOMLEFT", 0, -12);
                end
            else
                self.attachedToSystem = nil
                EditModeExpandedSystemSettingsDialog:Hide()
            end
        end
    end
end)

hooksecurefunc(f, "OnLoad", function()
    function EditModeExpandedSystemSettingsDialog:GetSettingPool(settingType)
        --if settingType == Enum.EditModeSettingDisplayType.Dropdown then
        --    return self.pools:GetPool("EditModeSettingDropdownTemplate");
        --else
        if settingType == Enum.EditModeSettingDisplayType.Slider then
            return self.pools:GetPool("EditModeSettingSliderTemplate")
        elseif settingType == Enum.ChrCustomizationOptionType.Checkbox then
            return self.pools:GetPool("EditModeSettingCheckboxTemplate");
        end
    end

    function EditModeExpandedSystemSettingsDialog:ReleaseNonDraggingSliders()
        local draggingSlider;
        local releaseSliders = {};

        for settingSlider in self.pools:EnumerateActiveByTemplate("EditModeSettingSliderTemplate") do
            if settingSlider.Slider.Slider:IsDraggingThumb() then
                draggingSlider = settingSlider;
            else
                table.insert(releaseSliders, settingSlider);
            end
        end

        for _, releaseSlider in ipairs(releaseSliders) do
            releaseSlider.Slider:Release();
            self.pools:Release(releaseSlider);
        end

        return draggingSlider;
    end
    
    function EditModeExpandedSystemSettingsDialog:OnSettingValueChanged(setting, value)
        local attachedToSystem = self.attachedToSystem
        if attachedToSystem then
            local db = framesDB[getSystemID(attachedToSystem)]
            if not db.settings then db.settings = {} end
            db.settings[setting] = value
            if setting == Enum.EditModeUnitFrameSetting.FrameSize then
                attachedToSystem:SetScaleOverride(value/100)
                db.x, db.y = attachedToSystem:GetRect()
            end
        end
    end
    
    function EditModeExpandedSystemSettingsDialog:OnLoad()
        local function onCloseCallback()
            if not EditModeSystemSettingsDialog:IsShown() then
                EditModeManagerExpandedFrame:ClearSelectedSystem()
            else
                EditModeExpandedSystemSettingsDialog:Hide()
            end
        end
    
        self.Buttons.RevertChangesButton:SetOnClickHandler(GenerateClosure(self.RevertChanges, self));
    
        self.onCloseCallback = onCloseCallback;
    
        self.pools = CreateFramePoolCollection();
        --self.pools:CreatePool("FRAME", self.Settings, "EditModeSettingDropdownTemplate") -- trying to use dropdowns causes taint issues, probably because of long-running taint issues with dropdowns in general
        self.pools:CreatePool("FRAME", self.Settings, "EditModeSettingSliderTemplate");
        self.pools:CreatePool("FRAME", self.Settings, "EditModeSettingCheckboxTemplate");
    
        local function resetExtraButton(pool, button)
            FramePool_HideAndClearAnchors(pool, button);
            button:Enable();
        end
        self.pools:CreatePool("BUTTON", self.Buttons, "EditModeSystemSettingsDialogExtraButtonTemplate", resetExtraButton);
    end
    EditModeExpandedSystemSettingsDialog:OnLoad()
end)

--
-- Profile handling
--
do
    local lf = CreateFrame("Frame")
    hooksecurefunc(f, "OnLoad", function()
        lf:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
    end)
    lf:SetScript("OnEvent", function()
        profilesInitialised = true
        
        for _, frames in pairs({frames, existingFrames}) do
            for name, frame in pairs(frames) do
                if type(frame) == "boolean" then
                    frame = _G[name]
                end
                EditModeExpandedSystemSettingsDialog:Hide()
                local systemID = frame.EMESystemID or frame.system
                local db = baseFramesDB[systemID]
                
                -- if currently selected Edit Mode profile does not exist in the db, try importing a legacy db instead
                local layoutInfo = EditModeManagerFrame:GetActiveLayoutInfo()
                local profileName = layoutInfo.layoutType.."-"..layoutInfo.layoutName
                if layoutInfo.layoutType == Enum.EditModeLayoutType.Character then
                    local unitName, unitRealm = UnitFullName("player")
                    profileName = layoutInfo.layoutType.."-"..unitName.."-"..unitRealm.."-"..layoutInfo.layoutName
                end
                
                if not db.profiles then db.profiles = {} end
                if not db.profiles[profileName] then
                    db.profiles[profileName] = {}
                    db.profiles[profileName].x = db.x
                    db.profiles[profileName].y = db.y
                    if frame.EMEdisabledByDefault then
                        db.profiles[profileName].enabled = false
                    else
                        db.profiles[profileName].enabled = db.enabled
                    end
                    db.profiles[profileName].settings = db.settings
                    db.profiles[profileName].defaultX = db.defaultX
                    db.profiles[profileName].defaultY = db.defaultY
                    
                    db.x = nil
                    db.y = nil
                    db.enabled = nil
                    db.settings = nil
                    db.clamped = nil
                end
                
                if db.minimap then
                    db.profiles[profileName].minimap = db.minimap
                    db.minimap = nil
                end
                
                db = db.profiles[profileName]
                framesDB[systemID] = db
                
                -- frame hide option
                if db.settings and (db.settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= nil) then
                    frame:SetShown(framesDB[systemID].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= 1)
                end
                
                if not frame.EMESystemID then
                    
                    -- update scale
                    if db.settings and db.settings[Enum.EditModeUnitFrameSetting.FrameSize] then
                        frame:SetScaleOverride(db.settings[Enum.EditModeUnitFrameSetting.FrameSize]/100)
                    end
                    
                    -- update position
                    frame:ClearAllPoints()
                    local anchorPoint = frame.EMEanchorPoint
                    if db.x and db.y then
                        local x, y = getOffsetXY(frame, db.x, db.y)
                        frame:SetPoint(anchorPoint, frame.EMEanchorTo, anchorPoint, x, y)
                    else
                        if db.defaultX and db.defaultY then
                            local x, y = getOffsetXY(frame, db.defaultX, db.defaultY)
                            if not pcall( function() frame:SetPoint(anchorPoint, frame.EMEanchorTo, anchorPoint, x, y) end ) then
                                frame:SetPoint(anchorPoint, nil, anchorPoint, x, y)
                            end
                        end
                    end
                
                    -- minimap pinning
                    if framesDialogsKeys[systemID] and framesDialogsKeys[systemID][ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED] then
                        if db.settings and (db.settings[ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED] ~= nil) then
                            if db.settings[ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED] == 1 then
                                pinToMinimap(frame)
                            else
                                unpinFromMinimap(frame)
                            end
                        end
                    end
                    
                    -- the option in the expanded frame
                    if frame.EMEdisabledByDefault then
                        db.enabled = false
                    end
                    if db.enabled == nil then
                        db.enabled = true
                    end
                    frame.EMECheckButtonFrame:SetChecked(db.enabled)
                    
                    -- only way I can find to un-select frames
                    if EditModeManagerFrame.editModeActive and frame:IsShown() then
                        frame:HighlightSystem()
                    end
                    
                    if db.clamped == 1 then
                        frame:SetClampedToScreen(true)
                    else
                        frame:SetClampedToScreen(false)
                    end
                
                end
            end
            
            for _, func in pairs(customCheckboxCallDuringProfileInit) do
                func()
            end
        end
    end)
end

--
-- allow a frame to be pinned to the minimap
--

-- Prerequsities: LibDataBroker and LibDBIcon
-- Must be called during PLAYER_ENTERING_WORLD or later, or issues with MBB compatibility can occur
function lib:RegisterMinimapPinnable(frame)
    local name = frame:GetName().."LDB"
    local db = framesDB[frame.system]
    if not db.minimap then db.minimap = {} end
    if not db.settings then db.settings = {} end
    
    -- requirements to show the minimap icon:
    -- 1. player has selected option to pin the frame to the minimap
    -- 2. the frame is actually currently visible
    db.minimap.hide = not ((db.settings[ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED] == 1) and frame:IsShown())
    
    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(name, {
        type = "data source",
        text = frame:GetName(),
        icon = "",
    })
    local icon = LibStub("LibDBIcon-1.0")
    icon:Register(name, LDB, db.minimap)
    
    -- compatibility with Minimap Button Bag
    if MBB_Version and MBB_OnClick and MBB_Ignore then
        icon:Show(name)
        table.insert(MBB_Ignore, icon:GetMinimapButton(name):GetName())
        icon:Hide(name)
    end
    
    frame:HookScript("OnShow", function()
        local db = framesDB[frame.system]
        if not db.minimap then db.minimap = {} end
        if not db.settings then db.settings = {} end
        if db.settings[ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED] == 1 then
            db.minimap.hide = nil
            icon:Show(name)
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", icon:GetMinimapButton(name), "CENTER")
        end
    end)
    
    frame:HookScript("OnHide", function()
        local db = framesDB[frame.system]
        if not db.minimap then db.minimap = {} end
        if not db.settings then db.settings = {} end
        db.minimap.hide = true
        icon:Hide(name)
    end)
    
    local function showHide()
        local db = framesDB[frame.system]
        if not db.minimap then db.minimap = {} end
        if not db.settings then db.settings = {} end
        if (db.settings[ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED] == 1) and frame:IsShown() then
            db.minimap.hide = nil
            icon:Show(name)
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", icon:GetMinimapButton(name), "CENTER")
        else
            db.minimap.hide = true
            icon:Hide(name)
        end
    end
    
    hooksecurefunc(frame, "SetShown", function()
        showHide()
    end)
    showHide()
    
    if not framesDialogs[frame.system] then framesDialogs[frame.system] = {} end
    if framesDialogsKeys[frame.system] and framesDialogsKeys[frame.system][ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED] then return end
    if not framesDialogsKeys[frame.system] then framesDialogsKeys[frame.system] = {} end
    framesDialogsKeys[frame.system][ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED] = true
    table.insert(framesDialogs[frame.system],
        {
            setting = ENUM_EDITMODEACTIONBARSETTING_MINIMAPPINNED,
            name = "Pin to Minimap",
            type = Enum.EditModeSettingDisplayType.Checkbox,
        }
    )
    
    frame.minimapLDBIcon = icon
end

function pinToMinimap(frame)
    local db = framesDB[frame.system]
    if not db.minimap then db.minimap = {} end
    
    if db.minimap.hide then
        frame.minimapLDBIcon:Hide(frame:GetName().."LDB")
    else
        frame.minimapLDBIcon:Show(frame:GetName().."LDB")
    end
    
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", frame.minimapLDBIcon:GetMinimapButton(frame:GetName().."LDB"), "CENTER")
end

function unpinFromMinimap(frame)
    local db = framesDB[frame.system]
    frame:ClearAllPoints()
    local x, y = getOffsetXY(frame, db.x, db.y)
    frame:SetPoint(frame.EMEanchorPoint, frame.EMEanchorTo, frame.EMEanchorPoint, db.x, db.y)
    db.minimap.hide = true
    frame.minimapLDBIcon:Hide(frame:GetName().."LDB")
end

--
-- Handle frame being based on a frame other than UIParent
--
function getOffsetXY(frame, x, y)
    local scale = frame:GetEffectiveScale()
    local parentscale = frame.EMEanchorTo:GetEffectiveScale()

    local anchorPoint = frame.EMEanchorPoint or "BOTTOMLEFT"
    if anchorPoint == "BOTTOMLEFT" then
        local targetX, targetY = frame.EMEanchorTo:GetRect()
        return x - ((targetX * parentscale) / scale), y - ((targetY * parentscale) / scale)
    elseif anchorPoint == "BOTTOMRIGHT" then
        local targetX, targetY, targetWidth = frame.EMEanchorTo:GetRect()
        local width = frame:GetSize()
        return (x + width) - (((targetX + targetWidth) * parentscale) / scale), y - ((targetY * parentscale) / scale)
    elseif anchorPoint == "TOPLEFT" then
        local targetX, targetY, _, targetHeight = frame.EMEanchorTo:GetRect()
        local _, height = frame:GetSize()
        return x - ((targetX * parentscale) / scale), (y + height) - (((targetY + targetHeight) * parentscale) / scale)
    elseif anchorPoint == "TOPRIGHT" then
        local targetX, targetY, targetWidth, targetHeight = frame.EMEanchorTo:GetRect()
        local width, height = frame:GetSize()
        return (x + width) - (((targetX + targetWidth) * parentscale) / scale), (y + height) - (((targetY + targetHeight) * parentscale) / scale)
    elseif anchorPoint == "CENTER" then
        local targetX, targetY, targetWidth, targetHeight = frame.EMEanchorTo:GetRect()
        local width, height = frame:GetSize()
        return (x + 0.5 * width) - (((targetX + 0.5 * targetWidth) * parentscale) / scale), (y + 0.5 * height) - (((targetY + 0.5 * targetHeight) * parentscale) / scale)
    elseif anchorPoint == "TOP" then
        local targetX, targetY, targetWidth, targetHeight = frame.EMEanchorTo:GetRect()
        local width, height = frame:GetSize()
        return (x + 0.5 * width) - (((targetX + 0.5 * targetWidth) * parentscale) / scale), (y + height) - (((targetY + targetHeight) * parentscale) / scale)
    elseif anchorPoint == "BOTTOM" then
        local targetX, targetY, targetWidth = frame.EMEanchorTo:GetRect()
        local width = frame:GetSize()
        return (x + 0.5 * width) - (((targetX + 0.5 * targetWidth) * parentscale) / scale), y - ((targetY * parentscale) / scale)
    elseif anchorPoint == "LEFT" then
        local targetX, targetY, _, targetHeight = frame.EMEanchorTo:GetRect()
        local _, height = frame:GetSize()
        return x - ((targetX * parentscale) / scale), (y + 0.5 * height) - (((targetY + 0.5 * targetHeight) * parentscale) / scale)
    elseif anchorPoint == "RIGHT" then
        local targetX, targetY, targetWidth, targetHeight = frame.EMEanchorTo:GetRect()
        local width, height = frame:GetSize()
        return (x + width) - (((targetX + targetWidth) * parentscale) / scale), (y + 0.5 * height) - (((targetY + 0.5 * targetHeight) * parentscale) / scale)
    end 
end

--
-- Handle allowing frame to be moved with arrow keys
--
function registerFrameMovableWithArrowKeys(frame, anchorPoint, anchorTo)
    frame.Selection:EnableKeyboard();
    frame.Selection:SetPropagateKeyboardInput(true);
    frame.Selection:SetScript("OnKeyDown", function(self, key)
        frame:MoveWithArrowKey(key);
    end)

    function frame:MoveWithArrowKey(key)
        if self.isSelected then
            local x, y = self:GetRect();

            local new_x = x;
            local new_y = y;

            if key == "RIGHT" then      new_x = new_x + 1;
            elseif key == "LEFT" then   new_x = new_x - 1;
            elseif key == "UP" then     new_y = new_y + 1;
            elseif key == "DOWN" then   new_y = new_y - 1;
            end
            
            if new_x ~= x or new_y ~= y then
                -- consume the key used to prevent movement / cam turning
                self.Selection:SetPropagateKeyboardInput(false);
                
                if existingFrames[frame:GetName()] then
                    local layoutInfoCopy = CopyTable(EditModeManagerFrame.layoutInfo)
                    local activeLayout = layoutInfoCopy.layouts[layoutInfoCopy.activeLayout]
                    local a, b, c, d, e = self:GetPoint()
                    for index, frameData in ipairs(activeLayout.systems) do
                        local anchorInfo = frameData.anchorInfo
                        if frame.EMELayoutInfoIDKnown then
                            if (frame.EMELayoutInfoIDKnown.system == frameData.system) and (frame.EMELayoutInfoIDKnown.systemIndex == frameData.systemIndex) then
                                anchorInfo.offsetX = new_x
                                anchorInfo.offsetY = new_y
                                break
                            end
                        end
                        if 
                            (anchorInfo.point == a) and 
                            (anchorInfo.relativeTo == b:GetName()) and 
                            (anchorInfo.relativePoint == c) and 
                            (tonumber(string.format("%.3f", anchorInfo.offsetX)) == tonumber(string.format("%.3f", d))) and 
                            (tonumber(string.format("%.3f", anchorInfo.offsetY)) == tonumber(string.format("%.3f", e))) 
                        then
                            frame.EMELayoutInfoIDKnown = {
                                system = frameData.system,
                                systemIndex = frameData.systemIndex,
                            }
                            anchorInfo.offsetX = new_x
                            anchorInfo.offsetY = new_y
                            break
                        end
                    end
                    C_EditMode.SaveLayouts(layoutInfoCopy)
                else
                    local db = framesDB[getSystemID(frame)]
                    db.x, db.y = new_x, new_y
                end
                self:ClearAllPoints()
                local x, y = getOffsetXY(frame, new_x, new_y)
                self:SetPoint(anchorPoint, anchorTo, anchorPoint, x, y);
                return
            end
        end

        self.Selection:SetPropagateKeyboardInput(true);
    end
end

-- Will make the frame not shown during edit mode by default
function lib:HideByDefault(frame)
    local db = framesDB[frame.system]
    db.enabled = false
    frame.EMEdisabledByDefault = true
    frame.EMECheckButtonFrame:SetChecked(false)
end

-- Adds an option to hide the frame during combat
-- Frame must be already have had :RegisterHideable called on it for this to work
function lib:RegisterToggleInCombat(frame)
    local systemID = getSystemID(frame)
    
    if not framesDialogs[systemID] then framesDialogs[systemID] = {} end
    if framesDialogsKeys[systemID] and framesDialogsKeys[systemID][ENUM_EDITMODEACTIONBARSETTING_HIDDENINCOMBAT] then return end
    if not framesDialogsKeys[systemID] then framesDialogsKeys[systemID] = {} end
    framesDialogsKeys[systemID][ENUM_EDITMODEACTIONBARSETTING_HIDDENINCOMBAT] = true
    table.insert(framesDialogs[systemID],
        {
            setting = ENUM_EDITMODEACTIONBARSETTING_HIDDENINCOMBAT,
            name = "Toggle Visibility in Combat",
            type = Enum.EditModeSettingDisplayType.Checkbox,
    })
end

do
    local lf = CreateFrame("Frame")
    hooksecurefunc(f, "OnLoad", function()
        lf:RegisterEvent("PLAYER_REGEN_DISABLED")
        lf:RegisterEvent("PLAYER_REGEN_ENABLED")
    end)
    lf:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            -- entering combat
            for _, frames in pairs({frames, existingFrames}) do
                for name, frame in pairs(frames) do
                    if type(frame) == "boolean" then
                        frame = _G[name]
                    end
                    local systemID = getSystemID(frame)
                    local db = framesDB[systemID]
                    local settings = db.settings
                    local dialogs = framesDialogsKeys[systemID]
                    
                    if dialogs and dialogs[ENUM_EDITMODEACTIONBARSETTING_HIDDENINCOMBAT] and settings and (settings[ENUM_EDITMODEACTIONBARSETTING_HIDDENINCOMBAT] == 1) and dialogs[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] then
                        if settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] == 1 then
                            -- if "Hide" in enabled and this option too, then hide it while out of combat, show it while in combat
                            frame:Show()
                        else
                            frame:Hide()
                        end
                    end
                end
            end
        elseif event == "PLAYER_REGEN_ENABLED" then
            -- exiting combat
            for _, frames in pairs({frames, existingFrames}) do
                for name, frame in pairs(frames) do
                    if type(frame) == "boolean" then
                        frame = _G[name]
                    end
                    local systemID = getSystemID(frame)
                    local db = framesDB[systemID]
                    local settings = db.settings
                    local dialogs = framesDialogsKeys[systemID]
                    
                    if dialogs and settings and dialogs[ENUM_EDITMODEACTIONBARSETTING_HIDDENINCOMBAT] and (settings[ENUM_EDITMODEACTIONBARSETTING_HIDDENINCOMBAT] == 1) and dialogs[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] then
                        if settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] == 1 then
                            frame:Hide()
                        else
                            frame:Show()
                        end
                    end
                end
            end
        end
    end)
end
