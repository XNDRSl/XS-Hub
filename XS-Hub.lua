--[[ 
    XS 0.0.3
    Update: Refined Premium UI Design
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

if CoreGui:FindFirstChild("XS_PRESTIGE") then CoreGui.XS_PRESTIGE:Destroy() end

getgenv().XS_Config = {
    Aim = { Enabled = true, Key = Enum.UserInputType.MouseButton2, FOV = 200, Smooth = 0.12, TeamCheck = true },
    Visuals = { BoxESP = true },
    UI = { Minimized = false }
}

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Helper: Team Check
local function IsEnemy(targetPlayer)
    if not getgenv().XS_Config.Aim.TeamCheck then return true end
    return targetPlayer.Team ~= LocalPlayer.Team or targetPlayer.TeamColor ~= LocalPlayer.TeamColor
end

-- ═══════════════════════════════════════════════════════════════════════════
-- UI CONSTRUCTION (PREMIUM DESIGN)
-- ═══════════════════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "XS_PRESTIGE"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 380, 0, 260)
Main.Position = UDim2.new(0.5, -190, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
Main.BackgroundTransparency = 0.1
Main.BorderSizePixel = 0
Main.ClipsDescendants = true

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(45, 45, 45)
MainStroke.Thickness = 1
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Header Section
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "XS // GHOST PRESTIGE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 14
Title.TextXAlignment = "Left"
Title.BackgroundTransparency = 1

local Line = Instance.new("Frame", Main)
Line.Size = UDim2.new(1, -30, 0, 1)
Line.Position = UDim2.new(0, 15, 0, 40)
Line.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Line.BorderSizePixel = 0

-- Container
local Container = Instance.new("Frame", Main)
Container.Size = UDim2.new(1, -30, 1, -60)
Container.Position = UDim2.new(0, 15, 0, 55)
Container.BackgroundTransparency = 1
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 6)

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULES (ESP & AIM)
-- ═══════════════════════════════════════════════════════════════════════════
local function CreateESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 255, 255)
    Box.Thickness = 1
    Box.Filled = false

    RunService.RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and getgenv().XS_Config.Visuals.BoxESP and IsEnemy(player) then
            local Root = player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            if OnScreen then
                local Size = (Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, -3.5, 0)).Y)
                Box.Size = Vector2.new(Size / 1.5, Size)
                Box.Position = Vector2.new(Pos.X - Box.Size.X / 2, Pos.Y - Box.Size.Y / 2)
                Box.Visible = true
            else Box.Visible = false end
        else Box.Visible = false end
    end)
end

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()
    if getgenv().XS_Config.Aim.Enabled and UserInputService:IsMouseButtonPressed(getgenv().XS_Config.Aim.Key) then
        local target, dist = nil, getgenv().XS_Config.Aim.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and IsEnemy(p) then
                local pos, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local mDist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if on and mDist < dist then dist = mDist; target = p.Character.Head end
            end
        end
        if target then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), getgenv().XS_Config.Aim.Smooth)
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRETTY CONTROLS
-- ═══════════════════════════════════════════════════════════════════════════
local function AddToggle(name, path, key)
    local Frame = Instance.new("TextButton", Container)
    Frame.Size = UDim2.new(1, 0, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Frame.Text = "  " .. name:upper()
    Frame.TextColor3 = path[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
    Frame.Font = Enum.Font.Code
    Frame.TextSize = 12
    Frame.TextXAlignment = "Left"
    
    local S = Instance.new("UIStroke", Frame)
    S.Color = path[key] and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

    Frame.MouseButton1Click:Connect(function()
        path[key] = not path[key]
        TweenService:Create(Frame, TweenInfo.new(0.2), {TextColor3 = path[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)}):Play()
        TweenService:Create(S, TweenInfo.new(0.2), {Color = path[key] and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(30, 30, 30)}):Play()
    end)
end

AddToggle("Aimbot Master", getgenv().XS_Config.Aim, "Enabled")
AddToggle("Filter Teammates", getgenv().XS_Config.Aim, "TeamCheck")
AddToggle("Box Visuals", getgenv().XS_Config.Visuals, "BoxESP")

-- Dragging
local d, di, ds, sp
Main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = Main.Position end end)
Main.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - ds
    Main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
end end)

-- Minimize
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.RightShift then
        getgenv().XS_Config.UI.Minimized = not getgenv().XS_Config.UI.Minimized
        local m = getgenv().XS_Config.UI.Minimized
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = m and UDim2.new(0, 45, 0, 45) or UDim2.new(0, 380, 0, 260)}):Play()
        Title.Visible = not m; Container.Visible = not m; Line.Visible = not m
    end
end)
