local addonName, addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local libDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

--
-- Adapted from Blizzard_UIWidgetTemplateBase.lua
--

EMEWidgetTemplateTooltipFrameMixin = {}

function EMEWidgetTemplateTooltipFrameMixin:SetMouse(disableMouse)
	local useMouse = (self.tooltip and self.tooltip ~= "" and not disableMouse) or false;
	self:EnableMouse(useMouse);
	self:SetMouseClickEnabled(false);
end

function EMEWidgetTemplateTooltipFrameMixin:OnLoad()
end

function EMEWidgetTemplateTooltipFrameMixin:UpdateMouseEnabled()
	self:SetMouse(self.disableTooltip);
end

function EMEWidgetTemplateTooltipFrameMixin:Setup(widgetContainer, tooltipLoc)
	self.disableTooltip = widgetContainer.disableWidgetTooltips;
	self:UpdateMouseEnabled();
	self:SetTooltipLocation(tooltipLoc);

	if self.mouseOver then
		self:OnEnter();
	end
end

function EMEWidgetTemplateTooltipFrameMixin:SetTooltip(tooltip, color)
	self.tooltip = tooltip;
	self.tooltipContainsHyperLink = false;
	self.preString = nil;
	self.hyperLinkString = nil;
	self.postString = nil;
	self.tooltipColor = color;

	if tooltip then
		self.tooltipContainsHyperLink, self.preString, self.hyperLinkString, self.postString = ExtractHyperlinkString(tooltip);
	end
	self:UpdateMouseEnabled();
end

local tooltipLocToAnchor = {
	[Enum.UIWidgetTooltipLocation.BottomLeft]	= "ANCHOR_BOTTOMLEFT",
	[Enum.UIWidgetTooltipLocation.Left]			= "ANCHOR_NONE",
	[Enum.UIWidgetTooltipLocation.TopLeft]		= "ANCHOR_LEFT",
	[Enum.UIWidgetTooltipLocation.Top]			= "ANCHOR_TOP",
	[Enum.UIWidgetTooltipLocation.TopRight]		= "ANCHOR_RIGHT",
	[Enum.UIWidgetTooltipLocation.Right]		= "ANCHOR_NONE",
	[Enum.UIWidgetTooltipLocation.BottomRight]	= "ANCHOR_BOTTOMRIGHT",
	[Enum.UIWidgetTooltipLocation.Bottom]		= "ANCHOR_BOTTOM",
};

function EMEWidgetTemplateTooltipFrameMixin:SetTooltipLocation(tooltipLoc)
	self.tooltipLoc = tooltipLoc;
	self.tooltipAnchor = tooltipLocToAnchor[tooltipLoc] or self.defaultTooltipAnchor;
end

function EMEWidgetTemplateTooltipFrameMixin:SetTooltipOwner()
	if self.tooltipAnchor == "ANCHOR_NONE" then
		EmbeddedItemTooltip:SetOwner(self, self.tooltipAnchor);
		EmbeddedItemTooltip:ClearAllPoints();
		if self.tooltipLoc == Enum.UIWidgetTooltipLocation.Left then
			EmbeddedItemTooltip:SetPoint("RIGHT", self, "LEFT", self.tooltipXOffset, self.tooltipYOffset);
		elseif self.tooltipLoc == Enum.UIWidgetTooltipLocation.Right then
			EmbeddedItemTooltip:SetPoint("LEFT", self, "RIGHT", self.tooltipXOffset, self.tooltipYOffset);
		end
	else
		EmbeddedItemTooltip:SetOwner(self, self.tooltipAnchor, self.tooltipXOffset, self.tooltipYOffset);
	end
end

function EMEWidgetTemplateTooltipFrameMixin:OnEnter()
	if self.tooltip and self.tooltip ~= "" then
		self:SetTooltipOwner();

		if self.tooltipBackdropStyle then
			SharedTooltip_SetBackdropStyle(EmbeddedItemTooltip, self.tooltipBackdropStyle);
		end

		if self.tooltipContainsHyperLink then
			local clearTooltip = true;
			if self.preString and self.preString:len() > 0 then
				GameTooltip_AddNormalLine(EmbeddedItemTooltip, self.preString, true);
				clearTooltip = false;
			end

			GameTooltip_ShowHyperlink(EmbeddedItemTooltip, self.hyperLinkString, 0, 0, clearTooltip);

			if self.postString and self.postString:len() > 0 then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, self.postString, self.tooltipColor or HIGHLIGHT_FONT_COLOR, true);
			end

			self.UpdateTooltip = self.OnEnter;

			EmbeddedItemTooltip:Show();
		else
			local header, nonHeader = SplitTextIntoHeaderAndNonHeader(self.tooltip);
			if header then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, header, self.tooltipColor or NORMAL_FONT_COLOR, true);
			end
			if nonHeader then
				GameTooltip_AddColoredLine(EmbeddedItemTooltip, nonHeader, self.tooltipColor or NORMAL_FONT_COLOR, true);
			end

			self.UpdateTooltip = nil;

			EmbeddedItemTooltip:SetShown(header ~= nil);
		end
	end
	self.mouseOver = true;
end

function EMEWidgetTemplateTooltipFrameMixin:OnLeave()
	EmbeddedItemTooltip:Hide();
	self.mouseOver = false;
	self.UpdateTooltip = nil;
end

EMEWidgetBaseTemplateMixin = CreateFromMixins(EMEWidgetTemplateTooltipFrameMixin);

function EMEWidgetBaseTemplateMixin:ShouldApplyEffectsToSubFrames()
	return false;
end

function EMEWidgetBaseTemplateMixin:ClearEffects()
	local frames = {self:GetChildren()};
	table.insert(frames, self);
	for _, frame in ipairs(frames) do
		if frame.effectController then
			frame.effectController:CancelEffect();
			frame.effectController = nil;
		end
	end
end

function EMEWidgetBaseTemplateMixin:ApplyEffectToFrame(widgetInfo, widgetContainer, frame)
	if frame.effectController then
		frame.effectController:CancelEffect();
		frame.effectController = nil;
	end
	if widgetInfo.scriptedAnimationEffectID and widgetInfo.modelSceneLayer ~= Enum.UIWidgetModelSceneLayer.None then
		if widgetInfo.modelSceneLayer == Enum.UIWidgetModelSceneLayer.Front then
			frame.effectController = widgetContainer.FrontModelScene:AddEffect(widgetInfo.scriptedAnimationEffectID, frame, frame);
		elseif widgetInfo.modelSceneLayer == Enum.UIWidgetModelSceneLayer.Back then
			frame.effectController = widgetContainer.BackModelScene:AddEffect(widgetInfo.scriptedAnimationEffectID, frame, frame);
		end
	end
end

function EMEWidgetBaseTemplateMixin:ApplyEffects(widgetInfo)
	local applyFrames = self:ShouldApplyEffectsToSubFrames() and {self:GetChildren()} or {self};
	for _, frame in ipairs(applyFrames) do
		self:ApplyEffectToFrame(widgetInfo, self.widgetContainer, frame);
	end
end

function EMEWidgetBaseTemplateMixin:OnLoad()
	EMEWidgetTemplateTooltipFrameMixin.OnLoad(self);
end

function EMEWidgetBaseTemplateMixin:GetWidgetWidth()
	return self:GetWidth() * self:GetScale();
end

function EMEWidgetBaseTemplateMixin:GetWidgetHeight()
	return self:GetHeight() * self:GetScale();
end

function EMEWidgetBaseTemplateMixin:InAnimFinished()
end

function EMEWidgetBaseTemplateMixin:OutAnimFinished()
	self.widgetContainer:RemoveWidget(self.widgetID);
end

function EMEWidgetBaseTemplateMixin:GetInAnim()
	if self.inAnimType == Enum.WidgetAnimationType.Fade then
		return self.FadeInAnim;
	end
end

function EMEWidgetBaseTemplateMixin:GetOutAnim()
	if self.outAnimType == Enum.WidgetAnimationType.Fade then
		return self.FadeOutAnim;
	end
end

function EMEWidgetBaseTemplateMixin:ResetAnimState()
	self.FadeInAnim:Stop();
	self.FadeOutAnim:Stop();
	self:SetAlpha(1);
end

function EMEWidgetBaseTemplateMixin:AnimIn()
	if not self:IsShown() then
		self:ResetAnimState();

		self:Show();

		local inAnim = self:GetInAnim();
		if inAnim then
			inAnim:Play();
		else
			self:InAnimFinished();
		end
	end
end

-- Animates the widget out. Once that is done the widget is removed from the widget container and actually released
function EMEWidgetBaseTemplateMixin:AnimOut()
	if self:IsShown() then
		self:ResetAnimState();

		local outAnim = self:GetOutAnim();
		if outAnim then
			outAnim:Play();
		else
			self:OutAnimFinished();
		end
	end
end

local widgetScales =
{
	[Enum.UIWidgetScale.OneHundred]	= 1,
	[Enum.UIWidgetScale.Ninty] = 0.9,
	[Enum.UIWidgetScale.Eighty] = 0.8,
	[Enum.UIWidgetScale.Seventy] = 0.7,
	[Enum.UIWidgetScale.Sixty] = 0.6,
	[Enum.UIWidgetScale.Fifty] = 0.5,
	[Enum.UIWidgetScale.OneHundredTen] = 1.1,
	[Enum.UIWidgetScale.OneHundredTwenty] = 1.2,
	[Enum.UIWidgetScale.OneHundredThirty] = 1.3,
	[Enum.UIWidgetScale.OneHundredForty] = 1.4,
	[Enum.UIWidgetScale.OneHundredFifty] = 1.5,
	[Enum.UIWidgetScale.OneHundredSixty] = 1.6,
	[Enum.UIWidgetScale.OneHundredSeventy] = 1.7,
	[Enum.UIWidgetScale.OneHundredEighty] = 1.8,
	[Enum.UIWidgetScale.OneHundredNinety] = 1.9,
	[Enum.UIWidgetScale.TwoHundred] = 2,
}

local function GetWidgetScale(widgetScale)
	return widgetScales[widgetScale] and widgetScales[widgetScale] or widgetScales[Enum.UIWidgetScale.OneHundred];
end

-- Override with any custom behaviour that you need to perform when this widget is updated. Make sure you still call the base though because it handles animations
function EMEWidgetBaseTemplateMixin:Setup(widgetInfo, widgetContainer)
	self:SetScale(GetWidgetScale(widgetInfo.widgetScale));
	EMEWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer, widgetInfo.tooltipLoc);
	self.widgetContainer = widgetContainer;
	self.orderIndex = widgetInfo.orderIndex;
	self.layoutDirection = widgetInfo.layoutDirection;
	self:AnimIn();
end

-- Override with any custom behaviour that you need to perform when this widget is destroyed (e.g. release pools)
function EMEWidgetBaseTemplateMixin:OnReset()
	self:Hide();
	self:ClearAllPoints();
	self:ClearEffects();
end

--
-- Adapted from Blizzard_UIWidgetTemplateFillUpFrames.lua
--

local widgetIDs = {
    5145, -- Algari dark
    4460, -- Dragonriding
    5144, -- Algari bronze
    5143, -- Algari silver
    5140, -- Algari gold
}
local widgetSetID = 283

local widgetInfos = {
    [5140] = {
        ["scriptedAnimationEffectID"] = 0,
        ["modelSceneLayer"] = 0,
        ["numFullFrames"] = 6,
        ["textureKit"] = "dragonriding_sgvigor",
        ["tooltipLoc"] = 6,
        ["fillMax"] = 100,
        ["shownState"] = 0,
        ["fillMin"] = 0,
        ["numTotalFrames"] = 0,
        ["widgetTag"] = "",
        ["tooltip"] = "Vigor recharges while grounded, whether mounted or not, and while skyriding at high speeds.",
        ["widgetScale"] = 0,
        ["orderIndex"] = 0,
        ["layoutDirection"] = 0,
        ["inAnimType"] = 0,
        ["fillValue"] = 0,
        ["hasTimer"] = false,
        ["outAnimType"] = 0,
        ["frameTextureKit"] = "gold",
        ["widgetSizeSetting"] = 0,
        ["pulseFillingFrame"] = false,
    },
    [5144] = {
        ["scriptedAnimationEffectID"] = 0,
        ["modelSceneLayer"] = 0,
        ["numFullFrames"] = 6,
        ["textureKit"] = "dragonriding_sgvigor",
        ["tooltipLoc"] = 6,
        ["fillMax"] = 100,
        ["shownState"] = 0,
        ["fillMin"] = 0,
        ["numTotalFrames"] = 0,
        ["widgetTag"] = "",
        ["tooltip"] = "Vigor recharges while grounded, whether mounted or not, and while skyriding at high speeds.",
        ["widgetScale"] = 0,
        ["orderIndex"] = 0,
        ["layoutDirection"] = 0,
        ["inAnimType"] = 0,
        ["fillValue"] = 0,
        ["hasTimer"] = false,
        ["outAnimType"] = 0,
        ["frameTextureKit"] = "bronze",
        ["widgetSizeSetting"] = 0,
        ["pulseFillingFrame"] = false,
    },
    [4460] = {
        ["scriptedAnimationEffectID"] = 0,
        ["modelSceneLayer"] = 0,
        ["numFullFrames"] = 6,
        ["textureKit"] = "dragonriding_vigor",
        ["tooltipLoc"] = 6,
        ["fillMax"] = 100,
        ["shownState"] = 0,
        ["fillMin"] = 0,
        ["numTotalFrames"] = 6,
        ["widgetTag"] = "",
        ["tooltip"] = "Vigor recharges while grounded, whether mounted or not, and while skyriding at high speeds.",
        ["widgetScale"] = 0,
        ["orderIndex"] = 0,
        ["layoutDirection"] = 0,
        ["inAnimType"] = 0,
        ["fillValue"] = 0,
        ["hasTimer"] = false,
        ["outAnimType"] = 0,
        ["widgetSizeSetting"] = 0,
        ["pulseFillingFrame"] = false,
    },
    [5143] = {
        ["scriptedAnimationEffectID"] = 0,
        ["modelSceneLayer"] = 0,
        ["numFullFrames"] = 6,
        ["textureKit"] = "dragonriding_sgvigor",
        ["tooltipLoc"] = 6,
        ["fillMax"] = 100,
        ["shownState"] = 0,
        ["fillMin"] = 0,
        ["numTotalFrames"] = 0,
        ["widgetTag"] = "",
        ["tooltip"] = "Vigor recharges while grounded, whether mounted or not, and while skyriding at high speeds.",
        ["widgetScale"] = 0,
        ["orderIndex"] = 0,
        ["layoutDirection"] = 0,
        ["inAnimType"] = 0,
        ["fillValue"] = 0,
        ["hasTimer"] = false,
        ["outAnimType"] = 0,
        ["frameTextureKit"] = "silver",
        ["widgetSizeSetting"] = 0,
        ["pulseFillingFrame"] = false,
    },
    [5145] = {
        ["scriptedAnimationEffectID"] = 0,
        ["modelSceneLayer"] = 0,
        ["numFullFrames"] = 6,
        ["textureKit"] = "dragonriding_sgvigor",
        ["tooltipLoc"] = 6,
        ["fillMax"] = 100,
        ["shownState"] = 0,
        ["fillMin"] = 0,
        ["numTotalFrames"] = 6,
        ["widgetTag"] = "",
        ["tooltip"] = "Vigor recharges while grounded, whether mounted or not, and while slyriding at high speeds.",
        ["widgetScale"] = 0,
        ["orderIndex"] = 0,
        ["layoutDirection"] = 0,
        ["inAnimType"] = 0,
        ["fillValue"] = 0,
        ["hasTimer"] = false,
        ["outAnimType"] = 0,
        ["frameTextureKit"] = "dark",
        ["widgetSizeSetting"] = 0,
        ["pulseFillingFrame"] = false,
    }
}

--local function GetFillUpFramesVisInfoData(widgetID)
--	local widgetInfo = widgetInfos[widgetID]
--	if widgetInfo and widgetInfo.shownState ~= Enum.WidgetShownState.Hidden then
--		return widgetInfo;
--	end
--end

-- UIWidgetManager:RegisterWidgetVisTypeTemplate(Enum.UIWidgetVisualizationType.FillUpFrames, {frameType = "FRAME", frameTemplate = "UIWidgetTemplateFillUpFrames"}, GetFillUpFramesVisInfoData);

EMEWidgetTemplateFillUpFramesMixin = CreateFromMixins(EMEWidgetBaseTemplateMixin);

local decorFormatStringDefault = "%s_decor";
local decorFormatStringExtra = "%s_decor_%s";
local decorFlipbookLeftTextureKitFormatString = "%s_decor_flipbook_left";
local decorFlipbookRightTextureKitFormatString = "%s_decor_flipbook_right";

local decorTopPadding = {
	dragonriding_vigor = 8,
	dragonriding_sgvigor = -15,
};

local firstAndLastPadding = {
	dragonriding_vigor = -20,
	dragonriding_sgvigor = -17,
};

local decorFlipbookfixedSizeByTextureKit = {
	dragonriding_sgvigor = {width=77, height=106},
};

local decorFlipbookOffsetByTextureKit = {
	dragonriding_sgvigor = {x=7, y=12},
};

function EMEWidgetTemplateFillUpFramesMixin:OnLoad()
	EMEWidgetBaseTemplateMixin.OnLoad(self); 
	self.fillUpFramePool = CreateFramePool("FRAME", self, "EMEWidgetFillUpFrameTemplate");
end

function EMEWidgetTemplateFillUpFramesMixin:Setup(widgetInfo, widgetContainer)
	EMEWidgetBaseTemplateMixin.Setup(self, widgetInfo, widgetContainer);
	self:SetTooltip(widgetInfo.tooltip);
	
	local atlasDecorName;

	if widgetInfo.frameTextureKit ~= nil and widgetInfo.frameTextureKit ~= "" then
		atlasDecorName = decorFormatStringExtra:format(widgetInfo.textureKit, widgetInfo.frameTextureKit);
	else
		atlasDecorName = decorFormatStringDefault:format(widgetInfo.textureKit);
	end

	self.DecorLeft:SetAtlas(atlasDecorName, TextureKitConstants.UseAtlasSize);
	self.DecorRight:SetAtlas(atlasDecorName, TextureKitConstants.UseAtlasSize);

	self.DecorLeft.topPadding = decorTopPadding[widgetInfo.textureKit];
	self.DecorRight.topPadding = decorTopPadding[widgetInfo.textureKit];

	local decorFlipbookAtlasLeft = decorFlipbookLeftTextureKitFormatString:format(widgetInfo.textureKit);
	local decorFlipbookAtlasRight = decorFlipbookRightTextureKitFormatString:format(widgetInfo.textureKit);
	local decorFlipbookAtlasInfoLeft = C_Texture.GetAtlasInfo(decorFlipbookAtlasLeft);
	local decorFlipbookAtlasInfoRight = C_Texture.GetAtlasInfo(decorFlipbookAtlasRight);
	if decorFlipbookAtlasInfoLeft and decorFlipbookAtlasInfoRight then
		self.DecorFlipbookLeft:SetAtlas(decorFlipbookAtlasLeft, TextureKitConstants.UseAtlasSize);
		self.DecorFlipbookRight:SetAtlas(decorFlipbookAtlasRight, TextureKitConstants.UseAtlasSize);

		local decorFlipbookFixedSize = decorFlipbookfixedSizeByTextureKit[widgetInfo.textureKit];
		if decorFlipbookFixedSize then
			self.DecorFlipbookLeft:SetSize(decorFlipbookFixedSize.width, decorFlipbookFixedSize.height);
			self.DecorFlipbookRight:SetSize(decorFlipbookFixedSize.width, decorFlipbookFixedSize.height);
		end

		local decorFlipbookOffset = decorFlipbookOffsetByTextureKit[widgetInfo.textureKit];
		if decorFlipbookOffset then
			self.DecorFlipbookLeft:SetPoint("CENTER", self.DecorLeft, -decorFlipbookOffset.x, decorFlipbookOffset.y);
			self.DecorFlipbookRight:SetPoint("CENTER", self.DecorRight, decorFlipbookOffset.x, decorFlipbookOffset.y);
		else
			self.DecorFlipbookLeft:SetPoint("CENTER", self.DecorLeft, 0, 0);
			self.DecorFlipbookRight:SetPoint("CENTER", self.DecorRight, 0, 0);
		end

	else
		self.DecorFlipbookLeft:Hide();
		self.DecorFlipbookRight:Hide();
	end

	self.fillUpFramePool:ReleaseAll();

	if not self.lastNumFullFrames then
		self.lastNumFullFrames = widgetInfo.numFullFrames;
	end

	local shouldPlayDecorAnimation = false;
	
	for index = 1, widgetInfo.numTotalFrames do
		local fillUpFrame = self.fillUpFramePool:Acquire();

		local isFull = (index <= widgetInfo.numFullFrames);
		local isFilling = (index == (widgetInfo.numFullFrames + 1));
		local flashFrame = isFull and (widgetInfo.numFullFrames > self.lastNumFullFrames) and (index > self.lastNumFullFrames);
		local pulseFrame = isFilling and widgetInfo.pulseFillingFrame and (widgetInfo.fillValue < widgetInfo.fillMax);
		local consumeFrame = not isFull and widgetInfo.numFullFrames < self.lastNumFullFrames and index == self.lastNumFullFrames;

		fillUpFrame:SetPoint("TOPLEFT", self, "TOPLEFT");
		fillUpFrame:Setup(widgetContainer, widgetInfo.textureKit, isFull, isFilling, flashFrame, pulseFrame, widgetInfo.fillMin, widgetInfo.fillMax, widgetInfo.fillValue, widgetInfo.frameTextureKit, consumeFrame)
		fillUpFrame.layoutIndex = index;

		if flashFrame then
			shouldPlayDecorAnimation = true;
		end

		if isFull then
			self:ApplyEffectToFrame(widgetInfo, self.widgetContainer, fillUpFrame);
		else
			if fillUpFrame.effectController then
				fillUpFrame.effectController:CancelEffect();
				fillUpFrame.effectController = nil;
			end
		end

		if index == 1 then
			fillUpFrame.leftPadding = firstAndLastPadding[widgetInfo.textureKit];
		elseif index == widgetInfo.numTotalFrames then
			fillUpFrame.rightPadding = firstAndLastPadding[widgetInfo.textureKit];
		end
	end

	if shouldPlayDecorAnimation and decorFlipbookAtlasInfoLeft and decorFlipbookAtlasInfoRight then
		self.DecorFlipbookLeft:Show();
		self.DecorFlipbookRight:Show();
		self.DecorFlipbookAnim:Restart();
	end

	self.lastNumFullFrames = widgetInfo.numFullFrames;

	self:Layout();
end

function EMEWidgetTemplateFillUpFramesMixin:ApplyEffects()--widgetInfo)
	-- Intentionally empty, we apply the effect on the frames themselves when they are full
end

EMEWidgetFillUpFrameTemplateMixin = CreateFromMixins(EMEWidgetTemplateTooltipFrameMixin);

local frameTextureKitRegions = {
	BG = "%s_background",
	Spark = "%s_spark",
	SparkMask = "%s_mask",
	Flash = "%s_flash",
};

local fillTextureKitFormatString = "%s_fill";
local fillFullTextureKitFormatString = "%s_fillfull";
local fillFlipbookTextureKitFormatString = "%s_fill_flipbook";

local frameFormatStringDefault = "%s_frame";
local frameFormatStringExtra = "%s_frame_%s";

local burstFlipbookTextureKitFormatString = "%s_burst_flipbook";
local filledFlipbookTextureKitFormatString = "%s_filled_flipbook";

local fixedSizeByTextureKit = {
	dragonriding_vigor = {width=42, height=45},
	dragonriding_sgvigor = {width=48, height=62},
};

local filledFlipbookfixedSizeByTextureKit = {
	dragonriding_sgvigor = {width=34, height=50},
};

local burstFlipbookfixedSizeByTextureKit = {
	dragonriding_sgvigor = {width=100, height=100},
};

local flashFameSound = {
	dragonriding_vigor = SOUNDKIT.UI_DRAGONRIDING_FULL_NODE,
	dragonriding_sgvigor = SOUNDKIT.UI_DRAGONRIDING_FULL_NODE,
};

function EMEWidgetFillUpFrameTemplateMixin:Setup(widgetContainer, textureKit, isFull, isFilling, flashFrame, pulseFrame, min, max, value, frameTextureKit, consumeFrame)
	EMEWidgetTemplateTooltipFrameMixin.Setup(self, widgetContainer);

	SetupTextureKitOnRegions(textureKit, self, frameTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	local atlasFrameName;
	if frameTextureKit ~= nil and frameTextureKit ~= "" then
		atlasFrameName = frameFormatStringExtra:format(textureKit, frameTextureKit);
	else
		atlasFrameName = frameFormatStringDefault:format(textureKit);
	end

	self.Frame:SetAtlas(atlasFrameName, TextureKitConstants.UseAtlasSize);

	local fillAtlas;
	if isFull then
		fillAtlas = fillFullTextureKitFormatString:format(textureKit);
	else
		fillAtlas = fillTextureKitFormatString:format(textureKit);
	end

	local fillAtlasInfo = C_Texture.GetAtlasInfo(fillAtlas);
	if fillAtlasInfo and fillAtlas ~= self.lastFillAtlas then
		self.Bar:SetStatusBarTexture(fillAtlas);
		self.Bar:SetSize(fillAtlasInfo.width, fillAtlasInfo.height);
		self.Spark:SetPoint("CENTER", self.Bar:GetStatusBarTexture(), "TOP", 0, 0);
		self.Bar.FlipbookMask:SetPoint("TOP", self.Bar:GetStatusBarTexture(), "TOP", 0, 0);
		self.lastFillAtlas = fillAtlas;
	end

	local flipbookAtlas = fillFlipbookTextureKitFormatString:format(textureKit);
	local flipbookAtlasInfo = C_Texture.GetAtlasInfo(flipbookAtlas);
	if flipbookAtlasInfo then
		self.Bar.Flipbook:SetAtlas(flipbookAtlas, TextureKitConstants.UseAtlasSize);
	end

	local burstFlipbookAtlas = burstFlipbookTextureKitFormatString:format(textureKit);
	local burstFlipbookAtlasInfo = C_Texture.GetAtlasInfo(burstFlipbookAtlas);
	if burstFlipbookAtlasInfo then
		self.Bar.BurstFlipbook:SetAtlas(burstFlipbookAtlas, TextureKitConstants.UseAtlasSize);

		local burstFlipbookFixedSize = burstFlipbookfixedSizeByTextureKit[textureKit];
		if burstFlipbookFixedSize then
			self.Bar.BurstFlipbook:SetSize(burstFlipbookFixedSize.width, burstFlipbookFixedSize.height);
		end
	else
		self.Bar.BurstFlipbook:Hide();
	end

	local filledFlipbookAtlas = filledFlipbookTextureKitFormatString:format(textureKit);
	local filledFlipbookAtlasInfo = C_Texture.GetAtlasInfo(filledFlipbookAtlas);
	if filledFlipbookAtlasInfo then
		self.Bar.FilledFlipbook:SetAtlas(filledFlipbookAtlas, TextureKitConstants.UseAtlasSize);
		
		local filledFlipbookFixedSize = filledFlipbookfixedSizeByTextureKit[textureKit];
		if filledFlipbookFixedSize then
			self.Bar.FilledFlipbook:SetSize(filledFlipbookFixedSize.width, filledFlipbookFixedSize.height);
		end
	else
		self.Bar.FilledFlipbook:Hide();
	end

	self.Bar:SetMinMaxValues(min, max);

	if isFull then
		self.Bar:SetValue(max);
	elseif isFilling then
        self.Bar:SetValue(value);
	else
		self.Bar:SetValue(min);
	end

	if flashFrame then
		self.Bar.Flipbook:Hide();
		self.Flash.PulseAnim:Stop();
		self.Flash.FlashAnim:Restart();
		if flashFameSound[textureKit] then
			PlaySound(flashFameSound[textureKit]);
		end

		if filledFlipbookAtlasInfo then
			self.Bar.FilledFlipbook:Show();
			self.Bar.FilledFlipbookAnim:Restart();	
		else
			self.Bar.FilledFlipbook:Hide();
			self.Bar.FilledFlipbookAnim:Stop();
		end
	else
		if pulseFrame then
			self.Flash.PulseAnim:Play();
			if flipbookAtlasInfo then
				if value > 0 then
					self.Bar.Flipbook:Show();
					self.Bar.FillupFlipbookAnim:Play();
				else
					self.Bar.Flipbook:Hide();
					self.Bar.FillupFlipbookAnim:Stop();
				end
			end
		else
			self.Flash.PulseAnim:Stop();
			self.Bar.Flipbook:Hide();
			self.Bar.FillupFlipbookAnim:Stop();
		end
	end

	if consumeFrame then
		if burstFlipbookAtlasInfo then
			self.Bar.BurstFlipbook:Show();
			self.Bar.BurstFlipbookAnim:Restart();
		else
			self.Bar.BurstFlipbook:Hide();
			self.Bar.BurstFlipbookAnim:Stop();
		end
	end

	self.Spark:SetShown(isFilling and value > min and value < max);

	local fixedSize = fixedSizeByTextureKit[textureKit];
	if fixedSize then
		self.fixedWidth = fixedSize.width;
		self.fixedHeight = fixedSize.height;
	else
		self.fixedWidth = nil;
		self.fixedHeight = nil;
	end

	self.leftPadding = nil;
	self.rightPadding = nil;

	self:Show();
	self:Layout();
end

EMEDecorFlipbookAnimMixin = {}

function EMEDecorFlipbookAnimMixin:OnAnimFinished()
	self:GetParent().DecorFlipbookLeft:Hide();
	self:GetParent().DecorFlipbookRight:Hide();
end

EMEFilledFlipbookAnimMixin = {}

function EMEFilledFlipbookAnimMixin:OnAnimFinished()
	self:GetParent().FilledFlipbook:Hide();
end

EMEBurstFlipbookAnimMixin = {}

function EMEBurstFlipbookAnimMixin:OnAnimFinished()
	self:GetParent().BurstFlipbook:Hide();
end

local SURGE_FORWARD_SPELL_ID = 372608
local ALGARI_STORMRIDER_SPELL_ID = 417888

local selectedVigorWidgetID = nil

local function shouldShow(widgetID)
    local _, canGlide = C_PlayerInfo.GetGlidingInfo()
    
    local stormriderAura = C_UnitAuras.GetPlayerAuraBySpellID(ALGARI_STORMRIDER_SPELL_ID)
    
    if selectedVigorWidgetID == 1 then
        if (widgetID == 5140) and stormriderAura then
            return canGlide
        end
        
        if (widgetID == 4460) and (not stormriderAura) then
            return canGlide
        end
        
        return false
    end
    
    return (selectedVigorWidgetID == widgetID) and canGlide
end

local container
local function updateWidget(vigorFrame, widgetID)
    local show = shouldShow(widgetID)
    vigorFrame:SetShown(show)
    if not show then return end
    
    local chargeInfo = C_Spell.GetSpellCharges(SURGE_FORWARD_SPELL_ID)
    if chargeInfo then
        --[[
            currentCharges 	number 	Number of charges currently available
            maxCharges 	number 	Max number of charges that can be accumulated
            cooldownStartTime 	number 	If charge cooldown is active, time at which the most recent charge cooldown began; 0 if cooldown is not active
            cooldownDuration 	number 	Cooldown duration in seconds required to generate a charge
            chargeModRate 	number 	Rate at which cooldown UI should update 
        --]]
        
        widgetInfos[widgetID].numTotalFrames = chargeInfo.maxCharges
        widgetInfos[widgetID].numFullFrames = chargeInfo.currentCharges
        widgetInfos[widgetID].pulseFillingFrame = false
        if chargeInfo.cooldownStartTime > 0 then
            widgetInfos[widgetID].fillValue = 100 * (GetTime() - chargeInfo.cooldownStartTime) / chargeInfo.cooldownDuration
            if widgetInfos[widgetID].fillValue < 100 then
                widgetInfos[widgetID].pulseFillingFrame = true
            end
        end
        vigorFrame:Setup(widgetInfos[widgetID], container)
    end
end

local dropdownOptions = {
    [1] = "Mix: Dragonriding and Algari Stormrider",
    [4460] = "Dragonriding",
    [5140] = "Algari - Gold",
    [5143] = "Algari - Silver",
    [5144] = "Algari - Bronze",
    [5145] = "Algari - Dark",
}

local function initDropDown()
    local dropdown, getSettingDB = lib:RegisterDropdown(container, libDD, "SelectedVigorBarAppearance")
    
    libDD:UIDropDownMenu_Initialize(dropdown, function(self)
        local db = getSettingDB()
        local info = libDD:UIDropDownMenu_CreateInfo()        
        for widgetID, dropdownName in pairs(dropdownOptions) do
            info.text = dropdownName
            info.checked = db.checked == widgetID
            info.func = function()
                if db.checked == widgetID then
                    db.checked = nil
                else
                    db.checked = widgetID
                end
                selectedVigorWidgetID = widgetID
            end
            libDD:UIDropDownMenu_AddButton(info)
        end
    end)
    
    C_Timer.After(1, function()
        local db = getSettingDB()
        selectedVigorWidgetID = db.checked
    end)
    
    libDD:UIDropDownMenu_SetWidth(dropdown, 200)
    libDD:UIDropDownMenu_SetText(dropdown, "Vigor Bar Apperance")
end

function addon:initVigorBar()
    local db = addon.db.global
    if not db.EMEOptions.vigorBar then return end
    
    container = CreateFrame("Frame", "EMEVigorContainer", UIParent, "UIWidgetContainerTemplate")
    container:SetPoint("CENTER", UIParent, "CENTER", -75, -200)
    container:RegisterForWidgetSet(widgetSetID)
    container:SetScript("OnEvent", nop)
    addon:registerFrame(container, L["Vigor Bar"], db.VigorBar, UIParent, "CENTER")
    lib:RegisterResizable(container)
    lib:SetDefaultSize(container, 305, 66)
    container:Show()
    initDropDown()
    
    for _, widgetID in ipairs(widgetIDs) do
        local vigorFrame = CreateFrame("Frame", "EMEVigorFrame"..widgetID, container, "EMEWidgetTemplateFillUpFrames")
        vigorFrame:Setup(widgetInfos[widgetID], container)
        DefaultWidgetLayout(container, {vigorFrame})
        vigorFrame:SetShown(shouldShow(widgetID))
        vigorFrame:RegisterEvent("PLAYER_CAN_GLIDE_CHANGED")
        vigorFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
        vigorFrame:SetScript("OnEvent", function(self)
            updateWidget(self, widgetID)
        end)
        vigorFrame:HookScript("OnUpdate", function(self)
            updateWidget(self, widgetID)
        end)
    end
    container.Layout = nop
    container:SetSize(305, 66)
end