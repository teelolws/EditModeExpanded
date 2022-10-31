local MAJOR, MINOR = "EditModeExpanded-1.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)

local index = 13

local frames = {}

-- Call this on a frame to register it for capture during Edit Mode
function lib.RegisterFrame(frame, name)
    table.insert(frames, frame)
    Mixin(frame, EditModeSystemMixin)
    --frame:HookScript("OnHide", frame.OnSystemHide)
    
    --Enum.EditModeSystem["MenuBar"] = index
    MicroButtonAndBagsBar.system = index
    index = index + 1

    frame.systemNameString = name or "Unnamed Frame"
    frame.Selection = CreateFrame("Frame", nil, frame, "EditModeSystemSelectionTemplate")
    frame.Selection:SetAllPoints(frame)
    frame.defaultHideSelection = true
    frame.Selection:Hide()

    function frame.UpdateMagnetismRegistration() end

    frame.Selection:SetScript("OnMouseDown", function()
    	frame:SelectSystem()
    end)
    
    function frame:SelectSystem()
    	if not self.isSelected then
    		self:SetMovable(true);
    		self.Selection:ShowSelected();
    		--EditModeSystemSettingsDialog:AttachToSystemFrame(self);
    		self.isSelected = true;
    		--self:UpdateMagnetismRegistration();
    	end
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
        if systemFrame ~= MicroButtonAndBagsBar then
            frame:HighlightSystem()
        end
    end
end)

lib.RegisterFrame(MicroButtonAndBagsBar)
lib.RegisterFrame(BuffFrame)