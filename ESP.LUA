local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = game:GetService("CoreGui")
local Lighting = cloneref(game:GetService("Lighting"))
local UserInputService = game:GetService("UserInputService")
local gameId = game.PlaceId
local SEGMENTS = 16
local HAT_OFFSET = Vector3.new(0, 0.2, 0)
local HAT_HEIGHT = 1.8
local HAT_RADIUS = 1.3

_Periphean = _Periphean or {}
_Periphean.ESPConfig = _Periphean.ESPConfig or {
    Enabled = true,
    MaxDistance = 2000,
    FontSize = 11,
    MinFontSize = 8,
    Drawing = {
        Names = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Distances = {
            Enabled = true,
            Position = "Text",
            RGB = Color3.fromRGB(255, 255, 255),
        },
        Healthbar = {
            Enabled = true,
            HealthText = true,
            Width = 2.7,
        },
        Boxes = {
            Filled = {
                Enabled = true,
                Transparency = 0.75,
                RGB = Color3.fromRGB(0, 0, 0),
            },
            Full = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
            Corner = {
                Enabled = true,
                RGB = Color3.fromRGB(255, 255, 255),
            },
        },
        Tracers = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 255, 255),
            Thickness = 2,
        },
        InventoryViewer = { -- ar2 only
            Enabled = false,
            KeyPicker = Enum.KeyCode.E,
        },
        Skeleton = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 255, 255),
            Thickness = 2,
        },
        ChinaHat = {
            Enabled = true,
            RGB = Color3.fromRGB(255, 0, 0),
        },
        AimView = {
            Enabled = false,
            RGB = Color3.fromRGB(0, 255, 0),
            Thickness = 2,
            Length = 6,
        },
        Chams = {
            Enabled = false,
            Rainbow = true,
            Pulse = true,
            RGB = Color3.fromRGB(255, 0, 0),
        },
    },
    Connections = {
        RunService = RunService;
    },
}

local ESP = _Periphean.ESPConfig
local lplayer = Players.LocalPlayer
local Cam = Workspace.CurrentCamera

local Functions = {}
do
    function Functions:Create(Class, Properties)
        local _Instance = typeof(Class) == 'string' and Instance.new(Class) or Class
        for Property, Value in pairs(Properties) do
            _Instance[Property] = Value
        end
        return _Instance
    end

    function Functions:Lerp(a, b, t)
        return a + (b - a) * t
    end
end

do
    local ScreenGui = Functions:Create("ScreenGui", {
        Parent = CoreGui,
        Name = "ESPHolder",
    })

    local function CreateESPElement(Class, Properties)
        return Functions:Create(Class, Properties)
    end

    local ESP = function(plr)
        local Name = CreateESPElement("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(0.5, 0, 0, -11),
            Size = UDim2.new(0, 100, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Code,
            TextSize = ESP.FontSize,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            RichText = true
        })
        local Distance = CreateESPElement("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(0.5, 0, 0, 11),
            Size = UDim2.new(0, 100, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Code,
            TextSize = ESP.FontSize,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            RichText = true
        })
        local Box = CreateESPElement("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.75,
            BorderSizePixel = 0
        })
        local Healthbar = CreateESPElement("Frame", {
            Parent = ScreenGui,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0
        })
        local BehindHealthbar = CreateESPElement("Frame", {
            Parent = ScreenGui,
            ZIndex = -1,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0
        })
        local HealthText = CreateESPElement("TextLabel", {
            Parent = ScreenGui,
            Size = UDim2.new(0, 50, 0, 20),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Code,
            TextSize = ESP.FontSize,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        })
        
        local Tracer = Drawing.new("Line")
        Tracer.Color = ESP.Drawing.Tracers.RGB
        Tracer.Thickness = ESP.Drawing.Tracers.Thickness
        Tracer.Transparency = 1

        local ChinaHat = {}
        for i = 1, SEGMENTS do
            local line = Drawing.new("Line")
            line.Thickness = 1
            line.Color = ESP.Drawing.ChinaHat.RGB
            line.Transparency = 0.9
            table.insert(ChinaHat, line)
        end
        for i = 1, SEGMENTS do
            local rimLine = Drawing.new("Line")
            rimLine.Thickness = 2
            rimLine.Color = ESP.Drawing.ChinaHat.RGB
            rimLine.Transparency = 0.9
            table.insert(ChinaHat, rimLine)
        end

        local InventoryViewer = CreateESPElement("TextLabel", {
            Parent = ScreenGui,
            Position = UDim2.new(0, 10, 0, 300),
            Size = UDim2.new(0, 300, 0, 200),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Code,
            TextSize = ESP.FontSize,
            TextStrokeTransparency = 0,
            TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
            RichText = true,
            Visible = false
        })

        local Highlight = Instance.new("Highlight")
        Highlight.Parent = CoreGui
        Highlight.Adornee = plr.Character
        Highlight.FillColor = ESP.Drawing.Chams.RGB
        Highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        
        local CornerFrames = {}
        for _, pos in ipairs({"LeftTop", "LeftSide", "RightTop", "RightSide", "BottomSide", "BottomDown", "BottomRightSide", "BottomRightDown"}) do
            CornerFrames[pos] = CreateESPElement("Frame", {
                Parent = ScreenGui,
                BackgroundColor3 = ESP.Drawing.Boxes.Corner.RGB,
                Position = UDim2.new(0, 0, 0, 0)
            })
        end

        local SkeletonLines = {}
        for _, bone in ipairs({"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}) do
            SkeletonLines[bone] = Drawing.new("Line")
            SkeletonLines[bone].Color = ESP.Drawing.Skeleton.RGB
            SkeletonLines[bone].Thickness = ESP.Drawing.Skeleton.Thickness
            SkeletonLines[bone].Transparency = 1
        end

        local AimViewLine = Drawing.new("Line")
        AimViewLine.Color = ESP.Drawing.AimView.RGB
        AimViewLine.Thickness = ESP.Drawing.AimView.Thickness
        AimViewLine.Transparency = 1

        local Connection
        local function HideESP()
            Box.Visible = false
            Name.Visible = false
            Distance.Visible = false
            Healthbar.Visible = false
            BehindHealthbar.Visible = false
            HealthText.Visible = false
            Tracer.Visible = false
            InventoryViewer.Visible = false
            AimViewLine.Visible = false
            for _, frame in pairs(CornerFrames) do
                frame.Visible = false
            end
            for _, line in pairs(SkeletonLines) do
                line.Visible = false
            end
            for _, line in pairs(ChinaHat) do
                line.Visible = false
            end
            if Highlight then
                Highlight.Enabled = false
            end
            if not plr then
                ScreenGui:Destroy()
                Connection:Disconnect()
            end
        end
        
        local previousInventoryText = ""
        
        local maxDistance = ESP.MaxDistance
        local namesEnabled = ESP.Drawing.Names.Enabled
        local namesRGB = ESP.Drawing.Names.RGB
        local distancesEnabled = ESP.Drawing.Distances.Enabled
        local distancesRGB = ESP.Drawing.Distances.RGB
        local healthbarEnabled = ESP.Drawing.Healthbar.Enabled
        local healthbarWidth = ESP.Drawing.Healthbar.Width
        local boxesFullEnabled = ESP.Drawing.Boxes.Full.Enabled
        local boxesFilledRGB = ESP.Drawing.Boxes.Filled.RGB
        local boxesFilledTransparency = ESP.Drawing.Boxes.Filled.Transparency
        local boxesCornerEnabled = ESP.Drawing.Boxes.Corner.Enabled
        local tracersEnabled = ESP.Drawing.Tracers.Enabled
        local tracersRGB = ESP.Drawing.Tracers.RGB
        local tracersThickness = ESP.Drawing.Tracers.Thickness
        local inventoryViewerEnabled = ESP.Drawing.InventoryViewer.Enabled
        local inventoryViewerKeyPicker = ESP.Drawing.InventoryViewer.KeyPicker
        local skeletonEnabled = ESP.Drawing.Skeleton.Enabled
        local skeletonRGB = ESP.Drawing.Skeleton.RGB
        local skeletonThickness = ESP.Drawing.Skeleton.Thickness
        local chinaHatEnabled = ESP.Drawing.ChinaHat.Enabled
        local chinaHatRGB = ESP.Drawing.ChinaHat.RGB
        local aimViewEnabled = ESP.Drawing.AimView.Enabled
        local aimViewRGB = ESP.Drawing.AimView.RGB
        local aimViewThickness = ESP.Drawing.AimView.Thickness
        local aimViewLength = ESP.Drawing.AimView.Length
        local chamsEnabled = ESP.Drawing.Chams.Enabled
        local chamsRainbow = ESP.Drawing.Chams.Rainbow
        local chamsPulse = ESP.Drawing.Chams.Pulse
        local chamsRGB = ESP.Drawing.Chams.RGB 

        Connection = ESP.Connections.RunService.RenderStepped:Connect(function()
            local character = plr.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local HRP = character.HumanoidRootPart
                local Humanoid = character:WaitForChild("Humanoid")
                local Pos, OnScreen = Cam:WorldToScreenPoint(HRP.Position)
                local Dist = (Cam.CFrame.Position - HRP.Position).Magnitude / 3.5714285714
                
                if not OnScreen or Dist > maxDistance then
                    HideESP()
                    return
                end
        
                local Size = HRP.Size.Y
                local scaleFactor = (Size * Cam.ViewportSize.Y) / (Pos.Z * 2)
                local w, h = 3 * scaleFactor, 4.5 * scaleFactor
        
                local targetTextSize = math.max(ESP.MinFontSize, ESP.FontSize * (1 - (Dist / maxDistance)))
                local smoothTextSize = Functions:Lerp(Name.TextSize, targetTextSize, 0.1)
        
                Box.Position = UDim2.new(0, Pos.X - w / 2, 0, Pos.Y - h / 2)
                Box.Size = UDim2.new(0, w, 0, h)
                Box.Visible = boxesFullEnabled
                Box.BackgroundColor3 = boxesFilledRGB
                Box.BackgroundTransparency = boxesFilledTransparency
        
                local CornerPositions = {
                    LeftTop = {Pos.X - w / 2, Pos.Y - h / 2, w / 5, 1},
                    LeftSide = {Pos.X - w / 2, Pos.Y - h / 2, 1, h / 5},
                    BottomSide = {Pos.X - w / 2, Pos.Y + h / 2, 1, h / 5, Vector2.new(0, 5)},
                    BottomDown = {Pos.X - w / 2, Pos.Y + h / 2, w / 5, 1, Vector2.new(0, 1)},
                    RightTop = {Pos.X + w / 2, Pos.Y - h / 2, w / 5, 1, Vector2.new(1, 0)},
                    RightSide = {Pos.X + w / 2 - 1, Pos.Y - h / 2, 1, h / 5, Vector2.new(0, 0)},
                    BottomRightSide = {Pos.X + w / 2, Pos.Y + h / 2, 1, h / 5, Vector2.new(1, 1)},
                    BottomRightDown = {Pos.X + w / 2, Pos.Y + h / 2, w / 5, 1, Vector2.new(1, 1)}
                }
        
                for pos, data in pairs(CornerPositions) do
                    local frame = CornerFrames[pos]
                    frame.Visible = boxesCornerEnabled
                    frame.Position = UDim2.new(0, data[1], 0, data[2])
                    frame.Size = UDim2.new(0, data[3], 0, data[4])
                    if data[5] then
                        frame.AnchorPoint = data[5]
                    end
                end
        
                local health, maxHealth
                if gameId == 863266079 then
                    local stats = plr:FindFirstChild("Stats")
                    if stats then
                        local healthValue = stats:FindFirstChild("Health")
                        if healthValue then
                            health = healthValue.Value
                            maxHealth = 100
                        end
                    end
                else
                    health = Humanoid.Health
                    maxHealth = Humanoid.MaxHealth
                end
        
                health = health or 0
                maxHealth = maxHealth or 100
        
                Healthbar.Visible = healthbarEnabled
                Healthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2 + h * (1 - health / maxHealth))  
                Healthbar.Size = UDim2.new(0, healthbarWidth, 0, h * (health / maxHealth))
                Healthbar.BackgroundColor3 = Color3.fromHSV((health / maxHealth) * 0.33, 1, 1)
                BehindHealthbar.Visible = healthbarEnabled
                BehindHealthbar.Position = UDim2.new(0, Pos.X - w / 2 - 6, 0, Pos.Y - h / 2)  
                BehindHealthbar.Size = UDim2.new(0, healthbarWidth, 0, h)
        
                if ESP.Drawing.Healthbar.HealthText then
                    local healthPercentage = math.floor((health / maxHealth) * 100)
                    HealthText.Position = UDim2.new(0, Pos.X - w / 2 - 10, 0, Pos.Y - h / 2 + h / 2)
                    HealthText.Text = tostring(healthPercentage) .. "%"
                    HealthText.Visible = true
                    HealthText.TextColor3 = Color3.fromHSV((health / maxHealth) * 0.33, 1, 1)
                    HealthText.TextSize = smoothTextSize
                end
                
                Name.Visible = namesEnabled
                if Name.Visible then
                    Name.Text = plr.Name
                    Name.Position = UDim2.new(0, Pos.X, 0, Pos.Y - h / 2 - 9)
                    Name.TextSize = smoothTextSize
                end
        
                if distancesEnabled then
                    Distance.Position = UDim2.new(0, Pos.X, 0, Pos.Y + h / 2 + 7)
                    Distance.Text = math.floor(Dist) .. " meters"
                    Distance.Visible = true
                    Distance.TextSize = smoothTextSize
                end   
        
                if tracersEnabled then
                    local head = character:FindFirstChild("Head")
                    if head then
                        local headBottomPos = head.Position - Vector3.new(0, head.Size.Y / 2, 0)
                        local headScreenPos = Cam:WorldToViewportPoint(headBottomPos)
                        local mousePos = UserInputService:GetMouseLocation()
                        Tracer.From = Vector2.new(mousePos.X, mousePos.Y)
                        Tracer.To = Vector2.new(headScreenPos.X, headScreenPos.Y)
                        Tracer.Visible = health > 0
                    end
                end

                if aimViewEnabled then
                    local head = character:FindFirstChild("Head")
                    if head then
                        local headPos = head.Position
                        local headScreenPos = Cam:WorldToViewportPoint(headPos)
                        local lookVector = head.CFrame.LookVector
                        local endPos = headPos + (lookVector * aimViewLength)
                        local endScreenPos = Cam:WorldToViewportPoint(endPos)
        
                        if endScreenPos.Z > 0 then
                            AimViewLine.From = Vector2.new(headScreenPos.X, headScreenPos.Y)
                            AimViewLine.To = Vector2.new(endScreenPos.X, endScreenPos.Y)
                            AimViewLine.Visible = true
                        else
                            AimViewLine.Visible = false
                        end
                    else
                        AimViewLine.Visible = false
                    end
                end  
        
                if ESP.Drawing.Chams.Enabled then
                    Highlight.Adornee = character
                    if ESP.Drawing.Chams.Rainbow then
                        local hue = tick() % 5 / 5
                        Highlight.FillColor = Color3.fromHSV(hue, 1, 1)
                    else
                        Highlight.FillColor = ESP.Drawing.Chams.RGB
                    end
        
                    if ESP.Drawing.Chams.Pulse then
                        local pulse = math.abs(math.sin(tick() * 2))
                        Highlight.FillTransparency = pulse * 0.5
                    else
                        Highlight.FillTransparency = 0.5
                    end
        
                    Highlight.Enabled = true
                else
                    Highlight.Enabled = false
                end        

                if skeletonEnabled then
                    local bones = {
                        Head = character:FindFirstChild("Head"),
                        UpperTorso = character:FindFirstChild("UpperTorso"),
                        LowerTorso = character:FindFirstChild("LowerTorso"),
                        LeftUpperArm = character:FindFirstChild("LeftUpperArm"),
                        RightUpperArm = character:FindFirstChild("RightUpperArm"),
                        LeftLowerArm = character:FindFirstChild("LeftLowerArm"),
                        RightLowerArm = character:FindFirstChild("RightLowerArm"),
                        LeftHand = character:FindFirstChild("LeftHand"),
                        RightHand = character:FindFirstChild("RightHand"),
                        LeftUpperLeg = character:FindFirstChild("LeftUpperLeg"),
                        RightUpperLeg = character:FindFirstChild("RightUpperLeg"),
                        LeftLowerLeg = character:FindFirstChild("LeftLowerLeg"),
                        RightLowerLeg = character:FindFirstChild("RightLowerLeg"),
                        LeftFoot = character:FindFirstChild("LeftFoot"),
                        RightFoot = character:FindFirstChild("RightFoot")
                    }
                
                    local function hexagonHead(head)
                        local points = {}
                        local radius = head.Size.X / 2
                        local centerPos = head.Position
                        local cameraPos = Cam.CFrame.Position
                
                        local cameraLook = (cameraPos - centerPos).Unit
                        local right = Vector3.new(0, 1, 0):Cross(cameraLook).Unit
                        local up = cameraLook:Cross(right).Unit
                
                        local angles = {0, 60, 120, 180, 240, 300}
                        for _, angle in ipairs(angles) do
                            local rad = math.rad(angle)
                            local x = math.cos(rad) * radius
                            local y = math.sin(rad) * radius
                            local point = centerPos + (right * x) + (up * y) + (cameraLook * 0.1)
                            table.insert(points, point)
                        end
                        return points
                    end
                
                    local function hexagon(head, lines)
                        local hexagonPoints = hexagonHead(head)
                        for i = 1, 6 do
                            local point1 = hexagonPoints[i]
                            local point2 = hexagonPoints[i % 6 + 1]
                
                            local screenPos1, onScreen1 = Cam:WorldToViewportPoint(point1)
                            local screenPos2, onScreen2 = Cam:WorldToViewportPoint(point2)
                
                            if onScreen1 and onScreen2 then
                                local lineKey = "Hexagon_" .. i
                                if not SkeletonLines[lineKey] then
                                    SkeletonLines[lineKey] = Drawing.new("Line")
                                    SkeletonLines[lineKey].Color = skeletonRGB
                                    SkeletonLines[lineKey].Thickness = skeletonThickness
                                    SkeletonLines[lineKey].Transparency = 1
                                end
                
                                SkeletonLines[lineKey].From = Vector2.new(screenPos1.X, screenPos1.Y)
                                SkeletonLines[lineKey].To = Vector2.new(screenPos2.X, screenPos2.Y)
                                SkeletonLines[lineKey].Visible = true
                            else
                                if SkeletonLines[lineKey] then
                                    SkeletonLines[lineKey].Visible = false
                                end
                            end
                        end
                    end
                
                    local function drawBone(bone1, bone2)
                        local lineKey = bone1 .. "_" .. bone2
                        if not SkeletonLines[lineKey] then
                            SkeletonLines[lineKey] = Drawing.new("Line")
                            SkeletonLines[lineKey].Color = skeletonRGB
                            SkeletonLines[lineKey].Thickness = skeletonThickness
                            SkeletonLines[lineKey].Transparency = 1
                        end
                        if bones[bone1] and bones[bone2] then
                            local pos1 = Cam:WorldToViewportPoint(bones[bone1].Position)
                            local pos2 = Cam:WorldToViewportPoint(bones[bone2].Position)
                            SkeletonLines[lineKey].From = Vector2.new(pos1.X, pos1.Y)
                            SkeletonLines[lineKey].To = Vector2.new(pos2.X, pos2.Y)
                            SkeletonLines[lineKey].Visible = true
                        else
                            SkeletonLines[lineKey].Visible = false
                        end
                    end
                
                    if bones.Head then
                        hexagon(bones.Head, SkeletonLines)
                    end
                
                    drawBone("Head", "UpperTorso")
                    drawBone("UpperTorso", "LowerTorso")
                    drawBone("UpperTorso", "LeftUpperArm")
                    drawBone("UpperTorso", "RightUpperArm")
                    drawBone("LeftUpperArm", "LeftLowerArm")
                    drawBone("RightUpperArm", "RightLowerArm")
                    drawBone("LeftLowerArm", "LeftHand")
                    drawBone("RightLowerArm", "RightHand")
                    drawBone("LowerTorso", "LeftUpperLeg")
                    drawBone("LowerTorso", "RightUpperLeg")
                    drawBone("LeftUpperLeg", "LeftLowerLeg")
                    drawBone("RightUpperLeg", "RightLowerLeg")
                    drawBone("LeftLowerLeg", "LeftFoot")
                    drawBone("RightLowerLeg", "RightFoot")
                end
        
                if gameId == 863266079 and UserInputService:IsKeyDown(inventoryViewerKeyPicker) then
                    local closestPlayer, closestDist = nil, math.huge
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= lplayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local mousePos = UserInputService:GetMouseLocation()
                            local playerPos = Cam:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                            local dist = (Vector2.new(playerPos.X, playerPos.Y) - mousePos).Magnitude
                            if dist < closestDist then
                                closestPlayer, closestDist = player, dist
                            end
                        end
                    end
                
                    if closestPlayer and closestDist <= maxDistance then
                        local stats = closestPlayer:FindFirstChild("Stats")
                        local primary, secondary = "None", "None"
                        if stats then
                            primary = stats:FindFirstChild("Primary") and stats.Primary.Value or "None"
                            secondary = stats:FindFirstChild("Secondary") and stats.Secondary.Value or "None"
                        end
                
                        local equipment = {}
                        local equipmentFolder = closestPlayer.Character:FindFirstChild("Equipment")
                        if equipmentFolder then
                            for _, item in pairs(equipmentFolder:GetChildren()) do
                                table.insert(equipment, item.Name)
                            end
                        end
                        local equipmentText = table.concat(equipment, "\n")
                
                        local health = stats:FindFirstChild("Health") and stats.Health.Value or 0
                        local hpBoost = health > 100 and "Yes" or "No"
                
                        local characterState = "Idle"
                        if closestPlayer.Character and closestPlayer.Character:FindFirstChild("Humanoid") then
                            local humanoid = closestPlayer.Character.Humanoid
                            if humanoid:GetState() == Enum.HumanoidStateType.Running then
                                characterState = "Running"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Seated then
                                characterState = "Sitting"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                                characterState = "Jumping"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Freefall then
                                characterState = "Falling"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Climbing then
                                characterState = "Climbing"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Swimming then
                                characterState = "Swimming"
                            elseif humanoid:GetState() == Enum.HumanoidStateType.Dead then
                                characterState = "Dead"
                            end
                        end
                
                        local newInventoryText = string.format(
                            "%s's information:\n\nWeapons:\nPrimary: %s\nSecondary: %s\n\nEquipment:\n%s\n\nInfo:\nHP: %d%%\nHP Boost: %s\nCharacter State: %s",
                            closestPlayer.Name, primary, secondary, equipmentText, health, hpBoost, characterState
                        )
        
                        if newInventoryText ~= previousInventoryText then
                            InventoryViewer.Text = newInventoryText
                            previousInventoryText = newInventoryText
                        end
                        InventoryViewer.Visible = true
                    else
                        InventoryViewer.Visible = false
                    end
                else
                    InventoryViewer.Visible = false
                end
                
                if ESP.Drawing.ChinaHat.Enabled then
                    local head = character:FindFirstChild("Head")
                    if head then
                        local headPos = head.Position + HAT_OFFSET
                        local screenPos = Cam:WorldToViewportPoint(headPos)
                        
                        if screenPos.Z > 0 then
                            local topPoint = Cam:WorldToViewportPoint(headPos + Vector3.new(0, HAT_HEIGHT, 0))
                            
                            for i = 1, SEGMENTS do
                                local angle1 = (i - 1) * (2 * math.pi / SEGMENTS)
                                local angle2 = i * (2 * math.pi / SEGMENTS)
                                
                                local basePoint1 = Cam:WorldToViewportPoint(headPos + Vector3.new(
                                    math.cos(angle1) * HAT_RADIUS,
                                    0,
                                    math.sin(angle1) * HAT_RADIUS
                                ))
                                local basePoint2 = Cam:WorldToViewportPoint(headPos + Vector3.new(
                                    math.cos(angle2) * HAT_RADIUS,
                                    0,
                                    math.sin(angle2) * HAT_RADIUS
                                ))
                                
                                ChinaHat[i].From = Vector2.new(basePoint1.X, basePoint1.Y)
                                ChinaHat[i].To = Vector2.new(topPoint.X, topPoint.Y)
                                ChinaHat[i].Visible = true
                                
                                local rimIndex = i + SEGMENTS
                                ChinaHat[rimIndex].From = Vector2.new(basePoint1.X, basePoint1.Y)
                                ChinaHat[rimIndex].To = Vector2.new(basePoint2.X, basePoint2.Y)
                                ChinaHat[rimIndex].Visible = true
                            end
                        else
                            for _, line in pairs(ChinaHat) do
                                line.Visible = false
                            end
                        end
                    end
                end
            else
                HideESP()
            end
        end)
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v.Name ~= lplayer.Name then
            ESP(v)
        end      
    end

    Players.PlayerAdded:Connect(function(v)
        ESP(v)
    end)
end
