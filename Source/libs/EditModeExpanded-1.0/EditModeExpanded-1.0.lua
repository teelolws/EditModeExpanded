local MAJOR, MINOR = "EditModeExpanded-1.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)

local index = 13
local frames = {}
--local coordinateDB = {}

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
local function duplicateMicroButtonAndBagsBar()
    MicroButtonAndBagsBar:Hide()
    local duplicate = CreateFrame("Frame", "MicroButtonAndBagsBarMovable", UIParent)
    duplicate:SetSize(232, 80)
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
    CharacterMicroButton:SetParent(duplicate)
    SpellbookMicroButton:SetParent(duplicate)
    TalentMicroButton:SetParent(duplicate)
    AchievementMicroButton:SetParent(duplicate)
    QuestLogMicroButton:SetParent(duplicate)
    GuildMicroButton:SetParent(duplicate)
    LFDMicroButton:SetParent(duplicate)
    CollectionsMicroButton:SetParent(duplicate)
    EJMicroButton:SetParent(duplicate)
    StoreMicroButton:SetParent(duplicate)
    MainMenuMicroButton:SetParent(duplicate)
    HelpMicroButton:SetParent(duplicate)
    
    MainMenuBarBackpackButton:SetPoint("TOPRIGHT", duplicate, -4, 2)
    MainMenuBarBackpackButton:SetParent(duplicate)
    BagBarExpandToggle:SetParent(duplicate)
    CharacterBag0Slot:SetParent(duplicate)
    CharacterBag1Slot:SetParent(duplicate)
    CharacterBag2Slot:SetParent(duplicate)
    CharacterBag3Slot:SetParent(duplicate)
    CharacterReagentBag0Slot:SetParent(duplicate)
    
    return duplicate
end

-- Call this on a frame to register it for capture during Edit Mode
-- param1: frame, the Frame to register
-- param2: name, localized name to appear when the frame is selected during Edit Mode
-- param3: db, a table in your saved variables to save the frame position in
function lib.RegisterFrame(frame, name, db)
    -- IMPORTANT: force update every patch incase of UI changes that cause problems and/or make this library redundant!
    if not (GetBuildInfo() == "10.0.0") then return end

    if frame == MicroButtonAndBagsBar then
        if MicroButtonAndBagsBarMovable then return end
        frame = duplicateMicroButtonAndBagsBar()
    end
    
     
    table.insert(frames, frame)
    --table.insert(coordinateDB, db)
    
    Mixin(frame, EditModeSystemMixin)
    
    frame.system = index
    index = index + 1

    --frame.SetScaleBase = frame.SetScale;
	--frame.SetScale = frame.SetScaleOverride;

	--frame.SetPointBase = frame.SetPoint;
	--frame.SetPoint = frame.SetPointOverride;

	--frame.ClearAllPointsBase = frame.ClearAllPoints;
	--frame.ClearAllPoints = frame.ClearAllPointsOverride;

	frame.Selection = CreateFrame("Frame", nil, frame, "EditModeSystemSelectionTemplate")
    frame.Selection:SetAllPoints(frame)
    frame.defaultHideSelection = true
    frame.Selection:Hide()
    
    frame.systemNameString = name or "Unnamed Frame"
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
        print(self:GetRect())
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
end

hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function(self)
    for _, frame in ipairs(frames) do
	   frame:SetHasActiveChanges(false)
	   frame:HighlightSystem();
    end
end)

hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
    for _, frame in ipairs(frames) do
        frame:ClearHighlight();
    	frame:StopMovingOrSizing();
    end
end)

hooksecurefunc(EditModeManagerFrame, "SelectSystem", function(self, systemFrame)
    for _, frame in ipairs(frames) do
        if systemFrame ~= frame then
            frame:HighlightSystem()
        end
    end
end)
