local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

local isEnabled, hideNames, hideIcons, barsFillToEmpty
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
        if not isEnabled then return end
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
                if (not isEnabled) or (not itemFrame:GetSpellID()) then
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
end

function addon:initCooldownManager()
    if not addon.db.global.EMEOptions.cooldownManager then return end
    
    local wasConverted
    local function updateAll()
        if not isEnabled then return end
        for _, itemFrame in pairs(EssentialCooldownViewer:GetItemFrames()) do
            initCustomBuffBar(itemFrame)
            itemFrame.EMEBuffBar:Show()
            itemFrame:Hide()
        end
    end
    
    --hooksecurefunc(EssentialCooldownViewer, "OnAcquireItemFrame", updateAll)
    hooksecurefunc(EssentialCooldownViewer, "Layout", updateAll)
    
    lib:RegisterCustomCheckbox(EssentialCooldownViewer, "Convert To Bar",
        function()
            isEnabled = true
            updateAll()
        end,
        function()
            if not isEnabled then return end
            
            isEnabled = false
            for _, itemFrame in pairs(EssentialCooldownViewer:GetItemFrames()) do
                itemFrame:Show()
                itemFrame.EMEBuffBar:Hide()
            end
        end,
        "ConvertToBar")
    
    lib:RegisterSlider(EssentialCooldownViewer, "Icon Size (Bar version)", "BarIconSize",
        function(value)
            for _, itemFrame in pairs(EssentialCooldownViewer:GetItemFrames()) do
                if itemFrame.EMEBuffBar then
                    itemFrame.EMEBuffBar.Icon:SetScale(value/100)
                end
            end
        end,
        20, 200, 10)
        
    lib:RegisterCustomCheckbox(EssentialCooldownViewer, "Hide Name (Bar version)",
        function()
            hideNames = true
        end,
        function()
            hideNames = false
        end,
        "HideNames")
    
    lib:RegisterCustomCheckbox(EssentialCooldownViewer, "Hide Icon (Bar version)",
        function()
            hideIcons = true
        end,
        function()
            hideIcons = false
        end,
        "HideIcons")
        
    lib:RegisterCustomCheckbox(EssentialCooldownViewer, "Bars Fill To Empty",
        function()
            barsFillToEmpty = true
        end,
        function()
            barsFillToEmpty = false
        end,
        "BarsFillToEmpty")
end