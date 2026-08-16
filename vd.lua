-- LocalScript
-- Credits: GodFather & goldgoldgoldblazn

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Key Configuration
local CORRECT_KEY = "OpFather211"
local isKeyUnlocked = false

-- States
local flyEnabled = false
local noclipEnabled = false
local infiniteJumpEnabled = false
local espEnabled = false
local flySpeed = 50

local flyConnection = nil
local noclipConnection = nil
local jumpConnection = nil
local espConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

local targetPlayers = {}
local currentTargetIndex = 0
local espObjects = {}

-- ============ ScreenGui ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TestingMenuUI_Modern"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Toggle Button (Bulat Modern)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Active = true
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

local toggleCorner = Instance.new("UICorner", toggleBtn)
toggleCorner.CornerRadius = UDim.new(1, 0)

local toggleStroke = Instance.new("UIStroke", toggleBtn)
toggleStroke.Color = Color3.fromRGB(0, 230, 140)
toggleStroke.Thickness = 2

-- ============ Key Frame ============
local keyFrame = Instance.new("Frame")
keyFrame.Name = "KeyFrame"
keyFrame.Active = true
keyFrame.Size = UDim2.new(0, 280, 0, 190)
keyFrame.Position = UDim2.new(0.5, -140, 0.5, -95)
keyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = screenGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 10)

local keyStroke = Instance.new("UIStroke", keyFrame)
keyStroke.Color = Color3.fromRGB(40, 40, 55)
keyStroke.Thickness = 1.5

local keyDragHandle = Instance.new("Frame")
keyDragHandle.Name = "KeyDragHandle"
keyDragHandle.Active = true
keyDragHandle.Size = UDim2.new(1, 0, 0, 35)
keyDragHandle.BackgroundTransparency = 1
keyDragHandle.ZIndex = 5
keyDragHandle.Parent = keyFrame

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 35)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🔑 KEY SYSTEM"
keyTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 14
keyTitle.ZIndex = 5
keyTitle.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.85, 0, 0, 35)
keyInput.Position = UDim2.new(0.075, 0, 0, 50)
keyInput.PlaceholderText = "Enter Access Key..."
keyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
keyInput.Text = ""
keyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 13
keyInput.ZIndex = 5
keyInput.Parent = keyFrame
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0, 6)

local keySubmitBtn = Instance.new("TextButton")
keySubmitBtn.Size = UDim2.new(0.85, 0, 0, 35)
keySubmitBtn.Position = UDim2.new(0.075, 0, 0, 95)
keySubmitBtn.Text = "UNLOCK MENU"
keySubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
keySubmitBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
keySubmitBtn.Font = Enum.Font.GothamBold
keySubmitBtn.TextSize = 13
keySubmitBtn.ZIndex = 5
keySubmitBtn.Parent = keyFrame
Instance.new("UICorner", keySubmitBtn).CornerRadius = UDim.new(0, 6)

local keyStatusLabel = Instance.new("TextLabel")
keyStatusLabel.Size = UDim2.new(0.85, 0, 0, 20)
keyStatusLabel.Position = UDim2.new(0.075, 0, 0, 145)
keyStatusLabel.BackgroundTransparency = 1
keyStatusLabel.Text = ""
keyStatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
keyStatusLabel.Font = Enum.Font.Gotham
keyStatusLabel.TextSize = 12
keyStatusLabel.ZIndex = 5
keyStatusLabel.Parent = keyFrame

-- ============ Main Frame (Kotak Modern & Compact) ============
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Active = true
frame.Size = UDim2.new(0, 300, 0, 280)
frame.Position = UDim2.new(0.5, -150, 0.5, -140)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = Color3.fromRGB(45, 45, 60)
frameStroke.Thickness = 1.5

-- Header Drag Handle
local dragHandle = Instance.new("Frame")
dragHandle.Name = "DragHandle"
dragHandle.Active = true
dragHandle.Size = UDim2.new(1, 0, 0, 40)
dragHandle.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
dragHandle.ZIndex = 5
dragHandle.Parent = frame
Instance.new("UICorner", dragHandle).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -15, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "GODFATHER HUB v2"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
title.Parent = dragHandle

-- SCROLLING FRAME
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ContentScroll"
scrollFrame.Size = UDim2.new(1, -20, 1, -50)
scrollFrame.Position = UDim2.new(0, 10, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 230, 140)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Helper Function untuk Membuat Button Toggle
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

-- ===== UI ELEMENTS IN SCROLL FRAME =====
local flyBtn, flyInd = createToggleButton("FlyBtn", "Fly Control", 1)
local noclipBtn, noclipInd = createToggleButton("NoclipBtn", "Noclip Passthrough", 2)
local jumpBtn, jumpInd = createToggleButton("JumpBtn", "Infinite Jump", 3)
local espBtn, espInd = createToggleButton("EspBtn", "ESP Visuals", 4)

-- WalkSpeed Container
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

-- Teleport Container
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

-- Spectate Player UI
local spectateLabel = Instance.new("TextLabel")
spectateLabel.Name = "SpectateLabel"
spectateLabel.Size = UDim2.new(1, -6, 0, 20)
spectateLabel.LayoutOrder = 9
spectateLabel.BackgroundTransparency = 1
spectateLabel.Text = "SPECTATE PLAYER"
spectateLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
spectateLabel.Font = Enum.Font.GothamBold
spectateLabel.TextSize = 11
spectateLabel.TextXAlignment = Enum.TextXAlignment.Left
spectateLabel.Parent = scrollFrame

local spectateBtn = Instance.new("TextButton")
spectateBtn.Name = "SpectateBtn"
spectateBtn.Size = UDim2.new(1, -6, 0, 36)
spectateBtn.LayoutOrder = 10
spectateBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
spectateBtn.Text = "  SPECTATE SELECTED PLAYER"
spectateBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
spectateBtn.Font = Enum.Font.GothamBold
spectateBtn.TextSize = 12
spectateBtn.TextXAlignment = Enum.TextXAlignment.Left
spectateBtn.Parent = scrollFrame
Instance.new("UICorner", spectateBtn).CornerRadius = UDim.new(0, 6)

local spectateIndicator = Instance.new("Frame")
spectateIndicator.Name = "Indicator"
spectateIndicator.Size = UDim2.new(0, 10, 0, 10)
spectateIndicator.Position = UDim2.new(1, -20, 0.5, -5)
spectateIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
spectateIndicator.Parent = spectateBtn
Instance.new("UICorner", spectateIndicator).CornerRadius = UDim.new(1, 0)

-- ============ Key & Camera Systems ============

local cameraZoomConnection = nil

local function enableCameraNoLimit()
	player.CameraMaxZoomDistance = 100000
	player.CameraMinZoomDistance = 0.5
	
	if cameraZoomConnection then  
		cameraZoomConnection:Disconnect()  
		cameraZoomConnection = nil  
	end  
	
	cameraZoomConnection = RunService.RenderStepped:Connect(function()  
		if not isKeyUnlocked then return end  
		if player.CameraMaxZoomDistance ~= 100000 then player.CameraMaxZoomDistance = 100000 end  
		if player.CameraMinZoomDistance ~= 0.5 then player.CameraMinZoomDistance = 0.5 end  
	end)
end

keySubmitBtn.MouseButton1Click:Connect(function()
	if keyInput.Text == CORRECT_KEY then
		isKeyUnlocked = true
		keyStatusLabel.TextColor3 = Color3.fromRGB(0, 230, 140)
		keyStatusLabel.Text = "Access Granted!"
		enableCameraNoLimit()
		task.wait(0.4)
		keyFrame:Destroy()
		frame.Visible = true
		toggleBtn.Visible = true
	else
		keyStatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
		keyStatusLabel.Text = "Invalid Key!"
	end
end)

-- Helper Visual Toggle Update
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

-- ============ Fly Logic ============

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

-- ============ Noclip Logic ============

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

-- ============ Infinite Jump Logic ============

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

-- ============ Rainbow Glow Box & Tracer ESP ============

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

	-- Rainbow Box Highlight (Glow Effect)
	local highlight = Instance.new("Highlight")
	highlight.Name = "RainbowESP"
	highlight.Adornee = char
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = char

	-- Info Billboard Gui (Nama, Jarak, HP)
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

	-- Drawing Tracer Line
	local tracer = Drawing.new("Line")
	tracer.Visible = false
	tracer.Thickness = 2
	tracer.Transparency = 1

	espObjects[plr] = {
		Highlight = highlight,
		Billboard = billboard,
		Tracer = tracer
	}
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

	-- Posisi awal Tracer langsung dihitung dari HumanoidRootPart kamu di Layar
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
					-- Update Rainbow Glow Box
					if data.Highlight then
						data.Highlight.FillColor = rainbowColor
						data.Highlight.OutlineColor = rainbowColor
					end

					-- Update Billboard Info
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

					-- Update Rainbow Tracer Line dari HumanoidRootPart kamu ke target
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

-- ============ WalkSpeed & Fly Speed Controls ============

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

-- ============ Teleport Logic ============

local selectedPlayerName = nil
local spectating = false
local spectatedPlayer = nil
local originalCameraSubject = nil

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

-- ============ Character Respawn & UI Toggle ============

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")

	if isKeyUnlocked then enableCameraNoLimit() end
	if flyEnabled and isKeyUnlocked then stopFly() startFly() end
end)

toggleBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	frame.Visible = not frame.Visible
end)

-- ============ Spectate Logic ============

local function stopSpectate()
	if not spectating then return end

	local camera = workspace.CurrentCamera
	spectating = false
	spectatedPlayer = nil

	if humanoid then
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
	end

	spectateBtn.Text = "  SPECTATE SELECTED PLAYER"
	spectateBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
	spectateBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	spectateIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
end

local function startSpectate(targetPlayer)
	if not targetPlayer then return end

	if targetPlayer == player then
		spectateBtn.Text = "  CANNOT SPECTATE YOURSELF"
		task.delay(1, function()
			if spectateBtn then spectateBtn.Text = "  SPECTATE SELECTED PLAYER" end
		end)
		return
	end

	local targetCharacter = targetPlayer.Character
	if not targetCharacter then
		spectateBtn.Text = "  TARGET HAS NO CHARACTER"
		task.delay(1, function()
			if spectateBtn me.Text = "  SPECTATE SELECTED PLAYER" end
		end)
		return
	end

	local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
	if not targetHumanoid then
		spectateBtn.Text = "  TARGET INVALID"
		task.delay(1, function()
			if spectateBtn then spectateBtn.Text = "  SPECTATE SELECTED PLAYER" end
		end)
		return
	end

	local camera = workspace.CurrentCamera
	if spectating then stopSpectate() end

	spectating = true
	spectatedPlayer = targetPlayer
	originalCameraSubject = camera.CameraSubject

	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = targetHumanoid

	spectateBtn.Text = "  SPECTATING: " .. targetPlayer.DisplayName
	spectateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	spectateBtn.BackgroundColor3 = Color3.fromRGB(35, 60, 52)
	spectateIndicator.BackgroundColor3 = Color3.fromRGB(0, 230, 140)
end

spectateBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	if spectating then stopSpectate() return end

	if not selectedPlayerName then
		spectateBtn.Text = "  SELECT A PLAYER FIRST"
		task.delay(1, function()
			if spectateBtn and not spectating then spectateBtn.Text = "  SPECTATE SELECTED PLAYER" end
		end)
		return
	end

	local targetPlayer = Players:FindFirstChild(selectedPlayerName)
	if targetPlayer then
		startSpectate(targetPlayer)
	else
		spectateBtn.Text = "  PLAYER NOT FOUND"
		task.delay(1, function()
			if spectateBtn then spectateBtn.Text = "  SPECTATE SELECTED PLAYER" end
		end)
	end
end)

-- ============ Mobile & Mouse Dragging ============

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

makeDraggable(dragHandle, frame)
makeDraggable(toggleBtn, toggleBtn)
makeDraggable(keyDragHandle, keyFrame)


-- =================================================================
-- =============== SCRIPT 2: VIOLENCE DISTRICT HUB =================
-- =================================================================

task.spawn(function()
	local function detectMobilePlatform()
		local hasTouchScreen = UserInputService.TouchEnabled
		local camera = workspace.CurrentCamera
		local viewportSize = camera and camera.ViewportSize or Vector2.new(0, 0)
		local isSmallScreen = viewportSize.X <= 1024 or viewportSize.Y <= 768
		local hasGyroscope = UserInputService.GyroscopeEnabled or UserInputService.AccelerometerEnabled
		local noKeyboard = not UserInputService.KeyboardEnabled
		
		local executorName = identifyexecutor and identifyexecutor() or "Unknown"
		local isMobileExecutor = executorName:lower():find("delta") or 
								 executorName:lower():find("arceus") or
								 executorName:lower():find("fluxus") or
								 executorName:lower():find("krnl")
		
		local isMobile = hasTouchScreen and (noKeyboard or isSmallScreen or hasGyroscope or isMobileExecutor)
		if hasTouchScreen and isMobileExecutor then isMobile = true end
		return isMobile
	end

	local isMobile = detectMobilePlatform()
	local executorName = identifyexecutor and identifyexecutor() or "Unknown"

	print("=== Violence District v2.2 Mobile Compatible ===")
	print("Platform: " .. (isMobile and "Mobile" or "PC"))
	print("Executor: " .. executorName)
	print("============================================")

	local function safeHttpGet(url)
		local success, result
		if game.HttpGet then
			success, result = pcall(function() return game:HttpGet(url) end)
			if success then return result end
		end
		if syn and syn.request then
			success, result = pcall(function() return syn.request({Url = url, Method = "GET"}).Body end)
			if success then return result end
		end
		if http and http.request then
			success, result = pcall(function() return http.request({Url = url, Method = "GET"}).Body end)
			if success then return result end
		end
		if http_request then
			success, result = pcall(function() return http_request({Url = url, Method = "GET"}).Body end)
			if success then return result end
		end
		if request then
			success, result = pcall(function() return request({Url = url, Method = "GET"}).Body end)
			if success then return result end
		end
		error("Failed to load URL: " .. url)
	end

	local Rayfield
	local loadSuccess, loadError = pcall(function()
		Rayfield = loadstring(safeHttpGet('https://sirius.menu/rayfield'))()
	end)

	if not loadSuccess then
		warn("Failed to load Rayfield from sirius.menu, trying backup...")
		pcall(function()
			Rayfield = loadstring(safeHttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
		end)
		if not Rayfield then
			error("CRITICAL: Could not load Rayfield UI Library. Please check your internet connection or executor compatibility.")
		end
	end

	local LocalPlayer = Players.LocalPlayer

	local Config = {
		ESP = {
			Killer = false,
			Survivor = false,
			Generator = false,
			Gate = false,
			Hook = false,
			Pallet = false,
			Window = false,
			Pumpkin = false,
			ClosestHook = false,
			ShowOnlyClosestHook = false,
			ShowDistance = true,
			MaxDistance = 500
		},
		AutoFeatures = {
			AutoGenerator = false,
			GeneratorMode = "great",
			AutoLeaveGenerator = false,
			LeaveDistance = 15,
			LeaveKeybind = Enum.KeyCode.Q,
			AutoAttack = false,
			AttackRange = 10
		},
		Teleportation = {
			TeleportOffset = 3,
			SafeTeleport = true,
			TeleportDelay = 0.1
		},
		Performance = {
			UpdateRate = 0.5,
			UseDistanceCulling = true,
			MaxESPObjects = isMobile and 50 or 100, 
			DisableParticles = false,
			LowerGraphics = false,
			DisableShadows = false,
			ReduceRenderDistance = false
		},
		Mobile = {
			TouchControlsEnabled = isMobile,
			ButtonSize = 80,
			ButtonTransparency = 0.3,
			AutoOptimize = true,
			AggressiveOptimization = false
		}
	}

	local Highlights = {}
	local BillboardGuis = {}
	local LastUpdate = 0
	local UpdateConnection = nil
	local LeaveGeneratorConnection = nil
	local AutoAttackConnection = nil
	local MobileUI = nil
	local FPSCounterEnabled = false
	local FPSCounterUI = nil

	local function notify(title, content, duration)
		local success = pcall(function()
			Rayfield:Notify({
				Title = title,
				Content = content,
				Duration = duration or 3,
				Image = 4483362458
			})
		end)
		if not success then
			warn(string.format("[%s] %s", title, content))
		end
	end

	local function safeCall(func, ...)
		local success, result = pcall(func, ...)
		if not success then return nil end
		return result
	end

	local function validateInstance(instance)
		return instance and typeof(instance) == "Instance" and instance.Parent ~= nil
	end

	local function isKiller()
		return LocalPlayer.Team and LocalPlayer.Team.Name == "Killer"
	end

	local function isSurvivor()
		return LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors"
	end

	local function applyMobileOptimizations()
		if not isMobile then return end
		local lighting = game:GetService("Lighting")
		
		safeCall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			lighting.GlobalShadows = false
			lighting.FogEnd = 100
			lighting.Brightness = 2
			
			for _, effect in ipairs(lighting:GetChildren()) do
				if effect:IsA("PostEffect") then effect.Enabled = false end
			end
			
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
					obj.Enabled = false
				end
			end
			
			Workspace.StreamingEnabled = true
			Workspace.StreamingMinRadius = 32
			Workspace.StreamingTargetRadius = 64
			
			if Workspace:FindFirstChild("Terrain") then
				Workspace.Terrain.Decoration = false
			end
			
			RunService:Set3dRenderingEnabled(true)
		end)
	end

	local function applyAggressiveMobileOptimizations()
		if not isMobile then return end
		applyMobileOptimizations()
		
		safeCall(function()
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
			settings().Rendering.EnableFRM = false
			
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("Texture") or obj:IsA("Decal") then
					obj.Transparency = 1
				elseif obj:IsA("SurfaceAppearance") then
					obj.Parent = nil
				end
			end
			
			safeCall(function()
				for _, sound in ipairs(Workspace:GetDescendants()) do
					if sound:IsA("Sound") and sound.Name ~= "Music" then
						sound.Volume = 0
					end
				end
			end)
			
			Config.Performance.UpdateRate = 1.0 
			Config.Performance.MaxESPObjects = 25 
		end)
	end

	local function applyPerformanceSettings()
		local lighting = game:GetService("Lighting")
		if Config.Performance.DisableParticles then
			safeCall(function()
				for _, obj in ipairs(Workspace:GetDescendants()) do
					if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
						obj.Enabled = false
					end
				end
			end)
		end
		if Config.Performance.LowerGraphics then
			safeCall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
		end
		if Config.Performance.DisableShadows then
			safeCall(function()
				lighting.GlobalShadows = false
				lighting.FogEnd = 100
			end)
		end
		if Config.Performance.ReduceRenderDistance then
			safeCall(function()
				Workspace.StreamingEnabled = true
				Workspace.StreamingMinRadius = 32
				Workspace.StreamingTargetRadius = 64
			end)
		end
	end

	local function resetPerformanceSettings()
		local lighting = game:GetService("Lighting")
		safeCall(function()
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
					obj.Enabled = true
				end
			end
			settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
			lighting.GlobalShadows = true
			lighting.FogEnd = 100000
			
			for _, effect in ipairs(lighting:GetChildren()) do
				if effect:IsA("PostEffect") then effect.Enabled = true end
			end
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if obj:IsA("Texture") or obj:IsA("Decal") then obj.Transparency = 0 end
			end
		end)
	end

	local function getCharacterRootPart()
		if not LocalPlayer.Character then return nil end
		return LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	end

	local function safeTeleport(targetCFrame, offset)
		local hrp = getCharacterRootPart()
		if not hrp then 
			notify("Error", "Character not found", 3)
			return false
		end
		
		offset = offset or Vector3.new(0, Config.Teleportation.TeleportOffset, 0)
		
		if Config.Teleportation.SafeTeleport then
			safeCall(function()
				for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end)
		end
		
		hrp.CFrame = targetCFrame + offset
		
		if Config.Teleportation.SafeTeleport then
			task.delay(0.5, function()
				safeCall(function()
					for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
						if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
							part.CanCollide = true
						end
					end
				end)
			end)
		end
		return true
	end

	local function isNearGenerator()
		local hrp = getCharacterRootPart()
		if not hrp then return false, nil end
		local map = Workspace:FindFirstChild("Map")
		if not map then return false, nil end
		
		local nearestGen, nearestDist = nil, math.huge
		for _, obj in ipairs(map:GetDescendants()) do
			if obj:IsA("Model") and obj.Name == "Generator" then
				local genPart = obj:FindFirstChildWhichIsA("BasePart")
				if genPart then
					local distance = (genPart.Position - hrp.Position).Magnitude
					if distance < nearestDist then
						nearestDist = distance
						nearestGen = obj
					end
				end
			end
		end
		if nearestGen and nearestDist <= Config.AutoFeatures.LeaveDistance then
			return true, nearestGen, nearestDist
		end
		return false, nil, nil
	end

	local function leaveGenerator()
		local hrp = getCharacterRootPart()
		if not hrp then return false end
		
		local isNear, nearestGen = isNearGenerator()
		if not isNear then
			notify("Not Near", "You're not near any generator", 2)
			return false
		end
		
		local genPart = nearestGen:FindFirstChildWhichIsA("BasePart")
		if genPart then
			local direction = (hrp.Position - genPart.Position).Unit
			local escapeDistance = Config.AutoFeatures.LeaveDistance + 15
			local escapePosition = hrp.Position + (direction * escapeDistance)
			local escapeCFrame = CFrame.new(escapePosition, escapePosition + hrp.CFrame.LookVector)
			
			if safeTeleport(escapeCFrame, Vector3.new(0, 2, 0)) then
				notify("Escaped!", string.format("Moved %.0f studs away", escapeDistance), 2)
				return true
			end
		end
		return false
	end

	local function createMobileControls()
		if not isMobile then return end
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "MobileControls"
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		
		local leaveButton = Instance.new("TextButton")
		leaveButton.Name = "LeaveGenerator"
		leaveButton.Size = UDim2.new(0, Config.Mobile.ButtonSize, 0, Config.Mobile.ButtonSize)
		leaveButton.Position = UDim2.new(1, -100, 0.5, -40)
		leaveButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		leaveButton.BackgroundTransparency = Config.Mobile.ButtonTransparency
		leaveButton.Text = "LEAVE"
		leaveButton.TextColor3 = Color3.new(1, 1, 1)
		leaveButton.TextScaled = true
		leaveButton.Font = Enum.Font.GothamBold
		leaveButton.Parent = screenGui
		
		Instance.new("UICorner", leaveButton).CornerRadius = UDim.new(0, 10)
		leaveButton.MouseButton1Click:Connect(leaveGenerator)
		
		local tpButton = Instance.new("TextButton")
		tpButton.Name = "TeleportGen"
		tpButton.Size = UDim2.new(0, Config.Mobile.ButtonSize, 0, Config.Mobile.ButtonSize)
		tpButton.Position = UDim2.new(1, -100, 0.5, 60)
		tpButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
		tpButton.BackgroundTransparency = Config.Mobile.ButtonTransparency
		tpButton.Text = "TP GEN"
		tpButton.TextColor3 = Color3.new(1, 1, 1)
		tpButton.TextScaled = true
		tpButton.Font = Enum.Font.GothamBold
		tpButton.Parent = screenGui
		
		Instance.new("UICorner", tpButton).CornerRadius = UDim.new(0, 10)
		tpButton.MouseButton1Click:Connect(function()
			local map = Workspace:FindFirstChild("Map")
			if not map then return end
			local hrp = getCharacterRootPart()
			if not hrp then return end
			
			local closestGen = nil
			local closestDist = math.huge
			for _, obj in ipairs(map:GetDescendants()) do
				if obj:IsA("Model") and obj.Name == "Generator" then
					local genPart = obj:FindFirstChildWhichIsA("BasePart")
					if genPart then
						local dist = (genPart.Position - hrp.Position).Magnitude
						if dist < closestDist then
							closestDist = dist
							closestGen = genPart
						end
					end
				end
			end
			if closestGen then
				safeTeleport(closestGen.CFrame)
				notify("Teleported!", "Moved to closest generator", 2)
			end
		end)
		
		if pcall(function() screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) then
			notify("Mobile Controls", "Touch controls enabled!", 3)
			MobileUI = screenGui
		end
	end

	local function createFPSCounter()
		if FPSCounterUI then return end
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FPSCounter"
		screenGui.ResetOnSpawn = false
		
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 120, 0, 50)
		frame.Position = UDim2.new(0, 10, 0, 10)
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		frame.BackgroundTransparency = 0.3
		frame.Parent = screenGui
		
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
		
		local fpsLabel = Instance.new("TextLabel")
		fpsLabel.Size = UDim2.new(1, 0, 1, 0)
		fpsLabel.BackgroundTransparency = 1
		fpsLabel.Text = "FPS: 0"
		fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		fpsLabel.Font = Enum.Font.GothamBold
		fpsLabel.TextSize = 18
		fpsLabel.Parent = frame
		
		local lastTime, frameCount = tick(), 0
		RunService.Heartbeat:Connect(function()
			if not FPSCounterEnabled then return end
			frameCount = frameCount + 1
			local currentTime = tick()
			local deltaTime = currentTime - lastTime
			if deltaTime >= 1.5 then
				local fps = math.floor(frameCount / deltaTime)
				frameCount = 0
				lastTime = currentTime
				fpsLabel.TextColor3 = fps >= 60 and Color3.fromRGB(0, 255, 0) or (fps >= 30 and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(255, 0, 0))
				fpsLabel.Text = string.format("FPS: %d", fps)
			end
		end)
		
		if pcall(function() screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end) then
			FPSCounterUI = screenGui
			FPSCounterEnabled = true
			notify("FPS Counter", "Enabled!", 3)
		end
	end

	local function removeFPSCounter()
		if FPSCounterUI then
			FPSCounterUI:Destroy()
			FPSCounterUI = nil
			FPSCounterEnabled = false
		end
	end

	local Window = Rayfield:CreateWindow({
		Name = "🎮 Golds Easy Hub - Violence District v2.2",
		LoadingTitle = "Loading Mobile-Compatible Script",
		LoadingSubtitle = "by goldgoldgoldblazn | " .. (isMobile and "Mobile Mode" or "PC Mode"),
		ConfigurationSaving = { Enabled = false },
		Discord = { Enabled = false },
		KeySystem = false
	})

	local CreditsTab = Window:CreateTab("ℹ️ Credits & Info", 4483362458)
	CreditsTab:CreateSection("👤 Main Developer")
	CreditsTab:CreateLabel("Created by: goldgoldgoldblazn")
	CreditsTab:CreateLabel("Version: 2.2 (Mobile Compatible)")

	local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
	ESPTab:CreateSection("ESP Visuals Settings")
	ESPTab:CreateToggle({
		Name = "Killer ESP (Red)",
		CurrentValue = false,
		Callback = function(Value) Config.ESP.Killer = Value end
	})
	ESPTab:CreateToggle({
		Name = "Survivor ESP (Green)",
		CurrentValue = false,
		Callback = function(Value) Config.ESP.Survivor = Value end
	})

	local GameplayTab = Window:CreateTab("🎮 Gameplay", 4483362458)
	GameplayTab:CreateSection("Auto Features")
	GameplayTab:CreateToggle({
		Name = "Auto Complete Generators",
		CurrentValue = false,
		Callback = function(Value) Config.AutoFeatures.AutoGenerator = Value end
	})

	local TeleportTab = Window:CreateTab("🚀 Teleport", 4483362458)
	TeleportTab:CreateSection("Quick Teleports")
	TeleportTab:CreateButton({
		Name = "Teleport to Exit Gate",
		Callback = function()
			local map = Workspace:FindFirstChild("Map")
			if not map then return end
			for _, obj in ipairs(map:GetDescendants()) do
				if obj:IsA("Model") and obj.Name == "Gate" then
					local gatePart = obj:FindFirstChildWhichIsA("BasePart")
					if gatePart then safeTeleport(gatePart.CFrame) break end
				end
			end
		end
	})

	local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
	SettingsTab:CreateSection("Display Options")
	SettingsTab:CreateToggle({
		Name = "Show FPS Counter",
		CurrentValue = false,
		Callback = function(Value)
			if Value then createFPSCounter() else removeFPSCounter() end
		end
	})

	-- Loop untuk Auto Repair Generator
	task.spawn(function()
		while task.wait(0.2) do
			if Config.AutoFeatures.AutoGenerator then
				safeCall(function()
					local remotes = ReplicatedStorage:FindFirstChild("Remotes")
					if not remotes then return end
					local genRemotes = remotes:FindFirstChild("Generator")
					if not genRemotes then return end
					local repairEvent = genRemotes:FindFirstChild("RepairEvent")
					local skillCheckEvent = genRemotes:FindFirstChild("SkillCheckResultEvent")
					if not repairEvent or not skillCheckEvent then return end
					
					local map = Workspace:FindFirstChild("Map")
					if not map then return end
					for _, obj in ipairs(map:GetDescendants()) do
						if obj:IsA("Model") and obj.Name == "Generator" then
							for _, point in ipairs(obj:GetChildren()) do
								if point.Name:find("GeneratorPoint") then
									pcall(function()
										repairEvent:FireServer(point, true)
										local result = Config.AutoFeatures.GeneratorMode == "great" and "success" or "neutral"
										local value = Config.AutoFeatures.GeneratorMode == "great" and 1 or 0
										skillCheckEvent:FireServer(result, value, obj, point)
									end)
								end
							end
						end
					end
				end)
			end
		end
	end)

	if isMobile then
		task.wait(1)
		createMobileControls()
		if Config.Mobile.AutoOptimize then
			task.wait(0.5)
			applyMobileOptimizations()
		end
	end

	notify("Script Loaded!", "Violence District v2.2 & GodFather Hub", 4)
end)
