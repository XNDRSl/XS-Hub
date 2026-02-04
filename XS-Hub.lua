--[[ 
    XS HUB
    - NEW: Target HUD (Info about enemy you aim at)
    - NEW: Auto-Clicker (For semi-auto guns)
    - NEW: Night Mode (Visual clarity)
    - Preserved: Cube, Kill Script, All Fixes
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")

local UI_NAME = "XS_TITAN_V51"
if CoreGui:FindFirstChild(UI_NAME) then CoreGui[UI_NAME]:Destroy() end

getgenv().XS_Config = {
    Combat = { Enabled = false, Key = Enum.UserInputType.MouseButton2, FOV = 150, Smooth = 0.08, TeamCheck = true },
    Visuals = { BoxESP = false, Chams = false, ShowFOV = false, NightMode = false },
    Player = { Speed = 16, Jump = 50, Enabled = false, AutoClicker = false },
    Camera = { POV = 70 },
    UI = { Minimized = false }
}

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2; FOVCircle.NumSides = 100; FOVCircle.Color = Color3.new(1,1,1); FOVCircle.Filled = false

-- ═══════════════════════════════════════════════════════════════════════════
-- TARGET HUD (НОВА ПРИКОЛЮХА)
-- ═══════════════════════════════════════════════════════════════════════════
local TargetGui = Instance.new("ScreenGui", CoreGui)
local TFrame = Instance.new("Frame", TargetGui)
TFrame.Size = UDim2.new(0, 200, 0, 60); TFrame.Position = UDim2.new(0.5, 120, 0.5, -30); TFrame.BackgroundColor3 = Color3.fromRGB(10,10,10); TFrame.Visible = false; Instance.new("UICorner", TFrame)
Instance.new("UIStroke", TFrame).Color = Color3.fromRGB(60,60,60)
local TName = Instance.new("TextLabel", TFrame); TName.Size = UDim2.new(1,0,0,30); TName.BackgroundTransparency = 1; TName.TextColor3 = Color3.new(1,1,1); TName.Font = "Code"; TName.TextSize = 14; TName.Text = "Target: None"
local THealth = Instance.new("Frame", TFrame); THealth.Size = UDim2.new(0.8, 0, 0, 4); THealth.Position = UDim2.new(0.1, 0, 0.7, 0); THealth.BackgroundColor3 = Color3.fromRGB(30,30,30)
local TFill = Instance.new("Frame", THealth); TFill.Size = UDim2.new(1, 0, 1, 0); TFill.BackgroundColor3 = Color3.new(0,1,0)

-- ═══════════════════════════════════════════════════════════════════════════
-- WATERMARK & UI CONSTRUCTION (ЗБЕРЕЖЕНО)
-- ═══════════════════════════════════════════════════════════════════════════
local WM_Gui = Instance.new("ScreenGui", CoreGui)
local WM_Frame = Instance.new("Frame", WM_Gui); WM_Frame.Size = UDim2.new(0, 220, 0, 30); WM_Frame.Position = UDim2.new(0, 20, 0, 20); WM_Frame.BackgroundColor3 = Color3.fromRGB(10,10,10); Instance.new("UICorner", WM_Frame)
local WM_Text = Instance.new("TextLabel", WM_Frame); WM_Text.Size = UDim2.new(1,0,1,0); WM_Text.BackgroundTransparency = 1; WM_Text.TextColor3 = Color3.new(1,1,1); WM_Text.Font = "Code"; WM_Text.TextSize = 14
Instance.new("UIStroke", WM_Frame).Color = Color3.fromRGB(60,60,60)

task.spawn(function()
    while task.wait(0.5) and WM_Gui.Parent do
        local fps = math.floor(Stats.WorkspaceResources.FPS:GetValue())
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        WM_Text.Text = "XS TITAN | FPS: "..fps.." | PING: "..ping.."ms"
    end
end)

local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = UI_NAME
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0, 620, 0, 480); Main.Position = UDim2.new(0.5, -310, 0.5, -240); Main.BackgroundColor3 = Color3.fromRGB(6, 6, 6); Main.ClipsDescendants = true; Instance.new("UICorner", Main)
local MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = Color3.fromRGB(60,60,60); MainStroke.Thickness = 2

local Cube = Instance.new("Frame", ScreenGui); Cube.Size = UDim2.new(0, 60, 0, 60); Cube.Position = Main.Position; Cube.BackgroundColor3 = Color3.fromRGB(15,15,15); Cube.Visible = false; Instance.new("UICorner", Cube)
local CubeLogo = Instance.new("TextLabel", Cube); CubeLogo.Size = UDim2.new(1,0,1,0); CubeLogo.Text = "XS"; CubeLogo.TextColor3 = Color3.new(1,1,1); CubeLogo.Font = "Code"; CubeLogo.TextSize = 25; CubeLogo.BackgroundTransparency = 1
Instance.new("UIStroke", Cube).Color = Color3.new(1,1,1)

local Sidebar = Instance.new("Frame", Main); Sidebar.Size = UDim2.new(0, 180, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Instance.new("UICorner", Sidebar)
local TabHolder = Instance.new("Frame", Sidebar); TabHolder.Size = UDim2.new(1, 0, 1, -100); TabHolder.Position = UDim2.new(0, 0, 0, 80); TabHolder.BackgroundTransparency = 1
Instance.new("UIListLayout", TabHolder).Padding = UDim.new(0, 10); TabHolder.UIListLayout.HorizontalAlignment = "Center"
local Container = Instance.new("Frame", Main); Container.Size = UDim2.new(1, -210, 1, -60); Container.Position = UDim2.new(0, 195, 0, 30); Container.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(Name)
    local F = Instance.new("ScrollingFrame", Container); F.Size = UDim2.new(1, 0, 1, 0); F.BackgroundTransparency = 1; F.Visible = false; F.ScrollBarThickness = 0
    Instance.new("UIListLayout", F).Padding = UDim.new(0, 12); Tabs[Name] = F
    local B = Instance.new("TextButton", TabHolder); B.Size = UDim2.new(0, 160, 0, 48); B.BackgroundColor3 = Color3.fromRGB(18, 18, 18); B.Text = Name; B.Font = "Code"; B.TextColor3 = Color3.fromRGB(130, 130, 130); B.TextSize = 18; Instance.new("UICorner", B)
    B.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do tab.Visible = false end
        F.Visible = true; for _, btn in pairs(TabHolder:GetChildren()) do if btn:IsA("TextButton") then btn.TextColor3 = Color3.fromRGB(130,130,130) end end
        B.TextColor3 = Color3.new(1,1,1)
    end)
end

local function AddToggle(Tab, Text, Path, Key)
    local b = Instance.new("TextButton", Tabs[Tab]); b.Size = UDim2.new(1, -15, 0, 55); b.BackgroundColor3 = Color3.fromRGB(12, 12, 12); b.Text = "  " .. Text; b.Font = "Code"; b.TextSize = 18; b.TextColor3 = Color3.fromRGB(200, 200, 200); b.TextXAlignment = "Left"; Instance.new("UICorner", b)
    local ind = Instance.new("Frame", b); ind.Size = UDim2.new(0, 40, 0, 22); ind.Position = UDim2.new(1, -55, 0.5, -11); ind.BackgroundColor3 = Path[Key] and Color3.new(1,1,1) or Color3.fromRGB(30, 30, 30); Instance.new("UICorner", ind)
    b.MouseButton1Click:Connect(function()
        Path[Key] = not Path[Key]
        TweenService:Create(ind, TweenInfo.new(0.3), {BackgroundColor3 = Path[Key] and Color3.new(1,1,1) or Color3.fromRGB(30, 30, 30)}):Play()
    end)
end

local function AddSlider(Tab, Text, Min, Max, Path, Key)
    local sf = Instance.new("Frame", Tabs[Tab]); sf.Size = UDim2.new(1, -15, 0, 75); sf.BackgroundTransparency = 1
    local t = Instance.new("TextLabel", sf); t.Size = UDim2.new(1, 0, 0, 30); t.Text = Text .. ": " .. string.format("%.2f", Path[Key]); t.TextColor3 = Color3.new(1,1,1); t.Font = "Code"; t.TextSize = 17; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"
    local bar = Instance.new("Frame", sf); bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0,0,0,45); bar.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Instance.new("UICorner", bar)
    local fill = Instance.new("Frame", bar); fill.Size = UDim2.new((Path[Key]-Min)/(Max-Min), 0, 1, 0); fill.BackgroundColor3 = Color3.new(1,1,1); Instance.new("UICorner", fill)
    local btn = Instance.new("TextButton", bar); btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
    local dragging = false
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local p = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = Min + (Max - Min) * p; Path[Key] = v; fill.Size = UDim2.new(p, 0, 1, 0); t.Text = Text .. ": " .. string.format("%.2f", v)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- INITIALIZE
-- ═══════════════════════════════════════════════════════════════════════════
CreateTab("Combat"); CreateTab("Visuals"); CreateTab("Player"); CreateTab("Settings")
Tabs.Combat.Visible = true

AddToggle("Combat", "Aimbot Enabled", getgenv().XS_Config.Combat, "Enabled")
AddToggle("Combat", "Team Check", getgenv().XS_Config.Combat, "TeamCheck")
AddSlider("Combat", "Aim Smooth", 0.01, 1, getgenv().XS_Config.Combat, "Smooth")
AddSlider("Combat", "Aim FOV", 50, 1000, getgenv().XS_Config.Combat, "FOV")

AddToggle("Visuals", "WallHack (Chams)", getgenv().XS_Config.Visuals, "Chams")
AddToggle("Visuals", "Box ESP", getgenv().XS_Config.Visuals, "BoxESP")
AddToggle("Visuals", "Night Mode", getgenv().XS_Config.Visuals, "NightMode")
AddToggle("Visuals", "Show FOV Circle", getgenv().XS_Config.Visuals, "ShowFOV")

AddToggle("Player", "Enable Hacks", getgenv().XS_Config.Player, "Enabled")
AddToggle("Player", "Auto-Clicker", getgenv().XS_Config.Player, "AutoClicker")
AddSlider("Player", "WalkSpeed", 16, 250, getgenv().XS_Config.Player, "Speed")
AddSlider("Player", "JumpPower", 50, 500, getgenv().XS_Config.Player, "Jump")

local KillBtn = Instance.new("TextButton", Tabs.Settings); KillBtn.Size = UDim2.new(1, -15, 0, 55); KillBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0); KillBtn.Text = "KILL SCRIPT"; KillBtn.Font = "Code"; KillBtn.TextColor3 = Color3.new(1,1,1); KillBtn.TextSize = 18; Instance.new("UICorner", KillBtn)
KillBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); WM_Gui:Destroy(); TargetGui:Destroy(); FOVCircle:Remove(); getgenv().XS_Config.Combat.Enabled = false end)

-- ═══════════════════════════════════════════════════════════════════════════
-- CORE LOGIC
-- ═══════════════════════════════════════════════════════════════════════════
local function ToggleUI()
    getgenv().XS_Config.UI.Minimized = not getgenv().XS_Config.UI.Minimized
    if getgenv().XS_Config.UI.Minimized then
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 60, 0, 60), Position = Cube.Position}):Play()
        task.wait(0.5); Main.Visible = false; Cube.Visible = true
    else
        Cube.Visible = false; Main.Visible = true; Main.Position = Cube.Position
        TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 620, 0, 480)}):Play()
    end
end
UserInputService.InputBegan:Connect(function(i) if i.KeyCode == Enum.KeyCode.RightShift then ToggleUI() end end)

local function Drag(obj)
    local dragging, ds, sp
    obj.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; ds = i.Position; sp = obj.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - ds; obj.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        if obj == Main then Cube.Position = Main.Position elseif obj == Cube then Main.Position = Cube.Position end
    end end)
    obj.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end
Drag(Main); Drag(Cube)

RunService.RenderStepped:Connect(function(dt)
    FOVCircle.Visible = getgenv().XS_Config.Visuals.ShowFOV; FOVCircle.Radius = getgenv().XS_Config.Combat.FOV; FOVCircle.Position = UserInputService:GetMouseLocation()
    
    -- Night Mode
    Lighting.ClockTime = getgenv().XS_Config.Visuals.NightMode and 0 or 14

    -- Auto Clicker
    if getgenv().XS_Config.Player.AutoClicker and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        mouse1click()
    end

    -- Aim & Target HUD
    local target_found = nil
    if getgenv().XS_Config.Combat.Enabled and UserInputService:IsMouseButtonPressed(getgenv().XS_Config.Combat.Key) then
        local nearest = getgenv().XS_Config.Combat.FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                if getgenv().XS_Config.Combat.TeamCheck and p.Team == LocalPlayer.Team then continue end
                local pos, on = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if on then
                    local dist = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if dist < nearest then target_found = p; nearest = dist end
                end
            end
        end
        if target_found then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target_found.Character.Head.Position), getgenv().XS_Config.Combat.Smooth)
            TFrame.Visible = true; TName.Text = "Target: "..target_found.Name
            TFill.Size = UDim2.new(target_found.Character.Humanoid.Health/target_found.Character.Humanoid.MaxHealth, 0, 1, 0)
        else TFrame.Visible = false end
    else TFrame.Visible = false end

    -- Chams & Player Fix
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local Highlight = p.Character:FindFirstChild("XS_Cham")
            if getgenv().XS_Config.Visuals.Chams and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if not Highlight then Highlight = Instance.new("Highlight", p.Character); Highlight.Name = "XS_Cham" end
                Highlight.Enabled = not (getgenv().XS_Config.Combat.TeamCheck and p.Team == LocalPlayer.Team); Highlight.FillColor = Color3.new(1,0,0)
            elseif Highlight then Highlight:Destroy() end
        end
    end
    if getgenv().XS_Config.Player.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().XS_Config.Player.Speed
        LocalPlayer.Character.Humanoid.JumpPower = getgenv().XS_Config.Player.Jump
    end
end)

print("XS TITAN V51 LOADED. TARGET HUD ACTIVE.")
