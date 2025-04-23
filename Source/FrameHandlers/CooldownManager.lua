local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local libDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local function initFrame(frame)
    local dropdown, getSettingDB = lib:RegisterDropdown(frame, libDD, "ExcludeCooldownDropdown")

    hooksecurefunc(frame, "RefreshData", function(self)
        if self:IsEditing() then return end
        
    	local cooldownIDs = self:GetCooldownIDs();
        
        local db = getSettingDB()
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
    		else
    			itemFrame:ClearCooldownID();
    		end
    	end

    	self:RefreshItemsShown()
        self:GetItemContainerFrame():Layout()
    end)
    frame:RefreshData()
    
    
    libDD:UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local db = getSettingDB()
        local info = libDD:UIDropDownMenu_CreateInfo()        
        local cooldownIDs = frame:GetCooldownIDs()
        
        for _, cooldownID in ipairs(cooldownIDs) do
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
        end
    end)
    libDD:UIDropDownMenu_SetWidth(dropdown, 200)
    libDD:UIDropDownMenu_SetText(dropdown, "Hide These Spells")
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
