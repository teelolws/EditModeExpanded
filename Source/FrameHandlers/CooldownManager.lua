local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

local z = 1
local x = CreateFrame
local function CreateFrame(...)
    print(z)
    z = z+1
    return x(...)
end

local function initCustomBuffBar(itemFrame)
    if itemFrame.EMEBuffBar then return end
    local buffBar = CreateFrame("Frame", nil, EssentialCooldownViewer)
    itemFrame.EMEBuffBar = buffBar
    buffBar:SetPoint(itemFrame:GetPoint())
    buffBar:Show()
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
    buffBar.CoverBar:SetAllPoints(buffBar.Bar)
    buffBar.CoverBar:SetStatusBarTexture("UI-HUD-CoolDownManager-Bar")
    buffBar.CoverBar:SetStatusBarColor(1, 0.5, 0.25)
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
    buffBar.Name = buffBar:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    buffBar.Name:SetJustifyH("LEFT")
    buffBar.Name:SetJustifyV("MIDDLE")
    buffBar.Name:SetPoint("TOPLEFT", 5, 0)
    buffBar.Name:SetPoint("BOTTOMRIGHT", -25, 0)
    buffBar.Duration = buffBar:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    buffBar.Duration:SetJustifyH("LEFT")
    buffBar.Duration:SetPoint("RIGHT", -8, 0)
    
    hooksecurefunc(itemFrame, "RefreshData", function()
        if not buffBar:IsShown() then return end
        itemFrame:Hide()
        if not itemFrame:GetSpellID() then return end
        
        
        local durationObject = C_Spell.GetSpellCooldownDuration(itemFrame:GetSpellID())
        
        local spellTexture = itemFrame:GetSpellTexture()
	    buffBar.Icon.Icon:SetTexture(spellTexture)
        
        local barFrame = buffBar.Bar
    	local durationFontString = buffBar.Duration
    	local pipTexture = buffBar.Bar.Pip
        
        local isZero = durationObject:IsZero()
        buffBar.CoverBar:SetAlphaFromBoolean(isZero)
        
        barFrame:SetTimerDuration(durationObject)
        if durationFontString:IsShown() then
            if itemFrame.EMEDurationTicker then itemFrame.EMEDurationTicker:Cancel() end
            itemFrame.EMEDurationTicker = C_Timer.NewTicker(1, function()
                durationObject = C_Spell.GetSpellCooldownDuration(itemFrame:GetSpellID())
                durationFontString:SetText(string.format(COOLDOWN_DURATION_SEC, durationObject:GetRemainingDuration()))
            end)
        end
                
        pipTexture:SetShown(C_Spell.IsSpellUsable(itemFrame:GetSpellID()))
        --)

        --itemFrame:Hide()
    end)
end

function addon:initCooldownManager()
    if not addon.db.global.EMEOptions.cooldownManager then return end
    
    local wasConverted
    lib:RegisterCustomCheckbox(EssentialCooldownViewer, "Convert To Bar",
        function()
            wasConverted = true
            
            for _, itemFrame in pairs(EssentialCooldownViewer:GetItemFrames()) do
                initCustomBuffBar(itemFrame)
                if true then return end
            end
        end,
        function()
            if not wasConverted then return end
            
            
        end,
        "ConvertToBar")
    
    
    
    
    
    --[[
    for i = 1, 5 do
        local frame = EssentialCooldownViewer:GetItemFrames()[i]
        local statusBar = CreateFrame("StatusBar", "zzzz", frame)
        statusBar:SetPoint("LEFT", frame, "RIGHT")
        statusBar:SetSize(100, 20)
        statusBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
        statusBar:SetStatusBarColor(0, 1, 0)
        statusBar:SetFillStyle(1)
        frame:HookScript("OnUpdate", function()
            statusBar:SetTimerDuration(C_Spell.GetSpellCooldownDuration(frame:GetSpellID()))
        end)
    end]]
end