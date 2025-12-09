local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local libDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local ITEM_ID_PADDING = 9999999

function addon:initCooldownManager()
    local globalDB = addon.db.global
    if globalDB.EMEOptions.cooldownManager then

        local function refreshAll()
            EssentialCooldownViewer:RefreshLayout()
            UtilityCooldownViewer:RefreshLayout()
            BuffBarCooldownViewer:RefreshLayout()
        end

        local function getCurrentLoadoutID(self)
            local cooldownIDs = self:GetCooldownIDs()
            
            local loadoutString = ""
            for _, cooldownID in ipairs(cooldownIDs) do
                loadoutString = loadoutString..cooldownID.."-"
            end
            
            return loadoutString
        end

        local settingFrame = CreateFrame("Frame", "EMECooldownManagerSettingFrame", UIParent, "VerticalLayoutFrame")
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

        -- Formerly used for displayed which icons are enabled, repurposed to icons added via this addon but using the old name
        settingFrame.activeFontString = settingFrame:CreateFontString(nil, nil, "GameTooltipText")
        settingFrame.activeFontString:SetText("Active Icons")
        settingFrame.activeFontString.layoutIndex = 1

        settingFrame.activeIcons = CreateFrame("Frame", nil, settingFrame, "HorizontalLayoutFrame")
        settingFrame.activeIcons.layoutIndex = 2
        settingFrame.activeIcons.framePool = CreateFramePool("Frame", settingFrame.activeIcons, EssentialCooldownViewer.itemTemplate)

        settingFrame.closeButton = CreateFrame("Button", nil, settingFrame, "UIPanelCloseButton")
        settingFrame.closeButton.ignoreInLayout = true
        settingFrame.closeButton:SetPoint("TOPRIGHT", settingFrame, "TOPRIGHT", 3, 4)

        hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function() settingFrame:Hide() end)

        settingFrame.addRow = CreateFrame("Frame", nil, settingFrame, "HorizontalLayoutFrame")
        settingFrame.addRow.layoutIndex = 3
        settingFrame.addRow.spacing = 10

        settingFrame.addRow.addFontString = settingFrame.addRow:CreateFontString(nil, nil, "GameTooltipText")
        settingFrame.addRow.addFontString.layoutIndex = 1
        settingFrame.addRow.addFontString:SetText("Add spell ID:")

        settingFrame.addRow.addEditBox = CreateFrame("EditBox", nil, settingFrame.addRow, "EditModeDialogLayoutNameEditBoxTemplate")
        settingFrame.addRow.addEditBox.layoutIndex = 2
        settingFrame.addRow.addEditBox:SetNumeric(true)
        settingFrame.addRow.addEditBox:SetScript("OnEnterPressed", function(self)
            local input = self:GetNumber()
            table.insert(settingFrame.db, -1 * input)
            settingFrame:RefreshSettingFrame()
            settingFrame.viewer:RefreshLayout()
        end)
        settingFrame.addRow.addEditBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)
        settingFrame.addRow.addEditBox:SetScript("OnTextChanged", nop)
        settingFrame.addRow.addEditBox:SetAutoFocus(false)
        
        settingFrame.addItemRow = CreateFrame("Frame", nil, settingFrame, "HorizontalLayoutFrame")
        settingFrame.addItemRow.layoutIndex = 4
        settingFrame.addItemRow.spacing = 10
        
        settingFrame.addItemRow.addFontString = settingFrame.addItemRow:CreateFontString(nil, nil, "GameTooltipText")
        settingFrame.addItemRow.addFontString.layoutIndex = 1
        settingFrame.addItemRow.addFontString:SetText("Add Item ID:")
        
        settingFrame.addItemRow.addEditBox = CreateFrame("EditBox", nil, settingFrame.addItemRow, "EditModeDialogLayoutNameEditBoxTemplate")
        settingFrame.addItemRow.addEditBox.layoutIndex = 2
        settingFrame.addItemRow.addEditBox:SetNumeric(true)
        settingFrame.addItemRow.addEditBox:SetScript("OnEnterPressed", function(self)
            local input = self:GetNumber()
            -- crude way to implement a different datatype but its only for 2 patches then all this goes *poof*
            table.insert(settingFrame.db, ITEM_ID_PADDING + input)
            settingFrame:RefreshSettingFrame()
            settingFrame.viewer:RefreshLayout()
        end)
        settingFrame.addItemRow.addEditBox:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)
        settingFrame.addItemRow.addEditBox:SetScript("OnTextChanged", nop)
        settingFrame.addItemRow.addEditBox:SetAutoFocus(false)

        local function onSettingIconDrag(self)
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
            
            if (cooldownID > ITEM_ID_PADDING) or (cooldownID < -2) then
                table.remove(cooldownIDs, layoutIndex)
                settingFrame:RefreshSettingFrame()
                settingFrame.viewer:RefreshLayout()
                return
            elseif cooldownID >= 0 then
                print("EME: Use Blizzard's UI to hide this icon")
                return
            end
            
            
            --[[
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
            end]]
            
            --local newIndex = -1 * cooldownID
            --if cooldownID < 0 then
            --    newIndex = cooldownID
            --end
            --cooldownIDs[newIndex] = cooldownID
            for k, v in pairs(cooldownIDs) do
                if (v == cooldownID) or (v == (-1 * cooldownID)) then
                    table.remove(cooldownIDs, k)
                end
            end
            
            
            settingFrame:RefreshSettingFrame()
            settingFrame.viewer:RefreshLayout()
        end

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
                    local spellTexture = C_Spell.GetSpellTexture(cooldownID * -1)
                    icon:GetIconTexture():SetTexture(spellTexture)
                elseif cooldownID > ITEM_ID_PADDING then
                    local _, _, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(cooldownID - ITEM_ID_PADDING)
                    icon:GetIconTexture():SetTexture(itemTexture)
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
                icon.hideButton:SetShown((cooldownID < 0) or (cooldownID > ITEM_ID_PADDING))
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
                if (self.cooldownID >= 0) and (self.cooldownID < ITEM_ID_PADDING) then return end
            	
                if self.cooldownID > ITEM_ID_PADDING then
                    local startTimeSeconds, durationSeconds, enableCooldownTimer = C_Item.GetItemCooldown(self.cooldownID - ITEM_ID_PADDING)
                    self.cooldownEnabled = enableCooldownTimer
                    self.cooldownStartTime = startTimeSeconds
                    self.cooldownDuration = durationSeconds
                    self.cooldownModRate = 1
                elseif self.cooldownID > -3 then
                    local invSlotId = (self.cooldownID == -2) and INVSLOT_TRINKET1 or INVSLOT_TRINKET2
                    local start, duration = GetInventoryItemCooldown("player", invSlotId)
        		    self.cooldownEnabled = start
        		    self.cooldownStartTime = start
        		    self.cooldownDuration = duration
                    self.cooldownModRate = 1
                else
                    local cooldownInfo = C_Spell.GetSpellCooldown(self.cooldownID * -1)
                    if cooldownInfo then
                        self.cooldownEnabled = cooldownInfo.isEnabled;
            		    self.cooldownStartTime = cooldownInfo.startTime;
            		    self.cooldownDuration = cooldownInfo.duration;
            		    self.cooldownModRate = cooldownInfo.modRate;
                    end
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

        local refreshCooldownInfoHooks = {}
        local function hookRefreshCooldownInfo(self)
            if refreshCooldownInfoHooks[self] then return end
            if not self.RefreshCooldownInfo then return end
            
            if self:GetParent() == BuffBarCooldownViewer then
                hooksecurefunc(self, "RefreshCooldownInfo", function(self)
                	if not self.cooldownID then return end
                    if self.cooldownID >= 0 then return end
                    
                    local barFrame = self:GetBarFrame();
                	local durationFontString = self:GetDurationFontString();
                	local pipTexture = self:GetPipTexture();

                	local auraData = C_UnitAuras.GetPlayerAuraBySpellID(self.cooldownID * -1)
                    if not auraData then return end
                    local expirationTime, duration = auraData.expirationTime, auraData.duration
                	local currentTime = expirationTime - GetTime();

                	if currentTime > 0 then
                		barFrame:SetMinMaxValues(0, duration);
                		barFrame:SetValue(currentTime);

                		if durationFontString:IsShown() then
                			local time = string.format(COOLDOWN_DURATION_SEC, currentTime);
                			durationFontString:SetText(time);
                		end

                		pipTexture:SetShown(true);
                	else
                		barFrame:SetMinMaxValues(0, 0);
                		barFrame:SetValue(0);

                		if durationFontString:IsShown() then
                			durationFontString:SetText("");
                		end

                		pipTexture:SetShown(false);
                	end
                end)
                
                hooksecurefunc(self, "RefreshName", function(self)
                	if not self.cooldownID then return end
                    if self.cooldownID >= 0 then return end
                            
                	local nameFontString = self:GetNameFontString();
                	if not nameFontString:IsShown() then
                		return;
                	end
                    nameFontString:SetText(C_Spell.GetSpellName(self.cooldownID * -1))
                end)
            end
            
            refreshCooldownInfoHooks[self] = true
        end
        
        local refreshSpellTextureHooks = {}
        local function hookRefreshSpellTexture(self)
            if refreshSpellTextureHooks[self] then return end
            
            hooksecurefunc(self, "RefreshSpellTexture", function(self)
                if not self.cooldownID then return end
                if (self.cooldownID >= 0) and (self.cooldownID < ITEM_ID_PADDING) then return end
                
                local spellTexture
                if self.cooldownID > ITEM_ID_PADDING then
                    local _, _, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(self.cooldownID - ITEM_ID_PADDING)
                    spellTexture = itemTexture
                elseif self.cooldownID > -3 then
                    local invSlotId = (self.cooldownID == -2) and INVSLOT_TRINKET1 or INVSLOT_TRINKET2
            	    spellTexture = GetInventoryItemTexture("player", invSlotId)
                else
                    spellTexture = C_Spell.GetSpellTexture(self.cooldownID * -1)
                end
                
                self:GetIconTexture():SetTexture(spellTexture)
                for _, region in pairs({self:GetRegions()}) do
                    -- extra care here in case other non-Textures get added as regions
                    if (region:GetObjectType() == "Texture") and (region:GetAtlas() == "UI-HUD-CoolDownManager-IconOverlay") then
                        region:SetShown(spellTexture ~= nil)
                    end
                end
            end)
            self:RefreshSpellTexture()
            
            refreshSpellTextureHooks[self] = true
        end

        local refreshActiveHooks = {}
        local function hookRefreshActive(self)
            if refreshActiveHooks[self] then return end
            
            if self:GetParent() == BuffBarCooldownViewer then
                hooksecurefunc(self, "RefreshActive", function()
                    if not self.cooldownID then return self:SetIsActive(false) end
                    if self.cooldownID >= 0 then return self:SetIsActive(false) end
                    
                    local auraData = C_UnitAuras.GetPlayerAuraBySpellID(self.cooldownID * -1)
                	if auraData then
                		-- Auras with an expirationTime of 0 are infinite and considered active until they are removed.
                		if auraData.expirationTime == 0 then
                			return self:SetIsActive(true)
                		end

                		return self:SetIsActive(auraData.expirationTime > GetTime())
                	end

                	return self:SetIsActive(false)
                end)
            end
            
            refreshActiveHooks[self] = true
        end

        local refreshSpellChargeInfoHooks = {}
        local function hookRefreshSpellChargeInfo(self)
            if refreshSpellChargeInfoHooks[self] then return end
            
            if (self:GetParent() == EssentialCooldownViewer) or (self:GetParent() == UtilityCooldownViewer) then
                hooksecurefunc(self, "RefreshSpellChargeInfo", function()
                    if not self.cooldownID then return end
                    if self.cooldownID >= 0 then return end
                    
                    local spellChargeInfo = C_Spell.GetSpellCharges(self.cooldownID * -1)
                    if spellChargeInfo and spellChargeInfo.maxCharges > 1 then
                    	self.cooldownChargesShown = true;
                    	self.cooldownChargesCount = spellChargeInfo.currentCharges;
                    else
                        self.cooldownChargesCount = C_Spell.GetSpellCastCount(self.cooldownID * -1);
                        self.cooldownChargesShown = self.cooldownChargesCount > 0;
                    end

                  	local chargeCountFrame = self:GetChargeCountFrame();
                  	chargeCountFrame:SetShown(self.cooldownChargesShown);

                  	if self.cooldownChargesShown then
                  		chargeCountFrame.Current:SetText(self.cooldownChargesCount);
                  	end
                end)
            end

            refreshSpellChargeInfoHooks[self] = true
        end

        local lockdown
        local function integrityCheck(self, db)
            if lockdown then return end
            local cooldownIDs = self:GetCooldownIDs()
            
            -- integrity check: remove any nils that snuck into the dataset
            for index = #db, 1, -1 do
                local cooldownID = db[index]
                if not cooldownID then
                    table.remove(db, index)
                end
            end
            
            -- integrity check: indexes below 0 no longer used
            for k in pairs(db) do
                if k <= 0 then
                    db[k] = nil
                end
            end
            
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
            
            -- integrity check: remove any regular cooldown IDs that are not in the current default loadout set
            for i = #db, 1, -1 do
                local cooldownID = db[i]
                if (cooldownID > 0) and (cooldownID < ITEM_ID_PADDING) then
                    local found
                    for _, cid2 in pairs(cooldownIDs) do
                        if cooldownID == cid2 then
                            found = true
                        end
                    end
                    if not found then
                        table.remove(db, i)
                    end
                end
            end
        end
        
        local function initFrame(frame, db)
            lib:RegisterCustomButton(frame, "Add/remove custom icons", function()
                settingFrame:SetShown(not settingFrame:IsShown())
                settingFrame.viewer = frame
                settingFrame.db = db[getCurrentLoadoutID(frame)]
                settingFrame:RefreshSettingFrame()
            end)
            
            hooksecurefunc(frame, "RefreshData", function(self)
                local loadoutdb = db[getCurrentLoadoutID(frame)]
                integrityCheck(self, loadoutdb)
                
            	for itemFrame in self.itemFramePool:EnumerateActive() do
            		local cooldownID = loadoutdb and loadoutdb[itemFrame.layoutIndex];
            		if cooldownID then
            			itemFrame:SetCooldownID(cooldownID);
                        if (cooldownID < 0) or (cooldownID > ITEM_ID_PADDING) then
                            hookRefreshSpellTexture(itemFrame)
                            hookCacheCooldownValues(itemFrame)
                            hookRefreshActive(itemFrame)
                            hookRefreshCooldownInfo(itemFrame)
                            hookRefreshSpellChargeInfo(itemFrame)
                        end
            		else
                        itemFrame:ClearCooldownID();
            		end
            	end

                self:GetItemContainerFrame():Layout()
            end)
            
            hooksecurefunc(frame, "RefreshLayout", function(self)
                local loadoutdb = db[getCurrentLoadoutID(frame)]
            	integrityCheck(self, loadoutdb)
                
                self.itemFramePool:ReleaseAll();
                
                for i = 1, #loadoutdb do
                    local itemFrame = self.itemFramePool:Acquire()
                    itemFrame.layoutIndex = i
                    self:OnAcquireItemFrame(itemFrame)
                end
                
                if frame == BuffBarCooldownViewer then
                    self:GetItemContainerFrame().stride = #loadoutdb
                end
                
                self:RefreshData()
            end)
            
            frame:HookScript("OnEvent", function(self, event)
                if event == TRAIT_CONFIG_UPDATED then
                    C_Timer.After(3, function()
                        self:RefreshLayout()
                    end)
                end
            end)

            lib:RegisterResizable(frame, nil, nil, 1)
            
            lib:RegisterCustomButton(frame, "Add trinkets", function()
                local loadoutdb = db[getCurrentLoadoutID(frame)]
                
                -- integrity check: add trinkets if they're missing, at slots -2 and -1
                local found1, found2
                for i, cooldownID in pairs(loadoutdb) do
                    if cooldownID == -2 then
                        found2 = true
                    elseif cooldownID == -1 then
                        found1 = true
                    elseif cooldownID == 2 then
                        loadoutdb[i] = -2
                        found2 = true
                    elseif cooldownID == 1 then
                        loadoutdb[i] = -1
                        found1 = true
                    end
                end
                if not found2 then
                    table.insert(loadoutdb, -2)
                end
                if not found1 then
                    table.insert(loadoutdb, -1)
                end
                
                frame:RefreshLayout()
                if settingFrame.loadoutdb then
                    settingFrame:RefreshSettingFrame()
                    settingFrame.viewer:RefreshLayout()
                end
            end)
        end

        hooksecurefunc(C_SpecializationInfo, "SetSpecialization", function()
            lockdown = true
        end)
        
        hooksecurefunc(C_ClassTalents, "LoadConfig", function(_, autoApply)
            if not autoApply then return end
            lockdown = true
        end)

        EssentialCooldownViewer:RegisterEvent("SPECIALIZATION_CHANGE_CAST_FAILED")
        EssentialCooldownViewer:RegisterEvent("CONFIG_COMMIT_FAILED")
        EssentialCooldownViewer:RegisterEvent("UI_INFO_MESSAGE")
        EssentialCooldownViewer:RegisterEvent("PLAYER_ENTERING_WORLD")
        
        EssentialCooldownViewer:HookScript("OnEvent", function(self, event, ...)
            if event == "SPECIALIZATION_CHANGE_CAST_FAILED" then
                lockdown = false
            elseif event == "CONFIG_COMMIT_FAILED" then
                lockdown = false
            elseif event == "TRAIT_CONFIG_UPDATED" then
                if lockdown then
                    C_Timer.After(2, function()
                        lockdown = false
                        refreshAll()
                    end)
                end
            elseif event == "UI_INFO_MESSAGE" then
                local _, errorMsg = ...
                if (errorMsg == ERR_PVP_WARMODE_TOGGLE_ON) or (errorMsg == ERR_PVP_WARMODE_TOGGLE_OFF) then
                    C_Timer.After(2, refreshAll)
                end
            elseif event == "PLAYER_ENTERING_WORLD" then
                C_Timer.After(2, refreshAll)
            end
        end)
        
        initFrame(EssentialCooldownViewer, addon.db.char.EssentialCooldownViewerSpellIDs, true)
        initFrame(UtilityCooldownViewer, addon.db.char.UtilityCooldownViewerSpellIDs, true)
        initFrame(BuffBarCooldownViewer, addon.db.char.BuffBarCooldownViewerSpellIDs)
        
        C_Timer.After(3, refreshAll)
        
        local dropdown, getSettingDB = lib:RegisterDropdown(BuffBarCooldownViewer, libDD, "Resort")
        local dropdownOptions = {"None", "Top by duration", "Bottom by duration"}
        
        libDD:UIDropDownMenu_Initialize(dropdown, function(self)
            local db = getSettingDB()
            local info = libDD:UIDropDownMenu_CreateInfo()        
            
            if db.checked == nil then db.checked = "None" end
            
            for _, f in ipairs(dropdownOptions) do
                info.text = f
                info.checked = db.checked == f
                info.func = function()
                    if db.checked == f then
                        db.checked = nil
                    else
                        db.checked = f
                    end
                end
                libDD:UIDropDownMenu_AddButton(info)
            end
        end)
        libDD:UIDropDownMenu_SetWidth(dropdown, 100)
        libDD:UIDropDownMenu_SetText(dropdown, "Sort Icons:")
        
        BuffBarCooldownViewer:HookScript("OnEvent", function(self)
            local settingDB = getSettingDB()
            if settingDB.checked == "None" then return end
            
            if settingDB.checked == "Top by duration" then
                self.layoutFramesGoingUp = false
            else
                self.layoutFramesGoingUp = true
            end
            
            local include = {}
            for itemFrame in self.itemFramePool:EnumerateActive() do
                if itemFrame:IsActive() then
                    table.insert(include, itemFrame)
                else
                    itemFrame.layoutIndex = 999
                end
            end
            
            table.sort(include, function(a, b)
                local aExpirationTime = a:GetCooldownValues()
                local aCurrentTime = aExpirationTime - GetTime()
                local bExpirationTime = b:GetCooldownValues()
                local bCurrentTime = bExpirationTime - GetTime()
                
                if aCurrentTime == bCurrentTime then
                    return a.cooldownID < b.cooldownID
                end
                
                return aCurrentTime < bCurrentTime
            end)
            
            for index, itemFrame in ipairs(include) do
                itemFrame.layoutIndex = index
            end
            
            self:GetItemContainerFrame():Layout()
        end)
        
        -- Needed to prevent taint error - original code tries to hide edit mode manager frame which tries to clear target, but execution path is tainted
        function CooldownViewerSettings:ShowUIPanel(fromEditMode)
        	if fromEditMode then
        		if EditModeManagerFrame:IsEditModeActive() then
            		EditModeManagerFrame:ClearSelectedSystem();
            		HideUIPanel(EditModeManagerFrame);
                    EditModeManagerFrame:HideSystemSelections()
            	end
        	end

        	ShowUIPanel(self);
        end
    end
end