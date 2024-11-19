local current_camera = game:GetService("Workspace").CurrentCamera
local local_player = game:GetService("Players").LocalPlayer

local ESP = {
    Enabled = false,
    BoxType = "Static", -- dynamic, static
    
    BoxEnabled = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxTransparency = 0,
    
    HealthBarEnabled = false,
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    HealthBarTransparency = 0,
    HealthBarBoostEnabled = false,
    HealthBarBoostColor = Color3.fromRGB(0, 175, 0),
    
    HealthTextEnabled = false,
    HealthTextColor = Color3.fromRGB(0, 0, 0),
    
    SkeletonEnabled = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    SkeletonTransparency = 0,
    
    NameEnabled = false,
    NameColor = Color3.fromRGB(255, 255, 255),
    NameTransparency = 0,
    DisplayNames = false,
    
    DistanceEnabled = false,
    DistanceColor = Color3.fromRGB(255, 255, 255),
    DistanceTransparency = 0,
    
    OOFArrowsEnabled = false,
    OOFArrowsColor = Color3.fromRGB(255, 255, 255),
    OOFArrowsTransparency = 0,
    OOFArrowsRadius = 100,
    
    --[[ViewTracerEnabled = true,
    ViewTracerColor = Color3.fromRGB(79, 220, 255),
    ViewTracerTransparency = 0,
    ViewTracerLength = 10,--]]
    
    ActiveItemEnabled = false,
    ActiveItemColor = Color3.fromRGB(255, 255, 255),
    ActiveItemTransparency = 0,

    MaxDistance = 2000,
    MeasurementType = "Roblox"
}

local skeleton_order = {
    ["LeftFoot"] = "LeftLowerLeg",
    ["LeftLowerLeg"] = "LeftUpperLeg",
    ["LeftUpperLeg"] = "LowerTorso",
    ["RightFoot"] = "RightLowerLeg",
    ["RightLowerLeg"] = "RightUpperLeg",
    ["RightUpperLeg"] = "LowerTorso",
    ["LeftHand"] = "LeftLowerArm",
    ["LeftLowerArm"] = "LeftUpperArm",
    ["LeftUpperArm"] = "UpperTorso",
    ["RightHand"] = "RightLowerArm",
    ["RightLowerArm"] = "RightUpperArm",
    ["RightUpperArm"] = "UpperTorso",
    ["LowerTorso"] = "UpperTorso",
    ["UpperTorso"] = "Head"
}

local function calculate_box(player)
    if ESP.BoxType == "Dynamic" then
        local position = player.Character:GetBoundingBox()
        local size = player.Character:GetExtentsSize()
        
        local maxs = (position * CFrame.new(size / 2)).Position
        local mins = (position * CFrame.new(size / -2)).Position
        
        local points = {
            Vector3.new(mins.X, mins.Y, mins.Z),
            Vector3.new(mins.X, maxs.Y, mins.Z),
            Vector3.new(maxs.X, maxs.Y, mins.Z),
            Vector3.new(maxs.X, mins.Y, mins.Z),
            Vector3.new(maxs.X, maxs.Y, maxs.Z),
            Vector3.new(mins.X, maxs.Y, maxs.Z),
            Vector3.new(mins.X, mins.Y, maxs.Z),
            Vector3.new(maxs.X, mins.Y, maxs.Z)
        }
        
        local visible = true
        for idx, point in next, points do
            points[idx], visible = current_camera:WorldToViewportPoint(point)
        end
        
        if not visible then return end
        
        local left = math.huge
        local right = 0
        local top = math.huge
        local bottom = 0
        
        for _, point in next, points do
            if point.X < left then left = point.X end
            if point.X > right then right = point.X end
            if point.Y < top then top = point.Y end
            if point.Y > bottom then bottom = point.Y end
        end
        
        return {
            X = math.floor(left),
            Y = math.floor(top),
            W = math.floor(right - left),
            H = math.floor(bottom - top)
        }
    else
        local camera_cframe = current_camera.CFrame
        local torso_cframe = player.Character.HumanoidRootPart.CFrame
        
        local matrix_top = (torso_cframe.Position + Vector3.new(0, 0.3, 0)) + (torso_cframe.UpVector * 1.5) + camera_cframe.UpVector
        local matrix_bottom = (torso_cframe.Position + Vector3.new(0, 0.4, 0)) - (torso_cframe.UpVector * 3)
        
        local top, top_visible = current_camera:WorldToViewportPoint(matrix_top)
        local bottom, bottom_visible = current_camera:WorldToViewportPoint(matrix_bottom)
        
        if not top_visible and not bottom_visible then return end
        
        local width = math.floor(math.abs(top.X - bottom.X))
        local height = math.floor(math.max(math.abs(bottom.Y - top.Y), width * 0.6))
        local box_size = Vector2.new(math.floor(math.max(height / 1.7, width * 1.8)), height)
        local box_position = Vector2.new(math.floor(top.X * 0.5 + bottom.X * 0.5 - box_size.X * 0.5), math.floor(math.min(top.Y, bottom.Y)))
        
        return {
            X = box_position.X,
            Y = box_position.Y,
            W = box_size.X,
            H = box_size.Y
        }
    end
end

local function draw(class, properties)
    local object = Drawing.new(class)
    
    for property, value in pairs(properties) do
        object[property] = value
    end
    
    return object
end

local esp_objects = {}

game:GetService("RunService").RenderStepped:Connect(function()
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player == local_player then continue end
        
        if not player.Character or not player.Character:FindFirstChild("Humanoid") or not player.Character:FindFirstChild("HumanoidRootPart") then
            if esp_objects[player.Name] then
                for _, object in pairs(esp_objects[player.Name]) do
                    object.Visible = false
                end
            end
            continue
        end
        
        local distance = (player.Character.HumanoidRootPart.Position - local_player.Character.HumanoidRootPart.Position).Magnitude
        if distance > ESP.MaxDistance then
            if esp_objects[player.Name] then
                for _, object in pairs(esp_objects[player.Name]) do
                    object.Visible = false
                end
            end
            continue
        end
        
        local box = calculate_box(player)
        
        if not esp_objects[player.Name] then
            esp_objects[player.Name] = {
                box_outside = draw("Square", {
                    Color = Color3.new(0, 0, 0),
                    Thickness = 1,
                    Transparency = 0.5,
                    Filled = false
                }),
                box = draw("Square", {
                    Thickness = 1,
                    Filled = false
                }),
                box_inside = draw("Square", {
                    Color = Color3.new(0, 0, 0),
                    Thickness = 1,
                    Transparency = 0.5,
                    Filled = false
                }),
                name = draw("Text", {
                    Center = true,
                    Outline = true,
                    Size = 13,
                    Font = 2
                }),
                health_bar_outside = draw("Square", {
                    Color = Color3.new(0, 0, 0),
                    Thickness = 1,
                    Transparency = 0.5,
                    Filled = true
                }),
                health_bar = draw("Square", {
                    Thickness = 1,
                    Filled = true
                }),
                health_bar_boost = draw("Square", {
                    Thickness = 1,
                    Filled = true
                }),
                health_text = draw("Text", {
                    Center = true,
                    Outline = true,
                    Size = 13,
                    Font = 2
                }),
                distance = draw("Text", {
                    Center = true,
                    Outline = true,
                    Size = 13,
                    Font = 2
                }),
                view_tracer = draw("Line", {
                    Thickness = 1,
                    Transparency = 1
                }),
                oof_arrow = draw("Triangle", {
                    Thickness = 1,
                    Filled = true
                }),
                oof_arrow_outline = draw("Triangle", {
                    Color = Color3.new(0, 0, 0),
                    Thickness = 1,
                    Filled = false
                }),
                active_item = draw("Text", {
                    Center = true,
                    Outline = true,
                    Size = 13,
                    Font = 2
                })
            }
            
            for required, _ in next, skeleton_order do
                esp_objects[player.Name]["skeleton_".. required] = draw("Line", {
                    Color = ESP.SkeletonColor,
                    Transparency = 1 - ESP.SkeletonTransparency,
                    Visible = false
                })
            end
        end
        
        local objects = esp_objects[player.Name]
        
        if box then
            if ESP.BoxEnabled then
                objects.box_outside.Position = Vector2.new(box.X - 1, box.Y - 1)
                objects.box_outside.Size = Vector2.new(box.W + 2, box.H + 2)
                objects.box_outside.Transparency = 0.5
                objects.box_outside.Visible = true
                
                objects.box.Position = Vector2.new(box.X, box.Y)
                objects.box.Size = Vector2.new(box.W, box.H)
                objects.box.Color = ESP.BoxColor
                objects.box.Transparency = 1 - ESP.BoxTransparency
                objects.box.Visible = true
                
                objects.box_inside.Position = Vector2.new(box.X + 1, box.Y + 1)
                objects.box_inside.Size = Vector2.new(box.W - 2, box.H - 2)
                objects.box_inside.Transparency = 0.5
                objects.box_inside.Visible = true
            else
                objects.box_outside.Visible = false
                objects.box.Visible = false
                objects.box_inside.Visible = false
            end
            
            if ESP.HealthBarEnabled then
                local health = game.PlaceId == 863266079 and math.floor(player.Stats.Health.Value) or player.Character.Humanoid.Health
                local max_health = game.PlaceId == 863266079 and 100 or player.Character.Humanoid.MaxHealth
                local health_percent = health / max_health
                
                objects.health_bar_outside.Position = Vector2.new(box.X - 6, box.Y - 1)
                objects.health_bar_outside.Size = Vector2.new(4, box.H + 2)
                objects.health_bar_outside.Transparency = 0.5
                objects.health_bar_outside.Visible = true
                
                objects.health_bar.Position = Vector2.new(box.X - 5, box.Y)
                objects.health_bar.Size = Vector2.new(2, box.H)
                objects.health_bar.Color = ESP.HealthBarColor:Lerp(Color3.fromRGB(255, 0, 0), 1 - health_percent)
                objects.health_bar.Transparency = 1 - ESP.HealthBarTransparency
                objects.health_bar.Visible = true
                
                if ESP.HealthBarBoostEnabled then
                    local boost = math.clamp(health - max_health, 0, 100)
                    local boost_percent = boost / max_health
                    
                    objects.health_bar_boost.Position = Vector2.new(box.X - 5, box.Y)
                    objects.health_bar_boost.Size = Vector2.new(2, box.H * boost_percent)
                    objects.health_bar_boost.Color = ESP.HealthBarBoostColor
                    objects.health_bar_boost.Visible = boost > 0
                end
                
                if ESP.HealthTextEnabled then
                    objects.health_text.Position = Vector2.new(box.X - 7 - objects.health_text.TextBounds.X, box.Y + (box.H * (1 - health_percent)))
                    objects.health_text.Color = Color3.new(1, 1, 1)
                    objects.health_text.OutlineColor = Color3.new(0, 0, 0)
                    objects.health_text.Text = tostring(math.floor(health))
                    objects.health_text.Visible = health <= 90
                end                
            end            
            
            if ESP.NameEnabled then
                objects.name.Position = Vector2.new(box.X + (box.W / 2), box.Y - 5 - objects.name.TextBounds.Y)
                objects.name.Color = ESP.NameColor
                objects.name.Transparency = 1 - ESP.NameTransparency
                objects.name.Text = ESP.DisplayNames and player.DisplayName or player.Name
                objects.name.Visible = true
            else
                objects.name.Visible = false
            end
            
            if ESP.DistanceEnabled then
                local measurement = {
                    Roblox = {div = 1, suffix = "s"},
                    Imperial = {div = 3.265, suffix = "y"},
                    Metric = {div = 3.333, suffix = "m"}
                }
                
                local current = measurement[ESP.MeasurementType]
                local display_distance = math.floor(distance / current.div)
                
                objects.distance.Position = Vector2.new(box.X + (box.W / 2), box.Y + box.H + 5)
                objects.distance.Color = ESP.DistanceColor
                objects.distance.Transparency = 1 - ESP.DistanceTransparency
                objects.distance.Text = string.format("[%d%s]", display_distance, current.suffix)
                objects.distance.Visible = true
            else
                objects.distance.Visible = false
            end
            
            if ESP.SkeletonEnabled then
                for _, part in next, player.Character:GetChildren() do
                    local parent_part = skeleton_order[part.Name]
                    if not parent_part then continue end
                    
                    local parent = player.Character:FindFirstChild(parent_part)
                    if not parent then continue end
                    
                    local part_position, on_screen_start = current_camera:WorldToViewportPoint(part.Position)
                    local parent_part_position, on_screen_end = current_camera:WorldToViewportPoint(parent.Position)
                    
                    local skeleton = objects["skeleton_".. part.Name]

                    if on_screen_start and on_screen_end then
                        skeleton.Visible = true
                    else 
                        skeleton.Visible = false
                    end

                    skeleton.From = Vector2.new(part_position.X, part_position.Y)
                    skeleton.To = Vector2.new(parent_part_position.X, parent_part_position.Y)
                    skeleton.Color = ESP.SkeletonColor
                    skeleton.Transparency = 1 - ESP.SkeletonTransparency
                    skeleton.Visible = true
                end
            else
                for required, _ in next, skeleton_order do
                    objects["skeleton_".. required].Visible = false
                end
            end
            
            if ESP.ActiveItemEnabled then
                if player:FindFirstChild("Stats") then
                    local primary = player.Stats:FindFirstChild("Primary") and player.Stats.Primary.Value or ""
                    local secondary = player.Stats:FindFirstChild("Secondary") and player.Stats.Secondary.Value or ""
                    local distance_text = string.format("[%d%s]", display_distance, current.suffix)
                    
                    objects.active_item.Position = Vector2.new(box.X + (box.W / 2), box.Y + box.H + 5)
                    objects.active_item.Color = ESP.ActiveItemColor
                    objects.active_item.Transparency = 1 - ESP.ActiveItemTransparency
                    objects.active_item.Text = string.format("[%s]\n[%s]", primary, secondary)
                    objects.active_item.Visible = true
                    
                    if ESP.DistanceEnabled then
                        objects.distance.Position = Vector2.new(box.X + (box.W / 2), box.Y + box.H + 35)
                        objects.distance.Text = distance_text
                    end
                end
            else
                objects.active_item.Visible = false
                if ESP.DistanceEnabled then
                    objects.distance.Position = Vector2.new(box.X + (box.W / 2), box.Y + box.H + 5)
                end
            end                 

            --[[if ESP.ViewTracerEnabled then
                local camera_direction = player.Character.Head.CFrame.lookVector * ESP.ViewTracerLength
                local parameters = RaycastParams.new()
                parameters.FilterDescendantsInstances = {current_camera, local_player.Character}
                parameters.FilterType = Enum.RaycastFilterType.Blacklist
                
                local result = workspace:Raycast(player.Character.Head.Position, camera_direction, parameters)
                
                if result then
                    local head_position, visible = current_camera:WorldToViewportPoint(player.Character.Head.Position)
                    local hit_position, visible_hit = current_camera:WorldToViewportPoint(result.Position)
                    
                    if visible and visible_hit then
                        objects.view_tracer.From = Vector2.new(head_position.X, head_position.Y)
                        objects.view_tracer.To = Vector2.new(hit_position.X, hit_position.Y)
                        objects.view_tracer.Color = ESP.ViewTracerColor
                        objects.view_tracer.Transparency = 1 - ESP.ViewTracerTransparency
                        objects.view_tracer.Visible = true
                    else
                        objects.view_tracer.Visible = false
                    end
                else
                    objects.view_tracer.Visible = false
                end
            else
                objects.view_tracer.Visible = false
            end--]]
            
            objects.oof_arrow.Visible = false
            objects.oof_arrow_outline.Visible = false
        else
            if ESP.OOFArrowsEnabled then
                local fix_ratio = 450 / ESP.OOFArrowsRadius
                local relative = current_camera.CFrame:PointToObjectSpace(player.Character.HumanoidRootPart.Position)
                local middle = current_camera.ViewportSize / 2
                local degree = math.deg(math.atan2(-relative.Y, relative.X)) * math.pi / 180
                
                local end_pos = middle + (Vector2.new(math.cos(degree), math.sin(degree))) * ESP.OOFArrowsRadius
                local end_pos_a = middle + (Vector2.new(math.cos(degree + math.rad(2 * fix_ratio)), math.sin(degree + math.rad(2 * fix_ratio)))) * ESP.OOFArrowsRadius
                local end_pos_c = middle + (Vector2.new(math.cos(degree - math.rad(2 * fix_ratio)), math.sin(degree - math.rad(2 * fix_ratio)))) * ESP.OOFArrowsRadius
                
                local difference = middle - end_pos
                
                objects.oof_arrow.PointA = end_pos_a
                objects.oof_arrow.PointB = end_pos + (-difference.Unit * 15)
                objects.oof_arrow.PointC = end_pos_c
                objects.oof_arrow.Color = ESP.OOFArrowsColor
                objects.oof_arrow.Transparency = 1 - ESP.OOFArrowsTransparency
                objects.oof_arrow.Visible = true
                
                objects.oof_arrow_outline.PointA = end_pos_a
                objects.oof_arrow_outline.PointB = end_pos + (-difference.Unit * 15)
                objects.oof_arrow_outline.PointC = end_pos_c
                objects.oof_arrow_outline.Transparency = 1 - ESP.OOFArrowsTransparency
                objects.oof_arrow_outline.Visible = true
            else
                objects.oof_arrow.Visible = false
                objects.oof_arrow_outline.Visible = false
            end
            
            for _, object in pairs(objects) do
                if object ~= objects.oof_arrow and object ~= objects.oof_arrow_outline then
                    object.Visible = false
                end
            end
        end
    end
    
    for player_name, objects in pairs(esp_objects) do
        if not game:GetService("Players"):FindFirstChild(player_name) then
            for _, object in pairs(objects) do
                object:Remove()
            end
            esp_objects[player_name] = nil
        end
    end    
end)

return ESP
