--[[
Copyright 2013-2026 João Cardoso
SecureTabs is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of SecureTabs.

SecureTabs is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

SecureTabs is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SecureTabs. If not, see <http://www.gnu.org/licenses/>.
--]]

local Lib, old = LibStub:NewLibrary('SecureTabs-2.0', 15)
if not Lib then
	return
elseif not old then
	hooksecurefunc('PanelTemplates_SetTab', function(panel, id)
		Lib:Update(panel)
	end)
end

Lib.tabs = Lib.tabs or {}
Lib.covers = Lib.covers or {}
Lib.template = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and 'PanelTabButtonTemplate' or 'CharacterFrameTabButtonTemplate'


--[[ Main API ]]--

function Lib:Add(panel, frame, label)
	local secureTabs = self.tabs[panel] or {}
	local id = #secureTabs
	local anchor = id > 0 and 'SecureTab' .. (id-1) or 'Tab' .. panel.numTabs

	local tab = CreateFrame('Button', '$parentSecureTab' .. id, panel, self.template)
	tab.frame = frame
	tab.Select = function(tab) self:Select(tab) end
	tab:SetPoint('LEFT', panel:GetName() .. anchor, 'RIGHT', WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and 3 or -16, 0)
	tab:SetFrameLevel(panel:GetFrameLevel() + 610)
	tab:SetScript('OnClick', tab.Select)
	tab:SetText(label)
	tinsert(secureTabs, tab)
	PanelTemplates_DeselectTab(tab)

	local cover = self.covers[panel] or CreateFrame('Button', '$parentCoverTab', panel, self.template)
	cover:SetScript('OnClick', function() self:Update(panel) end)
	PanelTemplates_DeselectTab(cover)

	self.tabs[panel] = secureTabs
	self.covers[panel] = cover

	return tab
end

function Lib:Select(tab)
	self:Update(tab:GetParent(), tab)
end


--[[ Advanced Methods ]]--

function Lib:Update(panel, selection)
	local secureTabs = self.tabs[panel]
	if not secureTabs then
		return
	end

	for i, tab in ipairs(secureTabs) do
		local selected = tab == selection
		if selected then
			if tab:IsEnabled() and tab.OnSelect then
				xpcall(tab.OnSelect, CallErrorHandler, tab)
			end
		else
			if not tab:IsEnabled() and tab.OnDeselect then
				xpcall(tab.OnDeselect, CallErrorHandler, tab)
			end
		end

		local frame = tab.frame
		if frame then
			frame:SetShown(selected)

			if selected then
				frame:SetParent(panel)
				frame:EnableMouse(true)
				frame:SetAllPoints(true)
				frame:SetFrameLevel(panel:GetFrameLevel() + 600)

				if frame.CloseButton and panel.CloseButton then
					panel.CloseButton:SetFrameLevel(frame.CloseButton:GetFrameLevel() + 10)
				end
			end
		end

		(tab == selection and PanelTemplates_SelectTab or PanelTemplates_DeselectTab)(tab)
	end

	if panel.selectedTab then
		local cover = self.covers[panel]
		local tab = _G[panel:GetName() .. 'Tab'.. panel.selectedTab]

		local name = tab:GetName()
		local left = tab.LeftActive or _G[name..'LeftDisabled']
		local middle = tab.MiddleActive or _G[name..'MiddleDisabled']
		local right = tab.RightActive or _G[name..'RightDisabled']

		cover:SetShown(selection)
		left:SetShown(not selection)
		middle:SetShown(not selection)
		right:SetShown(not selection)

 		if selection then
			cover:SetParent(tab)
			cover:SetAllPoints(tab)
			cover:SetText(tab:GetText())
			PanelTemplates_TabResize(cover, 0, nil, 36, panel.maxTabWidth or 88)
		end
	end

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
end
