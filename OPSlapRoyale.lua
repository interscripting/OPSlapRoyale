local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	TweenService = game:GetService("TweenService"),
	UserInputService = game:GetService("UserInputService"),
	MarketplaceService = game:GetService("MarketplaceService"),
	ContextActionService = game:GetService("ContextActionService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	CollectionService = game:GetService("CollectionService")
}

local Players = Services.Players
local RunService = Services.RunService
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local MarketplaceService = Services.MarketplaceService
local ContextActionService = Services.ContextActionService
local ReplicatedStorage = Services.ReplicatedStorage
local player = Players.LocalPlayer

local Config = {}

Config.Themes = {
	["Midnight Arcade"] = {
		Main = Color3.fromRGB(9, 11, 20),
		Panel = Color3.fromRGB(18, 22, 36),
		Button = Color3.fromRGB(0, 210, 255),
		ButtonDark = Color3.fromRGB(27, 32, 50),
		Stroke = Color3.fromRGB(96, 225, 255),
		Text = Color3.fromRGB(245, 250, 255),
		SubText = Color3.fromRGB(155, 190, 210)
	},
	["Inferno Ops"] = {
		Main = Color3.fromRGB(18, 10, 8),
		Panel = Color3.fromRGB(34, 18, 14),
		Button = Color3.fromRGB(255, 92, 38),
		ButtonDark = Color3.fromRGB(55, 30, 22),
		Stroke = Color3.fromRGB(255, 168, 76),
		Text = Color3.fromRGB(255, 244, 234),
		SubText = Color3.fromRGB(255, 188, 138)
	},
	["Mint Circuit"] = {
		Main = Color3.fromRGB(7, 18, 16),
		Panel = Color3.fromRGB(13, 34, 30),
		Button = Color3.fromRGB(68, 255, 190),
		ButtonDark = Color3.fromRGB(20, 52, 46),
		Stroke = Color3.fromRGB(130, 255, 220),
		Text = Color3.fromRGB(238, 255, 250),
		SubText = Color3.fromRGB(160, 235, 215)
	},
	["Royal Pulse"] = {
		Main = Color3.fromRGB(13, 9, 24),
		Panel = Color3.fromRGB(27, 18, 48),
		Button = Color3.fromRGB(175, 95, 255),
		ButtonDark = Color3.fromRGB(45, 30, 74),
		Stroke = Color3.fromRGB(218, 165, 255),
		Text = Color3.fromRGB(250, 244, 255),
		SubText = Color3.fromRGB(210, 182, 245)
	},
	["Storm Glass"] = {
		Main = Color3.fromRGB(10, 16, 22),
		Panel = Color3.fromRGB(19, 31, 42),
		Button = Color3.fromRGB(105, 205, 255),
		ButtonDark = Color3.fromRGB(30, 48, 62),
		Stroke = Color3.fromRGB(170, 230, 255),
		Text = Color3.fromRGB(240, 250, 255),
		SubText = Color3.fromRGB(170, 210, 230)
	}
}

local themes = Config.Themes
local currentTheme = themes["Midnight Arcade"]

local UI = {
	ThemedObjects = {},
	TabButtons = {},
	Pages = {},
	SelectedTab = "Main",
	TopLevelToggleOrder = 0
}

local Notify = {
	Order = 0,
	Active = {},
	Width = 374,
	Height = 96,
	Gap = 10,
	BottomOffset = 104,
	RightOffset = 22,
	LifeTime = 4.2,
	MaxVisible = 5
}

Notify.Presets = {
	Info = {
		Icon = "i",
		Color = Color3.fromRGB(95, 205, 255)
	},
	Success = {
		Icon = "+",
		Color = Color3.fromRGB(95, 255, 165)
	},
	Warning = {
		Icon = "!",
		Color = Color3.fromRGB(255, 205, 85)
	},
	Error = {
		Icon = "x",
		Color = Color3.fromRGB(255, 90, 105)
	}
}

local themedObjects = UI.ThemedObjects
local tabButtons = UI.TabButtons
local pages = UI.Pages
local selectedTabName = UI.SelectedTab
local topLevelToggleOrder = UI.TopLevelToggleOrder

local gui = Instance.new("ScreenGui")
gui.Name = "OPSlapRoyaleUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

function UI.ThemeObject(object, property, key)
	table.insert(UI.ThemedObjects, {
		Object = object,
		Property = property,
		Key = key
	})

	object[property] = currentTheme[key]
end

function UI.AddCorner(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = object
	return corner
end

function UI.AddStroke(object, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(0, 0, 0)
	stroke.Thickness = thickness or 2
	stroke.Parent = object
	return stroke
end

function UI.StyleButton(button)
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	UI.AddCorner(button, 8)

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = button

	local stroke = UI.AddStroke(button, Color3.fromRGB(0, 0, 0), 1)
	stroke.Transparency = 0.18

	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Transparency = 0.82
	glow.Parent = button
	UI.ThemeObject(glow, "Color", "Stroke")
	UI.ThemeObject(button, "TextColor3", "Text")

	local hovering = false

	local function tweenScale(targetScale, duration)
		TweenService:Create(
			scale,
			TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Scale = targetScale }
		):Play()
	end

	local function tweenButton(backgroundTransparency, glowTransparency, duration)
		TweenService:Create(
			button,
			TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ BackgroundTransparency = backgroundTransparency }
		):Play()

		TweenService:Create(
			glow,
			TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Transparency = glowTransparency }
		):Play()
	end

	button.MouseEnter:Connect(function()
		hovering = true
		tweenScale(1.018, 0.16)
		tweenButton(0.04, 0.42, 0.16)
	end)

	button.MouseLeave:Connect(function()
		hovering = false
		tweenScale(1, 0.18)
		tweenButton(0, 0.82, 0.18)
	end)

	button.MouseButton1Down:Connect(function()
		tweenScale(0.965, 0.08)
		tweenButton(0.13, 0.32, 0.08)
	end)

	button.MouseButton1Up:Connect(function()
		tweenScale(hovering and 1.018 or 1, 0.18)
		tweenButton(hovering and 0.04 or 0, hovering and 0.42 or 0.82, 0.18)
	end)
end

local themeObject = UI.ThemeObject
local addCorner = UI.AddCorner
local addStroke = UI.AddStroke
local styleButton = UI.StyleButton

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(660, 430)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.BackgroundTransparency = 0
mainFrame.Parent = gui
themeObject(mainFrame, "BackgroundColor3", "Main")
addCorner(mainFrame, 12)

local normalSize = UDim2.fromOffset(660, 430)
local minimizedSize = UDim2.fromOffset(560, 58)
local windowTween = nil

mainFrame.Size = UDim2.fromOffset(590, 360)
mainFrame.Position = UDim2.fromScale(0.5, 0.54)

local function tweenWindow(targetSize, targetPosition, duration)
	if windowTween then
		windowTween:Cancel()
	end

	windowTween = TweenService:Create(
		mainFrame,
		TweenInfo.new(duration or 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Size = targetSize,
			Position = targetPosition
		}
	)

	windowTween:Play()
	return windowTween
end

task.defer(function()
	tweenWindow(normalSize, UDim2.fromScale(0.5, 0.5), 0.45)
end)

local mainStroke = addStroke(mainFrame, currentTheme.Stroke, 1)
themeObject(mainStroke, "Color", "Stroke")

local outerGlow = Instance.new("UIStroke")
outerGlow.Thickness = 4
outerGlow.Transparency = 0.78
outerGlow.Parent = mainFrame
themeObject(outerGlow, "Color", "Stroke")

local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(1, -28, 0, 3)
topAccent.Position = UDim2.fromOffset(14, 56)
topAccent.BorderSizePixel = 0
topAccent.Parent = mainFrame
themeObject(topAccent, "BackgroundColor3", "Stroke")
addCorner(topAccent, 2)

local scanlineHolder = Instance.new("Frame")
scanlineHolder.Size = UDim2.fromScale(1, 1)
scanlineHolder.BackgroundTransparency = 1
scanlineHolder.ZIndex = 0
scanlineHolder.Parent = mainFrame

for i = 1, 10 do
	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, 0, 0, 1)
	line.Position = UDim2.new(0, 0, 0, i * 38)
	line.BackgroundTransparency = 0.88
	line.BorderSizePixel = 0
	line.Parent = scanlineHolder
	themeObject(line, "BackgroundColor3", "Stroke")
end

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 60)
topBar.BackgroundTransparency = 1
topBar.Parent = mainFrame

local titleBox = Instance.new("Frame")
titleBox.Size = UDim2.new(1, -112, 0, 34)
titleBox.Position = UDim2.fromOffset(12, 9)
titleBox.BorderSizePixel = 0
titleBox.Parent = topBar
themeObject(titleBox, "BackgroundColor3", "Panel")
addCorner(titleBox, 9)
addStroke(titleBox, Color3.fromRGB(0, 0, 0), 2)

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(1, 1)
title.BackgroundTransparency = 1
title.Text = "OP Slap Royale"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = titleBox
themeObject(title, "TextColor3", "Text")

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.fromOffset(34, 34)
minimizeButton.Position = UDim2.new(1, -76, 0, 9)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
minimizeButton.Parent = topBar
themeObject(minimizeButton, "BackgroundColor3", "ButtonDark")
styleButton(minimizeButton)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(34, 34)
closeButton.Position = UDim2.new(1, -38, 0, 9)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = topBar
themeObject(closeButton, "BackgroundColor3", "ButtonDark")
styleButton(closeButton)

local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(0, 172, 1, -82)
tabScroll.Position = UDim2.fromOffset(14, 68)
tabScroll.BorderSizePixel = 0
tabScroll.ScrollBarThickness = 4
tabScroll.CanvasSize = UDim2.fromOffset(0, 0)
tabScroll.ClipsDescendants = true
tabScroll.Parent = mainFrame
themeObject(tabScroll, "BackgroundColor3", "Panel")
addCorner(tabScroll, 10)

local tabStroke = addStroke(tabScroll, currentTheme.Stroke, 1)
themeObject(tabStroke, "Color", "Stroke")

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 8)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabScroll

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 10)
tabPadding.PaddingLeft = UDim.new(0, 10)
tabPadding.PaddingRight = UDim.new(0, 10)
tabPadding.Parent = tabScroll

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -206, 1, -82)
contentFrame.Position = UDim2.fromOffset(194, 68)
contentFrame.BorderSizePixel = 0
contentFrame.ClipsDescendants = true
contentFrame.Parent = mainFrame
themeObject(contentFrame, "BackgroundColor3", "Panel")
addCorner(contentFrame, 10)

local contentStroke = addStroke(contentFrame, currentTheme.Stroke, 1)
themeObject(contentStroke, "Color", "Stroke")

function UI.CreatePage(name)
	local page = Instance.new("Frame")
	page.Name = name .. "Page"
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = contentFrame
	UI.Pages[name] = page
	return page
end

local createPage = UI.CreatePage

local mainPage = createPage("Main")
local itemsPage = createPage("Items")
local combatPage = createPage("Combat")
local miscPage = createPage("Misc")
local themePage = createPage("Theme")

function UI.ApplyTheme(themeName)
	if not themes[themeName] then
		return
	end

	currentTheme = themes[themeName]

	for _, item in ipairs(UI.ThemedObjects) do
		if item.Object and item.Object.Parent then
			item.Object[item.Property] = currentTheme[item.Key]
		end
	end

	for name, button in pairs(UI.TabButtons) do
		button.BackgroundColor3 = name == UI.SelectedTab and currentTheme.Button or currentTheme.ButtonDark
	end
end

function UI.SelectTab(tabName)
	UI.SelectedTab = tabName
	selectedTabName = tabName

	for name, page in pairs(UI.Pages) do
		page.Visible = name == tabName
	end

	for name, button in pairs(UI.TabButtons) do
		button.BackgroundColor3 = name == tabName and currentTheme.Button or currentTheme.ButtonDark
	end
end

local applyTheme = UI.ApplyTheme
local selectTab = UI.SelectTab

local tabIcons = {
	Main = "*",
	Items = "!",
	Combat = ">",
	Misc = "+",
	Theme = "#"
}

function UI.CreateTab(name)
	local button = Instance.new("TextButton")
	button.Name = name .. "Tab"
	button.Size = UDim2.new(1, -4, 0, 46)
	button.Text = (tabIcons[name] or "-") .. "  " .. name
	button.Font = Enum.Font.GothamBlack
	button.TextSize = 14
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = tabScroll
	themeObject(button, "BackgroundColor3", "ButtonDark")
	styleButton(button)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 16)
	padding.Parent = button

	UI.TabButtons[name] = button

	button.MouseButton1Click:Connect(function()
		selectTab(name)
	end)
end

UI.CreateTab("Main")
UI.CreateTab("Items")
UI.CreateTab("Combat")
UI.CreateTab("Misc")
UI.CreateTab("Theme")

function UI.CreatePageTitle(parent, text)
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, -28, 0, 48)
	box.Position = UDim2.fromOffset(14, 12)
	box.BorderSizePixel = 0
	box.Parent = parent
	themeObject(box, "BackgroundColor3", "ButtonDark")
	addCorner(box, 8)

	local rail = Instance.new("Frame")
	rail.Size = UDim2.new(0, 5, 1, -14)
	rail.Position = UDim2.fromOffset(12, 7)
	rail.BorderSizePixel = 0
	rail.Parent = box
	themeObject(rail, "BackgroundColor3", "Button")
	addCorner(rail, 4)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -42, 1, 0)
	label.Position = UDim2.fromOffset(28, 0)
	label.BackgroundTransparency = 1
	label.Text = string.upper(text)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = box
	themeObject(label, "TextColor3", "Text")
end

UI.CreatePageTitle(mainPage, "Main")
UI.CreatePageTitle(itemsPage, "Items")
UI.CreatePageTitle(combatPage, "Combat")
UI.CreatePageTitle(miscPage, "Misc")
UI.CreatePageTitle(themePage, "Theme")

function UI.CreatePageList(parent)
	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -36, 1, -124)
	list.Position = UDim2.fromOffset(18, 68)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 4
	list.CanvasSize = UDim2.fromOffset(0, 0)
	list.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	local function updateCanvas()
		task.wait()
		list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
	end

	return list, updateCanvas
end

local mainList, updateMainCanvas = UI.CreatePageList(mainPage)
local itemsList, updateItemsCanvas = UI.CreatePageList(itemsPage)
local combatList, updateCombatCanvas = UI.CreatePageList(combatPage)
local miscList, updateMiscCanvas = UI.CreatePageList(miscPage)

function UI.CreateSmallButton(parent, text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -12, 0, 36)
	button.Text = text
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = parent
	themeObject(button, "BackgroundColor3", "Button")
	styleButton(button)
	button.MouseButton1Click:Connect(callback)
	return button
end

function UI.CreateWarningLabel(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -12, 0, 28)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextColor3 = Color3.fromRGB(255, 80, 80)
	label.Parent = parent
	return label
end

UI.ToggleDescriptions = {
	["Auto Collect"] = "Collects available items in priority order.",
	["Auto Use"] = "Uses buff items from your inventory automatically.",
	["Auto Heal"] = "Uses healing items when your health is low.",
	["Show checklist"] = "Shows the item checklist on the right side of the screen.",
	["Expand Hitbox"] = "Applies the selected hitbox size to other players.",
	["Visualise Hitboxes"] = "Shows or hides the hitbox visuals.",
	["Player Stats ESP"] = "Shows player stats above each player.",
	["Anti Acid & Lava"] = "Creates invisible safety platforms over danger zones."
}

function UI.CreateToggleButton(parent, text, defaultState, callback, descriptionText)
	local state = defaultState == true
	local description = descriptionText or UI.ToggleDescriptions[text] or ""

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -12, 0, description ~= "" and 58 or 40)
	button.Text = ""
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = parent

	if not parent:GetAttribute("IsDropdownBody") then
		UI.TopLevelToggleOrder += 1
		topLevelToggleOrder = UI.TopLevelToggleOrder
		button.LayoutOrder = -1000 + UI.TopLevelToggleOrder
	end

	themeObject(button, "BackgroundColor3", "ButtonDark")
	styleButton(button)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 0, description ~= "" and 24 or 40)
	label.Position = UDim2.fromOffset(12, description ~= "" and 5 or 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button
	themeObject(label, "TextColor3", "Text")

	local descriptionLabel = nil

	if description ~= "" then
		descriptionLabel = Instance.new("TextLabel")
		descriptionLabel.Size = UDim2.new(1, -76, 0, 24)
		descriptionLabel.Position = UDim2.fromOffset(12, 28)
		descriptionLabel.BackgroundTransparency = 1
		descriptionLabel.Text = description
		descriptionLabel.Font = Enum.Font.GothamMedium
		descriptionLabel.TextSize = 10
		descriptionLabel.TextWrapped = true
		descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
		descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
		descriptionLabel.Parent = button
		themeObject(descriptionLabel, "TextColor3", "SubText")
	end

	local switch = Instance.new("Frame")
	switch.Size = UDim2.fromOffset(42, 22)
	switch.Position = UDim2.new(1, -52, 0, description ~= "" and 10 or 9)
	switch.BorderSizePixel = 0
	switch.Parent = button
	addCorner(switch, 11)
	addStroke(switch, Color3.fromRGB(0, 0, 0), 1)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(16, 16)
	knob.Position = UDim2.fromOffset(3, 3)
	knob.BorderSizePixel = 0
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Parent = switch
	addCorner(knob, 8)

	local function setState(newState, runCallback)
		state = newState

		button.BackgroundColor3 = currentTheme.ButtonDark
		switch.BackgroundColor3 = state and currentTheme.Button or Color3.fromRGB(35, 35, 35)

		label.TextColor3 = currentTheme.Text

		if descriptionLabel then
			descriptionLabel.TextColor3 = currentTheme.SubText
		end

		TweenService:Create(
			knob,
			TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = state and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }
		):Play()

		if runCallback then
			callback(state)
		end
	end

	button.MouseButton1Click:Connect(function()
		setState(not state, true)
	end)

	setState(state, false)

	return {
		Button = button,
		Label = label,
		Description = descriptionLabel,
		Set = setState,
		Get = function()
			return state
		end
	}
end
function UI.CreateDropdown(list, titleText, updateCanvas)
	local wrapper = Instance.new("Frame")
	wrapper.Size = UDim2.new(1, -6, 0, 47)
	wrapper.BackgroundTransparency = 1
	wrapper.BorderSizePixel = 0
	wrapper.ClipsDescendants = false
	wrapper.Parent = list

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -24, 0, 44)
	holder.Position = UDim2.new(0.5, 0, 0, 3)
	holder.AnchorPoint = Vector2.new(0.5, 0)
	holder.BorderSizePixel = 0
	holder.ClipsDescendants = true
	holder.Parent = wrapper
	themeObject(holder, "BackgroundColor3", "ButtonDark")
	addCorner(holder, 8)
	addStroke(holder, Color3.fromRGB(0, 0, 0), 2)

	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, 0, 0, 44)
	header.BackgroundTransparency = 1
	header.Text = titleText
	header.Font = Enum.Font.GothamBold
	header.TextSize = 14
	header.TextXAlignment = Enum.TextXAlignment.Center
	header.Parent = holder
	themeObject(header, "TextColor3", "Text")

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.fromOffset(28, 28)
	arrow.Position = UDim2.new(1, -40, 0, 8)
	arrow.BackgroundTransparency = 1
	arrow.Text = "v"
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 16
	arrow.Parent = holder
	themeObject(arrow, "TextColor3", "Text")

	local dropdownScale = Instance.new("UIScale")
	dropdownScale.Scale = 1
	dropdownScale.Parent = holder

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, 0, 0, 0)
	body.Position = UDim2.fromOffset(0, 48)
	body.BackgroundTransparency = 1
	body.Visible = false
	body.Parent = holder
	body:SetAttribute("IsDropdownBody", true)

	local bodyLayout = Instance.new("UIListLayout")
	bodyLayout.Padding = UDim.new(0, 8)
	bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	bodyLayout.Parent = body

	local bodyPadding = Instance.new("UIPadding")
	bodyPadding.PaddingLeft = UDim.new(0, 6)
	bodyPadding.PaddingRight = UDim.new(0, 6)
	bodyPadding.Parent = body

	local open = false

	local function refreshSize(animated)
		local bodyHeight = bodyLayout.AbsoluteContentSize.Y + 12
		local targetHeight = open and (52 + bodyHeight) or 44

		body.Size = UDim2.new(1, 0, 0, bodyHeight)
		wrapper.Size = UDim2.new(1, -6, 0, targetHeight + 3)

		if animated then
			TweenService:Create(
				holder,
				TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, -24, 0, targetHeight) }
			):Play()
		else
			holder.Size = UDim2.new(1, -24, 0, targetHeight)
		end

		updateCanvas()
		task.delay(0.28, updateCanvas)
	end

	local function toggle()
		open = not open
		body.Visible = open
		arrow.Text = open and "^" or "v"

		TweenService:Create(
			dropdownScale,
			TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Scale = 0.985 }
		):Play()

		task.delay(0.08, function()
			if dropdownScale.Parent then
				TweenService:Create(
					dropdownScale,
					TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{ Scale = 1 }
				):Play()
			end
		end)

		refreshSize(true)
	end

	header.MouseButton1Click:Connect(toggle)
	arrow.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			toggle()
		end
	end)

	bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		refreshSize(false)
	end)

	updateCanvas()
	return body
end

local createSmallButton = UI.CreateSmallButton
local createWarningLabel = UI.CreateWarningLabel
local createToggleButton = UI.CreateToggleButton
local createDropdown = UI.CreateDropdown

function Notify.GetKind(titleText, kind)
	if kind and Notify.Presets[kind] then
		return kind
	end

	local title = string.lower(tostring(titleText))

	if string.find(title, "error") or string.find(title, "failed") then
		return "Error"
	end

	if string.find(title, "warning") or string.find(title, "anti") or string.find(title, "wait") or string.find(title, "cooldown") then
		return "Warning"
	end

	if string.find(title, "enabled") or string.find(title, "found") or string.find(title, "success") then
		return "Success"
	end

	return "Info"
end

local notificationStack = Instance.new("Frame")
notificationStack.Name = "NotificationStack"
notificationStack.Size = UDim2.new(0, Notify.Width, 1, -Notify.BottomOffset)
notificationStack.Position = UDim2.new(1, -(Notify.Width + Notify.RightOffset), 0, 0)
notificationStack.BackgroundTransparency = 1
notificationStack.Parent = gui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.FillDirection = Enum.FillDirection.Vertical
notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.Padding = UDim.new(0, Notify.Gap)
notificationLayout.Parent = notificationStack

function Notify.Trim()
	while #Notify.Active > Notify.MaxVisible do
		local oldest = table.remove(Notify.Active, 1)
		if oldest and oldest.Parent then
			oldest:Destroy()
		end
	end
end

function Notify.Show(titleText, messageText, kind)
	Notify.Order += 1

	local preset = Notify.Presets[Notify.GetKind(titleText, kind)]

	local slot = Instance.new("Frame")
	slot.Size = UDim2.fromOffset(Notify.Width, 0)
	slot.BackgroundTransparency = 1
	slot.LayoutOrder = Notify.Order
	slot.ClipsDescendants = true
	slot.Parent = notificationStack

	table.insert(Notify.Active, slot)
	Notify.Trim()

	local popup = Instance.new("TextButton")
	popup.Size = UDim2.fromOffset(Notify.Width, Notify.Height)
	popup.Position = UDim2.fromOffset(Notify.Width + 42, 0)
	popup.BackgroundTransparency = 0.04
	popup.BorderSizePixel = 0
	popup.Text = ""
	popup.AutoButtonColor = false
	popup.ClipsDescendants = true
	popup.Parent = slot
	themeObject(popup, "BackgroundColor3", "Panel")
	addCorner(popup, 12)

	local scale = Instance.new("UIScale")
	scale.Scale = 0.92
	scale.Parent = popup

	local stroke = addStroke(popup, preset.Color, 1)
	stroke.Transparency = 0.18

	local glow = Instance.new("UIStroke")
	glow.Thickness = 4
	glow.Transparency = 0.76
	glow.Color = preset.Color
	glow.Parent = popup

	local iconBubble = Instance.new("Frame")
	iconBubble.Size = UDim2.fromOffset(34, 34)
	iconBubble.Position = UDim2.fromOffset(14, 13)
	iconBubble.BorderSizePixel = 0
	iconBubble.BackgroundColor3 = preset.Color
	iconBubble.Parent = popup
	addCorner(iconBubble, 17)

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromScale(1, 1)
	icon.BackgroundTransparency = 1
	icon.Text = preset.Icon
	icon.Font = Enum.Font.GothamBlack
	icon.TextSize = 18
	icon.TextColor3 = Color3.fromRGB(10, 12, 18)
	icon.Parent = iconBubble

	local noteTitle = Instance.new("TextLabel")
	noteTitle.Size = UDim2.new(1, -72, 0, 25)
	noteTitle.Position = UDim2.fromOffset(58, 12)
	noteTitle.BackgroundTransparency = 1
	noteTitle.Text = tostring(titleText)
	noteTitle.Font = Enum.Font.GothamBlack
	noteTitle.TextSize = 15
	noteTitle.TextXAlignment = Enum.TextXAlignment.Left
	noteTitle.TextTruncate = Enum.TextTruncate.AtEnd
	noteTitle.Parent = popup
	themeObject(noteTitle, "TextColor3", "Text")

	local message = Instance.new("TextLabel")
	message.Size = UDim2.new(1, -72, 0, 38)
	message.Position = UDim2.fromOffset(58, 38)
	message.BackgroundTransparency = 1
	message.Text = tostring(messageText)
	message.Font = Enum.Font.GothamMedium
	message.TextSize = 12
	message.TextWrapped = true
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextYAlignment = Enum.TextYAlignment.Top
	message.Parent = popup
	themeObject(message, "TextColor3", "SubText")

	local progressBack = Instance.new("Frame")
	progressBack.Size = UDim2.new(1, -28, 0, 4)
	progressBack.Position = UDim2.new(0, 14, 1, -12)
	progressBack.BorderSizePixel = 0
	progressBack.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	progressBack.BackgroundTransparency = 0.88
	progressBack.Parent = popup
	addCorner(progressBack, 3)

	local progress = Instance.new("Frame")
	progress.Size = UDim2.fromScale(1, 1)
	progress.BorderSizePixel = 0
	progress.BackgroundColor3 = preset.Color
	progress.Parent = progressBack
	addCorner(progress, 3)

	local dismissed = false

	local function dismiss()
		if dismissed then
			return
		end

		dismissed = true

		TweenService:Create(
			scale,
			TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{ Scale = 0.94 }
		):Play()

		TweenService:Create(
			slot,
			TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{ Size = UDim2.fromOffset(Notify.Width, 0) }
		):Play()

		local outTween = TweenService:Create(
			popup,
			TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				Position = UDim2.fromOffset(Notify.Width + 46, 0),
				BackgroundTransparency = 0.25
			}
		)

		outTween:Play()
		outTween.Completed:Connect(function()
			for index, item in ipairs(Notify.Active) do
				if item == slot then
					table.remove(Notify.Active, index)
					break
				end
			end

			if slot.Parent then
				slot:Destroy()
			end
		end)
	end

	TweenService:Create(
		slot,
		TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Size = UDim2.fromOffset(Notify.Width, Notify.Height) }
	):Play()

	TweenService:Create(
		popup,
		TweenInfo.new(0.42, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Position = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 0.02
		}
	):Play()

	TweenService:Create(
		scale,
		TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()

	TweenService:Create(
		progress,
		TweenInfo.new(Notify.LifeTime, Enum.EasingStyle.Linear),
		{ Size = UDim2.new(0, 0, 1, 0) }
	):Play()

	popup.MouseEnter:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.16, Enum.EasingStyle.Quint), { Scale = 1.018 }):Play()
		TweenService:Create(glow, TweenInfo.new(0.16, Enum.EasingStyle.Quint), { Transparency = 0.48 }):Play()
	end)

	popup.MouseLeave:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = 1 }):Play()
		TweenService:Create(glow, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Transparency = 0.76 }):Play()
	end)

	popup.MouseButton1Click:Connect(dismiss)

	task.delay(Notify.LifeTime, function()
		if popup.Parent then
			dismiss()
		end
	end)
end

local createNotification = Notify.Show

local Utility = {}
local Main = {}
local Teleport = {}
local Items = {}

Main.CodeKeywords = {
	"math", "equation", "problem", "code", "puzzle",
	"question", "solve", "answer", "number"
}

Teleport.MaxStrikes = 5
Teleport.Cooldown = 8
Teleport.Debounce = 2.5
Teleport.PostFLock = 1
Teleport.Strikes = 0
Teleport.LockedUntil = 0
Teleport.LastClickAt = 0
Teleport.BlockFUntil = 0

Items.SearchRootName = "Items"

Teleport.Locations = {
	{ Name = "Acid", Position = Vector3.new(-113, 14, -625) },
	{ Name = "Barn", Position = Vector3.new(477, 87, 318) },
	{ Name = "Beach", Position = Vector3.new(-463, 13, -702) },
	{ Name = "Bob Cave", Position = Vector3.new(315, 49, -576) },
	{ Name = "Bone Pit", Position = Vector3.new(-344, -150, -414) },
	{ Name = "Crystal", Position = Vector3.new(488, -50, -272) },
	{ Name = "Forest", Position = Vector3.new(7, 18, 4) },
	{ Name = "Lighthouse", Position = Vector3.new(113, 14, -625) },
	{ Name = "Saloon", Position = Vector3.new(-576, 17, -188) },
	{ Name = "School", Position = Vector3.new(494, 47, -322) },
	{ Name = "Shop", Position = Vector3.new(-575, 13, -481) },
	{ Name = "Towers", Position = Vector3.new(-31, 93, 428) },
	{ Name = "Tunnels", Position = Vector3.new(-561, -35, -234) },
	{ Name = "Volcano", Position = Vector3.new(-304, -26, 379) },
	{ Name = "Watch Tower", Position = Vector3.new(78, 124, 101) }
}

function Utility.NormalizeName(text)
	return string.lower(tostring(text):gsub("’", "'"))
end

function Utility.GetObjectCFrame(object)
	if object:IsA("BasePart") then
		return object.CFrame
	end

	if object:IsA("Model") then
		return object:GetPivot()
	end

	if object:IsA("Tool") then
		local handle = object:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			return handle.CFrame
		end
	end

	local part = object:FindFirstChildWhichIsA("BasePart", true)
	return part and part.CFrame or nil
end

function Main.GetPuzzleCode()
	local found = {}
	local ids = {}

	local function isRelevant(object)
		local full = string.lower(object:GetFullName())
		local name = string.lower(object.Name)

		for _, word in ipairs(Main.CodeKeywords) do
			if string.find(full, word) or string.find(name, word) then
				return true
			end
		end

		return false
	end

	for _, object in ipairs(game:GetDescendants()) do
		local image = nil

		if object:IsA("ImageLabel") or object:IsA("ImageButton") then
			image = object.Image
		elseif object:IsA("Decal") or object:IsA("Texture") then
			image = object.Texture
		end

		if image and image ~= "" and isRelevant(object) then
			local id = tonumber(string.match(image, "%d+"))

			if id and not found[id] then
				found[id] = true
				table.insert(ids, id)
			end
		end
	end

	local code = ""

	for _, id in ipairs(ids) do
		local success, info = pcall(function()
			return MarketplaceService:GetProductInfo(id)
		end)

		if success and info and info.Name then
			code = code .. tostring(info.Name)
		end
	end

	print("CODE:", code)
	return code
end

function Teleport.GetCooldownLeft()
	return math.max(0, math.ceil(Teleport.LockedUntil - os.clock()))
end

function Teleport.IsLocked()
	return os.clock() < Teleport.LockedUntil
end

function Teleport.ResetStrikesIfReady()
	if not Teleport.IsLocked() and Teleport.LockedUntil > 0 then
		Teleport.Strikes = 0
		Teleport.LockedUntil = 0
	end
end

function Teleport.ShowWarning(secondsText)
	createNotification(
		"Cooldown",
		"Wait " .. secondsText .. " before teleporting again.",
		"Warning"
	)
end

function Teleport.CanTeleport()
	Teleport.ResetStrikesIfReady()

	if Teleport.IsLocked() then
		Teleport.ShowWarning(Teleport.GetCooldownLeft() .. " seconds")
		return false
	end

	local debounceLeft = Teleport.Debounce - (os.clock() - Teleport.LastClickAt)

	if debounceLeft > 0 then
		Teleport.ShowWarning(string.format("%.1f seconds", debounceLeft))
		return false
	end

	return true
end

function Teleport.AddStrike()
	Teleport.LastClickAt = os.clock()
	Teleport.Strikes += 1

	if Teleport.Strikes >= Teleport.MaxStrikes then
		Teleport.LockedUntil = os.clock() + Teleport.Cooldown
	end
end

function Teleport.StartFBlock()
	Teleport.BlockFUntil = os.clock() + Teleport.PostFLock
end

function Teleport.ShowFBlockedWarning()
	local secondsLeft = math.max(1, math.ceil(Teleport.BlockFUntil - os.clock()))

	createNotification(
		"Cooldown",
		"Wait " .. secondsLeft .. " seconds before pressing F again.",
		"Warning"
	)
end

function Teleport.MoveRoot(root, targetCFrame)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	local _, yRotation, _ = root.CFrame:ToOrientation()
	root.CFrame = CFrame.new(targetCFrame.Position) * CFrame.Angles(0, yRotation, 0)

	task.wait()

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

function Teleport.CreateMarker(position)
	local markerPart = Instance.new("Part")
	markerPart.Name = "Part"
	markerPart.Size = Vector3.new(5, 1, 5)
	markerPart.Anchored = true
	markerPart.CanCollide = false
	markerPart.Transparency = 0.25
	markerPart.Color = Color3.fromRGB(0, 170, 255)
	markerPart.Material = Enum.Material.SmoothPlastic
	markerPart.Position = position
	markerPart.Parent = workspace
	return markerPart
end

function Teleport.ToLocation(locationName, position)
	if not Teleport.CanTeleport() then
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)

	if not root then
		createNotification("Teleport", "Could not find your character.", "Error")
		return
	end

	Teleport.CreateMarker(position)
	Teleport.MoveRoot(root, CFrame.new(position + Vector3.new(0, 5, 0)))
	Teleport.AddStrike()
	Teleport.StartFBlock()
	createNotification("Teleport", "Teleported to " .. locationName)
end

function Items.GetSearchRoot()
	return workspace:FindFirstChild(Items.SearchRootName)
end

function Items.GetSearchDescendants()
	local root = Items.GetSearchRoot()
	return root and root:GetDescendants() or {}
end

function Items.FindManualItem(itemName)
	for _, object in ipairs(Items.GetSearchDescendants()) do
		if Utility.NormalizeName(object.Name) == Utility.NormalizeName(itemName) then
			local itemCFrame = Utility.GetObjectCFrame(object)

			if itemCFrame then
				local part = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart", true)

				if part
					and part.Parent
					and part:IsDescendantOf(workspace)
					and part.Transparency < 0.95
					and part.Size.X > 0
					and part.Size.Y > 0
					and part.Size.Z > 0
				then
					return object, part
				end
			end
		end
	end

	return nil, nil
end

function Items.TeleportTo(itemName)
	if not Teleport.CanTeleport() then
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		createNotification("Items", "Could not find your character.", "Error")
		return
	end

	local itemObject, itemPart = Items.FindManualItem(itemName)

	if not itemObject or not itemPart then
		createNotification("Items", itemName .. " is not currently available.")
		return
	end

	task.wait(0.08)

	if not itemObject.Parent
		or not itemPart.Parent
		or not itemPart:IsDescendantOf(workspace)
		or itemPart.Transparency >= 0.95
	then
		createNotification("Items", itemName .. " disappeared before teleporting.")
		return
	end

	Teleport.MoveRoot(root, itemPart.CFrame + Vector3.new(0, 4, 0))
	Teleport.AddStrike()
	Teleport.StartFBlock()
	createNotification("Items", "Teleported to " .. itemName)
end

ContextActionService:BindActionAtPriority(
	"BlockFAfterTeleport",
	function(_, inputState)
		if inputState == Enum.UserInputState.Begin and os.clock() < Teleport.BlockFUntil then
			Teleport.ShowFBlockedWarning()
			return Enum.ContextActionResult.Sink
		end

		return Enum.ContextActionResult.Pass
	end,
	false,
	3000,
	Enum.KeyCode.F
)

local normalizeName = Utility.NormalizeName
local getObjectCFrame = Utility.GetObjectCFrame
local getPuzzleCode = Main.GetPuzzleCode

local canTeleport = Teleport.CanTeleport
local addTeleportStrike = Teleport.AddStrike
local startFBlockAfterTeleport = Teleport.StartFBlock
local teleportRootSafely = Teleport.MoveRoot
local teleportToLocation = Teleport.ToLocation
local teleportToItem = Items.TeleportTo
local getItemSearchDescendants = Items.GetSearchDescendants

local getCodeButton = createSmallButton(mainList, "Get Code", function()
	createNotification("Code", "Searching...")

	task.spawn(function()
		local code = Main.GetPuzzleCode()
		createNotification("Code Found", code ~= "" and code or "No code found.", code ~= "" and "Success" or "Info")
	end)
end)

local teleportDropdown = createDropdown(mainList, "Teleport", updateMainCanvas)
createWarningLabel(teleportDropdown, "DONT SPAM")

local itemsDropdown = createDropdown(itemsList, "Teleport to items", updateItemsCanvas)
itemsDropdown.Parent.Parent.LayoutOrder = 10

local itemsWarning = createWarningLabel(itemsDropdown, "DONT SPAM")
itemsWarning.LayoutOrder = 0

for _, location in ipairs(Teleport.Locations) do
	createSmallButton(teleportDropdown, location.Name, function()
		Teleport.ToLocation(location.Name, location.Position)
	end)
end



local CollectionService = Services.CollectionService

local autoCollectEnabled = false
local autoCollectThread = nil
local autoCollectToggle = nil

local COLLECTIBLE_TAG = "CollectibleItem"

local AUTO_COLLECT_TELEPORT_DELAY = 2
local AUTO_COLLECT_F_DELAY = 1
local AUTO_COLLECT_SAFE_LIMIT = 4
local AUTO_COLLECT_SAFE_WAIT = 8
local AUTO_COLLECT_POSITION_RADIUS = 8

local autoCollectCount = 0
local autoCollectWindowStartedAt = 0
local visitedCollectPositions = {}
local movementSave = nil

local itemNames = {
	"Apple",
	"Bandage",
	"Boba",
	"Bomb",
	"Bull's Essence",
	"Cube of Ice",
	"First Aid Kit",
	"Forcefield Crystal",
	"Frog Potion",
	"Gravitation Shard",
	"Healing Potion",
	"Lightning Potion",
	"Potion of Strength",
	"Speed Potion",
	"Sphere of Fury",
	"Tomahawk",
	"True Power"
}

local autoCollectPriority = {
	"True Power",
	"Potion of Strength",
	"Bull's Essence",
	"Boba",
	"Speed Potion",
	"Frog Potion",
	"Healing Potion",
	"Cube of Ice",
	"Sphere of Fury",
	"Tomahawk",
	"Gravitation Shard",
	"Bomb",
	"Lightning Potion",
	"First Aid Kit",
	"Apple",
	"Bandage",
	"Forcefield Crystal"
}

local function matchesItem(toolName, itemList)
	local normalized = normalizeName(toolName)

	for _, itemName in ipairs(itemList) do
		if normalized == normalizeName(itemName) then
			return true
		end
	end

	return false
end

local function getItemDisplayName(object)
	return object:GetAttribute("ItemName")
		or object:GetAttribute("DisplayName")
		or object.Name
end

local function itemNameMatches(object, wantedName)
	return normalizeName(getItemDisplayName(object)) == normalizeName(wantedName)
end

local function isItemMarkedGone(object)
	return object:GetAttribute("Collected") == true
		or object:GetAttribute("PickedUp") == true
		or object:GetAttribute("Available") == false
		or object:GetAttribute("Enabled") == false
end

local function getLiveItemPart(object)
	if not object or not object.Parent or not object:IsDescendantOf(workspace) or isItemMarkedGone(object) then
		return nil
	end

	local part = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart", true)

	if not part or not part.Parent or not part:IsDescendantOf(workspace) then
		return nil
	end

	if part.Transparency >= 0.95 or part.Size.X <= 0 or part.Size.Y <= 0 or part.Size.Z <= 0 then
		return nil
	end

	local characterModel = part:FindFirstAncestorOfClass("Model")
	if characterModel and Players:GetPlayerFromCharacter(characterModel) then
		return nil
	end

	return part
end

local function setMovementPaused(paused)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	if paused then
		if not movementSave then
			movementSave = {
				WalkSpeed = humanoid.WalkSpeed,
				JumpPower = humanoid.JumpPower,
				JumpHeight = humanoid.JumpHeight,
				AutoRotate = humanoid.AutoRotate
			}
		end

		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
		humanoid.AutoRotate = false
	elseif movementSave then
		humanoid.WalkSpeed = movementSave.WalkSpeed
		humanoid.JumpPower = movementSave.JumpPower
		humanoid.JumpHeight = movementSave.JumpHeight
		humanoid.AutoRotate = movementSave.AutoRotate
		movementSave = nil
	end
end

local function isVisitedCollectPosition(position)
	for _, visitedPosition in ipairs(visitedCollectPositions) do
		if (visitedPosition - position).Magnitude <= AUTO_COLLECT_POSITION_RADIUS then
			return true
		end
	end

	return false
end

local function markVisitedCollectPosition(position)
	table.insert(visitedCollectPositions, position)
end

local function getCollectibleSearchPool()
	local taggedItems = CollectionService:GetTagged(COLLECTIBLE_TAG)

	if #taggedItems > 0 then
		return taggedItems
	end

	return getItemSearchDescendants()
end

local function findLiveItemByName(wantedName)
	for _, object in ipairs(getCollectibleSearchPool()) do
		if itemNameMatches(object, wantedName) then
			local part = getLiveItemPart(object)

			if part and not isVisitedCollectPosition(part.Position) then
				return wantedName, part.CFrame, part.Position, object, part
			end
		end
	end

	return nil, nil, nil, nil, nil
end

local function findNextCollectTarget()
	for _, wantedName in ipairs(autoCollectPriority) do
		local itemName, itemCFrame, itemPosition, itemObject, itemPart = findLiveItemByName(wantedName)

		if itemName and itemCFrame and itemPosition and itemObject and itemPart then
			return itemName, itemCFrame, itemPosition, itemObject, itemPart
		end
	end

	return nil, nil, nil, nil, nil
end

local function isSameItemStillThere(itemObject, itemPart, wantedName)
	if not itemObject or not itemPart or not itemObject.Parent or not itemPart.Parent then
		return false
	end

	if not itemNameMatches(itemObject, wantedName) then
		return false
	end

	return getLiveItemPart(itemObject) == itemPart
end

local function pressF()
	local VirtualInputManager = game:GetService("VirtualInputManager")

	pcall(function()
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
		task.wait(0.05)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
	end)
end

local function resetAutoCollectWindowIfReady()
	if autoCollectWindowStartedAt ~= 0 and os.clock() - autoCollectWindowStartedAt >= AUTO_COLLECT_SAFE_WAIT then
		autoCollectCount = 0
		autoCollectWindowStartedAt = 0
	end
end

local function waitForAutoCollectSafety()
	while autoCollectEnabled do
		resetAutoCollectWindowIfReady()

		if autoCollectCount < AUTO_COLLECT_SAFE_LIMIT then
			setMovementPaused(false)
			return true
		end

		setMovementPaused(true)
		task.wait(1)
	end

	setMovementPaused(false)
	return false
end

local function waitForTeleportReady()
	while autoCollectEnabled do
		if Teleport.LockedUntil and os.clock() < Teleport.LockedUntil then
			task.wait(0.25)
		elseif Teleport.LastClickAt and os.clock() - Teleport.LastClickAt < Teleport.Debounce then
			task.wait(0.05)
		else
			return true
		end
	end

	return false
end

local function recordAutoCollectTeleport()
	if autoCollectCount == 0 then
		autoCollectWindowStartedAt = os.clock()
	end

	autoCollectCount += 1
end

local function stopAutoCollect(message)
	autoCollectEnabled = false
	setMovementPaused(false)

	if autoCollectToggle then
		autoCollectToggle.Set(false, false)
	end

	if message then
		createNotification("Auto Collect", message)
	end
end

local function runAutoCollect()
	setMovementPaused(true)

	while autoCollectEnabled do
		if not waitForAutoCollectSafety() then
			break
		end

		setMovementPaused(true)

		local itemName, itemCFrame, itemPosition, itemObject, itemPart = findNextCollectTarget()

		if not itemName then
			stopAutoCollect("Every item has been collected.")
			break
		end

		if not waitForTeleportReady() or not canTeleport() then
			task.wait(0.25)
			continue
		end

		if not isSameItemStillThere(itemObject, itemPart, itemName) then
			markVisitedCollectPosition(itemPosition)
			task.wait(0.1)
			continue
		end

		local character = player.Character or player.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart", 5)

		if root then
			markVisitedCollectPosition(itemPosition)
			teleportRootSafely(root, itemPart.CFrame + Vector3.new(0, 4, 0))
			addTeleportStrike()
			startFBlockAfterTeleport()
			recordAutoCollectTeleport()
			createNotification("Auto Collect", "Collected " .. itemName)

			task.delay(AUTO_COLLECT_F_DELAY, function()
				if autoCollectEnabled and isSameItemStillThere(itemObject, itemPart, itemName) then
					pressF()
				end
			end)
		end

		task.wait(AUTO_COLLECT_TELEPORT_DELAY)
	end

	setMovementPaused(false)
end

local ItemChecklist = {
	Visible = false,
	Rows = {},
	Thread = nil
}

ItemChecklist.Frame = Instance.new("Frame")
ItemChecklist.Frame.Name = "ItemChecklist"
ItemChecklist.Frame.Size = UDim2.fromOffset(260, 430)
ItemChecklist.Frame.Position = UDim2.new(1, -280, 0.5, -215)
ItemChecklist.Frame.BorderSizePixel = 0
ItemChecklist.Frame.Visible = false
ItemChecklist.Frame.Parent = gui
themeObject(ItemChecklist.Frame, "BackgroundColor3", "Panel")
addCorner(ItemChecklist.Frame, 10)
addStroke(ItemChecklist.Frame, currentTheme.Stroke, 1)

ItemChecklist.Title = Instance.new("TextLabel")
ItemChecklist.Title.Size = UDim2.new(1, -20, 0, 34)
ItemChecklist.Title.Position = UDim2.fromOffset(10, 8)
ItemChecklist.Title.BackgroundTransparency = 1
ItemChecklist.Title.Text = "Items 0/0"
ItemChecklist.Title.Font = Enum.Font.GothamBlack
ItemChecklist.Title.TextSize = 16
ItemChecklist.Title.TextXAlignment = Enum.TextXAlignment.Left
ItemChecklist.Title.Parent = ItemChecklist.Frame
themeObject(ItemChecklist.Title, "TextColor3", "Text")

ItemChecklist.List = Instance.new("ScrollingFrame")
ItemChecklist.List.Size = UDim2.new(1, -20, 1, -54)
ItemChecklist.List.Position = UDim2.fromOffset(10, 44)
ItemChecklist.List.BackgroundTransparency = 1
ItemChecklist.List.BorderSizePixel = 0
ItemChecklist.List.ScrollBarThickness = 4
ItemChecklist.List.CanvasSize = UDim2.fromOffset(0, 0)
ItemChecklist.List.Parent = ItemChecklist.Frame

ItemChecklist.Layout = Instance.new("UIListLayout")
ItemChecklist.Layout.Padding = UDim.new(0, 6)
ItemChecklist.Layout.SortOrder = Enum.SortOrder.LayoutOrder
ItemChecklist.Layout.Parent = ItemChecklist.List

function ItemChecklist.GetItemCounts(itemName)
	local totalCount = 0
	local leftCount = 0

	for _, object in ipairs(getCollectibleSearchPool()) do
		if itemNameMatches(object, itemName) then
			totalCount += 1

			if getLiveItemPart(object) then
				leftCount += 1
			end
		end
	end

	return leftCount, totalCount
end

function ItemChecklist.Build()
	for _, row in pairs(ItemChecklist.Rows) do
		row:Destroy()
	end

	ItemChecklist.Rows = {}

	for index, itemName in ipairs(itemNames) do
		local row = Instance.new("TextLabel")
		row.Size = UDim2.new(1, -4, 0, 24)
		row.BackgroundTransparency = 1
		row.Font = Enum.Font.GothamBold
		row.TextSize = 12
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.LayoutOrder = index
		row.Parent = ItemChecklist.List
		themeObject(row, "TextColor3", "Text")

		ItemChecklist.Rows[itemName] = row
	end

	ItemChecklist.List.CanvasSize = UDim2.fromOffset(0, ItemChecklist.Layout.AbsoluteContentSize.Y + 8)
end

function ItemChecklist.Refresh()
	local totalLeft = 0
	local totalItems = 0

	for _, itemName in ipairs(itemNames) do
		local row = ItemChecklist.Rows[itemName]
		local leftCount, totalCount = ItemChecklist.GetItemCounts(itemName)

		totalLeft += leftCount
		totalItems += totalCount

		if row then
			row.Text = "[" .. tostring(leftCount) .. "/" .. tostring(totalCount) .. "] " .. itemName
			row.TextTransparency = leftCount > 0 and 0 or 0.45
		end
	end

	ItemChecklist.Title.Text = "Items " .. tostring(totalLeft) .. "/" .. tostring(totalItems)
	ItemChecklist.List.CanvasSize = UDim2.fromOffset(0, ItemChecklist.Layout.AbsoluteContentSize.Y + 8)
end

function ItemChecklist.SetVisible(state)
	ItemChecklist.Visible = state
	ItemChecklist.Frame.Visible = state

	if state then
		ItemChecklist.Build()
		ItemChecklist.Refresh()

		if not ItemChecklist.Thread then
			ItemChecklist.Thread = task.spawn(function()
				while ItemChecklist.Visible do
					ItemChecklist.Refresh()
					task.wait(1)
				end

				ItemChecklist.Thread = nil
			end)
		end
	end
end

local checklistToggle = createToggleButton(itemsList, "Show checklist", false, function(state)
	ItemChecklist.SetVisible(state)
end)

checklistToggle.Button.LayoutOrder = 4

autoCollectToggle = createToggleButton(itemsList, "Auto Collect", false, function(state)
	autoCollectEnabled = state

	if autoCollectEnabled then
		autoCollectCount = 0
		autoCollectWindowStartedAt = 0
		visitedCollectPositions = {}

		createNotification("Auto Collect", "Auto Collect enabled.", "Success")

		if not autoCollectThread then
			autoCollectThread = task.spawn(function()
				runAutoCollect()
				autoCollectThread = nil
			end)
		end
	else
		setMovementPaused(false)
		createNotification("Auto Collect", "Auto Collect disabled.")
	end
end)
autoCollectToggle.Button.LayoutOrder = 1
local autoUseDropdown = itemsList

local autoUseEnabled = false
local autoUseThread = nil
local autoHealEnabled = false
local autoHealThread = nil
local autoHealConnection = nil

local autoUseItems = {
	"Speed Potion",
	"Potion of Strength",
	"Bull's Essence",
	"Boba",
	"Frog Potion"
}

local healingItems = {
	"Healing Potion",
	"Bandage",
	"First Aid Kit",
	"Apple"
}

local function matchesItem(toolName, itemList)
	local normalized = normalizeName(toolName)

	for _, itemName in ipairs(itemList) do
		if normalized == normalizeName(itemName) then
			return true
		end
	end

	return false
end

local function useTool(tool)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or not tool or not tool:IsA("Tool") then
		return false
	end

	if tool.Parent == player.Backpack then
		humanoid:EquipTool(tool)
		task.wait()
	end

	if tool.Parent == character then
		pcall(function()
			tool:Activate()
		end)

		return true
	end

	return false
end

local function findMatchingTool(itemList)
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")

	if character then
		for _, tool in ipairs(character:GetChildren()) do
			if tool:IsA("Tool") and matchesItem(tool.Name, itemList) then
				return tool
			end
		end
	end

	if backpack then
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") and matchesItem(tool.Name, itemList) then
				return tool
			end
		end
	end

	return nil
end

local function tryAutoHeal()
	if not autoHealEnabled then
		return
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid and humanoid.Health > 0 and humanoid.Health <= 30 then
		local tool = findMatchingTool(healingItems)

		if tool then
			useTool(tool)
		end
	end
end

local function hookAutoHealCharacter()
	if autoHealConnection then
		autoHealConnection:Disconnect()
		autoHealConnection = nil
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		autoHealConnection = humanoid.HealthChanged:Connect(function()
			tryAutoHeal()
		end)
	end
end

local function runAutoUse()
	while autoUseEnabled do
		local tool = findMatchingTool(autoUseItems)

		if tool then
			useTool(tool)
			task.wait(0.02)
		else
			task.wait(0.04)
		end
	end
end

local function runAutoHeal()
	while autoHealEnabled do
		tryAutoHeal()
		task.wait(0.02)
	end
end

for index, itemName in ipairs(itemNames) do
	local itemButton = createSmallButton(itemsDropdown, itemName, function()
		teleportToItem(itemName)
	end)

	itemButton.LayoutOrder = 10 + index
end

local autoUseToggle = createToggleButton(autoUseDropdown, "Auto Use", false, function(state)
	autoUseEnabled = state

	if autoUseEnabled then
		createNotification("Auto Use", "Auto Use enabled.")

		if not autoUseThread then
			autoUseThread = task.spawn(function()
				runAutoUse()
				autoUseThread = nil
			end)
		end
	else
		createNotification("Auto Use", "Auto Use disabled.")
	end
end)

autoUseToggle.Button.LayoutOrder = 2

local autoHealToggle = createToggleButton(autoUseDropdown, "Auto Heal", false, function(state)
	autoHealEnabled = state

	if autoHealEnabled then
		createNotification("Auto Heal", "Auto Heal enabled.")
		hookAutoHealCharacter()
		tryAutoHeal()

		if not autoHealThread then
			autoHealThread = task.spawn(function()
				runAutoHeal()
				autoHealThread = nil
			end)
		end
	else
		if autoHealConnection then
			autoHealConnection:Disconnect()
			autoHealConnection = nil
		end

		createNotification("Auto Heal", "Auto Heal disabled.")
	end
end)

autoHealToggle.Button.LayoutOrder = 3

player.CharacterAdded:Connect(function()
	task.wait(0.25)

	if autoHealEnabled then
		hookAutoHealCharacter()
	end
end)

local Combat = {
	HitboxSize = 10,
	HitboxMinSize = 10,
	HitboxMaxSize = 25,
	HitboxTransparency = 0.7,
	HitboxColor = Color3.fromRGB(0, 170, 255),
	HitboxExpanded = false,
	HitboxVisible = true,
	SavedHitboxes = {},
	HitboxConnection = nil
}

local hitboxSize = Combat.HitboxSize
local hitboxExpanded = Combat.HitboxExpanded
local hitboxVisible = Combat.HitboxVisible
local savedHitboxes = Combat.SavedHitboxes

function Combat.GetEnemyRoot(otherPlayer)
	if otherPlayer == Players.LocalPlayer then
		return nil
	end

	local character = otherPlayer.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

function Combat.SaveOriginalHitbox(otherPlayer, root)
	if Combat.SavedHitboxes[otherPlayer] then
		return
	end

	Combat.SavedHitboxes[otherPlayer] = {
		Size = root.Size,
		Transparency = root.Transparency,
		Color = root.Color,
		Material = root.Material,
		CanCollide = root.CanCollide
	}
end

function Combat.ApplyHitbox(otherPlayer)
	local root = Combat.GetEnemyRoot(otherPlayer)
	if not root then
		return
	end

	Combat.SaveOriginalHitbox(otherPlayer, root)

	root.Size = Vector3.new(Combat.HitboxSize, Combat.HitboxSize, Combat.HitboxSize)
	root.Transparency = Combat.HitboxVisible and Combat.HitboxTransparency or 1
	root.Color = Combat.HitboxColor
	root.Material = Enum.Material.Neon
	root.CanCollide = false
end

function Combat.ResetHitbox(otherPlayer)
	local root = Combat.GetEnemyRoot(otherPlayer)
	local saved = Combat.SavedHitboxes[otherPlayer]

	if root and saved then
		root.Size = saved.Size
		root.Transparency = saved.Transparency
		root.Color = saved.Color
		root.Material = saved.Material
		root.CanCollide = saved.CanCollide
	end

	Combat.SavedHitboxes[otherPlayer] = nil
end

function Combat.StartHitboxLoop()
	if Combat.HitboxConnection then
		return
	end

	Combat.HitboxConnection = RunService.RenderStepped:Connect(function()
		if not Combat.HitboxExpanded then
			return
		end

		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			Combat.ApplyHitbox(otherPlayer)
		end
	end)
end

function Combat.StopHitboxLoop()
	if Combat.HitboxConnection then
		Combat.HitboxConnection:Disconnect()
		Combat.HitboxConnection = nil
	end

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		Combat.ResetHitbox(otherPlayer)
	end
end

function Combat.RefreshHitboxes()
	hitboxSize = Combat.HitboxSize
	hitboxExpanded = Combat.HitboxExpanded
	hitboxVisible = Combat.HitboxVisible
	savedHitboxes = Combat.SavedHitboxes

	if Combat.HitboxExpanded then
		Combat.StartHitboxLoop()

		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			Combat.ApplyHitbox(otherPlayer)
		end
	else
		Combat.StopHitboxLoop()
	end
end

function Combat.GetPlayerRoot(targetPlayer)
	if not targetPlayer or targetPlayer == player then
		return nil
	end

	local character = targetPlayer.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

function Combat.GetPlayerHumanoid(targetPlayer)
	local character = targetPlayer.Character
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

function Combat.TeleportToPlayer(targetPlayer)
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)
	local targetRoot = Combat.GetPlayerRoot(targetPlayer)

	if not root then
		createNotification("Players", "Could not find your character.", "Error")
		return
	end

	if not targetRoot then
		createNotification("Players", "Could not find target player.", "Error")
		return
	end

	root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
	createNotification("Players", "Teleported to " .. targetPlayer.Name)
end

function Combat.TeleportToLowestHealthPlayer()
	local lowestPlayer = nil
	local lowestHealth = math.huge

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			local humanoid = Combat.GetPlayerHumanoid(targetPlayer)
			local targetRoot = Combat.GetPlayerRoot(targetPlayer)

			if humanoid and targetRoot and humanoid.Health > 0 and humanoid.Health < lowestHealth then
				lowestHealth = humanoid.Health
				lowestPlayer = targetPlayer
			end
		end
	end

	if lowestPlayer then
		Combat.TeleportToPlayer(lowestPlayer)
	else
		createNotification("Players", "No valid lowest health player found.")
	end
end

function Combat.TeleportToNearestPlayer()
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)

	if not root then
		createNotification("Players", "Could not find your character.", "Error")
		return
	end

	local nearestPlayer = nil
	local nearestDistance = math.huge

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			local humanoid = Combat.GetPlayerHumanoid(targetPlayer)
			local targetRoot = Combat.GetPlayerRoot(targetPlayer)

			if humanoid and targetRoot and humanoid.Health > 0 then
				local distance = (root.Position - targetRoot.Position).Magnitude

				if distance < nearestDistance then
					nearestDistance = distance
					nearestPlayer = targetPlayer
				end
			end
		end
	end

	if nearestPlayer then
		Combat.TeleportToPlayer(nearestPlayer)
	else
		createNotification("Players", "No valid nearest player found.")
	end
end

function Combat.SetHitboxSize(newSize)
	Combat.HitboxSize = math.clamp(newSize, Combat.HitboxMinSize, Combat.HitboxMaxSize)
	hitboxSize = Combat.HitboxSize

	if Combat.HitboxSizeLabel then
		Combat.HitboxSizeLabel.Text = "Hitbox Size: " .. tostring(math.floor(Combat.HitboxSize + 0.5))
	end

	if Combat.HitboxExpanded then
		Combat.RefreshHitboxes()
	end
end

function Combat.SetupPlayerHitboxRefresh(otherPlayer)
	otherPlayer.CharacterAdded:Connect(function()
		task.wait(1)

		if Combat.HitboxExpanded then
			Combat.ApplyHitbox(otherPlayer)
		end
	end)
end

local getEnemyRoot = Combat.GetEnemyRoot
local applyHitboxToPlayer = Combat.ApplyHitbox
local resetHitboxForPlayer = Combat.ResetHitbox
local refreshHitboxes = Combat.RefreshHitboxes
local setupPlayerHitboxRefresh = Combat.SetupPlayerHitboxRefresh

local playersDropdown = createDropdown(combatList, "Players", updateCombatCanvas)

createSmallButton(playersDropdown, "Teleport To Lowest Health", function()
	Combat.TeleportToLowestHealthPlayer()
end)

createSmallButton(playersDropdown, "Teleport To Nearest", function()
	Combat.TeleportToNearestPlayer()
end)

local hitboxMenu = createDropdown(combatList, "Hitbox Menu", updateCombatCanvas)

Combat.HitboxSizeLabel = Instance.new("TextLabel")
Combat.HitboxSizeLabel.Size = UDim2.new(1, -12, 0, 30)
Combat.HitboxSizeLabel.BackgroundTransparency = 1
Combat.HitboxSizeLabel.Font = Enum.Font.GothamBold
Combat.HitboxSizeLabel.TextSize = 13
Combat.HitboxSizeLabel.TextXAlignment = Enum.TextXAlignment.Center
Combat.HitboxSizeLabel.Parent = hitboxMenu
themeObject(Combat.HitboxSizeLabel, "TextColor3", "Text")

createSmallButton(hitboxMenu, "+ Bigger Hitbox", function()
	Combat.SetHitboxSize(Combat.HitboxSize + 1)
end)

createSmallButton(hitboxMenu, "- Smaller Hitbox", function()
	Combat.SetHitboxSize(Combat.HitboxSize - 1)
end)

Combat.SetHitboxSize(Combat.HitboxSize)

createToggleButton(hitboxMenu, "Expand Hitbox", false, function(state)
	Combat.HitboxExpanded = state
	hitboxExpanded = state
	Combat.RefreshHitboxes()
end)

createToggleButton(hitboxMenu, "Visualise Hitboxes", true, function(state)
	Combat.HitboxVisible = state
	hitboxVisible = state

	if Combat.HitboxExpanded then
		Combat.RefreshHitboxes()
	end
end)

local ESP = {
	Enabled = false,
	Connections = {}
}

ESP.Folder = Instance.new("Folder")
ESP.Folder.Name = "PlayerStatsESP"
ESP.Folder.Parent = gui

function ESP.GetStatValue(targetPlayer, statNames)
	local leaderstats = targetPlayer:FindFirstChild("leaderstats")

	if leaderstats then
		for _, statName in ipairs(statNames) do
			local stat = leaderstats:FindFirstChild(statName)

			if stat and stat:IsA("ValueBase") then
				return stat.Value
			end
		end
	end

	for _, statName in ipairs(statNames) do
		local attribute = targetPlayer:GetAttribute(statName)

		if attribute ~= nil then
			return attribute
		end
	end

	local character = targetPlayer.Character

	if character then
		for _, statName in ipairs(statNames) do
			local attribute = character:GetAttribute(statName)

			if attribute ~= nil then
				return attribute
			end
		end

		for _, object in ipairs(character:GetDescendants()) do
			for _, statName in ipairs(statNames) do
				if normalizeName(object.Name) == normalizeName(statName) and object:IsA("ValueBase") then
					return object.Value
				end
			end
		end
	end

	for _, object in ipairs(targetPlayer:GetDescendants()) do
		for _, statName in ipairs(statNames) do
			if normalizeName(object.Name) == normalizeName(statName) and object:IsA("ValueBase") then
				return object.Value
			end
		end
	end

	return "?"
end

function ESP.GetSpeed(targetPlayer)
	local statSpeed = ESP.GetStatValue(targetPlayer, { "Speed", "WalkSpeed" })

	if statSpeed ~= "?" then
		return statSpeed
	end

	local character = targetPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		return math.floor(humanoid.WalkSpeed)
	end

	return "?"
end

function ESP.Remove(targetPlayer)
	local existingBillboard = ESP.Folder:FindFirstChild(targetPlayer.Name .. "_StatsESP")

	if existingBillboard then
		existingBillboard:Destroy()
	end

	local character = targetPlayer.Character
	local existingHighlight = character and character:FindFirstChild("OPSlapPlayerStatsHighlight")

	if existingHighlight then
		existingHighlight:Destroy()
	end
end

function ESP.Create(targetPlayer)
	if targetPlayer == player then
		return
	end

	ESP.Remove(targetPlayer)

	local character = targetPlayer.Character
	local head = character and character:FindFirstChild("Head")

	if not character or not head then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "OPSlapPlayerStatsHighlight"
	highlight.FillColor = Color3.fromRGB(0, 170, 255)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.75
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = character

	local billboard = Instance.new("BillboardGui")
	billboard.Name = targetPlayer.Name .. "_StatsESP"
	billboard.Size = UDim2.fromOffset(360, 170)
	billboard.StudsOffset = Vector3.new(0, 5.2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 10000
	billboard.Adornee = head
	billboard.Parent = ESP.Folder

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.15
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = 28
	label.TextWrapped = true
	label.RichText = true
	label.Parent = billboard

	task.spawn(function()
		while ESP.Enabled and billboard.Parent do
			local liveCharacter = targetPlayer.Character
			local humanoid = liveCharacter and liveCharacter:FindFirstChildOfClass("Humanoid")

			local health = "?"
			if humanoid then
				health = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
			end

			local kills = ESP.GetStatValue(targetPlayer, { "Kills", "Kill", "KOs" })
			local power = ESP.GetStatValue(targetPlayer, { "Power", "Strength", "Slaps" })
			local speed = ESP.GetSpeed(targetPlayer)

			label.Text =
				'<font color="rgb(255,255,255)">' .. targetPlayer.Name .. '</font>'
				.. '\n<font color="rgb(80,255,120)">Health: ' .. tostring(health) .. '</font>'
				.. '\n<font color="rgb(80,170,255)">Kills: ' .. tostring(kills) .. '</font>'
				.. '\n<font color="rgb(255,80,80)">Strength: ' .. tostring(power) .. '</font>'
				.. '\n<font color="rgb(255,235,70)">Speed: ' .. tostring(speed) .. '</font>'

			task.wait(0.25)
		end
	end)
end

function ESP.Refresh()
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if ESP.Enabled then
			ESP.Create(targetPlayer)
		else
			ESP.Remove(targetPlayer)
		end
	end
end

function ESP.ClearConnections()
	for _, connection in ipairs(ESP.Connections) do
		connection:Disconnect()
	end

	ESP.Connections = {}
end

function ESP.Enable()
	ESP.Enabled = true
	ESP.Refresh()

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		table.insert(ESP.Connections, targetPlayer.CharacterAdded:Connect(function()
			task.wait(0.5)

			if ESP.Enabled then
				ESP.Create(targetPlayer)
			end
		end))
	end

	table.insert(ESP.Connections, Players.PlayerAdded:Connect(function(targetPlayer)
		table.insert(ESP.Connections, targetPlayer.CharacterAdded:Connect(function()
			task.wait(0.5)

			if ESP.Enabled then
				ESP.Create(targetPlayer)
			end
		end))
	end))

	table.insert(ESP.Connections, Players.PlayerRemoving:Connect(function(targetPlayer)
		ESP.Remove(targetPlayer)
	end))
end

function ESP.Disable()
	ESP.Enabled = false
	ESP.ClearConnections()

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		ESP.Remove(targetPlayer)
	end

	for _, item in ipairs(ESP.Folder:GetChildren()) do
		item:Destroy()
	end
end

createToggleButton(miscList, "Player Stats ESP", false, function(state)
	if state then
		ESP.Enable()
		createNotification("ESP", "Player Stats ESP enabled.", "Success")
	else
		ESP.Disable()
		createNotification("ESP", "Player Stats ESP disabled.")
	end
end)

local Anti = {
	Folder = nil
}

function Anti.ClearParts()
	if Anti.Folder and Anti.Folder.Parent then
		Anti.Folder:Destroy()
	end

	Anti.Folder = nil
end

function Anti.CreatePart(position, size)
	if not Anti.Folder then
		return
	end

	local platform = Instance.new("Part")
	platform.Name = "Part"
	platform.Size = size
	platform.Position = position
	platform.Anchored = true
	platform.CanCollide = true
	platform.Transparency = 1
	platform.Color = Color3.fromRGB(0, 170, 255)
	platform.Material = Enum.Material.SmoothPlastic
	platform.Parent = Anti.Folder

	return platform
end

function Anti.EnableAcidLava()
	Anti.ClearParts()

	Anti.Folder = Instance.new("Folder")
	Anti.Folder.Name = "AntiAcidLavaParts"
	Anti.Folder.Parent = workspace

	Anti.CreatePart(
		Vector3.new(-74.52057647705078, 13, -727.3116455078125),
		Vector3.new(150, 2, 150)
	)

	Anti.CreatePart(
		Vector3.new(-255.963623046875, -33.78499221801758, 407.39410400390625),
		Vector3.new(300, 5, 300)
	)

	Anti.CreatePart(
		Vector3.new(-591.77001953125, -47.32532501220703, -205.88002014160156),
		Vector3.new(300, 5, 300)
	)
end

local antiDropdown = createDropdown(miscList, "Anti", updateMiscCanvas)

createToggleButton(antiDropdown, "Anti Acid & Lava", false, function(state)
	if state then
		Anti.EnableAcidLava()
		createNotification("Anti", "Anti Acid & Lava enabled.", "Success")
	else
		Anti.ClearParts()
		createNotification("Anti", "Anti Acid & Lava disabled.")
	end
end)

local themeList = Instance.new("ScrollingFrame")
themeList.Size = UDim2.new(1, -36, 1, -124)
themeList.Position = UDim2.fromOffset(18, 68)
themeList.BackgroundTransparency = 1
themeList.BorderSizePixel = 0
themeList.ScrollBarThickness = 4
themeList.CanvasSize = UDim2.fromOffset(0, 0)
themeList.Parent = themePage

local themeLayout = Instance.new("UIListLayout")
themeLayout.Padding = UDim.new(0, 10)
themeLayout.SortOrder = Enum.SortOrder.LayoutOrder
themeLayout.Parent = themeList

for themeName in pairs(themes) do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -6, 0, 40)
	button.Text = themeName
	button.Font = Enum.Font.GothamBold
	button.TextSize = 14
	button.Parent = themeList
	themeObject(button, "BackgroundColor3", "ButtonDark")
	styleButton(button)

	button.MouseButton1Click:Connect(function()
		applyTheme(themeName)
	end)
end

themeList.CanvasSize = UDim2.fromOffset(0, themeLayout.AbsoluteContentSize.Y + 10)

Players.PlayerAdded:Connect(Combat.SetupPlayerHitboxRefresh)

for _, otherPlayer in ipairs(Players:GetPlayers()) do
	Combat.SetupPlayerHitboxRefresh(otherPlayer)
	Combat.ResetHitbox(otherPlayer)
end

Players.PlayerRemoving:Connect(function(otherPlayer)
	Combat.SavedHitboxes[otherPlayer] = nil
end)

local Window = {
	Dragging = false,
	Resizing = false,
	Minimized = false,
	DragStart = nil,
	ResizeStart = nil,
	StartPosition = nil,
	StartSize = nil,
	ResizeHandle = nil
}

function Window.StartDrag(inputObject)
	if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	Window.Dragging = true
	Window.DragStart = inputObject.Position
	Window.StartPosition = mainFrame.Position
end

function Window.StopDrag(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		Window.Dragging = false
	end
end

function Window.StartResize(inputObject)
	if inputObject.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	Window.Resizing = true
	Window.ResizeStart = inputObject.Position
	Window.StartSize = mainFrame.Size
end

function Window.StopResize(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		Window.Resizing = false
	end
end

function Window.HandleInputChanged(inputObject)
	if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	if Window.Dragging and Window.DragStart and Window.StartPosition then
		local delta = inputObject.Position - Window.DragStart

		mainFrame.Position = UDim2.new(
			Window.StartPosition.X.Scale,
			Window.StartPosition.X.Offset + delta.X,
			Window.StartPosition.Y.Scale,
			Window.StartPosition.Y.Offset + delta.Y
		)
	end

	if Window.Resizing and Window.ResizeStart and Window.StartSize then
		local delta = inputObject.Position - Window.ResizeStart
		local newWidth = math.clamp(Window.StartSize.X.Offset + delta.X, 500, 900)
		local newHeight = math.clamp(Window.StartSize.Y.Offset + delta.Y, 320, 650)

		mainFrame.Size = UDim2.fromOffset(newWidth, newHeight)
	end
end

function Window.ToggleMinimized()
	Window.Minimized = not Window.Minimized

	if Window.Minimized then
		normalSize = mainFrame.Size
		minimizedSize = UDim2.fromOffset(math.max(normalSize.X.Offset, 500), 52)

		tabScroll.Visible = false
		contentFrame.Visible = false
		Window.ResizeHandle.Visible = false

		tweenWindow(minimizedSize, mainFrame.Position, 0.3)
	else
		tweenWindow(normalSize, mainFrame.Position, 0.35)

		task.delay(0.12, function()
			if not Window.Minimized then
				tabScroll.Visible = true
				contentFrame.Visible = true
				Window.ResizeHandle.Visible = true
			end
		end)
	end
end

Window.ResizeHandle = Instance.new("TextButton")
Window.ResizeHandle.Size = UDim2.fromOffset(30, 30)
Window.ResizeHandle.Position = UDim2.new(1, -38, 1, -38)
Window.ResizeHandle.Text = "+"
Window.ResizeHandle.Font = Enum.Font.GothamBlack
Window.ResizeHandle.TextSize = 17
Window.ResizeHandle.Parent = mainFrame
themeObject(Window.ResizeHandle, "BackgroundColor3", "Button")
styleButton(Window.ResizeHandle)

topBar.InputBegan:Connect(Window.StartDrag)
topBar.InputEnded:Connect(Window.StopDrag)

Window.ResizeHandle.InputBegan:Connect(Window.StartResize)
Window.ResizeHandle.InputEnded:Connect(Window.StopResize)

UserInputService.InputChanged:Connect(Window.HandleInputChanged)

minimizeButton.MouseButton1Click:Connect(Window.ToggleMinimized)

closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

selectTab("Main")
applyTheme("Midnight Arcade")

tabScroll.CanvasSize = UDim2.fromOffset(0, tabLayout.AbsoluteContentSize.Y + 20)
updateItemsCanvas()
updateMainCanvas()
updateCombatCanvas()
updateMiscCanvas()
