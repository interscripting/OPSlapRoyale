local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	TweenService = game:GetService("TweenService"),
	UserInputService = game:GetService("UserInputService"),
	MarketplaceService = game:GetService("MarketplaceService"),
	ContextActionService = game:GetService("ContextActionService"),
	CollectionService = game:GetService("CollectionService")
}

local Players = Services.Players
local RunService = Services.RunService
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local MarketplaceService = Services.MarketplaceService
local ContextActionService = Services.ContextActionService
local player = Players.LocalPlayer

local Config = {}

Config.Themes = {
	["Neon Orchid"] = {
		Main = Color3.fromRGB(13, 10, 24),
		Panel = Color3.fromRGB(21, 17, 36),
		Button = Color3.fromRGB(216, 96, 255),
		ButtonDark = Color3.fromRGB(35, 27, 56),
		Stroke = Color3.fromRGB(250, 150, 255),
		Text = Color3.fromRGB(253, 248, 255),
		SubText = Color3.fromRGB(204, 181, 222)
	},
	["Cyber Lime"] = {
		Main = Color3.fromRGB(8, 15, 13),
		Panel = Color3.fromRGB(13, 26, 23),
		Button = Color3.fromRGB(142, 255, 92),
		ButtonDark = Color3.fromRGB(23, 42, 35),
		Stroke = Color3.fromRGB(195, 255, 139),
		Text = Color3.fromRGB(244, 255, 242),
		SubText = Color3.fromRGB(176, 216, 174)
	},
	["Solar Flare"] = {
		Main = Color3.fromRGB(20, 12, 9),
		Panel = Color3.fromRGB(37, 22, 17),
		Button = Color3.fromRGB(255, 174, 64),
		ButtonDark = Color3.fromRGB(59, 35, 26),
		Stroke = Color3.fromRGB(255, 214, 112),
		Text = Color3.fromRGB(255, 248, 238),
		SubText = Color3.fromRGB(232, 190, 146)
	},
	["Ocean Sync"] = {
		Main = Color3.fromRGB(7, 16, 24),
		Panel = Color3.fromRGB(12, 30, 43),
		Button = Color3.fromRGB(58, 210, 255),
		ButtonDark = Color3.fromRGB(20, 48, 64),
		Stroke = Color3.fromRGB(132, 234, 255),
		Text = Color3.fromRGB(241, 252, 255),
		SubText = Color3.fromRGB(166, 208, 224)
	},
	["Rose Terminal"] = {
		Main = Color3.fromRGB(22, 9, 16),
		Panel = Color3.fromRGB(37, 16, 28),
		Button = Color3.fromRGB(255, 92, 156),
		ButtonDark = Color3.fromRGB(56, 27, 42),
		Stroke = Color3.fromRGB(255, 162, 204),
		Text = Color3.fromRGB(255, 246, 250),
		SubText = Color3.fromRGB(226, 174, 200)
	}
}

local themes = Config.Themes
local currentTheme = themes["Neon Orchid"]

local UI = {
	SideDropdowns = {},
	DropdownClosers = {},
	WindowTransparency = 0.45,
	ThemedObjects = {},
	TabButtons = {},
	Pages = {},
	SelectedTab = "Main",
	TopLevelToggleOrder = 0
}

local Notify = {
	Order = 0,
	Active = {},
	Width = 286,
	Height = 68,
	Gap = 6,
	BottomOffset = 58,
	RightOffset = 10,
	LifeTime = 4.2,
	MaxVisible = 4,
	Muted = false
}

Notify.Presets = {
	Info = {
		Icon = "💬",
		Color = Color3.fromRGB(95, 205, 255)
	},
	Success = {
		Icon = "✅",
		Color = Color3.fromRGB(95, 255, 165)
	},
	Warning = {
		Icon = "⚠️",
		Color = Color3.fromRGB(255, 205, 85)
	},
	Error = {
		Icon = "❌",
		Color = Color3.fromRGB(255, 90, 105)
	}
}

local gui = Instance.new("ScreenGui")
gui.Name = "OPSlapRoyaleUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
	button.BackgroundTransparency = 0.12
	UI.AddCorner(button, 6)

	local scale = Instance.new("UIScale")
	scale.Scale = 1
	scale.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Thickness = 1
	stroke.Transparency = 0.76
	stroke.Parent = button
	UI.ThemeObject(stroke, "Color", "Stroke")

	UI.ThemeObject(button, "TextColor3", "Text")

	local hovering = false

	local function tween(object, duration, props)
		TweenService:Create(
			object,
			TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			props
		):Play()
	end

	button.MouseEnter:Connect(function()
		hovering = true
		tween(scale, 0.14, { Scale = 1.006 })
		tween(stroke, 0.14, { Transparency = 0.42 })
		tween(button, 0.14, { BackgroundTransparency = 0.04 })
	end)

	button.MouseLeave:Connect(function()
		hovering = false
		tween(scale, 0.16, { Scale = 1 })
		tween(stroke, 0.16, { Transparency = 0.76 })
		tween(button, 0.16, { BackgroundTransparency = 0.12 })
	end)

	button.MouseButton1Down:Connect(function()
		tween(scale, 0.08, { Scale = 0.985 })
	end)

	button.MouseButton1Up:Connect(function()
		tween(scale, 0.14, { Scale = hovering and 1.006 or 1 })
	end)
end

UI.Icons = {
	Main = "🏠",
	Items = "🎒",
	Teleports = "🧭",
	Combat = "⚔️",
	Visuals = "👁️",
	Safety = "🛡️",
	Settings = "⚙️",
	["Get Code + Go Barn"] = "🔢",
	["Quick Teleports"] = "⚡",
	["Mobile Quick Menus"] = "📱",
	["Map Locations"] = "🗺️",
	["Item Teleports"] = "🎁",
	["Player Teleports"] = "👤",
	["Auto Items"] = "🤖",
	["Auto Collect"] = "🧲",
	["Auto Heal"] = "❤️",
	["Auto Sort"] = "🎒",
	["Meteor Crate"] = "📦",
	["Hitbox Controls"] = "🎯",
	["Expand Hitbox"] = "📦",
	["Visualise Hitboxes"] = "✨",
	["Auto Glove Tap"] = "👊",
	["Player Stats ESP"] = "📊",
	["World Safety"] = "🚧",
	["Anti Acid & Lava"] = "🔥",
	["Themes"] = "🎨",
	["Window Transparency"] = "🪟",
	["Quick Menu Hotkeys"] = "⌨️",
	["Toggle recommended settings?"] = "⭐",
	["Teleport To Lowest Health"] = "🩹",
	["Teleport To Nearest"] = "📍",
	["Kill Players"] = "⚔️",
	["Start Kill Players"] = "⚔️",
	["Open Item Teleports"] = "🎁",
	["Open Player Teleports"] = "👤",
	["Open Map Locations"] = "🗺️",
	Teleport = "🚀"
}

UI.Descriptions = {
	Main = "Fast actions, puzzle tools, and recommended setup.",
	Items = "Find, track, and collect the nearest useful item.",
	Teleports = "Jump to map points or players from compact menus.",
	Combat = "Hitbox controls and player movement utilities.",
	Visuals = "On-screen overlays and player information.",
	Safety = "World hazard protection and safety toggles.",
	Settings = "Theme, hotkey, and window controls.",
	["Quick Teleports"] = "Pinned locations for fast map movement.",
	["Mobile Quick Menus"] = "Touch shortcuts for menus that use hotkeys on PC.",
	["Auto Items"] = "Automatic item use and collection controls.",
	["Hitbox Controls"] = "Adjust size and visibility for player hitboxes.",
	["World Safety"] = "Invisible protection over danger zones.",
	["Kill Players"] = "Cycles through players from lowest health upward.",
	["Themes"] = "Switch the full menu color profile.",
	["Theme Creator"] = "Tune the accent color for your current theme.",
	["Get Code + Go Barn"] = "Moves to barn, scans puzzle assets, and reports the code.",
	["Toggle recommended settings?"] = "Turns on the useful defaults without enabling auto heal."
}

function UI.GetIcon(text)
	if UI.Icons[text] then
		return UI.Icons[text]
	end

	return UI.Icons.Teleport
end

function UI.GetDescription(text)
	return UI.Descriptions[text] or ""
end

local themeObject = UI.ThemeObject
local addCorner = UI.AddCorner
local addStroke = UI.AddStroke
local styleButton = UI.StyleButton

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(520, 380)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.BackgroundTransparency = 0
mainFrame.ZIndex = 10
mainFrame.Parent = gui
themeObject(mainFrame, "BackgroundColor3", "Main")
addCorner(mainFrame, 14)

local isTouchDevice = UserInputService.TouchEnabled

local function getViewportSize()
	local camera = workspace.CurrentCamera
	return camera and camera.ViewportSize or Vector2.new(660, 430)
end

local function getUIScale()
	local viewport = getViewportSize()

	if isTouchDevice or viewport.X < 720 then
		return math.clamp(viewport.X / 430, 0.72, 0.9)
	end

	if viewport.X < 1000 or viewport.Y < 650 then
		return 0.88
	end

	if viewport.X < 1360 or viewport.Y < 760 then
		return 0.94
	end

	return 1
end

local function px(value)
	return math.max(1, math.floor(value * getUIScale() + 0.5))
end

local rootScale = Instance.new("UIScale")
rootScale.Scale = getUIScale()
rootScale.Parent = mainFrame

local function getWindowSize()
	local viewport = getViewportSize()
	local scale = getUIScale()

	if isTouchDevice or viewport.X < 720 then
		return UDim2.fromOffset(
			math.clamp(math.floor(viewport.X * 0.92), 280, math.floor(470 * scale)),
			math.clamp(math.floor(viewport.Y * 0.74), 260, math.floor(420 * scale))
		)
	end

	return UDim2.fromOffset(
		math.clamp(math.floor(viewport.X * 0.58), 500, math.floor(680 * scale)),
		math.clamp(math.floor(viewport.Y * 0.7), 340, math.floor(470 * scale))
	)
end

local function getMinimizedSize()
	local viewport = getViewportSize()

	if isTouchDevice or viewport.X < 720 then
		return UDim2.fromOffset(math.clamp(math.floor(viewport.X * 0.76), 230, 390), px(42))
	end

	return UDim2.fromOffset(420, 42)
end

local function applyMobileMetrics()
	local viewport = getViewportSize()
	local compact = isTouchDevice or viewport.X < 720

	Notify.Width = compact and math.clamp(math.floor(viewport.X * 0.72), 210, 280) or math.floor(286 * getUIScale())
	Notify.RightOffset = compact and 8 or 10
	Notify.BottomOffset = compact and 44 or 58
	Notify.Height = compact and 64 or math.floor(68 * getUIScale())
	Notify.Gap = compact and 5 or 6
end

applyMobileMetrics()

local normalSize = getWindowSize()
local minimizedSize = getMinimizedSize()
local windowTween = nil

local function getOpenWindowPosition()
	local viewport = getViewportSize()
	local topPadding = isTouchDevice and 28 or 38
	local centerY = math.floor((normalSize.Y.Offset / 2) + topPadding)
	local maxCenterY = math.max(centerY, viewport.Y - math.floor(normalSize.Y.Offset / 2) - 12)

	return UDim2.new(0.5, 0, 0, math.min(centerY, maxCenterY))
end

mainFrame.Size = UDim2.fromOffset(math.max(normalSize.X.Offset - 36, 280), math.max(normalSize.Y.Offset - 36, 260))
mainFrame.Position = getOpenWindowPosition()

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
	tweenWindow(normalSize, getOpenWindowPosition(), 0.45)
end)

do
	local stroke = addStroke(mainFrame, currentTheme.Stroke, 1)
	themeObject(stroke, "Color", "Stroke")
end

do
	local glow = Instance.new("UIStroke")
	glow.Thickness = 5
	glow.Transparency = 0.7
	glow.Parent = mainFrame
	themeObject(glow, "Color", "Stroke")
end

do
	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(1, -22, 0, 2)
	accent.Position = UDim2.fromOffset(11, 53)
	accent.BorderSizePixel = 0
	accent.Parent = mainFrame
	themeObject(accent, "BackgroundColor3", "Stroke")
	addCorner(accent, 2)
end

do
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromScale(1, 1)
	holder.BackgroundTransparency = 1
	holder.ZIndex = 0
	holder.Parent = mainFrame

	for i = 1, 10 do
		local line = Instance.new("Frame")
		line.Size = UDim2.new(1, 0, 0, 1)
		line.Position = UDim2.new(0, 0, 0, i * 38)
		line.BackgroundTransparency = 0.88
		line.BorderSizePixel = 0
		line.Parent = holder
		themeObject(line, "BackgroundColor3", "Stroke")
	end
end

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 56)
topBar.BackgroundTransparency = 1
topBar.Active = true
topBar.ZIndex = 30
topBar.Parent = mainFrame

do
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, -104, 0, 32)
	box.Position = UDim2.fromOffset(10, 9)
	box.BorderSizePixel = 0
	box.Parent = topBar
	themeObject(box, "BackgroundColor3", "Panel")
	box.BackgroundTransparency = 0.08
	addCorner(box, 6)
	addStroke(box, Color3.fromRGB(0, 0, 0), 2)

	local badge = Instance.new("TextLabel")
	badge.Size = UDim2.fromOffset(26, 22)
	badge.Position = UDim2.fromOffset(7, 5)
	badge.BorderSizePixel = 0
	badge.Text = "OP"
	badge.Font = Enum.Font.GothamBlack
	badge.TextSize = 10
	badge.Parent = box
	themeObject(badge, "BackgroundColor3", "ButtonDark")
	themeObject(badge, "TextColor3", "Button")
	addCorner(badge, 6)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -44, 1, 0)
	title.Position = UDim2.fromOffset(38, 0)
	title.BackgroundTransparency = 1
	title.Text = "OP Control"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = isTouchDevice and 15 or 17
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = box
	themeObject(title, "TextColor3", "Text")
end

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.fromOffset(31, 31)
minimizeButton.Position = UDim2.new(1, -70, 0, 9)
minimizeButton.Text = "-"
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
minimizeButton.ZIndex = 40
minimizeButton.Parent = topBar
themeObject(minimizeButton, "BackgroundColor3", "ButtonDark")
styleButton(minimizeButton)

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(31, 31)
closeButton.Position = UDim2.new(1, -35, 0, 9)
closeButton.Text = "X"
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.ZIndex = 40
closeButton.Parent = topBar
themeObject(closeButton, "BackgroundColor3", "ButtonDark")
styleButton(closeButton)

local viewportSize = getViewportSize()
local sideTabWidth = viewportSize.X < 420 and 70 or 88
local contentLeftOffset = 9

local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(1, -18, 0, 50)
tabScroll.Position = UDim2.fromOffset(9, 61)
tabScroll.BorderSizePixel = 0
tabScroll.ScrollBarThickness = 4
tabScroll.CanvasSize = UDim2.fromOffset(0, 0)
tabScroll.ClipsDescendants = true
tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
tabScroll.Parent = mainFrame
themeObject(tabScroll, "BackgroundColor3", "Panel")
addCorner(tabScroll, 6)

local tabStroke = addStroke(tabScroll, currentTheme.Stroke, 1)
themeObject(tabStroke, "Color", "Stroke")
tabStroke.Transparency = 0.35

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabLayout.Padding = UDim.new(0, 7)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Parent = tabScroll

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 6)
tabPadding.PaddingLeft = UDim.new(0, 7)
tabPadding.PaddingRight = UDim.new(0, 7)
tabPadding.Parent = tabScroll

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -18, 1, -122)
contentFrame.Position = UDim2.fromOffset(contentLeftOffset, 116)
contentFrame.BorderSizePixel = 0
contentFrame.ClipsDescendants = true
contentFrame.Parent = mainFrame
themeObject(contentFrame, "BackgroundColor3", "Panel")
addCorner(contentFrame, 6)

local contentStroke = addStroke(contentFrame, currentTheme.Stroke, 1)
themeObject(contentStroke, "Color", "Stroke")
contentStroke.Transparency = 0.35

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

UI.CreatePage("Main")
UI.CreatePage("Items")
UI.CreatePage("Teleports")
UI.CreatePage("Combat")
UI.CreatePage("Safety")
UI.CreatePage("Settings")

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

		local icon = button:FindFirstChild("IconBadge")
		local label = button:FindFirstChild("TabLabel")

		if icon then
			icon.BackgroundColor3 = name == UI.SelectedTab and currentTheme.Main or currentTheme.Panel
			icon.TextColor3 = name == UI.SelectedTab and currentTheme.Button or currentTheme.Text
		end

		if label then
			label.TextColor3 = currentTheme.Text
		end
	end
end

function UI.SelectTab(tabName)
	UI.SelectedTab = tabName

	for name, page in pairs(UI.Pages) do
		page.Visible = name == tabName
	end

	for name, button in pairs(UI.TabButtons) do
		button.BackgroundColor3 = name == tabName and currentTheme.Button or currentTheme.ButtonDark

		local icon = button:FindFirstChild("IconBadge")
		local label = button:FindFirstChild("TabLabel")

		if icon then
			icon.BackgroundColor3 = name == tabName and currentTheme.Main or currentTheme.Panel
			icon.TextColor3 = name == tabName and currentTheme.Button or currentTheme.Text
		end

		if label then
			label.TextColor3 = currentTheme.Text
		end
	end
end

local applyTheme = UI.ApplyTheme
local selectTab = UI.SelectTab

function UI.CreateTab(name)
	local button = Instance.new("TextButton")
	button.Name = name .. "Tab"
	button.Size = UDim2.fromOffset(isTouchDevice and 72 or 94, isTouchDevice and 38 or 40)
	button.Text = ""
	button.Font = Enum.Font.GothamBlack
	button.TextSize = 12
	button.TextXAlignment = Enum.TextXAlignment.Center
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	button.Parent = tabScroll
	themeObject(button, "BackgroundColor3", "ButtonDark")
	themeObject(button, "TextColor3", "Text")
	addCorner(button, 6)

	local icon = Instance.new("TextLabel")
	icon.Name = "IconBadge"
	icon.Size = UDim2.fromOffset(18, 18)
	icon.Position = UDim2.fromOffset(8, 10)
	icon.BackgroundTransparency = 0
	icon.Text = UI.GetIcon(name)
	icon.Font = Enum.Font.GothamBlack
	icon.TextSize = 10
	icon.TextXAlignment = Enum.TextXAlignment.Center
	icon.TextYAlignment = Enum.TextYAlignment.Center
	icon.Parent = button
	addCorner(icon, 5)

	local label = Instance.new("TextLabel")
	label.Name = "TabLabel"
	label.Size = UDim2.new(1, -34, 1, 0)
	label.Position = UDim2.fromOffset(30, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.Font = Enum.Font.GothamBold
	label.TextSize = isTouchDevice and 9 or 11
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = button
	themeObject(label, "TextColor3", "Text")

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 4)
	padding.PaddingRight = UDim.new(0, 4)
	padding.Parent = button

	UI.TabButtons[name] = button

	button.MouseButton1Click:Connect(function()
		selectTab(name)
	end)
end

UI.CreateTab("Main")
UI.CreateTab("Teleports")
UI.CreateTab("Items")
UI.CreateTab("Combat")
UI.CreateTab("Safety")
UI.CreateTab("Settings")

tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	tabScroll.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X + 20, 0)
end)

function UI.CreatePageTitle(parent, text)
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, -16, 0, isTouchDevice and 46 or 50)
	box.Position = UDim2.fromOffset(8, 8)
	box.BorderSizePixel = 0
	box.Parent = parent
	themeObject(box, "BackgroundColor3", "ButtonDark")
	box.BackgroundTransparency = 0.12
	addCorner(box, 6)
	local boxStroke = addStroke(box, currentTheme.Stroke, 1)
	boxStroke.Transparency = 0.55
	themeObject(boxStroke, "Color", "Stroke")

	local rail = Instance.new("Frame")
	rail.Size = UDim2.new(0, 4, 1, -14)
	rail.Position = UDim2.fromOffset(9, 7)
	rail.BorderSizePixel = 0
	rail.Parent = box
	themeObject(rail, "BackgroundColor3", "Button")
	addCorner(rail, 4)

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromOffset(24, 24)
	icon.Position = UDim2.fromOffset(20, isTouchDevice and 11 or 13)
	icon.BorderSizePixel = 0
	icon.Text = UI.GetIcon(text)
	icon.Font = Enum.Font.GothamBlack
	icon.TextSize = 13
	icon.Parent = box
	themeObject(icon, "BackgroundColor3", "Panel")
	themeObject(icon, "TextColor3", "Button")
	addCorner(icon, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -66, 0, 22)
	label.Position = UDim2.fromOffset(54, 7)
	label.BackgroundTransparency = 1
	label.Text = string.upper(text)
	label.Font = Enum.Font.GothamBlack
	label.TextSize = isTouchDevice and 12 or 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = box
	themeObject(label, "TextColor3", "Text")

	local description = Instance.new("TextLabel")
	description.Size = UDim2.new(1, -68, 0, 18)
	description.Position = UDim2.fromOffset(54, 27)
	description.BackgroundTransparency = 1
	description.Text = UI.GetDescription(text)
	description.Font = Enum.Font.GothamMedium
	description.TextSize = isTouchDevice and 9 or 10
	description.TextTruncate = Enum.TextTruncate.AtEnd
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextYAlignment = Enum.TextYAlignment.Center
	description.Parent = box
	themeObject(description, "TextColor3", "SubText")
end

UI.CreatePageTitle(UI.Pages.Main, "Main")
UI.CreatePageTitle(UI.Pages.Items, "Items")
UI.CreatePageTitle(UI.Pages.Teleports, "Teleports")
UI.CreatePageTitle(UI.Pages.Combat, "Combat")
UI.CreatePageTitle(UI.Pages.Safety, "Safety")
UI.CreatePageTitle(UI.Pages.Settings, "Settings")

function UI.CreatePageList(parent)
	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -16, 1, -(isTouchDevice and 108 or 114))
	list.Position = UDim2.fromOffset(8, isTouchDevice and 66 or 72)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = isTouchDevice and 3 or 5
	list.CanvasSize = UDim2.fromOffset(0, 0)
	list.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, isTouchDevice and 7 or 9)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	local function updateCanvas()
		task.wait()
		list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
	end

	return list, updateCanvas
end

local mainList, updateMainCanvas = UI.CreatePageList(UI.Pages.Main)
local itemsList, updateItemsCanvas = UI.CreatePageList(UI.Pages.Items)
local teleportList, updateTeleportCanvas = UI.CreatePageList(UI.Pages.Teleports)
local combatList, updateCombatCanvas = UI.CreatePageList(UI.Pages.Combat)
local safetyList, updateSafetyCanvas = UI.CreatePageList(UI.Pages.Safety)
local settingsList, updateSettingsCanvas = UI.CreatePageList(UI.Pages.Settings)

function UI.CreateSmallButton(parent, text, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -8, 0, isTouchDevice and 34 or 38)
	button.Text = ""
	button.Font = Enum.Font.GothamBold
	button.TextSize = 12
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.AutoButtonColor = false
	button.Parent = parent
	themeObject(button, "BackgroundColor3", "ButtonDark")
	styleButton(button)

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromOffset(18, 18)
	icon.Position = UDim2.fromOffset(9, isTouchDevice and 8 or 10)
	icon.BorderSizePixel = 0
	icon.BackgroundTransparency = 1
	icon.Text = UI.GetIcon(text)
	icon.Font = Enum.Font.GothamBlack
	icon.TextSize = 10
	icon.Parent = button
	themeObject(icon, "TextColor3", "Button")

	local label = Instance.new("TextLabel")
	label.Name = "ButtonLabel"
	label.Size = UDim2.new(1, -42, 1, 0)
	label.Position = UDim2.fromOffset(33, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = isTouchDevice and 10 or 12
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = button
	themeObject(label, "TextColor3", "Text")

	button.MouseButton1Click:Connect(function()
		callback()

		local closer = UI.DropdownClosers[parent]
		if closer then
			closer()
		end

		if parent:GetAttribute("IsDropdownBody") then
			UI.CloseActiveSideDropdown()
		end
	end)

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

function UI.CreateSlider(parent, text, minValue, maxValue, defaultValue, callback)
	local value = math.clamp(defaultValue, minValue, maxValue)

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -8, 0, isTouchDevice and 46 or 52)
	holder.BorderSizePixel = 0
	holder.Parent = parent
	themeObject(holder, "BackgroundColor3", "ButtonDark")
	addCorner(holder, 8)
	addStroke(holder, currentTheme.Stroke, 1)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -24, 0, 24)
	label.Position = UDim2.fromOffset(12, 4)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = isTouchDevice and 9 or 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder
	themeObject(label, "TextColor3", "Text")

	local bar = Instance.new("TextButton")
	bar.Size = UDim2.new(1, -24, 0, isTouchDevice and 10 or 7)
	bar.Position = UDim2.fromOffset(12, isTouchDevice and 32 or 36)
	bar.Text = ""
	bar.BorderSizePixel = 0
	bar.AutoButtonColor = false
	bar.Active = true
	bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	bar.Parent = holder
	addCorner(bar, isTouchDevice and 7 or 4)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BorderSizePixel = 0
	fill.Parent = bar
	themeObject(fill, "BackgroundColor3", "Button")
	addCorner(fill, 4)

	local dragging = false

	local function isSliderStart(inputObject)
		return inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch
	end

	local function isSliderMove(inputObject)
		return inputObject.UserInputType == Enum.UserInputType.MouseMovement
			or inputObject.UserInputType == Enum.UserInputType.Touch
	end

	local function setValueFromX(x)
		local percent = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		value = minValue + ((maxValue - minValue) * percent)
		fill.Size = UDim2.fromScale(percent, 1)
		label.Text = text .. ": " .. tostring(math.floor(value * 100 + 0.5)) .. "%"
		callback(value)
	end

	local function refresh()
		local percent = (value - minValue) / (maxValue - minValue)
		fill.Size = UDim2.fromScale(percent, 1)
		label.Text = text .. ": " .. tostring(math.floor(value * 100 + 0.5)) .. "%"
		callback(value)
	end

	bar.InputBegan:Connect(function(inputObject)
		if isSliderStart(inputObject) then
			dragging = true
			setValueFromX(inputObject.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(inputObject)
		if isSliderStart(inputObject) then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(inputObject)
		if dragging and isSliderMove(inputObject) then
			setValueFromX(inputObject.Position.X)
		end
	end)

	refresh()
	return holder
end

function UI.CreateSearchBox(parent, placeholderText, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -10, 0, isTouchDevice and 46 or 52)
	holder.BorderSizePixel = 0
	holder.Parent = parent
	themeObject(holder, "BackgroundColor3", "ButtonDark")
	addCorner(holder, 6)
	addStroke(holder, currentTheme.Stroke, 1)

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromOffset(24, 24)
	icon.Position = UDim2.fromOffset(10, isTouchDevice and 11 or 14)
	icon.BackgroundTransparency = 1
	icon.Text = "🔎"
	icon.Font = Enum.Font.GothamBlack
	icon.TextSize = isTouchDevice and 14 or 16
	icon.Parent = holder
	themeObject(icon, "TextColor3", "Button")

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -48, 1, -10)
	box.Position = UDim2.fromOffset(40, 5)
	box.BackgroundTransparency = 1
	box.ClearTextOnFocus = false
	box.PlaceholderText = placeholderText
	box.Text = ""
	box.Font = Enum.Font.GothamBold
	box.TextSize = isTouchDevice and 11 or 13
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextTruncate = Enum.TextTruncate.AtEnd
	box.Parent = holder
	themeObject(box, "TextColor3", "Text")
	themeObject(box, "PlaceholderColor3", "SubText")

	box:GetPropertyChangedSignal("Text"):Connect(function()
		callback(box.Text)
	end)

	return holder, box
end

UI.ToggleDescriptions = {
	["Auto Collect"] = "Moves to the closest available item and collects it.",
	["Auto Heal"] = "Uses healing tools when health drops below the set threshold.",
	["Expand Hitbox"] = "Applies your selected hitbox size to other players.",
	["Visualise Hitboxes"] = "Toggles the neon hitbox preview on or off.",
	["Auto Glove Tap"] = "Automatically taps/clicks when another player's glove enters your hitbox.",
	["Player Stats ESP"] = "Shows health, kills, strength, and speed above players.",
	["Anti Acid & Lava"] = "Places invisible safety floors over known hazard zones.",
	["Quick Menu Hotkeys"] = "Enables R, Q, and G shortcuts for the quick menus.",
	["Toggle recommended settings?"] = "Turns on ESP, hitbox, auto tap, hotkeys, and safety."
}

function UI.CreateToggleButton(parent, text, defaultState, callback, descriptionText)
	local state = defaultState == true
	local description = descriptionText or UI.ToggleDescriptions[text] or ""

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -8, 0, description ~= "" and (isTouchDevice and 56 or 64) or (isTouchDevice and 38 or 44))
	button.Text = ""
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = parent

	UI.TopLevelToggleOrder += 1
	button.LayoutOrder = -10000 + UI.TopLevelToggleOrder

	themeObject(button, "BackgroundColor3", "ButtonDark")
	styleButton(button)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -90, 0, description ~= "" and 20 or 38)
	label.Position = UDim2.fromOffset(42, description ~= "" and 6 or 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextSize = isTouchDevice and 10 or 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = button
	themeObject(label, "TextColor3", "Text")

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.fromOffset(21, 21)
	icon.Position = UDim2.fromOffset(10, description ~= "" and 10 or 9)
	icon.BorderSizePixel = 0
	icon.Text = UI.GetIcon(text)
	icon.Font = Enum.Font.GothamBlack
	icon.TextSize = 10
	icon.Parent = button
	themeObject(icon, "BackgroundColor3", "Panel")
	themeObject(icon, "TextColor3", "Button")
	addCorner(icon, 6)

	local descriptionLabel = nil

	if description ~= "" then
		descriptionLabel = Instance.new("TextLabel")
		descriptionLabel.Size = UDim2.new(1, -100, 0, 26)
        descriptionLabel.Position = UDim2.fromOffset(43, 28)
		descriptionLabel.BackgroundTransparency = 1
		descriptionLabel.Text = description
		descriptionLabel.Font = Enum.Font.GothamMedium
		descriptionLabel.TextSize = isTouchDevice and 8 or 10
		descriptionLabel.TextWrapped = true
		descriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
		descriptionLabel.TextYAlignment = Enum.TextYAlignment.Top
		descriptionLabel.Parent = button
		themeObject(descriptionLabel, "TextColor3", "SubText")
	end

	local switch = Instance.new("Frame")
	switch.Size = UDim2.fromOffset(34, 18)
	switch.Position = UDim2.new(1, -44, 0, description ~= "" and 14 or 10)
	switch.BorderSizePixel = 0
	switch.Parent = button
	addCorner(switch, 11)
	addStroke(switch, Color3.fromRGB(0, 0, 0), 1)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(12, 12)
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
			{ Position = state and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3) }
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
	wrapper.Size = UDim2.new(1, -6, 0, isTouchDevice and 54 or 60)
	wrapper.BackgroundTransparency = 1
	wrapper.BorderSizePixel = 0
	wrapper.ClipsDescendants = false
	wrapper.Parent = list

	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, -18, 0, isTouchDevice and 50 or 56)
	holder.Position = UDim2.new(0.5, 0, 0, 3)
	holder.AnchorPoint = Vector2.new(0.5, 0)
	holder.BorderSizePixel = 0
	holder.ClipsDescendants = true
	holder.Parent = wrapper
	themeObject(holder, "BackgroundColor3", "ButtonDark")
	holder.BackgroundTransparency = 0.1
	addCorner(holder, 6)
	do
		local stroke = addStroke(holder, currentTheme.Stroke, 1)
		stroke.Transparency = 0.78
		themeObject(stroke, "Color", "Stroke")
	end

	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, 0, 0, isTouchDevice and 50 or 56)
	header.BackgroundTransparency = 1
	header.Text = ""
	header.Font = Enum.Font.GothamBold
	header.TextSize = 14
	header.TextXAlignment = Enum.TextXAlignment.Center
	header.Parent = holder
	themeObject(header, "TextColor3", "Text")

	local headerIcon = Instance.new("TextLabel")
	headerIcon.Size = UDim2.fromOffset(isTouchDevice and 26 or 30, isTouchDevice and 26 or 30)
	headerIcon.Position = UDim2.fromOffset(11, isTouchDevice and 12 or 13)
	headerIcon.BorderSizePixel = 0
	headerIcon.Text = UI.GetIcon(titleText)
	headerIcon.Font = Enum.Font.GothamBlack
	headerIcon.TextSize = isTouchDevice and 11 or 13
	headerIcon.Parent = holder
	themeObject(headerIcon, "BackgroundColor3", "Panel")
	themeObject(headerIcon, "TextColor3", "Button")
	headerIcon.BackgroundTransparency = 0.22
	addCorner(headerIcon, 6)

	local headerLabel = Instance.new("TextLabel")
	headerLabel.Size = UDim2.new(1, -86, 0, 22)
	headerLabel.Position = UDim2.fromOffset(isTouchDevice and 45 or 50, isTouchDevice and 7 or 9)
	headerLabel.BackgroundTransparency = 1
	headerLabel.Text = titleText
	headerLabel.Font = Enum.Font.GothamBlack
	headerLabel.TextSize = isTouchDevice and 12 or 14
	headerLabel.TextTruncate = Enum.TextTruncate.AtEnd
	headerLabel.TextXAlignment = Enum.TextXAlignment.Left
	headerLabel.Parent = holder
	themeObject(headerLabel, "TextColor3", "Text")

	local headerDescription = Instance.new("TextLabel")
	headerDescription.Size = UDim2.new(1, -86, 0, 18)
	headerDescription.Position = UDim2.fromOffset(isTouchDevice and 45 or 50, isTouchDevice and 28 or 32)
	headerDescription.BackgroundTransparency = 1
	headerDescription.Text = UI.GetDescription(titleText)
	headerDescription.Font = Enum.Font.GothamMedium
	headerDescription.TextSize = isTouchDevice and 8 or 10
	headerDescription.TextTruncate = Enum.TextTruncate.AtEnd
	headerDescription.TextXAlignment = Enum.TextXAlignment.Left
	headerDescription.Parent = holder
	themeObject(headerDescription, "TextColor3", "SubText")

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.fromOffset(24, 24)
	arrow.Position = UDim2.new(1, -34, 0, isTouchDevice and 13 or 16)
	arrow.BackgroundTransparency = 1
	arrow.Active = true
	arrow.Text = "+"
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = 14
	arrow.Parent = holder
	themeObject(arrow, "TextColor3", "Text")

	local dropdownScale = Instance.new("UIScale")
	dropdownScale.Scale = 1
	dropdownScale.Parent = holder

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, 0, 0, 0)
	body.Position = UDim2.fromOffset(0, isTouchDevice and 54 or 60)
	body.BackgroundTransparency = 1
	body.Visible = false
	body.Parent = holder
	body:SetAttribute("IsDropdownBody", true)

	local bodyLayout = Instance.new("UIListLayout")
	bodyLayout.Padding = UDim.new(0, isTouchDevice and 6 or 8)
	bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	bodyLayout.Parent = body

	local bodyPadding = Instance.new("UIPadding")
	bodyPadding.PaddingLeft = UDim.new(0, 6)
	bodyPadding.PaddingRight = UDim.new(0, 6)
	bodyPadding.Parent = body

	local open = false

	local function refreshSize(animated)
		local bodyHeight = bodyLayout.AbsoluteContentSize.Y + 12
		local closedHeight = isTouchDevice and 50 or 56
		local targetHeight = open and ((isTouchDevice and 58 or 64) + bodyHeight) or closedHeight

		body.Size = UDim2.new(1, 0, 0, bodyHeight)
		wrapper.Size = UDim2.new(1, -6, 0, targetHeight + 7)

		if animated then
			TweenService:Create(
				holder,
				TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, -18, 0, targetHeight) }
			):Play()
		else
			holder.Size = UDim2.new(1, -18, 0, targetHeight)
		end

		updateCanvas()
		task.delay(0.28, updateCanvas)
	end

	local function toggle()
		open = not open
		body.Visible = open
		arrow.Text = open and "-" or "+"

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
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1
			or inputObject.UserInputType == Enum.UserInputType.Touch
		then
			toggle()
		end
	end)

			bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		refreshSize(false)
	end)

	UI.DropdownClosers[body] = function()
		if open then
			open = false
			body.Visible = false
			arrow.Text = "+"
			refreshSize(true)
		end
	end

	updateCanvas()
	return body
end

function UI.CloseActiveSideDropdown()
	if UI.ActiveSideDropdown and UI.ActiveSideDropdown.Close then
		UI.ActiveSideDropdown.Close()
	end
end

function UI.CloseAllDropdowns()
	for _, closer in pairs(UI.DropdownClosers) do
		if closer then
			closer()
		end
	end

	UI.CloseActiveSideDropdown()
end

function UI.CreateSideDropdown(list, titleText, updateCanvas, descriptionText)
	local description = descriptionText or ""
	local viewport = getViewportSize()
	local flyoutWidth = isTouchDevice and math.clamp(math.floor(viewport.X * 0.76), 220, 292) or 300

	local function refreshFlyoutWidth()
		local viewportSize = getViewportSize()
		flyoutWidth = isTouchDevice and math.clamp(math.floor(viewportSize.X * 0.76), 220, 292) or 300
	end

	local wrapper = Instance.new("Frame")
	wrapper.Size = UDim2.new(1, -6, 0, description ~= "" and (isTouchDevice and 58 or 64) or (isTouchDevice and 42 or 48))
	wrapper.BackgroundTransparency = 1
	wrapper.BorderSizePixel = 0
	wrapper.Parent = list

	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, -18, 0, description ~= "" and (isTouchDevice and 54 or 60) or (isTouchDevice and 38 or 44))
	header.Position = UDim2.new(0.5, 0, 0, 3)
	header.AnchorPoint = Vector2.new(0.5, 0)
	header.BorderSizePixel = 0
	header.Text = ""
	header.Font = Enum.Font.GothamBold
	header.TextSize = 14
	header.Parent = wrapper
	themeObject(header, "BackgroundColor3", "ButtonDark")
	header.BackgroundTransparency = 0.1
	styleButton(header)

	local headerIcon = Instance.new("TextLabel")
	headerIcon.Size = UDim2.fromOffset(isTouchDevice and 24 or 28, isTouchDevice and 24 or 28)
	headerIcon.Position = UDim2.fromOffset(10, description ~= "" and 8 or 8)
	headerIcon.BorderSizePixel = 0
	headerIcon.Text = UI.GetIcon(titleText)
	headerIcon.Font = Enum.Font.GothamBlack
	headerIcon.TextSize = isTouchDevice and 11 or 13
	headerIcon.Parent = header
	themeObject(headerIcon, "BackgroundColor3", "Panel")
	themeObject(headerIcon, "TextColor3", "Button")
	headerIcon.BackgroundTransparency = 0.22
	addCorner(headerIcon, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -56, 0, 22)
	label.Position = UDim2.fromOffset(isTouchDevice and 40 or 46, description ~= "" and 5 or 9)
	label.BackgroundTransparency = 1
	label.Text = titleText
	label.Font = Enum.Font.GothamBlack
	label.TextSize = isTouchDevice and 11 or 13
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = header
	themeObject(label, "TextColor3", "Text")

	if description ~= "" then
		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(1, -58, 0, 23)
		desc.Position = UDim2.fromOffset(isTouchDevice and 40 or 46, 28)
		desc.BackgroundTransparency = 1
		desc.Text = description
		desc.Font = Enum.Font.GothamMedium
		desc.TextSize = isTouchDevice and 8 or 10
		desc.TextWrapped = true
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.TextYAlignment = Enum.TextYAlignment.Top
		desc.Parent = header
		themeObject(desc, "TextColor3", "SubText")
	end

	local flyout = Instance.new("Frame")
	flyout.Size = UDim2.fromOffset(flyoutWidth, 0)
	flyout.BackgroundTransparency = 0.04
	flyout.BorderSizePixel = 0
	flyout.Visible = false
	flyout.Active = false
	flyout.ZIndex = 80
	flyout.ClipsDescendants = true
	flyout.Parent = gui
	themeObject(flyout, "BackgroundColor3", "Panel")
	addCorner(flyout, 6)

	local flyoutStroke = addStroke(flyout, currentTheme.Stroke, 1)
	themeObject(flyoutStroke, "Color", "Stroke")
	flyoutStroke.Transparency = 0.72

	local flyoutTitle = Instance.new("TextLabel")
	flyoutTitle.Size = UDim2.new(1, -84, 0, 40)
	flyoutTitle.Position = UDim2.fromOffset(46, 0)
	flyoutTitle.BackgroundTransparency = 1
	flyoutTitle.Text = titleText
	flyoutTitle.Font = Enum.Font.GothamBlack
	flyoutTitle.TextSize = isTouchDevice and 12 or 14
	flyoutTitle.TextXAlignment = Enum.TextXAlignment.Left
	flyoutTitle.Parent = flyout
	themeObject(flyoutTitle, "TextColor3", "Text")

	local flyoutIcon = Instance.new("TextLabel")
	flyoutIcon.Size = UDim2.fromOffset(26, 26)
	flyoutIcon.Position = UDim2.fromOffset(10, 7)
	flyoutIcon.BorderSizePixel = 0
	flyoutIcon.Text = UI.GetIcon(titleText)
	flyoutIcon.Font = Enum.Font.GothamBlack
	flyoutIcon.TextSize = isTouchDevice and 11 or 13
	flyoutIcon.Parent = flyout
	themeObject(flyoutIcon, "BackgroundColor3", "ButtonDark")
	themeObject(flyoutIcon, "TextColor3", "Button")
	flyoutIcon.BackgroundTransparency = 0.22
	addCorner(flyoutIcon, 6)

	local closeFlyout = Instance.new("TextButton")
	closeFlyout.Size = UDim2.fromOffset(28, 28)
	closeFlyout.Position = UDim2.new(1, -35, 0, 6)
	closeFlyout.BorderSizePixel = 0
	closeFlyout.Text = "X"
	closeFlyout.Font = Enum.Font.GothamBlack
	closeFlyout.TextSize = 13
	closeFlyout.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeFlyout.BackgroundColor3 = Color3.fromRGB(220, 45, 55)
	closeFlyout.Parent = flyout
	addCorner(closeFlyout, 8)
	styleButton(closeFlyout)

	local body = Instance.new("ScrollingFrame")
	body.Size = UDim2.new(1, -18, 1, -50)
	body.Position = UDim2.fromOffset(9, 44)
	body.BackgroundTransparency = 1
	body.BorderSizePixel = 0
	body.ScrollBarThickness = isTouchDevice and 3 or 5
	body.CanvasSize = UDim2.fromOffset(0, 0)
	body.Parent = flyout
	body:SetAttribute("IsDropdownBody", true)

	local bodyLayout = Instance.new("UIListLayout")
	bodyLayout.Padding = UDim.new(0, isTouchDevice and 6 or 8)
	bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	bodyLayout.Parent = body

	local bodyPadding = Instance.new("UIPadding")
	bodyPadding.PaddingLeft = UDim.new(0, 4)
	bodyPadding.PaddingRight = UDim.new(0, 4)
	bodyPadding.Parent = body

	local open = false
	local flyoutTween = nil

	local function getTargetPosition()
		refreshFlyoutWidth()

		local viewportSize = getViewportSize()
		local targetX = mainFrame.AbsolutePosition.X + mainFrame.AbsoluteSize.X + 12
		local targetY = mainFrame.AbsolutePosition.Y + 58

		if isTouchDevice or targetX + flyoutWidth > viewportSize.X - 8 then
			targetX = math.clamp(mainFrame.AbsolutePosition.X + 8, 8, math.max(8, viewportSize.X - flyoutWidth - 8))
			targetY = math.clamp(mainFrame.AbsolutePosition.Y + 66, 8, math.max(8, viewportSize.Y - 160))
		end

		return UDim2.fromOffset(targetX, targetY)
	end

	local function getTargetHeight()
		local viewportSize = getViewportSize()
		local targetPosition = getTargetPosition()
	local maxHeight = math.max(120, math.min(math.max(210, mainFrame.AbsoluteSize.Y - 58), viewportSize.Y - targetPosition.Y.Offset - 10))

		return math.clamp(bodyLayout.AbsoluteContentSize.Y + 50, 120, maxHeight)
	end

	local function refreshBody()
		body.CanvasSize = UDim2.fromOffset(0, bodyLayout.AbsoluteContentSize.Y + 14)
	end

	local function repositionFlyout()
		if open and flyout.Visible then
			flyout.Position = getTargetPosition()
			flyout.Size = UDim2.fromOffset(flyoutWidth, getTargetHeight())
		end
	end

	local function tweenFlyout(targetSize, targetPosition, targetTransparency, duration)
		if flyoutTween then
			flyoutTween:Cancel()
		end

		flyoutTween = TweenService:Create(
			flyout,
			TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Size = targetSize,
				Position = targetPosition,
				BackgroundTransparency = targetTransparency
			}
		)

		flyoutTween:Play()
		return flyoutTween
	end

	local function closeFlyoutAnimated()
		if not open then
			flyout.Visible = false
			flyout.Active = false
			return
		end

		open = false
		flyout.Active = false

		local targetPosition = getTargetPosition()
		local outTween = tweenFlyout(
			UDim2.fromOffset(flyoutWidth, 0),
			UDim2.fromOffset(targetPosition.X.Offset - 18, targetPosition.Y.Offset),
			0.35,
			0.22
		)

		outTween.Completed:Connect(function()
			if not open then
				flyout.Visible = false
				flyout.Active = false
			end
		end)

		if UI.ActiveSideDropdown and UI.ActiveSideDropdown.Body == body then
			UI.ActiveSideDropdown = nil
		end
	end

	local function openFlyout()
		if UI.ActiveSideDropdown and UI.ActiveSideDropdown.Body ~= body then
			UI.ActiveSideDropdown.Close()
		end

		UI.ActiveSideDropdown = {
			Body = body,
			Close = closeFlyoutAnimated,
			Reposition = repositionFlyout
		}

		open = true
		refreshBody()

		local targetPosition = getTargetPosition()
		local targetHeight = getTargetHeight()

		flyout.Position = UDim2.fromOffset(targetPosition.X.Offset - 18, targetPosition.Y.Offset)
		flyout.Size = UDim2.fromOffset(flyoutWidth, 0)
		flyout.BackgroundTransparency = 0.35
		flyout.Visible = true
		flyout.Active = true

		tweenFlyout(UDim2.fromOffset(flyoutWidth, targetHeight), targetPosition, 0.04, 0.28)
	end

	header.MouseButton1Click:Connect(function()
		if open then
			closeFlyoutAnimated()
		else
			openFlyout()
		end
	end)

	closeFlyout.MouseButton1Click:Connect(closeFlyoutAnimated)

	bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		refreshBody()

		if open then
			tweenFlyout(UDim2.fromOffset(flyoutWidth, getTargetHeight()), getTargetPosition(), 0.04, 0.18)
		end
	end)

	mainFrame:GetPropertyChangedSignal("Position"):Connect(repositionFlyout)
	mainFrame:GetPropertyChangedSignal("Size"):Connect(repositionFlyout)

	UI.SideDropdowns[titleText] = {
		Body = body,
		Open = openFlyout,
		Close = closeFlyoutAnimated,
		IsOpen = function()
			return open
		end
	}

	updateCanvas()
	return body
end

local createSmallButton = UI.CreateSmallButton
local createWarningLabel = UI.CreateWarningLabel
local createToggleButton = UI.CreateToggleButton
local createSearchBox = UI.CreateSearchBox
local createDropdown = UI.CreateDropdown
local createSideDropdown = UI.CreateSideDropdown

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
notificationStack.Active = false
notificationStack.ZIndex = 100
notificationStack.Parent = gui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.FillDirection = Enum.FillDirection.Vertical
notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.Padding = UDim.new(0, Notify.Gap)
notificationLayout.Parent = notificationStack

function Notify.RefreshLayout()
	applyMobileMetrics()

	notificationStack.Size = UDim2.new(0, Notify.Width, 1, -Notify.BottomOffset)
	notificationStack.Position = UDim2.new(1, -(Notify.Width + Notify.RightOffset), 0, 0)

	for _, slot in ipairs(Notify.Active) do
		if slot and slot.Parent then
			slot.Size = UDim2.fromOffset(Notify.Width, slot.Size.Y.Offset)

			local popup = slot:FindFirstChild("Popup")
			if popup then
				popup.Size = UDim2.fromOffset(Notify.Width, Notify.Height)
			end
		end
	end
end

function Notify.Trim()
	while #Notify.Active > Notify.MaxVisible do
		local oldest = table.remove(Notify.Active, 1)
		if oldest and oldest.Parent then
			oldest:Destroy()
		end
	end
end

function Notify.Clear()
	for _, slot in ipairs(Notify.Active) do
		if slot and slot.Parent then
			slot:Destroy()
		end
	end

	Notify.Active = {}
end

function Notify.Show(titleText, messageText, kind, clickCallback, lifeTime, forceShow)
	if Notify.Muted and not forceShow then
		return
	end

	Notify.RefreshLayout()
	Notify.Order += 1
	lifeTime = lifeTime or Notify.LifeTime

	local preset = Notify.Presets[Notify.GetKind(titleText, kind)]

	local slot = Instance.new("Frame")
	slot.Size = UDim2.fromOffset(Notify.Width, 0)
	slot.BackgroundTransparency = 1
	slot.LayoutOrder = Notify.Order
	slot.ClipsDescendants = true
	slot.Active = false
	slot.ZIndex = 100
	slot.Parent = notificationStack

	table.insert(Notify.Active, slot)
	Notify.Trim()

	local hasClickAction = clickCallback ~= nil

	local popup = Instance.new("Frame")
	popup.Name = "Popup"
	popup.Size = UDim2.fromOffset(Notify.Width, Notify.Height)
	popup.Position = UDim2.fromOffset(Notify.Width + 42, 0)
	popup.BackgroundTransparency = 0.04
	popup.BorderSizePixel = 0
	popup.ClipsDescendants = true
	popup.Active = false
	popup.ZIndex = 101
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
	iconBubble.Size = UDim2.fromOffset(28, 28)
	iconBubble.Position = UDim2.fromOffset(12, 10)
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
	noteTitle.Size = UDim2.new(1, -58, 0, 24)
	noteTitle.Position = UDim2.fromOffset(48, 10)
	noteTitle.BackgroundTransparency = 1
	noteTitle.Text = tostring(titleText)
	noteTitle.Font = Enum.Font.GothamBlack
	noteTitle.TextSize = isTouchDevice and 14 or 15
	noteTitle.TextXAlignment = Enum.TextXAlignment.Left
	noteTitle.TextTruncate = Enum.TextTruncate.AtEnd
	noteTitle.Parent = popup
	themeObject(noteTitle, "TextColor3", "Text")

	local message = Instance.new("TextLabel")
	message.Size = UDim2.new(1, -58, 0, 38)
	message.Position = UDim2.fromOffset(48, 36)
	message.BackgroundTransparency = 1
	message.Text = tostring(messageText)
	message.Font = Enum.Font.GothamMedium
	message.TextSize = isTouchDevice and 12 or 13
	message.TextWrapped = true
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextYAlignment = Enum.TextYAlignment.Top
	message.Parent = popup
	themeObject(message, "TextColor3", "SubText")

	local progressBack = Instance.new("Frame")
	progressBack.Size = UDim2.new(1, -28, 0, 4)
	progressBack.Position = UDim2.new(0, 14, 1, -9)
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
	local dismiss = nil

	if hasClickAction then
		local clickButton = Instance.new("TextButton")
		clickButton.Size = UDim2.fromOffset(44, 28)
		clickButton.Position = UDim2.new(1, -54, 0, 10)
		clickButton.BorderSizePixel = 0
		clickButton.Text = "GO"
		clickButton.Font = Enum.Font.GothamBlack
		clickButton.TextSize = 12
		clickButton.TextColor3 = Color3.fromRGB(10, 12, 18)
		clickButton.BackgroundColor3 = preset.Color
		clickButton.AutoButtonColor = false
		clickButton.ZIndex = popup.ZIndex + 1
		clickButton.Parent = popup
		addCorner(clickButton, 6)

		clickButton.MouseButton1Click:Connect(function()
			clickCallback()
			dismiss()
		end)
	end

	dismiss = function()
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
		TweenInfo.new(lifeTime, Enum.EasingStyle.Linear),
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

	task.delay(lifeTime, function()
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
Teleport.Cooldown = 1
Teleport.Debounce = 1
Teleport.PostFLock = 0.5
Teleport.Strikes = 0
Teleport.LockedUntil = 0
Teleport.LastClickAt = 0
Teleport.BlockFUntil = 0

Items.SearchRootName = "Items"
Items.SearchText = ""
Items.TeleportDebounce = Teleport.Debounce
Items.Crates = {}
Items.KnownCrates = {}
Items.CrateButtonLabel = nil

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
	if Teleport.LastClickAt == 0 or os.clock() - Teleport.LastClickAt >= Teleport.Cooldown then
		Teleport.Strikes = 0
		Teleport.LockedUntil = 0
	end
end

function Teleport.ShowWarning(secondsText)
	Notify.Show(
		"Cooldown",
		"Wait " .. secondsText .. " before teleporting again.",
		"Warning",
		nil,
		2.2,
		true
	)
end

function Teleport.CanTeleport(debounceOverride)
	if Teleport.IsLocked() then
		Teleport.ShowWarning(tostring(Teleport.GetCooldownLeft()))
		return false
	end

	local now = os.clock()
	local debounce = debounceOverride or Teleport.Debounce
	local debounceLeft = debounce - (now - Teleport.LastClickAt)

	if Teleport.LastClickAt ~= 0 and debounceLeft > 0 then
		Teleport.ShowWarning(tostring(math.max(1, math.ceil(debounceLeft))))
		return false
	end

	Teleport.ResetStrikesIfReady()
	return true
end

function Teleport.AddStrike()
	Teleport.LastClickAt = os.clock()
	Teleport.Strikes += 1

	if Teleport.Strikes >= Teleport.MaxStrikes then
		Teleport.LockedUntil = os.clock() + Teleport.Cooldown
		Teleport.Strikes = 0
	end
end

function Teleport.StartFBlock()
	Teleport.BlockFUntil = os.clock() + Teleport.PostFLock
end

function Teleport.ShowFBlockedWarning()
	local secondsLeft = math.max(0.1, Teleport.BlockFUntil - os.clock())

	Notify.Show(
		"Cooldown",
		"Wait " .. string.format("%.1f", secondsLeft) .. " seconds before pressing F again.",
		"Warning",
		nil,
		1.4,
		true
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

function Teleport.GetGroundCFrame(position, excludeInstances, stayClose)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = excludeInstances or {}

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = excludeInstances or {}

	local function hasRoom(candidatePosition)
		local touching = workspace:GetPartBoundsInBox(CFrame.new(candidatePosition + Vector3.new(0, 2, 0)), Vector3.new(4, 5, 4), overlapParams)

		for _, part in ipairs(touching) do
			if part.CanCollide and part.Transparency < 0.95 then
				return false
			end
		end

		return true
	end

	local offsets = stayClose and {
		Vector3.zero,
		Vector3.new(2, 0, 0),
		Vector3.new(-2, 0, 0),
		Vector3.new(0, 0, 2),
		Vector3.new(0, 0, -2),
		Vector3.new(3, 0, 3),
		Vector3.new(-3, 0, 3),
		Vector3.new(3, 0, -3),
		Vector3.new(-3, 0, -3)
	} or {
		Vector3.zero,
		Vector3.new(6, 0, 0),
		Vector3.new(-6, 0, 0),
		Vector3.new(0, 0, 6),
		Vector3.new(0, 0, -6),
		Vector3.new(8, 0, 8),
		Vector3.new(-8, 0, 8),
		Vector3.new(8, 0, -8),
		Vector3.new(-8, 0, -8)
	}

	for _, offset in ipairs(offsets) do
		local rayOrigin = position + offset + Vector3.new(0, 6, 0)
		local rayDirection = Vector3.new(0, -90, 0)
		local result = workspace:Raycast(rayOrigin, rayDirection, params)
		local candidatePosition = result and (result.Position + Vector3.new(0, 4, 0)) or (position + offset + Vector3.new(0, 4, 0))

		if hasRoom(candidatePosition) then
			return CFrame.new(candidatePosition)
		end
	end

	return CFrame.new(position + Vector3.new(0, 4, 0))
end

function Teleport.GetItemCFrame(itemPart, excludeInstances)
	local position = itemPart.Position

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = excludeInstances or {}

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = excludeInstances or {}

	local function hasRoom(candidatePosition)
		local touching = workspace:GetPartBoundsInBox(CFrame.new(candidatePosition + Vector3.new(0, 2, 0)), Vector3.new(4, 5, 4), overlapParams)

		for _, part in ipairs(touching) do
			if part ~= itemPart and part.CanCollide and part.Transparency < 0.95 then
				return false
			end
		end

		return true
	end

	local offsets = {
		Vector3.new(2.5, 0, 0),
		Vector3.new(-2.5, 0, 0),
		Vector3.new(0, 0, 2.5),
		Vector3.new(0, 0, -2.5),
		Vector3.new(3.5, 0, 3.5),
		Vector3.new(-3.5, 0, 3.5),
		Vector3.new(3.5, 0, -3.5),
		Vector3.new(-3.5, 0, -3.5),
		Vector3.zero
	}

	for _, offset in ipairs(offsets) do
		local rayOrigin = position + offset + Vector3.new(0, 5, 0)
		local result = workspace:Raycast(rayOrigin, Vector3.new(0, -18, 0), params)

		if result and math.abs(result.Position.Y - position.Y) <= 12 then
			local candidatePosition = result.Position + Vector3.new(0, 4, 0)

			if hasRoom(candidatePosition) then
				return CFrame.new(candidatePosition)
			end
		end
	end

	for _, offset in ipairs(offsets) do
		local candidatePosition = position + offset + Vector3.new(0, 3, 0)

		if hasRoom(candidatePosition) then
			return CFrame.new(candidatePosition)
		end
	end

	return CFrame.new(position + Vector3.new(0, 4, 0))
end

function Teleport.CreateMarker(position)
	return nil
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

	local groundCFrame = Teleport.GetGroundCFrame(position, { character })
	local distance = (root.Position - groundCFrame.Position).Magnitude

	print("[TELEPORT DEBUG]", locationName, "distance:", math.floor(distance), "target:", groundCFrame.Position)

	Teleport.MoveRoot(root, groundCFrame)
	Teleport.AddStrike()
	Teleport.StartFBlock()
	createNotification("Teleport", "Teleported to " .. locationName)
end

Items.SearchCache = {}
Items.SearchCacheBusy = false
Items.LastSearchCacheAt = 0
Items.SearchCacheCooldown = 0.35

function Items.GetSearchRoot()
	return workspace:FindFirstChild(Items.SearchRootName)
end

function Items.RebuildSearchCache()
	if Items.SearchCacheBusy then
		return
	end

	Items.SearchCacheBusy = true

	task.spawn(function()
		local root = Items.GetSearchRoot() or workspace
		local queue = root:GetChildren()
		local results = {}
		local scanned = 0
		local lookup = Items.SearchNameLookup

		while #queue > 0 do
			local object = table.remove(queue)

			local displayName = object.Name

			if not lookup or lookup[Utility.NormalizeName(displayName)] then
				table.insert(results, object)
			end

			for _, child in ipairs(object:GetChildren()) do
				table.insert(queue, child)
			end

			scanned += 1

			if scanned % 45 == 0 then
				task.wait()
			end
		end

		Items.SearchCache = results
		Items.LastSearchCacheAt = os.clock()
		Items.SearchCacheBusy = false
	end)
end

function Items.GetSearchDescendants()
	if os.clock() - Items.LastSearchCacheAt > Items.SearchCacheCooldown then
		Items.RebuildSearchCache()
	end

	return Items.SearchCache
end

function Items.FindManualItem(itemName)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil, nil
	end

	local closestObject = nil
	local closestPart = nil
	local closestDistance = math.huge

	for _, object in ipairs(Items.GetSearchDescendants()) do
		local displayName = object.Name

		if Utility.NormalizeName(displayName) == Utility.NormalizeName(itemName) then
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
					local distance = (root.Position - part.Position).Magnitude

					if distance < closestDistance then
						closestDistance = distance
						closestObject = object
						closestPart = part
					end
				end
			end
		end
	end

	return closestObject, closestPart
end

function Items.TeleportTo(itemName)
	if not Teleport.CanTeleport(Items.TeleportDebounce) then
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

	local groundCFrame = Teleport.GetItemCFrame(itemPart, { character, itemObject })

	Teleport.MoveRoot(root, groundCFrame)
	Teleport.AddStrike()
	Teleport.StartFBlock()
	createNotification("Items", "Teleported to " .. itemName)
end

function Items.GetCratePart(crate)
	if not crate or not crate.Parent or not crate:IsDescendantOf(workspace) then
		return nil
	end

	if crate:IsA("BasePart") then
		return crate
	end

	if crate:IsA("Model") then
		return crate.PrimaryPart or crate:FindFirstChildWhichIsA("BasePart", true)
	end

	return crate:FindFirstChildWhichIsA("BasePart", true)
end

function Items.IsMeteorCrate(object)
	if not object or not object.Parent then
		return false
	end

	local name = Utility.NormalizeName(object.Name)
	if not string.find(name, "crate") then
		return false
	end

	return object:IsA("BasePart") or object:IsA("Model") or object:FindFirstChildWhichIsA("BasePart", true) ~= nil
end

function Items.GetCrateRoot(object)
	local current = object
	local crateRoot = nil

	while current and current ~= workspace do
		if Items.IsMeteorCrate(current) then
			crateRoot = current
		end

		current = current.Parent
	end

	return crateRoot
end

function Items.RefreshCrates()
	local liveCrates = {}

	for _, crate in ipairs(Items.Crates) do
		if Items.GetCratePart(crate) then
			table.insert(liveCrates, crate)
		end
	end

	Items.Crates = liveCrates

	if Items.CrateButtonLabel then
		if #Items.Crates > 0 then
			Items.CrateButtonLabel.Text = "Meteor Crate (" .. tostring(#Items.Crates) .. ")"
		else
			Items.CrateButtonLabel.Text = "Meteor Crate (none spawned)"
		end
	end
end

function Items.TrackCrate(crate, notify)
	local crateRoot = Items.GetCrateRoot(crate)

	if not crateRoot then
		return
	end

	local current = crateRoot.Parent
	while current and current ~= workspace do
		if Items.KnownCrates[current] then
			return
		end

		current = current.Parent
	end

	for knownCrate in pairs(Items.KnownCrates) do
		if knownCrate.Parent and knownCrate:IsDescendantOf(crateRoot) then
			Items.KnownCrates[knownCrate] = nil
		end
	end

	if Items.KnownCrates[crateRoot] then
		return
	end

	Items.KnownCrates[crateRoot] = true
	table.insert(Items.Crates, crateRoot)
	Items.RefreshCrates()

	if notify then
		createNotification("Meteor Crate", "A meteor crate spawned.", "Success")
	end

	crateRoot.AncestryChanged:Connect(function()
		Items.RefreshCrates()
	end)
end

function Items.FindNearestCrate()
	Items.RefreshCrates()

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local nearestCrate = nil
	local nearestPart = nil
	local nearestDistance = math.huge

	for _, crate in ipairs(Items.Crates) do
		local part = Items.GetCratePart(crate)

		if part then
			local distance = root and (root.Position - part.Position).Magnitude or 0

			if distance < nearestDistance then
				nearestDistance = distance
				nearestCrate = crate
				nearestPart = part
			end
		end
	end

	return nearestCrate, nearestPart
end

function Items.TeleportToCrate()
	if not Teleport.CanTeleport(Items.TeleportDebounce) then
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart")

	if not root then
		createNotification("Meteor Crate", "Could not find your character.", "Error")
		return
	end

	local crate, part = Items.FindNearestCrate()
	if not crate or not part then
		createNotification("Meteor Crate", "No crates spawned yet.", "Warning")
		return
	end

	local targetPosition = part.Position + Vector3.new(0, (part.Size.Y / 2) + 4, 0)

	Teleport.MoveRoot(root, CFrame.new(targetPosition))
	Teleport.AddStrike()
	Teleport.StartFBlock()
	createNotification("Meteor Crate", "Teleported on top of the crate.", "Success")
end

function Items.StartCrateWatcher()
	workspace.DescendantAdded:Connect(function(object)
		task.defer(function()
			Items.TrackCrate(object, true)
		end)
	end)

	Items.RefreshCrates()
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

createSmallButton(mainList, "Get Code + Go Barn", function()
	Teleport.ToLocation("Barn", Vector3.new(477, 87, 318))
	createNotification("Code", "Searching...")

	task.spawn(function()
		local code = Main.GetPuzzleCode()
		createNotification("Code Found", code ~= "" and code or "No code found.", code ~= "" and "Success" or "Info")
	end)
end)

do
	local itemsDropdown = createSideDropdown(
		itemsList,
		"Item Teleports",
		updateItemsCanvas,
		"Shows available items and moves you to them."
	)

	do
		local warning = createWarningLabel(itemsDropdown, "DONT SPAM")
		warning.LayoutOrder = 0
	end

	do
		local dropdown = createSideDropdown(
			teleportList,
			"Map Locations",
			updateTeleportCanvas,
			"Moves you to a selected map location."
		)

		for _, location in ipairs(Teleport.Locations) do
			createSmallButton(dropdown, location.Name, function()
				Teleport.ToLocation(location.Name, location.Position)
			end)
		end
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
	if not toolName or not itemList then
		return false
	end

	local normalized = normalizeName(toolName)

	for _, itemName in ipairs(itemList) do
		if normalized == normalizeName(itemName) then
			return true
		end
	end

	return false
end

local function getItemDisplayName(object)
	return object.Name
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

	return Items.GetSearchDescendants()
end

local pinnedItemOrder = {
	"True Power",
	"Potion of Strength",
	"Bull's Essence",
	"Boba",
	"Speed Potion",
	"Frog Potion"
}

local PINNED_COLLECTION_SWITCH_PERCENT = 1
local searchAllItemsUnlocked = false
local pinnedItemsEverSeen = false

local function setItemSearchTargets(itemList)
	Items.SearchNameLookup = {}

	for _, itemName in ipairs(itemList) do
		Items.SearchNameLookup[normalizeName(itemName)] = true
	end

	Items.SearchCache = {}
	Items.LastSearchCacheAt = 0
	Items.RebuildSearchCache()
end

local function getPinnedCollectionProgress()
	local totalPinned = 0
	local leftPinned = 0

	for _, itemName in ipairs(pinnedItemOrder) do
		local leftCount = 0
		local totalCount = 0

		for _, object in ipairs(getCollectibleSearchPool()) do
			if itemNameMatches(object, itemName) then
				totalCount += 1

				if getLiveItemPart(object) then
					leftCount += 1
				end
			end
		end

		if totalCount > 0 then
			pinnedItemsEverSeen = true
		end

		totalPinned += totalCount
		leftPinned += leftCount
	end

	if totalPinned <= 0 then
		return pinnedItemsEverSeen and 1 or 0
	end

	return (totalPinned - leftPinned) / totalPinned
end

local function updateItemSearchMode()
	if searchAllItemsUnlocked then
		return
	end

	if getPinnedCollectionProgress() >= PINNED_COLLECTION_SWITCH_PERCENT then
		searchAllItemsUnlocked = true
		setItemSearchTargets(itemNames)
		createNotification("Items", "Most priority items collected. Searching all items now.", "Success")
	end
end

setItemSearchTargets(itemNames)

local function findLiveItemByName(wantedName)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil, nil, nil, nil, nil
	end

	local closestObject = nil
	local closestPart = nil
	local closestDistance = math.huge

	for _, object in ipairs(getCollectibleSearchPool()) do
		if itemNameMatches(object, wantedName) then
			local part = getLiveItemPart(object)

			if part and not isVisitedCollectPosition(part.Position) then
				local distance = (root.Position - part.Position).Magnitude

				if distance < closestDistance then
					closestDistance = distance
					closestObject = object
					closestPart = part
				end
			end
		end
	end

	if closestObject and closestPart then
		return wantedName, closestPart.CFrame, closestPart.Position, closestObject, closestPart
	end

	return nil, nil, nil, nil, nil
end

local function findNextCollectTarget()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil, nil, nil, nil, nil
	end

	local closestName = nil
	local closestPart = nil
	local closestObject = nil
	local closestDistance = math.huge

	for _, wantedName in ipairs(autoCollectPriority) do
		local itemName, _, _, itemObject, itemPart = findLiveItemByName(wantedName)

		if itemName and itemObject and itemPart then
			local distance = (root.Position - itemPart.Position).Magnitude

			if distance < closestDistance then
				closestDistance = distance
				closestName = itemName
				closestObject = itemObject
				closestPart = itemPart
			end
		end
	end

	if closestName and closestObject and closestPart then
		return closestName, closestPart.CFrame, closestPart.Position, closestObject, closestPart
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
		return true
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

		if not waitForTeleportReady() or not Teleport.CanTeleport() then
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
			local groundCFrame = Teleport.GetItemCFrame(itemPart, { character, itemObject })

			Teleport.MoveRoot(root, groundCFrame)
			Teleport.AddStrike()
			Teleport.StartFBlock()
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

local autoUseDropdown = createDropdown(itemsList, "Auto Items", updateItemsCanvas)

autoCollectToggle = createToggleButton(autoUseDropdown, "Auto Collect", false, function(state)
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
local autoHealEnabled = false
local autoHealThread = nil
local autoHealConnection = nil

local healingItems = {
	"Healing Potion",
	"Bandage",
	"First Aid Kit",
	"Apple"
}

local priorityHotbarItems = {
	"True Power",
	"Gravitation Shard",
	"Lightning Potion",
	"Forcefield Crystal",
	"Sphere of Fury",
	"Tomahawk"
}

local function getInventoryTools()
	local tools = {}
	local character = player.Character
	local backpack = player:FindFirstChild("Backpack")

	if character then
		for _, tool in ipairs(character:GetChildren()) do
			if tool:IsA("Tool") then
				table.insert(tools, tool)
			end
		end
	end

	if backpack then
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				table.insert(tools, tool)
			end
		end
	end

	return tools
end

local function getItemOrderRank(toolName, itemList)
	for index, itemName in ipairs(itemList) do
		if normalizeName(toolName) == normalizeName(itemName) then
			return index
		end
	end

	return nil
end

local function isLikelyGloveTool(tool)
	local name = normalizeName(tool.Name)

	if string.find(name, "glove") or string.find(name, "slap") then
		return true
	end

	return not matchesItem(tool.Name, itemNames)
end

local function getToolSortRank(tool)
	if isLikelyGloveTool(tool) then
		return 1
	end

	local priorityRank = getItemOrderRank(tool.Name, priorityHotbarItems)
	if priorityRank then
		return 10 + priorityRank
	end

	local healingRank = getItemOrderRank(tool.Name, healingItems)
	if healingRank then
		return 100 + healingRank
	end

	for index, itemName in ipairs(itemNames) do
		if normalizeName(tool.Name) == normalizeName(itemName) then
			return 50 + index
		end
	end

	return 80
end

local function sortInventory()
	local backpack = player:FindFirstChild("Backpack")

	if not backpack then
		createNotification("Inventory", "Backpack not found.", "Error")
		return
	end

	local tools = getInventoryTools()
	local holdingFolder = Instance.new("Folder")

	for _, tool in ipairs(tools) do
		tool.Parent = holdingFolder
	end

	table.sort(tools, function(left, right)
		local leftRank = getToolSortRank(left)
		local rightRank = getToolSortRank(right)

		if leftRank == rightRank then
			return left.Name < right.Name
		end

		return leftRank < rightRank
	end)

	for _, tool in ipairs(tools) do
		tool.Parent = backpack
		task.wait()
	end

	holdingFolder:Destroy()

	createNotification("Auto Sort", "Glove first, priority items next, healing grouped in backpack.", "Success")
end

do
	local button = createSmallButton(itemsList, "Auto Sort", function()
		sortInventory()
	end)

	button.LayoutOrder = -9500
end

do
	local button = createSmallButton(itemsList, "Meteor Crate", function()
		Items.TeleportToCrate()
	end)

	button.LayoutOrder = -9499
	Items.CrateButtonLabel = button:FindFirstChild("ButtonLabel")
	Items.RefreshCrates()
end

local function useTool(tool)
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not tool or not tool:IsA("Tool") then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	if tool.Parent == player.Backpack then
		humanoid:EquipTool(tool)
		task.wait(0.12)
	end

	if tool.Parent == character then
		local wasAnchored = root and root.Anchored or false

		if root then
			root.AssemblyAngularVelocity = Vector3.zero
			root.AssemblyLinearVelocity = Vector3.zero
			root.Anchored = true
		end

		pcall(function()
			tool:Activate()
		end)

		task.wait(0.08)

		if root then
			root.Anchored = wasAnchored
			root.AssemblyAngularVelocity = Vector3.zero
			root.AssemblyLinearVelocity = Vector3.zero
		end

		humanoid.PlatformStand = false
		humanoid.Sit = false
		humanoid:ChangeState(Enum.HumanoidStateType.Running)

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

local function runAutoHeal()
	while autoHealEnabled do
		tryAutoHeal()
		task.wait(0.35)
	end
end

local itemChecklistOrder = {}
local pinnedLookup = {}

for _, itemName in ipairs(pinnedItemOrder) do
	pinnedLookup[normalizeName(itemName)] = true
	table.insert(itemChecklistOrder, itemName)
end

for _, itemName in ipairs(itemNames) do
	if not pinnedLookup[normalizeName(itemName)] then
		table.insert(itemChecklistOrder, itemName)
	end
end

local ItemTeleportChecklist = {
	Rows = {},
	KnownTotals = {},
	Open = false
}

local function isItemBeingScanned(itemName)
	if searchAllItemsUnlocked then
		return true
	end

	return pinnedLookup[normalizeName(itemName)] == true
end

local function getItemCounts(itemName)
	local leftCount = 0
	local currentTotal = 0

	for _, object in ipairs(getCollectibleSearchPool()) do
		if itemNameMatches(object, itemName) then
			currentTotal += 1

			if getLiveItemPart(object) then
				leftCount += 1
			end
		end
	end

	local knownTotal = ItemTeleportChecklist.KnownTotals[itemName]

	if not knownTotal or currentTotal > knownTotal then
		knownTotal = currentTotal
		ItemTeleportChecklist.KnownTotals[itemName] = knownTotal
	end

	return leftCount, knownTotal or currentTotal
end

function Items.HasAvailableTeleportItems()
	return #itemChecklistOrder > 0
end

local function clearItemTeleportChecklist()
	for _, row in pairs(ItemTeleportChecklist.Rows) do
		if row and row.Parent then
			row:Destroy()
		end
	end

	ItemTeleportChecklist.Rows = {}
end

local function createItemChecklistRow(itemName, layoutOrder, showCount, leftCount, totalCount)
	local row = Instance.new("Frame")
	row.Name = normalizeName(itemName):gsub("%W", "") .. "ChecklistRow"
	row.Size = UDim2.new(1, -8, 0, 68)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.LayoutOrder = layoutOrder
	row.Parent = itemsDropdown

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -104, 0, 42)
	title.Position = UDim2.fromOffset(6, 0)
	title.BackgroundTransparency = 1
	if showCount and totalCount and totalCount > 0 then
		title.Text = "[" .. tostring(leftCount) .. "/" .. tostring(totalCount) .. "] " .. itemName
	else
		title.Text = itemName
	end
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 14
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextYAlignment = Enum.TextYAlignment.Center
	title.Parent = row
	themeObject(title, "TextColor3", "Text")

	local teleportButton = Instance.new("TextButton")
	teleportButton.Size = UDim2.new(0, 92, 0, 42)
	teleportButton.Position = UDim2.new(1, -98, 0, 0)
	teleportButton.Text = "Teleport"
	teleportButton.Font = Enum.Font.GothamBold
	teleportButton.TextSize = 13
	teleportButton.Parent = row
	themeObject(teleportButton, "BackgroundColor3", "ButtonDark")
	styleButton(teleportButton)

		teleportButton.MouseButton1Click:Connect(function()
		Items.TeleportTo(itemName)
	end)

	ItemTeleportChecklist.Rows[itemName] = row
end

local function createNoItemsRow(layoutOrder)
	local row = Instance.new("TextLabel")
	row.Name = "NoItemsFoundRow"
	row.Size = UDim2.new(1, -8, 0, 52)
	row.BackgroundTransparency = 1
	row.LayoutOrder = layoutOrder
	row.Text = "No items found"
	row.Font = Enum.Font.GothamBold
	row.TextSize = 14
	row.TextXAlignment = Enum.TextXAlignment.Center
	row.Parent = itemsDropdown
	themeObject(row, "TextColor3", "SubText")

	ItemTeleportChecklist.Rows.NoItemsFound = row
end

local function refreshItemTeleportChecklist()
	updateItemSearchMode()
	clearItemTeleportChecklist()

	local layoutOrder = 10
	local shown = 0

	for _, itemName in ipairs(itemChecklistOrder) do
		local showCount = isItemBeingScanned(itemName)
		local leftCount = nil
		local totalCount = nil
		local itemDetected = false

		if showCount then
			leftCount, totalCount = getItemCounts(itemName)
			itemDetected = leftCount and leftCount > 0
		else
			local _, _, _, itemObject, itemPart = findLiveItemByName(itemName)
			itemDetected = itemObject ~= nil and itemPart ~= nil
		end

		if itemDetected then
			createItemChecklistRow(itemName, layoutOrder, showCount, leftCount, totalCount)
			layoutOrder += 1
			shown += 1
		end
	end

	if shown == 0 then
		createNoItemsRow(layoutOrder)
	end
end

task.spawn(function()
	task.wait(0.25)

	while itemsDropdown and itemsDropdown.Parent do
		refreshItemTeleportChecklist()
		task.wait(0.35)
	end
end)

do
	local knownItemLookup = {}
	local notifiedDrops = {}

	for _, itemName in ipairs(itemChecklistOrder) do
		knownItemLookup[normalizeName(itemName)] = itemName
	end

	task.spawn(function()
		local firstScan = true

		while itemsDropdown and itemsDropdown.Parent do
			for _, object in ipairs(getCollectibleSearchPool()) do
				local itemName = knownItemLookup[normalizeName(getItemDisplayName(object))]

				if itemName and not notifiedDrops[object] and getLiveItemPart(object) then
					notifiedDrops[object] = true

					if not firstScan then
						createNotification(
							itemName .. " was dropped!",
							"Click to teleport.",
							"Success",
							function()
								Items.TeleportTo(itemName)
							end,
							10
						)
					end
				end
			end

			firstScan = false
			task.wait(1)
		end
	end)
end

do
	local toggle = createToggleButton(autoUseDropdown, "Auto Heal", false, function(state)
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

end

player.CharacterAdded:Connect(function()
	task.wait(0.25)

	if autoHealEnabled then
		hookAutoHealCharacter()
	end
end)

end

local Combat = {
	HitboxSize = 10,
	HitboxMinSize = 10,
	HitboxMaxSize = 25,
	HitboxTransparency = 0.7,
	HitboxColor = Color3.fromRGB(0, 170, 255),
	HitboxExpanded = false,
	HitboxVisible = true,
	SavedHitboxes = {},
	HitboxConnection = nil,
	AutoGloveTapEnabled = false,
	AutoGloveTapConnection = nil,
	AutoGloveTapDebounce = 0.08,
	LastAutoGloveTap = 0,
	KillPlayersBusy = false,
	KillPlayersCooldown = 10,
	KillPlayersNextAt = 0,
	KillPlayersStayTime = 1
}

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

	local character = otherPlayer.Character
	local humanoid = Combat.GetPlayerHumanoid(otherPlayer)
	if not humanoid or humanoid.Health <= 0 or Combat.IsRagdolledTarget(character, humanoid) then
		Combat.ResetHitbox(otherPlayer)
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
			local humanoid = Combat.GetPlayerHumanoid(otherPlayer)

			if humanoid and humanoid.Health > 0 then
				Combat.ApplyHitbox(otherPlayer)
			else
				Combat.ResetHitbox(otherPlayer)
			end
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
	if Combat.HitboxExpanded then
		Combat.StartHitboxLoop()

		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			local humanoid = Combat.GetPlayerHumanoid(otherPlayer)

			if humanoid and humanoid.Health > 0 then
				Combat.ApplyHitbox(otherPlayer)
			else
				Combat.ResetHitbox(otherPlayer)
			end
		end
	else
		Combat.StopHitboxLoop()
	end
end

function Combat.GetEquippedTool()
	local character = player.Character

	if not character then
		return nil
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") then
			return child
		end
	end

	return nil
end

function Combat.HasTruthyStatus(object, statusNames)
	if not object then
		return false
	end

	for _, statusName in ipairs(statusNames) do
		if object:GetAttribute(statusName) == true then
			return true
		end

		local statusObject = object:FindFirstChild(statusName)
		if statusObject then
			if statusObject:IsA("BoolValue") then
				if statusObject.Value == true then
					return true
				end
			else
				return true
			end
		end
	end

	return false
end

function Combat.IsRagdolledTarget(character, humanoid)
	local ragdollStatuses = {
		"Ragdoll",
		"Ragdolled",
		"IsRagdolled",
		"Knocked",
		"KnockedDown",
		"Downed"
	}

	if Combat.HasTruthyStatus(character, ragdollStatuses) or Combat.HasTruthyStatus(humanoid, ragdollStatuses) then
		return true
	end

	if humanoid.PlatformStand or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
		return true
	end

	local state = humanoid:GetState()
	return state == Enum.HumanoidStateType.FallingDown
		or state == Enum.HumanoidStateType.Physics
		or state == Enum.HumanoidStateType.GettingUp
end

function Combat.IsValidAutoTapTarget(targetPlayer)
	if targetPlayer == player then
		return nil, nil, nil
	end

	local character = targetPlayer.Character
	if not character then
		return nil, nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root or humanoid.Health <= 0 then
		return nil, nil, nil
	end

	if Combat.IsRagdolledTarget(character, humanoid) then
		return nil, nil, nil
	end

	return character, humanoid, root
end

function Combat.IsGlovePart(object)
	if not object:IsA("BasePart") then
		return false
	end

	local name = normalizeName(object.Name)
	return string.find(name, "glove")
		or string.find(name, "hand")
		or string.find(name, "handle")
end

function Combat.GetAutoGloveTapRadius()
	return math.max((Combat.HitboxSize / 2) + 4, 8)
end

function Combat.IsEnemyGloveInHitbox()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return false
	end

	local radius = Combat.GetAutoGloveTapRadius()
	local radiusSquared = radius * radius

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		local targetCharacter, _, targetRoot = Combat.IsValidAutoTapTarget(targetPlayer)

		if targetCharacter then
			local rootDelta = root.Position - targetRoot.Position
			if rootDelta:Dot(rootDelta) <= radiusSquared then
				return true
			end

			for _, object in ipairs(targetCharacter:GetDescendants()) do
				if Combat.IsGlovePart(object) then
					local gloveDelta = root.Position - object.Position
					if gloveDelta:Dot(gloveDelta) <= radiusSquared then
						return true
					end
				end
			end
		end
	end

	return false
end

function Combat.TapEquippedGlove()
	local now = os.clock()

	if now - Combat.LastAutoGloveTap < Combat.AutoGloveTapDebounce then
		return
	end

	Combat.LastAutoGloveTap = now

	local tool = Combat.GetEquippedTool()
	if tool then
		pcall(function()
			tool:Activate()
		end)
	end
end

function Combat.StartAutoGloveTap()
	if Combat.AutoGloveTapConnection then
		return
	end

	Combat.AutoGloveTapConnection = RunService.Heartbeat:Connect(function()
		if Combat.AutoGloveTapEnabled and Combat.IsEnemyGloveInHitbox() then
			Combat.TapEquippedGlove()
		end
	end)
end

function Combat.StopAutoGloveTap()
	if Combat.AutoGloveTapConnection then
		Combat.AutoGloveTapConnection:Disconnect()
		Combat.AutoGloveTapConnection = nil
	end
end

function Combat.SetAutoGloveTap(state)
	Combat.AutoGloveTapEnabled = state == true

	if Combat.AutoGloveTapEnabled then
		Combat.StartAutoGloveTap()
		createNotification("Auto Glove Tap", "Auto Glove Tap enabled.", "Success")
	else
		Combat.StopAutoGloveTap()
		createNotification("Auto Glove Tap", "Auto Glove Tap disabled.")
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

function Combat.GetValidPlayerTarget(targetPlayer)
	if not targetPlayer or targetPlayer == player then
		return nil, nil, nil
	end

	local character = targetPlayer.Character
	if not character then
		return nil, nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not root or humanoid.Health <= 0 then
		return nil, nil, nil
	end

	if Combat.IsRagdolledTarget(character, humanoid) then
		return nil, nil, nil
	end

	return character, humanoid, root
end

function Combat.StabilizeCharacter(character, root)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end

	if humanoid then
		humanoid.PlatformStand = false
		humanoid.Sit = false
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end

function Combat.FindStormPosition()
	local bestPosition = nil
	local bestDistance = math.huge
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local origin = root and root.Position or Vector3.zero

	for _, object in ipairs(workspace:GetDescendants()) do
		local name = normalizeName(object.Name)

		if string.find(name, "storm") or string.find(name, "zone") or string.find(name, "circle") then
			local cframe = nil

			if object:IsA("BasePart") then
				cframe = object.CFrame
			elseif object:IsA("Model") then
				cframe = object:GetPivot()
			end

			if cframe then
				local distance = (origin - cframe.Position).Magnitude

				if distance < bestDistance then
					bestDistance = distance
					bestPosition = cframe.Position
				end
			end
		end
	end

	return bestPosition
end

function Combat.AimRootAtPosition(root, lookPosition)
	if not root or not lookPosition then
		return
	end

	local flatTarget = Vector3.new(lookPosition.X, root.Position.Y, lookPosition.Z)
	if (flatTarget - root.Position).Magnitude < 1 then
		return
	end

	root.CFrame = CFrame.lookAt(root.Position, flatTarget)
	root.AssemblyAngularVelocity = Vector3.zero
end

function Combat.AimAtStorm(root)
	Combat.AimRootAtPosition(root, Combat.FindStormPosition())
end

function Combat.GetPlayerGroundCFrame(targetRoot, character, targetCharacter)
	local excludeInstances = { character }

	if targetCharacter then
		table.insert(excludeInstances, targetCharacter)
	end

	local lookVector = targetRoot.CFrame.LookVector
	local rightVector = targetRoot.CFrame.RightVector
	local velocity = targetRoot.AssemblyLinearVelocity or Vector3.zero
	local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
	local predictedPosition = targetRoot.Position

	if horizontalVelocity.Magnitude > 1 then
		predictedPosition += horizontalVelocity.Unit * math.min(horizontalVelocity.Magnitude * 0.25, 5)
	end

	local candidatePositions = {
		predictedPosition + (rightVector * 2.2),
		predictedPosition - (rightVector * 2.2),
		predictedPosition - (lookVector * 2),
		predictedPosition + (lookVector * 1.5),
		predictedPosition,
		targetRoot.Position + (rightVector * 2),
		targetRoot.Position - (rightVector * 2),
		targetRoot.Position
	}

	for _, candidatePosition in ipairs(candidatePositions) do
		local groundCFrame = Teleport.GetGroundCFrame(candidatePosition, excludeInstances, true)

		if (groundCFrame.Position - targetRoot.Position).Magnitude <= 7 then
			return groundCFrame
		end
	end

	return Teleport.GetGroundCFrame(targetRoot.Position, excludeInstances, true)
end

function Combat.GetKillPlayerCFrame(targetRoot, character, targetCharacter)
	local excludeInstances = { character }

	if targetCharacter then
		table.insert(excludeInstances, targetCharacter)
	end

	local velocity = targetRoot.AssemblyLinearVelocity or Vector3.zero
	local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
	local walkDirection = horizontalVelocity.Magnitude > 1 and horizontalVelocity.Unit or targetRoot.CFrame.LookVector
	local rightVector = targetRoot.CFrame.RightVector
	local leadPosition = targetRoot.Position + (walkDirection * 3.5)
	local candidatePositions = {
		leadPosition,
		leadPosition + (rightVector * 1.8),
		leadPosition - (rightVector * 1.8),
		targetRoot.Position + (walkDirection * 2.5),
		targetRoot.Position + (walkDirection * 4.5)
	}

	for _, candidatePosition in ipairs(candidatePositions) do
		local groundCFrame = Teleport.GetGroundCFrame(candidatePosition, excludeInstances, true)

		if (groundCFrame.Position - targetRoot.Position).Magnitude <= 8 then
			return CFrame.lookAt(groundCFrame.Position, Vector3.new(targetRoot.Position.X, groundCFrame.Position.Y, targetRoot.Position.Z))
		end
	end

	local fallback = Teleport.GetGroundCFrame(leadPosition, excludeInstances, true)
	return CFrame.lookAt(fallback.Position, Vector3.new(targetRoot.Position.X, fallback.Position.Y, targetRoot.Position.Z))
end

function Combat.TeleportToPlayer(targetPlayer)
	if not Teleport.CanTeleport() then
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)
	local targetCharacter, _, targetRoot = Combat.GetValidPlayerTarget(targetPlayer)

	if not root then
		createNotification("Players", "Could not find your character.", "Error")
		return
	end

	if not targetRoot then
		createNotification("Players", "Target player is unavailable or ragdolled.", "Warning")
		return
	end

	local targetCFrame = Combat.GetPlayerGroundCFrame(targetRoot, character, targetCharacter)

	Combat.StabilizeCharacter(character, root)
	Teleport.MoveRoot(root, targetCFrame)
	Combat.StabilizeCharacter(character, root)
	task.delay(0.15, function()
		if character.Parent and root.Parent then
			Combat.StabilizeCharacter(character, root)
		end
	end)
	Teleport.AddStrike()
	Teleport.StartFBlock()
	createNotification("Players", "Teleported to " .. targetPlayer.Name)
end

function Combat.TeleportToLowestHealthPlayer()
	local lowestPlayer = nil
	local lowestHealth = math.huge

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		local _, humanoid, targetRoot = Combat.GetValidPlayerTarget(targetPlayer)

		if humanoid and targetRoot and humanoid.Health < lowestHealth then
			lowestHealth = humanoid.Health
			lowestPlayer = targetPlayer
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
		local _, humanoid, targetRoot = Combat.GetValidPlayerTarget(targetPlayer)

		if humanoid and targetRoot then
			local distance = (root.Position - targetRoot.Position).Magnitude

			if distance < nearestDistance then
				nearestDistance = distance
				nearestPlayer = targetPlayer
			end
		end
	end

	if nearestPlayer then
		Combat.TeleportToPlayer(nearestPlayer)
	else
		createNotification("Players", "No valid nearest player found.")
	end
end

function Combat.GetKillPlayerTargets()
	local targets = {}

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		local _, humanoid, targetRoot = Combat.GetValidPlayerTarget(targetPlayer)

		if humanoid and targetRoot then
			table.insert(targets, {
				Player = targetPlayer,
				Health = humanoid.Health
			})
		end
	end

	table.sort(targets, function(left, right)
		if left.Health == right.Health then
			return left.Player.Name < right.Player.Name
		end

		return left.Health < right.Health
	end)

	return targets
end

function Combat.MoveToPlayerForKill(targetPlayer)
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)
	local targetCharacter, _, targetRoot = Combat.GetValidPlayerTarget(targetPlayer)

	if not root or not targetRoot then
		return false
	end

	local targetCFrame = Combat.GetKillPlayerCFrame(targetRoot, character, targetCharacter)

	Combat.StabilizeCharacter(character, root)
	Teleport.MoveRoot(root, targetCFrame)
	Combat.AimRootAtPosition(root, targetRoot.Position)
	Combat.StabilizeCharacter(character, root)
	task.delay(0.15, function()
		if character.Parent and root.Parent then
			Combat.StabilizeCharacter(character, root)
			Combat.AimRootAtPosition(root, targetRoot.Position)
		end
	end)
	Teleport.StartFBlock()
	return true
end

function Combat.StartKillPlayers()
	if Combat.KillPlayersBusy then
		createNotification("Kill Players", "Already running.", "Warning")
		return
	end

	local now = os.clock()
	if now < Combat.KillPlayersNextAt then
		local secondsLeft = math.ceil(Combat.KillPlayersNextAt - now)
		createNotification("Kill Players", "Wait " .. tostring(secondsLeft) .. " seconds before using this again.", "Warning")
		return
	end

	local targets = Combat.GetKillPlayerTargets()
	if #targets == 0 then
		createNotification("Kill Players", "No valid players found.", "Warning")
		return
	end

	Combat.KillPlayersBusy = true
	createNotification("Kill Players", "Cycling through " .. tostring(#targets) .. " players.", "Success")

	task.spawn(function()
		for _, target in ipairs(targets) do
			local targetPlayer = target.Player
			local _, humanoid, targetRoot = Combat.GetValidPlayerTarget(targetPlayer)

			if humanoid and targetRoot then
				if Combat.MoveToPlayerForKill(targetPlayer) then
					createNotification("Kill Players", "Teleported to " .. targetPlayer.Name)
					task.wait(Combat.KillPlayersStayTime)
				end
			end
		end

		Combat.KillPlayersBusy = false
		Combat.KillPlayersNextAt = os.clock() + Combat.KillPlayersCooldown
		createNotification("Kill Players", "Finished. Ready again in " .. tostring(Combat.KillPlayersCooldown) .. " seconds.", "Success")
	end)
end

function Combat.SetHitboxSize(newSize)
	Combat.HitboxSize = math.clamp(newSize, Combat.HitboxMinSize, Combat.HitboxMaxSize)

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

do
	local dropdown = createSideDropdown(
		teleportList,
		"Player Teleports",
		updateTeleportCanvas,
		"Moves you to a player based on health or distance."
	)

	createSmallButton(dropdown, "Teleport To Lowest Health", function()
		Combat.TeleportToLowestHealthPlayer()
	end)

	createSmallButton(dropdown, "Teleport To Nearest", function()
		Combat.TeleportToNearestPlayer()
	end)
end

local quickMenuHotkeysEnabled = false

local function hasAvailableTeleportItems()
	return Items.HasAvailableTeleportItems and Items.HasAvailableTeleportItems() or false
end

local function toggleSideDropdown(menuName)
	local menu = UI.SideDropdowns[menuName]

	if not menu then
		return
	end

	if menu.IsOpen and menu.IsOpen() then
		menu.Close()
	else
		UI.CloseActiveSideDropdown()
		menu.Open()
	end
end

local quickMenuHotkeysToggle = nil

if not isTouchDevice then
	quickMenuHotkeysToggle = createToggleButton(settingsList, "Quick Menu Hotkeys", false, function(state)
		quickMenuHotkeysEnabled = state
		createNotification("Hotkeys", state and "Quick menu hotkeys enabled." or "Quick menu hotkeys disabled.")
	end, "R opens items. Q opens players. G opens map locations.")

	UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
		if gameProcessed or not quickMenuHotkeysEnabled then
			return
		end

		if inputObject.KeyCode == Enum.KeyCode.R then
			if hasAvailableTeleportItems() then
				toggleSideDropdown("Item Teleports")
			else
				createNotification("Items", "No item teleports are currently available.")
			end
		elseif inputObject.KeyCode == Enum.KeyCode.Q then
			toggleSideDropdown("Player Teleports")
		elseif inputObject.KeyCode == Enum.KeyCode.G then
			toggleSideDropdown("Map Locations")
		end
	end)
end

if isTouchDevice then
	local mobileQuickDropdown = createDropdown(mainList, "Mobile Quick Menus", updateMainCanvas)

	createSmallButton(mobileQuickDropdown, "Open Item Teleports", function()
		if hasAvailableTeleportItems() then
			toggleSideDropdown("Item Teleports")
		else
			createNotification("Items", "No item teleports are currently available.")
		end
	end)

	createSmallButton(mobileQuickDropdown, "Open Player Teleports", function()
		toggleSideDropdown("Player Teleports")
	end)

	createSmallButton(mobileQuickDropdown, "Open Map Locations", function()
		toggleSideDropdown("Map Locations")
	end)
end

local expandHitboxToggle
local autoGloveTapToggle

do
	Combat.SetHitboxSize(Combat.HitboxSize)

	expandHitboxToggle = createToggleButton(combatList, "Expand Hitbox", false, function(state)
		Combat.HitboxExpanded = state
		Combat.RefreshHitboxes()
	end)

	createToggleButton(combatList, "Visualise Hitboxes", true, function(state)
		Combat.HitboxVisible = state

		if Combat.HitboxExpanded then
			Combat.RefreshHitboxes()
		end
	end)

	autoGloveTapToggle = createToggleButton(combatList, "Auto Glove Tap", false, function(state)
		Combat.SetAutoGloveTap(state)
	end)
end

do
	local dropdown = createDropdown(combatList, "Kill Players", updateCombatCanvas)

	createSmallButton(dropdown, "Start Kill Players", function()
		Combat.StartKillPlayers()
	end)
end

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
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not character or not head or not humanoid or humanoid.Health <= 0 then
		ESP.Remove(targetPlayer)
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
			local liveHumanoid = liveCharacter and liveCharacter:FindFirstChildOfClass("Humanoid")

			if not liveHumanoid or liveHumanoid.Health <= 0 then
				ESP.Remove(targetPlayer)
				break
			end

			local health = "?"
			health = math.floor(liveHumanoid.Health) .. "/" .. math.floor(liveHumanoid.MaxHealth)

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

local playerEspToggle = createToggleButton(mainList, "Player Stats ESP", false, function(state)
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

local antiAcidLavaToggle

do
	local dropdown = createDropdown(safetyList, "World Safety", updateSafetyCanvas)

	antiAcidLavaToggle = createToggleButton(dropdown, "Anti Acid & Lava", false, function(state)
		if state then
			Anti.EnableAcidLava()
			createNotification("Anti", "Anti Acid & Lava enabled.", "Success")
		else
			Anti.ClearParts()
			createNotification("Anti", "Anti Acid & Lava disabled.")
		end
	end)
end

createToggleButton(mainList, "Toggle recommended settings?", false, function(state)
	if playerEspToggle then
		playerEspToggle.Set(state, true)
	end

	if expandHitboxToggle then
		expandHitboxToggle.Set(state, true)
	end

	if autoGloveTapToggle then
		autoGloveTapToggle.Set(state, true)
	end

	if quickMenuHotkeysToggle then
		quickMenuHotkeysToggle.Set(state, true)
	end

	if antiAcidLavaToggle then
		antiAcidLavaToggle.Set(state, true)
	end

	createNotification(
		"Recommended Settings",
		state and "Recommended settings enabled." or "Recommended settings disabled.",
		state and "Success" or "Info"
	)
end, "Turns on ESP, hitbox, auto tap, teleport hotkeys, and anti acid/lava.")

do
	local dropdown = createDropdown(settingsList, "Themes", updateSettingsCanvas)

	for themeName in pairs(themes) do
		createSmallButton(dropdown, themeName, function()
			applyTheme(themeName)
		end)
	end
end

UI.CreateSlider(settingsList, "Window Transparency", 0, 0.45, UI.WindowTransparency, function(value)
	UI.WindowTransparency = value

	mainFrame.BackgroundTransparency = value
	tabScroll.BackgroundTransparency = value
	contentFrame.BackgroundTransparency = value
end)

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
	DidDragWindow = false,
	Minimized = false,
	DragStart = nil,
	ResizeStart = nil,
	StartPosition = nil,
	StartSize = nil,
	ResizeHandle = nil,
	Launcher = nil,
	LauncherScale = nil,
	LauncherDragging = false,
	LauncherDragStart = nil,
	LauncherStartPosition = nil,
	DidDragLauncher = false,
	LauncherSize = isTouchDevice and px(52) or px(58),
	DefaultReopenKey = Enum.KeyCode.T,
	ReopenKey = Enum.KeyCode.T,
	CustomKeybindsEnabled = false,
	WaitingForKeybind = false
}

local function isPointerBegin(inputObject)
	return inputObject.UserInputType == Enum.UserInputType.MouseButton1
		or inputObject.UserInputType == Enum.UserInputType.Touch
end

local function isPointerMove(inputObject)
	return inputObject.UserInputType == Enum.UserInputType.MouseMovement
		or inputObject.UserInputType == Enum.UserInputType.Touch
end

local function isPointerEnd(inputObject)
	return inputObject.UserInputType == Enum.UserInputType.MouseButton1
		or inputObject.UserInputType == Enum.UserInputType.Touch
end

function Window.StartDrag(inputObject)
	if not isPointerBegin(inputObject) then
		return
	end

	Window.Dragging = true
	Window.DidDragWindow = false
	Window.DragStart = inputObject.Position
	Window.StartPosition = mainFrame.Position
end

function Window.StopDrag(inputObject)
	if isPointerEnd(inputObject) then
		Window.Dragging = false
	end
end

function Window.StartResize(inputObject)
	if not isPointerBegin(inputObject) then
		return
	end

	Window.Resizing = true
	Window.ResizeStart = inputObject.Position
	Window.StartSize = mainFrame.Size
end

function Window.StopResize(inputObject)
	if isPointerEnd(inputObject) then
		Window.Resizing = false
	end
end

function Window.HandleInputChanged(inputObject)
	if not isPointerMove(inputObject) then
		return
	end

	if Window.Dragging and Window.DragStart and Window.StartPosition then
		local delta = inputObject.Position - Window.DragStart
		if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
			Window.DidDragWindow = true
		end

		mainFrame.Position = UDim2.new(
			Window.StartPosition.X.Scale,
			Window.StartPosition.X.Offset + delta.X,
			Window.StartPosition.Y.Scale,
			Window.StartPosition.Y.Offset + delta.Y
		)
	end

	if Window.LauncherDragging and Window.Launcher and Window.LauncherDragStart and Window.LauncherStartPosition then
		local delta = inputObject.Position - Window.LauncherDragStart
		if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
			Window.DidDragLauncher = true
		end

		Window.Launcher.Position = UDim2.fromOffset(
			Window.LauncherStartPosition.X.Offset + delta.X,
			Window.LauncherStartPosition.Y.Offset + delta.Y
		)
	end

	if Window.Resizing and Window.ResizeStart and Window.StartSize then
		local delta = inputObject.Position - Window.ResizeStart
		local viewport = getViewportSize()
		local minWidth = isTouchDevice and 292 or 460
		local minHeight = isTouchDevice and 270 or 300
		local maxWidth = math.max(minWidth, math.min(760, viewport.X - 16))
		local maxHeight = math.max(minHeight, math.min(560, viewport.Y - 28))
		local newWidth = math.clamp(Window.StartSize.X.Offset + delta.X, minWidth, maxWidth)
		local newHeight = math.clamp(Window.StartSize.Y.Offset + delta.Y, minHeight, maxHeight)

		mainFrame.Size = UDim2.fromOffset(newWidth, newHeight)
	end
end

function Window.StartLauncherDrag(inputObject)
	if not isPointerBegin(inputObject) or not Window.Launcher then
		return
	end

	Window.LauncherDragging = true
	Window.DidDragLauncher = false
	Window.LauncherDragStart = inputObject.Position
	Window.LauncherStartPosition = Window.Launcher.Position
end

function Window.StopLauncherDrag(inputObject)
	if isPointerEnd(inputObject) then
		Window.LauncherDragging = false
	end
end

function Window.GetLauncherPosition()
	local viewport = getViewportSize()
	local size = Window.LauncherSize
	local topPadding = isTouchDevice and 18 or 24

	return UDim2.fromOffset(
		math.max(14, math.floor((viewport.X - size) / 2)),
		topPadding
	)
end

function Window.GetLauncherCenterPosition()
	local position = Window.GetLauncherPosition()
	local halfSize = math.floor(Window.LauncherSize / 2)

	return UDim2.fromOffset(position.X.Offset + halfSize, position.Y.Offset + halfSize)
end

function Window.CreateLauncher()
	if Window.Launcher then
		return
	end

	Window.Launcher = Instance.new("TextButton")
	Window.Launcher.Name = "OPSlapLauncher"
	Window.Launcher.Size = UDim2.fromOffset(Window.LauncherSize, Window.LauncherSize)
	Window.Launcher.Position = Window.GetLauncherPosition()
	Window.Launcher.AnchorPoint = Vector2.new(0, 0)
	Window.Launcher.BackgroundTransparency = 0.02
	Window.Launcher.BorderSizePixel = 0
	Window.Launcher.Text = ""
	Window.Launcher.AutoButtonColor = false
	Window.Launcher.Visible = false
	Window.Launcher.Parent = gui
	themeObject(Window.Launcher, "BackgroundColor3", "Panel")
	addCorner(Window.Launcher, 100)

	do
		local stroke = addStroke(Window.Launcher, currentTheme.Stroke, 2)
		stroke.Transparency = 0.12
		themeObject(stroke, "Color", "Stroke")
	end

	do
		local glow = Instance.new("UIStroke")
		glow.Thickness = 6
		glow.Transparency = 0.7
		glow.Parent = Window.Launcher
		themeObject(glow, "Color", "Stroke")
	end

	Window.LauncherScale = Instance.new("UIScale")
	Window.LauncherScale.Scale = 0
	Window.LauncherScale.Parent = Window.Launcher

	do
		local logo = Instance.new("TextLabel")
		logo.Name = "Logo"
		logo.Size = UDim2.fromOffset(Window.LauncherSize - 16, Window.LauncherSize - 16)
		logo.Position = UDim2.fromOffset(8, 5)
		logo.BackgroundTransparency = 1
		logo.Text = "OP"
		logo.Font = Enum.Font.GothamBlack
		logo.TextSize = isTouchDevice and 16 or 18
		logo.TextXAlignment = Enum.TextXAlignment.Center
		logo.TextYAlignment = Enum.TextYAlignment.Center
		logo.Parent = Window.Launcher
		themeObject(logo, "TextColor3", "Button")
	end

	do
		local hint = Instance.new("TextLabel")
		hint.Size = UDim2.new(1, 0, 0, 16)
		hint.Position = UDim2.new(0, 0, 1, -19)
		hint.BackgroundTransparency = 1
		hint.Text = "OPEN"
		hint.Font = Enum.Font.GothamBlack
		hint.TextSize = 8
		hint.TextXAlignment = Enum.TextXAlignment.Center
		hint.Parent = Window.Launcher
		themeObject(hint, "TextColor3", "SubText")
	end

	Window.Launcher.InputBegan:Connect(Window.StartLauncherDrag)
	Window.Launcher.InputEnded:Connect(Window.StopLauncherDrag)

	Window.Launcher.MouseButton1Click:Connect(function()
		if not Window.DidDragLauncher then
			Window.Open()
		end
	end)
end

function Window.ShowLauncher()
	Window.CreateLauncher()

	Window.Launcher.Position = Window.GetLauncherPosition()
	Window.Launcher.Visible = true
	Window.Launcher.BackgroundTransparency = 0.22
	Window.LauncherScale.Scale = 0

	TweenService:Create(
		Window.LauncherScale,
		TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Scale = 1 }
	):Play()

	TweenService:Create(
		Window.Launcher,
		TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 0.02 }
	):Play()
end

function Window.HideLauncher()
	if not Window.Launcher or not Window.Launcher.Visible then
		return
	end

	TweenService:Create(
		Window.LauncherScale,
		TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
		{ Scale = 0.72 }
	):Play()

	local tween = TweenService:Create(
		Window.Launcher,
		TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
		{ BackgroundTransparency = 0.5 }
	)

	tween:Play()
	tween.Completed:Connect(function()
		if Window.Launcher and not Window.Minimized then
			Window.Launcher.Visible = false
		end
	end)
end

function Window.Minimize()
	if Window.Minimized then
		return
	end

	UI.CloseAllDropdowns()
	Window.Minimized = true
	normalSize = mainFrame.Size
	minimizedSize = getMinimizedSize()

	tabScroll.Visible = false
	contentFrame.Visible = false
	Window.ResizeHandle.Visible = false

	local targetPosition = Window.GetLauncherCenterPosition()
	local tween = tweenWindow(UDim2.fromOffset(Window.LauncherSize, Window.LauncherSize), targetPosition, 0.28)

	TweenService:Create(
		mainFrame,
		TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
		{ BackgroundTransparency = 0.35 }
	):Play()

	tween.Completed:Connect(function()
		if Window.Minimized then
			mainFrame.Visible = false
			Window.ShowLauncher()
		end
	end)

	createNotification(
		"Menu Minimized",
		isTouchDevice and "Tap the OP circle to open the menu again." or ("Press " .. ((Window.CustomKeybindsEnabled and Window.ReopenKey or Window.DefaultReopenKey).Name) .. " or click the OP circle to open the menu again."),
		"Info"
	)
end

function Window.Open()
	if not Window.Minimized then
		return
	end

	Window.Minimized = false
	Window.HideLauncher()

	mainFrame.Visible = true
	mainFrame.Size = UDim2.fromOffset(Window.LauncherSize, Window.LauncherSize)
	mainFrame.Position = Window.GetLauncherCenterPosition()
	mainFrame.BackgroundTransparency = UI.WindowTransparency

	tweenWindow(normalSize, getOpenWindowPosition(), 0.38)

	task.delay(0.15, function()
		if not Window.Minimized then
			tabScroll.Visible = true
			contentFrame.Visible = true
			Window.ResizeHandle.Visible = not isTouchDevice
		end
	end)
end

function Window.ToggleMinimized()
	if Window.Minimized then
		Window.Open()
	else
		Window.Minimize()
	end
end

function Window.ResetPosition()
	UI.CloseAllDropdowns()
	normalSize = getWindowSize()
	mainFrame.Visible = true
	mainFrame.Size = normalSize
	mainFrame.Position = getOpenWindowPosition()
	mainFrame.BackgroundTransparency = UI.WindowTransparency

	if Window.Minimized then
		Window.Minimized = false
		Window.HideLauncher()
	end

	tabScroll.Visible = true
	contentFrame.Visible = true

	if Window.ResizeHandle then
		Window.ResizeHandle.Visible = not isTouchDevice
	end
end

Window.ResizeHandle = Instance.new("TextButton")
Window.ResizeHandle.Size = isTouchDevice and UDim2.fromOffset(32, 32) or UDim2.fromOffset(28, 28)
Window.ResizeHandle.Position = isTouchDevice and UDim2.new(1, -39, 1, -39) or UDim2.new(1, -35, 1, -35)
Window.ResizeHandle.Text = "+"
Window.ResizeHandle.Font = Enum.Font.GothamBlack
Window.ResizeHandle.TextSize = 17
Window.ResizeHandle.Active = true
Window.ResizeHandle.Visible = not isTouchDevice
Window.ResizeHandle.Parent = mainFrame
themeObject(Window.ResizeHandle, "BackgroundColor3", "Button")
styleButton(Window.ResizeHandle)

topBar.InputBegan:Connect(Window.StartDrag)
topBar.InputEnded:Connect(Window.StopDrag)
minimizeButton.InputBegan:Connect(Window.StartDrag)
minimizeButton.InputEnded:Connect(Window.StopDrag)

Window.ResizeHandle.InputBegan:Connect(Window.StartResize)
Window.ResizeHandle.InputEnded:Connect(Window.StopResize)

UserInputService.InputChanged:Connect(Window.HandleInputChanged)

minimizeButton.MouseButton1Click:Connect(function()
	if not Window.DidDragWindow then
		Window.ToggleMinimized()
	end
end)

UserInputService.InputBegan:Connect(function(inputObject, gameProcessed)
	if gameProcessed or UserInputService:GetFocusedTextBox() then
		return
	end

	if isTouchDevice then
		return
	end

	if Window.WaitingForKeybind and inputObject.KeyCode ~= Enum.KeyCode.Unknown then
		Window.ReopenKey = inputObject.KeyCode
		Window.CustomKeybindsEnabled = true
		Window.WaitingForKeybind = false
		createNotification("Keybind", "Menu key set to " .. inputObject.KeyCode.Name .. ".", "Success")
		return
	end

	local reopenKey = Window.CustomKeybindsEnabled and Window.ReopenKey or Window.DefaultReopenKey

	if inputObject.KeyCode == reopenKey then
		Window.ToggleMinimized()
	end
end)

closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

local function applyResponsiveWindow()
	applyMobileMetrics()
	rootScale.Scale = getUIScale()
	Window.LauncherSize = isTouchDevice and px(52) or px(58)

	if Window.Minimized then
		minimizedSize = getMinimizedSize()
		mainFrame.Size = UDim2.fromOffset(Window.LauncherSize, Window.LauncherSize)
		mainFrame.Position = Window.GetLauncherCenterPosition()

		if Window.Launcher then
			Window.Launcher.Size = UDim2.fromOffset(Window.LauncherSize, Window.LauncherSize)
			Window.Launcher.Position = Window.GetLauncherPosition()
		end

		if Notify.RefreshLayout then
			Notify.RefreshLayout()
		end
		return
	end

	local viewport = getViewportSize()
	sideTabWidth = viewport.X < 420 and 70 or 88
	contentLeftOffset = 9
	normalSize = getWindowSize()
	mainFrame.Size = normalSize
	mainFrame.Position = getOpenWindowPosition()
	tabScroll.Size = UDim2.new(1, -18, 0, 50)
	tabScroll.Position = UDim2.fromOffset(9, 61)
	contentFrame.Size = UDim2.new(1, -18, 1, -122)
	contentFrame.Position = UDim2.fromOffset(contentLeftOffset, 116)
	tabScroll.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X + 20, 0)

	if Notify.RefreshLayout then
		Notify.RefreshLayout()
	end

	if UI.ActiveSideDropdown and UI.ActiveSideDropdown.Reposition then
		UI.ActiveSideDropdown.Reposition()
	end
end

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		applyResponsiveWindow()
	end)
end

selectTab("Main")
applyTheme("Neon Orchid")
Items.StartCrateWatcher()

tabScroll.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X + 20, 0)
updateMainCanvas()
updateItemsCanvas()
updateTeleportCanvas()
updateCombatCanvas()
updateSafetyCanvas()
updateSettingsCanvas()
