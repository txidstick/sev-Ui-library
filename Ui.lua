-- Sev UI Library
-- Premium black theme with clean design
-- Created by: Sev | Version 3.0

local ModernUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local GuiInset, _ = GuiService:GetGuiInset()
GuiInset = GuiInset.Y - 20

-- Utility Functions
local function Tween(instance, properties, duration, style, direction)
    duration = duration or 0.3
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function Ripple(button, x, y)
    spawn(function()
        local ripple = Instance.new("ImageLabel")
        ripple.Name = "Ripple"
        ripple.BackgroundTransparency = 1
        ripple.Image = "rbxassetid://2708891598"
        ripple.ImageTransparency = 0.5
        ripple.ScaleType = Enum.ScaleType.Fit
        ripple.ZIndex = button.ZIndex + 1
        ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Parent = button
        
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        Tween(ripple, {Size = UDim2.new(0, size, 0, size), ImageTransparency = 1}, 0.5)
        
        task.wait(0.5)
        ripple:Destroy()
    end)
end

local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput, mousePos, framePos
    
    dragHandle = dragHandle or frame
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mousePos
            Tween(frame, {
                Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            }, 0.1, Enum.EasingStyle.Linear)
        end
    end)
end

-- Notification System
local NotificationHolder = nil

function ModernUI.Notify(options)
    options = options or {}
    local Title = options.Title or "Notification"
    local Content = options.Content or ""
    local Duration = options.Duration or 3
    local Icon = options.Icon or ""
    
    if not NotificationHolder then
        -- Create notification holder if it doesn't exist
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "ModernUINotifications"
        notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        notifGui.ResetOnSpawn = false
        
        if syn and syn.protect_gui then
            syn.protect_gui(notifGui)
            notifGui.Parent = CoreGui
        elseif gethui then
            notifGui.Parent = gethui()
        else
            notifGui.Parent = CoreGui
        end
        
        NotificationHolder = Instance.new("Frame")
        NotificationHolder.Name = "NotificationHolder"
        NotificationHolder.Size = UDim2.new(0, 300, 1, -40)
        NotificationHolder.Position = UDim2.new(1, -320, 0, 20)
        NotificationHolder.BackgroundTransparency = 1
        NotificationHolder.Parent = notifGui
        
        local NotifLayout = Instance.new("UIListLayout")
        NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
        NotifLayout.Padding = UDim.new(0, 10)
        NotifLayout.Parent = NotificationHolder
    end
    
    -- Create notification
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(1, 0, 0, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(27, 29, 33)
    Notification.BorderSizePixel = 0
    Notification.ClipsDescendants = true
    Notification.Parent = NotificationHolder
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 8)
    NotifCorner.Parent = Notification
    
    local NotifStroke = Instance.new("UIStroke")
    NotifStroke.Color = Color3.fromRGB(65, 69, 77)
    NotifStroke.Thickness = 1
    NotifStroke.Transparency = 0.6
    NotifStroke.Parent = Notification
    
    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -20, 0, 20)
    NotifTitle.Position = UDim2.new(0, 10, 0, 8)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = Title
    NotifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifTitle.TextSize = 14
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.TextTransparency = 1
    NotifTitle.Parent = Notification
    
    local NotifContent = Instance.new("TextLabel")
    NotifContent.Size = UDim2.new(1, -20, 0, 40)
    NotifContent.Position = UDim2.new(0, 10, 0, 30)
    NotifContent.BackgroundTransparency = 1
    NotifContent.Text = Content
    NotifContent.TextColor3 = Color3.fromRGB(165, 165, 165)
    NotifContent.TextSize = 12
    NotifContent.Font = Enum.Font.Gotham
    NotifContent.TextXAlignment = Enum.TextXAlignment.Left
    NotifContent.TextYAlignment = Enum.TextYAlignment.Top
    NotifContent.TextWrapped = true
    NotifContent.TextTransparency = 1
    NotifContent.Parent = Notification
    
    -- Animate in
    Tween(Notification, {Size = UDim2.new(1, 0, 0, 80)}, 0.3, Enum.EasingStyle.Back)
    task.wait(0.1)
    Tween(NotifTitle, {TextTransparency = 0}, 0.2)
    Tween(NotifContent, {TextTransparency = 0}, 0.2)
    
    -- Auto dismiss
    task.delay(Duration, function()
        Tween(NotifTitle, {TextTransparency = 1}, 0.2)
        Tween(NotifContent, {TextTransparency = 1}, 0.2)
        task.wait(0.2)
        Tween(Notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        Notification:Destroy()
    end)
end

-- Main Library Functions
function ModernUI.CreateWindow(options)
    options = options or {}
    local WindowName = options.Name or "Sev UI"
    local WindowIcon = options.Icon or "rbxassetid://7733955511"
    
    -- Device detection and responsive sizing
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local isTablet = UserInputService.TouchEnabled and UserInputService.KeyboardEnabled
    local ViewportSize = Camera.ViewportSize
    
    local defaultWidth, defaultHeight
    if isMobile then
        -- Phone sizing
        defaultWidth = math.min(ViewportSize.X - 20, 700)
        defaultHeight = math.min(ViewportSize.Y - GuiInset - 40, 500)
    elseif isTablet then
        -- Tablet sizing
        defaultWidth = math.min(ViewportSize.X - 40, 1400)
        defaultHeight = math.min(ViewportSize.Y - GuiInset - 60, 550)
    else
        -- PC sizing
        defaultWidth = 2000
        defaultHeight = 550
    end
    
    local WindowSize = options.Size or {Width = defaultWidth, Height = defaultHeight}
    local Theme = options.Theme or {
        Primary = Color3.fromRGB(27, 29, 33),
        Secondary = Color3.fromRGB(33, 34, 38),
        Accent = Color3.fromRGB(80, 80, 80),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(165, 165, 165),
        Background = Color3.fromRGB(23, 25, 29),
        Border = Color3.fromRGB(65, 69, 77)
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SevUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = CoreGui
    end
    
    -- Main Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, WindowSize.Width, 0, WindowSize.Height)
    MainFrame.Position = UDim2.new(0.5, -WindowSize.Width/2, 0.5, -WindowSize.Height/2)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.3
    MainStroke.Parent = MainFrame
    
    -- Drop Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = MainFrame
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Theme.Primary
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 12)
    TopBarCorner.Parent = TopBar
    
    local TopBarBottom = Instance.new("Frame")
    TopBarBottom.Size = UDim2.new(1, 0, 0, 12)
    TopBarBottom.Position = UDim2.new(0, 0, 1, -12)
    TopBarBottom.BackgroundColor3 = Theme.Primary
    TopBarBottom.BorderSizePixel = 0
    TopBarBottom.Parent = TopBar
    
    -- Icon
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Size = UDim2.new(0, 30, 0, 30)
    Icon.Position = UDim2.new(0, 15, 0.5, -15)
    Icon.BackgroundTransparency = 1
    Icon.Image = WindowIcon
    Icon.ImageColor3 = Theme.Accent
    Icon.Parent = TopBar
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Position = UDim2.new(0, 55, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = WindowName
    Title.TextColor3 = Theme.Text
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Window Control Buttons Container
    local ControlsContainer = Instance.new("Frame")
    ControlsContainer.Name = "Controls"
    ControlsContainer.Size = UDim2.new(0, 90, 0, 26)
    ControlsContainer.Position = UDim2.new(1, -98, 0.5, -13)
    ControlsContainer.BackgroundTransparency = 1
    ControlsContainer.Parent = TopBar
    
    local ControlsLayout = Instance.new("UIListLayout")
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ControlsLayout.Padding = UDim.new(0, 4)
    ControlsLayout.Parent = ControlsContainer
    
    -- Minimize Button (blank circle)
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Minimize"
    MinimizeButton.Size = UDim2.new(0, 12, 0, 12)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    MinimizeButton.Text = ""
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.LayoutOrder = 1
    MinimizeButton.Parent = ControlsContainer
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(1, 0)
    MinimizeCorner.Parent = MinimizeButton
    
    -- Maximize Button (blank circle)
    local MaximizeButton = Instance.new("TextButton")
    MaximizeButton.Name = "Maximize"
    MaximizeButton.Size = UDim2.new(0, 12, 0, 12)
    MaximizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    MaximizeButton.Text = ""
    MaximizeButton.BorderSizePixel = 0
    MaximizeButton.AutoButtonColor = false
    MaximizeButton.LayoutOrder = 2
    MaximizeButton.Parent = ControlsContainer
    
    local MaximizeCorner = Instance.new("UICorner")
    MaximizeCorner.CornerRadius = UDim.new(1, 0)
    MaximizeCorner.Parent = MaximizeButton
    
    -- Close Button (blank circle)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 12, 0, 12)
    CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    CloseButton.Text = ""
    CloseButton.BorderSizePixel = 0
    CloseButton.AutoButtonColor = false
    CloseButton.LayoutOrder = 3
    CloseButton.Parent = ControlsContainer
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseButton
    
    -- Window state tracking
    local Minimized = false
    local Maximized = false
    local oldSize = MainFrame.Size
    local oldPosition = MainFrame.Position
    
    -- Minimize Button Functions
    MinimizeButton.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        if Minimized then
            Tween(MainFrame, {Position = UDim2.new(0.5, -WindowSize.Width/2, 1.5, 0)}, 0.3)
        else
            if Maximized then
                Tween(MainFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
            else
                Tween(MainFrame, {Position = UDim2.new(0.5, -WindowSize.Width/2, 0.5, -WindowSize.Height/2)}, 0.3)
            end
        end
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}, 0.2)
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, 0.2)
    end)
    
    -- Maximize Button Functions
    MaximizeButton.MouseButton1Click:Connect(function()
        Maximized = not Maximized
        if Maximized then
            oldSize = MainFrame.Size
            oldPosition = MainFrame.Position
            Tween(MainFrame, {Size = UDim2.new(1, -4, 1, -4)}, 0.3)
            Tween(MainFrame, {Position = UDim2.new(0, 2, 0, 2)}, 0.3)
        else
            Tween(MainFrame, {Size = oldSize}, 0.3)
            Tween(MainFrame, {Position = oldPosition}, 0.3)
        end
    end)
    
    MaximizeButton.MouseEnter:Connect(function()
        Tween(MaximizeButton, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}, 0.2)
    end)
    
    MaximizeButton.MouseLeave:Connect(function()
        Tween(MaximizeButton, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, 0.2)
    end)
    
    -- Close Button Functions
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(200, 50, 60)}, 0.2)
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}, 0.2)
    end)
    
    -- Mobile Toggle Button (Left side of screen, middle height)
    local MobileToggle = Instance.new("TextButton")
    MobileToggle.Name = "MobileToggle"
    MobileToggle.Size = UDim2.new(0, 50, 0, 50)
    MobileToggle.Position = UDim2.new(0, 10, 0.5, -25)
    MobileToggle.AnchorPoint = Vector2.new(0, 0.5)
    MobileToggle.BackgroundColor3 = Color3.fromRGB(27, 29, 33)
    MobileToggle.Text = ""
    MobileToggle.BorderSizePixel = 0
    MobileToggle.AutoButtonColor = false
    MobileToggle.ZIndex = 10
    MobileToggle.Visible = true  -- Always show for easy access
    MobileToggle.Parent = ScreenGui
    
    local MobileToggleCorner = Instance.new("UICorner")
    MobileToggleCorner.CornerRadius = UDim.new(0, 10)
    MobileToggleCorner.Parent = MobileToggle
    
    local MobileToggleStroke = Instance.new("UIStroke")
    MobileToggleStroke.Color = Color3.fromRGB(65, 69, 77)
    MobileToggleStroke.Thickness = 2
    MobileToggleStroke.Parent = MobileToggle
    
    local MobileToggleIcon = Instance.new("TextLabel")
    MobileToggleIcon.Size = UDim2.new(1, 0, 1, 0)
    MobileToggleIcon.BackgroundTransparency = 1
    MobileToggleIcon.Text = "◀"
    MobileToggleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    MobileToggleIcon.TextSize = 20
    MobileToggleIcon.Font = Enum.Font.GothamBold
    MobileToggleIcon.Parent = MobileToggle
    
    -- Mobile toggle function - single tap to toggle
    local function toggleWindowMobile()
        Minimized = not Minimized
        if Minimized then
            Tween(MainFrame, {Position = UDim2.new(0.5, -WindowSize.Width/2, 1.5, 0)}, 0.3)
            MobileToggleIcon.Text = "▶"
        else
            if Maximized then
                Tween(MainFrame, {Position = UDim2.new(0, 2, 0, 2)}, 0.3)
            else
                Tween(MainFrame, {Position = UDim2.new(0.5, -WindowSize.Width/2, 0.5, -WindowSize.Height/2)}, 0.3)
            end
            MobileToggleIcon.Text = "◀"
        end
    end
    
    -- Single tap/click support
    local toggleDebounce = false
    MobileToggle.MouseButton1Click:Connect(function()
        if not toggleDebounce then
            toggleDebounce = true
            toggleWindowMobile()
            task.wait(0.5)
            toggleDebounce = false
        end
    end)
    
    MobileToggle.MouseEnter:Connect(function()
        Tween(MobileToggle, {BackgroundColor3 = Color3.fromRGB(33, 34, 38)}, 0.2)
    end)
    
    MobileToggle.MouseLeave:Connect(function()
        Tween(MobileToggle, {BackgroundColor3 = Color3.fromRGB(27, 29, 33)}, 0.2)
    end)
    
    -- Auto-resize on viewport change for responsive design
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local newViewportSize = Camera.ViewportSize
        local newWidth, newHeight
        
        if isMobile then
            newWidth = math.min(newViewportSize.X - 20, 700)
            newHeight = math.min(newViewportSize.Y - GuiInset - 40, 500)
        elseif isTablet then
            newWidth = math.min(newViewportSize.X - 40, 1400)
            newHeight = math.min(newViewportSize.Y - GuiInset - 60, 550)
        else
            -- For PC, keep the current size unless it exceeds viewport
            newWidth = math.min(MainFrame.AbsoluteSize.X, newViewportSize.X - 40)
            newHeight = math.min(MainFrame.AbsoluteSize.Y, newViewportSize.Y - GuiInset - 40)
        end
        
        if not Maximized then
            WindowSize.Width = newWidth
            WindowSize.Height = newHeight
            Tween(MainFrame, {
                Size = UDim2.new(0, newWidth, 0, newHeight),
                Position = UDim2.new(0.5, -newWidth/2, 0.5, -newHeight/2)
            }, 0.3)
        end
    end)
    
    -- Player Info Box will be added to TabContainer after it's created
    local PlayerInfo = Instance.new("Frame")
    PlayerInfo.Name = "PlayerInfo"
    PlayerInfo.Size = UDim2.new(1, 0, 0, 60)
    PlayerInfo.BackgroundColor3 = Theme.Secondary
    PlayerInfo.BorderSizePixel = 0
    PlayerInfo.LayoutOrder = 999999
    
    local PlayerInfoCorner = Instance.new("UICorner")
    PlayerInfoCorner.CornerRadius = UDim.new(0, 8)
    PlayerInfoCorner.Parent = PlayerInfo
    
    local PlayerInfoStroke = Instance.new("UIStroke")
    PlayerInfoStroke.Color = Theme.Border
    PlayerInfoStroke.Thickness = 1
    PlayerInfoStroke.Transparency = 0.6
    PlayerInfoStroke.Parent = PlayerInfo
    
    -- Avatar Image
    local PlayerAvatar = Instance.new("ImageLabel")
    PlayerAvatar.Name = "Avatar"
    PlayerAvatar.Size = UDim2.new(0, 40, 0, 40)
    PlayerAvatar.Position = UDim2.new(0, 10, 0, 10)
    PlayerAvatar.BackgroundColor3 = Theme.Secondary
    PlayerAvatar.BorderSizePixel = 0
    PlayerAvatar.Parent = PlayerInfo
    
    -- Load avatar asynchronously
    task.spawn(function()
        local success, imageUrl = pcall(function()
            return Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
        end)
        if success then
            PlayerAvatar.Image = imageUrl
        end
    end)
    
    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = PlayerAvatar
    
    -- Username Label
    local PlayerUsername = Instance.new("TextLabel")
    PlayerUsername.Name = "Username"
    PlayerUsername.Size = UDim2.new(1, -60, 0, 18)
    PlayerUsername.Position = UDim2.new(0, 55, 0, 16)
    PlayerUsername.BackgroundTransparency = 1
    PlayerUsername.Text = "@" .. LocalPlayer.Name
    PlayerUsername.TextColor3 = Theme.Text
    PlayerUsername.TextSize = 12
    PlayerUsername.Font = Enum.Font.GothamBold
    PlayerUsername.TextXAlignment = Enum.TextXAlignment.Left
    PlayerUsername.TextTruncate = Enum.TextTruncate.AtEnd
    PlayerUsername.Parent = PlayerInfo
    
    -- Display Name Label
    local PlayerDisplayName = Instance.new("TextLabel")
    PlayerDisplayName.Name = "DisplayName"
    PlayerDisplayName.Size = UDim2.new(1, -60, 0, 16)
    PlayerDisplayName.Position = UDim2.new(0, 55, 0, 36)
    PlayerDisplayName.BackgroundTransparency = 1
    PlayerDisplayName.Text = LocalPlayer.DisplayName
    PlayerDisplayName.TextColor3 = Theme.SubText
    PlayerDisplayName.TextSize = 11
    PlayerDisplayName.Font = Enum.Font.Gotham
    PlayerDisplayName.TextXAlignment = Enum.TextXAlignment.Left
    PlayerDisplayName.TextTruncate = Enum.TextTruncate.AtEnd
    PlayerDisplayName.Parent = PlayerInfo
    
    MakeDraggable(MainFrame, TopBar)
    
    -- Tab Container (Left Side)
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 180, 1, -60)
    TabContainer.Position = UDim2.new(0, 10, 0, 55)
    TabContainer.BackgroundColor3 = Theme.Primary
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 4
    TabContainer.ScrollBarImageColor3 = Theme.Accent
    TabContainer.ScrollingEnabled = true
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabContainer.Parent = MainFrame
    
    -- Add player info to tab container
    PlayerInfo.Parent = TabContainer
    
    local TabContainerStroke = Instance.new("UIStroke")
    TabContainerStroke.Color = Theme.Border
    TabContainerStroke.Thickness = 1
    TabContainerStroke.Transparency = 0.5
    TabContainerStroke.Parent = TabContainer
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 10)
    TabCorner.Parent = TabContainer
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.PaddingBottom = UDim.new(0, 75)
    TabPadding.PaddingLeft = UDim.new(0, 5)
    TabPadding.PaddingRight = UDim.new(0, 5)
    TabPadding.Parent = TabContainer
    
    -- Content Container (Right Side)
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -210, 1, -60)
    ContentContainer.Position = UDim2.new(0, 200, 0, 55)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    
    local Tabs = {}
    local CurrentTab = nil
    
    local Window = {}
    
    function Window:CreateTab(options)
        options = options or {}
        local TabName = options.Name or "Tab"
        local TabIcon = options.Icon or "rbxassetid://7733955511"
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = TabName
        TabButton.Size = UDim2.new(1, 0, 0, 45)
        TabButton.BackgroundColor3 = Theme.Secondary
        TabButton.Text = ""
        TabButton.BorderSizePixel = 0
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 8)
        TabButtonCorner.Parent = TabButton
        
                local TabButtonStroke = Instance.new("UIStroke")
        TabButtonStroke.Color = Theme.Border
        TabButtonStroke.Thickness = 1
        TabButtonStroke.Transparency = 0.7
        TabButtonStroke.Parent = TabButton
        
        local TabIconImage = Instance.new("ImageLabel")
        TabIconImage.Name = "Icon"
        TabIconImage.Size = UDim2.new(0, 24, 0, 24)
        TabIconImage.Position = UDim2.new(0, 10, 0.5, -12)
        TabIconImage.BackgroundTransparency = 1
        TabIconImage.Image = TabIcon
        TabIconImage.ImageColor3 = Theme.SubText
        TabIconImage.Parent = TabButton
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "Label"
        TabLabel.Size = UDim2.new(1, -45, 1, 0)
        TabLabel.Position = UDim2.new(0, 40, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = TabName
        TabLabel.TextColor3 = Theme.SubText
        TabLabel.TextSize = 14
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("Frame")
        TabContent.Name = TabName .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        -- Left Section
        local LeftSection = Instance.new("ScrollingFrame")
        LeftSection.Name = "LeftSection"
        LeftSection.Size = UDim2.new(0.49, 0, 1, 0)
        LeftSection.Position = UDim2.new(0, 0, 0, 0)
        LeftSection.BackgroundTransparency = 1
        LeftSection.BorderSizePixel = 0
        LeftSection.ScrollBarThickness = 4
        LeftSection.ScrollBarImageColor3 = Theme.Accent
        LeftSection.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
        LeftSection.Parent = TabContent
        
        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.Parent = LeftSection
        
        local LeftPadding = Instance.new("UIPadding")
        LeftPadding.PaddingBottom = UDim.new(0, 100)
        LeftPadding.Parent = LeftSection
        
        -- Right Section
        local RightSection = Instance.new("ScrollingFrame")
        RightSection.Name = "RightSection"
        RightSection.Size = UDim2.new(0.49, 0, 1, 0)
        RightSection.Position = UDim2.new(0.51, 0, 0, 0)
        RightSection.BackgroundTransparency = 1
        RightSection.BorderSizePixel = 0
        RightSection.ScrollBarThickness = 4
        RightSection.ScrollBarImageColor3 = Theme.Accent
        RightSection.CanvasSize = UDim2.new(0, 0, 0, 0)
        RightSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
        RightSection.Parent = TabContent
        
        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.Parent = RightSection
        
        local RightPadding = Instance.new("UIPadding")
        RightPadding.PaddingBottom = UDim.new(0, 100)
        RightPadding.Parent = RightSection
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Tabs) do
                tab.Button.BackgroundColor3 = Theme.Secondary
                tab.Icon.ImageColor3 = Theme.SubText
                tab.Label.TextColor3 = Theme.SubText
                tab.Content.Visible = false
                tab.ButtonStroke.Color = Theme.Border
                tab.ButtonStroke.Transparency = 0.7
            end
            
            TabButton.BackgroundColor3 = Theme.Background
            TabIconImage.ImageColor3 = Theme.Accent
            TabLabel.TextColor3 = Theme.Text
            TabButtonStroke.Color = Theme.Accent
            TabButtonStroke.Transparency = 0.3
            TabContent.Visible = true
            CurrentTab = TabContent
            
            Ripple(TabButton, Mouse.X, Mouse.Y)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if TabButton.BackgroundColor3 == Theme.Secondary then
                Tween(TabButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}, 0.2)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if TabContent.Visible == false then
                Tween(TabButton, {BackgroundColor3 = Theme.Secondary}, 0.2)
            end
        end)
        
        local Tab = {
            Button = TabButton,
            Icon = TabIconImage,
            Label = TabLabel,
            Content = TabContent,
            LeftSection = LeftSection,
            RightSection = RightSection,
            ButtonStroke = TabButtonStroke
        }
        
        table.insert(Tabs, Tab)
        
        if #Tabs == 1 then
            TabButton.BackgroundColor3 = Theme.Background
            TabIconImage.ImageColor3 = Theme.Accent
            TabLabel.TextColor3 = Theme.Text
            TabButtonStroke.Color = Theme.Accent
            TabButtonStroke.Transparency = 0.3
            TabContent.Visible = true
            CurrentTab = TabContent
        end
        
        -- Tab Functions
        function Tab:CreateSection(options)
            options = options or {}
            local SectionName = options.Name or "Section"
            local Side = options.Side or "Left"
            
            local Parent = Side == "Left" and LeftSection or RightSection
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = SectionName
            SectionFrame.Size = UDim2.new(1, 0, 0, 35)
            SectionFrame.BackgroundColor3 = Theme.Primary
            SectionFrame.BorderSizePixel = 0
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.Parent = Parent
            
            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 8)
            SectionCorner.Parent = SectionFrame
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, -16, 0, 30)
            SectionTitle.Position = UDim2.new(0, 8, 0, 3)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = SectionName
            SectionTitle.TextColor3 = Theme.Text
            SectionTitle.TextSize = 14
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame
            
            local SectionContainer = Instance.new("Frame")
            SectionContainer.Name = "Container"
            SectionContainer.Size = UDim2.new(1, -16, 1, -38)
            SectionContainer.Position = UDim2.new(0, 8, 0, 35)
            SectionContainer.BackgroundTransparency = 1
            SectionContainer.AutomaticSize = Enum.AutomaticSize.Y
            SectionContainer.Parent = SectionFrame
            
            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 8)
            SectionLayout.Parent = SectionContainer
            
            local Section = {}
            
            function Section:AddButton(options)
                options = options or {}
                local ButtonName = options.Name or "Button"
                local Callback = options.Callback or function() end
                
                local Button = Instance.new("TextButton")
                Button.Name = ButtonName
                Button.Size = UDim2.new(1, 0, 0, 35)
                Button.BackgroundColor3 = Theme.Secondary
                Button.Text = ButtonName
                Button.TextColor3 = Theme.Text
                Button.TextSize = 14
                Button.Font = Enum.Font.GothamMedium
                Button.BorderSizePixel = 0
                Button.AutoButtonColor = false
                Button.Parent = SectionContainer
                
                local ButtonCorner = Instance.new("UICorner")
                ButtonCorner.CornerRadius = UDim.new(0, 6)
                ButtonCorner.Parent = Button
                
                Button.MouseButton1Click:Connect(function()
                    Ripple(Button, Mouse.X, Mouse.Y)
                    pcall(Callback)
                end)
                
                Button.MouseEnter:Connect(function()
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}, 0.2)
                end)
                
                Button.MouseLeave:Connect(function()
                    Tween(Button, {BackgroundColor3 = Theme.Secondary}, 0.2)
                end)
                
                return Button
            end
            
            function Section:AddToggle(options)
                options = options or {}
                local ToggleName = options.Name or "Toggle"
                local Default = options.Default or false
                local Callback = options.Callback or function() end
                
                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Name = ToggleName
                ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
                ToggleFrame.BackgroundColor3 = Theme.Secondary
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Parent = SectionContainer
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 6)
                ToggleCorner.Parent = ToggleFrame
                
                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = ToggleName
                ToggleLabel.TextColor3 = Theme.Text
                ToggleLabel.TextSize = 14
                ToggleLabel.Font = Enum.Font.GothamMedium
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.Parent = ToggleFrame
                
                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(0, 44, 0, 24)
                ToggleButton.Position = UDim2.new(1, -48, 0.5, -12)
                ToggleButton.BackgroundColor3 = Default and Theme.Accent or Color3.fromRGB(65, 69, 77)
                ToggleButton.Text = ""
                ToggleButton.BorderSizePixel = 0
                ToggleButton.AutoButtonColor = false
                ToggleButton.Parent = ToggleFrame
                
                local ToggleButtonCorner = Instance.new("UICorner")
                ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
                ToggleButtonCorner.Parent = ToggleButton
                
                local ToggleIndicator = Instance.new("Frame")
                ToggleIndicator.Size = UDim2.new(0, 18, 0, 18)
                ToggleIndicator.Position = Default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleIndicator.BorderSizePixel = 0
                ToggleIndicator.Parent = ToggleButton
                
                local IndicatorCorner = Instance.new("UICorner")
                IndicatorCorner.CornerRadius = UDim.new(1, 0)
                IndicatorCorner.Parent = ToggleIndicator
                
                local Toggled = Default
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    
                    Tween(ToggleButton, {BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(65, 69, 77)}, 0.2)
                    Tween(ToggleIndicator, {Position = Toggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, 0.2)
                    
                    pcall(function()
                        Callback(Toggled)
                    end)
                end)
                
                local Toggle = {}
                function Toggle:SetValue(value)
                    Toggled = value
                    Tween(ToggleButton, {BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(65, 69, 77)}, 0.2)
                    Tween(ToggleIndicator, {Position = Toggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, 0.2)
                end
                
                return Toggle
            end
            
            function Section:AddSlider(options)
                options = options or {}
                local SliderName = options.Name or "Slider"
                local Min = options.Min or 0
                local Max = options.Max or 100
                local Default = options.Default or Min
                local Increment = options.Increment or 1
                local Callback = options.Callback or function() end
                
                local SliderFrame = Instance.new("Frame")
                SliderFrame.Name = SliderName
                SliderFrame.Size = UDim2.new(1, 0, 0, 55)
                SliderFrame.BackgroundColor3 = Theme.Secondary
                SliderFrame.BorderSizePixel = 0
                SliderFrame.Parent = SectionContainer
                
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 6)
                SliderCorner.Parent = SliderFrame
                
                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(1, -20, 0, 20)
                SliderLabel.Position = UDim2.new(0, 10, 0, 5)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = SliderName
                SliderLabel.TextColor3 = Theme.Text
                SliderLabel.TextSize = 14
                SliderLabel.Font = Enum.Font.GothamMedium
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame
                
                local SliderValue = Instance.new("TextLabel")
                SliderValue.Size = UDim2.new(0, 50, 0, 20)
                SliderValue.Position = UDim2.new(1, -60, 0, 5)
                SliderValue.BackgroundTransparency = 1
                SliderValue.Text = tostring(Default)
                SliderValue.TextColor3 = Theme.Accent
                SliderValue.TextSize = 14
                SliderValue.Font = Enum.Font.GothamBold
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                SliderValue.Parent = SliderFrame
                
                local SliderBackground = Instance.new("Frame")
                SliderBackground.Size = UDim2.new(1, -20, 0, 8)
                SliderBackground.Position = UDim2.new(0, 10, 1, -18)
                SliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                SliderBackground.BorderSizePixel = 0
                SliderBackground.Parent = SliderFrame
                
                local SliderBgCorner = Instance.new("UICorner")
                SliderBgCorner.CornerRadius = UDim.new(1, 0)
                SliderBgCorner.Parent = SliderBackground
                
                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
                SliderFill.BackgroundColor3 = Theme.Accent
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBackground
                
                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(1, 0)
                SliderFillCorner.Parent = SliderFill
                
                local SliderCircle = Instance.new("Frame")
                SliderCircle.Size = UDim2.new(0, 18, 0, 18)
                SliderCircle.Position = UDim2.new((Default - Min) / (Max - Min), -9, 0.5, -9)
                SliderCircle.BackgroundColor3 = Theme.Text
                SliderCircle.BorderSizePixel = 0
                SliderCircle.ZIndex = 2
                SliderCircle.Parent = SliderBackground
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(1, 0)
                CircleCorner.Parent = SliderCircle
                
                local CircleShadow = Instance.new("UIStroke")
                CircleShadow.Color = Color3.fromRGB(0, 0, 0)
                CircleShadow.Thickness = 3
                CircleShadow.Transparency = 0.5
                CircleShadow.Parent = SliderCircle
                
                local Dragging = false
                local CurrentValue = Default
                
                local function UpdateSlider(input)
                    local mouseX = input.Position.X
                    local sliderX = SliderBackground.AbsolutePosition.X
                    local sliderWidth = SliderBackground.AbsoluteSize.X
                    
                    local pos = math.clamp((mouseX - sliderX) / sliderWidth, 0, 1)
                    local value = math.floor((Min + (Max - Min) * pos) / Increment + 0.5) * Increment
                    value = math.clamp(value, Min, Max)
                    
                    CurrentValue = value
                    SliderValue.Text = tostring(value)
                    
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderCircle.Position = UDim2.new(pos, -9, 0.5, -9)
                    
                    pcall(function()
                        Callback(value)
                    end)
                end
                
                local function OnDragStart()
                    Dragging = true
                    Tween(SliderCircle, {
                        Size = UDim2.new(0, 24, 0, 24),
                        BackgroundColor3 = Theme.Accent
                    }, 0.15)
                    Tween(CircleShadow, {Transparency = 0.3}, 0.15)
                end
                
                local function OnDragEnd()
                    Dragging = false
                    Tween(SliderCircle, {
                        Size = UDim2.new(0, 18, 0, 18),
                        BackgroundColor3 = Theme.Text
                    }, 0.15)
                    Tween(CircleShadow, {Transparency = 0.5}, 0.15)
                end
                
                SliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        OnDragStart()
                        UpdateSlider(input)
                    end
                end)
                
                SliderBackground.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        OnDragEnd()
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if Dragging then
                            OnDragEnd()
                        end
                    end
                end)
                
                SliderCircle.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        OnDragStart()
                    end
                end)
                
                SliderCircle.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        OnDragEnd()
                    end
                end)
                
                local Slider = {}
                function Slider:SetValue(value)
                    CurrentValue = math.clamp(value, Min, Max)
                    SliderValue.Text = tostring(CurrentValue)
                    local pos = (CurrentValue - Min) / (Max - Min)
                    Tween(SliderFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.2)
                    Tween(SliderCircle, {Position = UDim2.new(pos, -9, 0.5, -9)}, 0.2)
                end
                
                return Slider
            end
            
            function Section:AddDropdown(options)
                options = options or {}
                local DropdownName = options.Name or "Dropdown"
                local Items = options.Items or {}
                local Default = options.Default or ""
                local Callback = options.Callback or function() end
                
                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Name = DropdownName
                DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
                DropdownFrame.BackgroundColor3 = Theme.Secondary
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.ClipsDescendants = true
                DropdownFrame.Parent = SectionContainer
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 6)
                DropdownCorner.Parent = DropdownFrame
                
                local DropdownButton = Instance.new("TextButton")
                DropdownButton.Size = UDim2.new(1, 0, 0, 35)
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Text = ""
                DropdownButton.Parent = DropdownFrame
                
                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Size = UDim2.new(1, -60, 1, 0)
                DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = DropdownName
                DropdownLabel.TextColor3 = Theme.Text
                DropdownLabel.TextSize = 14
                DropdownLabel.Font = Enum.Font.GothamMedium
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropdownButton
                
                local DropdownValue = Instance.new("TextLabel")
                DropdownValue.Size = UDim2.new(0, 100, 1, 0)
                DropdownValue.Position = UDim2.new(1, -130, 0, 0)
                DropdownValue.BackgroundTransparency = 1
                DropdownValue.Text = Default
                DropdownValue.TextColor3 = Theme.SubText
                DropdownValue.TextSize = 13
                DropdownValue.Font = Enum.Font.Gotham
                DropdownValue.TextXAlignment = Enum.TextXAlignment.Right
                DropdownValue.TextTruncate = Enum.TextTruncate.AtEnd
                DropdownValue.Parent = DropdownButton
                
                local DropdownArrow = Instance.new("TextLabel")
                DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
                DropdownArrow.Position = UDim2.new(1, -25, 0, 0)
                DropdownArrow.BackgroundTransparency = 1
                DropdownArrow.Text = "▼"
                DropdownArrow.TextColor3 = Theme.SubText
                DropdownArrow.TextSize = 10
                DropdownArrow.Font = Enum.Font.GothamBold
                DropdownArrow.Parent = DropdownButton
                
                local DropdownList = Instance.new("ScrollingFrame")
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.Position = UDim2.new(0, 0, 0, 35)
                DropdownList.BackgroundColor3 = Theme.Primary
                DropdownList.BorderSizePixel = 0
                DropdownList.ScrollBarThickness = 3
                DropdownList.ScrollBarImageColor3 = Theme.Accent
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
                DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
                DropdownList.Visible = false
                DropdownList.Parent = DropdownFrame
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = DropdownList
                
                local ListPadding = Instance.new("UIPadding")
                ListPadding.PaddingTop = UDim.new(0, 5)
                ListPadding.PaddingBottom = UDim.new(0, 5)
                ListPadding.Parent = DropdownList
                
                local Opened = false
                local CurrentValue = Default
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Opened = not Opened
                    
                    if Opened then
                        local height = math.min(#Items * 28 + 10, 150)
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35 + height)}, 0.3)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, height)}, 0.3)
                        task.wait(0.1)
                        DropdownList.Visible = true
                        Tween(DropdownArrow, {Rotation = 180}, 0.3)
                    else
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.3)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
                        Tween(DropdownArrow, {Rotation = 0}, 0.3)
                        task.wait(0.3)
                        DropdownList.Visible = false
                    end
                end)
                
                for _, item in ipairs(Items) do
                    local ItemButton = Instance.new("TextButton")
                    ItemButton.Size = UDim2.new(1, -10, 0, 25)
                    ItemButton.BackgroundColor3 = Theme.Secondary
                    ItemButton.Text = item
                    ItemButton.TextColor3 = Theme.Text
                    ItemButton.TextSize = 13
                    ItemButton.Font = Enum.Font.Gotham
                    ItemButton.BorderSizePixel = 0
                    ItemButton.AutoButtonColor = false
                    ItemButton.Parent = DropdownList
                    
                    local ItemCorner = Instance.new("UICorner")
                    ItemCorner.CornerRadius = UDim.new(0, 6)
                    ItemCorner.Parent = ItemButton
                    
                    ItemButton.MouseButton1Click:Connect(function()
                        CurrentValue = item
                        DropdownValue.Text = item
                        
                        Opened = false
                        Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.3)
                        Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
                        Tween(DropdownArrow, {Rotation = 0}, 0.3)
                        task.wait(0.3)
                        DropdownList.Visible = false
                        
                        pcall(function()
                            Callback(item)
                        end)
                    end)
                    
                    ItemButton.MouseEnter:Connect(function()
                        Tween(ItemButton, {BackgroundColor3 = Theme.Accent}, 0.2)
                    end)
                    
                    ItemButton.MouseLeave:Connect(function()
                        Tween(ItemButton, {BackgroundColor3 = Theme.Secondary}, 0.2)
                    end)
                end
                
                local Dropdown = {}
                function Dropdown:SetValue(value)
                    CurrentValue = value
                    DropdownValue.Text = value
                end
                
                function Dropdown:Refresh(newItems)
                    Items = newItems
                    for _, child in ipairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for _, item in ipairs(Items) do
                        local ItemButton = Instance.new("TextButton")
                        ItemButton.Size = UDim2.new(1, -10, 0, 25)
                        ItemButton.BackgroundColor3 = Theme.Secondary
                        ItemButton.Text = item
                        ItemButton.TextColor3 = Theme.Text
                        ItemButton.TextSize = 13
                        ItemButton.Font = Enum.Font.Gotham
                        ItemButton.BorderSizePixel = 0
                        ItemButton.AutoButtonColor = false
                        ItemButton.Parent = DropdownList
                        
                        local ItemCorner = Instance.new("UICorner")
                        ItemCorner.CornerRadius = UDim.new(0, 6)
                        ItemCorner.Parent = ItemButton
                        
                        ItemButton.MouseButton1Click:Connect(function()
                            CurrentValue = item
                            DropdownValue.Text = item
                            
                            Opened = false
                            Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.3)
                            Tween(DropdownList, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
                            Tween(DropdownArrow, {Rotation = 0}, 0.3)
                            task.wait(0.3)
                            DropdownList.Visible = false
                            
                            pcall(function()
                                Callback(item)
                            end)
                        end)
                        
                        ItemButton.MouseEnter:Connect(function()
                            Tween(ItemButton, {BackgroundColor3 = Theme.Accent}, 0.2)
                        end)
                        
                        ItemButton.MouseLeave:Connect(function()
                            Tween(ItemButton, {BackgroundColor3 = Theme.Secondary}, 0.2)
                        end)
                    end
                end
                
                return Dropdown
            end
            
            function Section:AddLabel(options)
                options = options or {}
                local LabelText = options.Text or "Label"
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 25)
                Label.BackgroundTransparency = 1
                Label.Text = LabelText
                Label.TextColor3 = Theme.SubText
                Label.TextSize = 13
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextWrapped = true
                Label.AutomaticSize = Enum.AutomaticSize.Y
                Label.Parent = SectionContainer
                
                local LabelObj = {}
                function LabelObj:SetText(text)
                    Label.Text = text
                end
                
                return LabelObj
            end
            
            function Section:AddTextBox(options)
                options = options or {}
                local TextBoxName = options.Name or "TextBox"
                local Default = options.Default or ""
                local Placeholder = options.Placeholder or "Enter text..."
                local Callback = options.Callback or function() end
                
                local TextBoxFrame = Instance.new("Frame")
                TextBoxFrame.Name = TextBoxName
                TextBoxFrame.Size = UDim2.new(1, 0, 0, 60)
                TextBoxFrame.BackgroundColor3 = Theme.Secondary
                TextBoxFrame.BorderSizePixel = 0
                TextBoxFrame.Parent = SectionContainer
                
                local TextBoxCorner = Instance.new("UICorner")
                TextBoxCorner.CornerRadius = UDim.new(0, 6)
                TextBoxCorner.Parent = TextBoxFrame
                
                local TextBoxLabel = Instance.new("TextLabel")
                TextBoxLabel.Size = UDim2.new(1, -20, 0, 20)
                TextBoxLabel.Position = UDim2.new(0, 10, 0, 5)
                TextBoxLabel.BackgroundTransparency = 1
                TextBoxLabel.Text = TextBoxName
                TextBoxLabel.TextColor3 = Theme.Text
                TextBoxLabel.TextSize = 14
                TextBoxLabel.Font = Enum.Font.GothamMedium
                TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextBoxLabel.Parent = TextBoxFrame
                
                local TextBoxInput = Instance.new("TextBox")
                TextBoxInput.Size = UDim2.new(1, -20, 0, 30)
                TextBoxInput.Position = UDim2.new(0, 10, 0, 25)
                TextBoxInput.BackgroundColor3 = Theme.Primary
                TextBoxInput.Text = Default
                TextBoxInput.PlaceholderText = Placeholder
                TextBoxInput.TextColor3 = Theme.Text
                TextBoxInput.PlaceholderColor3 = Theme.SubText
                TextBoxInput.TextSize = 13
                TextBoxInput.Font = Enum.Font.Gotham
                TextBoxInput.BorderSizePixel = 0
                TextBoxInput.ClearTextOnFocus = false
                TextBoxInput.Parent = TextBoxFrame
                
                local InputCorner = Instance.new("UICorner")
                InputCorner.CornerRadius = UDim.new(0, 6)
                InputCorner.Parent = TextBoxInput
                
                TextBoxInput.FocusLost:Connect(function(enterPressed)
                    if enterPressed then
                        pcall(function()
                            Callback(TextBoxInput.Text)
                        end)
                    end
                end)
                
                local TextBox = {}
                function TextBox:SetValue(text)
                    TextBoxInput.Text = text
                end
                
                return TextBox
            end
            
            return Section
        end
        
        return Tab
    end
    
    -- No resize handle - auto-sizing handled by viewport monitoring
    
    -- Intro Animation
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    Tween(MainFrame, {Size = UDim2.new(0, WindowSize.Width, 0, WindowSize.Height)}, 0.5, Enum.EasingStyle.Back)
    
    return Window
end

return ModernUI
