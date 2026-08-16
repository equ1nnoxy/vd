-- =================================================================
-- GODFATHER HUB v2 // PHANTOM AUTH & EXPLOIT SYSTEM (COMBINED)
-- =================================================================

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- State Variables & Configurations
local CORRECT_KEY = "OpFather211"
local LINK = "https://1drv.ms/f/c/483e7ba0d40a851b/IgCdkSgtayc4TaLMU-eF9HmPAarKTAf6cAF0GXtXK2kpNpI?e=IAkqZG"

local isKeyUnlocked = false
local flyEnabled = false
local noclipEnabled = false
local infiniteJumpEnabled = false
local espEnabled = false
local flySpeed = 50

local flyConnection = nil
local noclipConnection = nil
local jumpConnection = nil
local espConnection = nil
local cameraZoomConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

local targetPlayers = {}
local currentTargetIndex = 0
local selectedPlayerName = nil
local spectating = false
local spectatedPlayer = nil
local espObjects = {}

-- Utility Clipboard Function
local function copyToClipboard(text)
	if setclipboard then setclipboard(text) return true end
	if toclipboard then toclipboard(text) return true end
	if syn and syn.write_clipboard then syn.write_clipboard(text) return true end
	if clipboard and clipboard.set then clipboard.set(text) return true end
	return false
end

-- =================================================================
-- SCREEN GUI SETUP
-- =================================================================
local targetGuiParent = CoreGui:FindFirstChild("RobloxGui") or player:WaitForChild("PlayerGui")

-- Remove existing UI instances
if targetGuiParent:FindFirstChild("GodFatherHub_v2") then
	targetGuiParent.GodFatherHub_v2:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodFatherHub_v2"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = targetGuiParent

-- UI Helper Functions
local C = {
	bg = Color3.fromRGB(18, 18, 20),
	panel = Color3.fromRGB(28, 28, 32),
	panelLight = Color3.fromRGB(34, 34, 38),
	border = Color3.fromRGB(180, 35, 45),
	red = Color3.fromRGB(200, 45, 55),
	redDark = Color3.fromRGB(120, 28, 35),
	white = Color3.fromRGB(235, 235, 240),
	dim = Color3.fromRGB(120, 120, 130),
	yellow = Color3.fromRGB(220, 180, 60),
	green = Color3.fromRGB(70, 200, 100),
}

local function corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = inst
	return c
end

local function stroke(inst, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or C.border
	s.Thickness = thickness or 1
	s.Parent = inst
	return s
end

local function label(parent, props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.Code
	l.TextColor3 = C.white
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	for k, v in pairs(props) do l[k] = v end
	l.Parent = parent
	return l
end

local function button(parent, props)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = true
	b.Font = Enum.Font.Code
	b.TextColor3 = C.white
	b.Text = ""
	for k, v in pairs(props) do b[k] = v end
	b.Parent = parent
	return b
end

local function makeDraggable(handle, target)
	local dragging, startInputPos, startFramePos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startInputPos = input.Position
			startFramePos = target.Position
		end
	end)
	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - startInputPos
			target.Position = UDim2.new(
				startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
				startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
			)
		end
	end)
end

-- =================================================================
-- TOGGLE BUTTON (FLOATING ICON FOR MAIN HUB)
-- =================================================================
local toggleBtn = button(screenGui, {
	Name = "ToggleButton",
	Size = UDim2.new(0, 45, 0, 45),
	Position = UDim2.new(0, 20, 0, 20),
	BackgroundColor3 = Color3.fromRGB(15, 15, 20),
	Text = "⚡",
	TextColor3 = Color3.fromRGB(0, 230, 140),
	Font = Enum.Font.GothamBold,
	TextSize = 20,
	ZIndex = 10,
	Visible = false,
})
corner(toggleBtn, 22)
stroke(toggleBtn, Color3.fromRGB(0, 230, 140), 2)
makeDraggable(toggleBtn, toggleBtn)

-- =================================================================
-- PHANTOM AUTH SYSTEM FRAME
-- =================================================================
local authRoot = Instance.new("Frame")
authRoot.Name = "AuthRoot"
authRoot.AnchorPoint = Vector2.new(0.5, 0.5)
authRoot.Position = UDim2.new(0.5, 0, 0.5, 0)
authRoot.Size = UDim2.new(0, 420, 0, 520)
authRoot.BackgroundColor3 = C.bg
authRoot.BorderSizePixel = 0
authRoot.Parent = screenGui
corner(authRoot, 8)
stroke(authRoot, C.border, 1.5)

-- Auth Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundTransparency = 1
header.Parent = authRoot
makeDraggable(header, authRoot)

label(header, {
	Size = UDim2.new(1, -100, 1, 0),
	Position = UDim2.new(0, 14, 0, 0),
	Text = "◆  •  PHANTOM // AUTH SYSTEM",
	TextSize = 13,
})

local classified = button(header, {
	Size = UDim2.new(0, 88, 0, 22),
	Position = UDim2.new(1, -108, 0.5, -11),
	BackgroundColor3 = C.redDark,
	Text = "CLASSIFIED",
	TextSize = 11,
})
corner(classified, 4)

local closeBtn = button(header, {
	Size = UDim2.new(0, 18, 0, 18),
	Position = UDim2.new(1, -26, 0.5, -9),
	BackgroundColor3 = C.red,
	Text = "",
})
corner(closeBtn, 3)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local headerLine = Instance.new("Frame")
headerLine.Size = UDim2.new(1, -24, 0, 1)
headerLine.Position = UDim2.new(0, 12, 0, 44)
headerLine.BackgroundColor3 = C.border
headerLine.BorderSizePixel = 0
headerLine.Parent = authRoot

-- Auth Screens Containers
local authScreen = Instance.new("Frame")
authScreen.Name = "AuthScreen"
authScreen.Size = UDim2.new(1, 0, 1, -44)
authScreen.Position = UDim2.new(0, 0, 0, 44)
authScreen.BackgroundTransparency = 1
authScreen.Parent = authRoot

local briefScreen = Instance.new("Frame")
briefScreen.Name = "BriefScreen"
briefScreen.Size = UDim2.new(1, 0, 1, -44)
briefScreen.Position = UDim2.new(0, 0, 0, 44)
briefScreen.BackgroundTransparency = 1
briefScreen.Visible = false
briefScreen.Parent = authRoot

local function showAuth()
	authScreen.Visible = true
	briefScreen.Visible = false
end

local function showBrief()
	authScreen.Visible = false
	briefScreen.Visible = true
end

-- ---------- AUTH SCREEN ELEMENTS ----------
local banner = Instance.new("Frame")
banner.Size = UDim2.new(1, -24, 0, 64)
banner.Position = UDim2.new(0, 12, 0, 10)
banner.BackgroundColor3 = C.panel
banner.BorderSizePixel = 0
banner.Parent = authScreen
corner(banner, 6)

label(banner, {
	Size = UDim2.new(1, -16, 0, 22),
	Position = UDim2.new(0, 12, 0, 12),
	Text = "🛡  PHANTOM DEFENSE SYSTEM",
	TextSize = 15,
	Font = Enum.Font.GothamBold,
})

label(banner, {
	Size = UDim2.new(1, -16, 0, 18),
	Position = UDim2.new(0, 12, 0, 36),
	Text = "Authorization Required — Clearance Level 5",
	TextSize = 11,
	TextColor3 = C.dim,
})

local statsRow = Instance.new("Frame")
statsRow.Size = UDim2.new(1, -24, 0, 48)
statsRow.Position = UDim2.new(0, 12, 0, 82)
statsRow.BackgroundTransparency = 1
statsRow.Parent = authScreen

local statData = {
	{ title = "THREAT LEVEL", value = "ELEVATED", color = C.yellow },
	{ title = "ENCRYPTION", value = "AES-256", color = C.green },
	{ title = "SESSION", value = string.format("%06X", math.random(0, 0xFFFFFF)), color = C.dim },
}

for i, s in ipairs(statData) do
	local col = Instance.new("Frame")
	col.Size = UDim2.new(1 / 3, -4, 1, 0)
	col.Position = UDim2.new((i - 1) / 3, (i - 1) * 2, 0, 0)
	col.BackgroundTransparency = 1
	col.Parent = statsRow

	label(col, {
		Size = UDim2.new(1, 0, 0, 14),
		Text = s.title,
		TextSize = 9,
		TextColor3 = C.dim,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	label(col, {
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0, 16),
		Text = s.value,
		TextSize = 12,
		TextColor3 = s.color,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
end

local KEY_PLACEHOLDER = "KEY_XXXX-XXXX-XXXX-XXXX"

label(authScreen, {
	Size = UDim2.new(1, 0, 0, 18),
	Position = UDim2.new(0, 0, 0, 142),
	Text = "— ENTER AUTHORIZATION KEY —",
	TextSize = 11,
	TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Center,
})

local keyField = Instance.new("Frame")
keyField.Size = UDim2.new(1, -24, 0, 36)
keyField.Position = UDim2.new(0, 12, 0, 166)
keyField.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
keyField.BorderSizePixel = 0
keyField.Parent = authScreen
corner(keyField, 4)
local keyFieldStroke = stroke(keyField, Color3.fromRGB(45, 45, 52), 1)

label(keyField, {
	Size = UDim2.new(0, 28, 1, 0),
	Position = UDim2.new(0, 8, 0, 0),
	Text = ">>",
	TextSize = 14,
	TextColor3 = C.green,
	TextXAlignment = Enum.TextXAlignment.Left,
})

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -40, 1, 0)
keyBox.Position = UDim2.new(0, 36, 0, 0)
keyBox.BackgroundTransparency = 1
keyBox.TextColor3 = Color3.fromRGB(240, 240, 240)
keyBox.PlaceholderText = KEY_PLACEHOLDER
keyBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 100)
keyBox.Text = ""
keyBox.Font = Enum.Font.Code
keyBox.TextSize = 13
keyBox.ClearTextOnFocus = false
keyBox.BorderSizePixel = 0
keyBox.Parent = keyField

local authBtn = button(authScreen, {
	Size = UDim2.new(1, -24, 0, 40),
	Position = UDim2.new(0, 12, 0, 220),
	BackgroundColor3 = C.red,
	Text = "  ▶  AUTHENTICATE",
	TextSize = 14,
	Font = Enum.Font.GothamBold,
})
corner(authBtn, 6)

local freeKeyBtn = button(authScreen, {
	Size = UDim2.new(1, -24, 0, 36),
	Position = UDim2.new(0, 12, 0, 268),
	BackgroundColor3 = C.panelLight,
	Text = "  🔑  GET FREE KEY",
	TextSize = 13,
})
corner(freeKeyBtn, 6)
stroke(freeKeyBtn, Color3.fromRGB(50, 50, 55), 1)

freeKeyBtn.MouseButton1Click:Connect(showBrief)

local authFooter = Instance.new("Frame")
authFooter.Size = UDim2.new(1, -24, 0, 20)
authFooter.Position = UDim2.new(0, 12, 1, -28)
authFooter.BackgroundTransparency = 1
authFooter.Parent = authScreen

label(authFooter, {
	Size = UDim2.new(0.5, 0, 1, 0),
	Text = "PHANTOM v1.0",
	TextSize = 10,
	TextColor3 = C.dim,
})

local timeLabel = label(authFooter, {
	Size = UDim2.new(0.5, 0, 1, 0),
	Position = UDim2.new(0.5, 0, 0, 0),
	Text = "◆ 00:00:00 UTC",
	TextSize = 10,
	TextColor3 = C.dim,
	TextXAlignment = Enum.TextXAlignment.Right,
})

task.spawn(function()
	while screenGui.Parent do
		timeLabel.Text = "◆ " .. os.date("!%H:%M:%S") .. " UTC"
		task.wait(1)
	end
end)

-- ---------- BRIEFING SCREEN ELEMENTS ----------
local briefBanner = Instance.new("Frame")
briefBanner.Size = UDim2.new(1, -24, 0, 56)
briefBanner.Position = UDim2.new(0, 12, 0, 8)
briefBanner.BackgroundColor3 = C.panel
briefBanner.BorderSizePixel = 0
briefBanner.Parent = briefScreen
corner(briefBanner, 6)

label(briefBanner, {
	Size = UDim2.new(1, -14, 0, 20),
	Position = UDim2.new(0, 10, 0, 10),
	Text = "📡  KEY ACQUISITION BRIEFING",
	TextSize = 13,
	Font = Enum.Font.GothamBold,
})

label(briefBanner, {
	Size = UDim2.new(1, -14, 0, 16),
	Position = UDim2.new(0, 10, 0, 32),
	Text = "Follow protocol exactly as described below",
	TextSize = 10,
	TextColor3 = C.dim,
})

local steps = {
	{ n = "01", icon = "🖱", text = "Click [ COPY LINK ] to copy the access URL", tag = "HIGH", tagColor = C.red },
	{ n = "02", icon = "🌐", text = "Open a web browser on your device", tag = "MED", tagColor = C.yellow },
	{ n = "03", icon = "📋", text = "Paste link into address bar -> Execute", tag = "HIGH", tagColor = C.red },
	{ n = "04", icon = "✅", text = "Get key from the provided link", tag = "HIGH", tagColor = C.red },
	{ n = "05", icon = "🛡", text = "Return and submit key for authentication", tag = "LOW", tagColor = C.green },
}

local stepsContainer = Instance.new("ScrollingFrame")
stepsContainer.Size = UDim2.new(1, -24, 0, 280)
stepsContainer.Position = UDim2.new(0, 12, 0, 72)
stepsContainer.BackgroundTransparency = 1
stepsContainer.BorderSizePixel = 0
stepsContainer.ScrollBarThickness = 4
stepsContainer.ScrollBarImageColor3 = C.redDark
stepsContainer.CanvasSize = UDim2.new(0, 0, 0, #steps * 46)
stepsContainer.Parent = briefScreen

local briefListLayout = Instance.new("UIListLayout")
briefListLayout.Padding = UDim.new(0, 6)
briefListLayout.Parent = stepsContainer

for _, step in ipairs(steps) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 40)
	row.BackgroundColor3 = C.panel
	row.BorderSizePixel = 0
	row.Parent = stepsContainer
	corner(row, 4)

	label(row, {
		Size = UDim2.new(0, 28, 1, 0),
		Position = UDim2.new(0, 6, 0, 0),
		Text = step.n,
		TextSize = 12,
		TextColor3 = C.red,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	label(row, {
		Size = UDim2.new(0, 22, 1, 0),
		Position = UDim2.new(0, 32, 0, 0),
		Text = step.icon,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	label(row, {
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.new(0, 54, 0, 0),
		Text = step.text,
		TextSize = 10,
		TextWrapped = true,
		TextColor3 = C.white,
	})

	local tag = label(row, {
		Size = UDim2.new(0, 36, 0, 16),
		Position = UDim2.new(1, -42, 0.5, -8),
		Text = step.tag,
		TextSize = 9,
		TextColor3 = step.tagColor,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	tag.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	tag.BackgroundTransparency = 0.3
	corner(tag, 3)
end

local copyBtn = button(briefScreen, {
	Size = UDim2.new(1, -24, 0, 42),
	Position = UDim2.new(0, 12, 0, 362),
	BackgroundColor3 = C.redDark,
	Text = "  📋  COPY LINK",
	TextSize = 14,
	Font = Enum.Font.GothamBold,
})
corner(copyBtn, 6)
stroke(copyBtn, C.red, 1)

local returnBtn = button(briefScreen, {
	Size = UDim2.new(1, -24, 0, 32),
	Position = UDim2.new(0, 12, 0, 412),
	BackgroundColor3 = C.panel,
	Text = "←  RETURN TO AUTH SCREEN",
	TextSize = 11,
	TextColor3 = C.dim,
})
corner(returnBtn, 4)

returnBtn.MouseButton1Click:Connect(showAuth)

copyBtn.MouseButton1Click:Connect(function()
	local ok = copyToClipboard(LINK)
	if ok then
		copyBtn.Text = "  ✓  COPIED!"
		copyBtn.BackgroundColor3 = C.green
	else
		copyBtn.Text = "  !  FAILED TO COPY"
		copyBtn.BackgroundColor3 = C.yellow
	end
	task.delay(1.5, function()
		if copyBtn.Parent then
			copyBtn.Text = "  📋  COPY LINK"
			copyBtn.BackgroundColor3 = C.redDark
		end
	end)
end)

-- =================================================================
-- MAIN HUB FRAME (GODFATHER HUB v2)
-- =================================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 310, 0, 320)
mainFrame.Position = UDim2.new(0.5, -155, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
corner(mainFrame, 10)
stroke(mainFrame, Color3.fromRGB(45, 45, 60), 1.5)

local mainDragHandle = Instance.new("Frame")
mainDragHandle.Name = "DragHandle"
mainDragHandle.Size = UDim2.new(1, 0, 0, 40)
mainDragHandle.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
mainDragHandle.Parent = mainFrame
corner(mainDragHandle, 10)
makeDraggable(mainDragHandle, mainFrame)

local hubTitle = Instance.new("TextLabel")
hubTitle.Size = UDim2.new(1, -15, 1, 0)
hubTitle.Position = UDim2.new(0, 15, 0, 0)
hubTitle.BackgroundTransparency = 1
hubTitle.Text = "GODFATHER HUB v2"
hubTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
hubTitle.Font = Enum.Font.GothamBold
hubTitle.TextSize = 13
hubTitle.TextXAlignment = Enum.TextXAlignment.Left
hubTitle.Parent = mainDragHandle

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ContentScroll"
scrollFrame.Size = UDim2.new(1, -16, 1, -50)
scrollFrame.Position = UDim2.new(0, 8, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 230, 140)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 15)
end)

-- UI Helper Creator for Hub
local function createToggleButton(name, text, order)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, -6, 0, 36)
	btn.LayoutOrder = order
	btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	btn.Text = "  " .. text .. ": OFF"
	btn.TextColor3 = Color3.fromRGB(200, 200, 210)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = scrollFrame

	corner(btn, 6)

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 10, 0, 10)
	indicator.Position = UDim2.new(1, -20, 0.5, -5)
	indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
	indicator.Parent = btn
	corner(indicator, 5)

	return btn, indicator
end

local function updateToggleVisual(btn, indicator, state, text)
	if state then
		btn.Text = "  " .. text .. ": ON"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		indicator.BackgroundColor3 = Color3.fromRGB(0, 230, 140)
	else
		btn.Text = "  " .. text .. ": OFF"
		btn.TextColor3 = Color3.fromRGB(200, 200, 210)
		indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
	end
end

-- Hub Controls
local flyBtn, flyInd = createToggleButton("FlyBtn", "Fly Control", 1)
local noclipBtn, noclipInd = createToggleButton("NoclipBtn", "Noclip Passthrough", 2)
local jumpBtn, jumpInd = createToggleButton("JumpBtn", "Infinite Jump", 3)
local espBtn, espInd = createToggleButton("EspBtn", "ESP Visuals", 4)

-- WalkSpeed Block
local wsContainer = Instance.new("Frame")
wsContainer.Size = UDim2.new(1, -6, 0, 36)
wsContainer.LayoutOrder = 5
wsContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
wsContainer.Parent = scrollFrame
corner(wsContainer, 6)

local wsInput = Instance.new("TextBox")
wsInput.Size = UDim2.new(0.65, -10, 0, 26)
wsInput.Position = UDim2.new(0, 8, 0.5, -13)
wsInput.PlaceholderText = "WalkSpeed (16)..."
wsInput.PlaceholderColor3 = Color3.fromRGB(110, 110, 130)
wsInput.Text = ""
wsInput.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
wsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
wsInput.Font = Enum.Font.Gotham
wsInput.TextSize = 12
wsInput.Parent = wsContainer
corner(wsInput, 4)

local wsApplyBtn = Instance.new("TextButton")
wsApplyBtn.Size = UDim2.new(0.35, -12, 0, 26)
wsApplyBtn.Position = UDim2.new(0.65, 4, 0.5, -13)
wsApplyBtn.Text = "Set"
wsApplyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
wsApplyBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
wsApplyBtn.Font = Enum.Font.GothamBold
wsApplyBtn.TextSize = 12
wsApplyBtn.Parent = wsContainer
corner(wsApplyBtn, 4)

-- Fly Speed Controls
local flySpeedContainer = Instance.new("Frame")
flySpeedContainer.Size = UDim2.new(1, -6, 0, 36)
flySpeedContainer.LayoutOrder = 6
flySpeedContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
flySpeedContainer.Parent = scrollFrame
corner(flySpeedContainer, 6)

local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(0.5, 0, 1, 0)
flySpeedLabel.Position = UDim2.new(0, 10, 0, 0)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "Fly Speed: " .. flySpeed
flySpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
flySpeedLabel.Font = Enum.Font.GothamMedium
flySpeedLabel.TextSize = 12
flySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
flySpeedLabel.Parent = flySpeedContainer

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 28, 0, 24)
minusBtn.Position = UDim2.new(1, -66, 0.5, -12)
minusBtn.Text = "-10"
minusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 11
minusBtn.Parent = flySpeedContainer
corner(minusBtn, 4)

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 28, 0, 24)
plusBtn.Position = UDim2.new(1, -34, 0.5, -12)
plusBtn.Text = "+10"
plusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 11
plusBtn.Parent = flySpeedContainer
corner(plusBtn, 4)

-- Teleport & Spectate
local tpDropdown = Instance.new("TextButton")
tpDropdown.Name = "TpDropdown"
tpDropdown.Size = UDim2.new(1, -6, 0, 36)
tpDropdown.LayoutOrder = 7
tpDropdown.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
tpDropdown.Text = "  Select Target ▾"
tpDropdown.TextColor3 = Color3.fromRGB(200, 200, 210)
tpDropdown.Font = Enum.Font.GothamMedium
tpDropdown.TextSize = 12
tpDropdown.TextXAlignment = Enum.TextXAlignment.Left
tpDropdown.Parent = scrollFrame
corner(tpDropdown, 6)

local tpGoBtn = Instance.new("TextButton")
tpGoBtn.Name = "TpGoBtn"
tpGoBtn.Size = UDim2.new(1, -6, 0, 36)
tpGoBtn.LayoutOrder = 8
tpGoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
tpGoBtn.Text = "TELEPORT TO PLAYER"
tpGoBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
tpGoBtn.Font = Enum.Font.GothamBold
tpGoBtn.TextSize = 12
tpGoBtn.Parent = scrollFrame
corner(tpGoBtn, 6)

local spectateBtn, spectateInd = createToggleButton("SpectateBtn", "Spectate Target", 9)

-- =================================================================
-- FEATURES LOGIC IMPLEMENTATION
-- =================================================================

-- Camera Limits Removal
local function enableCameraNoLimit()
	player.CameraMaxZoomDistance = 100000
	player.CameraMinZoomDistance = 0.5
	if cameraZoomConnection then cameraZoomConnection:Disconnect() cameraZoomConnection = nil end
	cameraZoomConnection = RunService.RenderStepped:Connect(function()
		if not isKeyUnlocked then return end
		if player.CameraMaxZoomDistance ~= 100000 then player.CameraMaxZoomDistance = 100000 end
		if player.CameraMinZoomDistance ~= 0.5 then player.CameraMinZoomDistance = 0.5 end
	end)
end

-- Key Authentication Handler
local function denyAuth(message)
	keyBox.Text = ""
	keyBox.PlaceholderText = message
	keyBox.PlaceholderColor3 = C.red
	authBtn.Text = "  ✕  ACCESS DENIED"
	authBtn.BackgroundColor3 = C.redDark
	if keyFieldStroke then keyFieldStroke.Color = C.red end

	task.delay(2, function()
		if not keyBox.Parent then return end
		keyBox.PlaceholderText = KEY_PLACEHOLDER
		keyBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 100)
		authBtn.Text = "  ▶  AUTHENTICATE"
		authBtn.BackgroundColor3 = C.red
		if keyFieldStroke then keyFieldStroke.Color = Color3.fromRGB(45, 45, 52) end
	end)
end

authBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == CORRECT_KEY then
		isKeyUnlocked = true
		authBtn.Text = "  ✓  ACCESS GRANTED"
		authBtn.BackgroundColor3 = C.green
		enableCameraNoLimit()
		task.wait(0.5)
		authRoot:Destroy()
		mainFrame.Visible = true
		toggleBtn.Visible = true
	else
		denyAuth(keyBox.Text == "" and "Enter key first" or "INVALID ACCESS KEY")
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	mainFrame.Visible = not mainFrame.Visible
end)

-- Fly System
local function startFly()
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = humanoidRootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 10000
	bodyGyro.CFrame = humanoidRootPart.CFrame
	bodyGyro.Parent = humanoidRootPart

	flyConnection = RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		local camCFrame = camera.CFrame
		local humanoidMoveDir = humanoid.MoveDirection

		local moveDirection = Vector3.new(0, 0, 0)
		if humanoidMoveDir.Magnitude > 0 then
			moveDirection = camCFrame.LookVector * humanoidMoveDir:Dot(camCFrame.LookVector)
				+ camCFrame.RightVector * humanoidMoveDir:Dot(camCFrame.RightVector)
		end

		if moveDirection.Magnitude > 0 then
			bodyVelocity.Velocity = moveDirection.Unit * flySpeed
		else
			bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end
		bodyGyro.CFrame = camCFrame
	end)
end

local function stopFly()
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

flyBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	flyEnabled = not flyEnabled
	if flyEnabled then startFly() else stopFly() end
	updateToggleVisual(flyBtn, flyInd, flyEnabled, "Fly Control")
end)

-- Noclip System
local function startNoclip()
	noclipConnection = RunService.Stepped:Connect(function()
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function stopNoclip()
	if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	if character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
end

noclipBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	noclipEnabled = not noclipEnabled
	if noclipEnabled then startNoclip() else stopNoclip() end
	updateToggleVisual(noclipBtn, noclipInd, noclipEnabled, "Noclip Passthrough")
end)

-- Infinite Jump System
local function startInfiniteJump()
	jumpConnection = UserInputService.JumpRequest:Connect(function()
		if infiniteJumpEnabled and humanoid and isKeyUnlocked then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end

jumpBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	infiniteJumpEnabled = not infiniteJumpEnabled
	if infiniteJumpEnabled and not jumpConnection then startInfiniteJump() end
	updateToggleVisual(jumpBtn, jumpInd, infiniteJumpEnabled, "Infinite Jump")
end)

-- ESP Visuals System
local function clearESP()
	for plr, data in pairs(espObjects) do
		if data then
			if data.Highlight then data.Highlight:Destroy() end
			if data.Billboard then data.Billboard:Destroy() end
			if data.Tracer then data.Tracer:Remove() end
		end
		espObjects[plr] = nil
	end
end

local function createESP(plr)
	if plr == player or espObjects[plr] then return end
	local char = plr.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "RainbowESP"
	highlight.Adornee = char
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = char

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlayerESP"
	billboard.Adornee = root
	billboard.Size = UDim2.new(0, 150, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.ResetOnSpawn = false
	billboard.Parent = screenGui

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 18)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = plr.DisplayName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.2
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 12
	nameLabel.Parent = billboard

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Name = "Distance"
	distanceLabel.Size = UDim2.new(1, 0, 0, 16)
	distanceLabel.Position = UDim2.new(0, 0, 0, 18)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Text = "0 studs"
	distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
	distanceLabel.TextStrokeTransparency = 0.3
	distanceLabel.Font = Enum.Font.Gotham
	distanceLabel.TextSize = 11
	distanceLabel.Parent = billboard

	local hpLabel = Instance.new("TextLabel")
	hpLabel.Name = "HP"
	hpLabel.Size = UDim2.new(1, 0, 0, 16)
	hpLabel.Position = UDim2.new(0, 0, 0, 34)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = "HP: 100"
	hpLabel.TextColor3 = Color3.fromRGB(0, 230, 140)
	hpLabel.TextStrokeTransparency = 0.3
	hpLabel.Font = Enum.Font.GothamBold
	hpLabel.TextSize = 11
	hpLabel.Parent = billboard

	local tracer = Drawing.new("Line")
	tracer.Visible = false
	tracer.Thickness = 2
	tracer.Transparency = 1

	espObjects[plr] = { Highlight = highlight, Billboard = billboard, Tracer = tracer }
end

local function removeESP(plr)
	if espObjects[plr] then
		local data = espObjects[plr]
		if data.Highlight then data.Highlight:Destroy() end
		if data.Billboard then data.Billboard:Destroy() end
		if data.Tracer then data.Tracer:Remove() end
		espObjects[plr] = nil
	end
end

local function updateESP()
	if not espEnabled then return end
	local camera = workspace.CurrentCamera
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local myRootScreenPos, myRootOnScreen = camera:WorldToViewportPoint(myRoot.Position)
	local rainbowColor = Color3.fromHSV((tick() % 3) / 3, 1, 1)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if root and hum and hum.Health > 0 then
				createESP(plr)
				local data = espObjects[plr]
				if data then
					if data.Highlight then
						data.Highlight.FillColor = rainbowColor
						data.Highlight.OutlineColor = rainbowColor
					end

					local dist = (myRoot.Position - root.Position).Magnitude
					local distanceLabel = data.Billboard and data.Billboard:FindFirstChild("Distance")
					local hpLabel = data.Billboard and data.Billboard:FindFirstChild("HP")

					if distanceLabel then distanceLabel.Text = math.floor(dist) .. " studs" end
					if hpLabel then
						hpLabel.Text = "HP: " .. math.floor(hum.Health)
						if hum.Health > 50 then hpLabel.TextColor3 = Color3.fromRGB(0, 230, 140)
						elseif hum.Health > 25 then hpLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
						else hpLabel.TextColor3 = Color3.fromRGB(255, 80, 80) end
					end

					local targetScreenPos, targetOnScreen = camera:WorldToViewportPoint(root.Position)
					if data.Tracer then
						if myRootOnScreen and targetOnScreen then
							data.Tracer.From = Vector2.new(myRootScreenPos.X, myRootScreenPos.Y)
							data.Tracer.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
							data.Tracer.Color = rainbowColor
							data.Tracer.Visible = true
						else
							data.Tracer.Visible = false
						end
					end
				end
			else
				removeESP(plr)
			end
		end
	end
end

local function startESP()
	if espConnection then espConnection:Disconnect() end
	updateESP()
	espConnection = RunService.RenderStepped:Connect(updateESP)
end

local function stopESP()
	if espConnection then espConnection:Disconnect() espConnection = nil end
	clearESP()
end

espBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	espEnabled = not espEnabled
	if espEnabled then startESP() else stopESP() end
	updateToggleVisual(espBtn, espInd, espEnabled, "ESP Visuals")
end)

Players.PlayerAdded:Connect(function(plr)
	if espEnabled then plr.CharacterAdded:Connect(function() task.wait(0.5) if espEnabled then createESP(plr) end end) end
end)
Players.PlayerRemoving:Connect(removeESP)

-- Speed Controls
wsApplyBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	local val = tonumber(wsInput.Text)
	if val and humanoid then
		humanoid.WalkSpeed = val
		wsApplyBtn.Text = "OK!"
	else
		wsApplyBtn.Text = "Err"
	end
	task.wait(1)
	wsApplyBtn.Text = "Set"
end)

minusBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	flySpeed = math.max(10, flySpeed - 10)
	flySpeedLabel.Text = "Fly Speed: " .. flySpeed
end)

plusBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	flySpeed = math.min(300, flySpeed + 10)
	flySpeedLabel.Text = "Fly Speed: " .. flySpeed
end)

-- Teleport & Player Selection
tpDropdown.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	targetPlayers = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then table.insert(targetPlayers, plr) end
	end

	if #targetPlayers == 0 then
		tpDropdown.Text = "  No Other Players"
		task.wait(1)
		tpDropdown.Text = "  Select Target ▾"
		return
	end

	currentTargetIndex = currentTargetIndex + 1
	if currentTargetIndex > #targetPlayers then currentTargetIndex = 1 end
	local target = targetPlayers[currentTargetIndex]
	selectedPlayerName = target.Name
	tpDropdown.Text = "  Target: " .. target.DisplayName .. " ▾"
end)

tpGoBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked or not selectedPlayerName then return end
	local targetPlayer = Players:FindFirstChild(selectedPlayerName)
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		humanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
		tpGoBtn.Text = "TELEPORTED!"
	else
		tpGoBtn.Text = "TARGET INVALID"
	end
	task.wait(1)
	tpGoBtn.Text = "TELEPORT TO PLAYER"
end)

-- Spectate System
local function stopSpectate()
	if not spectating then return end
	local camera = workspace.CurrentCamera
	spectating = false
	spectatedPlayer = nil
	if humanoid then
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
	end
end

local function startSpectate(targetPlayer)
	if not targetPlayer or targetPlayer == player then return end
	local targetCharacter = targetPlayer.Character
	if not targetCharacter then return end
	local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
	if not targetHumanoid then return end

	local camera = workspace.CurrentCamera
	if spectating then stopSpectate() end

	spectating = true
	spectatedPlayer = targetPlayer
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = targetHumanoid
end

spectateBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	if spectating then
		stopSpectate()
		updateToggleVisual(spectateBtn, spectateInd, false, "Spectate Target")
	else
		if not selectedPlayerName then return end
		local targetPlayer = Players:FindFirstChild(selectedPlayerName)
		if targetPlayer then
			startSpectate(targetPlayer)
			updateToggleVisual(spectateBtn, spectateInd, true, "Spectate Target")
		end
	end
end)

-- Respawn Character Handler
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")

	if isKeyUnlocked then enableCameraNoLimit() end
	if flyEnabled and isKeyUnlocked then stopFly() startFly() end
end)

print("[PHANTOM SYSTEM] Hub & Auth System Loaded Successfully.")
local spectatedPlayer = nil
local espObjects = {}

-- Utility Clipboard
local function copyToClipboard(text)
	if setclipboard then setclipboard(text) return true end
	if toclipboard then toclipboard(text) return true end
	if syn and syn.write_clipboard then syn.write_clipboard(text) return true end
	if clipboard and clipboard.set then clipboard.set(text) return true end
	return false
end

-- =================================================================
-- SCREEN GUI ROOT
-- =================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodFatherHub_v2"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Dynamic Drag Function (Mouse & Touch Support)
local function makeDraggable(handle, target)
	local dragging = false
	local startInputPos, startFramePos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			startInputPos = input.Position
			startFramePos = target.Position
		end
	end)

	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - startInputPos
			target.Position = UDim2.new(
				startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
				startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
			)
		end
	end)
end

-- =================================================================
-- TOGGLE BUTTON (FLOATING ICON)
-- =================================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 20, 0, 20)
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
toggleBtn.Text = "⚡"
toggleBtn.TextColor3 = Color3.fromRGB(0, 230, 140)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 20
toggleBtn.ZIndex = 10
toggleBtn.Visible = false
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = Color3.fromRGB(0, 230, 140)
toggleStroke.Thickness = 2

makeDraggable(toggleBtn, toggleBtn)

-- =================================================================
-- KEY AUTHENTICATION SYSTEM FRAME
-- =================================================================
local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeyFrame"
keyFrame.Size = UDim2.new(0, 320, 0, 310)
keyFrame.Position = UDim2.new(0.5, -160, 0.5, -155)
keyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = screenGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 10)

local keyStroke = Instance.new("UIStroke", keyFrame)
keyStroke.Color = Color3.fromRGB(40, 40, 55)
keyStroke.Thickness = 1.5

local keyDragHandle = Instance.new("Frame")
keyDragHandle.Name = "KeyDragHandle"
keyDragHandle.Size = UDim2.new(1, 0, 0, 35)
keyDragHandle.BackgroundTransparency = 1
keyDragHandle.Parent = keyFrame
makeDraggable(keyDragHandle, keyFrame)

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 35)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🛡 PHANTOM DEFENSE SYSTEM"
keyTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 13
keyTitle.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.88, 0, 0, 35)
keyInput.Position = UDim2.new(0.06, 0, 0, 45)
keyInput.PlaceholderText = "Enter Access Key..."
keyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
keyInput.Text = ""
keyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 12
keyInput.Parent = keyFrame
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 6)

local keySubmitBtn = Instance.new("TextButton")
keySubmitBtn.Size = UDim2.new(0.88, 0, 0, 35)
keySubmitBtn.Position = UDim2.new(0.06, 0, 0, 88)
keySubmitBtn.Text = "▶ AUTHENTICATE"
keySubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
keySubmitBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
keySubmitBtn.Font = Enum.Font.GothamBold
keySubmitBtn.TextSize = 12
keySubmitBtn.Parent = keyFrame
Instance.new("UICorner", keySubmitBtn).CornerRadius = UDim.new(0, 6)

local keyStatusLabel = Instance.new("TextLabel")
keyStatusLabel.Size = UDim2.new(0.88, 0, 0, 20)
keyStatusLabel.Position = UDim2.new(0.06, 0, 0, 128)
keyStatusLabel.BackgroundTransparency = 1
keyStatusLabel.Text = ""
keyStatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
keyStatusLabel.Font = Enum.Font.Gotham
keyStatusLabel.TextSize = 11
keyStatusLabel.Parent = keyFrame

-- Copy Key Link Section
local linkBriefing = Instance.new("TextLabel")
linkBriefing.Size = UDim2.new(0.88, 0, 0, 80)
linkBriefing.Position = UDim2.new(0.06, 0, 0, 150)
linkBriefing.BackgroundTransparency = 1
linkBriefing.Text = "1. Click 'COPY LINK' below\n2. Open browser & paste link\n3. Get key & submit above"
linkBriefing.TextColor3 = Color3.fromRGB(160, 160, 180)
linkBriefing.Font = Enum.Font.Gotham
linkBriefing.TextSize = 11
linkBriefing.TextYAlignment = Enum.TextYAlignment.Top
linkBriefing.Parent = keyFrame

local copyLinkBtn = Instance.new("TextButton")
copyLinkBtn.Size = UDim2.new(0.88, 0, 0, 35)
copyLinkBtn.Position = UDim2.new(0.06, 0, 0, 245)
copyLinkBtn.Text = "📋 COPY LINK"
copyLinkBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
copyLinkBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
copyLinkBtn.Font = Enum.Font.GothamBold
copyLinkBtn.TextSize = 12
copyLinkBtn.Parent = keyFrame
Instance.new("UICorner", copyLinkBtn).CornerRadius = UDim.new(0, 6)

copyLinkBtn.MouseButton1Click:Connect(function()
	local success = copyToClipboard(LINK)
	if success then
		copyLinkBtn.Text = "COPIED TO CLIPBOARD!"
	else
		copyLinkBtn.Text = "FAILED TO COPY"
	end
	task.wait(2)
	copyLinkBtn.Text = "📋 COPY LINK"
end)

-- =================================================================
-- MAIN HUB FRAME (MODERN & COMPACT)
-- =================================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 310, 0, 320)
mainFrame.Position = UDim2.new(0.5, -155, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Color = Color3.fromRGB(45, 45, 60)
frameStroke.Thickness = 1.5

local mainDragHandle = Instance.new("Frame")
mainDragHandle.Name = "DragHandle"
mainDragHandle.Size = UDim2.new(1, 0, 0, 40)
mainDragHandle.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
mainDragHandle.Parent = mainFrame
Instance.new("UICorner", mainDragHandle).CornerRadius = UDim.new(0, 10)
makeDraggable(mainDragHandle, mainFrame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -15, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "GODFATHER HUB v2"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainDragHandle

-- Scrolling Canvas Container
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ContentScroll"
scrollFrame.Size = UDim2.new(1, -16, 1, -50)
scrollFrame.Position = UDim2.new(0, 8, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 230, 140)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 15)
end)

-- UI Helper Creator
local function createToggleButton(name, text, order)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, -6, 0, 36)
	btn.LayoutOrder = order
	btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	btn.Text = "  " .. text .. ": OFF"
	btn.TextColor3 = Color3.fromRGB(200, 200, 210)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = scrollFrame

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 10, 0, 10)
	indicator.Position = UDim2.new(1, -20, 0.5, -5)
	indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
	indicator.Parent = btn
	Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

	return btn, indicator
end

local function updateToggleVisual(btn, indicator, state, text)
	if state then
		btn.Text = "  " .. text .. ": ON"
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		indicator.BackgroundColor3 = Color3.fromRGB(0, 230, 140)
	else
		btn.Text = "  " .. text .. ": OFF"
		btn.TextColor3 = Color3.fromRGB(200, 200, 210)
		indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
	end
end

-- UI Controls Elements
local flyBtn, flyInd = createToggleButton("FlyBtn", "Fly Control", 1)
local noclipBtn, noclipInd = createToggleButton("NoclipBtn", "Noclip Passthrough", 2)
local jumpBtn, jumpInd = createToggleButton("JumpBtn", "Infinite Jump", 3)
local espBtn, espInd = createToggleButton("EspBtn", "ESP Visuals", 4)

-- WalkSpeed Block
local wsContainer = Instance.new("Frame")
wsContainer.Size = UDim2.new(1, -6, 0, 36)
wsContainer.LayoutOrder = 5
wsContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
wsContainer.Parent = scrollFrame
Instance.new("UICorner", wsContainer).CornerRadius = UDim.new(0, 6)

local wsInput = Instance.new("TextBox")
wsInput.Size = UDim2.new(0.65, -10, 0, 26)
wsInput.Position = UDim2.new(0, 8, 0.5, -13)
wsInput.PlaceholderText = "WalkSpeed (16)..."
wsInput.PlaceholderColor3 = Color3.fromRGB(110, 110, 130)
wsInput.Text = ""
wsInput.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
wsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
wsInput.Font = Enum.Font.Gotham
wsInput.TextSize = 12
wsInput.Parent = wsContainer
Instance.new("UICorner", wsInput).CornerRadius = UDim.new(0, 4)

local wsApplyBtn = Instance.new("TextButton")
wsApplyBtn.Size = UDim2.new(0.35, -12, 0, 26)
wsApplyBtn.Position = UDim2.new(0.65, 4, 0.5, -13)
wsApplyBtn.Text = "Set"
wsApplyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
wsApplyBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
wsApplyBtn.Font = Enum.Font.GothamBold
wsApplyBtn.TextSize = 12
wsApplyBtn.Parent = wsContainer
Instance.new("UICorner", wsApplyBtn).CornerRadius = UDim.new(0, 4)

-- Fly Speed Controls
local flySpeedContainer = Instance.new("Frame")
flySpeedContainer.Size = UDim2.new(1, -6, 0, 36)
flySpeedContainer.LayoutOrder = 6
flySpeedContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
flySpeedContainer.Parent = scrollFrame
Instance.new("UICorner", flySpeedContainer).CornerRadius = UDim.new(0, 6)

local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(0.5, 0, 1, 0)
flySpeedLabel.Position = UDim2.new(0, 10, 0, 0)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "Fly Speed: " .. flySpeed
flySpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
flySpeedLabel.Font = Enum.Font.GothamMedium
flySpeedLabel.TextSize = 12
flySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
flySpeedLabel.Parent = flySpeedContainer

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 28, 0, 24)
minusBtn.Position = UDim2.new(1, -66, 0.5, -12)
minusBtn.Text = "-10"
minusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 11
minusBtn.Parent = flySpeedContainer
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 4)

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 28, 0, 24)
plusBtn.Position = UDim2.new(1, -34, 0.5, -12)
plusBtn.Text = "+10"
plusBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 11
plusBtn.Parent = flySpeedContainer
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 4)

-- Teleport & Spectate Block
local tpDropdown = Instance.new("TextButton")
tpDropdown.Name = "TpDropdown"
tpDropdown.Size = UDim2.new(1, -6, 0, 36)
tpDropdown.LayoutOrder = 7
tpDropdown.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
tpDropdown.Text = "  Select Target ▾"
tpDropdown.TextColor3 = Color3.fromRGB(200, 200, 210)
tpDropdown.Font = Enum.Font.GothamMedium
tpDropdown.TextSize = 12
tpDropdown.TextXAlignment = Enum.TextXAlignment.Left
tpDropdown.Parent = scrollFrame
Instance.new("UICorner", tpDropdown).CornerRadius = UDim.new(0, 6)

local tpGoBtn = Instance.new("TextButton")
tpGoBtn.Name = "TpGoBtn"
tpGoBtn.Size = UDim2.new(1, -6, 0, 36)
tpGoBtn.LayoutOrder = 8
tpGoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
tpGoBtn.Text = "TELEPORT TO PLAYER"
tpGoBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
tpGoBtn.Font = Enum.Font.GothamBold
tpGoBtn.TextSize = 12
tpGoBtn.Parent = scrollFrame
Instance.new("UICorner", tpGoBtn).CornerRadius = UDim.new(0, 6)

local spectateBtn, spectateInd = createToggleButton("SpectateBtn", "Spectate Target", 9)

-- =================================================================
-- FEATURES LOGIC (FLY, NOCLIP, ESP, SPECTATE, UNLOCK)
-- =================================================================

-- Camera Zoom Unlimited
local function enableCameraNoLimit()
	player.CameraMaxZoomDistance = 100000
	player.CameraMinZoomDistance = 0.5
	if cameraZoomConnection then cameraZoomConnection:Disconnect() cameraZoomConnection = nil end
	cameraZoomConnection = RunService.RenderStepped:Connect(function()
		if not isKeyUnlocked then return end
		if player.CameraMaxZoomDistance ~= 100000 then player.CameraMaxZoomDistance = 100000 end
		if player.CameraMinZoomDistance ~= 0.5 then player.CameraMinZoomDistance = 0.5 end
	end)
end

-- Key Unlock Verification
keySubmitBtn.MouseButton1Click:Connect(function()
	if keyInput.Text == CORRECT_KEY then
		isKeyUnlocked = true
		keyStatusLabel.TextColor3 = Color3.fromRGB(0, 230, 140)
		keyStatusLabel.Text = "Access Granted!"
		enableCameraNoLimit()
		task.wait(0.4)
		keyFrame:Destroy()
		mainFrame.Visible = true
		toggleBtn.Visible = true
	else
		keyStatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
		keyStatusLabel.Text = "Invalid Key!"
	end
end)

toggleBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	mainFrame.Visible = not mainFrame.Visible
end)

-- Fly
local function startFly()
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = humanoidRootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 10000
	bodyGyro.CFrame = humanoidRootPart.CFrame
	bodyGyro.Parent = humanoidRootPart

	flyConnection = RunService.RenderStepped:Connect(function()
		local camera = workspace.CurrentCamera
		local camCFrame = camera.CFrame
		local humanoidMoveDir = humanoid.MoveDirection

		local moveDirection = Vector3.new(0, 0, 0)
		if humanoidMoveDir.Magnitude > 0 then
			moveDirection = camCFrame.LookVector * humanoidMoveDir:Dot(camCFrame.LookVector)
				+ camCFrame.RightVector * humanoidMoveDir:Dot(camCFrame.RightVector)
		end

		if moveDirection.Magnitude > 0 then
			bodyVelocity.Velocity = moveDirection.Unit * flySpeed
		else
			bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end
		bodyGyro.CFrame = camCFrame
	end)
end

local function stopFly()
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

flyBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	flyEnabled = not flyEnabled
	if flyEnabled then startFly() else stopFly() end
	updateToggleVisual(flyBtn, flyInd, flyEnabled, "Fly Control")
end)

-- Noclip
local function startNoclip()
	noclipConnection = RunService.Stepped:Connect(function()
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function stopNoclip()
	if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	if character then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
end

noclipBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	noclipEnabled = not noclipEnabled
	if noclipEnabled then startNoclip() else stopNoclip() end
	updateToggleVisual(noclipBtn, noclipInd, noclipEnabled, "Noclip Passthrough")
end)

-- Infinite Jump
local function startInfiniteJump()
	jumpConnection = UserInputService.JumpRequest:Connect(function()
		if infiniteJumpEnabled and humanoid and isKeyUnlocked then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end

jumpBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	infiniteJumpEnabled = not infiniteJumpEnabled
	if infiniteJumpEnabled and not jumpConnection then startInfiniteJump() end
	updateToggleVisual(jumpBtn, jumpInd, infiniteJumpEnabled, "Infinite Jump")
end)

-- ESP Visual System
local function clearESP()
	for plr, data in pairs(espObjects) do
		if data then
			if data.Highlight then data.Highlight:Destroy() end
			if data.Billboard then data.Billboard:Destroy() end
			if data.Tracer then data.Tracer:Remove() end
		end
		espObjects[plr] = nil
	end
end

local function createESP(plr)
	if plr == player or espObjects[plr] then return end
	local char = plr.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "RainbowESP"
	highlight.Adornee = char
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = char

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlayerESP"
	billboard.Adornee = root
	billboard.Size = UDim2.new(0, 150, 0, 60)
	billboard.StudsOffset = Vector3.new(0, 3.5, 0)
	billboard.AlwaysOnTop = true
	billboard.ResetOnSpawn = false
	billboard.Parent = screenGui

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 18)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = plr.DisplayName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.2
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 12
	nameLabel.Parent = billboard

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Name = "Distance"
	distanceLabel.Size = UDim2.new(1, 0, 0, 16)
	distanceLabel.Position = UDim2.new(0, 0, 0, 18)
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Text = "0 studs"
	distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
	distanceLabel.TextStrokeTransparency = 0.3
	distanceLabel.Font = Enum.Font.Gotham
	distanceLabel.TextSize = 11
	distanceLabel.Parent = billboard

	local hpLabel = Instance.new("TextLabel")
	hpLabel.Name = "HP"
	hpLabel.Size = UDim2.new(1, 0, 0, 16)
	hpLabel.Position = UDim2.new(0, 0, 0, 34)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = "HP: 100"
	hpLabel.TextColor3 = Color3.fromRGB(0, 230, 140)
	hpLabel.TextStrokeTransparency = 0.3
	hpLabel.Font = Enum.Font.GothamBold
	hpLabel.TextSize = 11
	hpLabel.Parent = billboard

	local tracer = Drawing.new("Line")
	tracer.Visible = false
	tracer.Thickness = 2
	tracer.Transparency = 1

	espObjects[plr] = { Highlight = highlight, Billboard = billboard, Tracer = tracer }
end

local function removeESP(plr)
	if espObjects[plr] then
		local data = espObjects[plr]
		if data.Highlight then data.Highlight:Destroy() end
		if data.Billboard then data.Billboard:Destroy() end
		if data.Tracer then data.Tracer:Remove() end
		espObjects[plr] = nil
	end
end

local function updateESP()
	if not espEnabled then return end
	local camera = workspace.CurrentCamera
	local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local myRootScreenPos, myRootOnScreen = camera:WorldToViewportPoint(myRoot.Position)
	local rainbowColor = Color3.fromHSV((tick() % 3) / 3, 1, 1)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local char = plr.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if root and hum and hum.Health > 0 then
				createESP(plr)
				local data = espObjects[plr]
				if data then
					if data.Highlight then
						data.Highlight.FillColor = rainbowColor
						data.Highlight.OutlineColor = rainbowColor
					end

					local dist = (myRoot.Position - root.Position).Magnitude
					local distanceLabel = data.Billboard and data.Billboard:FindFirstChild("Distance")
					local hpLabel = data.Billboard and data.Billboard:FindFirstChild("HP")

					if distanceLabel then distanceLabel.Text = math.floor(dist) .. " studs" end
					if hpLabel then
						hpLabel.Text = "HP: " .. math.floor(hum.Health)
						if hum.Health > 50 then hpLabel.TextColor3 = Color3.fromRGB(0, 230, 140)
						elseif hum.Health > 25 then hpLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
						else hpLabel.TextColor3 = Color3.fromRGB(255, 80, 80) end
					end

					local targetScreenPos, targetOnScreen = camera:WorldToViewportPoint(root.Position)
					if data.Tracer then
						if myRootOnScreen and targetOnScreen then
							data.Tracer.From = Vector2.new(myRootScreenPos.X, myRootScreenPos.Y)
							data.Tracer.To = Vector2.new(targetScreenPos.X, targetScreenPos.Y)
							data.Tracer.Color = rainbowColor
							data.Tracer.Visible = true
						else
							data.Tracer.Visible = false
						end
					end
				end
			else
				removeESP(plr)
			end
		end
	end
end

local function startESP()
	if espConnection then espConnection:Disconnect() end
	updateESP()
	espConnection = RunService.RenderStepped:Connect(updateESP)
end

local function stopESP()
	if espConnection then espConnection:Disconnect() espConnection = nil end
	clearESP()
end

espBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	espEnabled = not espEnabled
	if espEnabled then startESP() else stopESP() end
	updateToggleVisual(espBtn, espInd, espEnabled, "ESP Visuals")
end)

Players.PlayerAdded:Connect(function(plr)
	if espEnabled then plr.CharacterAdded:Connect(function() task.wait(0.5) if espEnabled then createESP(plr) end end) end
end)
Players.PlayerRemoving:Connect(removeESP)

-- Speed Controls
wsApplyBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	local val = tonumber(wsInput.Text)
	if val and humanoid then
		humanoid.WalkSpeed = val
		wsApplyBtn.Text = "OK!"
	else
		wsApplyBtn.Text = "Err"
	end
	task.wait(1)
	wsApplyBtn.Text = "Set"
end)

minusBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	flySpeed = math.max(10, flySpeed - 10)
	flySpeedLabel.Text = "Fly Speed: " .. flySpeed
end)

plusBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	flySpeed = math.min(300, flySpeed + 10)
	flySpeedLabel.Text = "Fly Speed: " .. flySpeed
end)

-- Teleport & Target Selector
tpDropdown.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	targetPlayers = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then table.insert(targetPlayers, plr) end
	end

	if #targetPlayers == 0 then
		tpDropdown.Text = "  No Other Players"
		task.wait(1)
		tpDropdown.Text = "  Select Target ▾"
		return
	end

	currentTargetIndex = currentTargetIndex + 1
	if currentTargetIndex > #targetPlayers then currentTargetIndex = 1 end
	local target = targetPlayers[currentTargetIndex]
	selectedPlayerName = target.Name
	tpDropdown.Text = "  Target: " .. target.DisplayName .. " ▾"
end)

tpGoBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked or not selectedPlayerName then return end
	local targetPlayer = Players:FindFirstChild(selectedPlayerName)
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		humanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
		tpGoBtn.Text = "TELEPORTED!"
	else
		tpGoBtn.Text = "TARGET INVALID"
	end
	task.wait(1)
	tpGoBtn.Text = "TELEPORT TO PLAYER"
end)

-- Spectate
local function stopSpectate()
	if not spectating then return end
	local camera = workspace.CurrentCamera
	spectating = false
	spectatedPlayer = nil
	if humanoid then
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
	end
end

local function startSpectate(targetPlayer)
	if not targetPlayer or targetPlayer == player then return end
	local targetCharacter = targetPlayer.Character
	if not targetCharacter then return end
	local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
	if not targetHumanoid then return end

	local camera = workspace.CurrentCamera
	if spectating then stopSpectate() end

	spectating = true
	spectatedPlayer = targetPlayer
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = targetHumanoid
end

spectateBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	if spectating then
		stopSpectate()
		updateToggleVisual(spectateBtn, spectateInd, false, "Spectate Target")
	else
		if not selectedPlayerName then return end
		local targetPlayer = Players:FindFirstChild(selectedPlayerName)
		if targetPlayer then
			startSpectate(targetPlayer)
			updateToggleVisual(spectateBtn, spectateInd, true, "Spectate Target")
		end
	end
end)

-- Respawn Character Handler
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")

	if isKeyUnlocked then enableCameraNoLimit() end
	if flyEnabled and isKeyUnlocked then stopFly() startFly() end
end)
