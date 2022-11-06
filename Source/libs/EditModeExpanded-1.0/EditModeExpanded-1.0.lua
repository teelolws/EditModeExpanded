local CURRENT_BUILD = "10.0.0"
local MAJOR, MINOR = "EditModeExpanded-1.0", 9
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

-- the internal frames provided by Blizzard go up to index 12. They reference an Enum.
local index = 13
local frames = {}
local framesDB = {}
local framesDialogs = {}
local framesDialogsKeys = {}

local ENUM_EDITMODEACTIONBARSETTING_HIDEABLE = 10 -- Enum.EditModeActionBarSetting.Hideable = 10

-- run OnLoad the first time RegisterFrame is called by an addon
local f = {}
function f.OnLoad() f.OnLoad = nil end

-- some caching tables, save the state of frames just before entering Edit Mode
local wasVisible = {}
local originalSize = {}
local defaultSize = {}

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

-- MicroButtonAndBagsBar:GetTop gets checked by EditModeManager, setting the scale of the Right Action bars
-- to allow it to be moved, we need to duplicate the frame, hide the original, and make the duplicate the one being moved instead
local function duplicateMicroButtonAndBagsBar(db)
    MicroButtonAndBagsBar:Hide()
    local duplicate = CreateFrame("Frame", "MicroButtonAndBagsBarMovable", UIParent)
    duplicate:SetSize(232, 40)
    duplicate:SetPoint("BOTTOMRIGHT")
    duplicate.QuickKeybindsMicroBagBarGlow = duplicate:CreateTexture(nil, "BACKGROUND")
    duplicate.QuickKeybindsMicroBagBarGlow:SetAtlas("QuickKeybind_BagMicro_Glow", true)
    duplicate.QuickKeybindsMicroBagBarGlow:Hide()
    duplicate.QuickKeybindsMicroBagBarGlow:SetPoint("CENTER", duplicate, "CENTER", -30, 30)
    
    hooksecurefunc("MoveMicroButtons", function(anchor, anchorTo, relAnchor, x, y, isStacked)
        if anchorTo == MicroButtonAndBagsBar then
            anchorTo = duplicate
            CharacterMicroButton:ClearAllPoints();
            CharacterMicroButton:SetPoint(anchor, anchorTo, relAnchor, x, y);
        end
    end)
    
    hooksecurefunc(MicroButtonAndBagsBar.QuickKeybindsMicroBagBarGlow, "SetShown", function(self, showEffects)
        duplicate.QuickKeybindsMicroBagBarGlow:SetShown(showEffects)
    end)
    
    duplicate:Show()
    
    CharacterMicroButton:ClearAllPoints();
    CharacterMicroButton:SetPoint("BOTTOMLEFT", duplicate, "BOTTOMLEFT", 7, 6)
    
    UpdateMicroButtonsParent(duplicate)
    hooksecurefunc("UpdateMicroButtonsParent", function(parent)
        for i=1, #MICRO_BUTTONS do
            _G[MICRO_BUTTONS[i]]:SetParent(duplicate)
        end
    end)
    
    MainMenuBarBackpackButton:SetPoint("TOPRIGHT", duplicate, -4, 2)
    MainMenuBarBackpackButton:SetParent(duplicate)
    
    QueueStatusButton:SetParent(duplicate)
    
    -- Now split the Backpack section into its own bar
    local backpackBar = CreateFrame("Frame", "EditModeExpandedBackpackBar", UIParent)
    backpackBar:SetSize(232, 40)
    backpackBar:SetPoint("BOTTOMRIGHT", duplicate, "TOPRIGHT")
    MainMenuBarBackpackButton:ClearAllPoints()
    MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", backpackBar, "BOTTOMRIGHT")
    MainMenuBarBackpackButton:SetParent(backpackBar)
    BagBarExpandToggle:SetParent(backpackBar)
    CharacterBag0Slot:SetParent(backpackBar)
    CharacterBag1Slot:SetParent(backpackBar)
    CharacterBag2Slot:SetParent(backpackBar)
    CharacterBag3Slot:SetParent(backpackBar)
    CharacterReagentBag0Slot:SetParent(backpackBar)
    
    if not db.BackpackBar then db.BackpackBar = {} end
    lib:RegisterFrame(EditModeExpandedBackpackBar, "Backpack", db.BackpackBar)
    return duplicate
end

-- Call this on a frame to register it for capture during Edit Mode
-- param1: frame, the Frame to register
-- param2: name, localized name to appear when the frame is selected during Edit Mode
-- param3: db, a table in your saved variables to save the frame position in
function lib:RegisterFrame(frame, name, db)
    assert(type(frame) == "table")
    assert(type(name) == "string")
    assert(type(db) == "table")
    
    -- IMPORTANT: force update every patch incase of UI changes that cause problems and/or make this library redundant!
    if not (GetBuildInfo() == CURRENT_BUILD) then return end
    
    if f.OnLoad then f.OnLoad() end
    
    -- If the frame was already registered (perhaps by another addon that uses this library), don't register it again
    for _, f in ipairs(frames) do
        if (frame == f) or ((frame == MicroButtonAndBagsBar) and (f == MicroButtonAndBagsBarMovable)) then
            if (not framesDB[f.system].x) and (not framesDB[f.system].y) then
                -- import new db settings if there are none saved in the existing db
                framesDB[f.system].x = db.x
                framesDB[f.system].y = db.y
                f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.x, db.y)
            end
            return
        end
    end
    
    if frame == MicroButtonAndBagsBar then
        frame = duplicateMicroButtonAndBagsBar(db)
        if not db.MenuBar then db.MenuBar = {} end
        db = db.MenuBar
    end
     
    table.insert(frames, frame)
    
    Mixin(frame, EditModeSystemMixin)
    
    frame.system = index
    index = index + 1
    framesDB[frame.system] = db

	frame.Selection = CreateFrame("Frame", nil, frame, "EditModeSystemSelectionTemplate")
    frame.Selection:SetAllPoints(frame)
    frame.defaultHideSelection = true
    frame.Selection:Hide()
    
    frame.systemNameString = name
    frame.systemName = frame.systemNameString;
	frame.Selection:SetLabelText(frame.systemName);
	frame:SetupSettingsDialogAnchor();
	frame.snappedFrames = {};
    frame.Selection:EnableKeyboard();
    frame.Selection:SetPropagateKeyboardInput(true);
    
    function frame.UpdateMagnetismRegistration() end

    frame.Selection:SetScript("OnMouseDown", function()
    	frame:SelectSystem()
    end)

    frame.Selection:SetScript("OnKeyDown", function(self, key)
        frame:MoveWithArrowKey(key);
    end)

    function frame:MoveWithArrowKey(key)
        if self.isSelected then
            x, y = self:GetRect();

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
                db.x, db.y = new_x, new_y;
                self:ClearAllPoints();
                self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.x, db.y);
                return
            end
        end

        self.Selection:SetPropagateKeyboardInput(true);
    end
    
    function frame:SelectSystem()
        if not self.isSelected then
            self:SetMovable(true);
            self.Selection:ShowSelected();
            self.isSelected = true;
            if framesDialogs[self.system] then
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
        db.x, db.y = self:GetRect()
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
    local resetButton = CreateFrame("Button", nil, EditModeManagerFrame, "UIPanelButtonTemplate")
    resetButton:SetText(RESET)
    resetButton:SetPoint("TOPLEFT", checkButtonFrame.Text, "TOPRIGHT", 5, 1)
    resetButton:SetScript("OnClick", function()
        frame:SetScale(1)
        frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.defaultX, db.defaultY)
        db.x = db.defaultX
        db.y = db.defaultY
        if not db.settings then db.settings = {} end
        db.settings[Enum.EditModeUnitFrameSetting.FrameSize] = 100
    end)
    
    checkButtonFrame:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        db.enabled = isChecked
        frame:SetShown(isChecked)
    end)
    
    checkButtonFrame.Text:SetText(name)
    checkButtonFrame.Text:SetFontObject(GameFontHighlightSmall)
    
    checkButtonFrame.index = frame.system
    if frame.system == 13 then
        checkButtonFrame:SetPoint("TOPLEFT", EditModeManagerExpandedFrame.AccountSettings, "TOPLEFT", 20, 0)
        checkButtonFrame:SetSize(32, 32)
    else
        checkButtonFrame:SetPoint("TOPLEFT", EditModeManagerExpandedFrame.AccountSettings[frame.system - 1], "BOTTOMLEFT", 0, 10)
        checkButtonFrame:SetSize(32, 32)
    end
    
    if db.enabled == nil then db.enabled = true end
    checkButtonFrame:SetChecked(db.enabled)
    
    function frame:GetSettingValue(setting, useRawValue)
    	if (not self:IsInitialized()) or (not db.settings) or (not db.settings[settings]) then
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
    
    db.defaultScale = frame:GetScale()
    db.defaultX, db.defaultY = frame:GetRect()
    
    if db.settings and db.settings[Enum.EditModeUnitFrameSetting.FrameSize] then
        frame:SetScaleOverride(db.settings[Enum.EditModeUnitFrameSetting.FrameSize]/100)
    end
    
    if db.x and db.y then
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.x, db.y)
    else
        db.x, db.y = frame:GetRect()
    end
    
    if db.settings and (db.settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= nil) then
        frame:SetShown(framesDB[frame.system].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= 1)
    end
end

if not (GetBuildInfo() == CURRENT_BUILD) then return end

--
-- Code for Expanded Manager Frame here
-- This is a frame that will show checkboxes, to turn on/off all custom frames during Edit Mode
--

hooksecurefunc(f, "OnLoad", function()
    CreateFrame("Frame", "EditModeManagerExpandedFrame", nil)
    EditModeManagerExpandedFrame:Hide()
    EditModeManagerExpandedFrame:SetPoint("TOPLEFT", EditModeManagerFrame, "TOPRIGHT", 2, 0)
    EditModeManagerExpandedFrame:SetPoint("BOTTOMLEFT", EditModeManagerFrame, "BOTTOMRIGHT", 2, 0)
    EditModeManagerExpandedFrame:SetWidth(250)
    EditModeManagerExpandedFrame.Title = EditModeManagerExpandedFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
    EditModeManagerExpandedFrame.Title:SetPoint("TOP", 0, -15)
    EditModeManagerExpandedFrame.Title:SetText("Expanded")
    EditModeManagerExpandedFrame.Border = CreateFrame("Frame", nil, EditModeManagerExpandedFrame, "DialogBorderTranslucentTemplate")
    EditModeManagerExpandedFrame.AccountSettings = CreateFrame("Frame", nil, EditModeManagerExpandedFrame)
    EditModeManagerExpandedFrame.AccountSettings:SetPoint("TOPLEFT", 0, -35)
    EditModeManagerExpandedFrame.AccountSettings:SetPoint("BOTTOMLEFT", 10, 10)
    EditModeManagerExpandedFrame.AccountSettings:SetWidth(200)
    
    EditModeManagerFrame:HookScript("OnShow", function()
        EditModeManagerExpandedFrame:Show()
    end)
    
    EditModeManagerFrame:HookScript("OnHide", function()
        EditModeManagerExpandedFrame:Hide()
    end)
    
    function EditModeManagerExpandedFrame:ClearSelectedSystem()
    	EditModeExpandedSystemSettingsDialog:Hide();
    end
end)

-- use this if a frame by default doesn't have a size set yet
function lib:SetDefaultSize(frame, x, y)
    assert(type(frame) == "table")
    assert(type(x) == "number")
    assert(type(y) == "number")
    
    defaultSize[frame.system] = {["x"] = x, ["y"] = y}
end

hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function(self)
    if #frames <= 0 then EditModeManagerExpandedFrame:Hide() end
    for _, frame in ipairs(frames) do
        frame:SetHasActiveChanges(false)
        frame:HighlightSystem();
        wasVisible[frame.system] = frame:IsShown()
        frame:SetShown(framesDB[frame.system].enabled)
        local x, y = frame:GetSize()
        if (x < 40) or (y < 40) then
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
end)

hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
    for _, frame in ipairs(frames) do
        frame:ClearHighlight();
        frame:StopMovingOrSizing();
        
        frame:SetShown(wasVisible[frame.system])
        if framesDB[frame.system] and framesDB[frame.system].settings and (framesDB[frame.system].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= nil) then
            frame:SetShown(framesDB[frame.system].settings[ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] ~= 1)
        end
        
        if originalSize[frame.system] then
            frame:SetSize(originalSize[frame.system].x, originalSize[frame.system].y)
        end
    end
    wipe(wasVisible)
    wipe(originalSize)
    EditModeExpandedSystemSettingsDialog:Hide()
end)

hooksecurefunc(EditModeManagerFrame, "SelectSystem", function(self, systemFrame)
    local wasCustom
    for _, frame in ipairs(frames) do
        if systemFrame ~= frame then
            frame:HighlightSystem()
        else
            wasCustom = true
        end
    end
    if not wasCustom then
        EditModeExpandedSystemSettingsDialog:Hide()
    end            
end)

--
-- Edit Mode Dialog Box code
--

hooksecurefunc(f, "OnLoad", function()
    local frame = CreateFrame("Frame", "EditModeExpandedSystemSettingsDialog", UIParent, "ResizeLayoutFrame")
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
    
    CreateFrame("Frame", "EditModeExpandedSettingSlider", frame)
    Mixin(EditModeExpandedSettingSlider, EditModeSettingSliderMixin)
    EditModeExpandedSettingSlider:Hide()
    EditModeExpandedSettingSlider:SetSize(343, 32)
    EditModeExpandedSettingSlider.Label = EditModeExpandedSettingSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
    EditModeExpandedSettingSlider.Label:SetJustifyH("LEFT")
    EditModeExpandedSettingSlider.Label:SetSize(100, 32)
    EditModeExpandedSettingSlider.Label:SetPoint("LEFT")
    EditModeExpandedSettingSlider.Slider = CreateFrame("Frame", nil, EditModeExpandedSettingSlider, "MinimalSliderWithSteppersTemplate")
    EditModeExpandedSettingSlider.Slider:SetSize(200, 32)
    EditModeExpandedSettingSlider.Slider:SetPoint("LEFT", EditModeExpandedSettingSlider.Label, "RIGHT", 5, 0)
    EditModeExpandedSettingSlider:SetScript("OnLoad", EditModeExpandedSettingSlider.OnLoad)
    EditModeExpandedSettingSlider:OnLoad()
    
    function EditModeExpandedSettingSlider:OnSliderValueChanged(value)
    	if not self.initInProgress then
    		EditModeExpandedSystemSettingsDialog:OnSettingValueChanged(self.setting, value);
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
    EditModeExpandedSystemSettingsDialog.CloseButton:SetScript("OnClick", function()                                                                 
		EditModeManagerExpandedFrame:ClearSelectedSystem();
	end)
    
    function EditModeExpandedSystemSettingsDialog:UpdateSettings(systemFrame)
    	if systemFrame == self.attachedToSystem then
    		self:ReleaseAllNonSliders();
            local draggingSlider = self:ReleaseNonDraggingSliders();
    
    		local settingsToSetup = {};
    
    		local systemSettingDisplayInfo = GetSystemSettingDisplayInfo(framesDialogs[self.attachedToSystem.system]);
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
                    if not framesDB[self.attachedToSystem.system].settings then framesDB[self.attachedToSystem.system].settings = {} end
  					
                    local savedValue = framesDB[self.attachedToSystem.system].settings[updatedDisplayInfo.setting]
                    
                    if displayInfo.setting == Enum.EditModeUnitFrameSetting.FrameSize then
                        savedValue = savedValue or 100
                        settingFrame:OnLoad()
                        
                        CallbackRegistryMixin.OnLoad(settingFrame);

                    	local function OnValueChanged(self, value)
                            if not self.initInProgress then
                                EditModeExpandedSystemSettingsDialog:OnSettingValueChanged(self.setting, value);
                            end
                        end
                        
                        settingFrame.cbrHandles = EventUtil.CreateCallbackHandleContainer();
                    	settingFrame.cbrHandles:RegisterCallback(settingFrame.Slider, MinimalSliderWithSteppersMixin.Event.OnValueChanged, OnValueChanged, settingFrame);
                    end
                    
                    if displayInfo.setting == ENUM_EDITMODEACTIONBARSETTING_HIDEABLE then
                        savedValue = framesDB[EditModeExpandedSystemSettingsDialog.attachedToSystem.system].settings[displayInfo.setting]
                        if savedValue == nil then savedValue = 0 end
                        settingFrame.Button:SetChecked(savedValue)
                        settingFrame.Button:HookScript("OnClick", function()
                            if settingFrame.Button:GetChecked() then
                                framesDB[EditModeExpandedSystemSettingsDialog.attachedToSystem.system].settings[displayInfo.setting] = 1
                                EditModeExpandedSystemSettingsDialog.attachedToSystem:Hide()
                            else
                                framesDB[EditModeExpandedSystemSettingsDialog.attachedToSystem.system].settings[displayInfo.setting] = 0
                                EditModeExpandedSystemSettingsDialog.attachedToSystem:Show()
                            end
                        end)
                    end
                    
  					settingsToSetup[settingFrame] = { displayInfo = updatedDisplayInfo, currentValue = savedValue, settingName = settingName },
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
    	end
    end
end)

-- param1: custom system frame
function lib:RegisterResizable(frame)
    if not framesDialogs[frame.system] then framesDialogs[frame.system] = {} end
    if framesDialogsKeys[frame.system] and framesDialogsKeys[frame.system][Enum.EditModeUnitFrameSetting.FrameSize] then return end
    if not framesDialogsKeys[frame.system] then framesDialogsKeys[frame.system] = {} end
    framesDialogsKeys[frame.system][Enum.EditModeUnitFrameSetting.FrameSize] = true
    table.insert(framesDialogs[frame.system],
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
 
function lib:RegisterHideable(frame)
    if not framesDialogs[frame.system] then framesDialogs[frame.system] = {} end
    if framesDialogsKeys[frame.system] and framesDialogsKeys[frame.system][ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] then return end
    if not framesDialogsKeys[frame.system] then framesDialogsKeys[frame.system] = {} end
    framesDialogsKeys[frame.system][ENUM_EDITMODEACTIONBARSETTING_HIDEABLE] = true
    table.insert(framesDialogs[frame.system],
        {
            setting = ENUM_EDITMODEACTIONBARSETTING_HIDEABLE,
            name = "Hide",
            type = Enum.EditModeSettingDisplayType.Checkbox,
    })
end


hooksecurefunc(f, "OnLoad", function()
    function EditModeExpandedSystemSettingsDialog:OnSettingValueChanged(setting, value)
        local attachedToSystem = self.attachedToSystem
    	if attachedToSystem then
            local db = framesDB[attachedToSystem.system]
            if not db.settings then db.settings = {} end
            db.settings[setting] = value
            if setting == Enum.EditModeUnitFrameSetting.FrameSize then
                attachedToSystem:SetScaleOverride(value/100)
                db.x, db.y = self:GetRect()
            end
    	end
    end
    
    function EditModeExpandedSystemSettingsDialog:OnLoad()
    	local function onCloseCallback()
    		EditModeExpandedManagerFrame:ClearSelectedSystem();
    	end
    
    	self.Buttons.RevertChangesButton:SetOnClickHandler(GenerateClosure(self.RevertChanges, self));
    
    	self.onCloseCallback = onCloseCallback;
    
    	self.pools = CreateFramePoolCollection();
    	self.pools:CreatePool("FRAME", self.Settings, "EditModeSettingDropdownTemplate");
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