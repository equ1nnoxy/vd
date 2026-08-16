-- =================================================================
-- GODFATHER HUB v2 // PHANTOM SYSTEM (NATIVE UI IMPLEMENTATION)
-- =================================================================

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- State Variables
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
