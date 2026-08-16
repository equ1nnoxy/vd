-- Combined Script: Godfather UI + Full GoldGoldGold Features
-- UI Framework: Godfather

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ============ Key Configuration & States ============
local CORRECT_KEY = "OpFather211"
local isKeyUnlocked = false

local flyEnabled = false
local noclipEnabled = false
local infiniteJumpEnabled = false
local espEnabled = false
local autoGenEnabled = false
local autoSkillCheckEnabled = false
local fullbrightEnabled = false
local flySpeed = 50

local flyConnection = nil
local noclipConnection = nil
local jumpConnection = nil
local espConnection = nil
local autoGenThread = nil
local bodyVelocity = nil
local bodyGyro = nil

local targetPlayers = {}
local currentTargetIndex = 0
local espObjects = {}

-- ============ GoldGoldGold Logic Config & Vars ============
local Config = {
    Players = {
        Killer = {Color = Color3.fromRGB(255, 93, 108)}, 
        Survivor = {Color = Color3.fromRGB(64, 224, 255)}
    },
    Objects = {
        Generator = {Color = Color3.fromRGB(150, 0, 200)}, 
        Gate = {Color = Color3.fromRGB(255, 255, 255)},
        Pallet = {Color = Color3.fromRGB(74, 255, 181)}, 
        Window = {Color = Color3.fromRGB(74, 255, 181)},
        Hook = {Color = Color3.fromRGB(132, 255, 169)}
    }
}

local MaskNames = {
    ["Richard"] = "Rooster", ["Tony"] = "Tiger", ["Brandon"] = "Panther",
    ["Cobra"] = "Cobra", ["Richter"] = "Rat", ["Rabbit"] = "Rabbit", ["Alex"] = "Chainsaw"
}

local MaskColors = {
    ["Richard"] = Color3.fromRGB(255, 0, 0), ["Tony"] = Color3.fromRGB(255, 255, 0),
    ["Brandon"] = Color3.fromRGB(160, 32, 240), ["Cobra"] = Color3.fromRGB(0, 255, 0),
    ["Richter"] = Color3.fromRGB(0, 0, 0), ["Rabbit"] = Color3.fromRGB(255, 105, 180),
    ["Alex"] = Color3.fromRGB(255, 255, 255)
}

local ActiveGenerators = {}
local LastUpdateTick = 0
local LastFullESPRefresh = 0
local TouchID = 8822
local ActionPath = "Survivor-mob.Controls.action.check"
local HeartbeatConnection = nil
local VisibilityConnection = nil
local IndicatorGui = nil

-- Helper Functions (GoldGoldGold)
local function SetupGui()
    if PlayerGui:FindFirstChild("ChasedInds") then PlayerGui:FindFirstChild("ChasedInds"):Destroy() end
    IndicatorGui = Instance.new("ScreenGui")
    IndicatorGui.Name = "ChasedInds"
    IndicatorGui.IgnoreGuiInset = true
    IndicatorGui.DisplayOrder = 999
    IndicatorGui.Parent = PlayerGui
end

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child then
        local success, val = pcall(function() return child.Value end)
        if success then return val end
    end
    return nil
end

local function ApplyHighlight(object, color)
    local h = object:FindFirstChild("H") or Instance.new("Highlight")
    h.Name = "H"
    h.Adornee = object
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.8
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
end

local function CreateBillboardTag(text, color, size, textSize)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BitchHook"
    billboard.AlwaysOnTop = true
    billboard.Size = size or UDim2.new(0, 120, 0, 30)
    
    local label = Instance.new("TextLabel")
    label.Name = "BitchHook"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = textSize or 10
    label.TextWrapped = true
    label.RichText = true 
    label.Parent = billboard
    return billboard
end

local function updatePlayerNametag(plr)
    if not IndicatorGui or not IndicatorGui.Parent then return end
    if not plr.Character then
        local m = IndicatorGui:FindFirstChild(plr.Name) if m then m:Destroy() end
        local c = IndicatorGui:FindFirstChild(plr.Name .. "_Chased") if c then c:Destroy() end
        local k = IndicatorGui:FindFirstChild(plr.Name .. "_Killer") if k then k:Destroy() end
        return 
    end
    
    local rootPart = plr.Character:FindFirstChild("HumanoidRootPart")
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not rootPart then return end
    
    local teamName = (plr.Team and plr.Team.Name:lower()) or ""
    local selectedKillerAttr = GetGameValue(plr, "SelectedKiller")
    local rawMask = GetGameValue(plr, "Mask") or GetGameValue(plr.Character, "Mask")
    local isKnocked = GetGameValue(plr.Character, "Knocked")
    local isHooked = GetGameValue(plr.Character, "IsHooked")
    local isChased = GetGameValue(plr.Character, "IsChased")
    
    local isKiller = teamName:find("killer") ~= nil
    local color = isKiller and Config.Players.Killer.Color or Config.Players.Survivor.Color
    
    if isHooked then 
        color = Color3.fromRGB(255, 182, 193) 
    elseif hum and hum.Health < hum.MaxHealth then
        color = isKnocked and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(200, 200, 0)
    end
    
    local distance = 0
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        distance = math.floor((rootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
    end
    
    local baseName = (isKiller and selectedKillerAttr and tostring(selectedKillerAttr) ~= "") and tostring(selectedKillerAttr) or plr.Name
    local billboard = rootPart:FindFirstChild("BitchHook")
    local nameText = baseName .. "\n[" .. distance .. " studs]"
    
    if not billboard then
        billboard = CreateBillboardTag(nameText, color)
        billboard.Adornee = rootPart
        billboard.Parent = rootPart
    else
        local lbl = billboard:FindFirstChild("BitchHook") or billboard:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text = nameText lbl.TextColor3 = color end
    end
    
    ApplyHighlight(plr.Character, color)

    local hasMask = false
    if isKiller and string.match(tostring(selectedKillerAttr):lower(), "masked") and rawMask then
        local searchMask = tostring(rawMask):lower()
        for key, name in pairs(MaskNames) do
            if key:lower() == searchMask then
                hasMask = true
                local maskBillboard = rootPart:FindFirstChild("MaskHook")
                if not maskBillboard then
                    maskBillboard = CreateBillboardTag(name, MaskColors[key] or Color3.new(1,1,1), UDim2.new(0, 100, 0, 20), 12)
                    maskBillboard.Name = "MaskHook"
                    maskBillboard.StudsOffset = Vector3.new(0, 3, 0)
                    maskBillboard.Adornee = rootPart
                    maskBillboard.Parent = rootPart
                else
                    local lbl = maskBillboard:FindFirstChild("BitchHook") or maskBillboard:FindFirstChildOfClass("TextLabel")
                    if lbl then lbl.Text = name lbl.TextColor3 = MaskColors[key] or Color3.new(1,1,1) end
                end
                break
            end
        end
    end
    if not hasMask then
        local maskBillboard = rootPart:FindFirstChild("MaskHook")
        if maskBillboard then maskBillboard:Destroy() end
    end

    local chasedLabel2D = IndicatorGui:FindFirstChild(plr.Name .. "_Chased")
    if isChased then
        local ct3 = billboard:FindFirstChild("ChasedLabel")
        if not ct3 then
            ct3 = Instance.new("TextLabel", billboard)
            ct3.Name = "ChasedLabel"
            ct3.Size, ct3.Position, ct3.BackgroundTransparency = UDim2.new(1,0,1,0), UDim2.new(0,0,-1.2,0), 1
            ct3.Font, ct3.TextSize = Enum.Font.GothamBold, 24
        end
        ct3.Text, ct3.TextColor3, ct3.TextStrokeTransparency = "!!", color, 0
        
        if not chasedLabel2D then
            chasedLabel2D = Instance.new("TextLabel", IndicatorGui)
            chasedLabel2D.Name, chasedLabel2D.BackgroundTransparency = plr.Name .. "_Chased", 1
            chasedLabel2D.Font, chasedLabel2D.TextSize, chasedLabel2D.TextStrokeTransparency = Enum.Font.GothamBold, 24, 0
            chasedLabel2D.AnchorPoint = Vector2.new(0.5, 0.5)
        end
        chasedLabel2D.Text, chasedLabel2D.TextColor3 = "!!", color
        
        local screenPos, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
        if onScreen then
            chasedLabel2D.Visible = false 
        else
            chasedLabel2D.Visible = true
            local viewportCenter = Workspace.CurrentCamera.ViewportSize / 2
            local direction = Vector2.new(screenPos.X, screenPos.Y) - viewportCenter
            if screenPos.Z < 0 then direction = -direction end
            local maxScale = math.max(math.abs(direction.X) / (viewportCenter.X - 30), math.abs(direction.Y) / (viewportCenter.Y - 30))
            chasedLabel2D.Position = UDim2.new(0, viewportCenter.X + direction.X / (maxScale == 0 and 1 or maxScale), 0, viewportCenter.Y + direction.Y / (maxScale == 0 and 1 or maxScale))
        end
    else
        if chasedLabel2D then chasedLabel2D:Destroy() end
        local ct3 = billboard:FindFirstChild("ChasedLabel")
        if ct3 then ct3:Destroy() end
    end

    local killerLabel2D = IndicatorGui:FindFirstChild(plr.Name .. "_Killer")
    if isKiller then
        if not killerLabel2D then
            killerLabel2D = Instance.new("TextLabel", IndicatorGui)
            killerLabel2D.Name, killerLabel2D.BackgroundTransparency = plr.Name .. "_Killer", 1
            killerLabel2D.Font, killerLabel2D.TextSize, killerLabel2D.TextStrokeTransparency = Enum.Font.GothamBold, 10, 0
            killerLabel2D.Size, killerLabel2D.RichText, killerLabel2D.AnchorPoint = UDim2.new(0, 120, 0, 30), true, Vector2.new(0.5, 0.5)
        end
        killerLabel2D.Text, killerLabel2D.TextColor3 = baseName .. "\n[" .. distance .. " studs]", color
        
        local screenPos, onScreen = Workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
        if not onScreen then
            killerLabel2D.Visible = true
            local viewportCenter = Workspace.CurrentCamera.ViewportSize / 2
            local direction = Vector2.new(screenPos.X, screenPos.Y) - viewportCenter
            if screenPos.Z < 0 then direction = -direction end
            local maxScale = math.max(math.abs(direction.X) / (viewportCenter.X - 30), math.abs(direction.Y) / (viewportCenter.Y - 30))
            killerLabel2D.Position = UDim2.new(0, viewportCenter.X + direction.X / (maxScale == 0 and 1 or maxScale), 0, viewportCenter.Y + direction.Y / (maxScale == 0 and 1 or maxScale))
        else
            killerLabel2D.Visible = false
        end
    elseif killerLabel2D then killerLabel2D:Destroy() end
end

local function updateGeneratorProgress(generator)
    if not generator or not generator.Parent then return true end
    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    
    local billboard = generator:FindFirstChild("GenBitchHook")
    if percent >= 100 then
        if billboard then billboard:Destroy() end
        local h = generator:FindFirstChild("H") if h then h:Destroy() end
        return true
    end
    
    local cp = math.clamp(percent, 0, 100)
    local finalColor = cp < 50 and Config.Objects.Generator.Color:Lerp(Color3.fromRGB(180, 180, 0), cp / 50) or Color3.fromRGB(180, 180, 0):Lerp(Color3.fromRGB(0, 150, 0), (cp - 50) / 50)
    
    local percentStr = string.format("[%.2f%%]", percent)
    if not billboard then
        billboard = CreateBillboardTag(percentStr, finalColor)
        billboard.Name, billboard.StudsOffset = "GenBitchHook", Vector3.new(0, 2, 0)
        billboard.Adornee = generator:FindFirstChild("defaultMaterial", true) or generator
        billboard.Parent = generator
    else
        local lbl = billboard:FindFirstChild("BitchHook") or billboard:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text = percentStr lbl.TextColor3 = finalColor end
    end
    return false
end

local function updateNextKillerDisplay()
    if not IndicatorGui or not IndicatorGui.Parent then return end
    local label = IndicatorGui:FindFirstChild("NextKillerDisplay")
    local teamName = (player.Team and player.Team.Name:lower()) or ""
    if teamName:find("spectator") or teamName:find("lobby") then
        if not label then
            label = Instance.new("TextLabel", IndicatorGui)
            label.Name, label.Size, label.Position = "NextKillerDisplay", UDim2.new(0, 220, 0, 30), UDim2.new(0.5, 0, 0, 45)
            label.AnchorPoint, label.BackgroundTransparency, label.BackgroundColor3 = Vector2.new(0.5, 0), 0.5, Color3.new(0, 0, 0)
            label.TextColor3, label.Font, label.TextSize, label.RichText = Color3.new(1, 1, 1), Enum.Font.GothamBold, 14, true
            label.Text = "Next Killer: Calculating..."
        end
        local playersList = Players:GetPlayers()
        
        table.sort(playersList, function(a, b)
            local aA = GetGameValue(a, "AllowKiller") or false
            local bA = GetGameValue(b, "AllowKiller") or false
            if aA ~= bA then return aA == true end
            return (GetGameValue(a, "KillerChance") or 0) > (GetGameValue(b, "KillerChance") or 0)
        end)
        
        local nk = playersList[1]
        if nk then
            label.Text = "Next Killer: <font color=\"rgb(255,0,0)\">" .. (nk == player and "YOU" or tostring(GetGameValue(nk, "SelectedKiller") or nk.Name)) .. "</font>"
        end
    elseif label then label:Destroy() end
end

local function RefreshMapESP()
    ActiveGenerators = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Window" then ApplyHighlight(obj, Config.Objects.Window.Color) end
    end
    local Map = Workspace:FindFirstChild("Map")
    if not Map then return end
    for _, obj in ipairs(Map:GetDescendants()) do
        if obj.Name == "Generator" then ApplyHighlight(obj, Config.Objects.Generator.Color) table.insert(ActiveGenerators, obj)
        elseif obj.Name == "Hook" then local m = obj:FindFirstChild("Model") if m then for _, p in ipairs(m:GetDescendants()) do if p:IsA("MeshPart") then ApplyHighlight(p, Config.Objects.Hook.Color) end end end
        elseif obj.Name == "Palletwrong" or obj.Name == "Pallet" then ApplyHighlight(obj, Config.Objects.Pallet.Color)
        elseif obj.Name == "Gate" then ApplyHighlight(obj, Config.Objects.Gate.Color) end
    end
end

local function GetActionTarget()
    local current = PlayerGui
    for segment in string.gmatch(ActionPath, "[^%.]+") do current = current and current:FindFirstChild(segment) end
    return current
end

local function TriggerMobileButton()
    local b = GetActionTarget()
    if b and b:IsA("GuiObject") then
        local p, s, i = b.AbsolutePosition, b.AbsoluteSize, GuiService:GetGuiInset()
        local cx, cy = p.X + (s.X/2) + i.X, p.Y + (s.Y/2) + i.Y
        pcall(function() VirtualInputManager:SendTouchEvent(TouchID, 0, cx, cy) task.wait(0.01) VirtualInputManager:SendTouchEvent(TouchID, 2, cx, cy) end)
    end
end

local function InitializeAutobuy()
    if not autoSkillCheckEnabled then return end
    task.spawn(function()
        local prompt = PlayerGui:WaitForChild("SkillCheckPromptGui", 10)
        local check = prompt and prompt:WaitForChild("Check", 10)
        if not check then return end
        local line, goal = check:WaitForChild("Line"), check:WaitForChild("Goal")
        if VisibilityConnection then VisibilityConnection:Disconnect() end
        VisibilityConnection = check:GetPropertyChangedSignal("Visible"):Connect(function()
            if autoSkillCheckEnabled and player.Team and player.Team.Name == "Survivors" and check.Visible then
                if HeartbeatConnection then HeartbeatConnection:Disconnect() end
                HeartbeatConnection = RunService.Heartbeat:Connect(function()
                    local lr, gr = line.Rotation % 360, goal.Rotation % 360
                    local ss, se = (gr + 101) % 360, (gr + 115) % 360
                    if (ss > se and (lr >= ss or lr <= se)) or (lr >= ss and lr <= se) then
                        TriggerMobileButton()
                        if HeartbeatConnection then HeartbeatConnection:Disconnect() HeartbeatConnection = nil end
                    end
                end)
            elseif HeartbeatConnection then HeartbeatConnection:Disconnect() HeartbeatConnection = nil end
        end)
    end)
end

-- ============ ScreenGui Godfather ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodfatherUI_GoldEdition"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

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

-- Key Frame
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

-- Main Frame
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Active = true
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0.5, -150, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local frameStroke = Instance.new("UIStroke", frame)
frameStroke.Color = Color3.fromRGB(45, 45, 60)
frameStroke.Thickness = 1.5

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
title.Text = "GODFATHER HUB x GOLD"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
title.Parent = dragHandle

-- Scrolling Frame
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

-- Controls UI
local flyBtn, flyInd = createToggleButton("FlyBtn", "Fly Control", 1)
local noclipBtn, noclipInd = createToggleButton("NoclipBtn", "Noclip Passthrough", 2)
local jumpBtn, jumpInd = createToggleButton("JumpBtn", "Infinite Jump", 3)
local espBtn, espInd = createToggleButton("EspBtn", "ESP Visuals", 4)
local autoGenBtn, autoGenInd = createToggleButton("AutoGenBtn", "Auto Generator (VD)", 5)
local skillCheckBtn, skillCheckInd = createToggleButton("SkillCheckBtn", "Auto Skill Check", 6)
local fullbrightBtn, fullbrightInd = createToggleButton("FullbrightBtn", "Fullbright Map", 7)

-- WalkSpeed Container
local wsContainer = Instance.new("Frame")
wsContainer.Size = UDim2.new(1, -6, 0, 36)
wsContainer.LayoutOrder = 8
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

-- Teleports & Actions
local tpGateBtn = Instance.new("TextButton")
tpGateBtn.Name = "TpGateBtn"
tpGateBtn.Size = UDim2.new(1, -6, 0, 36)
tpGateBtn.LayoutOrder = 9
tpGateBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
tpGateBtn.Text = "TELEPORT TO EXIT GATE"
tpGateBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
tpGateBtn.Font = Enum.Font.GothamBold
tpGateBtn.TextSize = 12
tpGateBtn.Parent = scrollFrame
Instance.new("UICorner", tpGateBtn).CornerRadius = UDim.new(0, 6)

local tpDropdown = Instance.new("TextButton")
tpDropdown.Name = "TpDropdown"
tpDropdown.Size = UDim2.new(1, -6, 0, 36)
tpDropdown.LayoutOrder = 10
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
tpGoBtn.LayoutOrder = 11
tpGoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
tpGoBtn.Text = "TELEPORT TO PLAYER"
tpGoBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
tpGoBtn.Font = Enum.Font.GothamBold
tpGoBtn.TextSize = 12
tpGoBtn.Parent = scrollFrame
Instance.new("UICorner", tpGoBtn).CornerRadius = UDim.new(0, 6)

local spectateBtn = Instance.new("TextButton")
spectateBtn.Name = "SpectateBtn"
spectateBtn.Size = UDim2.new(1, -6, 0, 36)
spectateBtn.LayoutOrder = 12
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

-- ============ Camera & Key Unlock Logic ============
local cameraZoomConnection = nil

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

keySubmitBtn.MouseButton1Click:Connect(function()
	if keyInput.Text == CORRECT_KEY then
		isKeyUnlocked = true
		keyStatusLabel.TextColor3 = Color3.fromRGB(0, 230, 140)
		keyStatusLabel.Text = "Access Granted!"
		enableCameraNoLimit()
		SetupGui()
		RefreshMapESP()
		task.wait(0.4)
		keyFrame:Destroy()
		frame.Visible = true
		toggleBtn.Visible = true
	else
		keyStatusLabel.TextColor3 = Color3.fromRGB(255, 90, 90)
		keyStatusLabel.Text = "Invalid Key!"
	end
end)

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

-- ============ Fly, Noclip, Infinite Jump Logic ============
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
		local camera = Workspace.CurrentCamera  
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

-- ============ Auto Generator & Skill Check ============
autoGenBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	autoGenEnabled = not autoGenEnabled
	if autoGenEnabled then
		autoGenThread = task.spawn(function()
			while autoGenEnabled do
				task.wait(0.2)
				pcall(function()
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
									repairEvent:FireServer(point, true)
									skillCheckEvent:FireServer("success", 1, obj, point)
								end
							end
						end
					end
				end)
			end
		end)
	end
	updateToggleVisual(autoGenBtn, autoGenInd, autoGenEnabled, "Auto Generator (VD)")
end)

skillCheckBtn.MouseButton1Click:Connect(function()
    if not isKeyUnlocked then return end
    autoSkillCheckEnabled = not autoSkillCheckEnabled
    if autoSkillCheckEnabled then InitializeAutobuy() end
    updateToggleVisual(skillCheckBtn, skillCheckInd, autoSkillCheckEnabled, "Auto Skill Check")
end)

fullbrightBtn.MouseButton1Click:Connect(function()
    if not isKeyUnlocked then return end
    fullbrightEnabled = not fullbrightEnabled
    updateToggleVisual(fullbrightBtn, fullbrightInd, fullbrightEnabled, "Fullbright Map")
end)

-- ============ Godfather ESP Visuals ============
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
	local camera = Workspace.CurrentCamera
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

espBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	espEnabled = not espEnabled
	if espEnabled then
		if espConnection then espConnection:Disconnect() end
		espConnection = RunService.RenderStepped:Connect(updateESP)
	else
		if espConnection then espConnection:Disconnect() espConnection = nil end
		clearESP()
	end
	updateToggleVisual(espBtn, espInd, espEnabled, "ESP Visuals")
end)

-- Walkspeed, Teleport, Spectate
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

tpGateBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	local map = Workspace:FindFirstChild("Map")
	if not map then return end
	for _, obj in ipairs(map:GetDescendants()) do
		if obj:IsA("Model") and obj.Name == "Gate" then
			local gatePart = obj:FindFirstChildWhichIsA("BasePart")
			if gatePart and humanoidRootPart then
				humanoidRootPart.CFrame = gatePart.CFrame + Vector3.new(0, 3, 0)
				tpGateBtn.Text = "TELEPORTED TO GATE!"
				task.wait(1)
				tpGateBtn.Text = "TELEPORT TO EXIT GATE"
				return
			end
		end
	end
	tpGateBtn.Text = "NO GATE FOUND"
	task.wait(1)
	tpGateBtn.Text = "TELEPORT TO EXIT GATE"
end)

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
	tpDropdown.Text = "  Target: " .. target.DisplayName .. " ▾"
end)

tpGoBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked or #targetPlayers == 0 then return end
	local targetPlayer = targetPlayers[currentTargetIndex]
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		humanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
		tpGoBtn.Text = "TELEPORTED!"
	else
		tpGoBtn.Text = "TARGET INVALID"
	end
	task.wait(1)
	tpGoBtn.Text = "TELEPORT TO PLAYER"
end)

local spectating = false
spectateBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked or #targetPlayers == 0 then return end
	local targetPlayer = targetPlayers[currentTargetIndex]
	local camera = Workspace.CurrentCamera

	if spectating then
		spectating = false
		if humanoid then camera.CameraSubject = humanoid end
		spectateBtn.Text = "  SPECTATE SELECTED PLAYER"
		spectateIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
	else
		if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid") then
			spectating = true
			camera.CameraSubject = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
			spectateBtn.Text = "  SPECTATING: " .. targetPlayer.DisplayName
			spectateIndicator.BackgroundColor3 = Color3.fromRGB(0, 230, 140)
		end
	end
end)

-- Draggable Logic
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
			target.Position = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)
		end
	end)
end

makeDraggable(dragHandle, frame)
makeDraggable(toggleBtn, toggleBtn)
makeDraggable(keyDragHandle, keyFrame)

toggleBtn.MouseButton1Click:Connect(function()
	if not isKeyUnlocked then return end
	frame.Visible = not frame.Visible
end)

-- ============ Heartbeat Event Integration ============
RunService.Heartbeat:Connect(function()
    if not isKeyUnlocked then return end
    
    local now = tick()
    if now - LastUpdateTick < 0.05 then return end
    LastUpdateTick = now
    
    if fullbrightEnabled then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end
    
    if now - LastFullESPRefresh > 5 then 
        LastFullESPRefresh = now 
        RefreshMapESP() 
    end
    
    updateNextKillerDisplay()
    
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local killerNearby = false
    
    for _, p in ipairs(Players:GetPlayers()) do 
        if p ~= player then 
            updatePlayerNametag(p) 
            local pTeam = p.Team and p.Team.Name:lower() or ""
            if pTeam:find("killer") and myRoot and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude < 99 then
                    killerNearby = true
                end
            end
        end 
    end
    
    if myRoot then
        local warn = myRoot:FindFirstChild("KillerWarn")
        if killerNearby then
            if not warn then
                warn = CreateBillboardTag("!", Color3.fromRGB(255, 0, 0), UDim2.new(0, 50, 0, 50), 40)
                warn.Name, warn.StudsOffset, warn.Adornee, warn.Parent = "KillerWarn", Vector3.new(0, 4, 0), myRoot, myRoot
            end
        elseif warn then warn:Destroy() end
    end
    
    for i = #ActiveGenerators, 1, -1 do
        local g = ActiveGenerators[i]
        if g and g.Parent then 
            if updateGeneratorProgress(g) then table.remove(ActiveGenerators, i) end 
        else 
            table.remove(ActiveGenerators, i) 
        end
    end
end)

-- Connections & Cleanup
Workspace.ChildAdded:Connect(function(c) if c.Name == "Map" then task.wait(1) RefreshMapESP() end end)

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    
    if HeartbeatConnection then HeartbeatConnection:Disconnect() end 
    if VisibilityConnection then VisibilityConnection:Disconnect() end 
    
    if isKeyUnlocked then 
        enableCameraNoLimit() 
        SetupGui()
        task.wait(1)
        InitializeAutobuy()
    end
    if flyEnabled and isKeyUnlocked then stopFly() startFly() end
end)

Players.PlayerRemoving:Connect(function(p)
    if not IndicatorGui then return end
    local l = {p.Name .. "_Chased", p.Name .. "_Killer", p.Name}
    for _, n in ipairs(l) do local obj = IndicatorGui:FindFirstChild(n) if obj then obj:Destroy() end end
end)
