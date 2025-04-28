local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local libDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local function getCurrentLoadoutID()
    return C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID()) or PlayerUtil.GetCurrentSpecID() or 0
end

local settingFrame = CreateFrame("Frame", "EMESettingFrame", UIParent, "VerticalLayoutFrame")
settingFrame:SetPoint("CENTER", 0, -200)
settingFrame.Border = CreateFrame("Frame", nil, settingFrame, "DialogBorderTranslucentTemplate")
settingFrame.expand = true
settingFrame.topPadding = 10
settingFrame.bottomPadding = 10
settingFrame.leftPadding = 10
settingFrame.rightPadding = 10
settingFrame.spacing = 10
settingFrame:Hide()
settingFrame:SetFrameStrata("TOOLTIP")

settingFrame.activeFontString = settingFrame:CreateFontString(nil, nil, "GameTooltipText")
settingFrame.activeFontString:SetText("Active Icons")
settingFrame.activeFontString.layoutIndex = 1

settingFrame.activeIcons = CreateFrame("Frame", nil, settingFrame, "HorizontalLayoutFrame")
settingFrame.activeIcons.layoutIndex = 2

settingFrame.inactiveFontString = settingFrame:CreateFontString(nil, nil, "GameTooltipText")
settingFrame.inactiveFontString:SetText("Inactive Icons")
settingFrame.inactiveFontString.layoutIndex = 3

settingFrame.inactiveIcons = CreateFrame("Frame", nil, settingFrame, "HorizontalLayoutFrame")
settingFrame.inactiveIcons.layoutIndex = 4

settingFrame.activeIcons.framePool = CreateFramePool("Frame", settingFrame.activeIcons, EssentialCooldownViewer.itemTemplate)
settingFrame.inactiveIcons.framePool = CreateFramePool("Frame", settingFrame.inactiveIcons, EssentialCooldownViewer.itemTemplate)

settingFrame.closeButton = CreateFrame("Button", nil, settingFrame, "UIPanelCloseButton")
settingFrame.closeButton.ignoreInLayout = true
settingFrame.closeButton:SetPoint("TOPRIGHT", settingFrame, "TOPRIGHT", 3, 4)

hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function() settingFrame:Hide() end)

settingFrame.addRow = CreateFrame("Frame", nil, settingFrame, "HorizontalLayoutFrame")
settingFrame.addRow.layoutIndex = 5
settingFrame.addRow.spacing = 10

settingFrame.addRow.addFontString = settingFrame.addRow:CreateFontString(nil, nil, "GameTooltipText")
settingFrame.addRow.addFontString.layoutIndex = 1
settingFrame.addRow.addFontString:SetText("Add spell ID:")

settingFrame.addRow.addEditBox = CreateFrame("EditBox", nil, settingFrame.addRow, "EditModeDialogLayoutNameEditBoxTemplate")
settingFrame.addRow.addEditBox.layoutIndex = 2
settingFrame.addRow.addEditBox:SetScript("OnEnterPressed", function(self)
	local text = self:GetText()
    
    if string.find(text, "[^%d]") then
        return
    end
    
    table.insert(settingFrame.db, -1 * tonumber(text))
    settingFrame:RefreshSettingFrame()
    settingFrame.viewer:RefreshLayout()
end)
settingFrame.addRow.addEditBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
end)
settingFrame.addRow.addEditBox:SetScript("OnTextChanged", nop)
settingFrame.addRow.addEditBox:SetAutoFocus(false)

local function onSettingIconDrag(self, button)
    self:StartMoving()
end

local function setNewIconIndex(self, newIndex)
    local db = settingFrame.db
    local cooldownID = db[self.layoutIndex]
    
    if self.layoutIndex < newIndex then
        for i = (self.layoutIndex + 1), newIndex do
            db[i - 1] = db[i]
        end
        db[newIndex] = cooldownID
    else
        for i = (self.layoutIndex - 1), newIndex, -1 do
            db[i + 1] = db[i]
        end
        db[newIndex] = cooldownID
    end
end

local function onSettingIconStop(self)
    for icon in settingFrame.activeIcons.framePool:EnumerateActive() do
        if (icon ~= self) and icon:IsMouseOver() then
            setNewIconIndex(self, icon.layoutIndex)
            break
        end
    end
    self:StopMovingOrSizing()
    RunNextFrame(function()
        settingFrame:RefreshSettingFrame()
        settingFrame.viewer:RefreshLayout()
    end)
end

local function hideButtonOnClick(self)
    local layoutIndex = self.icon.layoutIndex
    local cooldownID = self.icon:GetCooldownID()
    local cooldownIDs = settingFrame.db
    
    if cooldownID < -2 then
        table.remove(cooldownIDs, layoutIndex)
        settingFrame:RefreshSettingFrame()
        settingFrame.viewer:RefreshLayout()
        return
    end
    
    if cooldownID > 0 then
        local found
        for _, cid2 in pairs(settingFrame.viewer:GetCooldownIDs()) do
            if cooldownID == cid2 then
                found = true
            end
        end
        
        if not found then
            table.remove(cooldownIDs, layoutIndex)
            settingFrame:RefreshSettingFrame()
            settingFrame.viewer:RefreshLayout()
            return
        end
    end
    
    local newIndex = -1 * cooldownID
    if cooldownID < 0 then
        newIndex = cooldownID
    end
    cooldownIDs[newIndex] = cooldownID
    table.remove(cooldownIDs, layoutIndex)
    
    settingFrame:RefreshSettingFrame()
    settingFrame.viewer:RefreshLayout()
end

local function restoreButtonOnClick(self)
    local layoutIndex = self.layoutIndex
    local cooldownID = self:GetCooldownID()
    local cooldownIDs = settingFrame.db
    
    local oldIndex = -1 * cooldownID
    if cooldownID < 0 then
        oldIndex = cooldownID
    end
    cooldownIDs[oldIndex] = nil
    table.insert(cooldownIDs, cooldownID)
    
    settingFrame:RefreshSettingFrame()
    settingFrame.viewer:RefreshLayout()
end

local a = true
function settingFrame:RefreshSettingFrame()
    settingFrame.activeIcons.framePool:ReleaseAll()
    
    local cooldownIDs = self.db
    for i, cooldownID in ipairs(cooldownIDs) do
        local icon = settingFrame.activeIcons.framePool:Acquire()
        icon.layoutIndex = i
        icon:SetCooldownID(cooldownID)
        if cooldownID == -2 then
    	    local spellTexture = GetInventoryItemTexture("player", INVSLOT_TRINKET1)
            icon:GetIconTexture():SetTexture(spellTexture)
        elseif cooldownID == -1 then
            local spellTexture = GetInventoryItemTexture("player", INVSLOT_TRINKET2)
            icon:GetIconTexture():SetTexture(spellTexture)
        elseif cooldownID < -2 then
            spellTexture = C_Spell.GetSpellTexture(cooldownID * -1)
            icon:GetIconTexture():SetTexture(spellTexture)
        end
        
        icon:Show()
        
        icon:SetMovable(true)
        icon:EnableMouse(true)
        icon:RegisterForDrag("LeftButton")
        if not icon:GetScript("OnDragStart") then icon:SetScript("OnDragStart", onSettingIconDrag) end
        if not icon:GetScript("OnDragStop") then icon:SetScript("OnDragStop", onSettingIconStop) end
        if not icon.hideButton then
            icon.hideButton = CreateFrame("Button", nil, icon, "UIPanelCloseButton")
            icon.hideButton:SetPoint("TOPRIGHT", icon, "TOPRIGHT", 1, 1)
            icon.hideButton:SetScale(0.5)
            icon.hideButton.icon = icon
            icon.hideButton:SetScript("OnClick", hideButtonOnClick)
        end
    end
    
    settingFrame.inactiveIcons.framePool:ReleaseAll()
    
    local layoutIndex = 1
    for i, cooldownID in pairs(cooldownIDs) do
        if i < 1 then
            local icon = settingFrame.inactiveIcons.framePool:Acquire()
            icon.layoutIndex = layoutIndex
            layoutIndex = layoutIndex + 1
            icon:SetCooldownID(cooldownID)
            if cooldownID == -2 then
        	    local spellTexture = GetInventoryItemTexture("player", INVSLOT_TRINKET1)
                icon:GetIconTexture():SetTexture(spellTexture)
            end
            if cooldownID == -1 then
                local spellTexture = GetInventoryItemTexture("player", INVSLOT_TRINKET2)
                icon:GetIconTexture():SetTexture(spellTexture)
            end
            icon:Show()
            
            icon:EnableMouse(true)
            icon:SetScript("OnMouseUp", restoreButtonOnClick)
        end
    end
    
    settingFrame:Layout()
end

-- custom cooldown IDs will be added to the set like this:
-- the spell ID but as a negative, eg spatial rift spell ID is 256948 so will be listed as cooldown ID -256948
-- trinket 1 = -2, checked and confirmed spell ID 2 is not used
-- trinket 2 = -1, checked and confirmed spell ID 1 is an obsolete spell "Word of Recall"

local getCacheCooldownValues = {}
local function hookCacheCooldownValues(self)
    if getCacheCooldownValues[self] then return end
    if not self.CacheCooldownValues then return end
    
    hooksecurefunc(self, "CacheCooldownValues", function(self)
        if not self.cooldownID then return end
        if self.cooldownID >= 0 then return end
    	
        if self.cooldownID > -3 then
            local invSlotId = (self.cooldownID == -2) and INVSLOT_TRINKET1 or INVSLOT_TRINKET2
            local start, duration, enable = GetInventoryItemCooldown("player", invSlotId)
		    self.cooldownEnabled = start
		    self.cooldownStartTime = start
		    self.cooldownDuration = duration
            self.cooldownModRate = 1
        else
            local cooldownInfo = C_Spell.GetSpellCooldown(self.cooldownID * -1)
            self.cooldownEnabled = cooldownInfo.isEnabled;
		    self.cooldownStartTime = cooldownInfo.startTime;
		    self.cooldownDuration = cooldownInfo.duration;
		    self.cooldownModRate = cooldownInfo.modRate;
		end
        
		self.cooldownSwipeColor = CreateColor(0, 0, 0, 0.7);
		self.cooldownShowDrawEdge = false;
		self.cooldownShowSwipe = true;
		self.cooldownUseAuraDisplayTime = false;
		self.cooldownPaused = false;
        self.cooldownDesaturated = false;
		self.cooldownPlayFlash = false;
    end)
    
    getCacheCooldownValues[self] = true
end

local refreshSpellTextureHooks = {}
local function hookRefreshSpellTexture(self)
    if refreshSpellTextureHooks[self] then return end
    
    hooksecurefunc(self, "RefreshSpellTexture", function(self)
        if not self.cooldownID then return end
        if self.cooldownID >= 0 then return end
        
        local spellTexture
        if self.cooldownID > -3 then
            local invSlotId = (self.cooldownID == -2) and INVSLOT_TRINKET1 or INVSLOT_TRINKET2
    	    spellTexture = GetInventoryItemTexture("player", invSlotId)
        else
            spellTexture = C_Spell.GetSpellTexture(self.cooldownID * -1)
        end        
        self:GetIconTexture():SetTexture(spellTexture)
    end)
    self:RefreshSpellTexture()
    
    refreshSpellTextureHooks[self] = true
end

local function integrityCheck(self, db, includeTrinkets)
    local cooldownIDs = self:GetCooldownIDs()
    -- integrity check: if any cooldown IDs are missing from the local database, add them to the end
    for _, cooldownID in pairs(cooldownIDs) do
        local found
        for _, cid2 in pairs(db) do
            if cooldownID == cid2 then
                found = true
            end
        end
        if not found then
            table.insert(db, cooldownID)
        end
    end
    
    -- integrity check: add trinkets if they're missing, at slots -2 and -1
    if includeTrinkets then
        local found1, found2
        for _, cooldownID in pairs(db) do
            if cooldownID == -2 then
                found2 = true
            elseif cooldownID == -1 then
                found1 = true
            end
        end
        if not found2 then
            table.insert(db, -2)
        end
        if not found1 then
            table.insert(db, -1)
        end
    end
    
    -- integrity check: remove any duplicates
    for i1, cooldownID in pairs(db) do
        for i2, cid2 in pairs(db) do
            if i1 ~= i2 then
                if cooldownID == cid2 then
                    table.remove(db, i2)
                    break
                end
            end
        end
    end
    
    -- integrity check: remove any cooldown IDs that have no data
    for i = #db, 1, -1 do
        local cooldownID = db[i]
        if (cooldownID > 0) and (not C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)) then
            table.remove(db, i)
        end
    end
end

local function initFrame(frame, db, includeTrinkets)
    lib:RegisterCustomButton(frame, "Rearrange Buttons", function()
        local db = db[getCurrentLoadoutID()]
        settingFrame:SetShown(not settingFrame:IsShown())
        settingFrame.viewer = frame
        settingFrame.db = db
        settingFrame:RefreshSettingFrame()
    end)
    
    hooksecurefunc(frame, "RefreshData", function(self)
        local db = db[getCurrentLoadoutID()]
        integrityCheck(self, db, includeTrinkets)
        
        local cooldownIDs = db

    	for itemFrame in self.itemFramePool:EnumerateActive() do
            
    		local cooldownID = cooldownIDs and cooldownIDs[itemFrame.layoutIndex];
    		if cooldownID then
    			itemFrame:SetCooldownID(cooldownID);
                if cooldownID < 0 then
                    hookRefreshSpellTexture(itemFrame)
                    hookCacheCooldownValues(itemFrame)
                end
    		else
                itemFrame:ClearCooldownID();
    		end
    	end

    	self:RefreshItemsShown()
        self:GetItemContainerFrame():Layout()
    end)
    
    hooksecurefunc(frame, "RefreshLayout", function(self)
        local db = db[getCurrentLoadoutID()]
    	integrityCheck(self, db, includeTrinkets)
        
        self.itemFramePool:ReleaseAll();
        
        for i = 1, #db do
            local itemFrame = self.itemFramePool:Acquire()
            itemFrame.layoutIndex = i
            self:OnAcquireItemFrame(itemFrame)
        end
        
        self:RefreshData()
    end)
    
    frame:RefreshLayout()
    
    lib:RegisterResizable(frame, nil, nil, 1)
end

function addon:initCooldownManager()
    local db = addon.db.global
    if db.EMEOptions.cooldownManager then
        initFrame(EssentialCooldownViewer, addon.db.char.EssentialCooldownViewerSpellIDs, true)
        initFrame(UtilityCooldownViewer, addon.db.char.UtilityCooldownViewerSpellIDs, true)
        initFrame(BuffIconCooldownViewer, addon.db.char.BuffIconCooldownViewerSpellIDs)
        initFrame(BuffBarCooldownViewer, addon.db.char.BuffBarCooldownViewerSpellIDs)
    end
end
