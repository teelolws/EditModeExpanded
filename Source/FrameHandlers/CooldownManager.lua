local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local libDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

-- custom cooldown IDs will be added to the set like this:
-- the spell ID but as a negative, eg spatial rift spell ID is 256948 so will be listed as cooldown ID -256948
-- trinket 1 = -2, checked and confirmed spell ID 2 is not used
-- trinket 2 = -1, checked and confirmed spell ID 1 is an obsolete spell "Word of Recall"

local getCacheCooldownValues = {}
local function hookCacheCooldownValues(self)
    if getCacheCooldownValues[self] then return end
    
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
        
        self:GetIconTexture():SetTexture(spellTexture);
    end)
    
    refreshSpellTextureHooks[self] = true
end

local function initFrame(frame)
    local dropdown, getSettingDB = lib:RegisterDropdown(frame, libDD, "ExcludeCooldownDropdown")
    local rearrangeDropdown, getRearrangeSettingDB = lib:RegisterDropdown(frame, libDD, "RearrangeCooldownDropdown")
    local trinket1, trinket2
    
    dropdown:HookScript("OnEnter", function()
        GameTooltip:SetOwner(dropdown)
        GameTooltip:SetText("More options are available under Interface Options > AddOns > EditModeExpanded")
        GameTooltip:Show()
    end)
    dropdown:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- backup the function into char-variables so we can call them from the options file
    addon.db.char.excludeCooldownGetSettingDB = getSettingDB
    addon.db.char.rearrangeCooldownGetSettingDB = getRearrangeSettingDB
    
    hooksecurefunc(frame, "RefreshData", function(self)
    	local cooldownIDs = self:GetCooldownIDs();
        if trinket1 then
            table.insert(cooldownIDs, -2)
        end
        if trinket2 then
            table.insert(cooldownIDs, -1)
        end
        
        for _, cooldownID in ipairs(addon.db.char.customCooldownSpellIDs) do
            table.insert(cooldownIDs, cooldownID * -1)
        end
        
        local db = getSettingDB()
        local rdb = getRearrangeSettingDB()
        
        local cooldownIDsSorting = {}
        for cooldownIndex, cooldownID in ipairs(cooldownIDs) do
            if rdb[cooldownID] then
                cooldownIndex = cooldownIndex + rdb[cooldownID]
            end
            table.insert(cooldownIDsSorting, {id = cooldownID, index = cooldownIndex})
        end
        
        table.sort(cooldownIDsSorting, function(a, b)
            if a.index == b.index then
                return a.id < b.id
            end
            return a.index < b.index
        end)
        
        wipe(cooldownIDs)
        for index, cooldownInfo in pairs(cooldownIDsSorting) do
            table.insert(cooldownIDs, cooldownInfo.id)
        end
        
        for cooldownID in pairs(db) do
            for i = #cooldownIDs, 1, -1 do
                if cooldownIDs[i] == cooldownID then
                    table.remove(cooldownIDs, i)
                end
            end
        end

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
    frame:RefreshData()
    
    hooksecurefunc(frame, "RefreshLayout", function(self)
    	local itemCount = self:GetItemCount()
        itemCount = itemCount + 1
        if trinket1 then
            local itemFrame = self.itemFramePool:Acquire()
            itemFrame.layoutIndex = itemCount
            itemCount = itemCount + 1
            self:OnAcquireItemFrame(itemFrame)
        end
        if trinket2 then
            local itemFrame = self.itemFramePool:Acquire()
            itemFrame.layoutIndex = itemCount
            itemCount = itemCount + 1
            self:OnAcquireItemFrame(itemFrame)
        end
        
        local db = getSettingDB()
        for _, cooldownID in ipairs(addon.db.char.customCooldownSpellIDs) do
            cooldownID = cooldownID * -1
            if not db[cooldownID] then
                local itemFrame = self.itemFramePool:Acquire()
                itemFrame.layoutIndex = itemCount
                itemCount = itemCount + 1
                self:OnAcquireItemFrame(itemFrame)
            end
        end
        
        if itemCount > (self:GetItemCount() + 1) then
            self:RefreshData()
        end
    end)
    
    libDD:UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local db = getSettingDB()
        local info = libDD:UIDropDownMenu_CreateInfo()        
        local cooldownIDs = frame:GetCooldownIDs()
        if trinket1 then
            table.insert(cooldownIDs, -2)
        end
        if trinket2 then
            table.insert(cooldownIDs, -1)
        end
        
        for _, cooldownID in ipairs(addon.db.char.customCooldownSpellIDs) do
            cooldownID = cooldownID * -1
            table.insert(cooldownIDs, cooldownID)
        end
        
        for _, cooldownID in ipairs(cooldownIDs) do
            if cooldownID > 0 then
                local cooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)
                info.text = C_Spell.GetSpellName(cooldownInfo.spellID)
                info.checked = db[cooldownID]
                info.func = function()
                    if db[cooldownID] then
                        db[cooldownID] = nil
                    else
                        db[cooldownID] = true
                    end
                    frame:RefreshData()
                end
                libDD:UIDropDownMenu_AddButton(info)
            else
                if cooldownID > -3 then
                    local code = (cooldownID == -2) and "trinket1" or "trinket2"
                    info.text = (cooldownID == -2) and "Trinket 1" or "Trinket 2"
                    info.checked = not db[code]
                    info.func = function()
                        if db[code] then
                            db[code] = nil
                        else
                            db[code] = true
                        end
                        frame:RefreshData()
                    end
                    libDD:UIDropDownMenu_AddButton(info)
                else
                    info.text = C_Spell.GetSpellName(cooldownID * -1)
                    info.checked = db[cooldownID]
                    info.func = function()
                        if db[cooldownID] then
                            db[cooldownID] = nil
                        else
                            db[cooldownID] = true
                        end
                        frame:RefreshData()
                    end
                    libDD:UIDropDownMenu_AddButton(info)
                end
            end
        end
    end)
    libDD:UIDropDownMenu_SetWidth(dropdown, 200)
    libDD:UIDropDownMenu_SetText(dropdown, "Hide These Spells")
    
    libDD:UIDropDownMenu_Initialize(rearrangeDropdown, function(self, level, menuList)
        local db = getRearrangeSettingDB()
        local info = libDD:UIDropDownMenu_CreateInfo()        
        local cooldownIDs = frame:GetCooldownIDs()
        
        if trinket1 then
            table.insert(cooldownIDs, -2)
        end
        if trinket2 then
            table.insert(cooldownIDs, -1)
        end
        
        for _, cooldownID in ipairs(addon.db.char.customCooldownSpellIDs) do
            cooldownID = cooldownID * -1
            table.insert(cooldownIDs, cooldownID)
        end
        
        for cooldownIndex, cooldownID in ipairs(cooldownIDs) do
            local cooldownInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)
            
            local name 
            if cooldownID > 0 then
                name = C_Spell.GetSpellName(cooldownInfo.spellID)
            else
                if cooldownID > -3 then
                    name = (cooldownID == -2) and "Trinket 1" or "Trinket 2"
                else
                    name = C_Spell.GetSpellName(cooldownID * -1)
                end
            end
            
            info.text = "Move "..name.." ("..(cooldownIndex + (db[cooldownID] or 0))..")".." Up"
            info.func = function()
                if db[cooldownID] then
                    db[cooldownID] = db[cooldownID] - 1
                else
                    db[cooldownID] = cooldownIndex - 1
                end
                frame:RefreshData()
            end
            libDD:UIDropDownMenu_AddButton(info)
            
            info.text = "Move "..name.." Down"
            info.func = function()
                if db[cooldownID] then
                    db[cooldownID] = db[cooldownID] + 1
                else
                    db[cooldownID] = cooldownIndex + 1
                end
                frame:RefreshData()
            end
            libDD:UIDropDownMenu_AddButton(info)
        end
    end)
    libDD:UIDropDownMenu_SetWidth(rearrangeDropdown, 200)
    libDD:UIDropDownMenu_SetText(rearrangeDropdown, "Rearrange These Spells")
    
    lib:RegisterCustomCheckbox(frame, "Include Trinket 1",
        function()
            trinket1 = true
            frame:RefreshLayout()
        end,
        function()
            trinket1 = false
            frame:RefreshLayout()
        end,
        "IncludeTrinket1"
    )
    
    lib:RegisterCustomCheckbox(frame, "Include Trinket 2",
        function()
            trinket2 = true
            frame:RefreshLayout()
        end,
        function()
            trinket2 = false
            frame:RefreshLayout()
        end,
        "IncludeTrinket2"
    )
end

function addon:initCooldownManager()
    local db = addon.db.global
    if db.EMEOptions.cooldownManager then
        initFrame(EssentialCooldownViewer)
        initFrame(UtilityCooldownViewer)
        initFrame(BuffIconCooldownViewer)
        initFrame(BuffBarCooldownViewer)
    end
end
