local ModernUI
local success, err = pcall(function()
    ModernUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/txidstick/sev-Ui-library/refs/heads/main/Ui.lua"))()
end)

if not success or not ModernUI then
    warn("Failed to load UI library: " .. tostring(err))
    return
end

if ModernUI.Settings then
    -- Responsive sizing for all devices
    local Camera = workspace.CurrentCamera
    local ViewportSize = Camera.ViewportSize
    local maxWidth = math.min(ViewportSize.X - 100, 1000)
    local maxHeight = math.min(ViewportSize.Y - 100, 600)
    ModernUI.Settings.Size = UDim2.new(0, maxWidth, 0, maxHeight)
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

getgenv().SwimMethod = false
getgenv().usingEnhancedWalk = false

-- Notification wrapper for easy use
local function Notify(message, duration)
    if ModernUI and ModernUI.Notify then
        ModernUI.Notify({
            Title = "sev.cc",
            Content = message,
            Duration = duration or 3
        })
    else
        print("[Notification] " .. message)
    end
end

local function findPlayerByPartialName(name)
    name = name:lower()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower():sub(1, #name) == name or (player.DisplayName and player.DisplayName:lower():sub(1, #name) == name) then
            return player
        end
    end
    return nil
end

function teleportTo(input)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChild("Humanoid")

    if not hrp or not humanoid then
        return
    end

    local destinationCFrame

    if typeof(input) == "Vector3" then
        destinationCFrame = CFrame.new(input)
    elseif typeof(input) == "CFrame" then
        destinationCFrame = input
    elseif typeof(input) == "string" then
        local targetPlayer = findPlayerByPartialName(input)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            destinationCFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        else
            return
        end
    else
        return
    end

    humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    hrp.CFrame = destinationCFrame
end

-- Detect if mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Window = ModernUI.CreateWindow({
    Name = "sev.cc",
    Icon = "rbxassetid://7733955511"
    -- Size is auto-determined based on device type (phone/tablet/PC)
    -- Theme uses default Starlight theme from ui.lua
})

-- Main Features Tabs
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "rbxassetid://7733955511"
})

local MoneyTab = Window:CreateTab({
    Name = "Money",
    Icon = "rbxassetid://7734042031"
})

local MiscTab = Window:CreateTab({
    Name = "Miscellaneous",
    Icon = "rbxassetid://7733920644"
})

-- Extra Features Tabs
local CombatTab = Window:CreateTab({
    Name = "Combat",
    Icon = "rbxassetid://7734053495"
})

local SafeTab = Window:CreateTab({
    Name = "Safe",
    Icon = "rbxassetid://7734053495"
})

local TeleportTab = Window:CreateTab({
    Name = "Teleports",
    Icon = "rbxassetid://7743871002"
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "rbxassetid://7734053495"
})


local LocalPlayerModSection = MainTab:CreateSection({
    Name = "Local Player Modifications",
    Side = "Left"
})

LocalPlayerModSection:AddToggle({
    Name = "Infinite Sleep",
    Default = false,
    Callback = function(Value)
        getgenv().InfiniteSleep = Value
    end
})

LocalPlayerModSection:AddToggle({
    Name = "Infinite Hunger",
    Default = false,
    Callback = function(Value)
        getgenv().InfiniteHunger = Value
    end
})

LocalPlayerModSection:AddToggle({
    Name = "Infinite Stamina",
    Default = false,
    Callback = function(Value)
        getgenv().InfiniteStamina = Value
    end
})

LocalPlayerModSection:AddToggle({
    Name = "Instant Revive",
    Default = false,
    Callback = function(Value)
        getgenv().InstantRespawn = Value
        
        if Value then
            task.spawn(function()
                while getgenv().InstantRespawn do
                    task.wait(0.2)
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        local char = player.Character
                        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
                        if hum and hum.Health <= 0 then
                            game:GetService("ReplicatedStorage"):WaitForChild("RespawnRE"):FireServer()
                        end
                    end)
                end
            end)
        end
    end
})

RunService.RenderStepped:Connect(function()
    if LocalPlayer.PlayerGui:FindFirstChild("Run") and LocalPlayer.PlayerGui.Run:FindFirstChild("StaminaBarScript", true) then
        LocalPlayer.PlayerGui.Run:FindFirstChild("StaminaBarScript", true).Disabled = getgenv().InfiniteStamina
    end

    if LocalPlayer.PlayerGui:FindFirstChild("Hunger") and LocalPlayer.PlayerGui.Hunger:FindFirstChild("HungerBarScript", true) then
        LocalPlayer.PlayerGui.Hunger:FindFirstChild("HungerBarScript", true).Disabled = getgenv().InfiniteHunger
    end

    if LocalPlayer.PlayerGui:FindFirstChild("SleepGui") and LocalPlayer.PlayerGui.SleepGui:FindFirstChild("sleepScript", true) then
        LocalPlayer.PlayerGui.SleepGui:FindFirstChild("sleepScript", true).Disabled = getgenv().InfiniteSleep
    end
end)

LocalPlayerModSection:AddToggle({
    Name = "Instant Interact",
    Default = false,
    Callback = function(Value)
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = Value and 0 or 1
            end
        end
    end
})

LocalPlayerModSection:AddToggle({
    Name = "Instant Revive",
    Default = false,
    Callback = function(Value)
        getgenv().InstantRespawn = Value
        
        if Value then
            task.spawn(function()
                while getgenv().InstantRespawn do
                    task.wait(0.2)
                    pcall(function()
                        local player = game.Players.LocalPlayer
                        local char = player.Character
                        local hum = char and char:FindFirstChildWhichIsA("Humanoid")
                        if hum and hum.Health <= 0 then
                            game:GetService("ReplicatedStorage"):WaitForChild("RespawnRE"):FireServer()
                        end
                    end)
                end
            end)
        end
    end
})

LocalPlayerModSection:AddToggle({
    Name = "Auto Pickup Cash",
    Default = false,
    Callback = function(Value)
        getgenv().AutoPickupCash = Value
    end
})

LocalPlayerModSection:AddToggle({
    Name = "Auto Pickup Bags",
    Default = false,
    Callback = function(Value)
        getgenv().AutoPickupBags = Value
    end
})

RunService.RenderStepped:Connect(function()
    if getgenv().AutoPickupBags and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, Value in pairs(Workspace.Storage:GetChildren()) do
            if not Value:IsA("MeshPart") then continue end
            if Value:FindFirstChild("PlayerName") and Value:FindFirstChild("PlayerName").Value == LocalPlayer.Name then continue end

            if (Value.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 5 then
                fireproximityprompt(Value.stealprompt)
            end
        end
    end

    if getgenv().AutoPickupCash and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, Value in pairs(Workspace.Dollas:GetChildren()) do
            if not Value:IsA("Part") then continue end

            if (Value.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 5 then
                fireproximityprompt(Value.ProximityPrompt)
            end
        end
    end
end)

LocalPlayerModSection:AddToggle({
    Name = "Disable Camera Bobbing",
    Default = false,
    Callback = function(Value)
        getgenv().DisableCameraBobbing = Value
        if Value then
            task.spawn(function()
                while getgenv().DisableCameraBobbing do
                    task.wait(1)
                    if LocalPlayer and LocalPlayer.Character then
                        local cameraBobbing = LocalPlayer.Character:FindFirstChild("CameraBobbing")
                        if cameraBobbing then
                            cameraBobbing:Destroy()
                        end
                    end
                end
            end)
        end
    end
})

LocalPlayerModSection:AddToggle({
    Name = "Disable Blood Effects",
    Default = false,
    Callback = function(Value)
        getgenv().DisableBloodEffects = Value
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local bloodGui = playerGui:FindFirstChild("BloodGui")
                if bloodGui then
                    bloodGui.Enabled = not Value
                end
            end
        end)
    end
})

LocalPlayerModSection:AddToggle({
    Name = "No Rent Pay",
    Default = false,
    Callback = function(Value)
        getgenv().NoRentPay = Value
        if Value then
            task.spawn(function()
                while getgenv().NoRentPay do
                    task.wait(1)
                    local rentGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("RentGui")
                    if rentGui then
                        local rentScript = rentGui:FindFirstChild("LocalScript")
                        if rentScript then
                            rentScript.Disabled = true
                            rentScript:Destroy()
                        end
                    end
                end
            end)
        end
    end
})

LocalPlayerModSection:AddToggle({
    Name = "No Jump Cooldown",
    Default = false,
    Callback = function(Value)
        getgenv().noJumpCooldown = Value

        if Value then
            task.spawn(function()
                while getgenv().noJumpCooldown do
                    task.wait(0.2)
                    pcall(function()
                        local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
                        if playerGui then
                            local debounce = playerGui:FindFirstChild("JumpDebounce")
                            if debounce then
                                debounce:Destroy()
                            end
                        end
                    end)
                end
            end)
        end
    end
})

LocalPlayerModSection:AddToggle({
    Name = "No Crawl When Damaged",
    Default = false,
    Callback = function(Value)
        local function handleCharacter(character)
            local crawlScript = character:FindFirstChild("crawlWhenDamaged")
            if crawlScript then
                crawlScript.Disabled = Value
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                    if track.Name == "crawlAnimation" then
                        if Value then
                            track:Stop()
                        end
                    end
                end
            end
        end

        if LocalPlayer.Character then
            handleCharacter(LocalPlayer.Character)
        end

        LocalPlayer.CharacterAdded:Connect(function(char)
            if Value then
                handleCharacter(char)
            end
        end)
    end
})

LocalPlayerModSection:AddToggle({
    Name = "No Death Screen",
    Default = false,
    Callback = function(Value)
        if Value then
            game:GetService("ReplicatedStorage"):WaitForChild("deathScreen").Enabled = false
        else
            game:GetService("ReplicatedStorage"):WaitForChild("deathScreen").Enabled = true
        end
    end
})

local executor = identifyexecutor and identifyexecutor() or "Unknown"
local bannedExecutors = {
    ["Solara"] = true,
    ["JJSploit"] = true,
    ["Xeno"] = true,
    ["Zorara"] = true,
    ["Ronix"] = true
}

local function updateCharacterProperty(property, value)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("CharacterSettings") then
        local settings = require(character.CharacterSettings)
        settings[property] = value
    end
end

if not bannedExecutors[executor] then
    LocalPlayerModSection:AddToggle({
        Name = "No Max Pick Up Range",
        Default = false,
        Callback = function(Value)
            updateCharacterProperty("MaxPickUpRange", Value and 1000 or 6.5)
        end
    })

    LocalPlayerModSection:AddToggle({
        Name = "No KnockBack",
        Default = false,
        Callback = function(Value)
            updateCharacterProperty("KnockAt", Value and 1000 or 27)
        end
    })

    LocalPlayerModSection:AddToggle({
        Name = "No Carry Cooldown",
        Default = false,
        Callback = function(Value)
            updateCharacterProperty("CarryCooldown", Value and 0 or 0.25)
        end
    })
end

LocalPlayerModSection:AddToggle({
    Name = "No Fall Damage",
    Default = false,
    Callback = function(Value)
        getgenv().NoFallDamage = Value
        if Value then
            task.spawn(function()
                while getgenv().NoFallDamage do
                    task.wait(1)
                    if LocalPlayer and LocalPlayer.Character then
                        local fallDamage = LocalPlayer.Character:FindFirstChild("FallDamageRagdoll")
                        if fallDamage then
                            fallDamage.Disabled = true
                        end
                    end
                end
            end)
        end
    end
})



LocalPlayerModSection:AddToggle({
    Name = "No Crawl",
    Default = false,
    Callback = function(Value)
        getgenv().NoCrawl = Value
        if Value then
            task.spawn(function()
                while getgenv().NoCrawl do
                    task.wait(0.5)
                    pcall(function()
                        if LocalPlayer.Character then
                            local crawling = LocalPlayer.Character:FindFirstChild("Crawling")
                            if crawling then
                                crawling:Destroy()
                            end
                        end
                    end)
                end
            end)
        end
    end
})

LocalPlayerModSection:AddToggle({
    Name = "Respawn Where You Died",
    Default = false,
    Callback = function(Value)
        getgenv().RespawnWhereDied = Value
    end
})

local CharacterModSection = MainTab:CreateSection({
    Name = "Character Modifications",
    Side = "Right"
})

getgenv().WalkSpeedValue = 16
getgenv().PlayerFlySpeed = 50

CharacterModSection:AddToggle({
    Name = "No Clip",
    Default = false,
    Callback = function(Value)
        getgenv().NoClip = Value
        if Value then
            task.spawn(function()
                while getgenv().NoClip do
                    if LocalPlayer.Character then
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Enhanced WalkSpeed Bypass from valley.lua
local enhancedWalk = false
local character, humanoidRootPart, humanoid
local speed = 16
local boostMultiplier = 2
local bodyGyro
local movementConnection
local freezeConnection
local animationTrack

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://788285906"

-- Dedicated SwimMethod for Enhanced Walk
task.spawn(function()
    while task.wait() do
        if enhancedWalk then
            if not getgenv().SwimMethod then
                getgenv().SwimMethod = true
            end
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
            end
        end
    end
end)

local function updateCharacterRefs()
    character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
end

local function cleanup()
    if movementConnection then movementConnection:Disconnect() movementConnection = nil end
    if freezeConnection then freezeConnection:Disconnect() freezeConnection = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if animationTrack then animationTrack:Stop() animationTrack = nil end
end

local function setupMovement()
    if not humanoidRootPart then return end

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 50000
    bodyGyro.D = 1000
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart

    movementConnection = RunService.RenderStepped:Connect(function()
        if not enhancedWalk then return end

        local camera = workspace.CurrentCamera
        local dir = Vector3.zero
        local usingKeys = false

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            dir += Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
            usingKeys = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            dir -= Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
            usingKeys = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            dir -= camera.CFrame.RightVector
            usingKeys = true
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            dir += camera.CFrame.RightVector
            usingKeys = true
        end

        if not usingKeys then
            local md = humanoid.MoveDirection
            dir = Vector3.new(md.X, 0, md.Z)
        end

        local moveSpeed = speed
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveSpeed = moveSpeed * boostMultiplier
        end

        if dir.Magnitude > 0 then
            dir = dir.Unit * moveSpeed
        end

        local currentY = humanoidRootPart.AssemblyLinearVelocity.Y
        local groundedY = math.clamp(currentY, -100, -2)
        humanoidRootPart.AssemblyLinearVelocity = Vector3.new(dir.X, groundedY, dir.Z)

        if dir.Magnitude > 0 then
            local look = dir.Unit
            bodyGyro.CFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + Vector3.new(look.X, 0, look.Z))
        end

        humanoidRootPart.RotVelocity = Vector3.zero
        humanoidRootPart.AssemblyAngularVelocity = Vector3.zero

        if dir.Magnitude > 0 then
            if not animationTrack.IsPlaying then animationTrack:Play() end
        else
            if animationTrack.IsPlaying then animationTrack:Stop() end
        end
    end)
end

local function startEnhancedWalk()
    enhancedWalk = true
    getgenv().usingEnhancedWalk = true
    updateCharacterRefs()
    cleanup()
    humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    getgenv().SwimMethod = true

    Notify("Bypassing anti-cheat, please wait...", 3)

    freezeConnection = RunService.RenderStepped:Connect(function()
        if enhancedWalk then
            if not getgenv().SwimMethod then
                getgenv().SwimMethod = true
            end
            humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end)

    local animator = humanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", humanoid)
    animationTrack = animator:LoadAnimation(animation)
    animationTrack.Looped = true

    task.delay(3, function()
        if freezeConnection then freezeConnection:Disconnect() freezeConnection = nil end
        if enhancedWalk then
            setupMovement()
            Notify("WalkSpeed bypassed!", 3)
        end
    end)
end

local function stopEnhancedWalk()
    enhancedWalk = false
    getgenv().usingEnhancedWalk = false
    cleanup()
    getgenv().SwimMethod = false
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    updateCharacterRefs()
    if enhancedWalk then
        startEnhancedWalk()
    end
end)

CharacterModSection:AddToggle({
    Name = "Enhanced WalkSpeed Bypass",
    Default = false,
    Callback = function(Value)
        if Value then
            startEnhancedWalk()
        else
            stopEnhancedWalk()
        end
    end
})

CharacterModSection:AddSlider({
    Name = "WalkSpeed Amount",
    Default = 16,
    Min = 16,
    Max = 200,
    Suffix = " speed",
    Callback = function(Value)
        speed = Value
        getgenv().WalkSpeedValue = Value
    end
})

-- Advanced Fly System from valley.lua
local flightCharacter, flightHumanoidRootPart, flightHumanoid
local flightSpeed = 100
local flying = false
local bodyVelocity, bodyGyro, flyConnection
local flightSeat
local flightAnimationTrack

local function updateFlightCharacterReferences()
    flightCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    flightHumanoidRootPart = flightCharacter:WaitForChild("HumanoidRootPart")
    flightHumanoid = flightCharacter:WaitForChild("Humanoid")
end

local function cleanupMovement()
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if flightAnimationTrack then flightAnimationTrack:Stop() flightAnimationTrack = nil end
end

local function getNearestSeat()
    local map = workspace:FindFirstChild("1# Map")
    if not map then return nil end

    local closestSeat, shortestDistance = nil, math.huge

    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Seat") or obj:IsA("VehicleSeat") then
            local distance = (obj.Position - flightHumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestSeat = obj
            end
        end
    end

    return closestSeat
end

local function bringSeatToPlayer()
    flightSeat = getNearestSeat()
    if flightSeat then
        flightSeat.Anchored = false
        flightSeat.CanCollide = true
        flightSeat.CFrame = flightHumanoidRootPart.CFrame * CFrame.new(0, -3, 0)
        task.wait(0.1)
        flightSeat:Sit(flightHumanoid)
    end
end

local function keepUnanchoredAndSeated()
    RunService.Stepped:Connect(function()
        if flightHumanoidRootPart and flightHumanoidRootPart.Anchored then
            flightHumanoidRootPart.Anchored = false
        end
        if flightHumanoid and flightHumanoid.PlatformStand then
            flightHumanoid.PlatformStand = false
        end
        if flying and flightSeat and flightHumanoid.SeatPart ~= flightSeat then
            flightSeat:Sit(flightHumanoid)
        end
    end)
end

local function startFlying()
    if flying then return end
    flying = true

    updateFlightCharacterReferences()
    bringSeatToPlayer()
    keepUnanchoredAndSeated()
    cleanupMovement()

    bodyVelocity = Instance.new("BodyVelocity", flightHumanoidRootPart)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.zero

    bodyGyro = Instance.new("BodyGyro", flightHumanoidRootPart)
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = flightHumanoidRootPart.CFrame
    
    local ninjaAnimation = Instance.new("Animation")
    ninjaAnimation.AnimationId = "rbxassetid://742637544"
    local animator = flightHumanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", flightHumanoid)
    flightAnimationTrack = animator:LoadAnimation(ninjaAnimation)
    flightAnimationTrack.Looped = true
    flightAnimationTrack:Play()

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not flightHumanoidRootPart or not workspace.CurrentCamera then return end

        local camCF = workspace.CurrentCamera.CFrame
        local direction = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end

        local currentSpeed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            and (flightSpeed * boostMultiplier) or flightSpeed

        bodyVelocity.Velocity = (direction.Magnitude > 0 and direction.Unit * currentSpeed) or Vector3.zero
        bodyGyro.CFrame = camCF
    end)
    
    Notify("Flight enabled!", 3)
end

local function stopFlying()
    flying = false
    cleanupMovement()
    if flightSeat and flightHumanoid and flightHumanoid.SeatPart == flightSeat then
        flightHumanoid.Sit = false
    end
    flightSeat = nil
    Notify("Flight disabled!", 3)
end

CharacterModSection:AddToggle({
    Name = "Advanced Flight",
    Default = false,
    Callback = function(Value)
        if Value then
            startFlying()
        else
            stopFlying()
        end
    end
})

CharacterModSection:AddSlider({
    Name = "Flight Speed",
    Default = 100,
    Min = 10,
    Max = 200,
    Suffix = " speed",
    Callback = function(Value)
        flightSpeed = Value
    end
})



local ToggleInterfacesSection = MainTab:CreateSection({
    Name = "Toggle Interfaces",
    Side = "Right"
})

local selectedInterface = "None"
local interfacesList = {}

local function updateInterfacesList()
    interfacesList = {"None"}
    if LocalPlayer.PlayerGui then
        for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") or gui:IsA("BillboardGui") then
                table.insert(interfacesList, gui.Name)
            end
        end
    end
    return interfacesList
end

ToggleInterfacesSection:AddDropdown({
    Name = "Selected UI",
    Items = updateInterfacesList(),
    Default = "None",
    Callback = function(Value)
        selectedInterface = Value
        Notify("Selected UI: " .. Value, 2)
    end
})

ToggleInterfacesSection:AddToggle({
    Name = "Toggle Selected UI",
    Default = true,
    Callback = function(Value)
        if selectedInterface and selectedInterface ~= "None" then
            local gui = LocalPlayer.PlayerGui:FindFirstChild(selectedInterface)
            if gui then
                gui.Enabled = Value
                Notify(selectedInterface .. " set to: " .. tostring(Value), 2)
            end
        end
    end
})

getgenv().SelectedPlayer = nil

local SelectPlayerSection = MiscTab:CreateSection({
    Name = "Select Player",
    Side = "Left"
})

local playerButtons = {}
local function updatePlayerList()
    pcall(function()
        for _, button in pairs(playerButtons) do
            if button and button.Instance then
                pcall(function() button.Instance:Destroy() end)
            end
        end
        playerButtons = {}
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local success, btn = pcall(function()
                    return SelectPlayerSection:AddButton({
                        Name = player.Name,
                        Callback = function()
                            getgenv().SelectedPlayer = player
                            getgenv().killauratarget = player
                            Notify("Selected: " .. player.Name, 2)
                        end
                    })
                end)
                if success and btn then
                    table.insert(playerButtons, btn)
                end
            end
        end
    end)
end

updatePlayerList()
Players.PlayerAdded:Connect(function()
    task.wait(0.1)
    updatePlayerList()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    updatePlayerList()
end)

local PlayerOptionsSection = MiscTab:CreateSection({
    Name = "Player Options",
    Side = "Right"
})

PlayerOptionsSection:AddToggle({
    Name = "Spectate Player",
    Default = false,
    Callback = function(Value)
        getgenv().SpectatePlayer = Value
        if Value then
            task.spawn(function()
                while getgenv().SpectatePlayer do
                    if getgenv().SelectedPlayer and getgenv().SelectedPlayer.Character then
                        Workspace.CurrentCamera.CameraSubject = getgenv().SelectedPlayer.Character:FindFirstChildOfClass("Humanoid")
                    end
                    task.wait(0.5)
                end
                Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            end)
        else
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
})

PlayerOptionsSection:AddToggle({
    Name = "Bring Player",
    Default = false,
    Callback = function(Value)
        getgenv().BringPlayer = Value
        if Value then
            task.spawn(function()
                while getgenv().BringPlayer do
                    if getgenv().SelectedPlayer and getgenv().SelectedPlayer.Character and LocalPlayer.Character then
                        local targetHRP = getgenv().SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local myHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP and myHRP then
                            targetHRP.CFrame = myHRP.CFrame + myHRP.CFrame.LookVector * 3
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

PlayerOptionsSection:AddToggle({
    Name = "Auto Kill Player w/Gun",
    Default = false,
    Callback = function(Value)
        getgenv().AutoKillPlayer = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoKillPlayer do
                    if getgenv().SelectedPlayer and getgenv().SelectedPlayer.Character and LocalPlayer.Character then
                        local target = getgenv().SelectedPlayer
                        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool and tool:FindFirstChild("GunScript_Local") and target.Character:FindFirstChild("Head") then
                            pcall(function()
                                local args = {
                                    [1] = target.Character.Head,
                                    [2] = target.Character.Head.Position,
                                    [3] = tool
                                }
                                ReplicatedStorage.GunRemote:FireServer(unpack(args))
                            end)
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

PlayerOptionsSection:AddButton({
    Name = "Teleport To Player",
    Callback = function()
        if getgenv().SelectedPlayer and getgenv().SelectedPlayer.Character then
            local hrp = getgenv().SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                teleportTo(hrp.CFrame)
            end
        end
    end
})

PlayerOptionsSection:AddButton({
    Name = "Down Player - Hold Gun",
    Callback = function()
        if not getgenv().SelectedPlayer then
            Notify("No player selected!", 2)
            return
        end
        
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if not tool or not tool:FindFirstChild("GunScript_Local") then
            Notify("Hold a gun first!", 2)
            return
        end
        
        Notify("Downing player...", 2)
        task.spawn(function()
            local target = getgenv().SelectedPlayer
            if target and target.Character and target.Character:FindFirstChild("Head") then
                for i = 1, 30 do
                    if not target.Character or not target.Character:FindFirstChild("Humanoid") then break end
                    pcall(function()
                        local args = {
                            [1] = target.Character.Head,
                            [2] = target.Character.Head.Position,
                            [3] = tool
                        }
                        ReplicatedStorage.GunRemote:FireServer(unpack(args))
                    end)
                    task.wait(0.05)
                end
                Notify("Down complete!", 2)
            end
        end)
    end
})

PlayerOptionsSection:AddButton({
    Name = "Kill Player - Hold Gun",
    Callback = function()
        if not getgenv().SelectedPlayer then
            Notify("No player selected!", 2)
            return
        end
        
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if not tool or not tool:FindFirstChild("GunScript_Local") then
            Notify("Hold a gun first!", 2)
            return
        end
        
        Notify("Killing player...", 2)
        task.spawn(function()
            local target = getgenv().SelectedPlayer
            if target and target.Character and target.Character:FindFirstChild("Head") then
                for i = 1, 80 do
                    if not target.Character or not target.Character:FindFirstChild("Humanoid") or target.Character.Humanoid.Health <= 0 then break end
                    pcall(function()
                        local args = {
                            [1] = target.Character.Head,
                            [2] = target.Character.Head.Position,
                            [3] = tool
                        }
                        ReplicatedStorage.GunRemote:FireServer(unpack(args))
                    end)
                    task.wait(0.05)
                end
                Notify("Kill complete!", 2)
            end
        end)
    end
})

PlayerOptionsSection:AddButton({
    Name = "Kill All - Hold Gun",
    Callback = function()
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if not tool or not tool:FindFirstChild("GunScript_Local") then
            Notify("Hold a gun first!", 2)
            return
        end
        
        Notify("Killing all players...", 2)
        task.spawn(function()
            local duration = 5
            local startTime = tick()
            
            while tick() - startTime < duration do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
                        dmg(player, "Head", 1000)
                    end
                end
                task.wait(0.1)
            end
            Notify("Kill all complete!", 2)
        end)
    end
})

local PurchaseItemSection = MiscTab:CreateSection({
    Name = "Purchase Selected Item",
    Side = "Right"
})

local shopOptions = {
    {name = "Shiesty", type = "ShopRemote", price = "$25"},
    {name = "BlackGloves", type = "ShopRemote", price = "$10"},
    {name = "BluGloves", type = "ShopRemote", price = "$10"},
    {name = "WhiteGloves", type = "ShopRemote", price = "$10"},
    {name = "AppleJuice", type = "ShopRemote", price = "$15"},
    {name = "GreenAppleJuice", type = "ShopRemote", price = "$15"},
    {name = "FakeCard", type = "ExoticShopRemote", price = "$500"},
    {name = "Ice-Fruit Bag", type = "ExoticShopRemote", price = "$100"},
    {name = "Ice-Fruit Cupz", type = "ExoticShopRemote", price = "$75"},
    {name = "FijiWater", type = "ExoticShopRemote", price = "$50"},
    {name = "FreshWater", type = "ExoticShopRemote", price = "$25"}
}

local selectedShopItem = nil
local shopItemNames = {}
for _, item in ipairs(shopOptions) do
    table.insert(shopItemNames, item.name .. " (" .. item.price .. ")")
end

PurchaseItemSection:AddDropdown({
    Name = "Select Item",
    Items = shopItemNames,
    Default = shopItemNames[1] or "",
    Callback = function(selected)
        for _, item in ipairs(shopOptions) do
            if item.name .. " (" .. item.price .. ")" == selected then
                selectedShopItem = item
                Notify("Selected: " .. item.name, 1)
                break
            end
        end
    end
})

PurchaseItemSection:AddButton({
    Name = "Buy Item",
    Callback = function()
        if not selectedShopItem then 
            Notify("Please select an item first!", 2)
            return 
        end
        
        local success = pcall(function()
            if selectedShopItem.type == "ShopRemote" then
                ReplicatedStorage:WaitForChild("ShopRemote"):InvokeServer(selectedShopItem.name)
            else
                ReplicatedStorage:WaitForChild("ExoticShopRemote"):InvokeServer(selectedShopItem.name)
            end
        end)
        
        if success then
            Notify("Purchased " .. selectedShopItem.name, 2)
        end
    end
})

-- Weapon/Gun Shop with Teleport Method
getgenv().SelectedWeapon = nil

local function getRealWeapons()
    local realWeapons = {}
    
    if Workspace:FindFirstChild("GUNS") then
        for _, gunModel in pairs(Workspace.GUNS:GetChildren()) do
            if gunModel:IsA("Model") then
                local price = gunModel:FindFirstChild("Price", true)
                if price and price.Value > 0 then
                    table.insert(realWeapons, gunModel.Name)
                end
            end
        end
    end
    
    table.sort(realWeapons)
    return realWeapons
end

local weaponNames = getRealWeapons()

PurchaseItemSection:AddDropdown({
    Name = "Select Weapon",
    Items = weaponNames,
    Default = weaponNames[1] or "",
    Callback = function(selected)
        getgenv().SelectedWeapon = selected
        Notify("Selected: " .. selected, 1)
    end
})

PurchaseItemSection:AddButton({
    Name = "Buy Weapon",
    Callback = function()
        if not getgenv().SelectedWeapon then
            Notify("Please select a weapon first!", 2)
            return
        end
        
        task.spawn(function()
            local itemName = getgenv().SelectedWeapon
            local gunModel = Workspace.GUNS:FindFirstChild(itemName)
            
            if not gunModel then
                Notify("Weapon '" .. itemName .. "' not found!", 2)
                return
            end
            
            local gamepassID = gunModel:FindFirstChild("GamepassID", true)
            if gamepassID and gamepassID.Value > 0 then
                local hasPass = false
                pcall(function()
                    hasPass = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, gamepassID.Value)
                end)
                if not hasPass then
                    Notify("You need the gamepass for " .. itemName .. "!", 2)
                    return
                end
            end
            
            local prompt = gunModel:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                local oldPosition = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame
                
                if not oldPosition then
                    Notify("Character not found!", 2)
                    return
                end
                
                -- Teleport to weapon
                teleportTo(prompt.Parent.CFrame.Position + Vector3.new(0, 3, 0))
                task.wait(0.5)
                
                -- Fire the prompt
                for i = 1, 5 do
                    prompt.HoldDuration = 0
                    prompt.RequiresLineOfSight = false
                    fireproximityprompt(prompt)
                    task.wait(0.1)
                end
                
                task.wait(1)
                
                -- Teleport back
                teleportTo(oldPosition)
                
                Notify("Purchased " .. itemName .. "!", 2)
            else
                Notify("Could not find purchase prompt for " .. itemName .. "!", 2)
            end
        end)
    end
})

local TeleportSpots1 = TeleportTab:CreateSection({
    Name = "Teleport Spots",
    Side = "Left"
})

local TeleportSpots2 = TeleportTab:CreateSection({
    Name = "More Teleport Spots",
    Side = "Right"
})

local locations = {
    ["🏛️ Bank"] = Vector3.new(-226.22584533691406, 283.8095703125, -1217.7509765625),
    ["💸 Money Wash"] = Vector3.new(-376.1771 - 601, 197.6838 + 56, -1975.5855 + 1035 + 248),
    ["📦 Safe Items"] = Vector3.new(48917.8984 + 19597, 53680.5 - 396 - 343, -796.09),
    ["💰 Pawn Shop"] = Vector3.new(-23.6431 - 1026, 391.5367 - 138, -1118.2697 + 300 + 4),
    ["🔒 Bank Vault"] = Vector3.new(-217.568359375, 373.7984924316406, -1216.20947265625),
    ["🤑 Money Man"] = Vector3.new(-1008.0662, 262.1141, 55.1336),
    ["🔫 GunShop 1"] = Vector3.new(198909.8984 - 105940, 488.9688 + 121609, 17023.8867),
    ["🛡️ GunShop 1 Lobby"] = Vector3.new(-1002.4224, 563.6382 - 310, -1685.9125 + 244 + 638),
    ["🔫 GunShop 2"] = Vector3.new(66195.4453125, 123615.7109375, 5750.28271484375),
    ["🛡️ GunShop 2 Lobby"] = Vector3.new(-224.3818359375, 283.8034362792969, -794.7174072265625),
    ["🔫 GunShop 3"] = Vector3.new(61041.3086 - 55 - 166, 16979.1484 + 70630, -36.4746 - 315),
    ["🏢 Pent House"] = Vector3.new(-178.27471923828125, 397.1383056640625, -573.0322265625),
    ["🍵 Pent House2"] = Vector3.new(-618.0346069335938, 356.5451354980469, -681.4015502929688),
    ["🏠 Mini Mansion"] = Vector3.new(-791.5180053710938, 256.7944641113281, 1414.4248046875),
    ["🎒 Backpack Shop"] = Vector3.new(-692.4142456054688, 253.78091430664062, -681.0672607421875),
    ["💎 Frozen Shop"] = Vector3.new(-216.31436157226562, 284.031494140625, -1169.032470703125),
    ["💧 Drip Shop"] = Vector3.new(7378.6953 + 60084, 18630.0352 - 8141, 205.5895 + 344),
    ["🍗 Chicken Wings"] = Vector3.new(-1559.9142 + 512 + 90, 253.5367, -815.9442),
    ["🥪 Deli"] = Vector3.new(-755.8114013671875, 254.6927490234375, -687.1181640625),
    ["🚗 Car Dealer"] = Vector3.new(-401.99371337890625, 253.4141082763672, -1248.8380126953125),
    ["👕 Drip Store"] = Vector3.new(67462, 10489.21484375, 546.1941528320312),
    ["🥤 Soda Warehouse"] = Vector3.new(-187.85504150390625, 284.6252136230469, -291.3419189453125),
    ["🍾 Soda Supplies"] = Vector3.new(-403.09906005859375, 254.20343017578125, -580.0437622070312),
    ["🍹 Soda Seller"] = Vector3.new(-1292.2200927734375, 253.30044555664062, -3003.04833984375),
    ["🐍 Exotic Dealer"] = Vector3.new(-1523.5654296875, 273.9729919433594, -990.6575317382812),
    ["🔀 Switch Seller"] = Vector3.new(-1446.2166748046875, 256.059814453125, 2189.876220703125),
    ["🛠️ Bank Tools"] = Vector3.new(-397.4308776855469, 334.3142395019531, -555.7023315429688),
    ["🚧 Construction Site"] = Vector3.new(-3120.8307 + 135 + 1254, 1393.8123 - 1023, -5490.8387 + 4314),
    ["🚔 Prison"] = Vector3.new(-1135.0464, 254.7160, -3330.9954),
    ["🍟 McDonalds"] = Vector3.new(-1012.13, 253.71, -1148.07),
    ["❄️ Ice Box"] = Vector3.new(-120.1407 - 95, 283.5154, -1173.691 - 85),
    ["🏥 Hospital"] = Vector3.new(-1589.504150390625, 254.27223205566406, 17.6555233001709),
    ["🛍️ MarGreens"] = Vector3.new(-381.20751953125, 254.45382690429688, -385.66546630859375),
    ["🚨 Feds Room"] = Vector3.new(-1441.7904052734375, 255.03651428222656, -3132.597412109375),
    ["🚪 House Rob Door 1"] = Vector3.new(-714.2440185546875, 287.1214294433594, -779.2329711914062),
    ["🚪 House Rob Door 2"] = Vector3.new(-606.2669067382812, 253.8867645263672, -679.8844604492188),
    ["🎬 Studio Robbery"] = Vector3.new(93427.515625, 14484.9052734375, 566.6701049804688),
    ["🏕️ TrailerPark"] = Vector3.new(-1522.76904296875, 253.16094970703125, 2344.95947265625),
    ["🏨 Woody's Hotel"] = Vector3.new(-1022.61962890625, 325.8400573730469, -908.9157104492188)
}

local locationIndex = 0
for locationName, position in pairs(locations) do
    locationIndex = locationIndex + 1
    local targetSection = (locationIndex % 2 == 1) and TeleportSpots1 or TeleportSpots2
    targetSection:AddButton({
        Name = locationName,
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                teleportTo(position)
                Notify("Teleported to " .. locationName, 2)
            end
        end
    })
end

local FarmingSection = MoneyTab:CreateSection({
    Name = "Farming",
    Side = "Left"
})

FarmingSection:AddToggle({
    Name = "Auto Farm Studio",
    Default = false,
    Callback = function(Value)
        getgenv().AutoFarmStudio = Value
        
        if Value then
            task.spawn(function()
                local camera = Workspace.CurrentCamera
                
                local function studioPrompt()
                    for _, v in pairs(Workspace.StudioPay.Money:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.Name == "Prompt" then
                            v.HoldDuration = 0
                            v.RequiresLineOfSight = false
                        end
                    end
                end
                
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if not root or not humanoid then return end

                local originalCFrame = root.CFrame
                studioPrompt()

                for _, v in pairs(Workspace.StudioPay.Money:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Name == "Prompt" and v.Enabled and getgenv().AutoFarmStudio then
                        humanoid:ChangeState(0)
                        repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")

                        root.CFrame = CFrame.new(
                            v.Parent.Position.X,
                            v.Parent.Position.Y + 2,
                            v.Parent.Position.Z
                        )

                        camera.CFrame = CFrame.new(camera.CFrame.Position, v.Parent.Position)
                        task.wait(0.25)

                        repeat
                            task.wait(0.3)
                            fireproximityprompt(v)
                        until v.Enabled == false or not getgenv().AutoFarmStudio

                        if not getgenv().AutoFarmStudio then break end
                    end
                end

                if getgenv().AutoFarmStudio then
                    root.CFrame = originalCFrame
                    Notify("Studio robbery complete!", 2)
                end
            end)
        end
    end
})

FarmingSection:AddToggle({
    Name = "Auto Farm Dumpsters",
    Default = false,
    Callback = function(Value)
        getgenv().AutoFarmDumpsters = Value
        
        if Value then
            task.spawn(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Name == "ProximityPrompt" and v.Parent.Name == "DumpsterPromt" then
                        v.HoldDuration = 0
                        v.RequiresLineOfSight = false
                    end
                end

                while getgenv().AutoFarmDumpsters do
                    task.wait()
                    for _, v in pairs(Workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.Name == "ProximityPrompt" and v.Parent.Name == "DumpsterPromt" then
                            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                            if hrp and humanoid then
                                humanoid:ChangeState(0)
                                repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
                                hrp.CFrame = CFrame.new(v.Parent.Position.X, v.Parent.Position.Y, v.Parent.Position.Z + 3)
                            end
                            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, v.Parent.Position)
                            task.wait(0.3)
                            for _ = 1, 10 do fireproximityprompt(v) end
                            task.wait(0.1)
                            if not getgenv().AutoFarmDumpsters then break end
                        end
                    end
                end
            end)
        end
    end
})

FarmingSection:AddToggle({
    Name = "Auto Farm Construction",
    Default = false,
    Callback = function(Value)
        getgenv().AutoFarmConstruction = Value
        
        if Value then
            task.spawn(function()
                local function getCharacter()
                    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                end

                local function safeTeleport(cf)
                    local character = getCharacter()
                    local humanoid = character:WaitForChild("Humanoid")
                    local hrp = character:WaitForChild("HumanoidRootPart")
                    humanoid:ChangeState(0)
                    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
                    hrp.CFrame = cf
                end

                local function getBackpack()
                    return LocalPlayer:FindFirstChild("Backpack")
                end

                local function hasPlyWood()
                    local backpack = getBackpack()
                    local character = getCharacter()
                    return (backpack and backpack:FindFirstChild("PlyWood")) or
                    (character and character:FindFirstChild("PlyWood"))
                end

                local function equipPlyWood()
                    local backpack = getBackpack()
                    if backpack then
                        local plyWood = backpack:FindFirstChild("PlyWood")
                        if plyWood then
                            plyWood.Parent = getCharacter()
                        end
                    end
                end

                local function fireProx(prompt)
                    if prompt and prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt)
                    end
                end

                local function grabWood()
                    safeTeleport(CFrame.new(-1727, 371, -1178))
                    task.wait(0.1)

                    while getgenv().AutoFarmConstruction and not hasPlyWood() do
                        fireProx(Workspace.ConstructionStuff["Grab Wood"]:FindFirstChildOfClass("ProximityPrompt"))
                        task.wait(0.1)
                        equipPlyWood()
                    end
                end

                local function buildWall(wallPromptName, wallPosition)
                    local prompt = Workspace.ConstructionStuff[wallPromptName]:FindFirstChildOfClass("ProximityPrompt")

                    while getgenv().AutoFarmConstruction and prompt and prompt.Enabled do
                        safeTeleport(wallPosition)
                        task.wait(0.01)
                        fireProx(prompt)
                        task.wait()
                        if not hasPlyWood() then
                            grabWood()
                        end
                    end
                end

                -- Start job
                safeTeleport(CFrame.new(-1728, 371, -1172))
                task.wait(0.2)
                fireProx(Workspace.ConstructionStuff["Start Job"]:FindFirstChildOfClass("ProximityPrompt"))
                task.wait(0.5)

                while getgenv().AutoFarmConstruction do
                    if not hasPlyWood() then
                        grabWood()
                    end

                    buildWall("Wall2 Prompt", CFrame.new(-1705, 368, -1151))
                    buildWall("Wall3 Prompt", CFrame.new(-1732, 368, -1152))
                    buildWall("Wall4 Prompt2", CFrame.new(-1772, 368, -1152))
                    buildWall("Wall1 Prompt3", CFrame.new(-1674, 368, -1166))

                    if getgenv().AutoFarmConstruction then
                        Notify("Construction job complete!", 3)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

FarmingSection:AddToggle({
    Name = "Auto Farm Houses",
    Default = false,
    Callback = function(Value)
        getgenv().AutoFarmHouses = Value
        
        if Value then
            task.spawn(function()
                local Camera = Workspace.CurrentCamera
                
                local function BypassTp(cf)
                    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local humanoid = char:WaitForChild("Humanoid")
                    local root = char:WaitForChild("HumanoidRootPart")
                    humanoid:ChangeState(0)
                    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
                    root.CFrame = cf
                end

                local Houseleft = {}
                local Houseright = {}
                local targetPosition = Vector3.new(-615, 254, -695)

                local function updateDoors()
                    table.clear(Houseleft)
                    table.clear(Houseright)

                    for _, v in pairs(Workspace.HouseRobb:GetDescendants()) do
                        if (v.Name == "WoodenDoor" or v.Name == "HardDoor") and v:IsA("BasePart") and v:FindFirstChild("ProximityPrompt") then
                            if (v.Position - targetPosition).Magnitude <= 10 then
                                Houseright[v.Name] = v
                            else
                                Houseleft[v.Name] = v
                            end
                        end
                    end
                end

                local function HouseRobPrompts()
                    for _, v in pairs(Workspace.HouseRobb:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.Name == "ProximityPrompt" then
                            v.HoldDuration = 0
                            v.RequiresLineOfSight = false
                            v.Enabled = false
                        end
                    end
                end

                local OldCframe = LocalPlayer.Character.HumanoidRootPart.CFrame
                HouseRobPrompts()

                while getgenv().AutoFarmHouses do
                    task.wait()
                    updateDoors()

                    if not getgenv().AutoFarmHouses then break end

                    local house1Robbed = Houseleft["HardDoor"] and Houseleft["HardDoor"].Transparency == 1

                    if not house1Robbed and Houseleft["HardDoor"] then
                        for _, v in pairs(Houseleft["HardDoor"]:GetDescendants()) do
                            if v:IsA("ProximityPrompt") and v.Name == "ProximityPrompt" then
                                v.Enabled = true
                                BypassTp(v.Parent.CFrame * CFrame.new(-1.5, 0, 0))
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, v.Parent.Position)
                                repeat
                                    task.wait()
                                    fireproximityprompt(v)
                                until Houseleft["HardDoor"].Transparency == 1
                            end
                        end

                        for _, v in pairs(Houseleft["HardDoor"].Parent.Parent:GetDescendants()) do
                            if v:IsA("ProximityPrompt") and v.Name == "ProximityPrompt" then
                                HouseRobPrompts()
                                local targetCFrame = v.Parent.CFrame * CFrame.new(0, 0, -3)
                                BypassTp(targetCFrame)
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, v.Parent.Position)
                                v.Enabled = true
                                repeat
                                    fireproximityprompt(v)
                                    task.wait()
                                until v.Parent.Transparency == 1
                                v.Enabled = false
                            end
                        end
                    end

                    local house2Robbed = Houseright["WoodenDoor"] and Houseright["WoodenDoor"].Transparency == 1

                    if not house2Robbed and Houseright["WoodenDoor"] then
                        for _, v in pairs(Houseright["WoodenDoor"]:GetDescendants()) do
                            if v:IsA("ProximityPrompt") and v.Name == "ProximityPrompt" then
                                v.Enabled = true
                                BypassTp(v.Parent.CFrame * CFrame.new(-1.5, 0, 0))
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, v.Parent.Position)
                                repeat
                                    task.wait()
                                    fireproximityprompt(v)
                                until Houseright["WoodenDoor"].Transparency == 1
                            end
                        end

                        for _, v in pairs(Houseright["WoodenDoor"].Parent.Parent:GetDescendants()) do
                            if v:IsA("ProximityPrompt") and v.Name == "ProximityPrompt" then
                                HouseRobPrompts()
                                local targetCFrame = v.Parent.CFrame * CFrame.new(0, 0, -3)
                                BypassTp(targetCFrame)
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, v.Parent.Position)
                                v.Enabled = true
                                repeat
                                    fireproximityprompt(v)
                                    task.wait()
                                until v.Parent.Transparency == 1
                                v.Enabled = false
                            end
                        end
                    end

                    BypassTp(OldCframe)
                    Notify("House robbery complete!", 2)
                    break
                end
            end)
        end
    end
})

local BankActionsSection = MoneyTab:CreateSection({
    Name = "Bank Actions",
    Side = "Left"
})

local moneyAmount = 100
BankActionsSection:AddTextBox({
    Name = "Money Amount ($)",
    Default = "100",
    Placeholder = "Enter amount...",
    Callback = function(Value)
        moneyAmount = tonumber(Value) or 100
    end
})

BankActionsSection:AddButton({
    Name = "Withdraw",
    Callback = function()
        pcall(function()
            ReplicatedStorage:WaitForChild("BankAction"):FireServer("with", moneyAmount)
        end)
        Notify("Withdrew $" .. moneyAmount, 2)
    end
})

BankActionsSection:AddButton({
    Name = "Deposit",
    Callback = function()
        pcall(function()
            ReplicatedStorage:WaitForChild("BankProcessRemote"):InvokeServer("depo", moneyAmount)
        end)
        Notify("Deposited $" .. moneyAmount, 2)
    end
})

BankActionsSection:AddButton({
    Name = "Drop",
    Callback = function()
        pcall(function()
            ReplicatedStorage:WaitForChild("BankProcessRemote"):InvokeServer("Drop", moneyAmount)
        end)
        Notify("Dropped $" .. moneyAmount, 2)
    end
})

BankActionsSection:AddToggle({
    Name = "Auto Drop",
    Default = false,
    Callback = function(Value)
        getgenv().AutoDrop = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoDrop do
                    pcall(function()
                        ReplicatedStorage:WaitForChild("BankProcessRemote"):InvokeServer("Drop", moneyAmount)
                    end)
                    task.wait(1.5)
                end
            end)
        end
    end
})

local ManualFarmsSection = MoneyTab:CreateSection({
    Name = "Manual Farms",
    Side = "Right"
})

ManualFarmsSection:AddToggle({
    Name = "Auto Sell Trash",
    Default = false,
    Callback = function(Value)
        getgenv().AutoSellTrash = Value
        if Value then
            task.spawn(function()
                while getgenv().AutoSellTrash do
                    task.wait(1)
                    pcall(function()
                        for _, frame in ipairs(LocalPlayer.PlayerGui["Bronx PAWNING"].Frame.Holder.List:GetChildren()) do
                            if frame:IsA("Frame") then
                                local itemName = frame.Item.Text
                                while LocalPlayer.Backpack:FindFirstChild(itemName) and getgenv().AutoSellTrash do
                                    ReplicatedStorage.PawnRemote:FireServer(itemName)
                                    task.wait(0.05)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
})

ManualFarmsSection:AddButton({
    Name = "Clean All Filthy Money",
    Callback = function()
        Notify("Cleaning money...", 2)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hillsTools/clean-money/refs/heads/main/hills"))()
    end
})

local VulnerabilitySection = MoneyTab:CreateSection({
    Name = "Duping",
    Side = "Right"
})

getgenv().AutoDupeRunning = false

local function getPing()
    if typeof(LocalPlayer.GetNetworkPing) == "function" then
        local success, result = pcall(function()
            return tonumber(string.match(LocalPlayer:GetNetworkPing(), "%d+"))
        end)
        if success and result then return result end
    end
    local t0 = tick()
    local temp = Instance.new("BoolValue", ReplicatedStorage)
    temp.Name = "PingTest_" .. tostring(math.random(10000,99999))
    task.wait(0.1)
    local t1 = tick()
    temp:Destroy()
    return math.clamp((t1 - t0) * 1000, 50, 300)
end

VulnerabilitySection:AddToggle({
    Name = "Auto Dupe All Items",
    Default = false,
    Callback = function(Value)
        getgenv().AutoDupeRunning = Value
        if Value then
            Notify("Auto Dupe Started", 3)
            task.spawn(function()
                local Backpack = LocalPlayer:WaitForChild("Backpack")
                while getgenv().AutoDupeRunning do
                    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local Tool = Character:FindFirstChildOfClass("Tool")
                    if not Tool then
                        task.wait(1)
                        continue
                    end

                    local ToolName = Tool.Name
                    local ToolId = nil

                    -- Unequip to backpack
                    Tool.Parent = Backpack
                    task.wait(0.5)

                    -- Get optimized delay based on ping
                    local ping = getPing()
                    local delay = 0.25 + ((math.clamp(ping, 0, 300) / 300) * 0.08)

                    -- Monitor market for item listing
                    local marketconnection
                    marketconnection = ReplicatedStorage.MarketItems.ChildAdded:Connect(function(item)
                        if item.Name == ToolName then
                            local owner = item:WaitForChild("owner", 2)
                            if owner and owner.Value == LocalPlayer.Name then
                                ToolId = item:GetAttribute("SpecialId")
                            end
                        end
                    end)

                    -- List item on market at 99999
                    task.spawn(function()
                        ReplicatedStorage.ListWeaponRemote:FireServer(ToolName, 99999)
                    end)

                    task.wait(delay)

                    -- Store item in storage (WITHOUT adding to backpack)
                    task.spawn(function()
                        ReplicatedStorage.BackpackRemote:InvokeServer("Store", ToolName)
                    end)

                    task.wait(3.2)

                    -- Remove from market
                    if ToolId then
                        task.spawn(function()
                            ReplicatedStorage.BuyItemRemote:FireServer(ToolName, "Remove", ToolId)
                        end)
                    end

                    -- Grab back from storage (duped item)
                    task.spawn(function()
                        task.wait(0.3)
                        ReplicatedStorage.BackpackRemote:InvokeServer("Grab", ToolName)
                    end)

                    if marketconnection then
                        marketconnection:Disconnect()
                    end

                    task.wait(3.5)
                end
                Notify("Auto Dupe Stopped", 2)
            end)
        else
            getgenv().AutoDupeRunning = false
        end
    end
})

local VulnerabilitySection2 = MoneyTab:CreateSection({
    Name = "Vulnerabilities",
    Side = "Right"
})

VulnerabilitySection2:AddLabel({
    Text = "Need 5K To Do Auto Inf Money!"
})

VulnerabilitySection2:AddButton({
    Name = "Auto Infinite Money",
    Callback = function()
        Notify("Starting Auto Inf Money...", 3)
        
        task.spawn(function()
            local Camera = Workspace.CurrentCamera
            local player = LocalPlayer
            
            -- Helper function to check if cooking pot is in use
            local function isPotInUse(pot)
                if not pot then return true end
                local fire = pot:FindFirstChild("Fire1")
                if not fire then return false end
                local particleEmitter = fire:FindFirstChild("ParticleEmitter")
                if not particleEmitter then return false end
                return particleEmitter.Enabled
            end
            
            -- Find available cooking pot
            local cookingpot
            local allPots = {}
            
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name == "CookPart" then
                    table.insert(allPots, v)
                end
            end
            
            -- Find first available pot
            for _, pot in pairs(allPots) do
                if not isPotInUse(pot) then
                    cookingpot = pot
                    break
                end
            end
            
            -- If all pots are in use, use the first one found
            if not cookingpot and #allPots > 0 then
                cookingpot = allPots[1]
                Notify("All pots in use, waiting for one to be available...", 3)
            end
            
            local prompt = cookingpot and cookingpot:FindFirstChildWhichIsA("ProximityPrompt")
            
            -- Auto-find IceFruit Sell part in workspace
            local refill = Workspace:FindFirstChild("IceFruit Sell")
            if not refill then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "IceFruit Sell" then
                        refill = v
                        break
                    end
                end
            end
            
            -- Validation
            if not cookingpot or not prompt or not refill then
                Notify("Missing required game objects!", 3)
                return
            end
            
            -- Utility functions
            local function enableSellingPrompts()
                local sellPart = Workspace:FindFirstChild("IceFruit Sell")
                if not sellPart then return end
                
                for _, v in pairs(sellPart:GetDescendants()) do 
                    if v:IsA("ProximityPrompt") then 
                        v.Enabled = true
                        v.HoldDuration = 0
                        v.RequiresLineOfSight = false
                    end
                end
            end
            
            enableSellingPrompts()
            
            -- Check money
            local money = player:FindFirstChild("stored") and player.stored:FindFirstChild("Money") and player.stored.Money.Value or 0
            
            -- Item purchasing
            local requiredItems = {"Ice-Fruit Bag", "Ice-Fruit Cupz", "FijiWater", "FreshWater"}
            local hasAllItems = true
            
            for _, item in ipairs(requiredItems) do
                if not (player.Backpack:FindFirstChild(item) or (player.Character and player.Character:FindFirstChild(item))) then
                    hasAllItems = false
                    break
                end
            end
            
            if hasAllItems then
                Notify("You already have all items!", 2)
            else
                if money < 2696 then
                    Notify("Insufficient funds! Need $2696", 3)
                    return
                end
                
                Notify("Buying required items...", 2)
                
                local function buyItem(itemName)
                    if not player.Backpack:FindFirstChild(itemName) and not (player.Character and player.Character:FindFirstChild(itemName)) then
                        local success = pcall(function()
                            ReplicatedStorage:WaitForChild("ExoticShopRemote"):InvokeServer(itemName)
                        end)
                        return success
                    end
                    return true
                end
                
                for _, item in ipairs(requiredItems) do
                    local attempts = 0
                    repeat
                        local success = buyItem(item)
                        if not success then
                            task.wait(1)
                        end
                        task.wait(0.3)
                        attempts = attempts + 1
                    until (player.Character and player.Character:FindFirstChild(item)) or player.Backpack:FindFirstChild(item) or attempts > 5
                end
            end
            
            -- Cooking state functions
            local function isCookingActive()
                if not cookingpot then return false end
                local fire = cookingpot:FindFirstChild("Fire1")
                if not fire then return false end
                local particleEmitter = fire:FindFirstChild("ParticleEmitter")
                if not particleEmitter then return false end
                return particleEmitter.Enabled
            end
            
            local function isCookingCompleted()
                if not cookingpot then return false end
                local fire = cookingpot:FindFirstChild("Fire1")
                if not fire then return false end
                local particleEmitter = fire:FindFirstChild("ParticleEmitter")
                if not particleEmitter then return false end
                return not particleEmitter.Enabled
            end
            
            -- Tool usage function
            local function equipAndUse(toolName)
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        player.Character.Humanoid:UnequipTools()
                    end
                end)
                
                task.wait(0.5)
                if not prompt then return false end
                
                -- Setup for instant prompts
                prompt.HoldDuration = 0
                prompt.RequiresLineOfSight = false
                prompt.Enabled = true
                
                local tool = player.Backpack:FindFirstChild(toolName)
                if not tool then
                    return false
                end
                
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:EquipTool(tool)
                    
                    local toolEquippedTime = 0
                    repeat 
                        task.wait(0.1)
                        toolEquippedTime = toolEquippedTime + 0.1
                        if toolEquippedTime > 5 then
                            break
                        end
                    until player.Character:FindFirstChild(toolName) or toolEquippedTime > 5
                    
                    if cookingpot then
                        teleportTo(cookingpot.Position + Vector3.new(0, 3, 0))
                    end
                    
                    for i = 1, 30 do
                        task.wait(0.1)
                        
                        -- Ensure prompt settings
                        if prompt then
                            prompt.HoldDuration = 0
                            prompt.RequiresLineOfSight = false
                            prompt.Enabled = true
                        end
                        
                        if Camera and prompt and prompt.Parent then
                            Camera.CFrame = CFrame.new(Camera.CFrame.Position, prompt.Parent.Position)
                        end
                        
                        pcall(function()
                            fireproximityprompt(prompt)
                        end)
                        
                        if not player.Character:FindFirstChild(toolName) and not player.Backpack:FindFirstChild(toolName) then
                            return true
                        end
                        
                        if toolName == "FreshWater" and isCookingActive() then
                            return true
                        end
                    end
                    
                    return false
                end
                return false
            end
            
            -- Main cooking process
            Notify("Starting cooking process...", 2)
            
            if prompt and prompt.Parent then
                teleportTo(Vector3.new(-1609, 254, -517))
                local promptEnabledTime = 0
                
                repeat
                    task.wait(0.2)
                    if Camera and prompt and prompt.Parent then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, prompt.Parent.Position)
                    end
                    promptEnabledTime = promptEnabledTime + 0.2
                    if promptEnabledTime > 10 then
                        if cookingpot then
                            teleportTo(cookingpot.Position + Vector3.new(0, 3, 0))
                            task.wait(1)
                            promptEnabledTime = 0 
                        else
                            break
                        end
                    end
                until prompt.Enabled or promptEnabledTime > 10
                
                if prompt.Enabled then
                    prompt.RequiresLineOfSight = false
                    prompt.HoldDuration = 0
                    
                    local wateredSuccess = equipAndUse("FijiWater")
                    task.wait(0.5)
                    
                    local fruitSuccess = equipAndUse("Ice-Fruit Bag")
                    task.wait(1)
                    
                    local freshWaterSuccess = equipAndUse("FreshWater")
                    
                    local cookingStartTime = os.time()
                    repeat
                        task.wait(0.5)
                        
                        if os.time() - cookingStartTime > 10 and not isCookingActive() then
                            fruitSuccess = equipAndUse("Ice-Fruit Bag")
                            task.wait(1)
                            freshWaterSuccess = equipAndUse("FreshWater")
                            
                            cookingStartTime = os.time()
                        end
                        
                        if os.time() - cookingStartTime > 30 then
                            break
                        end
                        
                    until isCookingActive() or os.time() - cookingStartTime > 30
                    
                    if isCookingActive() then
                        Notify("Cooking in progress...", 2)
                        
                        local cookingTime = 0
                        repeat 
                            task.wait(0.5)
                            cookingTime = cookingTime + 0.5
                            
                            if cookingTime > 300 then
                                break
                            end
                        until isCookingCompleted() or cookingTime > 300
                        
                        if isCookingCompleted() then
                            Notify("Cooking completed!", 2)
                        end
                        
                        -- Equip Ice-Fruit Cupz
                        if player.Backpack:FindFirstChild("Ice-Fruit Cupz") and player.Character and player.Character:FindFirstChild("Humanoid") then
                            player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChild("Ice-Fruit Cupz"))
                        end
                        
                        -- Teleport back to cooking area
                        teleportTo(cookingpot.Position + Vector3.new(0, 3, 0))
                        
                        -- Use the prompt again
                        for i = 1, 10 do
                            task.wait(0.1)
                            
                            -- Setup for instant prompts
                            if prompt then
                                prompt.HoldDuration = 0
                                prompt.RequiresLineOfSight = false
                                prompt.Enabled = true
                            end
                            
                            if Camera and prompt and prompt.Parent then
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, prompt.Parent.Position)
                            end
                            pcall(function()
                                fireproximityprompt(prompt)
                            end)
                        end
                        
                        -- Verify cooked item
                        local hasCookedItem = false
                        if player.Character and player.Character:FindFirstChild("Ice-Fruit Cupz") then
                            hasCookedItem = true
                        elseif player.Backpack:FindFirstChild("Ice-Fruit Cupz") then
                            pcall(function()
                                player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChild("Ice-Fruit Cupz"))
                            end)
                            task.wait(0.5)
                            hasCookedItem = player.Character:FindFirstChild("Ice-Fruit Cupz") ~= nil
                        end
                        
                        if not hasCookedItem then
                            Notify("Failed to obtain cooked item!", 3)
                            return
                        end
                        
                        -- Selling process
                        Notify("Starting selling (1000x)...", 2)
                        local instance = refill:FindFirstChild("ProximityPrompt")
                        
                        if instance then
                            teleportTo(refill.Position)
                            
                            if Camera and instance and instance.Parent then
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, instance.Parent.Position)
                            end
                            
                            task.wait(2)
                            
                            -- Verify Ice-Fruit Cupz is equipped
                            if not (player.Character and player.Character:FindFirstChild("Ice-Fruit Cupz")) then
                                if player.Backpack:FindFirstChild("Ice-Fruit Cupz") then
                                    player.Character.Humanoid:EquipTool(player.Backpack:FindFirstChild("Ice-Fruit Cupz"))
                                    task.wait(0.5)
                                else
                                    Notify("Ice-Fruit Cupz not found!", 3)
                                    return
                                end
                            end
                            
                            -- Selling loop - 1000 times
                            local lastMoney = player:FindFirstChild("stored") and player.stored:FindFirstChild("FilthyStack") and player.stored.FilthyStack.Value or 0
                            
                            for i = 1, 1000 do
                                task.spawn(function()
                                    pcall(function()
                                        if instance then
                                            -- Setup for instant prompts
                                            instance.HoldDuration = 0
                                            instance.RequiresLineOfSight = false
                                            instance.Enabled = true
                                            
                                            if Camera and instance and instance.Parent then
                                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, instance.Parent.Position)
                                            end
                                            fireproximityprompt(instance)
                                        end
                                    end)
                                end)
                                
                                local currentMoney = player:FindFirstChild("stored") and player.stored:FindFirstChild("FilthyStack") and player.stored.FilthyStack.Value or 0
                                
                                if currentMoney > lastMoney then
                                    if i % 100 == 0 then
                                        Notify("Progress: " .. i .. "/1000", 1)
                                    end
                                    lastMoney = currentMoney
                                end
                            end
                            
                            Notify("INF MONEY Complete!", 3)
                        else
                            Notify("Selling prompt not found!", 3)
                        end
                    else
                        Notify("Cooking failed to start!", 3)
                    end
                else
                    Notify("Prompt not enabled!", 3)
                end
            end
        end)
    end
})

local KillAuraSection = CombatTab:CreateSection({
    Name = "Kill Aura",
    Side = "Left"
})

-- Get closest player to mouse
local function getcp()
    local mouse = LocalPlayer:GetMouse()
    local hit = mouse.Hit.Position
    local maxdis = math.huge
    local target = nil
    for i, v in next, Players:GetChildren() do
        if v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v ~= LocalPlayer then
            local mag = (hit - v.Character.HumanoidRootPart.Position).Magnitude
            if mag < maxdis then
                maxdis = mag
                target = v
            end
        end
    end
    return target
end

spawn(function()
    RunService.RenderStepped:Connect(function()
        local currentTarget = getcp()
        if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
            getgenv().killauratarget = currentTarget
        end
    end)
end)

getgenv().killauratarget = nil
getgenv().auraenabled = false
getgenv().killaurbeam = false
getgenv().rainbowbeam = false
getgenv().beamcolor = Color3.fromRGB(255, 255, 255)
getgenv().hitpart = "Head"
getgenv().damage = 50
getgenv().cooldown = 0.1

local function randomRGB()
    return Color3.fromRGB(
        math.random(0, 255),
        math.random(0, 255),
        math.random(0, 255)
    )
end

local function dmg(target, hpart, damage)
    pcall(function()
        ReplicatedStorage.InflictTarget:FireServer(
            LocalPlayer.Character:FindFirstChildWhichIsA("Tool"),
            LocalPlayer,
            target.Character.Humanoid,
            target.Character[hpart],
            damage,
            {0, 0, false, false,
                LocalPlayer.Character:FindFirstChildWhichIsA("Tool").GunScript_Server.IgniteScript,
                LocalPlayer.Character:FindFirstChildWhichIsA("Tool").GunScript_Server.IcifyScript,
                100, 100},
            {false, 5, 3},
            target.Character[hpart],
            {false, {1930359546}, 1, 1.5, 1},
            nil,
            nil,
            true
        )
    end)
end

KillAuraSection:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(state)
        getgenv().auraenabled = state
        while getgenv().auraenabled and task.wait(getgenv().cooldown) do
            task.wait()
            pcall(function()
                local target = getgenv().killauratarget
                if target and target.Character then
                    -- Show beam if enabled
                    if getgenv().killaurbeam then
                        local succ, err = pcall(function()
                            if LocalPlayer.Character:FindFirstChildWhichIsA("Tool") and
                                LocalPlayer.Character:FindFirstChildOfClass("Tool"):FindFirstChild("GunScript_Local") then
                                local plr = LocalPlayer
                                local part = Instance.new("Part", Workspace)
                                part.Size = Vector3.new(0.2, 0.2,
                                    (plr.Character.HumanoidRootPart.Position - target.Character.Head.Position).Magnitude)
                                part.Anchored = true
                                part.CanCollide = false
                                
                                if getgenv().rainbowbeam then
                                    part.Color = randomRGB()
                                else
                                    part.Color = getgenv().beamcolor
                                end
                                
                                part.Material = Enum.Material.Neon
                                local toolHandle = plr.Character:FindFirstChildWhichIsA("Tool"):FindFirstChild("Handle")
                                if toolHandle then
                                    local midpoint = (toolHandle.Position + target.Character[getgenv().hitpart].Position) / 2
                                    part.Position = midpoint
                                    part.CFrame = CFrame.new(midpoint, target.Character[getgenv().hitpart].Position)
                                end
                                task.wait(0.1)
                                part:Destroy()
                            end
                        end)
                    end
                    
                    -- Deal damage
                    dmg(target, getgenv().hitpart, getgenv().damage)
                end
            end)
        end
    end
})

KillAuraSection:AddToggle({
    Name = "Show Beam",
    Default = false,
    Callback = function(state)
        getgenv().killaurbeam = state
    end
})

KillAuraSection:AddToggle({
    Name = "Rainbow Beam",
    Default = false,
    Callback = function(state)
        getgenv().rainbowbeam = state
    end
})

KillAuraSection:AddSlider({
    Name = "Damage Amount",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(value)
        getgenv().damage = value
    end
})

KillAuraSection:AddSlider({
    Name = "Attack Speed",
    Min = 0,
    Max = 1,
    Default = 0.1,
    Callback = function(value)
        getgenv().cooldown = value
    end
})

KillAuraSection:AddDropdown({
    Name = "Target Part",
    Items = {"Head", "HumanoidRootPart", "UpperTorso"},
    Default = "Head",
    Callback = function(Value)
        getgenv().hitpart = Value
    end
})

-- Rainbow Gun in Combat tab
KillAuraSection:AddToggle({
    Name = "Rainbow Gun Color",
    Default = false,
    Callback = function(Value)
        getgenv().RainbowGunEnabled = Value
        if Value then
            task.spawn(function()
                while getgenv().RainbowGunEnabled do
                    local character = LocalPlayer.Character
                    if character then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then
                            for _, part in ipairs(tool:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    local hue = (tick() % 12) / 12
                                    part.Color = Color3.fromHSV(hue, 1, 1)
                                    part.Material = Enum.Material.Neon
                                end
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
})

-- Kill All Button
KillAuraSection:AddButton({
    Name = "Kill All Players",
    Callback = function()
        local function checkgun()
            local gunTool = nil

            for _, v in pairs(LocalPlayer.Backpack:GetDescendants()) do
                if v:IsA("LocalScript") and v.Name == "GunScript_Local" then
                    gunTool = v.Parent
                    break
                end
            end

            if not gunTool and LocalPlayer.Character then
                for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("LocalScript") and v.Name == "GunScript_Local" then
                        gunTool = v.Parent
                        break
                    end
                end
            end

            if gunTool and gunTool:IsA("Tool") then
                LocalPlayer.Character:WaitForChild("Humanoid"):EquipTool(gunTool)
            end

            return gunTool
        end

        local gun = checkgun()
        if not gun then
            Notify("Gun not found!", 2)
            return
        end

        local duration = 5 
        local startTime = tick()

        while tick() - startTime < duration do
            -- Fire the gun remotes for visual effect
            local fireRemote = gun:FindFirstChild("Fire") or gun:FindFirstChild("Shoot") or gun:FindFirstChild("Remote")
            if fireRemote and fireRemote:IsA("RemoteEvent") then
                fireRemote:FireServer()
            elseif fireRemote and fireRemote:IsA("RemoteFunction") then
                fireRemote:InvokeServer()
            elseif gun.Activate then
                gun:Activate()
            end

            -- Fire muzzle effect
            local handle = gun:FindFirstChild("Handle")
            local muzzleEffect = gun:FindFirstChild("GunScript_Local") and gun.GunScript_Local:FindFirstChild("MuzzleEffect")
            if handle and muzzleEffect and ReplicatedStorage:FindFirstChild("VisualizeMuzzle") then
                ReplicatedStorage.VisualizeMuzzle:FireServer(
                    handle,
                    true,
                    {false, 7, Color3.new(1, 1.1098, 0), 15, true, 0.02},
                    muzzleEffect
                )
            end

            -- Damage all players
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer then
                    local char = v.Character
                    if char and char:FindFirstChild("Head") and char:FindFirstChild("Humanoid") then
                        dmg(v, "Head", 1000)
                    end
                end
            end
            task.wait(0.1) 
        end

        Notify("Killed all players for 5 seconds!", 2)
    end
})


local function GetWorkingSafe()
    local Safe
    for Index, Value in pairs(Workspace:FindFirstChild("1# Map") and Workspace["1# Map"]:FindFirstChild("2 Crosswalks") and Workspace["1# Map"]["2 Crosswalks"]:FindFirstChild("Safes") and Workspace["1# Map"]["2 Crosswalks"].Safes:GetChildren() or {}) do
        if Value:IsA("Model") and Value.Name == "Safe" then
            if Value:FindFirstChild("ChestClicker") then
                Safe = Value
                break
            end
        end
    end
    return Safe
end

local SafeSelectedSection = SafeTab:CreateSection({
    Name = "Store Items in Safe",
    Side = "Left"
})
local storeButtons = {}
local lastStoreItems = {}

local function updateStoreButtons()
    -- Get current items
    local currentItems = {}
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            currentItems[item.Name] = true
        end
    end
    
    -- Check if items changed
    local itemsChanged = false
    for name, _ in pairs(currentItems) do
        if not lastStoreItems[name] then
            itemsChanged = true
            break
        end
    end
    for name, _ in pairs(lastStoreItems) do
        if not currentItems[name] then
            itemsChanged = true
            break
        end
    end
    
    -- Only update if items changed
    if not itemsChanged then
        return
    end
    
    -- Clear old buttons
    for _, btn in pairs(storeButtons) do
        pcall(function()
            if btn then
                btn:Destroy()
            end
        end)
    end
    storeButtons = {}
    lastStoreItems = currentItems
    
    -- Create new buttons
    for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local btn = SafeSelectedSection:AddButton({
                Name = "Store: " .. item.Name,
                Callback = function()
                    task.spawn(function()
                        local Safe = GetWorkingSafe()
                        if not Safe then
                            Notify("No working safe found!", 2)
                            return
                        end
                        
                        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            Notify("Character not found!", 2)
                            return
                        end
                        
                        local OldCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                        teleportTo(Safe.ChestClicker.CFrame)
                        
                        if LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid:UnequipTools()
                        end
                        
                        task.wait(0.5)
                        
                        if ReplicatedStorage:FindFirstChild("Inventory") then
                            ReplicatedStorage.Inventory:FireServer("Change", item.Name, "Backpack", Safe)
                        end
                        
                        task.wait(1)
                        teleportTo(OldCFrame)
                        
                        Notify("Stored " .. item.Name .. " in safe!", 2)
                    end)
                end
            })
            table.insert(storeButtons, btn)
        end
    end
end

-- Auto refresh every 1 second
task.spawn(function()
    while task.wait(1) do
        updateStoreButtons()
    end
end)

local TakeSelectedSection = SafeTab:CreateSection({
    Name = "Take Items from Safe",
    Side = "Right"
})
local takeButtons = {}
local lastTakeItems = {}

local function updateTakeButtons()
    -- Get current items in safe
    local currentItems = {}
    if LocalPlayer:FindFirstChild("InvData") then
        for _, item in pairs(LocalPlayer.InvData:GetChildren()) do
            currentItems[item.Name] = true
        end
    end
    
    -- Check if items changed
    local itemsChanged = false
    for name, _ in pairs(currentItems) do
        if not lastTakeItems[name] then
            itemsChanged = true
            break
        end
    end
    for name, _ in pairs(lastTakeItems) do
        if not currentItems[name] then
            itemsChanged = true
            break
        end
    end
    
    -- Only update if items changed
    if not itemsChanged then
        return
    end
    
    -- Clear old buttons
    for _, btn in pairs(takeButtons) do
        pcall(function()
            if btn then
                btn:Destroy()
            end
        end)
    end
    takeButtons = {}
    lastTakeItems = currentItems
    
    -- Create new buttons
    if LocalPlayer:FindFirstChild("InvData") then
        for _, item in pairs(LocalPlayer.InvData:GetChildren()) do
            local btn = TakeSelectedSection:AddButton({
                Name = "Take: " .. item.Name,
                Callback = function()
                    task.spawn(function()
                        local Safe = GetWorkingSafe()
                        if not Safe then
                            Notify("No working safe found!", 2)
                            return
                        end
                        
                        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            Notify("Character not found!", 2)
                            return
                        end
                        
                        local OldCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                        teleportTo(Safe.ChestClicker.CFrame)
                        
                        task.wait(0.5)
                        
                        if ReplicatedStorage:FindFirstChild("Inventory") then
                            ReplicatedStorage.Inventory:FireServer("Change", item.Name, "Inv", Safe)
                        end
                        
                        task.wait(1)
                        teleportTo(OldCFrame)
                        
                        Notify("Took " .. item.Name .. " from safe!", 2)
                    end)
                end
            })
            table.insert(takeButtons, btn)
        end
    end
end

-- Auto refresh every 1 second
task.spawn(function()
    while task.wait(1) do
        updateTakeButtons()
    end
end)


-- ESP from valley.lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))()
ESP.Enabled = false
ESP.ShowBox = false
ESP.BoxType = "Corner Box Esp"
ESP.ShowName = false
ESP.ShowHealth = false
ESP.ShowTracer = false
ESP.ShowDistance = false
ESP.ShowSkeletons = false

-- ESP Settings from valley.lua
local ESPSection = VisualsTab:CreateSection({
    Name = "ESP Settings",
    Side = "Left"
})

ESPSection:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        ESP.Enabled = Value
    end
})

ESPSection:AddToggle({
    Name = "Box ESP",
    Default = false,
    Callback = function(Value)
        ESP.ShowBox = Value
    end
})

ESPSection:AddToggle({
    Name = "Health ESP",
    Default = false,
    Callback = function(Value)
        ESP.ShowHealth = Value
    end
})

ESPSection:AddToggle({
    Name = "Name ESP",
    Default = false,
    Callback = function(Value)
        ESP.ShowName = Value
    end
})

ESPSection:AddToggle({
    Name = "Distance ESP",
    Default = false,
    Callback = function(Value)
        ESP.ShowDistance = Value
    end
})

ESPSection:AddToggle({
    Name = "Tracer ESP",
    Default = false,
    Callback = function(Value)
        ESP.ShowTracer = Value
    end
})

local WorldESP = VisualsTab:CreateSection({
    Name = "World Visuals",
    Side = "Right"
})

WorldESP:AddToggle({
    Name = "Remove Fog",
    Default = false,
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        if Value then
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = 1000
        end
    end
})

WorldESP:AddToggle({
    Name = "Rainbow Fog",
    Default = false,
    Callback = function(Value)
        getgenv().RainbowFogEnabled = Value
        if Value then
            task.spawn(function()
                while getgenv().RainbowFogEnabled do
                    local Lighting = game:GetService("Lighting")
                    local hue = (tick() % 12) / 12
                    Lighting.FogColor = Color3.fromHSV(hue, 0.5, 1)
                    task.wait(0.05)
                end
            end)
        end
    end
})

WorldESP:AddToggle({
    Name = "Fullbright",
    Default = false,
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        end
    end
})

WorldESP:AddToggle({
    Name = "Fullbright",
    Default = false,
    Callback = function(Value)
        local Lighting = game:GetService("Lighting")
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        end
    end
})

WorldESP:AddSlider({
    Name = "Time of Day",
    Min = 0,
    Max = 24,
    Default = 12,
    Callback = function(Value)
        game:GetService("Lighting"):SetMinutesAfterMidnight(Value * 60)
    end
})

local FOVSection = VisualsTab:CreateSection({
    Name = "FOV Circle",
    Side = "Right"
})

local fovCircle
FOVSection:AddToggle({
    Name = "Show FOV Circle",
    Default = false,
    Callback = function(Value)
        if Value then
            if not fovCircle then
                local Drawing = Drawing or {} 
                if Drawing.new then
                    fovCircle = Drawing.new("Circle")
                    fovCircle.Thickness = 2
                    fovCircle.NumSides = 100
                    fovCircle.Radius = 150
                    fovCircle.Filled = false
                    fovCircle.Visible = true
                    fovCircle.ZIndex = 999
                    fovCircle.Transparency = 1
                    fovCircle.Color = Color3.fromRGB(255, 255, 255)
                    
                    RunService.RenderStepped:Connect(function()
                        if fovCircle and fovCircle.Visible then
                            local camera = workspace.CurrentCamera
                            fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                        end
                    end)
                end
            else
                fovCircle.Visible = true
            end
        else
            if fovCircle then
                fovCircle.Visible = false
            end
        end
    end
})

FOVSection:AddSlider({
    Name = "FOV Size",
    Default = 150,
    Min = 50,
    Max = 500,
    Suffix = "px",
    Callback = function(Value)
        if fovCircle then
            fovCircle.Radius = Value
        end
    end
})

local FistModsSection = CombatTab:CreateSection({
    Name = "Fist Modifications",
    Side = "Right"
})

FistModsSection:AddToggle({
    Name = "Anti Cooldown Swing",
    Default = false,
    Callback = function(Value)
        pcall(function()
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Melee_Settings") then
                local settings = require(tool.Melee_Settings)
                settings.SwingCooldown = Value and 0 or nil
            end
        end)
    end
})

FistModsSection:AddToggle({
    Name = "Anti Cooldown Stomp",
    Default = false,
    Callback = function(Value)
        pcall(function()
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Melee_Settings") then
                local settings = require(tool.Melee_Settings)
                settings.StompCooldown = Value and 0 or nil
            end
        end)
    end
})

FistModsSection:AddToggle({
    Name = "Anti Cooldown Attack",
    Default = false,
    Callback = function(Value)
        pcall(function()
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Melee_Settings") then
                local settings = require(tool.Melee_Settings)
                settings.AttackCooldown = Value and 0 or nil
            end
        end)
    end
})

local WeaponModsSection = CombatTab:CreateSection({
    Name = "Weapon Modifications",
    Side = "Right"
})

-- Weapon mod global settings
getgenv().OneTapEnabled = false
getgenv().InfiniteAmmoEnabled = false
getgenv().InfiniteMagEnabled = false
getgenv().InfiniteRangeEnabled = false
getgenv().FullyAutoEnabled = false
getgenv().DisableJammingEnabled = false
getgenv().DisableRecoilEnabled = false
getgenv().SniperModeEnabled = false
getgenv().AutoReloadEnabled = false

-- Apply weapon mods to equipped tool
local function applyWeaponMods()
    task.spawn(function()
        while task.wait(0.1) do
            pcall(function()
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Setting") then
                    local setting = require(tool.Setting)
                    
                    if getgenv().OneTapEnabled then
                        setting.BaseDamage = 9e9
                    end
                    
                    if getgenv().InfiniteAmmoEnabled then
                        setting.LimitedAmmoEnabled = false
                        setting.MaxAmmo = 100000000
                        setting.AmmoPerMag = 10000000
                        setting.Ammo = 100000000
                    end
                    
                    if getgenv().InfiniteMagEnabled then
                        setting.AmmoPerMag = 1000000000
                    end
                    
                    if getgenv().InfiniteRangeEnabled then
                        setting.Range = 9e9
                    end
                    
                    if getgenv().FullyAutoEnabled then
                        setting.Auto = true
                    end
                    
                    if getgenv().DisableJammingEnabled then
                        setting.JamChance = 0
                    end
                    
                    if getgenv().SniperModeEnabled then
                        setting.SniperEnabled = true
                    end
                    
                    if getgenv().AutoReloadEnabled then
                        setting.AutoReload = true
                    end
                end
                
                -- Check for Settings (recoil)
                if tool and tool:FindFirstChild("Settings") then
                    local settings = require(tool.Settings)
                    if getgenv().DisableRecoilEnabled then
                        settings.Recoil = 0
                    end
                end
            end)
        end
    end)
end

applyWeaponMods()

WeaponModsSection:AddToggle({
    Name = "1 Tap",
    Default = false,
    Callback = function(Value)
        getgenv().OneTapEnabled = Value
    end
})

WeaponModsSection:AddToggle({
    Name = "Infinite Ammo",
    Default = false,
    Callback = function(Value)
        getgenv().InfiniteAmmoEnabled = Value
    end
})

WeaponModsSection:AddToggle({
    Name = "Infinite Mag",
    Default = false,
    Callback = function(Value)
        getgenv().InfiniteMagEnabled = Value
    end
})

WeaponModsSection:AddToggle({
    Name = "Infinite Range",
    Default = false,
    Callback = function(Value)
        getgenv().InfiniteRangeEnabled = Value
    end
})

WeaponModsSection:AddToggle({
    Name = "Fully Automatic",
    Default = false,
    Callback = function(Value)
        getgenv().FullyAutoEnabled = Value
    end
})

WeaponModsSection:AddToggle({
    Name = "Disable Jamming",
    Default = false,
    Callback = function(Value)
        getgenv().DisableJammingEnabled = Value
    end
})

WeaponModsSection:AddToggle({
    Name = "Disable Recoil",
    Default = false,
    Callback = function(Value)
        getgenv().DisableRecoilEnabled = Value
    end
})

WeaponModsSection:AddToggle({
    Name = "Enable Sniper Mode",
    Default = false,
    Callback = function(Value)
        getgenv().SniperModeEnabled = Value
    end
})

WeaponModsSection:AddToggle({
    Name = "Enable Auto Reload",
    Default = false,
    Callback = function(Value)
        getgenv().AutoReloadEnabled = Value
    end
})
local HitboxSection = CombatTab:CreateSection({
    Name = "Hitbox Expander",
    Side = "Left"
})

getgenv().HitboxEnabled = false
getgenv().HitboxSize = 10
getgenv().HitboxPart = "Head"

local function expandHitboxes()
    while getgenv().HitboxEnabled do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hitboxPart = player.Character:FindFirstChild(getgenv().HitboxPart)
                if hitboxPart and hitboxPart:IsA("BasePart") then
                    hitboxPart.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                    hitboxPart.Transparency = 0.5
                    hitboxPart.Color = Color3.fromRGB(255, 215, 0) -- Gold color for visibility
                    hitboxPart.Material = Enum.Material.Neon
                    hitboxPart.CanCollide = false
                end
            end
        end
        task.wait(0.1)
    end
end

HitboxSection:AddToggle({
    Name = "Enable Hitbox Expander",
    Default = false,
    Callback = function(Value)
        getgenv().HitboxEnabled = Value
        if Value then
            task.spawn(expandHitboxes)
        else
            -- Reset hitboxes
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local hitboxPart = player.Character:FindFirstChild(getgenv().HitboxPart)
                    if hitboxPart and hitboxPart:IsA("BasePart") then
                        hitboxPart.Transparency = 0
                        hitboxPart.Material = Enum.Material.Plastic
                    end
                end
            end
        end
    end
})

HitboxSection:AddSlider({
    Name = "Hitbox Size",
    Default = 10,
    Min = 5,
    Max = 50,
    Suffix = "",
    Callback = function(Value)
        getgenv().HitboxSize = Value
    end
})

HitboxSection:AddDropdown({
    Name = "Hitbox Target",
    Items = {"Head", "UpperTorso", "LowerTorso", "HumanoidRootPart", "LeftUpperLeg", "RightUpperLeg"},
    Default = "Head",
    Callback = function(Value)
        getgenv().HitboxPart = Value
    end
})

-- Notification
Notify("Script loaded successfully!", 3)

print("Valley script loaded successfully!")
