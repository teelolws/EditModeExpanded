local CURRENT_BUILD = "10.0.0"
local MAJOR, MINOR = "EditModeExpanded-1.0", 2
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

-- the internal frames provided by Blizzard go up to index 12. They reference an Enum.
local index = 13
local frames = {}
local framesDB = {}

-- some caching tables, save the state of frames just before entering Edit Mode
local wasVisible = {}
local originalSize = {}
local defaultSize = {}

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

-- Call this on a frame to register it for capture during Edit Mode
-- param1: frame, the Frame to register
-- param2: name, localized name to appear when the frame is selected during Edit Mode
-- param3: db, a table in your saved variables to save the frame position in
function lib:RegisterFrame(frame, name, db)
    assert(type(frame) == "table")
    assert(type(name) == "string")
    assert(type(db) == "table")
    assert(frame ~= MicroButtonAndBagsBar)
    
    -- IMPORTANT: force update every patch incase of UI changes that cause problems and/or make this library redundant!
    if not (GetBuildInfo() == CURRENT_BUILD) then return end
     
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

    function frame.UpdateMagnetismRegistration() end

    frame.Selection:SetScript("OnMouseDown", function()
    	frame:SelectSystem()
    end)
    
    function frame:SelectSystem()
        if not self.isSelected then
            self:SetMovable(true);
            self.Selection:ShowSelected();
            self.isSelected = true;
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
    
    if db.x and db.y then
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.x, db.y)
    else
        db.x, db.y = frame:GetRect()
    end
    
    EditModeManagerExpandedFrame.AccountSettings.Settings[frame.system] = CreateFrame("Frame", nil, EditModeManagerExpandedFrame.AccountSettings, "EditModeCheckButtonTemplate")
    EditModeManagerExpandedFrame.AccountSettings.Settings[frame.system]:SetLabelText(name)
    EditModeManagerExpandedFrame.AccountSettings.Settings[frame.system].index = frame.system
    if frame.system == 13 then
        EditModeManagerExpandedFrame.AccountSettings.Settings[frame.system]:SetPoint("TOPLEFT")
    else
        EditModeManagerExpandedFrame.AccountSettings.Settings[frame.system]:SetPoint("TOPLEFT", EditModeManagerExpandedFrame.AccountSettings.Settings[(frame.system - 1)], "BOTTOMLEFT")
    end
    EditModeManagerExpandedFrame:Layout()
    
    if db.enabled == nil then db.enabled = true end
    EditModeManagerExpandedFrame.AccountSettings.Settings[frame.system]:SetControlChecked(db.enabled)
    EditModeManagerExpandedFrame.AccountSettings.Settings[frame.system].OnCheckButtonClick = function(self)
        local isChecked = self:IsControlChecked()
        db.enabled = isChecked
        frame:SetShown(isChecked)
    end
end

if not (GetBuildInfo() == CURRENT_BUILD) then return end

local EditModeManagerExpandedFrame = CreateFrame("Frame", "EditModeManagerExpandedFrame", nil, "ResizeLayoutFrame")
EditModeManagerExpandedFrame:Hide()
EditModeManagerExpandedFrame:SetPoint("TOPLEFT", EditModeManagerFrame, "TOPRIGHT", 2, 0)
EditModeManagerExpandedFrame:SetPoint("BOTTOMLEFT", EditModeManagerFrame, "BOTTOMRIGHT", 2, 0)
EditModeManagerExpandedFrame.Title = EditModeManagerExpandedFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
EditModeManagerExpandedFrame.Title:SetPoint("TOP", 0, -15)
EditModeManagerExpandedFrame.Title:SetText("Expanded")
EditModeManagerExpandedFrame.Border = CreateFrame("Frame", nil, EditModeManagerExpandedFrame, "DialogBorderTranslucentTemplate")
EditModeManagerExpandedFrame.Border.ignoreInLayout = true
EditModeManagerExpandedFrame.AccountSettings = CreateFrame("Frame", nil, EditModeManagerExpandedFrame, "VerticalLayoutFrame")
EditModeManagerExpandedFrame.AccountSettings.fixedWidth = 200
EditModeManagerExpandedFrame.AccountSettings:SetPoint("TOP", 10, -55)
EditModeManagerExpandedFrame.AccountSettings.Settings = CreateFrame("Frame", nil, EditModeManagerExpandedFrame.AccountSettings, "ResizeLayoutFrame")
EditModeManagerExpandedFrame.AccountSettings.Settings.layoutIndex = 1
EditModeManagerExpandedFrame.AccountSettings.Settings.fixedWidth = 200
EditModeManagerExpandedFrame.AccountSettings.Settings:Layout()

EditModeManagerFrame:HookScript("OnShow", function()
    EditModeManagerExpandedFrame:Show()
end)

EditModeManagerFrame:HookScript("OnHide", function()
    EditModeManagerExpandedFrame:Hide()
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
        if originalSize[frame.system] then
            frame:SetSize(originalSize[frame.system].x, originalSize[frame.system].y)
        end
    end
    wipe(wasVisible)
end)

hooksecurefunc(EditModeManagerFrame, "SelectSystem", function(self, systemFrame)
    for _, frame in ipairs(frames) do
        if systemFrame ~= frame then
            frame:HighlightSystem()
        end
    end
end)
