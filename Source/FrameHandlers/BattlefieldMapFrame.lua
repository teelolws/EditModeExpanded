local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initBattlefieldMap()
    local db = addon.db.global
    if not db.EMEOptions.battlefieldMap then return end
    addon:registerFrame(BattlefieldMapFrame, BATTLEFIELD_MINIMAP, db.BattlefieldMapFrame)
    lib:RegisterResizable(BattlefieldMapFrame)
    lib:HideByDefault(BattlefieldMapFrame)
    
    -- Unsure if taint or secret issues can spread, only change these if they're not their default
    if BattlefieldMapOptions.locked ~= true then BattlefieldMapOptions.locked = true end
    if BattlefieldMapOptions.position ~= nil then BattlefieldMapOptions.position = nil end
    
    -- BattlefieldMapTab needs to be changed, base UI uses an old system to drag the battlefield map by dragging the tab while unlocked
    BattlefieldMapTab:SetParent(BattlefieldMapFrame)
    BattlefieldMapTab:ClearAllPoints()
    BattlefieldMapTab:SetUserPlaced(false)
    BattlefieldMapTab:SetPoint("BOTTOMLEFT", BattlefieldMapFrame, "TOPLEFT", 30, 5)
    BattlefieldMapTab:RegisterForDrag()
    BattlefieldMapTab:HookScript("OnClick", function(self, button)
        if button ~= "RightButton" then return end
        -- Watch Blizzard_BattlefieldMap.lua for changes
        MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
			rootDescription:SetTag("MENU_BATTLEFIELD_MAP");
            
			do
				-- Show battlefield players
				local function IsSelected()
					return BattlefieldMapOptions.showPlayers;
				end

				local function SetSelected()
					BattlefieldMapOptions.showPlayers = not BattlefieldMapOptions.showPlayers;
					BattlefieldMapFrame:UpdateUnitsVisibility();
				end
				rootDescription:CreateCheckbox(SHOW_BATTLEFIELDMINIMAP_PLAYERS, IsSelected, SetSelected);
			end
            
			-- EME change here: disable the lock/unlock frame (in addition to disabile its dragability)
            do
				-- Battlefield minimap lock
				local function IsSelected()
					--return BattlefieldMapOptions.locked;
                    return false
				end

				--local function SetSelected()
					--BattlefieldMapOptions.locked = not BattlefieldMapOptions.locked;
				--end
				rootDescription:CreateCheckbox("EditModeExpanded: use Edit Mode to move this!", IsSelected, nop)
			end

			do
				-- Opacity
				rootDescription:CreateButton(BATTLEFIELDMINIMAP_OPACITY_LABEL, function()
					self:ShowOpacity();
				end);
			end
		end);
    end)
end
