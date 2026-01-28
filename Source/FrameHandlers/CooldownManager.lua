local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

local enableConvertToBar, hideNames, hideIcons, barsFillToEmpty, updateAll

local settingFrame = CreateFrame("Frame", "EMECooldownManagerSettingFrame", UIParent, "VerticalLayoutFrame")
settingFrame.Border = CreateFrame("Frame", nil, settingFrame, "DialogBorderTranslucentTemplate")
settingFrame.expand = true
settingFrame.topPadding = 10
settingFrame.bottomPadding = 10
settingFrame.leftPadding = 10
settingFrame.rightPadding = 10
settingFrame.spacing = 10
settingFrame:Hide()
settingFrame:SetFrameStrata("TOOLTIP")

settingFrame.closeButton = CreateFrame("Button", nil, settingFrame, "UIPanelCloseButton")
settingFrame.closeButton.ignoreInLayout = true
settingFrame.closeButton:SetPoint("TOPRIGHT", settingFrame, "TOPRIGHT", 3, 4)

hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function() settingFrame:Hide() end)

settingFrame.enableConvertToBarCheckButton = CreateFrame("Frame", nil, settingFrame, "ResizeCheckButtonTemplate")
settingFrame.enableConvertToBarCheckButton.layoutIndex = 1
settingFrame.enableConvertToBarCheckButton.fixedWidth = 225
settingFrame.enableConvertToBarCheckButton.fixedHeight = 32

settingFrame.enableConvertToBarCheckButton.Button:SetScript("OnClick", function(self)
    local isChecked = self:GetChecked()
    settingFrame.db.convertToBar = isChecked
    enableConvertToBar = isChecked
    settingFrame.iconSizeSlider.Slider:SetEnabled(isChecked)
    settingFrame.HideNameCheckButton.Button:SetEnabled(isChecked)
    settingFrame.HideIconCheckButton.Button:SetEnabled(isChecked)
    settingFrame.BarsFillToEmptyCheckButton.Button:SetEnabled(isChecked)
    updateAll()
end)

settingFrame.enableConvertToBarCheckButton.Label:SetText("Convert to Bars")
settingFrame.enableConvertToBarCheckButton.Label:SetFontObject(GameFontHighlightMedium)

settingFrame.iconSizeSlider = CreateFrame("Frame", nil, settingFrame, "EditModeSettingSliderTemplate")
settingFrame.iconSizeSlider.layoutIndex = 2
settingFrame.iconSizeSlider.fixedWidth = 250
settingFrame.iconSizeSlider.fixedHeight = 40
CallbackRegistryMixin.OnLoad(settingFrame.iconSizeSlider)
settingFrame.iconSizeSlider.cbrHandles = EventUtil.CreateCallbackHandleContainer()
settingFrame.iconSizeSlider.cbrHandles:RegisterCallback(settingFrame.iconSizeSlider.Slider, MinimalSliderWithSteppersMixin.Event.OnValueChanged, function(self, value)
        if self.InitInProgress then return end
        for _, itemFrame in pairs(settingFrame.viewer:GetItemFrames()) do
            if itemFrame.EMEBuffBar then
                itemFrame.EMEBuffBar.Icon:SetScale(value/100)
            end
        end
        settingFrame.db.iconSize = value
    end, settingFrame.iconSizeSlider)
settingFrame.iconSizeSlider:Show()
        
settingFrame.HideNameCheckButton = CreateFrame("Frame", nil, settingFrame, "ResizeCheckButtonTemplate")
settingFrame.HideNameCheckButton.layoutIndex = 3
settingFrame.HideNameCheckButton.fixedWidth = 225
settingFrame.HideNameCheckButton.fixedHeight = 32

settingFrame.HideNameCheckButton.Button:SetScript("OnClick", function(self)
    hideNames = self:GetChecked()
    settingFrame.db.hideNames = hideNames
end)

settingFrame.HideNameCheckButton.Label:SetText("Hide Names")
settingFrame.HideNameCheckButton.Label:SetFontObject(GameFontHighlightMedium)

settingFrame.HideIconCheckButton = CreateFrame("Frame", nil, settingFrame, "ResizeCheckButtonTemplate")
settingFrame.HideIconCheckButton.layoutIndex = 4
settingFrame.HideIconCheckButton.fixedWidth = 225
settingFrame.HideIconCheckButton.fixedHeight = 32

settingFrame.HideIconCheckButton.Button:SetScript("OnClick", function(self)
    hideIcons = self:GetChecked()
    settingFrame.db.hideIcons = hideIcons
end)

settingFrame.HideIconCheckButton.Label:SetText("Hide Icons")
settingFrame.HideIconCheckButton.Label:SetFontObject(GameFontHighlightMedium)

settingFrame.BarsFillToEmptyCheckButton = CreateFrame("Frame", nil, settingFrame, "ResizeCheckButtonTemplate")
settingFrame.BarsFillToEmptyCheckButton.layoutIndex = 5
settingFrame.BarsFillToEmptyCheckButton.fixedWidth = 225
settingFrame.BarsFillToEmptyCheckButton.fixedHeight = 32

settingFrame.BarsFillToEmptyCheckButton.Button:SetScript("OnClick", function(self)
    barsFillToEmpty = self:GetChecked()
    settingFrame.db.barsFillToEmpty = barsFillToEmpty
end)

settingFrame.BarsFillToEmptyCheckButton.Label:SetText("Bars fill to empty")
settingFrame.BarsFillToEmptyCheckButton.Label:SetFontObject(GameFontHighlightMedium)

local function initCustomBuffBar(itemFrame)
    if itemFrame.EMEBuffBar then return end
    local buffBar = CreateFrame("Frame", nil, EssentialCooldownViewer)
    itemFrame.EMEBuffBar = buffBar
    buffBar:SetPoint("BOTTOMLEFT", itemFrame, "BOTTOMLEFT")
    buffBar:SetScale(itemFrame.iconScale or 1)
    buffBar:SetSize(220, 30)
    buffBar.Icon = CreateFrame("Frame", nil, buffBar)
    buffBar.Icon:SetFrameLevel(512)
    buffBar.Icon:SetPoint("LEFT")
    buffBar.Icon:SetSize(30, 30)
    buffBar.Icon.Icon = buffBar.Icon:CreateTexture(nil, "ARTWORK")
    buffBar.Icon.Icon:SetAllPoints(buffBar.Icon)
    local mask = buffBar.Icon:CreateMaskTexture(nil, "ARTWORK")
    mask:SetAllPoints(buffBar.Icon.Icon)
    mask:SetAtlas("UI-HUD-CoolDownManager-Mask")
    buffBar.Icon.Icon:AddMaskTexture(mask)
    local texture = buffBar.Icon:CreateTexture(nil, "OVERLAY")
    texture:SetAtlas("UI-HUD-CoolDownManager-IconOverlay")
    texture:SetPoint("TOPLEFT", -6, 5)
    texture:SetPoint("BOTTOMRIGHT", 6, -5)
    buffBar.Icon.Applications = buffBar.Icon:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    buffBar.Icon.Applications:SetJustifyH("RIGHT")
    buffBar.Icon.Applications:SetSize(32, 10)
    buffBar.Icon.Applications:SetPoint("BOTTOMRIGHT", -5, 5)
    buffBar.Bar = CreateFrame("StatusBar", nil, buffBar)
    buffBar.Bar:SetFrameLevel(511)
    buffBar.Bar:SetHeight(19)
    buffBar.Bar:SetPoint("LEFT", buffBar.Icon, "RIGHT", -3)
    buffBar.Bar:SetPoint("RIGHT")
    --texture = buffBar.Bar:GetStatusBarTexture()
    buffBar.Bar:SetStatusBarTexture("UI-HUD-CoolDownManager-Bar")
    --texture:SetAllPoints(buffBar.Bar)
    buffBar.Bar:SetStatusBarColor(1, 0.5, 0.25)
    buffBar.CoverBar = CreateFrame("StatusBar", nil, buffBar.Bar)
    buffBar.CoverBar:SetFrameLevel(509)
    buffBar.CoverBar:SetAllPoints(buffBar.Bar)
    buffBar.CoverBar:SetStatusBarTexture("UI-HUD-CoolDownManager-Bar")
    buffBar.CoverBar:SetStatusBarColor(0, 1, 0.25)
    buffBar.CoverBar:SetMinMaxValues(0, 1)
    buffBar.CoverBar:SetValue(1)
    texture = buffBar.Bar:CreateTexture(nil, "BACKGROUND")
    texture:SetAtlas("UI-HUD-CoolDownManager-Bar-BG")
    texture:SetHeight(30)
    texture:SetPoint("LEFT", -2, -2)
    texture:SetPoint("RIGHT", 6, -2)
    buffBar.Bar.Pip = buffBar.Bar:CreateTexture(nil, "OVERLAY")
    buffBar.Bar.Pip:SetAtlas("UI-HUD-CoolDownManager-Bar-Pip", true)
	buffBar.Bar.Pip:SetPoint("CENTER", buffBar.Bar:GetStatusBarTexture(), "RIGHT", 0, 0)
    buffBar.Bar.Name = buffBar.Bar:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    buffBar.Bar.Name:SetJustifyH("LEFT")
    buffBar.Bar.Name:SetJustifyV("MIDDLE")
    buffBar.Bar.Name:SetPoint("TOPLEFT", 5, 0)
    buffBar.Bar.Name:SetPoint("BOTTOMRIGHT", -25, 0)
    buffBar.Bar.Duration = buffBar.Bar:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    buffBar.Bar.Duration:SetJustifyH("LEFT")
    buffBar.Bar.Duration:SetPoint("RIGHT", -8, 0)
    
    hooksecurefunc(itemFrame, "RefreshData", function()
        if not enableConvertToBar then return end
        itemFrame:Hide()
        if not itemFrame:GetSpellID() then return end
        
        local durationObject = C_Spell.GetSpellCooldownDuration(itemFrame:GetSpellID())
        
        -- RefreshSpellTexture
        local spellTexture = itemFrame:GetSpellTexture()
        if hideIcons then
            buffBar.Icon:Hide()
        else
            buffBar.Icon:Show()
	        buffBar.Icon.Icon:SetTexture(spellTexture)
        end
        
        -- RefreshCooldownInfo
        local barFrame = buffBar.Bar
    	local durationFontString = barFrame.Duration
    	local pipTexture = barFrame.Pip
        buffBar.CoverBar:SetAlphaFromBoolean(durationObject:IsZero())
        barFrame:SetTimerDuration(durationObject, nil, barsFillToEmpty and 1 or 0)
        if EssentialCooldownViewer.timerShown then
            durationFontString:Show()
            if itemFrame.EMEDurationTicker then itemFrame.EMEDurationTicker:Cancel() end
            itemFrame.EMEDurationTicker = C_Timer.NewTicker(0.2, function()
                if (not enableConvertToBar) or (not itemFrame:GetSpellID()) then
                    itemFrame.EMEDurationTicker:Cancel()
                    return
                end
                durationObject = C_Spell.GetSpellCooldownDuration(itemFrame:GetSpellID())
                durationFontString:SetText(string.format(COOLDOWN_DURATION_SEC, durationObject:GetRemainingDuration()))
                durationFontString:SetAlphaFromBoolean(durationObject:IsZero(), 0, 255)
            end)
        else
            durationFontString:Hide()
        end
        pipTexture:SetAlphaFromBoolean(durationObject:IsZero(), 0, 255)
        
        -- RefreshName
        local nameFontString = barFrame.Name
    	if hideNames then
            nameFontString:Hide()
        else
            nameFontString:Show()
    		nameFontString:SetText(C_Spell.GetSpellName(itemFrame:GetSpellID()))
    	end
    	
        
        -- RefreshApplications
    	--local applicationsText = itemFrame:GetApplicationsText();
    	--local applicationsFontString = buffBar.Icon.Applications
    	--applicationsFontString:SetText(applicationsText);
    end)
    
    -- setup defaults
    buffBar.Icon.Icon:SetTexture(itemFrame:GetSpellTexture())
    if itemFrame:GetSpellID() then
        buffBar.Bar:SetTimerDuration(C_Spell.GetSpellCooldownDuration(itemFrame:GetSpellID()), nil, barsFillToEmpty and 1 or 0)
        if not hideNames then
            buffBar.Bar.Name:SetText(C_Spell.GetSpellName(itemFrame:GetSpellID()))
        end
    end
end

function addon:initCooldownManager()
    if not addon.db.global.EMEOptions.cooldownManager then return end
    
    function updateAll()
        if not enableConvertToBar then return end
        for _, itemFrame in pairs(EssentialCooldownViewer:GetItemFrames()) do
            initCustomBuffBar(itemFrame)
            itemFrame.EMEBuffBar:Show()
            itemFrame:Hide()
        end
    end
    
    --hooksecurefunc(EssentialCooldownViewer, "OnAcquireItemFrame", updateAll)
    hooksecurefunc(EssentialCooldownViewer, "Layout", updateAll)
        
    local getSettingDB
    getSettingDB = lib:RegisterCustomButton(EssentialCooldownViewer, "Show More Settings", function()
        settingFrame:SetShown(not settingFrame:IsShown())
        settingFrame.viewer = EssentialCooldownViewer
        settingFrame.db = getSettingDB()
        settingFrame.enableConvertToBarCheckButton.Button:SetChecked(settingFrame.db.convertToBar)
        settingFrame:SetPoint("TOPRIGHT", EditModeExpandedSystemSettingsDialog, "TOPLEFT")
        settingFrame.iconSizeSlider:SetupSetting({
            settingName = "Icon Size",
            displayInfo = {
                minValue = 1,
                maxValue = 200,
                stepSize = 1,
            },
            currentValue = settingFrame.db.iconSize or 100,
        })
        settingFrame:Layout()
    end, "CooldownManagerExtraSettings")
    
    local function updateProfile()
        local db = getSettingDB()
        enableConvertToBar = db.convertToBar or false -- can't pass `nil` in to a SetEnabled, has to explicitly be `false`
        barsFillToEmpty = db.barsFillToEmpty
        hideNames = db.hideNames
        hideIcons = db.hideIcons
        settingFrame.iconSizeSlider.Slider:SetEnabled(enableConvertToBar)
        settingFrame.HideNameCheckButton.Button:SetEnabled(enableConvertToBar)
        settingFrame.HideIconCheckButton.Button:SetEnabled(enableConvertToBar)
        settingFrame.BarsFillToEmptyCheckButton.Button:SetEnabled(enableConvertToBar)
        updateAll()
    end
    
    C_Timer.After(2, updateProfile)
    EventRegistry:RegisterFrameEventAndCallback("EDIT_MODE_LAYOUTS_UPDATED", updateProfile)
end