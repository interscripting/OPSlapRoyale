local Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	TweenService = game:GetService("TweenService"),
	UserInputService = game:GetService("UserInputService"),
	MarketplaceService = game:GetService("MarketplaceService"),
	ContextActionService = game:GetService("ContextActionService"),
	CollectionService = game:GetService("CollectionService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	TeleportService = game:GetService("TeleportService"),
	GuiService = game:GetService("GuiService"),
	ProximityPromptService = game:GetService("ProximityPromptService"),
	HttpService = game:GetService("HttpService")
}

local Players = Services.Players
local RunService = Services.RunService
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local MarketplaceService = Services.MarketplaceService
local ContextActionService = Services.ContextActionService
local ReplicatedStorage = Services.ReplicatedStorage
local ProximityPromptService = Services.ProximityPromptService
local HttpService = Services.HttpService
local player = Players.LocalPlayer

local UNDER_MAP_PLATFORM_Y = -35
local UNDER_MAP_PLATFORM_THICKNESS = 0.2
local UNDER_MAP_SAFE_OFFSET = 4
local UNDER_MAP_PLATFORM_SIZE = Vector3.new(12000, UNDER_MAP_PLATFORM_THICKNESS, 12000)
local UnderMapSafetyPlatform = nil

local function isUnderMapSafetyPlatform(object)
	return object:IsA("BasePart")
		and object.Name == "Part"
		and object.Transparency >= 1
		and object.Anchored
		and math.abs(object.Position.Y - UNDER_MAP_PLATFORM_Y) <= 1
		and object.Size.X >= UNDER_MAP_PLATFORM_SIZE.X * 0.9
		and object.Size.Z >= UNDER_MAP_PLATFORM_SIZE.Z * 0.9
end

local function clearUnderMapSafetyPlatform()
	if UnderMapSafetyPlatform and UnderMapSafetyPlatform.Parent then
		UnderMapSafetyPlatform:Destroy()
	end

	for _, object in ipairs(workspace:GetChildren()) do
		if isUnderMapSafetyPlatform(object) then
			object:Destroy()
		end
	end

	UnderMapSafetyPlatform = nil
end

local function ensureUnderMapSafetyPlatform()
	if UnderMapSafetyPlatform and UnderMapSafetyPlatform.Parent then
		return UnderMapSafetyPlatform
	end

	for _, object in ipairs(workspace:GetChildren()) do
		if isUnderMapSafetyPlatform(object) then
			UnderMapSafetyPlatform = object
			return object
		end
	end

	local platform = Instance.new("Part")
	platform.Name = "Part"
	platform.Size = UNDER_MAP_PLATFORM_SIZE
	platform.Position = Vector3.new(0, UNDER_MAP_PLATFORM_Y, 0)
	platform.Anchored = true
	platform.CanCollide = true
	platform.CanTouch = false
	platform.CanQuery = false
	platform.Transparency = 1
	platform.Material = Enum.Material.SmoothPlastic
	platform.Parent = workspace

	UnderMapSafetyPlatform = platform
	return platform
end

local sharedEnvironment = nil
do
	local success, environment = pcall(function()
		return type(getgenv) == "function" and getgenv() or nil
	end)

	if success and type(environment) == "table" then
		sharedEnvironment = environment

		if type(sharedEnvironment.OPSlapRoyaleCleanup) == "function" then
			pcall(sharedEnvironment.OPSlapRoyaleCleanup)
		end

		sharedEnvironment.OPSlapRoyaleCleanup = nil
	end
end

clearUnderMapSafetyPlatform()

local SCHOOL_BUS_CLEANUP_POSITION = Vector3.new(494, 47, -322)
local SCHOOL_BUS_CLEANUP_RADIUS = 220

local function isPlayerCharacterDescendant(object)
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		local character = targetPlayer.Character

		if character and object:IsDescendantOf(character) then
			return true
		end
	end

	return false
end

local function getObjectWorldPosition(object)
	if object:IsA("BasePart") then
		return object.Position
	end

	if object:IsA("Model") then
		local ok, pivot = pcall(function()
			return object:GetPivot()
		end)

		if ok and pivot then
			return pivot.Position
		end

		local boxOk, cframe = pcall(function()
			return object:GetBoundingBox()
		end)

		if boxOk and cframe then
			return cframe.Position
		end
	end

	return nil
end

local function getChairCleanupCandidate(object)
	if not object or not object.Parent or isPlayerCharacterDescendant(object) then
		return nil
	end

	local current = object
	local candidate = nil
	local busRelated = false

	while current and current ~= workspace do
		local lowerName = string.lower(current.Name)

		if string.find(lowerName, "bus", 1, true) then
			busRelated = true
			break
		end

		if current:IsA("Seat")
			or current:IsA("VehicleSeat")
			or ((string.find(lowerName, "chair", 1, true)
				or string.find(lowerName, "seat", 1, true)
				or string.find(lowerName, "stool", 1, true)
				or string.find(lowerName, "bench", 1, true))
				and (current:IsA("Model") or current:IsA("BasePart"))) then
			candidate = current
		end

		current = current.Parent
	end

	if busRelated then
		return nil
	end

	return candidate
end

local function hasChairCleanupHint(object)
	if not object then
		return false
	end

	local lowerName = string.lower(object.Name)

	return object:IsA("Seat")
		or object:IsA("VehicleSeat")
		or string.find(lowerName, "chair", 1, true) ~= nil
		or string.find(lowerName, "seat", 1, true) ~= nil
		or string.find(lowerName, "stool", 1, true) ~= nil
		or string.find(lowerName, "bench", 1, true) ~= nil
end

local function cleanupChairs()
	local removed = {}
	local removedCount = 0
	local scanned = 0
	local queue = workspace:GetChildren()
	local index = 1

	while index <= #queue do
		local object = queue[index]
		index += 1

		for _, child in ipairs(object:GetChildren()) do
			table.insert(queue, child)
		end

		local candidate = getChairCleanupCandidate(object)

		if candidate and candidate.Parent and not removed[candidate] then
			removed[candidate] = true
			removedCount += 1

			pcall(function()
				candidate:Destroy()
			end)
		end

		scanned += 1

		if scanned % 150 == 0 then
			task.wait(0.03)
		end
	end

	return removedCount
end

local function getSchoolBusCleanupCandidate(object)
	local current = object
	local candidate = nil

	while current and current ~= workspace do
		local lowerName = string.lower(current.Name)

		if string.find(lowerName, "bus", 1, true) and (current:IsA("Model") or current:IsA("BasePart")) then
			candidate = current
		end

		current = current.Parent
	end

	return candidate
end

local function cleanupSchoolBusNearSchoolHouse()
	local removed = {}
	local ok, nearbyParts = pcall(function()
		return workspace:GetPartBoundsInBox(
			CFrame.new(SCHOOL_BUS_CLEANUP_POSITION),
			Vector3.new(SCHOOL_BUS_CLEANUP_RADIUS * 2, 160, SCHOOL_BUS_CLEANUP_RADIUS * 2)
		)
	end)

	if not ok then
		return false
	end

	for _, object in ipairs(nearbyParts) do
		local candidate = getSchoolBusCleanupCandidate(object)

		if candidate and candidate.Parent and not removed[candidate] then
			local position = getObjectWorldPosition(candidate)

			if position and (position - SCHOOL_BUS_CLEANUP_POSITION).Magnitude <= SCHOOL_BUS_CLEANUP_RADIUS then
				removed[candidate] = true
				pcall(function()
					candidate:Destroy()
				end)
				return true
			end
		end
	end

	return false
end

task.spawn(function()
	local chairCleanupEndsAt = os.clock() + 20
	local chairAddedConnection = nil

	chairAddedConnection = workspace.DescendantAdded:Connect(function(object)
		if os.clock() > chairCleanupEndsAt then
			if chairAddedConnection then
				chairAddedConnection:Disconnect()
				chairAddedConnection = nil
			end

			return
		end

		if not hasChairCleanupHint(object) then
			return
		end

		task.defer(function()
			local candidate = getChairCleanupCandidate(object)

			if candidate and candidate.Parent then
				pcall(function()
					candidate:Destroy()
				end)
			end
		end)
	end)

	task.delay(20, function()
		if chairAddedConnection then
			chairAddedConnection:Disconnect()
			chairAddedConnection = nil
		end
	end)

	cleanupChairs()
	cleanupSchoolBusNearSchoolHouse()
end)

local Settings = nil
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

pcall(function()
	local playerGui = player:WaitForChild("PlayerGui", 5)

	if playerGui then
		for _, existingGui in ipairs(playerGui:GetChildren()) do
			if existingGui.Name == "OPSlapRoyaleUI" then
				existingGui:Destroy()
			end
		end
	end
end)

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
	BETA = "🧪",
	["Get Code + Go Barn"] = "🔢",
	["Early Bus Jump"] = "BUS",
	["Auto Rejoin"] = "JOIN",
	["Quick Teleports"] = "⚡",
	["Mobile Quick Menus"] = "📱",
	["Map Locations"] = "🗺️",
	["Item Teleports"] = "🎁",
	["Player Teleports"] = "👤",
	["Auto Items"] = "🤖",
	["Auto Heal"] = "❤️",
["Auto Sort"] = "🎒",
["Auto Use Permanent Items"] = "⚡",
["Meteor Crate"] = "📦",
	Hitboxes = "🎯",
["Hitbox Size"] = "📏",
["Expand Hitbox"] = "📦",
["Visualize Hitboxes"] = "✨",
["Player TP Buttons"] = "📍",
["Increase Glove Size"] = "🧤",
["Auto Slap"] = "👊",
	["Glove TP Slap"] = "🎯",
	["Collect Crates"] = "📦",
	["Anti-Ragdoll"] = "🧱",
	["Player Stats ESP"] = "📊",
	["Item ESP"] = "💎",
	["World Safety"] = "🚧",
	["Anti-Acid & Lava"] = "🔥",
	["Anti-Staff"] = "🕵️",
	["Themes"] = "🎨",
	["Cycle Theme"] = "🔁",
	["Disable Notifications"] = "🔕",
	["Window Transparency"] = "🪟",
	["Quick Menu Hotkeys"] = "⌨️",
	["Toggle recommended settings?"] = "⭐",
	["Teleport To Lowest Health"] = "🩹",
	["Teleport To Nearest"] = "📍",
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
	BETA = "Experimental combat tools.",
	["Quick Teleports"] = "Pinned locations for fast map movement.",
	["Mobile Quick Menus"] = "Touch shortcuts for menus that use hotkeys on PC.",
	["Auto Items"] = "Automatic item use and collection controls.",
	Hitboxes = "Adjust hitbox size, visibility, and expansion from one panel.",
	["Increase Glove Size"] = "Drag to resize your currently equipped glove.",
	["World Safety"] = "Invisible protection over danger zones.",
	["Themes"] = "Switch the full menu color profile.",
	["Theme Creator"] = "Tune the accent color for your current theme.",
	["Get Code + Go Barn"] = "Moves to barn, scans puzzle assets, and reports the code.",
	["Early Bus Jump"] = "Auto-fires bus jump when the script detects your character inside the bus.",
	["Early Auto Collect"] = "Starts collecting at timer 3; after Early Bus Jump, waits 10 seconds before collecting.",
	["Auto Rejoin"] = "Teleports to place 9426795465 when you die or a disconnect prompt appears.",
	["Infinite jump"] = "Lets each manual jump request jump again while in the air.",
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
UI.CreatePage("BETA")
UI.CreatePage("Safety")
UI.CreatePage("Settings")

function UI.ApplyTheme(themeName)
	if not themes[themeName] then
		return
	end

	currentTheme = themes[themeName]
	UI.CurrentThemeName = themeName

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
UI.CreateTab("BETA")
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
UI.CreatePageTitle(UI.Pages.BETA, "BETA")
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
local betaList, updateBetaCanvas = UI.CreatePageList(UI.Pages.BETA)
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

	local function setValue(newValue, runCallback)
		value = math.clamp(newValue, minValue, maxValue)
		local percent = (value - minValue) / (maxValue - minValue)
		fill.Size = UDim2.fromScale(math.clamp(percent, 0, 1), 1)
		label.Text = text .. ": " .. tostring(math.floor(value * 100 + 0.5)) .. "%"

		if runCallback then
			callback(value)

			if Settings and Settings.OnControlChanged then
				Settings.OnControlChanged()
			end
		end
	end

	local function setValueFromX(x)
		local percent = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		value = minValue + ((maxValue - minValue) * percent)
		setValue(value, true)
	end

	local function refresh()
		setValue(value, true)
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
	local control = {
		Holder = holder,
		Set = setValue,
		Get = function()
			return value
		end
	}

	if Settings and Settings.RegisterSlider then
		Settings.RegisterSlider(text, control)
	end

	return control
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
	["Early Auto Collect"] = "Starts at timer 3, but waits 10 seconds after Early Bus Jump before collecting.",
	["Auto pick up"] = "Creates an invisible pickup zone around you and presses pickup while items touch it.",
	["Auto Heal"] = "Uses healing tools when health drops below the set threshold.",
	["Auto Sort"] = "Keeps your glove first, priority items next, and healing items grouped.",
["Auto Use Permanent Items"] = "Uses permanent boost items shortly after they enter your inventory.",
["Expand Hitbox"] = "Applies your selected hitbox size to other players.",
["Visualize Hitboxes"] = "Toggles the neon hitbox preview on or off.",
["Player TP Buttons"] = "Shows big Teleport buttons above players that safely teleport you to them.",
["Increase Glove Size"] = "Drag to resize your currently equipped glove.",
	["Auto Slap"] = "Automatically slaps when another player's glove enters your hitbox.",
	["Glove TP Slap"] = "When your equipped glove slaps, teleports you to the nearest player.",
	["Collect Crates"] = "When your equipped glove slaps, sends only the glove to a spawned meteor crate.",
	["Anti-Ragdoll"] = "Briefly boxes your character in when ragdoll or knockback is detected.",
	["Player Stats ESP"] = "Shows health, kills, strength, and speed above players.",
	["Item ESP"] = "Highlights real item drops by category color with matching name tags.",
	["Anti-Acid & Lava"] = "Deletes hazard parts with acid, lava, kill, damage, or death names.",
	["Hide under map"] = "Moves you straight below the map, then back to safe land above you.",
	["Anti-Staff"] = "Leaves the server when chat suggests recording, proof, or staff attention.",
	["Quick Menu Hotkeys"] = "Enables R, Q, and G shortcuts for the quick menus.",
	["Disable Notifications"] = "Silences regular popups while keeping urgent cooldown warnings visible.",
	["Early Bus Jump"] = "Automatically fires bus jump once when your character is detected inside the bus.",
	["Auto Rejoin"] = "Teleports to place 9426795465 when you die or a disconnect prompt appears.",
	["Infinite jump"] = "Lets each manual jump request jump again while in the air.",
	["Toggle recommended settings?"] = "Turns on ESP, hitbox, Auto Slap, hotkeys, and safety."
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
		state = newState == true

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
			local success, errorMessage = pcall(function()
				callback(state)
			end)

			if not success then
				Notify.Show("Toggle Error", tostring(errorMessage), "Error", nil, 3, true)
			end
		end

		if runCallback and Settings and Settings.OnControlChanged then
			Settings.OnControlChanged()

			if Settings.SaveNow and not Settings.Loading and Settings.Ready then
				Settings.SaveDirty = false
				Settings.SaveNow()
			end
		end
	end

	button.MouseButton1Click:Connect(function()
		setState(not state, true)
	end)

	setState(state, false)

	local control = {
		Button = button,
		Label = label,
		Description = descriptionLabel,
		Set = setState,
		Get = function()
			return state
		end
	}

	if Settings and Settings.RegisterToggle and text ~= "Toggle recommended settings?" and text ~= "Hide under map" then
		Settings.RegisterToggle(text, control)
	end

	return control
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
local Combat = nil

Settings = {
	Folder = "OPSlapRoyale",
	FileName = "OPSlapRoyale/settings.json",
	Version = 1,
	Controls = {},
	Ready = false,
	Loading = false,
	SaveQueued = false,
	SaveDirty = false
}

function Settings.HasFileSupport()
	return type(readfile) == "function" and type(writefile) == "function"
end

function Settings.EnsureFolder()
	if type(makefolder) == "function" and type(isfolder) == "function" then
		local ok, exists = pcall(function()
			return isfolder(Settings.Folder)
		end)

		if ok and not exists then
			pcall(function()
				makefolder(Settings.Folder)
			end)
		end
	end
end

function Settings.Read()
	if not Settings.HasFileSupport() or (type(isfile) == "function" and not isfile(Settings.FileName)) then
		return {}
	end

	local success, contents = pcall(function()
		return readfile(Settings.FileName)
	end)

	if not success or type(contents) ~= "string" or contents == "" then
		return {}
	end

	local decodeSuccess, data = pcall(function()
		return HttpService:JSONDecode(contents)
	end)

	if decodeSuccess and type(data) == "table" then
		return data
	end

	return {}
end

function Settings.Write(data)
	if not Settings.HasFileSupport() then
		return false
	end

	Settings.EnsureFolder()

	local encodeSuccess, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)

	if not encodeSuccess then
		return false
	end

	return pcall(function()
		writefile(Settings.FileName, encoded)
	end)
end

function Settings.RegisterToggle(name, control)
	if name and control then
		Settings.Controls[name] = control
	end

	return control
end

function Settings.RegisterSlider(name, control)
	return Settings.RegisterToggle(name, control)
end

function Settings.Capture()
	local toggles = {}

	for name, control in pairs(Settings.Controls) do
		if control and control.Get then
			local success, value = pcall(control.Get)

			if success then
				if name ~= "Hide under map" and name ~= "Early Auto Collect" then
					toggles[name] = value
				end
			end
		end
	end

	return {
		Version = Settings.Version,
		Theme = UI.CurrentThemeName or "Neon Orchid",
		Toggles = toggles,
		HitboxSize = Combat and Combat.HitboxSize or nil,
		GloveSizeScale = Combat and Combat.GloveSizeScale or nil,
		WindowTransparency = UI.WindowTransparency
	}
end

function Settings.SaveNow()
	if Settings.Loading or not Settings.Ready then
		return
	end

	Settings.Write(Settings.Capture())
end

function Settings.OnControlChanged()
	if Settings.Loading or not Settings.Ready then
		return
	end

	Settings.SaveDirty = true

	if Settings.SaveQueued then
		return
	end

	Settings.SaveQueued = true

	task.delay(0.35, function()
		Settings.SaveQueued = false

		if Settings.SaveDirty then
			Settings.SaveDirty = false
			Settings.SaveNow()
		end
	end)
end

function Settings.Apply(data)
	if type(data) ~= "table" then
		return
	end

	Settings.Loading = true

	if type(data.Theme) == "string" and themes[data.Theme] then
		applyTheme(data.Theme)
	end

	if type(data.HitboxSize) == "number" and Combat then
		Combat.SetHitboxSize(data.HitboxSize)
	end

	if type(data.GloveSizeScale) == "number" and Combat then
		Combat.SetGloveSizeScale(data.GloveSizeScale, false)
	end

	local toggles = type(data.Toggles) == "table" and data.Toggles or {}
	if toggles["Auto Glove Tap"] ~= nil and toggles["Auto Slap"] == nil then
		toggles["Auto Slap"] = toggles["Auto Glove Tap"]
	end

	toggles["Auto Glove Tap"] = nil
	toggles["Hide under map"] = nil
	toggles["Early Auto Collect"] = nil

	for name, value in pairs(toggles) do
		local control = Settings.Controls[name]

		if control and control.Set then
			pcall(function()
				control.Set(value, true)
			end)
		end
	end

	local transparencyControl = Settings.Controls["Window Transparency"]
	if transparencyControl and transparencyControl.Set and type(data.WindowTransparency) == "number" then
		pcall(function()
			transparencyControl.Set(data.WindowTransparency, true)
		end)
	end

	Settings.Loading = false
end

function Settings.LoadAll()
	local data = Settings.Read()

	Settings.Apply(data)
	Settings.Ready = true
	Settings.SaveNow()
end

local Utility = {}
local Main = {}
local Teleport = {}
local Items = {}

Main.CodeKeywords = {
	"math", "equation", "problem", "code", "puzzle",
	"question", "solve", "answer", "number"
}

Main.CodeSearchOrigin = Vector3.new(464, 29, 323)
Main.CodeSearchRadius = 180
Main.KeypadSearchRadius = 170

Teleport.MaxStrikes = 4
Teleport.Cooldown = 2
Teleport.Debounce = 1
Teleport.PostFLock = 0.5
Teleport.Strikes = 0
Teleport.LockedUntil = 0
Teleport.LastClickAt = 0
Teleport.BlockFUntil = 0
Teleport.BusTopRidePlatform = nil
Teleport.BusTopRideConnection = nil
Teleport.BusTopRideLastCFrame = nil
Teleport.LastJumpAt = 0
Teleport.LastRagdolledAt = 0
Teleport.LastBusLandingAt = 0

Items.SearchRootName = "Items"
Items.SearchText = ""
Items.TeleportDebounce = Teleport.Debounce
Items.EarlyAutoCollectEnabled = false
Items.EarlyAutoCollectThread = nil
Items.EarlyAutoCollectToggle = nil
Items.EarlyAutoCollectAutoStarted = false
Items.EarlyAutoCollectNotInLobby = false
Items.EarlyAutoCollectPauseUntil = 0
Items.EarlyAutoCollectRestoreAutoPickup = false
Items.EarlyAutoCollectRestoreAutoPermanent = false
Items.EarlyBusPriorityTeleportBusy = false
Items.EarlyBusPriorityTeleportToken = 0
Items.LastEarlyBusPriorityTeleportAt = 0
Items.AutoPickupEnabled = false
Items.AutoPickupToggle = nil
Items.AutoPickupPart = nil
Items.AutoPickupFollowConnection = nil
Items.AutoPickupTouchedConnection = nil
Items.AutoPickupTouchEndedConnection = nil
Items.AutoPickupThread = nil
Items.AutoPickupTouching = {}
Items.Crates = {}
Items.KnownCrates = {}
Items.CrateButtonLabel = nil

Teleport.Locations = {
	{ Name = "Acid", Position = Vector3.new(-113, 14, -625) },
	{ Name = "Barn", Position = Vector3.new(477, 87, 318) },
	{ Name = "Beach", Position = Vector3.new(-463, 13, -702) },
	{ Name = "Bob Cave", Position = Vector3.new(315, 49, -576) },
	{ Name = "Bone Pit", Position = Vector3.new(-344, -150, -414) },
	{ Name = "Bunker", Position = Vector3.new(464, 29, 323) },
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

function Main.IsCodeRelevantName(text)
	local lower = string.lower(tostring(text))

	for _, word in ipairs(Main.CodeKeywords) do
		if string.find(lower, word, 1, true) then
			return true
		end
	end

	return string.find(lower, "barn", 1, true) ~= nil
end

function Main.GetPuzzleSearchRoots()
	local roots = {}
	local seen = {}

	local function addRoot(object)
		if object and not seen[object] then
			seen[object] = true
			table.insert(roots, object)
		end
	end

	local map = workspace:FindFirstChild("Map")
	if map then
		for _, object in ipairs(map:GetChildren()) do
			if Main.IsCodeRelevantName(object.Name) then
				addRoot(object)
			end
		end
	end

	local success, parts = pcall(function()
		return workspace:GetPartBoundsInRadius(Main.CodeSearchOrigin, Main.CodeSearchRadius)
	end)

	if success and parts then
		for _, part in ipairs(parts) do
			local object = part
			local chosen = nil

			while object and object ~= workspace do
				if (object:IsA("Folder") or object:IsA("Model")) and Main.IsCodeRelevantName(object.Name) then
					chosen = object
					break
				end

				object = object.Parent
			end

			addRoot(chosen or part)
		end
	end

	return roots
end

function Main.GetCodePieceFromAssetName(name)
	local text = tostring(name)
	local exactNumber = string.match(text, "^%s*(%d+)%s*$")

	if exactNumber and #exactNumber <= 4 then
		return exactNumber
	end

	local labeledDigit = string.match(text, "^%s*[Nn]umber%s*(%d)%s*$") or string.match(text, "^%s*[Dd]igit%s*(%d)%s*$")
	return labeledDigit
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

	for _, root in ipairs(Main.GetPuzzleSearchRoots()) do
		for _, object in ipairs(root:GetDescendants()) do
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
	end

	local code = ""

	for _, id in ipairs(ids) do
		local success, info = pcall(function()
			return MarketplaceService:GetProductInfo(id)
		end)

		if success and info and info.Name then
			local piece = Main.GetCodePieceFromAssetName(info.Name)

			if piece then
				code = code .. piece
			end
		end
	end

print("CODE:", code)
	return code
end

function Main.GetBarnKeypadButtonText(object)
	local text = tostring(object.Name or "")
	local scanned = 0

	for _, descendant in ipairs(object:GetDescendants()) do
		if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
			text ..= " " .. tostring(descendant.Text)
		end

		scanned += 1

		if scanned >= 120 then
			break
		end
	end

	return string.lower(text)
end

function Main.TextMatchesDigit(text, digit)
	text = string.lower(tostring(text or ""))
	digit = tostring(digit)

	return text == digit
		or string.find(text, "number%s*" .. digit) ~= nil
		or string.find(text, "digit%s*" .. digit) ~= nil
		or string.find(text, "button%s*" .. digit) ~= nil
		or string.find(text, "key%s*" .. digit) ~= nil
		or string.find(text, "%f[%d]" .. digit .. "%f[%D]") ~= nil
end

function Main.IsBarnSubmitButton(object, text)
	text = string.lower(tostring(text or object.Name or ""))

	if string.find(text, "green", 1, true)
		or string.find(text, "enter", 1, true)
		or string.find(text, "submit", 1, true)
		or string.find(text, "confirm", 1, true)
		or string.find(text, "accept", 1, true)
		or string.find(text, "check", 1, true) then
		return true
	end

	if object:IsA("BasePart") then
		local color = object.Color
		return color.G > 0.45 and color.G > color.R * 1.3 and color.G > color.B * 1.3
	end

	return false
end

function Main.GetBarnKeypadSearchObjects()
	local objects = {}
	local seen = {}

	local function add(object)
		if object and object.Parent and not seen[object] then
			seen[object] = true
			table.insert(objects, object)
		end
	end

	local ok, parts = pcall(function()
		return workspace:GetPartBoundsInRadius(Main.CodeSearchOrigin, Main.KeypadSearchRadius)
	end)

	if ok and parts then
		for _, part in ipairs(parts) do
			add(part)

			local current = part.Parent
			local depth = 0

			while current and current ~= workspace and depth < 4 do
				add(current)
				current = current.Parent
				depth += 1
			end
		end
	end

	return objects
end

function Main.FindBarnKeypadButton(target, isSubmit)
	local bestObject = nil
	local bestScore = -1

	for _, object in ipairs(Main.GetBarnKeypadSearchObjects()) do
		local text = Main.GetBarnKeypadButtonText(object)
		local full = string.lower(object:GetFullName())
		local score = -1

		if isSubmit then
			if Main.IsBarnSubmitButton(object, text) then
				score = 25
			end
		elseif Main.TextMatchesDigit(text, target) then
			score = 25
		end

		if score > 0 then
			if string.find(full, "keypad", 1, true) then
				score += 8
			end

			if string.find(full, "button", 1, true) then
				score += 5
			end

			if string.find(full, "barn", 1, true) then
				score += 4
			end

			if object:IsA("BasePart") then
				score += 2
			end

			if score > bestScore then
				bestScore = score
				bestObject = object
			end
		end
	end

	return bestObject
end

function Main.ActivateBarnKeypadButton(button)
	if not button or not button.Parent then
		return false
	end

	local clicked = false

	for _, descendant in ipairs(button:GetDescendants()) do
		if descendant:IsA("ClickDetector") and type(fireclickdetector) == "function" then
			pcall(function()
				fireclickdetector(descendant)
				clicked = true
			end)
		elseif descendant:IsA("ProximityPrompt") then
			pcall(function()
				if type(fireproximityprompt) == "function" then
					fireproximityprompt(descendant)
				else
					descendant:InputHoldBegin()
					task.wait(math.max(descendant.HoldDuration, 0.05))
					descendant:InputHoldEnd()
				end

				clicked = true
			end)
		end
	end

	if button:IsA("ClickDetector") and type(fireclickdetector) == "function" then
		pcall(function()
			fireclickdetector(button)
			clicked = true
		end)
	elseif button:IsA("ProximityPrompt") then
		pcall(function()
			if type(fireproximityprompt) == "function" then
				fireproximityprompt(button)
			else
				button:InputHoldBegin()
				task.wait(math.max(button.HoldDuration, 0.05))
				button:InputHoldEnd()
			end

			clicked = true
		end)
	elseif button:IsA("BasePart") and type(firetouchinterest) == "function" then
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")

		if root then
			pcall(function()
				firetouchinterest(root, button, 0)
				task.wait(0.04)
				firetouchinterest(root, button, 1)
				clicked = true
			end)
		end
	end

	return clicked
end

function Main.EnterBarnKeypadCode(code)
	code = tostring(code or ""):gsub("%D", "")

	if code == "" then
		return false
	end

	local pressed = 0

	for digit in string.gmatch(code, "%d") do
		local button = Main.FindBarnKeypadButton(digit, false)

		if not Main.ActivateBarnKeypadButton(button) then
			return false
		end

		pressed += 1
		task.wait(0.09)
	end

	local submitButton = Main.FindBarnKeypadButton(nil, true)

	if not Main.ActivateBarnKeypadButton(submitButton) then
		return false
	end

	return pressed == #code
end

function Main.GetCountdownNumber(text)
	text = tostring(text or "")

	local exact = string.match(text, "^%s*(%d+)%s*$")
	if exact then
		return tonumber(exact)
	end

	local minutes, seconds = string.match(text, "^%s*(%d+)%s*:%s*(%d+)%s*$")
	if minutes and seconds then
		return tonumber(minutes) * 60 + tonumber(seconds)
	end

	return nil
end

function Main.GetTimerCandidateScore(object, number)
	if not number or number < 0 or number > 600 then
		return -1
	end

	local score = 0
	local fullName = string.lower(object:GetFullName())
	local text = string.lower(tostring(object.Text))

	for _, word in ipairs({ "timer", "time", "countdown", "count", "start", "starting", "bus", "round", "match" }) do
		if string.find(fullName, word, 1, true) then
			score += 10
		end

		if string.find(text, word, 1, true) then
			score += 8
		end
	end

	if object.Visible then
		score += 2
	end

	if string.match(tostring(object.Text), "^%s*%d+%s*$") then
		score += 3
	end

	return score
end

function Main.FindSlapRoyaleTimer()
	local bestObject = nil
	local bestNumber = nil
	local bestScore = -1
	local playerGui = player:FindFirstChild("PlayerGui")

	if not playerGui then
		return nil, nil
	end

	for _, object in ipairs(playerGui:GetDescendants()) do
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			local number = Main.GetCountdownNumber(object.Text)
			local score = Main.GetTimerCandidateScore(object, number)

			if score > bestScore then
				bestObject = object
				bestNumber = number
				bestScore = score
			end
		end
	end

	return bestNumber, bestObject
end

function Main.StartSlapRoyaleTimerPrinter()
	if Main.TimerPrinterRunning then
		return
	end

	Main.TimerPrinterRunning = true
	Main.TimerPrinterLastNumber = nil

	task.spawn(function()
		while Main.TimerPrinterRunning do
			local number = Main.FindSlapRoyaleTimer()

			if number then
				if not Main.TimerPrinterLastNumber or number < Main.TimerPrinterLastNumber then
					Main.TimerPrinterLastNumber = number

					if number <= 0 then
						Main.TimerPrinterRunning = false
						break
					end
				elseif number > Main.TimerPrinterLastNumber then
					Main.TimerPrinterLastNumber = number
				end
			end

			task.wait(0.1)
		end

		Main.TimerPrinterRunning = false
	end)
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

function Teleport.IsLocalRagdolled(character, humanoid)
	if not character or not humanoid then
		return false
	end

	local ragdollStatuses = {
		"Ragdoll",
		"Ragdolled",
		"IsRagdolled",
		"Knocked",
		"KnockedDown",
		"Downed"
	}

	for _, statusName in ipairs(ragdollStatuses) do
		local characterAttribute = character:GetAttribute(statusName)
		local humanoidAttribute = humanoid:GetAttribute(statusName)

		if characterAttribute == true or humanoidAttribute == true then
			return true
		end

		local statusObject = character:FindFirstChild(statusName, true) or humanoid:FindFirstChild(statusName, true)

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

	local state = humanoid:GetState()

	return humanoid.PlatformStand
		or state == Enum.HumanoidStateType.Ragdoll
		or state == Enum.HumanoidStateType.Physics
		or state == Enum.HumanoidStateType.FallingDown
end

function Teleport.GetWaitBeforeTeleport(debounceOverride)
	local now = os.clock()

	if Teleport.IsLocked() then
		return math.max(0, Teleport.LockedUntil - now)
	end

	local debounce = debounceOverride or Teleport.Debounce

	if Teleport.LastClickAt ~= 0 then
		return math.max(0, debounce - (now - Teleport.LastClickAt))
	end

	return 0
end

function Teleport.CanTeleport(debounceOverride, silent)

	if Teleport.IsLocked() then
		if not silent then
			Teleport.ShowWarning(tostring(Teleport.GetCooldownLeft()))
		end
		return false
	end

	local now = os.clock()
	local debounce = debounceOverride or Teleport.Debounce
	local debounceLeft = debounce - (now - Teleport.LastClickAt)

	if Teleport.LastClickAt ~= 0 and debounceLeft > 0 then
		if not silent then
			Teleport.ShowWarning(tostring(math.max(1, math.ceil(debounceLeft))))
		end
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
	Teleport.RefreshPickupLock()
end

function Teleport.StartBusLandingLock(duration)
	local now = os.clock()
	local unlockAt = now + (duration or 4)

	Teleport.LastBusLandingAt = now
	Teleport.LockedUntil = math.max(Teleport.LockedUntil, unlockAt)
	Teleport.BlockFUntil = math.max(Teleport.BlockFUntil, unlockAt)
	Items.BusLandingFBlockActive = true
	Teleport.RefreshPickupLock()

	task.delay(math.max(0.05, unlockAt - os.clock()), function()
		if Teleport.BlockFUntil <= unlockAt + 0.02 then
			Items.BusLandingFBlockActive = false
		end
	end)
end

function Teleport.RefreshPickupLock()
	local unlockAt = Teleport.BlockFUntil

	pcall(function()
		game:GetService("ProximityPromptService").Enabled = false
	end)

	task.delay(math.max(0.05, unlockAt - os.clock()), function()
		if Teleport.BlockFUntil <= unlockAt + 0.02 then
			pcall(function()
				game:GetService("ProximityPromptService").Enabled = true
			end)
		end
	end)
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

function Teleport.MoveRoot(root, targetCFrame, lookAtPosition)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	if lookAtPosition then
		local flatLookAt = Vector3.new(lookAtPosition.X, targetCFrame.Position.Y, lookAtPosition.Z)

		if (flatLookAt - targetCFrame.Position).Magnitude > 0.1 then
			root.CFrame = CFrame.lookAt(targetCFrame.Position, flatLookAt)
		else
			root.CFrame = CFrame.new(targetCFrame.Position)
		end

		local camera = workspace.CurrentCamera
		if camera then
			local ignore = {}
			if player.Character then
				table.insert(ignore, player.Character)
			end

			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = ignore

			local overlapParams = OverlapParams.new()
			overlapParams.FilterType = Enum.RaycastFilterType.Exclude
			overlapParams.FilterDescendantsInstances = ignore

			local itemFocus = lookAtPosition + Vector3.new(0, 1.2, 0)
			local away = targetCFrame.Position - itemFocus

			if away.Magnitude < 1 then
				away = root.CFrame.LookVector * -1
			end

			away = away.Unit
			local right = Vector3.new(away.Z, 0, -away.X)

			local function isTreePart(part)
				if not part then
					return false
				end

				local current = part

				while current and current ~= workspace do
					local name = string.lower(current.Name)

					if string.find(name, "tree", 1, true)
						or string.find(name, "leaf", 1, true)
						or string.find(name, "leaves", 1, true)
						or string.find(name, "branch", 1, true)
						or string.find(name, "trunk", 1, true)
					then
						return true
					end

					current = current.Parent
				end

				return false
			end

			local cameraPositions = {
				targetCFrame.Position + away * 11 + Vector3.new(0, 4, 0),
				targetCFrame.Position + away * 8 + Vector3.new(0, 5, 0),
				targetCFrame.Position + right * 8 + Vector3.new(0, 4, 0),
				targetCFrame.Position - right * 8 + Vector3.new(0, 4, 0),
				targetCFrame.Position + (away + right).Unit * 10 + Vector3.new(0, 5, 0),
				targetCFrame.Position + (away - right).Unit * 10 + Vector3.new(0, 5, 0),
				targetCFrame.Position + (-away + right).Unit * 9 + Vector3.new(0, 5, 0),
				targetCFrame.Position + (-away - right).Unit * 9 + Vector3.new(0, 5, 0)
			}

			local cameraSet = false

			for _, cameraPosition in ipairs(cameraPositions) do
				local touching = workspace:GetPartBoundsInBox(CFrame.new(cameraPosition), Vector3.new(1.4, 1.4, 1.4), overlapParams)
				local insideWall = false

				for _, part in ipairs(touching) do
					if part.CanCollide and part.Transparency < 0.95 then
						insideWall = true
						break
					end
				end

				if insideWall then
					continue
				end

				local direction = itemFocus - cameraPosition
				local hit = workspace:Raycast(cameraPosition, direction, params)

				if not hit or ((hit.Position - itemFocus).Magnitude <= 2 and not isTreePart(hit.Instance)) then
					camera.CFrame = CFrame.lookAt(cameraPosition, itemFocus)
					cameraSet = true
					break
				end
			end

			if not cameraSet then
				local fallbackPosition = targetCFrame.Position - root.CFrame.LookVector * 10 + Vector3.new(0, 4, 0)
				camera.CFrame = CFrame.lookAt(fallbackPosition, itemFocus)
			end

			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				camera.CameraSubject = humanoid
				camera.CameraType = Enum.CameraType.Custom
			end
		end
	else
		local _, yRotation, _ = root.CFrame:ToOrientation()
		root.CFrame = CFrame.new(targetCFrame.Position) * CFrame.Angles(0, yRotation, 0)
	end

	task.wait()

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

function Teleport.StabilizeItemView(root, itemPart)
	if not root or not root.Parent or not itemPart or not itemPart.Parent then
		return
	end

	local camera = workspace.CurrentCamera
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero

	if camera then
		local focus = itemPart.Position + Vector3.new(0, 0.8, 0)
		local ignore = { character }

		table.insert(ignore, itemPart)

		if itemPart.Parent then
			table.insert(ignore, itemPart.Parent)
		end

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = ignore

		pcall(function()
			rayParams.FilterType = Enum.RaycastFilterType.Exclude
		end)

		local overlapParams = OverlapParams.new()
		overlapParams.FilterDescendantsInstances = ignore

		pcall(function()
			overlapParams.FilterType = Enum.RaycastFilterType.Exclude
		end)

		local function isBlockingCameraPart(part)
			if not part or not part:IsA("BasePart") then
				return false
			end

			if character and part:IsDescendantOf(character) then
				return false
			end

			return part.CanCollide and part.Transparency < 0.95
		end

		local function isCameraSpotClear(position)
			local parts = workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(1.6, 1.6, 1.6), overlapParams)

			for _, part in ipairs(parts) do
				if isBlockingCameraPart(part) then
					return false
				end
			end

			local headPosition = root.Position + Vector3.new(0, 2.5, 0)
			local overheadHit = workspace:Raycast(headPosition, position - headPosition, rayParams)

			if overheadHit and isBlockingCameraPart(overheadHit.Instance) then
				return false
			end

			local viewHit = workspace:Raycast(position, focus - position, rayParams)

			if viewHit and isBlockingCameraPart(viewHit.Instance) and (viewHit.Position - focus).Magnitude > 2.5 then
				return false
			end

			return true
		end

		local cameraPositions = {
			root.Position + Vector3.new(0, 13, 0),
			root.Position + root.CFrame.LookVector * 2 + Vector3.new(0, 10, 0),
			root.Position - root.CFrame.LookVector * 10 + Vector3.new(0, 4, 0),
			root.Position + root.CFrame.RightVector * 8 + Vector3.new(0, 5, 0),
			root.Position - root.CFrame.RightVector * 8 + Vector3.new(0, 5, 0),
		}

		local cameraPosition = cameraPositions[3]

		for _, position in ipairs(cameraPositions) do
			if isCameraSpotClear(position) then
				cameraPosition = position
				break
			end
		end

		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = CFrame.lookAt(cameraPosition, focus)

		if humanoid then
			camera.CameraSubject = humanoid

			task.delay(0.65, function()
				if camera and camera.Parent and humanoid and humanoid.Parent then
					camera.CameraSubject = humanoid
					camera.CameraType = Enum.CameraType.Custom
				end
			end)
		end
	end
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
		local touching = workspace:GetPartBoundsInBox(CFrame.new(candidatePosition + Vector3.new(0, 1.8, 0)), Vector3.new(2.8, 4.4, 2.8), overlapParams)

		for _, part in ipairs(touching) do
			if part ~= itemPart and part.CanCollide and part.Transparency < 0.95 then
				return false
			end
		end

		return true
	end

	local function canSeeItem(candidatePosition)
		local itemFocus = position + Vector3.new(0, 1, 0)
		local viewPosition = candidatePosition + Vector3.new(0, 1.6, 0)
		local direction = itemFocus - viewPosition

		if direction.Magnitude <= 0.1 then
			return true
		end

		local result = workspace:Raycast(viewPosition, direction, params)
		return not result or (result.Position - itemFocus).Magnitude <= 1.5
	end

	local roofResult = workspace:Raycast(position + Vector3.new(0, 0.5, 0), Vector3.new(0, 7, 0), params)
	local hasRoofAbove = roofResult and roofResult.Instance and roofResult.Instance.CanCollide and roofResult.Instance.Transparency < 0.95

	local centerOffsets = {
		Vector3.zero,
		Vector3.new(1, 0, 0),
		Vector3.new(-1, 0, 0),
		Vector3.new(0, 0, 1),
		Vector3.new(0, 0, -1)
	}

	local roofOffsets = {
		Vector3.new(0.8, 0, 0),
		Vector3.new(-0.8, 0, 0),
		Vector3.new(0, 0, 0.8),
		Vector3.new(0, 0, -0.8),
		Vector3.new(1.4, 0, 1.4),
		Vector3.new(-1.4, 0, 1.4),
		Vector3.new(1.4, 0, -1.4),
		Vector3.new(-1.4, 0, -1.4),
		Vector3.new(2, 0, 0),
		Vector3.new(-2, 0, 0),
		Vector3.new(0, 0, 2),
		Vector3.new(0, 0, -2)
	}

	local sideOffsets = {
		Vector3.new(3, 0, 0),
		Vector3.new(-3, 0, 0),
		Vector3.new(0, 0, 3),
		Vector3.new(0, 0, -3),
		Vector3.new(4, 0, 4),
		Vector3.new(-4, 0, 4),
		Vector3.new(4, 0, -4),
		Vector3.new(-4, 0, -4)
	}

	local searchOffsets = hasRoofAbove and roofOffsets or centerOffsets

	if not hasRoofAbove then
		local rayStartHeight = math.min((itemPart.Size.Y / 2) + 1.5, 4)
		local rayOrigin = position + Vector3.new(0, rayStartHeight, 0)
		local result = workspace:Raycast(rayOrigin, Vector3.new(0, -35, 0), params)

		if result and result.Position.Y <= position.Y + 0.6 and position.Y - result.Position.Y <= 18 then
			local candidatePosition = result.Position + Vector3.new(0, 4, 0)

			if hasRoom(candidatePosition) then
				return CFrame.new(candidatePosition)
			end
		end
	end

	for _, offset in ipairs(searchOffsets) do
		local rayStartHeight = math.min((itemPart.Size.Y / 2) + 1.5, 4)
		local rayOrigin = position + offset + Vector3.new(0, rayStartHeight, 0)
		local result = workspace:Raycast(rayOrigin, Vector3.new(0, -35, 0), params)

		if result and result.Position.Y <= position.Y + 0.6 and position.Y - result.Position.Y <= 18 then
			local candidatePosition = result.Position + Vector3.new(0, 4, 0)

			if hasRoom(candidatePosition) and (not hasRoofAbove or canSeeItem(candidatePosition)) then
				return CFrame.new(candidatePosition)
			end
		end
	end

	for _, offset in ipairs(searchOffsets) do
		local rayOrigin = position + offset + Vector3.new(0, 1.5, 0)
		local result = workspace:Raycast(rayOrigin, Vector3.new(0, -20, 0), params)

		if result and math.abs(result.Position.Y - position.Y) <= 12 then
			local candidatePosition = result.Position + Vector3.new(0, 4, 0)

			if hasRoom(candidatePosition) and (not hasRoofAbove or canSeeItem(candidatePosition)) then
				return CFrame.new(candidatePosition)
			end
		end
	end

	for _, offset in ipairs(searchOffsets) do
		local candidatePosition = position + offset + Vector3.new(0, 4, 0)

		if hasRoom(candidatePosition) and (not hasRoofAbove or canSeeItem(candidatePosition)) then
			return CFrame.new(candidatePosition)
		end
	end

	if hasRoofAbove then
		for _, offset in ipairs(sideOffsets) do
			local rayOrigin = position + offset + Vector3.new(0, 1.5, 0)
			local result = workspace:Raycast(rayOrigin, Vector3.new(0, -20, 0), params)

			if result and math.abs(result.Position.Y - position.Y) <= 12 then
				local candidatePosition = result.Position + Vector3.new(0, 4, 0)

				if hasRoom(candidatePosition) and canSeeItem(candidatePosition) then
					return CFrame.new(candidatePosition)
				end
			end
		end
	end

	return CFrame.new(position + Vector3.new(0, 4, 0))
end

function Teleport.CreateMarker(position)
	return nil
end

function Teleport.ToLocation(locationName, position, forceTeleport)
	if forceTeleport then
		Teleport.LockedUntil = 0
		Teleport.LastClickAt = 0
		Teleport.Strikes = 0
	elseif not Teleport.CanTeleport() then
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

	if not forceTeleport then
		Teleport.AddStrike()
		Teleport.StartFBlock()
	end

	createNotification("Teleport", "Teleported to " .. locationName)
end

function Teleport.GetBusCandidateFromObject(object)
	local current = object
	local candidate = nil

	while current and current ~= workspace do
		local name = Utility.NormalizeName(current.Name)

		if string.find(name, "bus", 1, true) and (current:IsA("Model") or current:IsA("BasePart")) then
			candidate = current
		end

		current = current.Parent
	end

	return candidate
end

function Teleport.GetBusParts(candidate)
	local parts = {}

	if not candidate or not candidate.Parent then
		return parts
	end

	if candidate:IsA("BasePart") then
		table.insert(parts, candidate)
		return parts
	end

	for _, object in ipairs(candidate:GetDescendants()) do
		if object:IsA("BasePart") then
			table.insert(parts, object)
		end
	end

	return parts
end

function Teleport.IsSchoolHouseBusCandidate(candidate)
	local position = getObjectWorldPosition(candidate)

	return position and (position - SCHOOL_BUS_CLEANUP_POSITION).Magnitude <= SCHOOL_BUS_CLEANUP_RADIUS
end

function Teleport.FindSchoolBusTopTarget()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local seen = {}
	local bestCandidate = nil
	local bestParts = nil
	local bestDistance = math.huge

	for _, object in ipairs(workspace:GetDescendants()) do
		local candidate = Teleport.GetBusCandidateFromObject(object)

		if candidate and candidate.Parent and not seen[candidate] and not Teleport.IsSchoolHouseBusCandidate(candidate) then
			seen[candidate] = true

			local parts = Teleport.GetBusParts(candidate)
			local position = getObjectWorldPosition(candidate)

			if #parts > 0 and position then
				local distance = root and (root.Position - position).Magnitude or 0

				if distance < bestDistance then
					bestDistance = distance
					bestCandidate = candidate
					bestParts = parts
				end
			end
		end
	end

	return bestCandidate, bestParts
end

function Teleport.MakeBusCollidable(parts)
	for _, part in ipairs(parts or {}) do
		if part and part.Parent then
			pcall(function()
				part.CanCollide = true
				part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 1, 0, 100, 0)
			end)
		end
	end
end

function Teleport.ClearBusTopRidePlatform()
	if Teleport.BusTopRideConnection then
		Teleport.BusTopRideConnection:Disconnect()
		Teleport.BusTopRideConnection = nil
	end

	if Teleport.BusTopRidePlatform and Teleport.BusTopRidePlatform.Parent then
		Teleport.BusTopRidePlatform:Destroy()
	end

	Teleport.BusTopRidePlatform = nil
	Teleport.BusTopRideLastCFrame = nil
end

function Teleport.GetBusTopCFrame(candidate, parts)
	local topPart = nil
	local topY = -math.huge

	for _, part in ipairs(parts or {}) do
		if part and part.Parent then
			local partTopY = part.Position.Y + (part.Size.Y * 0.5)

			if partTopY > topY then
				topY = partTopY
				topPart = part
			end
		end
	end

	if not topPart then
		return nil
	end

	local targetPosition = topPart.Position + Vector3.new(0, (topPart.Size.Y * 0.5) + 5, 0)
	local platformPosition = Vector3.new(topPart.Position.X, topY + 0.15, topPart.Position.Z)

	if candidate and candidate:IsA("Model") then
		local ok, boxCFrame, boxSize = pcall(function()
			return candidate:GetBoundingBox()
		end)

		if ok and boxCFrame and boxSize then
			targetPosition = Vector3.new(boxCFrame.Position.X, boxCFrame.Position.Y + (boxSize.Y * 0.5) + 5, boxCFrame.Position.Z)
			platformPosition = Vector3.new(boxCFrame.Position.X, boxCFrame.Position.Y + (boxSize.Y * 0.5) + 0.15, boxCFrame.Position.Z)
		end
	end

	return CFrame.new(targetPosition), CFrame.new(platformPosition), topPart
end

function Teleport.IsRootOnBusTopRide(root, platformCFrame)
	if not root or not platformCFrame then
		return false
	end

	local localPosition = platformCFrame:PointToObjectSpace(root.Position)

	return math.abs(localPosition.X) <= 18
		and math.abs(localPosition.Z) <= 18
		and localPosition.Y >= -4
		and localPosition.Y <= 12
end

function Teleport.CreateBusTopRidePlatform(candidate, parts, platformCFrame, topPart)
	Teleport.ClearBusTopRidePlatform()

	if not platformCFrame then
		return
	end

	local platform = Instance.new("Part")
	platform.Name = "Part"
	platform.Size = Vector3.new(18, 0.3, 18)
	platform.CFrame = platformCFrame
	platform.Anchored = topPart == nil
	platform.Massless = true
	platform.CanCollide = true
	platform.CanTouch = false
	platform.CanQuery = false
	platform.Transparency = 1
	platform.Material = Enum.Material.SmoothPlastic
	platform.CustomPhysicalProperties = PhysicalProperties.new(0.7, 1, 0, 100, 0)
	platform.Parent = workspace

	if topPart and topPart.Parent then
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = platform
		weld.Part1 = topPart
		weld.Parent = platform
	end

	Teleport.BusTopRidePlatform = platform
	Teleport.BusTopRideLastCFrame = platformCFrame
	Teleport.BusTopRideConnection = RunService.Heartbeat:Connect(function(dt)
		if not platform.Parent or not candidate or not candidate.Parent or (topPart and not topPart.Parent) then
			Teleport.ClearBusTopRidePlatform()
			return
		end

		local _, nextPlatformCFrame = Teleport.GetBusTopCFrame(candidate, parts)

		if nextPlatformCFrame then
			local lastCFrame = Teleport.BusTopRideLastCFrame or platform.CFrame
			local delta = nextPlatformCFrame.Position - lastCFrame.Position
			local horizontalDelta = Vector3.new(delta.X, 0, delta.Z)

			if platform.Anchored then
				platform.CFrame = nextPlatformCFrame
			end

			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")

			if root and Teleport.IsRootOnBusTopRide(root, lastCFrame) and horizontalDelta.Magnitude > 0.001 and horizontalDelta.Magnitude < 80 then
				root.CFrame = root.CFrame + horizontalDelta

				local velocity = root.AssemblyLinearVelocity
				local followDt = math.max(dt or 0, 1 / 240)
				root.AssemblyLinearVelocity = Vector3.new(horizontalDelta.X / followDt, velocity.Y, horizontalDelta.Z / followDt)
			end

			Teleport.BusTopRideLastCFrame = nextPlatformCFrame
		end
	end)
end

function Teleport.ToSchoolBusTop()
	if not Teleport.CanTeleport() then
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)

	if not root then
		createNotification("School Bus", "Could not find your character.", "Error")
		return
	end

	local bus, parts = Teleport.FindSchoolBusTopTarget()
	local targetCFrame, platformCFrame, topPart = Teleport.GetBusTopCFrame(bus, parts)

	if not bus or not targetCFrame then
		createNotification("School Bus", "Could not find a bus outside the schoolhouse area.", "Warning")
		return
	end

	Teleport.MakeBusCollidable(parts)
	Teleport.CreateBusTopRidePlatform(bus, parts, platformCFrame, topPart)
	if UI then
		UI.SkipNextBusLandingLockUntil = os.clock() + 3
		UI.BusLandingWasInBus = false
	end
	Teleport.MoveRoot(root, targetCFrame)
	Teleport.AddStrike()
	Teleport.StartFBlock()
	createNotification("School Bus", "Teleported on top of the bus.", "Success")
end

Items.SearchCache = {}
Items.SearchCacheBusy = false
Items.LastSearchCacheAt = 0
Items.SearchCacheCooldown = 1
Items.SearchCacheDirty = true
Items.SearchCacheRoot = nil
Items.SearchCacheRootConnections = {}

function Items.GetSearchRoot()
	local exactRoot = workspace:FindFirstChild(Items.SearchRootName)

	if exactRoot then
		return exactRoot
	end

	local wantedName = string.lower(Items.SearchRootName)

	for _, child in ipairs(workspace:GetChildren()) do
		if string.lower(child.Name) == wantedName then
			return child
		end
	end

	return nil
end

function Items.MarkSearchCacheDirty()
	Items.SearchCacheDirty = true
end

function Items.ClearSearchRootConnections()
	for _, connection in ipairs(Items.SearchCacheRootConnections) do
		if connection then
			connection:Disconnect()
		end
	end

	Items.SearchCacheRootConnections = {}
end

function Items.WatchSearchRoot(root)
	if Items.SearchCacheRoot == root then
		return
	end

	Items.ClearSearchRootConnections()
	Items.SearchCacheRoot = root

	if not root then
		return
	end

	table.insert(Items.SearchCacheRootConnections, root.DescendantAdded:Connect(Items.MarkSearchCacheDirty))
	table.insert(Items.SearchCacheRootConnections, root.DescendantRemoving:Connect(Items.MarkSearchCacheDirty))
end

function Items.RebuildSearchCache()
	if Items.SearchCacheBusy then
		return
	end

	Items.SearchCacheBusy = true

	task.spawn(function()
		local root = Items.GetSearchRoot()
		Items.WatchSearchRoot(root)

		if not root then
			Items.SearchCache = {}
			Items.LastSearchCacheAt = os.clock()
			Items.SearchCacheDirty = false
			Items.SearchCacheBusy = false
			return
		end

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
		Items.SearchCacheDirty = false
		Items.SearchCacheBusy = false
	end)
end

function Items.GetSearchDescendants()
	if Items.SearchCacheDirty or os.clock() - Items.LastSearchCacheAt > Items.SearchCacheCooldown then
		Items.RebuildSearchCache()
	end

	return Items.SearchCache
end

local itemNameAliases = {
	["Bull's Essence"] = {
		"Bull's essence"
	},
	["Sphere of Fury"] = {
		"Sphere of fury"
	}
}

local function strictItemNameMatches(candidateName, wantedName)
	local normalizedCandidate = Utility.NormalizeName(candidateName)
	local normalizedWanted = Utility.NormalizeName(wantedName)

	if candidateName == wantedName or normalizedCandidate == normalizedWanted then
		return true
	end

	if string.sub(normalizedCandidate, 1, #normalizedWanted) == normalizedWanted then
		return true
	end

	local aliases = itemNameAliases[wantedName]
	if aliases then
		for _, alias in ipairs(aliases) do
			local normalizedAlias = Utility.NormalizeName(alias)

			if candidateName == alias
				or normalizedCandidate == normalizedAlias
				or string.sub(normalizedCandidate, 1, #normalizedAlias) == normalizedAlias then
				return true
			end
		end
	end

	return false
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

		if strictItemNameMatches(displayName, itemName) then
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

	Teleport.MoveRoot(root, groundCFrame, itemPart.Position)
	task.delay(0.05, function()
		Teleport.StabilizeItemView(root, itemPart)
	end)
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
			if not Items.EarlyAutoCollectEnabled and not Items.EarlyBusFBlockActive and not Items.BusLandingFBlockActive then
				Teleport.BlockFUntil = 0
				return Enum.ContextActionResult.Pass
			end

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

local ItemESP = nil
UI.AutoEarlyBusJumpEnabled = false
UI.AutoEarlyBusJumpThread = nil
UI.AutoEarlyBusJumpFiredInBus = false
UI.LastAutoEarlyBusJumpAt = 0
UI.LastJumpBusSeenAt = 0
UI.JumpBusSearchActive = false
UI.JumpBusExitSent = false
UI.JumpBusTrackedObject = nil
UI.LastSlapRoyaleTimerNumber = nil
UI.LastSlapRoyaleTimerZeroAt = -math.huge
UI.JumpBusSearchStartedAt = 0
UI.JumpBusTimerSeen = false
UI.BusLandingWatcherStarted = false
UI.BusLandingWasInBus = false
UI.LastBusLandingLockAt = 0
UI.SkipNextBusLandingLockUntil = 0
UI.AutoRejoinEnabled = false
UI.AutoRejoinConnections = {}
UI.AutoRejoinBusy = false
UI.AutoRejoinPlaceId = 9426795465
UI.InfiniteJumpEnabled = false
UI.InfiniteJumpConnection = nil
UI.BusSearchCache = {}
UI.LastBusSearchAt = 0

function UI.SetInfiniteJump(state)
	UI.InfiniteJumpEnabled = state == true

	if UI.InfiniteJumpEnabled then
		if not UI.InfiniteJumpConnection then
			UI.InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
				if not UI.InfiniteJumpEnabled then
					return
				end

				local character = player.Character
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")

				if humanoid and humanoid.Health > 0 then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end

		createNotification("Infinite jump", "Infinite jump enabled.", "Success")
	else
		if UI.InfiniteJumpConnection then
			UI.InfiniteJumpConnection:Disconnect()
			UI.InfiniteJumpConnection = nil
		end

		createNotification("Infinite jump", "Infinite jump disabled.")
	end
end

function UI.FireRemoteAction(label, remoteName, ...)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local remote = remotes and remotes:FindFirstChild(remoteName)

	if remote and remote:IsA("RemoteEvent") then
		local ok, err = pcall(function(...)
			remote:FireServer(...)
		end, ...)

		if ok then
			createNotification(label, remoteName .. " request sent.", "Success")
			return true
		else
			createNotification(label, "Failed: " .. tostring(err), "Error")
			return false
		end
	else
		createNotification(label, remoteName .. " remote not found.", "Error")
		return false
	end
end

function UI.RequestEarlyBusPriorityTeleport(delaySeconds, forceRestart)
	task.delay(delaySeconds or 0, function()
		for _ = 1, 30 do
			if UI.TeleportToEarlyBusPriorityItem then
				UI.TeleportToEarlyBusPriorityItem(forceRestart)
				return
			end

			task.wait(0.2)
		end
	end)
end

function UI.FireEarlyBusJump()
	local success = UI.FireRemoteAction("Early Bus Jump", "BusJumping", true)

	if success then
		UI.JumpBusExitSent = true
		UI.RequestEarlyBusPriorityTeleport()
	end

	return success
end

function UI.RefreshJumpBusTimerWindow()
	local timerNumber = Main.FindSlapRoyaleTimer()
	local now = os.clock()

	if timerNumber then
		UI.JumpBusTimerSeen = true

		if timerNumber <= 5 or (UI.LastSlapRoyaleTimerNumber and UI.LastSlapRoyaleTimerNumber > 0 and timerNumber <= 0) then
			UI.LastSlapRoyaleTimerZeroAt = now
		end

		UI.LastSlapRoyaleTimerNumber = timerNumber
	elseif UI.LastSlapRoyaleTimerNumber and UI.LastSlapRoyaleTimerNumber <= 5 then
		UI.LastSlapRoyaleTimerZeroAt = now
		UI.LastSlapRoyaleTimerNumber = nil
	else
		UI.LastSlapRoyaleTimerNumber = nil
	end
end

function UI.IsJumpBusDetectionActive()
	UI.RefreshJumpBusTimerWindow()

	if UI.JumpBusExitSent then
		return true
	end

	if UI.JumpBusSearchActive ~= true then
		return false
	end

	local now = os.clock()

	if now - UI.LastSlapRoyaleTimerZeroAt <= 7 then
		return true
	end

	return not UI.JumpBusTimerSeen and now - (UI.JumpBusSearchStartedAt or 0) <= 12
end

function UI.GetBusCandidateRoot(object)
	local current = object
	local candidate = nil

	while current and current ~= workspace do
		local lowerName = string.lower(current.Name)

		if string.find(lowerName, "bus", 1, true) and (current:IsA("Model") or current:IsA("BasePart")) then
			candidate = current
		end

		current = current.Parent
	end

	return candidate
end

function UI.IsJumpBusCandidate(object)
	local lowerName = string.lower(object.Name)

	return string.find(lowerName, "bus", 1, true) ~= nil and (object:IsA("Model") or object:IsA("BasePart"))
end

function UI.GetBusCandidates(rootPosition)
	if os.clock() - UI.LastBusSearchAt < 0.65 then
		return UI.BusSearchCache
	end

	local results = {}

	if UI.IsJumpBusDetectionActive() and rootPosition then
		local seen = {}

		local ok, nearbyParts = pcall(function()
			return workspace:GetPartBoundsInBox(CFrame.new(rootPosition), Vector3.new(180, 130, 180))
		end)

		if ok then
			for _, part in ipairs(nearbyParts) do
				local candidate = UI.GetBusCandidateRoot(part)

				if candidate and not seen[candidate] then
					seen[candidate] = true
					table.insert(results, candidate)
				end
			end
		end

		if #results == 0 then
			for _, object in ipairs(workspace:GetChildren()) do
				if UI.IsJumpBusCandidate(object) and not seen[object] then
					seen[object] = true
					table.insert(results, object)
				end
			end
		end
	end

	UI.BusSearchCache = results
	UI.LastBusSearchAt = os.clock()
	return results
end

function UI.IsPointNearObjectBounds(point, object)
	if object:IsA("BasePart") then
		local localPoint = object.CFrame:PointToObjectSpace(point)
		local halfSize = (object.Size * 0.5) + Vector3.new(14, 14, 14)

		return math.abs(localPoint.X) <= halfSize.X
			and math.abs(localPoint.Y) <= halfSize.Y
			and math.abs(localPoint.Z) <= halfSize.Z
	end

	if object:IsA("Model") then
		local ok, cframe, size = pcall(function()
			return object:GetBoundingBox()
		end)

		if ok then
			local localPoint = cframe:PointToObjectSpace(point)
			local halfSize = (size * 0.5) + Vector3.new(18, 18, 18)

			return math.abs(localPoint.X) <= halfSize.X
				and math.abs(localPoint.Y) <= halfSize.Y
				and math.abs(localPoint.Z) <= halfSize.Z
		end
	end

	return false
end

function UI.IsLocalPlayerInBus()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return false
	end

	if UI.JumpBusTrackedObject and UI.JumpBusTrackedObject.Parent then
		if UI.IsPointNearObjectBounds(root.Position, UI.JumpBusTrackedObject) then
			UI.LastJumpBusSeenAt = os.clock()
			return true
		end

		if UI.JumpBusExitSent then
			return false
		end
	end

	for _, busObject in ipairs(UI.GetBusCandidates(root.Position)) do
		if busObject.Parent and UI.IsPointNearObjectBounds(root.Position, busObject) then
			UI.LastJumpBusSeenAt = os.clock()
			UI.JumpBusTrackedObject = busObject
			return true
		end
	end

	return false
end

function UI.DisconnectAutoRejoin()
	for _, connection in ipairs(UI.AutoRejoinConnections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(UI.AutoRejoinConnections)
end

function UI.TeleportAutoRejoin(reason)
	if UI.AutoRejoinBusy then
		return
	end

	UI.AutoRejoinBusy = true
	createNotification("Auto Rejoin", "Joining place " .. tostring(UI.AutoRejoinPlaceId) .. " after " .. reason .. ".", "Info")

	task.spawn(function()
		pcall(function()
			Services.TeleportService:Teleport(UI.AutoRejoinPlaceId, player)
		end)

		task.wait(3)
		UI.AutoRejoinBusy = false
	end)
end

function UI.HookAutoRejoinCharacter(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	table.insert(UI.AutoRejoinConnections, humanoid.Died:Connect(function()
		if UI.AutoRejoinEnabled then
			UI.TeleportAutoRejoin("death")
		end
	end))
end

function UI.SetAutoRejoin(state)
	UI.AutoRejoinEnabled = state == true

	UI.DisconnectAutoRejoin()

	if UI.AutoRejoinEnabled then
		UI.AutoRejoinBusy = false
		UI.HookAutoRejoinCharacter(player.Character)

		table.insert(UI.AutoRejoinConnections, player.CharacterAdded:Connect(function(character)
			task.wait(0.3)
			if UI.AutoRejoinEnabled then
				UI.HookAutoRejoinCharacter(character)
			end
		end))

		pcall(function()
			table.insert(UI.AutoRejoinConnections, Services.GuiService.ErrorMessageChanged:Connect(function()
				if UI.AutoRejoinEnabled then
					UI.TeleportAutoRejoin("disconnect")
				end
			end))
		end)

		createNotification("Auto Rejoin", "Auto rejoin enabled.", "Success")
	else
		UI.AutoRejoinBusy = false
		createNotification("Auto Rejoin", "Auto rejoin disabled.")
	end
end

function UI.RunAutoEarlyBusJump()
	if UI.AutoEarlyBusJumpThread then
		return
	end

	UI.JumpBusSearchActive = true
	UI.JumpBusExitSent = false
	UI.JumpBusTrackedObject = nil
	UI.JumpBusSearchStartedAt = os.clock()
	UI.JumpBusTimerSeen = false
	UI.LastSlapRoyaleTimerNumber = nil
	UI.LastSlapRoyaleTimerZeroAt = -math.huge
	UI.BusSearchCache = {}
	UI.LastBusSearchAt = 0

	UI.AutoEarlyBusJumpThread = task.spawn(function()
		while UI.AutoEarlyBusJumpEnabled do
			local inBus = UI.IsLocalPlayerInBus()

			if inBus and not UI.AutoEarlyBusJumpFiredInBus and os.clock() - UI.LastAutoEarlyBusJumpAt >= 1 then
				if UI.FireEarlyBusJump() then
					UI.AutoEarlyBusJumpFiredInBus = true
					UI.LastAutoEarlyBusJumpAt = os.clock()
				end
			elseif not inBus and not UI.JumpBusExitSent then
				UI.AutoEarlyBusJumpFiredInBus = false
			end

			task.wait(0.15)
		end

		UI.AutoEarlyBusJumpThread = nil
		UI.AutoEarlyBusJumpFiredInBus = false
		UI.JumpBusSearchActive = false
		UI.JumpBusTimerSeen = false
	end)
end

function UI.StartBusLandingWatcher()
	if UI.BusLandingWatcherStarted then
		return
	end

	UI.BusLandingWatcherStarted = true

	task.spawn(function()
		while gui.Parent do
			local inBus = UI.IsLocalPlayerInBus()
			local now = os.clock()
			local skipBusLandingLock = now < (UI.SkipNextBusLandingLockUntil or 0)

			if UI.BusLandingWasInBus and not inBus and not skipBusLandingLock then
				local earlyJumpedRecently = UI.LastAutoEarlyBusJumpAt > 0 and now - UI.LastAutoEarlyBusJumpAt <= 2

				if UI.AutoEarlyBusJumpEnabled or earlyJumpedRecently then
					UI.JumpBusSearchActive = false
					UI.JumpBusExitSent = false
					UI.JumpBusTrackedObject = nil
					UI.AutoEarlyBusJumpFiredInBus = false
					UI.JumpBusTimerSeen = false
					UI.BusSearchCache = {}
					UI.LastBusSearchAt = 0
					UI.LastAutoEarlyBusJumpAt = now
					UI.RequestEarlyBusPriorityTeleport(nil, true)
				end

			if not earlyJumpedRecently and now - UI.LastBusLandingLockAt >= 4 then
				UI.LastBusLandingLockAt = now
				Teleport.StartBusLandingLock(4)
				Notify.Show("Bus Landing", "Teleports and pickup are locked for 4 seconds.", "Warning", nil, 2.2, true)
				end
			end

			
			task.wait(0.15)
		end
	end)
end

UI.StartBusLandingWatcher()

function UI.SetAutoEarlyBusJump(state)
	UI.AutoEarlyBusJumpEnabled = state == true

	if UI.AutoEarlyBusJumpEnabled then
		UI.JumpBusSearchActive = true
		UI.JumpBusExitSent = false
		UI.JumpBusTrackedObject = nil
		UI.AutoEarlyBusJumpFiredInBus = false
		UI.JumpBusSearchStartedAt = os.clock()
		UI.JumpBusTimerSeen = false
		UI.LastSlapRoyaleTimerNumber = nil
		UI.LastSlapRoyaleTimerZeroAt = -math.huge
		UI.BusSearchCache = {}
		UI.LastBusSearchAt = 0
		UI.RunAutoEarlyBusJump()
		createNotification("Early Bus Jump", "Auto bus jump enabled.", "Success")
	else
		UI.JumpBusSearchActive = false
		UI.JumpBusExitSent = false
		UI.JumpBusTrackedObject = nil
		UI.AutoEarlyBusJumpFiredInBus = false
		UI.JumpBusTimerSeen = false
		UI.BusSearchCache = {}
		UI.LastBusSearchAt = 0
		createNotification("Early Bus Jump", "Auto bus jump disabled.")
	end
end

function Main.GetCodeGoBarn()
	Teleport.ToLocation("Bunker", Main.CodeSearchOrigin, true)
	Notify.Show("Code", "Searching...", "Info", nil, 2.2, true)

	task.spawn(function()
		task.wait(0.45)

		local code = Main.GetPuzzleCode()
		Notify.Show("Code Found", code ~= "" and code or "No code found.", code ~= "" and "Success" or "Info", nil, 4, true)

		if code ~= "" then
			task.wait(0.2)

			if Main.EnterBarnKeypadCode(code) then
				Notify.Show("Barn Keypad", "Entered and submitted " .. code .. ".", "Success", nil, 3.5, true)
			else
				Notify.Show("Barn Keypad", "Found code, but could not press every keypad button.", "Warning", nil, 4, true)
			end
		end
	end)
end

createSmallButton(mainList, "Get Code + Go Barn", function()
	Main.GetCodeGoBarn()
end)

createToggleButton(mainList, "Early Bus Jump", false, function(state)
	UI.SetAutoEarlyBusJump(state)
end)

createToggleButton(mainList, "Auto Rejoin", false, function(state)
	UI.SetAutoRejoin(state)
end)

createToggleButton(mainList, "Infinite jump", false, function(state)
	UI.SetInfiniteJump(state)
end)

do
	local itemsDropdown = createSideDropdown(
		itemsList,
		"Item Teleports",
		updateItemsCanvas,
		"Shows available items and moves you to them."
	)

	do
		local warning = createWarningLabel(itemsDropdown, "TRY NOT TO MOVE")
		warning.LayoutOrder = 0
	end

	do
		local dropdown = createSideDropdown(
			teleportList,
			"Map Locations",
			updateTeleportCanvas,
			"Moves you to a selected map location."
		)

		createSmallButton(dropdown, "Teleport On School Bus", function()
			Teleport.ToSchoolBusTop()
		end)

		for _, location in ipairs(Teleport.Locations) do
			createSmallButton(dropdown, location.Name, function()
				Teleport.ToLocation(location.Name, location.Position)
			end)
		end
	end

local CollectionService = Services.CollectionService

local COLLECTIBLE_TAG = "CollectibleItem"

local AUTO_COLLECT_POSITION_RADIUS = 8

local visitedCollectPositions = {}
local movementSave = nil
local autoSortEnabled = false
local autoSortConnections = {}
local autoSortBusy = false
local autoSortSuppressUntil = 0
local autoSortKnownTools = {}
local autoSortQueued = false
local autoPermanentEnabled = false
local autoPermanentThread = nil
local autoPermanentToggle = nil
local runAutoUsePermanentItems = nil
local lastAutoPermanentUseAt = 0
local autoPermanentSeenAt = {}
local toolUseBusy = false
local lastToolUseAt = 0
local TOOL_USE_SPACING = 0.1
local AUTO_PERMANENT_USE_DEBOUNCE = 0.1

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
	"True Power",
	"Bombs"
}

local autoCollectPriority = {
	"True Power",
	"Potion of Strength",
	"Bull's Essence",
	"Boba",
	"Speed Potion",
	"Frog Potion",
	"Sphere of Fury",
	"Tomahawk",
	"Gravitation Shard",
	"Healing Potion",
	"First Aid Kit",
	"Cube of Ice",
	"Bomb",
	"Bombs",
	"Bandage",
	"Apple",
	"Forcefield Crystal",
	"Lightning Potion"
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

local function getStrictItemMatchObject(object, wantedName)
	local current = object

	while current and current ~= workspace do
		if strictItemNameMatches(current.Name, wantedName) then
			return current
		end

		current = current.Parent
	end

	return nil
end

local function itemNameMatches(object, wantedName)
	return getStrictItemMatchObject(object, wantedName) ~= nil
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
		return
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

local collectibleSearchPoolCache = {}
local collectibleSearchPoolCacheAt = 0
local COLLECTIBLE_POOL_CACHE_TIME = 0.2

local function getCollectibleSearchPool()
	local now = os.clock()

	if now - collectibleSearchPoolCacheAt <= COLLECTIBLE_POOL_CACHE_TIME then
		return collectibleSearchPoolCache
	end

	local taggedItems = CollectionService:GetTagged(COLLECTIBLE_TAG)

	if #taggedItems > 0 then
		collectibleSearchPoolCache = taggedItems
		collectibleSearchPoolCacheAt = now
		return collectibleSearchPoolCache
	end

	collectibleSearchPoolCache = Items.GetSearchDescendants()
	collectibleSearchPoolCacheAt = now
	return collectibleSearchPoolCache
end

local primaryCollectOrder

local function getFullCollectibleSearchPool()
	local results = {}
	local seen = {}

	for _, object in ipairs(CollectionService:GetTagged(COLLECTIBLE_TAG)) do
		if not seen[object] then
			seen[object] = true
			table.insert(results, object)
		end
	end

	for _, object in ipairs(Items.GetSearchDescendants()) do
		if not seen[object] then
			seen[object] = true
			table.insert(results, object)
		end
	end

	return results
end

local function getImmediateCollectibleSearchPool()
	local results = {}
	local seen = {}

	local function add(object)
		if object and not seen[object] then
			seen[object] = true
			table.insert(results, object)
		end
	end

	for _, object in ipairs(CollectionService:GetTagged(COLLECTIBLE_TAG)) do
		add(object)
	end

	for _, rootName in ipairs({ "Items", "ItemDrops", "Drops", "Loot" }) do
		local root = workspace:FindFirstChild(rootName)

		if root then
			add(root)

			for _, object in ipairs(root:GetDescendants()) do
				add(object)
			end
		end
	end

	for _, object in ipairs(Items.GetSearchDescendants()) do
		add(object)
	end

	return results
end

primaryCollectOrder = {
	"True Power",
	"Potion of Strength",
	"Bull's Essence",
	"Boba",
	"Speed Potion"
}

Items.PermanentCollectStopOrder = {
	"True Power",
	"Potion of Strength",
	"Bull's Essence",
	"Boba",
	"Speed Potion"
}

local secondaryCollectOrder = {
	"Sphere of Fury",
	"Tomahawk",
	"Gravitation Shard",
	"Healing Potion",
	"First Aid Kit",
	"Cube of Ice",
	"Bomb",
	"Bombs",
	"Bandage",
	"Apple",
	"Forcefield Crystal",
	"Lightning Potion"
}

local pinnedItemOrder = primaryCollectOrder

local PINNED_COLLECTION_SWITCH_PERCENT = 1
local searchAllItemsUnlocked = false
local pinnedItemsEverSeen = false

local function setItemSearchTargets(itemList)
	Items.SearchNameLookup = {}

	for _, itemName in ipairs(itemList) do
		Items.SearchNameLookup[normalizeName(itemName)] = true

		local aliases = itemNameAliases[itemName]
		if aliases then
			for _, alias in ipairs(aliases) do
				Items.SearchNameLookup[normalizeName(alias)] = true
			end
		end
	end

	Items.SearchCache = {}
	Items.LastSearchCacheAt = 0
	Items.SearchCacheDirty = true
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
		if Items.SearchCacheBusy and Items.LastSearchCacheAt == 0 then
			return 0
		end

		return 1
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

local function findLiveItemByName(wantedName, allowVisited)
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

			if part and (allowVisited or not isVisitedCollectPosition(part.Position)) then
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

function Items.GetPermanentCollectStatus()
	local remaining = 0
	local total = 0

	for _, wantedName in ipairs(Items.PermanentCollectStopOrder) do
		for _, object in ipairs(getFullCollectibleSearchPool()) do
			if itemNameMatches(object, wantedName) then
				total += 1

				if getLiveItemPart(object) then
					remaining += 1
				end
			end
		end
	end

	return remaining, total
end

function Items.ShouldFinishEarlyAutoCollectPermanents()
	local remaining, total = Items.GetPermanentCollectStatus()

	if total > 0 then
		Items.EarlyAutoCollectPermanentSeen = true
	end

	if remaining > 0 or not Items.EarlyAutoCollectPermanentSeen then
		Items.EarlyAutoCollectConfirmingPermanents = false
		Items.EarlyAutoCollectConfirmCount = 0
		return false
	end

	if not Items.EarlyAutoCollectConfirmingPermanents then
		Items.EarlyAutoCollectConfirmingPermanents = true
		Items.EarlyAutoCollectConfirmCount = 1
		Items.EarlyAutoCollectConfirmAt = os.clock() + 0.35
		Items.RebuildSearchCache()
		return false
	end

	if Items.SearchCacheBusy or os.clock() < (Items.EarlyAutoCollectConfirmAt or 0) then
		return false
	end

	local checkRemaining, checkTotal = Items.GetPermanentCollectStatus()

	if checkTotal > 0 then
		Items.EarlyAutoCollectPermanentSeen = true
	end

	if checkRemaining > 0 then
		Items.EarlyAutoCollectConfirmingPermanents = false
		Items.EarlyAutoCollectConfirmCount = 0
		return false
	end

	Items.EarlyAutoCollectConfirmCount = (Items.EarlyAutoCollectConfirmCount or 1) + 1

	if Items.EarlyAutoCollectConfirmCount < 3 then
		Items.EarlyAutoCollectConfirmAt = os.clock() + 0.35
		Items.RebuildSearchCache()
		return false
	end

	return true
end

local function findNextCollectTarget()
	local collectOrder = primaryCollectOrder

	for _, wantedName in ipairs(collectOrder) do
		local itemName, _, _, itemObject, itemPart = findLiveItemByName(wantedName)

		if itemName and itemObject and itemPart then
			return itemName, itemPart.CFrame, itemPart.Position, itemObject, itemPart
		end
	end

	for _, wantedName in ipairs(collectOrder) do
		local itemName, _, _, itemObject, itemPart = findLiveItemByName(wantedName, true)

		if itemName and itemObject and itemPart then
			return itemName, itemPart.CFrame, itemPart.Position, itemObject, itemPart
		end
	end

	return nil, nil, nil, nil, nil
end

local function findImmediatePriorityCollectTarget()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return nil, nil, nil, nil, nil
	end

	for _, wantedName in ipairs(primaryCollectOrder) do
		local manualObject, manualPart = Items.FindManualItem(wantedName)

		if manualObject and manualPart and getLiveItemPart(manualObject) == manualPart then
			return wantedName, manualPart.CFrame, manualPart.Position, manualObject, manualPart
		end
	end

	for _, wantedName in ipairs(primaryCollectOrder) do
		local closestObject = nil
		local closestPart = nil
		local closestDistance = math.huge

		for _, object in ipairs(getImmediateCollectibleSearchPool()) do
			if itemNameMatches(object, wantedName) then
				local part = getLiveItemPart(object)

				if part then
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
	end

	return nil, nil, nil, nil, nil
end

local function isItemScanLoading()
	return Items.SearchCacheBusy or Items.LastSearchCacheAt == 0
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

local pressF

function UI.TeleportToEarlyBusPriorityItem(forceRestart)
	if Items.EarlyBusPriorityTeleportBusy and not forceRestart then
		return
	end

	Items.EarlyBusPriorityTeleportBusy = true
	Items.EarlyBusPriorityTeleportToken = (Items.EarlyBusPriorityTeleportToken or 0) + 1
	local teleportToken = Items.EarlyBusPriorityTeleportToken

	task.spawn(function()
		Items.LastEarlyBusPriorityTeleportAt = os.clock()
		createNotification("Early Bus Jump", "Finding first priority item to land on.", "Info")

		local itemName, itemCFrame, itemPosition, itemObject, itemPart = nil, nil, nil, nil, nil
		local findUntil = os.clock() + 18
		local postLandingLockActive = false

		repeat
			if Items.EarlyBusPriorityTeleportToken ~= teleportToken then
				return
			end

			Items.RebuildSearchCache()
			itemName, itemCFrame, itemPosition, itemObject, itemPart = findImmediatePriorityCollectTarget()

			if not itemName then
				itemName, itemCFrame, itemPosition, itemObject, itemPart = findNextCollectTarget()
			end

			if itemName and itemPart and isSameItemStillThere(itemObject, itemPart, itemName) then
				break
			end

			task.wait(0.1)
		until os.clock() >= findUntil

		if itemName and itemPart and isSameItemStillThere(itemObject, itemPart, itemName) then
			local character = player.Character or player.CharacterAdded:Wait()
			local root = character:WaitForChild("HumanoidRootPart", 5)

			if root then
				local groundCFrame = Teleport.GetItemCFrame(itemPart, { character, itemObject })

				if groundCFrame then
					Teleport.MoveRoot(root, groundCFrame, itemPart.Position)
					task.wait(0.08)

					if (root.Position - groundCFrame.Position).Magnitude > 12 then
						root.CFrame = groundCFrame
					end

					local landedAt = os.clock()
					local pressAt = landedAt + 10
					local nextTeleportAt = pressAt + 1

					postLandingLockActive = true
					Items.EarlyBusFBlockActive = true
					Items.EarlyAutoCollectPauseUntil = nextTeleportAt
					Teleport.BlockFUntil = math.max(Teleport.BlockFUntil, pressAt)
					Teleport.RefreshPickupLock()

					task.delay(math.max(0.05, pressAt - os.clock()), function()
						if Items.EarlyBusPriorityTeleportToken ~= teleportToken then
							return
						end

						if isSameItemStillThere(itemObject, itemPart, itemName) then
							Items.TryPickupPrompt(itemObject, itemPart)
						end

						pressF(true)
						Items.EarlyBusFBlockActive = false
						if Teleport.BlockFUntil <= pressAt + 1 then
							Teleport.BlockFUntil = 0
						end
						Teleport.RefreshPickupLock()
						createNotification("Early Bus Jump", "Pressed F. Next item teleport starts in 1 second.", "Info")
					end)
				else
					createNotification("Early Bus Jump", "Could not compute item landing position.", "Error")
				end

				task.delay(0.05, function()
					Teleport.StabilizeItemView(root, itemPart)
				end)
				Teleport.AddStrike()
				Teleport.MaxStrikes = 4
				Teleport.Cooldown = 3
				Teleport.PostFLock = 0.3
				Items.TeleportDebounce = 0.5
				createNotification("Early Bus Jump", "Teleported to " .. itemName .. ".", "Success")
			end
		else
			createNotification("Early Bus Jump", "No priority item was ready to teleport to.", "Warning")
		end

		if not postLandingLockActive then
			Items.EarlyBusFBlockActive = false
		end

		task.wait(1)

		if Items.EarlyBusPriorityTeleportToken == teleportToken then
			Items.EarlyBusPriorityTeleportBusy = false
		end
	end)
end

function pressF(skipPickupLock)
	local VirtualInputManager = game:GetService("VirtualInputManager")

	pcall(function()
		while not skipPickupLock and Items.EarlyAutoCollectEnabled and os.clock() < Teleport.BlockFUntil do
			task.wait(0.03)
		end

		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
		task.wait(0.05)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
	end)
end

function Items.TryPickupPrompt(itemObject, itemPart)
	local promptList = {}

	local function addPrompts(root)
		if not root then
			return
		end

		if root:IsA("ProximityPrompt") then
			table.insert(promptList, root)
			return
		end

		for _, descendant in ipairs(root:GetDescendants()) do
			if descendant:IsA("ProximityPrompt") then
				table.insert(promptList, descendant)
			end
		end
	end

	addPrompts(itemObject)
	addPrompts(itemPart)

	for _, prompt in ipairs(promptList) do
		if prompt.Enabled and prompt.Parent then
			pcall(function()
				if type(fireproximityprompt) == "function" then
					fireproximityprompt(prompt)
				else
					prompt:InputHoldBegin()
					task.wait(math.max(prompt.HoldDuration, 0.05))
					prompt:InputHoldEnd()
				end
			end)
		end
	end
end

function Items.GetAutoPickupRoot()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

function Items.FindAutoPickupItemFromPart(touchedPart)
	if not touchedPart or not touchedPart.Parent then
		return nil
	end

	for _, object in ipairs(getCollectibleSearchPool()) do
		local itemPart = getLiveItemPart(object)

		if itemPart
			and (touchedPart == itemPart
				or touchedPart:IsDescendantOf(object)
				or itemPart:IsDescendantOf(touchedPart)) then
			for _, itemName in ipairs(itemNames) do
				if itemNameMatches(object, itemName) then
					return object, itemPart, itemName
				end
			end
		end
	end

	return nil
end

function Items.IsPartInsideAutoPickupZone(itemPart, root)
	if not itemPart or not itemPart.Parent or not root then
		return false
	end

	local localPosition = root.CFrame:PointToObjectSpace(itemPart.Position)
	local halfItemSize = itemPart.Size * 0.5
	local halfZoneSize = 15

	return math.abs(localPosition.X) <= halfZoneSize + halfItemSize.X
		and math.abs(localPosition.Y) <= halfZoneSize + halfItemSize.Y
		and math.abs(localPosition.Z) <= halfZoneSize + halfItemSize.Z
end

function Items.TrackAutoPickupItem(itemObject, itemPart, itemName)
	if not itemObject or not itemPart or not itemName then
		return
	end

	Items.AutoPickupTouching[itemObject] = {
		Object = itemObject,
		Part = itemPart,
		Name = itemName,
	}
end

function Items.ScanAutoPickupItems()
	local root = Items.GetAutoPickupRoot()

	if not root then
		return
	end

	for _, object in ipairs(getCollectibleSearchPool()) do
		local itemPart = getLiveItemPart(object)

		if itemPart and Items.IsPartInsideAutoPickupZone(itemPart, root) then
			for _, itemName in ipairs(itemNames) do
				if itemNameMatches(object, itemName) then
					Items.TrackAutoPickupItem(object, itemPart, itemName)
					break
				end
			end
		end
	end
end

function Items.ClearAutoPickupPart()
	if Items.AutoPickupFollowConnection then
		Items.AutoPickupFollowConnection:Disconnect()
		Items.AutoPickupFollowConnection = nil
	end

	if Items.AutoPickupTouchedConnection then
		Items.AutoPickupTouchedConnection:Disconnect()
		Items.AutoPickupTouchedConnection = nil
	end

	if Items.AutoPickupTouchEndedConnection then
		Items.AutoPickupTouchEndedConnection:Disconnect()
		Items.AutoPickupTouchEndedConnection = nil
	end

	if Items.AutoPickupPart then
		pcall(function()
			Items.AutoPickupPart:Destroy()
		end)

		Items.AutoPickupPart = nil
	end

	Items.AutoPickupTouching = {}
end

function Items.EnsureAutoPickupPart()
	local root = Items.GetAutoPickupRoot()

	if not root then
		Items.ClearAutoPickupPart()
		return nil
	end

	if Items.AutoPickupPart and Items.AutoPickupPart.Parent then
		return Items.AutoPickupPart
	end

	local pickupPart = Instance.new("Part")
	pickupPart.Name = "Part"
	pickupPart.Size = Vector3.new(30, 30, 30)
	pickupPart.Transparency = 1
	pickupPart.Anchored = true
	pickupPart.CanCollide = false
	pickupPart.CanQuery = false
	pickupPart.CanTouch = true
	pickupPart.CFrame = root.CFrame
	pickupPart.Parent = workspace

	Items.AutoPickupPart = pickupPart

	Items.AutoPickupTouchedConnection = pickupPart.Touched:Connect(function(hit)
		local itemObject, itemPart, itemName = Items.FindAutoPickupItemFromPart(hit)
		Items.TrackAutoPickupItem(itemObject, itemPart, itemName)
	end)

	Items.AutoPickupTouchEndedConnection = pickupPart.TouchEnded:Connect(function(hit)
		local itemObject = Items.FindAutoPickupItemFromPart(hit)

		if itemObject then
			Items.AutoPickupTouching[itemObject] = nil
		end
	end)

	Items.AutoPickupFollowConnection = RunService.Heartbeat:Connect(function()
		local currentRoot = Items.GetAutoPickupRoot()

		if currentRoot and pickupPart.Parent then
			pickupPart.CFrame = currentRoot.CFrame
		end
	end)

	return pickupPart
end

function Items.StartAutoPickupThread()
	if Items.AutoPickupThread then
		return
	end

	Items.AutoPickupThread = task.spawn(function()
		while Items.AutoPickupEnabled do
			Items.EnsureAutoPickupPart()
			Items.ScanAutoPickupItems()

			local root = Items.GetAutoPickupRoot()
			local shouldPressPickup = false

			for itemObject, entry in pairs(Items.AutoPickupTouching) do
				local itemPart = getLiveItemPart(itemObject)

				if not root
					or not itemPart
					or not isSameItemStillThere(itemObject, itemPart, entry.Name)
					or not Items.IsPartInsideAutoPickupZone(itemPart, root) then
					Items.AutoPickupTouching[itemObject] = nil
				else
					shouldPressPickup = true
					entry.Part = itemPart

					pcall(function()
						ProximityPromptService.Enabled = true
					end)

					Items.TryPickupPrompt(itemObject, itemPart)
				end
			end

			if shouldPressPickup then
				pressF(true)
			end

			task.wait(0.1)
		end

		Items.AutoPickupThread = nil
	end)
end

function Items.SetAutoPickup(state, silent)
	Items.AutoPickupEnabled = state == true

	if Items.AutoPickupEnabled then
		Items.EnsureAutoPickupPart()
		Items.StartAutoPickupThread()

		if not silent then
			createNotification("Auto pick up", "Auto pick up enabled.", "Success")
		end
	else
		Items.ClearAutoPickupPart()

		if not silent then
			createNotification("Auto pick up", "Auto pick up disabled.")
		end
	end
end

local function setAutoPermanentItems(state, silent)
	autoPermanentEnabled = state == true

	if autoPermanentEnabled then
		autoPermanentSeenAt = {}

		if not silent then
			createNotification("Auto Use", "Auto Use Permanent Items enabled.", "Success")
		end

		if not autoPermanentThread and runAutoUsePermanentItems then
			autoPermanentThread = task.spawn(function()
				runAutoUsePermanentItems()
				autoPermanentThread = nil
			end)
		end
	elseif not silent then
		createNotification("Auto Use", "Auto Use Permanent Items disabled.")
	end
end

function Items.DisableEarlyAutoCollectConflicts()
	Items.EarlyAutoCollectRestoreAutoPickup = false
	Items.EarlyAutoCollectRestoreAutoPermanent = false

	if Items.AutoPickupEnabled then
		Items.EarlyAutoCollectRestoreAutoPickup = true

		if Items.AutoPickupToggle then
			Items.AutoPickupToggle.Set(false, false)
		end

		Items.SetAutoPickup(false, true)
	end

	if autoPermanentEnabled then
		Items.EarlyAutoCollectRestoreAutoPermanent = true

		if autoPermanentToggle then
			autoPermanentToggle.Set(false, false)
		end

		setAutoPermanentItems(false, true)
	end
end

function Items.RestoreEarlyAutoCollectConflicts()
	if Items.EarlyAutoCollectRestoreAutoPickup then
		if Items.AutoPickupToggle then
			Items.AutoPickupToggle.Set(true, false)
		end

		Items.SetAutoPickup(true, true)
	end

	if Items.EarlyAutoCollectRestoreAutoPermanent then
		if autoPermanentToggle then
			autoPermanentToggle.Set(true, false)
		end

		setAutoPermanentItems(true, true)
	end

	Items.EarlyAutoCollectRestoreAutoPickup = false
	Items.EarlyAutoCollectRestoreAutoPermanent = false
end

function Items.EnableAutoPickupAfterEarlyAutoCollect()
	if Items.AutoPickupToggle then
		Items.AutoPickupToggle.Set(true, false)
	end

	Items.SetAutoPickup(true, true)
end

function Items.SpamPickupForEarlyAutoCollect(itemObject, itemPart, itemName, duration)
	local stopAt = os.clock() + duration

	task.spawn(function()
		while Items.EarlyAutoCollectEnabled and os.clock() < stopAt and isSameItemStillThere(itemObject, itemPart, itemName) do
			Items.TryPickupPrompt(itemObject, itemPart)
			pressF()
			task.wait(0.08)
		end
	end)
end

function Items.StopEarlyAutoCollect(message, notInLobby)
	Items.EarlyAutoCollectEnabled = false
	setMovementPaused(false)
	Items.RestoreEarlyAutoCollectConflicts()

	if notInLobby then
		Items.EarlyAutoCollectNotInLobby = true
	end

	if Items.EarlyAutoCollectToggle then
		Items.EarlyAutoCollectToggle.Set(false, false)
	end

	if message then
		createNotification("Early Auto Collect", message)
	end
end

function Items.RunEarlyAutoCollect()
	setMovementPaused(true)
	Items.EarlyAutoCollectSawTimer = false

	while Items.EarlyAutoCollectEnabled do
		local number = Main.FindSlapRoyaleTimer()

		if number then
			Items.EarlyAutoCollectSawTimer = true
			Main.TimerPrinterLastNumber = number

			if number <= 3 then
				break
			end
		elseif Items.EarlyAutoCollectSawTimer then
			break
		end

		task.wait(0.05)
	end

	if not Items.EarlyAutoCollectEnabled then
		setMovementPaused(false)
		return
	end

	Teleport.MaxStrikes = 4
	Teleport.Cooldown = 2
	Teleport.PostFLock = 0.3
	Items.TeleportDebounce = 0.5
	createNotification("Early Auto Collect", "Timer hit 3. Starting priority collection.", "Success")

	while Items.EarlyAutoCollectEnabled do
		while Items.EarlyAutoCollectEnabled and os.clock() < (Items.EarlyAutoCollectPauseUntil or 0) do
			task.wait(0.05)
		end

		if Items.EarlyAutoCollectEnabled and Items.ShouldFinishEarlyAutoCollectPermanents() then
			Items.EarlyAutoCollectEnabled = false
			setMovementPaused(false)
			Items.RestoreEarlyAutoCollectConflicts()
			Items.EnableAutoPickupAfterEarlyAutoCollect()

			if Items.EarlyAutoCollectToggle then
				Items.EarlyAutoCollectToggle.Set(false, false)
			end

			createNotification("Early Auto Collect", "Permanent items collected. Going bunker.", "Success")

			task.defer(function()
				Main.GetCodeGoBarn()
			end)

			break
		end

		local teleportWait = Teleport.GetWaitBeforeTeleport(Items.TeleportDebounce)

		if teleportWait > 0 then
			task.wait(math.clamp(teleportWait, 0.1, 0.5))
			continue
		end

		if not Teleport.CanTeleport(Items.TeleportDebounce, true, true) then
			task.wait(0.15)
			continue
		end

		local itemName, itemCFrame, itemPosition, itemObject, itemPart = findNextCollectTarget()

		if not itemName then
			task.wait(isItemScanLoading() and 0.05 or 0.1)
			continue
		end

		if not isSameItemStillThere(itemObject, itemPart, itemName) then
			markVisitedCollectPosition(itemPosition)
			task.wait(0.05)
			continue
		end

		local character = player.Character or player.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart", 5)

		if root then
			markVisitedCollectPosition(itemPosition)

			local groundCFrame = Teleport.GetItemCFrame(itemPart, { character, itemObject })

			Teleport.MoveRoot(root, groundCFrame, itemPart.Position)
			task.delay(0.05, function()
				Teleport.StabilizeItemView(root, itemPart)
			end)
			Teleport.AddStrike()
			Teleport.StartFBlock()
			createNotification("Early Auto Collect", "Collected " .. itemName)

			task.delay(0.1, function()
				if Items.EarlyAutoCollectEnabled and isSameItemStillThere(itemObject, itemPart, itemName) then
					Items.SpamPickupForEarlyAutoCollect(itemObject, itemPart, itemName, 0.45)
				end
			end)
		end

		task.wait(0.5)
	end

	setMovementPaused(false)
end

function Items.SetEarlyAutoCollect(state)
	if state then
		if Items.EarlyAutoCollectNotInLobby then
			createNotification("Early Auto Collect", "Not in lobby", "Warning")

			task.defer(function()
				if Items.EarlyAutoCollectToggle then
					Items.EarlyAutoCollectToggle.Set(false, false)
				end
			end)

			return
		end

		if Items.EarlyAutoCollectEnabled then
			return
		end

		Items.DisableEarlyAutoCollectConflicts()
		Items.EarlyAutoCollectEnabled = true
		Items.EarlyAutoCollectPauseUntil = 0
		Items.EarlyAutoCollectPermanentSeen = false
		Items.EarlyAutoCollectConfirmingPermanents = false
		Items.EarlyAutoCollectConfirmAt = 0
		Items.EarlyAutoCollectConfirmCount = 0
		visitedCollectPositions = {}
		Teleport.MaxStrikes = 4
		Teleport.Cooldown = 2
		Teleport.PostFLock = 0.3
		Items.TeleportDebounce = 0.5
		createNotification("Early Auto Collect", "Waiting for countdown to end.", "Info")

		if not Items.EarlyAutoCollectThread then
			Items.EarlyAutoCollectThread = task.spawn(function()
				Items.RunEarlyAutoCollect()
				Items.EarlyAutoCollectThread = nil
			end)
		end
	else
		Items.EarlyAutoCollectEnabled = false
		setMovementPaused(false)
		Items.RestoreEarlyAutoCollectConflicts()
		createNotification("Early Auto Collect", "Early Auto Collect disabled.")
	end
end

local autoHealEnabled = false
local autoHealThread = nil
local autoHealConnection = nil
local lastAutoHealUseAt = 0
local AUTO_HEAL_USE_DEBOUNCE = 0.1

local healingItems = {
	"First Aid Kit",
	"Healing Potion",
	"Apple",
	"Bandage",
}

local priorityHotbarItems = {
	"True Power",
	"Gravitation Shard",
	"Lightning Potion",
	"Forcefield Crystal",
	"Tomahawk"
}

local permanentUseItems = {
	"Potion of Strength",
	"Bull's Essence",
	"Boba",
	"Speed Potion",
	"Frog Potion",
}

local backpackSortItems = {
	"First Aid Kit",
	"Healing Potion",
	"Apple",
	"Bandage",
	"Sphere of Fury",
	"Cube of Ice",
	"Bomb",
	"Bombs",
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
		return math.huge
	end

	if normalizeName(tool.Name) == normalizeName("True Power") then
		return 20
	end

	if normalizeName(tool.Name) == normalizeName("Tomahawk") then
		return 21
	end

	if normalizeName(tool.Name) == normalizeName("Gravitation Shard") then
		return 22
	end

	local permanentRank = getItemOrderRank(tool.Name, permanentUseItems)
	if permanentRank then
		return 30 + permanentRank
	end

	local priorityRank = getItemOrderRank(tool.Name, priorityHotbarItems)
	if priorityRank then
		return 50 + priorityRank
	end

	local backpackRank = getItemOrderRank(tool.Name, backpackSortItems)
	if backpackRank then
		return 120 + backpackRank
	end

	for index, itemName in ipairs(itemNames) do
		if normalizeName(tool.Name) == normalizeName(itemName) then
			return 60 + index
		end
	end

	return 80
end

local function hasInventoryItemNamed(toolName)
	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character

	if backpack then
		for _, child in ipairs(backpack:GetChildren()) do
			if child:IsA("Tool") and normalizeName(child.Name) == normalizeName(toolName) then
				return true
			end
		end
	end

	if character then
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") and normalizeName(child.Name) == normalizeName(toolName) then
				return true
			end
		end
	end

	return false
end

local function sortInventory(showNotification)
	if autoSortBusy then
		return
	end

	local backpack = player:FindFirstChild("Backpack")

	if not backpack then
		if showNotification ~= false then
			createNotification("Inventory", "Backpack not found.", "Error")
		end
		return
	end

	autoSortBusy = true
	autoSortSuppressUntil = os.clock() + 2
	local tools = {}
	local holdingFolder = Instance.new("Folder")

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and not isLikelyGloveTool(tool) then
			table.insert(tools, tool)
			tool.Parent = holdingFolder
		end
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
	autoSortBusy = false
	autoSortSuppressUntil = os.clock() + 2

	for _, tool in ipairs(getInventoryTools()) do
		autoSortKnownTools[tool] = true
	end

	if showNotification ~= false then
		createNotification("Auto Sort", "Glove first, priority items next, backpack items kept later.", "Success")
	end
end

local function refreshKnownAutoSortTools()
	autoSortKnownTools = {}

	for _, tool in ipairs(getInventoryTools()) do
		autoSortKnownTools[tool] = true
	end
end

local function queueAutoSort(child, allowKnownTool)
	if not autoSortEnabled or autoSortBusy or autoSortQueued or os.clock() < autoSortSuppressUntil then
		return
	end

	if child and not child:IsA("Tool") then
		return
	end

	if child and autoSortKnownTools[child] and not allowKnownTool then
		return
	end

	if child then
		autoSortKnownTools[child] = true
	end

	autoSortQueued = true
	task.delay(0.6, function()
		autoSortQueued = false

		if autoSortEnabled and not autoSortBusy and os.clock() >= autoSortSuppressUntil then
			sortInventory(false)
		end
	end)
end

local function queueAutoSortAdded(child)
	queueAutoSort(child, false)
end

local function queueAutoSortBackpackRemoved(child)
	if not child or not child:IsA("Tool") or not matchesItem(child.Name, itemNames) then
		return
	end

	local removedName = child.Name
	task.delay(0.15, function()
		if autoSortEnabled and not hasInventoryItemNamed(removedName) then
			queueAutoSort(child, true)
		end
	end)
end

local function queueAutoSortInventoryRemoved(child)
	if not child or not child:IsA("Tool") or not matchesItem(child.Name, itemNames) then
		return
	end

	queueAutoSort(child, true)
end

local function clearAutoSortConnections()
	for _, connection in ipairs(autoSortConnections) do
		connection:Disconnect()
	end

	autoSortConnections = {}
end

local function hookAutoSort()
	clearAutoSortConnections()
	refreshKnownAutoSortTools()

	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		table.insert(autoSortConnections, backpack.ChildAdded:Connect(queueAutoSortAdded))
		table.insert(autoSortConnections, backpack.ChildRemoved:Connect(queueAutoSortBackpackRemoved))
	end

	local character = player.Character
	if character then
		table.insert(autoSortConnections, character.ChildRemoved:Connect(queueAutoSortInventoryRemoved))
	end
end

local function setAutoSort(state)
	autoSortEnabled = state == true

	if autoSortEnabled then
		sortInventory(false)
		hookAutoSort()
		createNotification("Auto Sort", "Auto Sort enabled and sorted.", "Success")
	else
		clearAutoSortConnections()
		createNotification("Auto Sort", "Auto Sort disabled.")
	end
end

function Items.CleanupAutomation()
	autoPermanentEnabled = false
	autoHealEnabled = false
	autoSortEnabled = false
	Items.AutoPickupEnabled = false
	Items.EarlyAutoCollectRestoreAutoPickup = false
	Items.EarlyAutoCollectRestoreAutoPermanent = false
	setMovementPaused(false)
	clearAutoSortConnections()
	Items.ClearAutoPickupPart()

	pcall(function()
		game:GetService("ProximityPromptService").Enabled = true
	end)

	if autoHealConnection then
		autoHealConnection:Disconnect()
		autoHealConnection = nil
	end
end

do
	local autoSortToggle = createToggleButton(itemsList, "Auto Sort", false, function(state)
		setAutoSort(state)
	end)

	autoSortToggle.Button.LayoutOrder = -9990
end

do
	Items.AutoPickupToggle = createToggleButton(itemsList, "Auto pick up", false, function(state)
		Items.SetAutoPickup(state)
	end)

	Items.AutoPickupToggle.Button.LayoutOrder = -9989
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
	if toolUseBusy then
		return false
	end

	local now = os.clock()
	if now - lastToolUseAt < TOOL_USE_SPACING then
		return false
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not tool or not tool:IsA("Tool") then
		return false
	end

	if humanoid.Health <= 0 then
		return false
	end

	toolUseBusy = true
	local used = false
	local backpack = player:FindFirstChild("Backpack")

	humanoid.PlatformStand = false
	humanoid.Sit = false
	humanoid.AutoRotate = true
	humanoid:ChangeState(Enum.HumanoidStateType.Running)

	if root then
		root.AssemblyAngularVelocity = Vector3.zero
		root.AssemblyLinearVelocity = Vector3.zero
	end

	if backpack and tool.Parent == backpack then
		humanoid:EquipTool(tool)
		task.wait(0.35)
	end

	if tool.Parent == character then
		if root then
			root.AssemblyAngularVelocity = Vector3.zero
			root.AssemblyLinearVelocity = Vector3.zero
		end

		used = pcall(function()
			tool:Activate()
		end)

		task.wait(0.45)

		if root then
			root.AssemblyAngularVelocity = Vector3.zero
			root.AssemblyLinearVelocity = Vector3.zero
		end

		humanoid.PlatformStand = false
		humanoid.Sit = false
		humanoid:ChangeState(Enum.HumanoidStateType.Running)

		lastToolUseAt = os.clock()
		task.wait(0.3)
		toolUseBusy = false
		return used
	end

	toolUseBusy = false
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
	if not autoHealEnabled or toolUseBusy or os.clock() - lastToolUseAt < TOOL_USE_SPACING then
		return
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	local now = os.clock()
	local threshold = humanoid and math.max(30, humanoid.MaxHealth * 0.45) or 30

	if humanoid and humanoid.Health > 0 and humanoid.Health <= threshold and now - lastAutoHealUseAt >= AUTO_HEAL_USE_DEBOUNCE then
		local tool = findMatchingTool(healingItems)

		if tool then
			lastAutoHealUseAt = now
			if not useTool(tool) then
				lastAutoHealUseAt = os.clock()
			end
		end
	end
end

local function tryAutoUsePermanentItem()
	if not autoPermanentEnabled or toolUseBusy or os.clock() - lastAutoPermanentUseAt < AUTO_PERMANENT_USE_DEBOUNCE then
		return false
	end

	local tool = nil
	local now = os.clock()

	for _, candidate in ipairs(getInventoryTools()) do
		if candidate:IsA("Tool") and matchesItem(candidate.Name, permanentUseItems) then
			autoPermanentSeenAt[candidate] = autoPermanentSeenAt[candidate] or now

			if now - autoPermanentSeenAt[candidate] >= AUTO_PERMANENT_USE_DEBOUNCE then
				tool = candidate
				break
			end
		end
	end

	if not tool then
		return false
	end

	lastAutoPermanentUseAt = now
	autoPermanentSeenAt[tool] = nil
	if useTool(tool) then
		return true
	end

	lastAutoPermanentUseAt = os.clock()
	return false
end

runAutoUsePermanentItems = function()
	while autoPermanentEnabled do
		tryAutoUsePermanentItem()
		task.wait(0.35)
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
local checklistLookup = {}

for _, itemName in ipairs(pinnedItemOrder) do
	pinnedLookup[normalizeName(itemName)] = true
	checklistLookup[normalizeName(itemName)] = true
	table.insert(itemChecklistOrder, itemName)
end

for _, itemName in ipairs(secondaryCollectOrder) do
	if not checklistLookup[normalizeName(itemName)] then
		checklistLookup[normalizeName(itemName)] = true
		table.insert(itemChecklistOrder, itemName)
	end
end

for _, itemName in ipairs(itemNames) do
	if not checklistLookup[normalizeName(itemName)] then
		checklistLookup[normalizeName(itemName)] = true
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

local function createItemChecklistRow(itemName, layoutOrder, showCount, leftCount, totalCount)
	local existingRow = ItemTeleportChecklist.Rows[itemName]
	local titleText = itemName

	if showCount and totalCount and totalCount > 0 then
		titleText = "[" .. tostring(leftCount) .. "/" .. tostring(totalCount) .. "] " .. itemName
	end

	if existingRow and existingRow.Parent then
		existingRow.LayoutOrder = layoutOrder

		local title = existingRow:FindFirstChild("ItemTitle")
		if title then
			title.Text = titleText
		end

		return
	end

	local row = Instance.new("Frame")
	row.Name = normalizeName(itemName):gsub("%W", "") .. "ChecklistRow"
	row.Size = UDim2.new(1, -8, 0, 68)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.LayoutOrder = layoutOrder
	row.Parent = itemsDropdown

	local title = Instance.new("TextLabel")
	title.Name = "ItemTitle"
	title.Size = UDim2.new(1, -104, 0, 42)
	title.Position = UDim2.fromOffset(6, 0)
	title.BackgroundTransparency = 1
	title.Text = titleText
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
	local existingRow = ItemTeleportChecklist.Rows.NoItemsFound

	if existingRow and existingRow.Parent then
		existingRow.LayoutOrder = layoutOrder
		return
	end

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

	local layoutOrder = 10
	local shown = 0
	local seenRows = {}

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
			seenRows[itemName] = true
			layoutOrder += 1
			shown += 1
		end
	end

	if shown == 0 then
		createNoItemsRow(layoutOrder)
		seenRows.NoItemsFound = true
	end

	local rowsToRemove = {}

	for rowKey, row in pairs(ItemTeleportChecklist.Rows) do
		if not seenRows[rowKey] then
			if row and row.Parent then
				row:Destroy()
			end

			table.insert(rowsToRemove, rowKey)
		end
	end

	for _, rowKey in ipairs(rowsToRemove) do
		ItemTeleportChecklist.Rows[rowKey] = nil
	end
end

task.spawn(function()
	task.wait(0.25)

	while itemsDropdown and itemsDropdown.Parent do
		refreshItemTeleportChecklist()
		task.wait(1.25)
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
			task.wait(1.5)
		end
	end)
end

ItemESP = {
	Enabled = false,
	Folder = nil,
	Rows = {},
	Thread = nil,
	RefreshDelay = 1.5
}

ItemESP.Colors = {
	Default = Color3.fromRGB(235, 245, 255),
	TruePower = Color3.fromRGB(255, 255, 255),
	Power = Color3.fromRGB(255, 72, 86),
	Speed = Color3.fromRGB(255, 226, 82),
	Jump = Color3.fromRGB(92, 170, 255),
	Heal = Color3.fromRGB(98, 255, 142),
	Defense = Color3.fromRGB(96, 245, 255),
	Utility = Color3.fromRGB(190, 116, 255),
	Danger = Color3.fromRGB(255, 145, 72)
}

ItemESP.ColorLookup = {
	[normalizeName("True Power")] = ItemESP.Colors.TruePower,
	[normalizeName("Potion of Strength")] = ItemESP.Colors.Power,
	[normalizeName("Bull's Essence")] = ItemESP.Colors.Power,
	[normalizeName("Sphere of Fury")] = ItemESP.Colors.Power,
	[normalizeName("Speed Potion")] = ItemESP.Colors.Speed,
	[normalizeName("Boba")] = ItemESP.Colors.Speed,
	[normalizeName("Frog Potion")] = ItemESP.Colors.Jump,
	[normalizeName("Healing Potion")] = ItemESP.Colors.Heal,
	[normalizeName("First Aid Kit")] = ItemESP.Colors.Heal,
	[normalizeName("Apple")] = ItemESP.Colors.Heal,
	[normalizeName("Bandage")] = ItemESP.Colors.Heal,
	[normalizeName("Forcefield Crystal")] = ItemESP.Colors.Defense,
	[normalizeName("Cube of Ice")] = ItemESP.Colors.Defense,
	[normalizeName("Gravitation Shard")] = ItemESP.Colors.Utility,
	[normalizeName("Lightning Potion")] = ItemESP.Colors.Utility,
	[normalizeName("Bomb")] = ItemESP.Colors.Danger,
	[normalizeName("Tomahawk")] = ItemESP.Colors.Danger
}

ItemESP.KnownNameLookup = {}

for _, itemName in ipairs(itemNames) do
	ItemESP.KnownNameLookup[normalizeName(itemName)] = itemName
end

function ItemESP.GetColor(itemName)
	return ItemESP.ColorLookup[normalizeName(itemName)] or ItemESP.Colors.Default
end

function ItemESP.GetKnownName(object)
	return ItemESP.KnownNameLookup[normalizeName(getItemDisplayName(object))]
end

function ItemESP.GetSearchPool()
	return getCollectibleSearchPool()
end

function ItemESP.ClearObject(object)
	local row = ItemESP.Rows[object]

	if not row then
		return
	end

	if row.Highlight then
		row.Highlight:Destroy()
	end

	if row.Billboard then
		row.Billboard:Destroy()
	end

	ItemESP.Rows[object] = nil
end

function ItemESP.Clear()
	for object in pairs(ItemESP.Rows) do
		ItemESP.ClearObject(object)
	end

	if ItemESP.Folder then
		ItemESP.Folder:Destroy()
		ItemESP.Folder = nil
	end
end

function ItemESP.EnsureFolder()
	if ItemESP.Folder and ItemESP.Folder.Parent then
		return
	end

	ItemESP.Folder = Instance.new("Folder")
	ItemESP.Folder.Name = "ItemESP"
	ItemESP.Folder.Parent = gui
end

function ItemESP.CreateOrUpdate(object, itemName, part)
	ItemESP.EnsureFolder()

	local color = ItemESP.GetColor(itemName)
	local row = ItemESP.Rows[object]

	if not row then
		row = {}
		ItemESP.Rows[object] = row

		row.Highlight = Instance.new("Highlight")
		row.Highlight.Name = "OPItemESPHighlight"
		row.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		row.Highlight.FillTransparency = 0.72
		row.Highlight.OutlineTransparency = 0
		row.Highlight.Parent = ItemESP.Folder

		row.Billboard = Instance.new("BillboardGui")
		row.Billboard.Name = "OPItemESPName"
		row.Billboard.Size = UDim2.fromOffset(240, 48)
		row.Billboard.StudsOffset = Vector3.new(0, 3.2, 0)
		row.Billboard.AlwaysOnTop = true
		row.Billboard.MaxDistance = 1200
		row.Billboard.Parent = ItemESP.Folder

		row.Label = Instance.new("TextLabel")
		row.Label.Size = UDim2.fromScale(1, 1)
		row.Label.BackgroundTransparency = 1
		row.Label.Font = Enum.Font.GothamBlack
		row.Label.TextSize = 20
		row.Label.TextStrokeTransparency = 0.12
		row.Label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		row.Label.TextWrapped = true
		row.Label.Parent = row.Billboard
	end

	local highlightAdornee = object:IsA("Model") and object or part

	if row.Highlight.Adornee ~= highlightAdornee then
		row.Highlight.Adornee = highlightAdornee
	end

	if row.Highlight.FillColor ~= color then
		row.Highlight.FillColor = color
	end

	if row.Highlight.OutlineColor ~= color then
		row.Highlight.OutlineColor = color
	end

	if row.Billboard.Adornee ~= part then
		row.Billboard.Adornee = part
	end

	if row.Label.Text ~= itemName then
		row.Label.Text = itemName
	end

	if row.Label.TextColor3 ~= color then
		row.Label.TextColor3 = color
	end
end

function ItemESP.Refresh()
	local seen = {}

	for _, object in ipairs(ItemESP.GetSearchPool()) do
		local itemName = ItemESP.GetKnownName(object)

		if itemName then
			local part = getLiveItemPart(object)

			if part then
				seen[object] = true
				ItemESP.CreateOrUpdate(object, itemName, part)
			end
		end
	end

	for object in pairs(ItemESP.Rows) do
		if not seen[object] then
			ItemESP.ClearObject(object)
		end
	end
end

function ItemESP.Start()
	if ItemESP.Thread then
		return
	end

	ItemESP.Thread = task.spawn(function()
		while ItemESP.Enabled do
			ItemESP.Refresh()
			task.wait(ItemESP.RefreshDelay)
		end

		ItemESP.Thread = nil
	end)
end

function ItemESP.SetEnabled(state)
	ItemESP.Enabled = state

	if state then
		ItemESP.Start()
		ItemESP.Refresh()
	else
		ItemESP.Clear()
	end
end

do
	local toggle = createToggleButton(itemsList, "Auto Heal", false, function(state)
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

	toggle.Button.LayoutOrder = -9980
end

autoPermanentToggle = createToggleButton(itemsList, "Auto Use Permanent Items", false, function(state)
	setAutoPermanentItems(state, false)
end)
autoPermanentToggle.Button.LayoutOrder = -9970

player.CharacterAdded:Connect(function()
	task.wait(0.25)

	if autoHealEnabled then
		hookAutoHealCharacter()
	end

	if autoSortEnabled then
		hookAutoSort()
	end
end)

end

Combat = {
	HitboxSize = 10,
	HitboxMinSize = 10,
	HitboxMaxSize = 20,
	HitboxTransparency = 0.7,
	HitboxColor = Color3.fromRGB(0, 170, 255),
	HitboxExpanded = false,
	HitboxVisible = true,
	SavedHitboxes = {},
	HitboxConnection = nil,
	HitboxRefreshInterval = 0.15,
	LastHitboxRefresh = 0,
	PlayerTpButtonsEnabled = false,
	PlayerTpButtonGuis = {},
	PlayerTpButtonConnections = {},
	PlayerTpButtonPlayerConnections = {},
	PlayerTpButtonPlayerAddedConnection = nil,
	AutoGloveTapEnabled = false,
	AutoGloveTapConnection = nil,
	AutoGloveTapThread = nil,
	AutoGloveTapDebounce = 0.12,
	AutoGloveTapScanInterval = 0.12,
	LastAutoGloveTap = 0,
	LastAutoGloveScan = 0,
	GloveTpSlapEnabled = false,
	GloveTpSlapConnections = {},
	GloveTpSlapCharacterConnections = {},
	GloveTpSlapCharacterAddedConnection = nil,
	LastGloveTpSlap = 0,
	LastGloveTpSlapWarning = 0,
	GloveTpSlapBusy = false,
	GloveTpSlapInternalActivate = false,
	GloveTpSlapHoldTime = 0.5,
	GloveTpSlapDebounce = 1,
	GloveTpSlapActionName = "GloveTpSlapClickBlock",
	CollectCratesEnabled = false,
	CollectCratesConnections = {},
	CollectCratesCharacterConnections = {},
	CollectCratesCharacterAddedConnection = nil,
	CollectCratesBusy = false,
	LastCollectCrateSlap = 0,
	CollectCratesDebounce = 0.35,
	AntiSlapEnabled = false,
	AntiSlapConnections = {},
	AntiSlapBoxFolder = nil,
	AntiSlapWasRagdolled = false,
	AntiSlapEnabledAt = 0,
	AntiSlapActiveUntil = 0,
	LastAntiSlapBoxAt = 0,
	LastAntiSlapCheckAt = 0,
	AntiSlapCheckInterval = 0.12,
	AntiSlapBoxDuration = 1,
	GloveSizeScale = 1,
	GloveSizeMin = 1,
	GloveSizeMax = 8,
	GloveSizeStep = 0.25,
	GloveSizeOriginals = {},
	GloveSizeLabel = nil,
	GloveSizeConnections = {},
	GloveSizeCharacterAddedConnection = nil
}

Combat.KnownItemToolLookup = {}

for _, itemName in ipairs({
	"Apple",
	"Bandage",
	"Boba",
	"Bomb",
	"Bull's Essence",
	"Bull's essence",
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
	"Sphere of fury",
	"Tomahawk",
	"True Power",
	"Bombs"
}) do
	Combat.KnownItemToolLookup[Utility.NormalizeName(itemName)] = true
end

function Combat.IsKnownItemToolName(toolName)
	if not toolName then
		return false
	end

	return Combat.KnownItemToolLookup[Utility.NormalizeName(toolName)] == true
end

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

	local humanoid = Combat.GetPlayerHumanoid(otherPlayer)
	if not humanoid or humanoid.Health <= 0 then
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

	Combat.HitboxConnection = RunService.Heartbeat:Connect(function()
		if not Combat.HitboxExpanded then
			return
		end

		local now = os.clock()
		if now - Combat.LastHitboxRefresh < Combat.HitboxRefreshInterval then
			return
		end

		Combat.LastHitboxRefresh = now

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

function Combat.ClearPlayerTpButtons()
	for _, connection in ipairs(Combat.PlayerTpButtonConnections) do
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	for _, billboard in pairs(Combat.PlayerTpButtonGuis) do
		if billboard and billboard.Parent then
			pcall(function()
				billboard:Destroy()
			end)
		end
	end

	for _, connection in ipairs(Combat.PlayerTpButtonPlayerConnections) do
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	if Combat.PlayerTpButtonPlayerAddedConnection then
		pcall(function()
			Combat.PlayerTpButtonPlayerAddedConnection:Disconnect()
		end)
		Combat.PlayerTpButtonPlayerAddedConnection = nil
	end

	Combat.PlayerTpButtonConnections = {}
	Combat.PlayerTpButtonGuis = {}
	Combat.PlayerTpButtonPlayerConnections = {}
end

function Combat.ApplyPlayerTpButton(otherPlayer)
	if not Combat.PlayerTpButtonsEnabled or otherPlayer == player then
		return
	end

	local character = otherPlayer.Character
	local head = character and character:FindFirstChild("Head")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not character or not head or not humanoid or humanoid.Health <= 0 then
		return
	end

	local existing = Combat.PlayerTpButtonGuis[otherPlayer]
	if existing and existing.Parent and existing.Adornee == head then
		return
	elseif existing then
		pcall(function()
			existing:Destroy()
		end)
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = otherPlayer.Name .. "_PlayerTeleportButton"
	billboard.Size = UDim2.fromOffset(360, 280)
	billboard.StudsOffset = Vector3.new(0, 5.2, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 1000000000
	billboard.Active = true
	billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	billboard.Adornee = head
	billboard.Parent = gui

	local button = Instance.new("TextButton")
	button.Name = "TeleportButton"
	button.Size = UDim2.fromOffset(190, 46)
	button.Position = UDim2.new(0.5, -95, 0, 0)
	button.BackgroundColor3 = Color3.fromRGB(5, 8, 14)
	button.BackgroundTransparency = 0
	button.BorderSizePixel = 0
	button.Text = "TELEPORT"
	button.Font = Enum.Font.GothamBlack
	button.TextSize = 21
	button.TextColor3 = Color3.fromRGB(230, 250, 255)
	button.TextStrokeTransparency = 0
	button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	button.AutoButtonColor = true
	button.Active = true
	button.Selectable = true
	button.ZIndex = 50
	button.Parent = billboard
	addCorner(button, 8)
	addStroke(button, Color3.fromRGB(0, 0, 0), 4)

	local accent = Instance.new("Frame")
	accent.Name = "AccentLine"
	accent.Size = UDim2.new(1, -18, 0, 4)
	accent.Position = UDim2.new(0, 9, 1, -9)
	accent.BorderSizePixel = 0
	accent.BackgroundColor3 = Color3.fromRGB(80, 220, 255)
	accent.ZIndex = 51
	accent.Parent = button
	addCorner(accent, 3)

	Combat.PlayerTpButtonGuis[otherPlayer] = billboard

	local function teleportToButtonPlayer()
		if Combat.PlayerTpButtonsEnabled then
			Combat.TeleportToPlayer(otherPlayer)
		end
	end

	table.insert(Combat.PlayerTpButtonConnections, button.Activated:Connect(teleportToButtonPlayer))
	table.insert(Combat.PlayerTpButtonConnections, button.MouseButton1Click:Connect(teleportToButtonPlayer))
	table.insert(Combat.PlayerTpButtonConnections, humanoid.Died:Connect(function()
		if Combat.PlayerTpButtonGuis[otherPlayer] == billboard then
			Combat.PlayerTpButtonGuis[otherPlayer] = nil
		end

		if billboard and billboard.Parent then
			billboard:Destroy()
		end
	end))
end

function Combat.RefreshPlayerTpButtons()
	if not Combat.PlayerTpButtonsEnabled then
		Combat.ClearPlayerTpButtons()
		return
	end

	Combat.ClearPlayerTpButtons()

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		Combat.ApplyPlayerTpButton(otherPlayer)

		if otherPlayer ~= player then
			table.insert(Combat.PlayerTpButtonPlayerConnections, otherPlayer.CharacterAdded:Connect(function()
				task.wait(0.75)
				Combat.ApplyPlayerTpButton(otherPlayer)
			end))
		end
	end

	if not Combat.PlayerTpButtonPlayerAddedConnection then
		Combat.PlayerTpButtonPlayerAddedConnection = Players.PlayerAdded:Connect(function(otherPlayer)
			table.insert(Combat.PlayerTpButtonPlayerConnections, otherPlayer.CharacterAdded:Connect(function()
				task.wait(0.75)
				Combat.ApplyPlayerTpButton(otherPlayer)
			end))

			task.defer(function()
				task.wait(0.75)
				Combat.ApplyPlayerTpButton(otherPlayer)
			end)
		end)
	end

	table.insert(Combat.PlayerTpButtonPlayerConnections, Players.PlayerRemoving:Connect(function(otherPlayer)
		local billboard = Combat.PlayerTpButtonGuis[otherPlayer]
		Combat.PlayerTpButtonGuis[otherPlayer] = nil

		if billboard and billboard.Parent then
			billboard:Destroy()
		end
	end))
end

function Combat.SetPlayerTpButtons(state)
	Combat.PlayerTpButtonsEnabled = state == true

	if Combat.PlayerTpButtonsEnabled then
		Combat.RefreshPlayerTpButtons()
		createNotification("Player TP Buttons", "Player TP Buttons enabled.", "Success")
	else
		Combat.ClearPlayerTpButtons()
		createNotification("Player TP Buttons", "Player TP Buttons disabled.")
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

function Combat.HasStrictTruthyStatus(object, statusNames)
	if not object then
		return false
	end

	for _, statusName in ipairs(statusNames) do
		local attribute = object:GetAttribute(statusName)
		if attribute == true or attribute == 1 or attribute == "true" then
			return true
		end
		if typeof(attribute) == "string" and string.lower(attribute) == "true" then
			return true
		end

		local statusObject = object:FindFirstChild(statusName, true)
		if statusObject then
			if statusObject:IsA("BoolValue") then
				if statusObject.Value == true then
					return true
				end
			elseif statusObject:IsA("NumberValue") or statusObject:IsA("IntValue") then
				if statusObject.Value ~= 0 then
					return true
				end
			elseif statusObject:IsA("StringValue") then
				local value = string.lower(statusObject.Value)
				if value == "true" or value == "ragdoll" or value == "ragdolled" then
					return true
				end
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
	if not object or not object:IsA("BasePart") then
		return false
	end

	local name = Utility.NormalizeName(object.Name)
	return string.find(name, "glove")
		or string.find(name, "hand")
		or string.find(name, "handle")
end

function Combat.GetAutoTapHitboxSize(root)
	if not root then
		return Vector3.new(Combat.HitboxSize, Combat.HitboxSize, Combat.HitboxSize)
	end

	return Vector3.new(
		math.max(root.Size.X, Combat.HitboxSize),
		math.max(root.Size.Y, Combat.HitboxSize),
		math.max(root.Size.Z, Combat.HitboxSize)
	)
end

function Combat.GetAutoTapOverlapParams(parts)
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = parts

	local ok = pcall(function()
		params.FilterType = Enum.RaycastFilterType.Include
	end)

	if not ok then
		pcall(function()
			params.FilterType = Enum.RaycastFilterType.Whitelist
		end)
	end

	return params
end

function Combat.GetAutoTapGlovePadding(parts)
	local padding = 2

	for _, part in ipairs(parts) do
		if part and part.Parent then
			local size = part.Size
			padding = math.max(padding, math.max(size.X, size.Y, size.Z) * 0.5)
		end
	end

	return padding
end

function Combat.GetEquippedGloveParts(tool)
	local parts = {}

	if not Combat.IsEquippedGloveTool(tool) then
		return parts
	end

	for _, object in ipairs(tool:GetDescendants()) do
		if object:IsA("BasePart") then
			table.insert(parts, object)
		end
	end

	return parts
end

function Combat.GetCharacterGloveParts(character)
	local parts = {}
	local seen = {}

	if not character then
		return parts
	end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Tool") and not Combat.IsKnownItemToolName(child.Name) then
			for _, object in ipairs(child:GetDescendants()) do
				if object:IsA("BasePart") and not seen[object] then
					seen[object] = true
					table.insert(parts, object)
				end
			end
		end
	end

	for _, object in ipairs(character:GetDescendants()) do
		if Combat.IsGlovePart(object) and not seen[object] then
			seen[object] = true
			table.insert(parts, object)
		end
	end

	return parts
end

function Combat.IsPartInsideHitbox(part, hitboxRoot, hitboxSize, padding)
	if not part or not part.Parent or not hitboxRoot or not hitboxRoot.Parent then
		return false
	end

	local localPosition = hitboxRoot.CFrame:PointToObjectSpace(part.Position)
	local halfSize = hitboxSize * 0.5
	local partPadding = padding or (math.max(part.Size.X, part.Size.Y, part.Size.Z) * 0.5)

	return math.abs(localPosition.X) <= halfSize.X + partPadding
		and math.abs(localPosition.Y) <= halfSize.Y + partPadding
		and math.abs(localPosition.Z) <= halfSize.Z + partPadding
end

function Combat.ArePartsInsideHitbox(parts, hitboxRoot)
	if #parts == 0 or not hitboxRoot then
		return false
	end

	local hitboxSize = Combat.GetAutoTapHitboxSize(hitboxRoot)
	local padding = Combat.GetAutoTapGlovePadding(parts)

	local ok, touchingParts = pcall(function()
		return workspace:GetPartBoundsInBox(hitboxRoot.CFrame, hitboxSize + Vector3.new(padding * 2, padding * 2, padding * 2), Combat.GetAutoTapOverlapParams(parts))
	end)

	if ok and touchingParts and #touchingParts > 0 then
		return true
	end

	for _, part in ipairs(parts) do
		if Combat.IsPartInsideHitbox(part, hitboxRoot, hitboxSize, padding) then
			return true
		end
	end

	return false
end

function Combat.IsTargetInAutoTapRange(root, targetRoot)
	if not root or not targetRoot then
		return false
	end

	local targetSize = Combat.GetAutoTapHitboxSize(targetRoot)
	local targetRadius = math.max(targetSize.X, targetSize.Y, targetSize.Z) * 0.5
	local localRadius = math.max(root.Size.X, root.Size.Y, root.Size.Z) * 0.5
	local gloveReach = math.max(6, (Combat.GloveSizeScale or 1) * 4)
	local triggerDistance = targetRadius + localRadius + gloveReach

	local offset = root.Position - targetRoot.Position
	return offset:Dot(offset) <= triggerDistance * triggerDistance
end

function Combat.FindAutoGloveTapTarget()
	local tool = Combat.GetEquippedTool()
	local equippedGloveParts = Combat.GetEquippedGloveParts(tool)

	if #equippedGloveParts == 0 then
		return nil
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		local targetCharacter, _, targetRoot = Combat.IsValidAutoTapTarget(targetPlayer)

		if targetRoot and (Combat.ArePartsInsideHitbox(equippedGloveParts, targetRoot) or Combat.IsTargetInAutoTapRange(root, targetRoot)) then
			return targetPlayer
		end

		if root and targetCharacter and targetRoot and Combat.IsTargetInAutoTapRange(root, targetRoot) then
			local enemyGloveParts = Combat.GetCharacterGloveParts(targetCharacter)

			if Combat.ArePartsInsideHitbox(enemyGloveParts, root) then
				return targetPlayer
			end
		end
	end

	return nil
end

function Combat.TapEquippedGlove()
	local now = os.clock()

	if now - Combat.LastAutoGloveTap < Combat.AutoGloveTapDebounce then
		return false
	end

	local tool = Combat.GetEquippedTool()
	if not Combat.IsEquippedGloveTool(tool) then
		return false
	end

	Combat.LastAutoGloveTap = now

	pcall(function()
		tool:Activate()
	end)

	return true
end

function Combat.StartAutoGloveTap()
	if Combat.AutoGloveTapThread then
		return
	end

	Combat.AutoGloveTapThread = task.spawn(function()
		while Combat.AutoGloveTapEnabled do
			if Combat.FindAutoGloveTapTarget() then
				Combat.TapEquippedGlove()
			end

			task.wait(Combat.AutoGloveTapScanInterval)
		end

		Combat.AutoGloveTapThread = nil
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
		createNotification("Auto Slap", "Auto Slap enabled.", "Success")
	else
		Combat.StopAutoGloveTap()
		createNotification("Auto Slap", "Auto Slap disabled.")
	end
end

function Combat.ShowGloveTpSlapWarning(message)
	local now = os.clock()

	if now - Combat.LastGloveTpSlapWarning < 1.5 then
		return
	end

	Combat.LastGloveTpSlapWarning = now
	createNotification("Glove TP Slap", message, "Warning")
end

function Combat.IsEquippedGloveTool(tool)
	local character = player.Character

	if not character or not tool or not tool:IsA("Tool") or tool.Parent ~= character then
		return false
	end

	if Combat.IsKnownItemToolName(tool.Name) then
		return false
	end

	local toolName = Utility.NormalizeName(tool.Name)
	if string.find(toolName, "glove") or string.find(toolName, "slap") then
		return true
	end

	for _, object in ipairs(tool:GetDescendants()) do
		local objectName = Utility.NormalizeName(object.Name)

		if string.find(objectName, "glove") or string.find(objectName, "slap") then
			return true
		end
	end

	for _, object in ipairs(tool:GetDescendants()) do
		if object:IsA("BasePart") then
			return true
		end
	end

	return false
end

function Combat.GetNearestGloveTpSlapRoot(originPosition)
	local nearestRoot = nil
	local nearestDistance = math.huge

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		local _, humanoid, targetRoot = Combat.GetValidPlayerTarget(targetPlayer)

		if humanoid and targetRoot then
			local distance = (originPosition - targetRoot.Position).Magnitude

			if distance < nearestDistance then
				nearestDistance = distance
				nearestRoot = targetRoot
			end
		end
	end

	return nearestRoot
end

function Combat.DetachGloveTpSlapJoints(character, tool)
	local records = {}

	if not character or not tool then
		return records
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("JointInstance") or object:IsA("WeldConstraint") then
			local okPart0, part0 = pcall(function()
				return object.Part0
			end)
			local okPart1, part1 = pcall(function()
				return object.Part1
			end)

			part0 = okPart0 and part0 or nil
			part1 = okPart1 and part1 or nil

			local part0InTool = part0 and part0:IsDescendantOf(tool)
			local part1InTool = part1 and part1:IsDescendantOf(tool)

			if part0InTool ~= part1InTool then
				local record = {
					Joint = object,
					Part0 = part0,
					Part1 = part1,
					Enabled = nil,
					UsedEnabled = false
				}

				local okEnabled, enabled = pcall(function()
					return object.Enabled
				end)

				if okEnabled then
					record.Enabled = enabled
					record.UsedEnabled = pcall(function()
						object.Enabled = false
					end)
				end

				if not record.UsedEnabled then
					pcall(function()
						object.Part0 = nil
					end)
					pcall(function()
						object.Part1 = nil
					end)
				end

				table.insert(records, record)
			end
		end
	end

	return records
end

function Combat.RestoreGloveTpSlapJoints(records)
	for _, record in ipairs(records) do
		local joint = record.Joint

		if joint and joint.Parent then
			if record.UsedEnabled then
				pcall(function()
					joint.Enabled = record.Enabled
				end)
			else
				pcall(function()
					joint.Part0 = record.Part0
				end)
				pcall(function()
					joint.Part1 = record.Part1
				end)
			end
		end
	end

	if Settings and Settings.OnControlChanged then
		Settings.OnControlChanged()
	end
end

function Combat.PrepareGloveTpSlapParts(parts, root)
	local partStates = {}
	local rootCFrame = root and root.CFrame or nil

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			table.insert(partStates, {
				Part = part,
				CFrame = part.CFrame,
				RootOffset = rootCFrame and rootCFrame:ToObjectSpace(part.CFrame) or nil,
				Anchored = part.Anchored,
				CanCollide = part.CanCollide
			})

			part.Anchored = true
			part.CanCollide = false
			part.AssemblyLinearVelocity = Vector3.zero
			part.AssemblyAngularVelocity = Vector3.zero
		end
	end

	return partStates
end

function Combat.RestoreGloveTpSlapParts(partStates, root)
	for _, state in ipairs(partStates) do
		local part = state.Part

		if part and part.Parent then
			if root and root.Parent and state.RootOffset then
				part.CFrame = root.CFrame * state.RootOffset
			else
				part.CFrame = state.CFrame
			end

			part.Anchored = state.Anchored
			part.CanCollide = state.CanCollide
			part.AssemblyLinearVelocity = Vector3.zero
			part.AssemblyAngularVelocity = Vector3.zero
		end
	end
end

function Combat.GetGloveTpSlapCenterCFrame(parts)
	local totalPosition = Vector3.zero
	local count = 0

	for _, part in ipairs(parts) do
		if part:IsA("BasePart") then
			totalPosition += part.Position
			count += 1
		end
	end

	if count == 0 then
		return nil
	end

	return CFrame.new(totalPosition / count)
end

function Combat.TeleportToNearestPlayerOnGloveSlap(tool)
	local now = os.clock()

	if Combat.GloveTpSlapBusy or now - Combat.LastGloveTpSlap < Combat.GloveTpSlapDebounce then
		return
	end

	if not Combat.IsEquippedGloveTool(tool) then
		Combat.ShowGloveTpSlapWarning("Equip a glove before using Glove TP Slap.")
		return
	end

	Combat.GloveTpSlapBusy = true
	Combat.LastGloveTpSlap = now

	local teleported = Combat.TeleportToNearestPlayer()

	if not teleported then
		task.delay(Combat.GloveTpSlapDebounce, function()
			Combat.GloveTpSlapBusy = false
		end)

		return
	end

	task.delay(Combat.GloveTpSlapHoldTime, function()
		if Combat.GloveTpSlapEnabled and Combat.IsEquippedGloveTool(tool) then
			Combat.GloveTpSlapInternalActivate = true

			pcall(function()
				tool:Activate()
			end)

			task.delay(0.1, function()
				Combat.GloveTpSlapInternalActivate = false
			end)
		end
	end)

	task.delay(Combat.GloveTpSlapDebounce, function()
		Combat.GloveTpSlapBusy = false
	end)
end

function Combat.ClearGloveTpSlapHooks()
	for tool, connection in pairs(Combat.GloveTpSlapConnections) do
		if connection then
			connection:Disconnect()
		end

		Combat.GloveTpSlapConnections[tool] = nil
	end

	for _, connection in ipairs(Combat.GloveTpSlapCharacterConnections) do
		connection:Disconnect()
	end

	Combat.GloveTpSlapCharacterConnections = {}
end

function Combat.HookGloveTpSlapTool(tool)
	if not Combat.IsEquippedGloveTool(tool) or Combat.GloveTpSlapConnections[tool] then
		return
	end

	Combat.GloveTpSlapConnections[tool] = tool.Activated:Connect(function()
		if Combat.GloveTpSlapEnabled and not Combat.GloveTpSlapInternalActivate then
			Combat.TeleportToNearestPlayerOnGloveSlap(tool)
		end
	end)
end

function Combat.RefreshGloveTpSlapHooks()
	Combat.ClearGloveTpSlapHooks()

	local character = player.Character
	if not character then
		return
	end

	for _, child in ipairs(character:GetChildren()) do
		Combat.HookGloveTpSlapTool(child)
	end

	table.insert(Combat.GloveTpSlapCharacterConnections, character.ChildAdded:Connect(function(child)
		task.defer(function()
			if Combat.GloveTpSlapEnabled then
				Combat.HookGloveTpSlapTool(child)
			end
		end)
	end))

	table.insert(Combat.GloveTpSlapCharacterConnections, character.ChildRemoved:Connect(function(child)
		local connection = Combat.GloveTpSlapConnections[child]

		if connection then
			connection:Disconnect()
			Combat.GloveTpSlapConnections[child] = nil
		end
	end))
end

function Combat.StartGloveTpSlap()
	ContextActionService:BindActionAtPriority(
		Combat.GloveTpSlapActionName,
		function(_, inputState, inputObject)
			if inputState ~= Enum.UserInputState.Begin or not Combat.GloveTpSlapEnabled or Combat.GloveTpSlapInternalActivate then
				return Enum.ContextActionResult.Pass
			end

			if inputObject and inputObject.Position then
				local playerGui = player:FindFirstChildOfClass("PlayerGui")
				local ok, guiObjects = pcall(function()
					return playerGui and playerGui:GetGuiObjectsAtPosition(inputObject.Position.X, inputObject.Position.Y)
				end)

				if ok and guiObjects then
					for _, guiObject in ipairs(guiObjects) do
						if guiObject == gui or guiObject:IsDescendantOf(gui) then
							return Enum.ContextActionResult.Pass
						end
					end
				end
			end

			local tool = Combat.GetEquippedTool()
			if not Combat.IsEquippedGloveTool(tool) then
				return Enum.ContextActionResult.Pass
			end

			Combat.TeleportToNearestPlayerOnGloveSlap(tool)
			return Enum.ContextActionResult.Sink
		end,
		false,
		4000,
		Enum.UserInputType.MouseButton1,
		Enum.KeyCode.ButtonR2
	)

	if not Combat.GloveTpSlapCharacterAddedConnection then
		Combat.GloveTpSlapCharacterAddedConnection = player.CharacterAdded:Connect(function()
			task.wait(0.25)

			if Combat.GloveTpSlapEnabled then
				Combat.RefreshGloveTpSlapHooks()
			end
		end)
	end

	Combat.RefreshGloveTpSlapHooks()
end

function Combat.StopGloveTpSlap()
	ContextActionService:UnbindAction(Combat.GloveTpSlapActionName)

	if Combat.GloveTpSlapCharacterAddedConnection then
		Combat.GloveTpSlapCharacterAddedConnection:Disconnect()
		Combat.GloveTpSlapCharacterAddedConnection = nil
	end

	Combat.ClearGloveTpSlapHooks()
end

function Combat.SetGloveTpSlap(state)
	Combat.GloveTpSlapEnabled = state == true

	if Combat.GloveTpSlapEnabled then
		Combat.StartGloveTpSlap()
		createNotification("Glove TP Slap", "Glove TP Slap enabled.", "Success")
	else
		Combat.StopGloveTpSlap()
		createNotification("Glove TP Slap", "Glove TP Slap disabled.")
	end
end

function Combat.TouchCrateWithGlove(gloveParts, cratePart)
	for _, glovePart in ipairs(gloveParts) do
		pcall(function()
			if typeof(firetouchinterest) == "function" then
				firetouchinterest(glovePart, cratePart, 0)
				task.wait()
				firetouchinterest(glovePart, cratePart, 1)
			end
		end)
	end
end

function Combat.CollectCrateWithGlove(tool)
	local now = os.clock()
	if Combat.CollectCratesBusy or now - Combat.LastCollectCrateSlap < Combat.CollectCratesDebounce then
		return
	end

	Combat.CollectCratesBusy = true
	Combat.LastCollectCrateSlap = now

	if not Combat.IsEquippedGloveTool(tool) then
		Combat.CollectCratesBusy = false
		createNotification("Collect Crates", "Equip a glove before using Collect Crates.", "Warning")
		return
	end

	local crate, cratePart = Items.FindNearestCrate()
	if not crate or not cratePart then
		Combat.CollectCratesBusy = false
		Combat.SetCollectCrates(false)
		if Combat.CollectCratesToggle then
			Combat.CollectCratesToggle.Set(false, false)
		end
		createNotification("Collect Crates", "No meteor crate is spawned.", "Warning")
		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local gloveParts = Combat.GetEquippedGloveParts(tool)

	if #gloveParts == 0 then
		Combat.CollectCratesBusy = false
		createNotification("Collect Crates", "Could not find your glove parts.", "Warning")
		return
	end

	local jointRecords = Combat.DetachGloveTpSlapJoints(character, tool)
	local partStates = Combat.PrepareGloveTpSlapParts(gloveParts, root)
	local targetPosition = cratePart.Position + Vector3.new(0, (cratePart.Size.Y / 2) + 1.25, 0)

	for _, glovePart in ipairs(gloveParts) do
		if glovePart.Parent then
			glovePart.CFrame = CFrame.new(targetPosition)
			glovePart.AssemblyLinearVelocity = Vector3.zero
			glovePart.AssemblyAngularVelocity = Vector3.zero
		end
	end

	Combat.TouchCrateWithGlove(gloveParts, cratePart)

	pcall(function()
		tool:Activate()
	end)

	task.wait(0.18)
	Combat.TouchCrateWithGlove(gloveParts, cratePart)
	Combat.RestoreGloveTpSlapParts(partStates, root)
	Combat.RestoreGloveTpSlapJoints(jointRecords)

	task.delay(Combat.CollectCratesDebounce, function()
		Combat.CollectCratesBusy = false
	end)
end

function Combat.ClearCollectCrateHooks()
	for tool, connection in pairs(Combat.CollectCratesConnections) do
		if connection then
			connection:Disconnect()
		end

		Combat.CollectCratesConnections[tool] = nil
	end

	for _, connection in ipairs(Combat.CollectCratesCharacterConnections) do
		connection:Disconnect()
	end

	Combat.CollectCratesCharacterConnections = {}
end

function Combat.HookCollectCrateTool(tool)
	if not Combat.IsEquippedGloveTool(tool) or Combat.CollectCratesConnections[tool] then
		return
	end

	Combat.CollectCratesConnections[tool] = tool.Activated:Connect(function()
		if Combat.CollectCratesEnabled then
			Combat.CollectCrateWithGlove(tool)
		end
	end)
end

function Combat.RefreshCollectCrateHooks()
	Combat.ClearCollectCrateHooks()

	local character = player.Character
	if not character then
		return
	end

	for _, child in ipairs(character:GetChildren()) do
		Combat.HookCollectCrateTool(child)
	end

	table.insert(Combat.CollectCratesCharacterConnections, character.ChildAdded:Connect(function(child)
		task.defer(function()
			if Combat.CollectCratesEnabled then
				Combat.HookCollectCrateTool(child)
			end
		end)
	end))

	table.insert(Combat.CollectCratesCharacterConnections, character.ChildRemoved:Connect(function(child)
		local connection = Combat.CollectCratesConnections[child]

		if connection then
			connection:Disconnect()
			Combat.CollectCratesConnections[child] = nil
		end
	end))
end

function Combat.StartCollectCrates()
	if not Combat.CollectCratesCharacterAddedConnection then
		Combat.CollectCratesCharacterAddedConnection = player.CharacterAdded:Connect(function()
			task.wait(0.25)

			if Combat.CollectCratesEnabled then
				Combat.RefreshCollectCrateHooks()
			end
		end)
	end

	Combat.RefreshCollectCrateHooks()
end

function Combat.StopCollectCrates()
	if Combat.CollectCratesCharacterAddedConnection then
		Combat.CollectCratesCharacterAddedConnection:Disconnect()
		Combat.CollectCratesCharacterAddedConnection = nil
	end

	Combat.ClearCollectCrateHooks()
end

function Combat.SetCollectCrates(state)
	Combat.CollectCratesEnabled = state == true

	if Combat.CollectCratesEnabled then
		Combat.StartCollectCrates()
		createNotification("Collect Crates", "Collect Crates enabled.", "Success")
	else
		Combat.StopCollectCrates()
		createNotification("Collect Crates", "Collect Crates disabled.")
	end
end

function Combat.CreateAntiSlapPart(folder, cframe, size)
	local part = Instance.new("Part")
	part.Name = "Part"
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.CanCollide = true
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Parent = folder
	return part
end

function Combat.SpawnAntiSlapBox()
    if Combat.AntiSlapBoxFolder and not Combat.AntiSlapBoxFolder.Parent then
        Combat.AntiSlapBoxFolder = nil
    end

    if not Combat.AntiSlapEnabled or Combat.AntiSlapBoxFolder or os.clock() - Combat.LastAntiSlapBoxAt < 0.2 then
        return
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

	if not root then
		return
	end

	Combat.LastAntiSlapBoxAt = os.clock()

    local folder = Instance.new("Folder")
    folder.Name = "AntiSlapBox"
    folder.Parent = workspace
    Combat.AntiSlapBoxFolder = folder

    local center = root.CFrame
    local innerWidth = 8
    local innerHeight = 8
    local innerDepth = 8
	local thickness = 40
    local outerWidth = innerWidth + thickness * 2
    local outerHeight = innerHeight + thickness * 2
    local outerDepth = innerDepth + thickness * 2

	Combat.CreateAntiSlapPart(folder, center * CFrame.new(0, -(innerHeight / 2 + thickness / 2), 0), Vector3.new(outerWidth, thickness, outerDepth))
	Combat.CreateAntiSlapPart(folder, center * CFrame.new(0, innerHeight / 2 + thickness / 2, 0), Vector3.new(outerWidth, thickness, outerDepth))
    Combat.CreateAntiSlapPart(folder, center * CFrame.new(innerWidth / 2 + thickness / 2, 0, 0), Vector3.new(thickness, outerHeight, outerDepth))
    Combat.CreateAntiSlapPart(folder, center * CFrame.new(-(innerWidth / 2 + thickness / 2), 0, 0), Vector3.new(thickness, outerHeight, outerDepth))
    Combat.CreateAntiSlapPart(folder, center * CFrame.new(0, 0, innerDepth / 2 + thickness / 2), Vector3.new(outerWidth, outerHeight, thickness))
    Combat.CreateAntiSlapPart(folder, center * CFrame.new(0, 0, -(innerDepth / 2 + thickness / 2)), Vector3.new(outerWidth, outerHeight, thickness))
end

function Combat.ClearAntiSlapBox()
    if Combat.AntiSlapBoxFolder then
        Combat.AntiSlapBoxFolder:Destroy()
        Combat.AntiSlapBoxFolder = nil
    end
end

function Combat.IsLocalAntiSlapRagdolled(character, humanoid)
    if not character or not humanoid or humanoid.Health <= 0 then
        return false
    end

    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Running
        or state == Enum.HumanoidStateType.RunningNoPhysics
        or state == Enum.HumanoidStateType.Landed
        or state == Enum.HumanoidStateType.Climbing
        or state == Enum.HumanoidStateType.Swimming
        or state == Enum.HumanoidStateType.Seated
    then
        return false
    end

    local ragdollStatuses = {
        "Ragdoll",
        "Ragdolled",
        "IsRagdolled",
        "IsInRagdoll",
        "Ragdolling",
    }

    if Combat.HasStrictTruthyStatus(player, ragdollStatuses)
        or Combat.HasStrictTruthyStatus(character, ragdollStatuses)
        or Combat.HasStrictTruthyStatus(humanoid, ragdollStatuses)
    then
        return true
    end

    if state == Enum.HumanoidStateType.Ragdoll then
        return true
    end

    if state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.FallingDown then
        for _, object in ipairs(character:GetDescendants()) do
            local objectName = string.lower(object.Name)
            if string.find(objectName, "ragdoll", 1, true) then
                return true
            end

        end
    end

    return false
end

function Combat.IsLocalAntiSlapKnockbacked(character, humanoid, root)
    if not character or not humanoid or not root or humanoid.Health <= 0 then
        return false
    end

    if os.clock() - Combat.AntiSlapEnabledAt < 0.75 then
        return false
    end

    local state = humanoid:GetState()
    local slapState = humanoid.PlatformStand
        or state == Enum.HumanoidStateType.Ragdoll
        or state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.FallingDown
        or state == Enum.HumanoidStateType.GettingUp

    if not slapState then
        return false
    end

    local velocity = root.AssemblyLinearVelocity or Vector3.zero
    local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

    return horizontalVelocity >= 38 or math.abs(velocity.Y) >= 50
end

function Combat.UpdateAntiSlapBox(character, humanoid)
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local isRagdolled = Combat.AntiSlapEnabled and Combat.IsLocalAntiSlapRagdolled(character, humanoid)
    local isKnockbacked = Combat.AntiSlapEnabled and Combat.IsLocalAntiSlapKnockbacked(character, humanoid, root)
    local now = os.clock()
    local state = humanoid and humanoid:GetState()
    local recovered = state == Enum.HumanoidStateType.Running
        or state == Enum.HumanoidStateType.RunningNoPhysics
        or state == Enum.HumanoidStateType.Landed
        or state == Enum.HumanoidStateType.Climbing
        or state == Enum.HumanoidStateType.Swimming
        or state == Enum.HumanoidStateType.Seated

    if recovered then
        Combat.AntiSlapActiveUntil = 0
    end

    if not recovered and (isRagdolled or isKnockbacked) then
        Combat.AntiSlapActiveUntil = math.max(Combat.AntiSlapActiveUntil, now + 1)
    end

    local shouldBox = not recovered and (isRagdolled or isKnockbacked or now < Combat.AntiSlapActiveUntil)

    if shouldBox and (not Combat.AntiSlapWasRagdolled or (isKnockbacked and not Combat.AntiSlapBoxFolder)) then
        Combat.SpawnAntiSlapBox()
    elseif not shouldBox then
        Combat.ClearAntiSlapBox()
        Combat.AntiSlapActiveUntil = 0
    end

    Combat.AntiSlapWasRagdolled = shouldBox
end

function Combat.ClearAntiSlapConnections()
    for _, connection in ipairs(Combat.AntiSlapConnections) do
        connection:Disconnect()
	end

	Combat.AntiSlapConnections = {}
end

function Combat.HookAntiSlapCharacter()
	Combat.ClearAntiSlapConnections()

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not humanoid or not root then
        return
    end

    Combat.ClearAntiSlapBox()
    Combat.AntiSlapWasRagdolled = Combat.IsLocalAntiSlapRagdolled(character, humanoid)
    Combat.AntiSlapActiveUntil = 0

    table.insert(Combat.AntiSlapConnections, humanoid.StateChanged:Connect(function()
        Combat.UpdateAntiSlapBox(character, humanoid)
    end))

    for _, statusName in ipairs({ "Ragdoll", "Ragdolled", "IsRagdolled", "IsInRagdoll", "Ragdolling" }) do
        table.insert(Combat.AntiSlapConnections, character:GetAttributeChangedSignal(statusName):Connect(function()
            Combat.UpdateAntiSlapBox(character, humanoid)
        end))

        table.insert(Combat.AntiSlapConnections, humanoid:GetAttributeChangedSignal(statusName):Connect(function()
            Combat.UpdateAntiSlapBox(character, humanoid)
        end))

        table.insert(Combat.AntiSlapConnections, player:GetAttributeChangedSignal(statusName):Connect(function()
            Combat.UpdateAntiSlapBox(character, humanoid)
        end))
    end

    table.insert(Combat.AntiSlapConnections, character.DescendantAdded:Connect(function()
        Combat.UpdateAntiSlapBox(character, humanoid)
    end))

    table.insert(Combat.AntiSlapConnections, character.DescendantRemoving:Connect(function()
        task.defer(function()
            Combat.UpdateAntiSlapBox(character, humanoid)
        end)
    end))

    table.insert(Combat.AntiSlapConnections, RunService.Heartbeat:Connect(function()
        if not Combat.AntiSlapEnabled or not root.Parent then
            Combat.ClearAntiSlapBox()
            return
        end

        local now = os.clock()
        if now - Combat.LastAntiSlapCheckAt < Combat.AntiSlapCheckInterval then
            return
        end

        Combat.LastAntiSlapCheckAt = now
        Combat.UpdateAntiSlapBox(character, humanoid)
    end))
end

function Combat.SetAntiSlap(state)
	Combat.AntiSlapEnabled = state == true

    if Combat.AntiSlapEnabled then
        Combat.AntiSlapWasRagdolled = false
        Combat.AntiSlapEnabledAt = os.clock()
        Combat.AntiSlapActiveUntil = 0
    Combat.HookAntiSlapCharacter()
    createNotification("Anti-Ragdoll", "Anti-Ragdoll enabled.", "Success")
    else
        Combat.ClearAntiSlapConnections()
        Combat.ClearAntiSlapBox()
        Combat.AntiSlapWasRagdolled = false
        Combat.AntiSlapActiveUntil = 0
    createNotification("Anti-Ragdoll", "Anti-Ragdoll disabled.")
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

function Combat.TeleportToPlayer(targetPlayer)
	if not Teleport.CanTeleport() then
		return false
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)
	local targetCharacter, _, targetRoot = Combat.GetValidPlayerTarget(targetPlayer)

	if not root then
		createNotification("Players", "Could not find your character.", "Error")
		return false
	end

	if not targetRoot then
		createNotification("Players", "Target player is unavailable or ragdolled.", "Warning")
		return false
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
	return true
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
		return Combat.TeleportToPlayer(nearestPlayer)
	else
		createNotification("Players", "No valid nearest player found.")
	end

	return false
end

function Combat.SetHitboxSize(newSize)
	Combat.HitboxSize = math.clamp(newSize, Combat.HitboxMinSize, Combat.HitboxMaxSize)

	if Combat.HitboxSizeLabel then
		Combat.HitboxSizeLabel.Text = "Hitbox Size: " .. tostring(math.floor(Combat.HitboxSize + 0.5)) .. " / " .. tostring(Combat.HitboxMaxSize)
	end

	if Combat.HitboxExpanded then
		Combat.RefreshHitboxes()
	end

	if Settings and Settings.OnControlChanged then
		Settings.OnControlChanged()
	end
end

function Combat.GetGloveParts(tool)
	local parts = {}

	if not tool then
		return parts
	end

	local handle = tool:FindFirstChild("Handle")
	if handle and handle:IsA("BasePart") then
		table.insert(parts, handle)
	end

	for _, object in ipairs(tool:GetDescendants()) do
		if object:IsA("BasePart") and object ~= handle then
			table.insert(parts, object)
		end
	end

	return parts
end

function Combat.SaveGloveOriginal(part)
	if Combat.GloveSizeOriginals[part] then
		return
	end

	local meshes = {}
	for _, child in ipairs(part:GetChildren()) do
		if child:IsA("SpecialMesh") then
			meshes[child] = child.Scale
		end
	end

	Combat.GloveSizeOriginals[part] = {
		Size = part.Size,
		Meshes = meshes
	}
end

function Combat.RestoreGloveSize()
	for part, original in pairs(Combat.GloveSizeOriginals) do
		if part and part.Parent and original then
			pcall(function()
				part.Size = original.Size
			end)

			for mesh, originalScale in pairs(original.Meshes or {}) do
				if mesh and mesh.Parent then
					pcall(function()
						mesh.Scale = originalScale
					end)
				end
			end
		end
	end

	Combat.GloveSizeOriginals = {}
end

function Combat.ApplyGloveSize()
	local scale = Combat.GloveSizeScale
	Combat.RestoreGloveSize()
	Combat.GloveSizeScale = scale

	local character = player.Character
	local tool = character and character:FindFirstChildOfClass("Tool")

	if not tool then
		if Combat.GloveSizeLabel then
			Combat.GloveSizeLabel.Text = string.format("Glove Size: %.2fx (equip glove)", Combat.GloveSizeScale)
		end

		return false
	end

	local parts = Combat.GetGloveParts(tool)

	for _, part in ipairs(parts) do
		Combat.SaveGloveOriginal(part)

		local original = Combat.GloveSizeOriginals[part]
		if original then
			pcall(function()
				part.Size = original.Size * Combat.GloveSizeScale
			end)

			for mesh, originalScale in pairs(original.Meshes or {}) do
				if mesh and mesh.Parent then
					pcall(function()
						mesh.Scale = originalScale * Combat.GloveSizeScale
					end)
				end
			end
		end
	end

	if Combat.GloveSizeLabel then
		Combat.GloveSizeLabel.Text = string.format("Glove Size: %.2fx", Combat.GloveSizeScale)
	end

	return #parts > 0
end

function Combat.SetGloveSizeScale(newScale, showNotification)
	local steppedScale = math.floor((newScale / Combat.GloveSizeStep) + 0.5) * Combat.GloveSizeStep
	Combat.GloveSizeScale = math.clamp(steppedScale, Combat.GloveSizeMin, Combat.GloveSizeMax)

	local applied = Combat.ApplyGloveSize()

	if showNotification and not applied then
		createNotification("Glove Size", "Equip your glove first, then adjust the slider.", "Warning")
	end

	if Settings and Settings.OnControlChanged then
		Settings.OnControlChanged()
	end
end

function Combat.ClearGloveSizeHooks()
	for _, connection in ipairs(Combat.GloveSizeConnections) do
		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end
	end

	Combat.GloveSizeConnections = {}
end

function Combat.HookGloveSizeCharacter(character)
	Combat.ClearGloveSizeHooks()

	if not character then
		return
	end

	table.insert(Combat.GloveSizeConnections, character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			task.wait(0.05)
			Combat.ApplyGloveSize()
		end
	end))

	table.insert(Combat.GloveSizeConnections, character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			local scale = Combat.GloveSizeScale
			Combat.RestoreGloveSize()
			Combat.GloveSizeScale = scale
		end
	end))
end

function Combat.RefreshGloveSizeHooks()
	Combat.HookGloveSizeCharacter(player.Character)

	if not Combat.GloveSizeCharacterAddedConnection then
		Combat.GloveSizeCharacterAddedConnection = player.CharacterAdded:Connect(function(character)
			task.wait(0.25)
			Combat.HookGloveSizeCharacter(character)
			Combat.ApplyGloveSize()
		end)
	end
end

Combat.RefreshGloveSizeHooks()

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
	local hitboxDropdown = createDropdown(combatList, "Hitboxes", updateCombatCanvas)

	Combat.HitboxSizeLabel = Instance.new("TextLabel")
	Combat.HitboxSizeLabel.Size = UDim2.new(1, -10, 0, isTouchDevice and 28 or 30)
	Combat.HitboxSizeLabel.BackgroundTransparency = 1
	Combat.HitboxSizeLabel.Font = Enum.Font.GothamBlack
	Combat.HitboxSizeLabel.TextSize = isTouchDevice and 11 or 13
	Combat.HitboxSizeLabel.TextXAlignment = Enum.TextXAlignment.Center
	Combat.HitboxSizeLabel.TextYAlignment = Enum.TextYAlignment.Center
	Combat.HitboxSizeLabel.Parent = hitboxDropdown
	themeObject(Combat.HitboxSizeLabel, "TextColor3", "Text")

	local adjustRow = Instance.new("Frame")
	adjustRow.Size = UDim2.new(1, -8, 0, isTouchDevice and 36 or 40)
	adjustRow.BackgroundTransparency = 1
	adjustRow.Parent = hitboxDropdown

	local function createAdjustButton(text, xScale, callback)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0.5, -5, 1, 0)
		button.Position = UDim2.new(xScale, xScale == 0 and 0 or 5, 0, 0)
		button.Text = text
		button.Font = Enum.Font.GothamBlack
		button.TextSize = isTouchDevice and 15 or 17
		button.Parent = adjustRow
		themeObject(button, "BackgroundColor3", "ButtonDark")
		styleButton(button)

		button.MouseButton1Click:Connect(callback)
		return button
	end

	createAdjustButton("-", 0, function()
		Combat.SetHitboxSize(Combat.HitboxSize - 1)
	end)

	createAdjustButton("+", 0.5, function()
		Combat.SetHitboxSize(Combat.HitboxSize + 1)
	end)

	Combat.SetHitboxSize(Combat.HitboxSize)

	expandHitboxToggle = createToggleButton(hitboxDropdown, "Expand Hitbox", false, function(state)
		Combat.HitboxExpanded = state
		Combat.RefreshHitboxes()
	end)

	createToggleButton(hitboxDropdown, "Visualize Hitboxes", true, function(state)
		Combat.HitboxVisible = state

		if Combat.HitboxExpanded then
			Combat.RefreshHitboxes()
		end
	end)

	autoGloveTapToggle = createToggleButton(combatList, "Auto Slap", false, function(state)
		Combat.SetAutoGloveTap(state)
	end)

	createToggleButton(combatList, "Player TP Buttons", false, function(state)
		Combat.SetPlayerTpButtons(state)
	end)

	Items.EarlyAutoCollectToggle = createToggleButton(betaList, "Early Auto Collect", false, function(state)
		Items.SetEarlyAutoCollect(state)
	end)

	createToggleButton(betaList, "Glove TP Slap", false, function(state)
		Combat.SetGloveTpSlap(state)
	end)

	local collectCratesToggle
	collectCratesToggle = createToggleButton(betaList, "Collect Crates", false, function(state)
		if state then
			local crate, cratePart = Items.FindNearestCrate()

			if not crate or not cratePart then
				createNotification("Collect Crates", "No meteor crate is spawned.", "Warning")
				task.defer(function()
					if collectCratesToggle then
						collectCratesToggle.Set(false, false)
					end
				end)
				return
			end
		end

		Combat.SetCollectCrates(state)
	end)
	Combat.CollectCratesToggle = collectCratesToggle

end

do
	local gloveDropdown = createDropdown(combatList, "Increase Glove Size", updateCombatCanvas)

	Combat.GloveSizeLabel = Instance.new("TextLabel")
	Combat.GloveSizeLabel.Size = UDim2.new(1, -10, 0, isTouchDevice and 28 or 30)
	Combat.GloveSizeLabel.BackgroundTransparency = 1
	Combat.GloveSizeLabel.Font = Enum.Font.GothamBlack
	Combat.GloveSizeLabel.TextSize = isTouchDevice and 11 or 13
	Combat.GloveSizeLabel.TextXAlignment = Enum.TextXAlignment.Center
	Combat.GloveSizeLabel.TextYAlignment = Enum.TextYAlignment.Center
	Combat.GloveSizeLabel.Text = "Glove Size: 1.00x"
	Combat.GloveSizeLabel.Parent = gloveDropdown
	themeObject(Combat.GloveSizeLabel, "TextColor3", "Text")

	local slider = Instance.new("TextButton")
	slider.Size = UDim2.new(1, -12, 0, isTouchDevice and 34 or 30)
	slider.Position = UDim2.fromOffset(2, 0)
	slider.Text = ""
	slider.BorderSizePixel = 0
	slider.AutoButtonColor = false
	slider.Active = true
	slider.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	slider.BackgroundTransparency = 0.18
	slider.Parent = gloveDropdown
	addCorner(slider, 8)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BorderSizePixel = 0
	fill.BackgroundTransparency = 0.1
	fill.Parent = slider
	themeObject(fill, "BackgroundColor3", "Button")
	addCorner(fill, 8)

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.fromScale(1, 1)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = "1.00x"
	valueLabel.Font = Enum.Font.GothamBlack
	valueLabel.TextSize = isTouchDevice and 10 or 12
	valueLabel.TextXAlignment = Enum.TextXAlignment.Center
	valueLabel.TextYAlignment = Enum.TextYAlignment.Center
	valueLabel.Parent = slider
	themeObject(valueLabel, "TextColor3", "Text")

	local dragging = false

	local function refreshSlider()
		local percent = (Combat.GloveSizeScale - Combat.GloveSizeMin) / (Combat.GloveSizeMax - Combat.GloveSizeMin)
		fill.Size = UDim2.fromScale(math.clamp(percent, 0, 1), 1)
		valueLabel.Text = string.format("%.2fx", Combat.GloveSizeScale)
	end

	local function setFromX(x)
		local percent = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
		local scale = Combat.GloveSizeMin + ((Combat.GloveSizeMax - Combat.GloveSizeMin) * percent)
		Combat.SetGloveSizeScale(scale, false)
		refreshSlider()
	end

	slider.InputBegan:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromX(inputObject.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(inputObject)
		if dragging and (inputObject.UserInputType == Enum.UserInputType.MouseMovement or inputObject.UserInputType == Enum.UserInputType.Touch) then
			setFromX(inputObject.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(inputObject)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				Combat.SetGloveSizeScale(Combat.GloveSizeScale, true)
			end
		end
	end)

	refreshSlider()
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

local itemEspToggle = createToggleButton(itemsList, "Item ESP", false, function(state)
	ItemESP.SetEnabled(state)
	createNotification("Item ESP", state and "Item ESP enabled." or "Item ESP disabled.", state and "Success" or "Info")
end)

local Anti = {
	StaffEnabled = false,
	HideUnderMapEnabled = false,
	StaffConnections = {},
	StaffKeywords = {
		"record", "recording", "rec", "clip", "proof", "evidence", "caught", "exposed",
		"screen record", "screenrec", "screenshot", "screen shot", "ss", "video", "vid",
		"obs", "shadowplay", "geforce", "nvidia", "stream", "streaming", "live",
		"staff", "admin", "mod", "moderator", "report", "reported", "ticket", "discord",
		"grava", "gravando", "prova", "video", "print", "aufnahme", "beweis",
		"enregistrer", "preuve", "filmer", "registrare", "prova", "录制", "录像", "録画", "証拠"
	}
}

function Anti.IsHazardName(text)
	local lowerName = string.lower(tostring(text or ""))
	local hazardWords = {
		"acid",
		"lava",
		"kill",
		"damage",
		"death",
		"deadly",
		"hazard",
		"hurt",
		"burn",
		"fire",
		"void",
		"toxic"
	}

	for _, word in ipairs(hazardWords) do
		if string.find(lowerName, word, 1, true) then
			return true
		end
	end

	return false
end

function Anti.HasHazardAssetId(object)
	local targetAssetId = "113506713"

	local function matchesAssetId(value)
		return string.find(tostring(value or ""), targetAssetId, 1, true) ~= nil
	end

	if object:IsA("MeshPart") and (matchesAssetId(object.MeshId) or matchesAssetId(object.TextureID)) then
		return true
	end

	for _, descendant in ipairs(object:GetDescendants()) do
		if descendant:IsA("SpecialMesh") and (matchesAssetId(descendant.MeshId) or matchesAssetId(descendant.TextureId)) then
			return true
		end

		if descendant:IsA("Decal") and matchesAssetId(descendant.Texture) then
			return true
		end

		if descendant:IsA("Texture") and matchesAssetId(descendant.Texture) then
			return true
		end
	end

	return false
end

function Anti.IsHazardPart(object)
	if not object or not object:IsA("BasePart") then
		return false
	end

	if Anti.HasHazardAssetId(object) then
		return true
	end

	local current = object

	while current and current ~= workspace do
		if Anti.IsHazardName(current.Name) then
			return true
		end

		current = current.Parent
	end

	return false
end

function Anti.EnableAcidLava()
	local removed = {}
	local removedCount = 0

	for _, object in ipairs(workspace:GetDescendants()) do
		if Anti.IsHazardPart(object) and object.Parent and not removed[object] then
			removed[object] = true
			removedCount += 1

			pcall(function()
				object:Destroy()
			end)
		end
	end

	return removedCount
end

function Anti.ClearStaffConnections()
	for _, connection in ipairs(Anti.StaffConnections) do
		connection:Disconnect()
	end

	Anti.StaffConnections = {}
end

function Anti.GetStaffKeyword(message)
	local lowerMessage = string.lower(tostring(message or ""))

	for _, keyword in ipairs(Anti.StaffKeywords) do
		local lowerKeyword = string.lower(tostring(keyword))

		if string.find(lowerMessage, lowerKeyword, 1, true) then
			return keyword
		end
	end

	return nil
end

function Anti.HandleStaffChat(speaker, message)
	if not Anti.StaffEnabled or speaker == player then
		return
	end

	local keyword = Anti.GetStaffKeyword(message)
	if not keyword then
		return
	end

	local speakerName = speaker and speaker.Name or "Unknown"
		player:Kick("Anti-Staff detected chat from " .. speakerName .. ": " .. tostring(message) .. " [" .. tostring(keyword) .. "]")
end

function Anti.HookStaffPlayer(targetPlayer)
	if not targetPlayer or targetPlayer == player then
		return
	end

	table.insert(Anti.StaffConnections, targetPlayer.Chatted:Connect(function(message)
		Anti.HandleStaffChat(targetPlayer, message)
	end))
end

function Anti.SetStaffEnabled(state)
	Anti.StaffEnabled = state == true
	Anti.ClearStaffConnections()

	if Anti.StaffEnabled then
		for _, targetPlayer in ipairs(Players:GetPlayers()) do
			Anti.HookStaffPlayer(targetPlayer)
		end

		table.insert(Anti.StaffConnections, Players.PlayerAdded:Connect(function(targetPlayer)
			Anti.HookStaffPlayer(targetPlayer)
		end))

		createNotification("Anti-Staff", "Anti-Staff enabled.", "Success")
	else
		createNotification("Anti-Staff", "Anti-Staff disabled.")
	end
end

function Anti.GetLocalRoot()
	local character = player.Character or player.CharacterAdded:Wait()
	return character and character:WaitForChild("HumanoidRootPart", 5)
end

function Anti.GetGroundReturnCFrame(root)
	local platform = UnderMapSafetyPlatform
	local character = player.Character
	local returnX = root.Position.X
	local returnZ = root.Position.Z

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local excludeInstances = {}

	if character then
		table.insert(excludeInstances, character)
	end

	if platform then
		table.insert(excludeInstances, platform)
	end

	params.FilterDescendantsInstances = excludeInstances

	local origin = Vector3.new(returnX, 320, returnZ)
	local result = workspace:Raycast(origin, Vector3.new(0, -520, 0), params)

	if result and result.Position.Y > -80 and result.Position.Y < 260 then
		return CFrame.new(returnX, result.Position.Y + UNDER_MAP_SAFE_OFFSET, returnZ)
	end

	return CFrame.new(returnX, 30 + UNDER_MAP_SAFE_OFFSET, returnZ)
end

function Anti.SetHideUnderMap(state)
	local root = Anti.GetLocalRoot()

	if not root then
		createNotification("Hide under map", "Could not find your character.", "Error")
		return
	end

	local targetCFrame = nil
	local clearPlatformAfterMove = false

	if state then
		local platform = ensureUnderMapSafetyPlatform()

		Anti.HideUnderMapEnabled = true
		targetCFrame = CFrame.new(root.Position.X, platform.Position.Y + (platform.Size.Y * 0.5) + UNDER_MAP_SAFE_OFFSET, root.Position.Z)
		createNotification("Hide under map", "Moved under the map.", "Success")
	else
		Anti.HideUnderMapEnabled = false
		targetCFrame = Anti.GetGroundReturnCFrame(root)
		clearPlatformAfterMove = true
		createNotification("Hide under map", "Moved back above ground.", "Info")
	end

	Teleport.MoveRoot(root, targetCFrame)

	if clearPlatformAfterMove then
		clearUnderMapSafetyPlatform()
	end
end

local antiAcidLavaToggle
local antiStaffToggle
local antiRagdollToggle
local hideUnderMapToggle

antiAcidLavaToggle = createToggleButton(safetyList, "Anti-Acid & Lava", false, function(state)
	if state then
		local removedCount = Anti.EnableAcidLava()
		createNotification("Anti-Acid", "Removed " .. tostring(removedCount or 0) .. " hazard objects.", "Success")
	else
		createNotification("Anti-Acid", "Anti-Acid & Lava disabled.")
	end
end)

hideUnderMapToggle = createToggleButton(safetyList, "Hide under map", false, function(state)
	Anti.SetHideUnderMap(state)
end)

antiRagdollToggle = createToggleButton(safetyList, "Anti-Ragdoll", false, function(state)
	Combat.SetAntiSlap(state)
end)

antiStaffToggle = createToggleButton(safetyList, "Anti-Staff", false, function(state)
	Anti.SetStaffEnabled(state)
end)

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
end, "Turns on ESP, hitbox, Auto Slap, teleport hotkeys, and hazard deletion.")

do
	local dropdown = createDropdown(settingsList, "Themes", updateSettingsCanvas)
	local themeOrder = {}

	for themeName in pairs(themes) do
		table.insert(themeOrder, themeName)
	end

	table.sort(themeOrder)

	createSmallButton(dropdown, "Cycle Theme", function()
		local currentIndex = 0

		for index, themeName in ipairs(themeOrder) do
			if themes[themeName] == currentTheme then
				currentIndex = index
				break
			end
		end

		local nextTheme = themeOrder[(currentIndex % #themeOrder) + 1]
		applyTheme(nextTheme)
		createNotification("Theme", "Switched to " .. nextTheme .. ".", "Success")
	end)

	for _, themeName in ipairs(themeOrder) do
		createSmallButton(dropdown, themeName, function()
			applyTheme(themeName)
		end)
	end
end

createToggleButton(settingsList, "Disable Notifications", Notify.Muted, function(state)
	Notify.Muted = state

	if state then
		Notify.Show("Notifications", "Regular notifications are now muted.", "Info", nil, 2.4, true)
	else
		createNotification("Notifications", "Notifications are back on.", "Success")
	end
end)

UI.CreateSlider(settingsList, "Window Transparency", 0, 0.45, UI.WindowTransparency, function(value)
	UI.WindowTransparency = value

	mainFrame.BackgroundTransparency = value
	tabScroll.BackgroundTransparency = value
	contentFrame.BackgroundTransparency = value
end)

Players.PlayerAdded:Connect(Combat.SetupPlayerHitboxRefresh)

player.CharacterAdded:Connect(function()
	task.wait(0.35)

	if Combat.AntiSlapEnabled then
		Combat.HookAntiSlapCharacter()
	end
end)

for _, otherPlayer in ipairs(Players:GetPlayers()) do
	Combat.SetupPlayerHitboxRefresh(otherPlayer)
	Combat.ResetHitbox(otherPlayer)
end

Players.PlayerRemoving:Connect(function(otherPlayer)
	Combat.ResetHitbox(otherPlayer)
	Combat.SavedHitboxes[otherPlayer] = nil
end)

local Window = {
	Dragging = false,
	Resizing = false,
	Locked = false,
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
	if Window.Locked or not isPointerBegin(inputObject) then
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
	if Window.Locked or not isPointerBegin(inputObject) then
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
			Window.ResizeHandle.Visible = (not Window.Locked) and (not isTouchDevice)
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
		Window.ResizeHandle.Visible = (not Window.Locked) and (not isTouchDevice)
	end
end

Window.ResizeHandle = Instance.new("TextButton")
Window.ResizeHandle.Size = isTouchDevice and UDim2.fromOffset(32, 32) or UDim2.fromOffset(28, 28)
Window.ResizeHandle.Position = isTouchDevice and UDim2.new(1, -39, 1, -39) or UDim2.new(1, -35, 1, -35)
Window.ResizeHandle.Text = "+"
Window.ResizeHandle.Font = Enum.Font.GothamBlack
Window.ResizeHandle.TextSize = 17
Window.ResizeHandle.Active = true
Window.ResizeHandle.Visible = (not Window.Locked) and (not isTouchDevice)
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

local cleanupRuntime = nil

closeButton.MouseButton1Click:Connect(function()
	if cleanupRuntime then
		cleanupRuntime()
	elseif gui.Parent then
		gui:Destroy()
	end
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
Settings.LoadAll()
Items.StartCrateWatcher()

tabScroll.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X + 20, 0)
updateMainCanvas()
updateItemsCanvas()
updateTeleportCanvas()
updateCombatCanvas()
updateBetaCanvas()
updateSafetyCanvas()
updateSettingsCanvas()

task.defer(function()
	applyResponsiveWindow()
	updateMainCanvas()
	updateItemsCanvas()
	updateTeleportCanvas()
	updateCombatCanvas()
	updateBetaCanvas()
	updateSafetyCanvas()
	updateSettingsCanvas()
end)

do
	local cleanupRan = false

	cleanupRuntime = function()
		if cleanupRan then
			return
		end

		cleanupRan = true

		pcall(function()
			Items.EarlyAutoCollectEnabled = false
			UI.AutoEarlyBusJumpEnabled = false
			UI.AutoRejoinEnabled = false
			UI.InfiniteJumpEnabled = false
			if UI.InfiniteJumpConnection then
				UI.InfiniteJumpConnection:Disconnect()
				UI.InfiniteJumpConnection = nil
			end
			UI.DisconnectAutoRejoin()
			Items.CleanupAutomation()
		end)

		pcall(function()
			if Combat then
				Combat.HitboxExpanded = false
				Combat.RefreshHitboxes()
				Combat.PlayerTpButtonsEnabled = false
				Combat.ClearPlayerTpButtons()
				Combat.SetAutoGloveTap(false)
				Combat.SetGloveTpSlap(false)
				Combat.SetCollectCrates(false)
				Combat.SetAntiSlap(false)
				Combat.RestoreGloveSize()
			end
		end)

		pcall(function()
			if ESP then
				ESP.Disable()
			end
		end)

		pcall(function()
			if ItemESP then
				ItemESP.SetEnabled(false)
			end
		end)

		pcall(function()
			if Anti then
				Anti.HideUnderMapEnabled = false
				Anti.SetStaffEnabled(false)
			end
		end)

		pcall(function()
			if Teleport then
				Teleport.ClearBusTopRidePlatform()
			end
		end)

		pcall(function()
			clearUnderMapSafetyPlatform()
		end)

		pcall(function()
			ContextActionService:UnbindAction(Combat and Combat.GloveTpSlapActionName or "GloveTpSlapClickBlock")
		end)

		pcall(function()
			Notify.Clear()
		end)

		if gui.Parent then
			gui:Destroy()
		end

		if sharedEnvironment then
			pcall(function()
				if sharedEnvironment.OPSlapRoyaleCleanup == cleanupRuntime then
					sharedEnvironment.OPSlapRoyaleCleanup = nil
				end
			end)
		end
	end

	if sharedEnvironment then
		pcall(function()
			sharedEnvironment.OPSlapRoyaleCleanup = cleanupRuntime
		end)
	end
end

-- End of OP Slap Royale UI.
