local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local ContextActionService = game:GetService("ContextActionService")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui = Instance.new("ScreenGui")
gui.Name = "OPSlapRoyaleUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local themes = {
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

local currentTheme = themes["Midnight Arcade"]
local themedObjects = {}
local tabButtons = {}
local pages = {}
local selectedTabName = "Main"
local topLevelToggleOrder = 0

local function themeObject(object, property, key)
	table.insert(themedObjects, {
		Object = object,
		Property = property,
		Key = key
	})
	object[property] = currentTheme[key]
end

local function addCorner(object, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = object
end

local function addStroke(object, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(0, 0, 0)
	stroke.Thickness = thickness or 2
	stroke.Parent = object
	return stroke
end

local function styleButton(button)
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	addCorner(button, 8)

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = button

	local stroke = addStroke(button, Color3.fromRGB(0, 0, 0), 1)
	stroke.Transparency = 0.18

	local glow = Instance.new("UIStroke")
	glow.Thickness = 2
	glow.Transparency = 0.82
	glow.Parent = button
	themeObject(glow, "Color", "Stroke")

	themeObject(button, "TextColor3", "Text")

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

local function createPage(name)
	local page = Instance.new("Frame")
	page.Name = name .. "Page"
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = contentFrame
	pages[name] = page
	return page
end

local mainPage = createPage("Main")
local combatPage = createPage("Combat")
local miscPage = createPage("Misc")
local themePage = createPage("Theme")

local function applyTheme(themeName)
	currentTheme = themes[themeName]

	for _, item in ipairs(themedObjects) do
		if item.Object and item.Object.Parent then
			item.Object[item.Property] = currentTheme[item.Key]
		end
	end

	for name, button in pairs(tabButtons) do
		button.BackgroundColor3 = name == selectedTabName and currentTheme.Button or currentTheme.ButtonDark
	end
end

local function selectTab(tabName)
	selectedTabName = tabName

	for name, page in pairs(pages) do
		page.Visible = name == tabName
	end

	for name, button in pairs(tabButtons) do
		button.BackgroundColor3 = name == tabName and currentTheme.Button or currentTheme.ButtonDark
	end
end

local tabIcons = {
	Main = "◆",
	Combat = "⚔",
	Misc = "◇",
	Theme = "✦"
}

local function createTab(name)
	local button = Instance.new("TextButton")
	button.Name = name .. "Tab"
	button.Size = UDim2.new(1, -4, 0, 46)
	button.Text = (tabIcons[name] or "•") .. "  " .. name
	button.Font = Enum.Font.GothamBlack
	button.TextSize = 14
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Parent = tabScroll
	themeObject(button, "BackgroundColor3", "ButtonDark")
	styleButton(button)

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 16)
	padding.Parent = button

	tabButtons[name] = button

	button.MouseButton1Click:Connect(function()
		selectTab(name)
	end)
end

createTab("Main")
createTab("Combat")
createTab("Misc")
createTab("Theme")

local function createPageTitle(parent, text)
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

createPageTitle(mainPage, "Main")
createPageTitle(combatPage, "Combat")
createPageTitle(miscPage, "Misc")
createPageTitle(themePage, "Theme")

local function createPageList(parent)
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

local mainList, updateMainCanvas = createPageList(mainPage)
local combatList, updateCombatCanvas = createPageList(combatPage)
local miscList, updateMiscCanvas = createPageList(miscPage)

local function createSmallButton(parent, text, callback)
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

local function createWarningLabel(parent, text)
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

local function createToggleButton(parent, text, defaultState, callback)
	local state = defaultState == true

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -12, 0, 40)
	button.Text = ""
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = parent

	if not parent:GetAttribute("IsDropdownBody") then
		topLevelToggleOrder += 1
		button.LayoutOrder = -1000 + topLevelToggleOrder
	end

	themeObject(button, "BackgroundColor3", "ButtonDark")
	styleButton(button)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.fromOffset(12, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button
	themeObject(label, "TextColor3", "Text")

	local switch = Instance.new("Frame")
	switch.Size = UDim2.fromOffset(42, 22)
	switch.Position = UDim2.new(1, -52, 0.5, -11)
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

		button.BackgroundColor3 = state and currentTheme.Button or currentTheme.ButtonDark
		switch.BackgroundColor3 = state and currentTheme.Button or Color3.fromRGB(35, 35, 35)
		knob.Position = state and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)

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
		Set = setState,
		Get = function()
			return state
		end
	}
end

local function createDropdown(list, titleText, updateCanvas)
	local DROPDOWN_TOP_PADDING = 3

    local wrapper = Instance.new("Frame")
    wrapper.Size = UDim2.new(1, -6, 0, 44 + DROPDOWN_TOP_PADDING)
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.ClipsDescendants = false
    wrapper.Parent = list

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -24, 0, 44)
    holder.Position = UDim2.new(0.5, 0, 0, DROPDOWN_TOP_PADDING)
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
	arrow.Text = "▼"
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 16
	arrow.Parent = holder
	themeObject(arrow, "TextColor3", "Text")

	local dropdownScale = Instance.new("UIScale")
	dropdownScale.Scale = 1
	dropdownScale.Parent = holder

	local function tweenDropdownScale(targetScale, duration)
		TweenService:Create(
			dropdownScale,
			TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Scale = targetScale }
		):Play()
	end

	header.MouseEnter:Connect(function()
		tweenDropdownScale(1.01, 0.16)
	end)

	header.MouseLeave:Connect(function()
		tweenDropdownScale(1, 0.18)
	end)

	header.MouseButton1Down:Connect(function()
		tweenDropdownScale(0.985, 0.08)
	end)

	header.MouseButton1Up:Connect(function()
		tweenDropdownScale(1.01, 0.18)
	end)

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
		wrapper.Size = UDim2.new(1, -6, 0, targetHeight + DROPDOWN_TOP_PADDING)

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

		TweenService:Create(
			arrow,
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Rotation = open and 180 or 0 }
		):Play()

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

local NOTIFICATION_WIDTH = 374
local NOTIFICATION_HEIGHT = 96
local NOTIFICATION_GAP = 10
local NOTIFICATION_BOTTOM_OFFSET = 104
local NOTIFICATION_RIGHT_OFFSET = 22
local NOTIFICATION_LIFETIME = 4.2
local NOTIFICATION_MAX_VISIBLE = 5

local notificationPresets = {
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

local notificationStack = Instance.new("Frame")
notificationStack.Name = "NotificationStack"
notificationStack.Size = UDim2.new(0, NOTIFICATION_WIDTH, 1, -NOTIFICATION_BOTTOM_OFFSET)
notificationStack.Position = UDim2.new(1, -(NOTIFICATION_WIDTH + NOTIFICATION_RIGHT_OFFSET), 0, 0)
notificationStack.BackgroundTransparency = 1
notificationStack.Parent = gui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.FillDirection = Enum.FillDirection.Vertical
notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.Padding = UDim.new(0, NOTIFICATION_GAP)
notificationLayout.Parent = notificationStack

local notificationOrder = 0
local activeNotifications = {}

local function getNotificationKind(titleText, kind)
	if kind and notificationPresets[kind] then
		return kind
	end

	local title = string.lower(tostring(titleText))

	if string.find(title, "error") or string.find(title, "failed") then
		return "Error"
	end

	if string.find(title, "warning") or string.find(title, "anti") or string.find(title, "wait") then
		return "Warning"
	end

	if string.find(title, "enabled") or string.find(title, "found") or string.find(title, "success") then
		return "Success"
	end

	return "Info"
end

local function removeOldestNotification()
	while #activeNotifications > NOTIFICATION_MAX_VISIBLE do
		local oldest = table.remove(activeNotifications, 1)

		if oldest and oldest.Parent then
			oldest:Destroy()
		end
	end
end

local function createNotification(titleText, messageText, kind)
	notificationOrder += 1

	local notificationKind = getNotificationKind(titleText, kind)
	local preset = notificationPresets[notificationKind]

	local slot = Instance.new("Frame")
	slot.Size = UDim2.fromOffset(NOTIFICATION_WIDTH, 0)
	slot.BackgroundTransparency = 1
	slot.LayoutOrder = notificationOrder
	slot.ClipsDescendants = true
	slot.Parent = notificationStack

	table.insert(activeNotifications, slot)
	removeOldestNotification()

	local popup = Instance.new("TextButton")
	popup.Size = UDim2.fromOffset(NOTIFICATION_WIDTH, NOTIFICATION_HEIGHT)
	popup.Position = UDim2.fromOffset(NOTIFICATION_WIDTH + 42, 0)
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

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -72, 0, 25)
	title.Position = UDim2.fromOffset(58, 12)
	title.BackgroundTransparency = 1
	title.Text = tostring(titleText)
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 15
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.Parent = popup
	themeObject(title, "TextColor3", "Text")

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

		local outPosition = UDim2.fromOffset(NOTIFICATION_WIDTH + 46, 0)

		TweenService:Create(
			scale,
			TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{ Scale = 0.94 }
		):Play()

		local outTween = TweenService:Create(
			popup,
			TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{
				Position = outPosition,
				BackgroundTransparency = 0.25
			}
		)

		TweenService:Create(
			slot,
			TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{ Size = UDim2.fromOffset(NOTIFICATION_WIDTH, 0) }
		):Play()

		outTween:Play()
		outTween.Completed:Connect(function()
			for index, item in ipairs(activeNotifications) do
				if item == slot then
					table.remove(activeNotifications, index)
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
		{ Size = UDim2.fromOffset(NOTIFICATION_WIDTH, NOTIFICATION_HEIGHT) }
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
		TweenInfo.new(NOTIFICATION_LIFETIME, Enum.EasingStyle.Linear),
		{ Size = UDim2.new(0, 0, 1, 0) }
	):Play()

	popup.MouseEnter:Connect(function()
		TweenService:Create(
			scale,
			TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Scale = 1.018 }
		):Play()

		TweenService:Create(
			glow,
			TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Transparency = 0.48 }
		):Play()
	end)

	popup.MouseLeave:Connect(function()
		TweenService:Create(
			scale,
			TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()

		TweenService:Create(
			glow,
			TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Transparency = 0.76 }
		):Play()
	end)

	popup.MouseButton1Click:Connect(dismiss)

	task.delay(NOTIFICATION_LIFETIME, function()
		if popup.Parent then
			dismiss()
		end
	end)
end

local function getPuzzleCode()
	local keywords = {
		"math", "equation", "problem", "code", "puzzle",
		"question", "solve", "answer", "number"
	}

	local found = {}
	local ids = {}

	local function isRelevant(obj)
		local full = string.lower(obj:GetFullName())
		local name = string.lower(obj.Name)

		for _, word in ipairs(keywords) do
			if string.find(full, word) or string.find(name, word) then
				return true
			end
		end

		return false
	end

	local function extractId(text)
		return tonumber(string.match(text, "%d+"))
	end

	for _, obj in ipairs(game:GetDescendants()) do
		local image = nil

		if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
			image = obj.Image
		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			image = obj.Texture
		end

		if image and image ~= "" and isRelevant(obj) then
			local id = extractId(image)

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

local function normalizeName(text)
	return string.lower(tostring(text):gsub("’", "'"))
end

local function getObjectCFrame(object)
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
	if part then
		return part.CFrame
	end

	return nil
end

local MAX_TELEPORT_STRIKES = 5
local TELEPORT_COOLDOWN = 8
local TELEPORT_DEBOUNCE = 2.5
local POST_TELEPORT_F_LOCK = 1

local teleportStrikes = 0
local teleportLockedUntil = 0
local lastTeleportClickAt = 0
local blockFUntil = 0

local function teleportRootSafely(root, targetCFrame)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	local _, yRotation, _ = root.CFrame:ToOrientation()
	root.CFrame = CFrame.new(targetCFrame.Position) * CFrame.Angles(0, yRotation, 0)

	task.wait()

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function showTeleportWarning(secondsText)
	createNotification(
		"Cooldown",
		"Wait " .. secondsText .. " before teleporting again.",
		"Warning"
	)
end

local function startFBlockAfterTeleport()
	blockFUntil = os.clock() + POST_TELEPORT_F_LOCK
end

local function showFBlockedWarning()
	local secondsLeft = math.max(1, math.ceil(blockFUntil - os.clock()))

	createNotification(
		"Cooldown",
		"Wait " .. secondsLeft .. " seconds before pressing F again.",
		"Warning"
	)
end

ContextActionService:BindActionAtPriority(
	"BlockFAfterTeleport",
	function(_, inputState)
		if inputState == Enum.UserInputState.Begin and os.clock() < blockFUntil then
			showFBlockedWarning()
			return Enum.ContextActionResult.Sink
		end

		return Enum.ContextActionResult.Pass
	end,
	false,
	3000,
	Enum.KeyCode.F
)

local function getTeleportCooldownLeft()
	return math.max(0, math.ceil(teleportLockedUntil - os.clock()))
end

local function isTeleportLocked()
	return os.clock() < teleportLockedUntil
end

local function resetTeleportStrikesIfUnlocked()
	if not isTeleportLocked() and teleportLockedUntil > 0 then
		teleportStrikes = 0
		teleportLockedUntil = 0
	end
end

local function canTeleport()
	resetTeleportStrikesIfUnlocked()

	if isTeleportLocked() then
		local secondsLeft = getTeleportCooldownLeft()
		showTeleportWarning(secondsLeft .. " seconds")
		return false
	end

	local now = os.clock()
	local debounceLeft = TELEPORT_DEBOUNCE - (now - lastTeleportClickAt)

	if debounceLeft > 0 then
		showTeleportWarning(string.format("%.1f seconds", debounceLeft))
		return false
	end

	return true
end

local function recordSuccessfulTeleport()
	lastTeleportClickAt = os.clock()
	teleportStrikes += 1

	if teleportStrikes >= MAX_TELEPORT_STRIKES then
		teleportLockedUntil = os.clock() + TELEPORT_COOLDOWN
	end
end

local function addTeleportStrike()
	lastTeleportClickAt = os.clock()
	teleportStrikes += 1

	if teleportStrikes >= MAX_TELEPORT_STRIKES then
		teleportLockedUntil = os.clock() + TELEPORT_COOLDOWN
	end
end

local ITEM_SEARCH_ROOT_NAME = "Items"

local function getItemSearchRoot()
	return workspace:FindFirstChild(ITEM_SEARCH_ROOT_NAME)
end

local function getItemSearchDescendants()
	local root = getItemSearchRoot()

	if root then
		return root:GetDescendants()
	end

	return {}
end

local function teleportToItem(itemName)
	if not canTeleport() then
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")

	if not hrp then
		createNotification("Items", "Could not find your character.")
		return
	end

	local function findValidManualItem()
		for _, object in ipairs(getItemSearchDescendants()) do
			if normalizeName(object.Name) == normalizeName(itemName) then
				local itemCFrame = getObjectCFrame(object)

				if itemCFrame then
					local part = nil

					if object:IsA("BasePart") then
						part = object
					else
						part = object:FindFirstChildWhichIsA("BasePart", true)
					end

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

	local itemObject, itemPart = findValidManualItem()

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

	teleportRootSafely(hrp, itemPart.CFrame + Vector3.new(0, 4, 0))
	addTeleportStrike()
	startFBlockAfterTeleport()
	createNotification("Items", "Teleported to " .. itemName)
end

local function createMarkerPart(position)
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

local function teleportToLocation(locationName, position)
	if not canTeleport() then
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)

	if not root then
		createNotification("Teleport", "Could not find your character.")
		return
	end

	createMarkerPart(position)
	teleportRootSafely(root, CFrame.new(position + Vector3.new(0, 5, 0)))
	addTeleportStrike()
	startFBlockAfterTeleport()
	createNotification("Teleport", "Teleported to " .. locationName)
end

local getCodeToggle = nil

local getCodeButton = createSmallButton(mainList, "Get Code", function()
	createNotification("Code", "Searching...")

	task.spawn(function()
		local code = getPuzzleCode()
		createNotification("Code Found", code ~= "" and code or "No code found.")
	end)
end)

local itemsDropdown = createDropdown(mainList, "Items", updateMainCanvas)
local itemsWarning = createWarningLabel(itemsDropdown, "DONT SPAM")
itemsWarning.LayoutOrder = 0

local autoCollectEnabled = false
local autoCollectThread = nil
local autoCollectToggle = nil

local CollectionService = game:GetService("CollectionService")

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
	"Forcefield Crystal",
}

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
	if not object or not object.Parent then
		return nil
	end

	if not object:IsDescendantOf(workspace) then
		return nil
	end

	if isItemMarkedGone(object) then
		return nil
	end

	local part = nil

	if object:IsA("BasePart") then
		part = object
	else
		part = object:FindFirstChildWhichIsA("BasePart", true)
	end

	if not part or not part.Parent then
		return nil
	end

	if not part:IsDescendantOf(workspace) then
		return nil
	end

	if part.Transparency >= 0.95 then
		return nil
	end

	if part.Size.X <= 0 or part.Size.Y <= 0 or part.Size.Z <= 0 then
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
	else
		if movementSave then
			humanoid.WalkSpeed = movementSave.WalkSpeed
			humanoid.JumpPower = movementSave.JumpPower
			humanoid.JumpHeight = movementSave.JumpHeight
			humanoid.AutoRotate = movementSave.AutoRotate
			movementSave = nil
		end
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

			if part then
				local position = part.Position

				if not isVisitedCollectPosition(position) then
					return wantedName, part.CFrame, position, object, part
				end
			end
		end
	end

	return nil, nil, nil, nil, nil
end

local function hasAnyCollectTargetLeft()
	for _, wantedName in ipairs(autoCollectPriority) do
		local itemName = findLiveItemByName(wantedName)

		if itemName then
			return true
		end
	end

	return false
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
	if not itemObject or not itemPart then
		return false
	end

	if not itemObject.Parent or not itemPart.Parent then
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
	if autoCollectWindowStartedAt == 0 then
		return
	end

	if os.clock() - autoCollectWindowStartedAt >= AUTO_COLLECT_SAFE_WAIT then
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

		local secondsLeft = math.max(1, math.ceil(AUTO_COLLECT_SAFE_WAIT - (os.clock() - autoCollectWindowStartedAt)))

		createNotification(
			"Auto Collect",
			"Paused, starting back up in " .. secondsLeft .. " seconds"
		)

		task.wait(1)
	end

	setMovementPaused(false)
	return false
end

local function waitForTeleportReady()
	while autoCollectEnabled do
		local now = os.clock()

		if teleportLockedUntil and now < teleportLockedUntil then
			task.wait(0.25)
		elseif lastTeleportClickAt and now - lastTeleportClickAt < TELEPORT_DEBOUNCE then
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
		setMovementPaused(true)

		if not waitForAutoCollectSafety() then
			break
		end

		setMovementPaused(true)

		local itemName, itemCFrame, itemPosition, itemObject, itemPart = findNextCollectTarget()

		if not itemName or not itemCFrame or not itemPosition or not itemObject or not itemPart then
			stopAutoCollect("Every item has been collected.")
			break
		end

		if not isSameItemStillThere(itemObject, itemPart, itemName) then
			markVisitedCollectPosition(itemPosition)
			task.wait(0.1)
			continue
		end

		if not waitForTeleportReady() then
			break
		end

		if not canTeleport() then
			task.wait(0.25)
			continue
		end

		task.wait(0.08)

		if not isSameItemStillThere(itemObject, itemPart, itemName) then
			markVisitedCollectPosition(itemPosition)
			task.wait(0.1)
			continue
		end

		local character = player.Character or player.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart", 5)

		if root then
			setMovementPaused(true)
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

local teleportDropdown = createDropdown(mainList, "Teleport", updateMainCanvas)
createWarningLabel(teleportDropdown, "DONT SPAM")

local teleportLocations = {
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

for _, location in ipairs(teleportLocations) do
	createSmallButton(teleportDropdown, location.Name, function()
		teleportToLocation(location.Name, location.Position)
	end)
end



local function matchesItem(toolName, itemList)
	local normalized = normalizeName(toolName)

	for _, itemName in ipairs(itemList) do
		if normalized == normalizeName(itemName) then
			return true
		end
	end

	return false
end

autoCollectToggle = createToggleButton(itemsDropdown, "Auto Collect", false, function(state)
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
local autoUseDropdown = itemsDropdown

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

local hitboxSize = 10
local hitboxTransparency = 0.7
local hitboxColor = Color3.fromRGB(0, 170, 255)
local hitboxExpanded = false
local hitboxVisible = true
local savedHitboxes = {}
local hitboxConnection = nil

local function getEnemyRoot(otherPlayer)
	if otherPlayer == Players.LocalPlayer then
		return nil
	end

	local character = otherPlayer.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function saveOriginalHitbox(otherPlayer, hrp)
	if savedHitboxes[otherPlayer] then
		return
	end

	savedHitboxes[otherPlayer] = {
		Size = hrp.Size,
		Transparency = hrp.Transparency,
		Color = hrp.Color,
		Material = hrp.Material,
		CanCollide = hrp.CanCollide
	}
end

local function applyHitboxToPlayer(otherPlayer)
	local hrp = getEnemyRoot(otherPlayer)
	if not hrp then
		return
	end

	saveOriginalHitbox(otherPlayer, hrp)

	hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
	hrp.Transparency = hitboxVisible and hitboxTransparency or 1
	hrp.Color = hitboxColor
	hrp.Material = Enum.Material.Neon
	hrp.CanCollide = false
end

local function resetHitboxForPlayer(otherPlayer)
	local hrp = getEnemyRoot(otherPlayer)
	local saved = savedHitboxes[otherPlayer]

	if hrp and saved then
		hrp.Size = saved.Size
		hrp.Transparency = saved.Transparency
		hrp.Color = saved.Color
		hrp.Material = saved.Material
		hrp.CanCollide = saved.CanCollide
	end

	savedHitboxes[otherPlayer] = nil
end

local function startHitboxLoop()
	if hitboxConnection then
		return
	end

	hitboxConnection = RunService.RenderStepped:Connect(function()
		if not hitboxExpanded then
			return
		end

		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			applyHitboxToPlayer(otherPlayer)
		end
	end)
end

local function stopHitboxLoop()
	if hitboxConnection then
		hitboxConnection:Disconnect()
		hitboxConnection = nil
	end

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		resetHitboxForPlayer(otherPlayer)
	end
end

local function refreshHitboxes()
	if hitboxExpanded then
		startHitboxLoop()

		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			applyHitboxToPlayer(otherPlayer)
		end
	else
		stopHitboxLoop()
	end
end

local playersDropdown = createDropdown(combatList, "Players", updateCombatCanvas)

local function getPlayerRoot(targetPlayer)
	if not targetPlayer or targetPlayer == player then
		return nil
	end

	local character = targetPlayer.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function getPlayerHumanoid(targetPlayer)
	local character = targetPlayer.Character
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function teleportToPlayer(targetPlayer)
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)
	local targetRoot = getPlayerRoot(targetPlayer)

	if not root then
		createNotification("Players", "Could not find your character.")
		return
	end

	if not targetRoot then
		createNotification("Players", "Could not find target player.")
		return
	end

	root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
	createNotification("Players", "Teleported to " .. targetPlayer.Name)
end

local function teleportToLowestHealthPlayer()
	local lowestPlayer = nil
	local lowestHealth = math.huge

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			local humanoid = getPlayerHumanoid(targetPlayer)
			local targetRoot = getPlayerRoot(targetPlayer)

			if humanoid and targetRoot and humanoid.Health > 0 and humanoid.Health < lowestHealth then
				lowestHealth = humanoid.Health
				lowestPlayer = targetPlayer
			end
		end
	end

	if lowestPlayer then
		teleportToPlayer(lowestPlayer)
	else
		createNotification("Players", "No valid lowest health player found.")
	end
end

local function teleportToNearestPlayer()
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)

	if not root then
		createNotification("Players", "Could not find your character.")
		return
	end

	local nearestPlayer = nil
	local nearestDistance = math.huge

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			local humanoid = getPlayerHumanoid(targetPlayer)
			local targetRoot = getPlayerRoot(targetPlayer)

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
		teleportToPlayer(nearestPlayer)
	else
		createNotification("Players", "No valid nearest player found.")
	end
end

createSmallButton(playersDropdown, "Teleport To Lowest Health", function()
	teleportToLowestHealthPlayer()
end)

createSmallButton(playersDropdown, "Teleport To Nearest", function()
	teleportToNearestPlayer()
end)

local hitboxMenu = createDropdown(combatList, "Hitbox Menu", updateCombatCanvas)

local HITBOX_MIN_SIZE = 10
local HITBOX_MAX_SIZE = 25

hitboxSize = math.clamp(hitboxSize, HITBOX_MIN_SIZE, HITBOX_MAX_SIZE)

local hitboxSizeLabel = Instance.new("TextLabel")
hitboxSizeLabel.Size = UDim2.new(1, -12, 0, 30)
hitboxSizeLabel.BackgroundTransparency = 1
hitboxSizeLabel.Font = Enum.Font.GothamBold
hitboxSizeLabel.TextSize = 13
hitboxSizeLabel.TextXAlignment = Enum.TextXAlignment.Center
hitboxSizeLabel.Parent = hitboxMenu
themeObject(hitboxSizeLabel, "TextColor3", "Text")

local function updateHitboxSizeLabel()
	hitboxSizeLabel.Text = "Hitbox Size: " .. tostring(math.floor(hitboxSize + 0.5))

	if hitboxExpanded then
		refreshHitboxes()
	end
end

createSmallButton(hitboxMenu, "+ Bigger Hitbox", function()
	hitboxSize = math.clamp(hitboxSize + 1, HITBOX_MIN_SIZE, HITBOX_MAX_SIZE)
	updateHitboxSizeLabel()
end)

createSmallButton(hitboxMenu, "- Smaller Hitbox", function()
	hitboxSize = math.clamp(hitboxSize - 1, HITBOX_MIN_SIZE, HITBOX_MAX_SIZE)
	updateHitboxSizeLabel()
end)

updateHitboxSizeLabel()

createToggleButton(hitboxMenu, "Expand Hitbox", false, function(state)
	hitboxExpanded = state
	refreshHitboxes()
end)

createToggleButton(hitboxMenu, "Visualise Hitboxes", true, function(state)
	hitboxVisible = state

	if hitboxExpanded then
		refreshHitboxes()
	end
end)

local sortInventoryEnabled = false
local sortInventoryThread = nil

local function sortInventory()
	local backpack = player:FindFirstChild("Backpack")

	if not backpack then
		return
	end

	local tools = {}

	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") then
			table.insert(tools, item)
		end
	end

	table.sort(tools, function(a, b)
		return normalizeName(a.Name) < normalizeName(b.Name)
	end)

	local tempFolder = Instance.new("Folder")
	tempFolder.Name = "InventorySortTemp"
	tempFolder.Parent = player

	for _, tool in ipairs(tools) do
		tool.Parent = tempFolder
	end

	for _, tool in ipairs(tools) do
		tool.Parent = backpack
	end

	tempFolder:Destroy()
end

local function runSortInventory()
	while sortInventoryEnabled do
		sortInventory()
		task.wait(1)
	end
end

local sortInventoryThread = nil

local function isHealingItemName(toolName)
	return matchesItem(toolName, healingItems)
end

local function sortInventory()
	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not backpack then
		return
	end

	if humanoid then
		humanoid:UnequipTools()
		task.wait()
	end

	local tools = {}

	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") then
			table.insert(tools, item)
		end
	end

	if character then
		for _, item in ipairs(character:GetChildren()) do
			if item:IsA("Tool") then
				item.Parent = backpack
				table.insert(tools, item)
			end
		end
	end

	table.sort(tools, function(a, b)
		local aHealing = isHealingItemName(a.Name)
		local bHealing = isHealingItemName(b.Name)

		if aHealing ~= bHealing then
			return aHealing
		end

		return normalizeName(a.Name) < normalizeName(b.Name)
	end)

	local tempFolder = Instance.new("Folder")
	tempFolder.Name = "InventorySortTemp"
	tempFolder.Parent = player

	for _, tool in ipairs(tools) do
		tool.Parent = tempFolder
	end

	for _, tool in ipairs(tools) do
		tool.Parent = backpack
	end

	tempFolder:Destroy()
end

local function runSortInventory()
	while sortInventoryEnabled do
		sortInventory()
		task.wait(1)
	end
end

createToggleButton(miscList, "Auto Sort Inventory", false, function(state)
	sortInventoryEnabled = state

	if sortInventoryEnabled then
		sortInventory()
		createNotification("Inventory", "Auto Sort Inventory enabled.")

		if not sortInventoryThread then
			sortInventoryThread = task.spawn(function()
				runSortInventory()
				sortInventoryThread = nil
			end)
		end
	else
		createNotification("Inventory", "Auto Sort Inventory disabled.")
	end
end)

local playerStatsEspEnabled = false

local playerStatsEspFolder = Instance.new("Folder")
playerStatsEspFolder.Name = "PlayerStatsESP"
playerStatsEspFolder.Parent = gui

local playerStatsEspConnections = {}

local function getPlayerStatValue(targetPlayer, statNames)
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

local function getPlayerEspSpeed(targetPlayer)
	local statSpeed = getPlayerStatValue(targetPlayer, { "Speed", "WalkSpeed" })

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

local function removePlayerStatsEsp(targetPlayer)
	local existingBillboard = playerStatsEspFolder:FindFirstChild(targetPlayer.Name .. "_StatsESP")

	if existingBillboard then
		existingBillboard:Destroy()
	end

	local character = targetPlayer.Character

	if character then
		local existingHighlight = character:FindFirstChild("OPSlapPlayerStatsHighlight")

		if existingHighlight then
			existingHighlight:Destroy()
		end
	end
end

local function createPlayerStatsEsp(targetPlayer)
	if targetPlayer == player then
		return
	end

	removePlayerStatsEsp(targetPlayer)

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
	billboard.Parent = playerStatsEspFolder

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
	while playerStatsEspEnabled and billboard.Parent do
		local character = targetPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		local health = "?"
		if humanoid then
			health = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
		end

		local kills = getPlayerStatValue(targetPlayer, { "Kills", "Kill", "KOs" })
		local power = getPlayerStatValue(targetPlayer, { "Power", "Strength", "Slaps" })
		local speed = getPlayerEspSpeed(targetPlayer)

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

local function refreshPlayerStatsEsp()
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if playerStatsEspEnabled then
			createPlayerStatsEsp(targetPlayer)
		else
			removePlayerStatsEsp(targetPlayer)
		end
	end
end

local function clearPlayerStatsEspConnections()
	for _, connection in ipairs(playerStatsEspConnections) do
		connection:Disconnect()
	end

	playerStatsEspConnections = {}
end

local function enablePlayerStatsEsp()
	playerStatsEspEnabled = true
	refreshPlayerStatsEsp()

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		table.insert(playerStatsEspConnections, targetPlayer.CharacterAdded:Connect(function()
			task.wait(0.5)

			if playerStatsEspEnabled then
				createPlayerStatsEsp(targetPlayer)
			end
		end))
	end

	table.insert(playerStatsEspConnections, Players.PlayerAdded:Connect(function(targetPlayer)
		table.insert(playerStatsEspConnections, targetPlayer.CharacterAdded:Connect(function()
			task.wait(0.5)

			if playerStatsEspEnabled then
				createPlayerStatsEsp(targetPlayer)
			end
		end))
	end))

	table.insert(playerStatsEspConnections, Players.PlayerRemoving:Connect(function(targetPlayer)
		removePlayerStatsEsp(targetPlayer)
	end))
end

local function disablePlayerStatsEsp()
	playerStatsEspEnabled = false
	clearPlayerStatsEspConnections()

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		removePlayerStatsEsp(targetPlayer)
	end

	for _, item in ipairs(playerStatsEspFolder:GetChildren()) do
		item:Destroy()
	end
end

createToggleButton(miscList, "Player Stats ESP", false, function(state)
	if state then
		enablePlayerStatsEsp()
		createNotification("ESP", "Player Stats ESP enabled.")
	else
		disablePlayerStatsEsp()
		createNotification("ESP", "Player Stats ESP disabled.")
	end
end)

local antiDropdown = createDropdown(miscList, "Anti", updateMiscCanvas)
local antiFolder = nil

local function clearAntiParts()
	if antiFolder and antiFolder.Parent then
		antiFolder:Destroy()
	end

	antiFolder = nil
end

local function createAntiPart(position, size)
	local platform = Instance.new("Part")
	platform.Name = "Part"
	platform.Size = size
	platform.Position = position
	platform.Anchored = true
	platform.CanCollide = true
	platform.Transparency = 1
	platform.Color = Color3.fromRGB(0, 170, 255)
	platform.Material = Enum.Material.SmoothPlastic
	platform.Parent = antiFolder

	return platform
end

createToggleButton(antiDropdown, "Anti Acid & Lava", false, function(state)
	if state then
		clearAntiParts()

		antiFolder = Instance.new("Folder")
		antiFolder.Name = "AntiAcidLavaParts"
		antiFolder.Parent = workspace

		createAntiPart(
			Vector3.new(-74.52057647705078, 13, -727.3116455078125),
			Vector3.new(150, 2, 150)
		)

		createAntiPart(
			Vector3.new(-255.963623046875, -33.78499221801758, 407.39410400390625),
			Vector3.new(300, 5, 300)
		)

		createAntiPart(
			Vector3.new(-591.77001953125, -47.32532501220703, -205.88002014160156),
			Vector3.new(300, 5, 300)
		)

		createNotification("Anti", "Anti Acid & Lava enabled.")
	else
		clearAntiParts()
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

local function setupPlayerHitboxRefresh(otherPlayer)
	otherPlayer.CharacterAdded:Connect(function()
		task.wait(1)

		if hitboxExpanded then
			applyHitboxToPlayer(otherPlayer)
		end
	end)
end

Players.PlayerAdded:Connect(setupPlayerHitboxRefresh)

for _, otherPlayer in ipairs(Players:GetPlayers()) do
	setupPlayerHitboxRefresh(otherPlayer)
end

Players.PlayerRemoving:Connect(function(otherPlayer)
	savedHitboxes[otherPlayer] = nil
end)

for _, otherPlayer in ipairs(Players:GetPlayers()) do
	resetHitboxForPlayer(otherPlayer)
end

local dragging = false
local dragStart
local startPosition

topBar.InputBegan:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = inputObject.Position
		startPosition = mainFrame.Position
	end
end)

topBar.InputEnded:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.fromOffset(30, 30)
resizeHandle.Position = UDim2.new(1, -38, 1, -38)
resizeHandle.Text = "⛶"
resizeHandle.Font = Enum.Font.GothamBlack
resizeHandle.TextSize = 17
resizeHandle.Parent = mainFrame
themeObject(resizeHandle, "BackgroundColor3", "Button")
styleButton(resizeHandle)

local resizing = false
local resizeStart
local startSize

resizeHandle.InputBegan:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true
		resizeStart = inputObject.Position
		startSize = mainFrame.Size
	end
end)

resizeHandle.InputEnded:Connect(function(inputObject)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = false
	end
end)

UserInputService.InputChanged:Connect(function(inputObject)
	if inputObject.UserInputType ~= Enum.UserInputType.MouseMovement then
		return
	end

	if dragging then
		local delta = inputObject.Position - dragStart
		mainFrame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end

	if resizing then
		local delta = inputObject.Position - resizeStart
		local newWidth = math.clamp(startSize.X.Offset + delta.X, 500, 900)
		local newHeight = math.clamp(startSize.Y.Offset + delta.Y, 320, 650)

		mainFrame.Size = UDim2.fromOffset(newWidth, newHeight)
	end
end)

local minimized = false

minimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized

	if minimized then
		normalSize = mainFrame.Size
		minimizedSize = UDim2.fromOffset(math.max(normalSize.X.Offset, 500), 52)

		tabScroll.Visible = false
		contentFrame.Visible = false
		resizeHandle.Visible = false

		tweenWindow(minimizedSize, mainFrame.Position, 0.3)
	else
		tweenWindow(normalSize, mainFrame.Position, 0.35)

		task.delay(0.12, function()
			if not minimized then
				tabScroll.Visible = true
				contentFrame.Visible = true
				resizeHandle.Visible = true
			end
		end)
	end
end)

closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

selectTab("Main")
applyTheme("Midnight Arcade")

tabScroll.CanvasSize = UDim2.fromOffset(0, tabLayout.AbsoluteContentSize.Y + 20)
updateMainCanvas()
updateCombatCanvas()
updateMiscCanvas()