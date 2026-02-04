--[[ 
    XS ULTRA — 0.0.5 FIXED
    Stable Aim • Proper ESP • No Leaks
    XS Clean UI
]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- CLEAN OLD
for _,v in pairs(CoreGui:GetChildren()) do
    if v:IsA("ScreenGui") and v.Name:find("XS_ULTRA") then
        v:Destroy()
    end
end

-- CONFIG
getgenv().XS = {
    Combat = {
        Enabled = true,
        UseMouse = true,
        MouseKey = Enum.UserInputType.MouseButton2,
        FOV = 180,
        Smooth = 0.08,
        TeamCheck = true,
        WallCheck = true
    },
    Visuals = {
        BoxESP = true,
        Chams = true,
        ShowFOV = true
    },
    UI = {
        Minimized = false,
        Accent = Color3.fromRGB(255,255,255)
    }
}

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- FOV CIRCLE
local FOV = Drawing.new("Circle")
FOV.Thickness = 1.5
FOV.NumSides = 100
FOV.Transparency = 0.8
FOV.Filled = false
FOV.Color = XS.UI.Accent

-- VISIBILITY CHECK
local function IsVisible(part)
    if not XS.Combat.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, Camera}
    local ray = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return (not ray) or ray.Instance:IsDescendantOf(part.Parent)
end

local function IsEnemy(p)
    if not XS.Combat.TeamCheck then return true end
    return p.Team ~= LP.Team
end

-- UI ROOT
local GUI = Instance.new("ScreenGui", CoreGui)
GUI.Name = "XS_ULTRA_V25"
GUI.IgnoreGuiInset = true

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.new(0,560,0,400)
Main.Position = UDim2.new(0.5,-280,0.5,-200)
Main.BackgroundColor3 = Color3.fromRGB(5,5,5)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

-- SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0,140,1,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(8,8,8)
Sidebar.BorderSizePixel = 0

local TabsHolder = Instance.new("UIListLayout", Sidebar)
TabsHolder.Padding = UDim.new(0,8)
TabsHolder.HorizontalAlignment = Center

-- CONTENT
local Content = Instance.new("Frame", Main)
Content.Position = UDim2.new(0,150,0,10)
Content.Size = UDim2.new(1,-160,1,-20)
Content.BackgroundTransparency = 1

local Tabs = {}

local function CreateTab(name)
    local page = Instance.new("ScrollingFrame", Content)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    page.ScrollBarThickness = 0
    Instance.new("UIListLayout", page).Padding = UDim.new(0,10)
    Tabs[name] = page

    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0,120,0,38)
    btn.Text = name
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(130,130,130)
    btn.BackgroundColor3 = Color3.fromRGB(15,15,15)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        for _,t in pairs(Tabs) do t.Visible = false end
        page.Visible = true
        for _,b in pairs(Sidebar:GetChildren()) do
            if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(130,130,130) end
        end
        btn.TextColor3 = XS.UI.Accent
    end)
end

local function Toggle(tab,text,path,key)
    local b = Instance.new("TextButton", Tabs[tab])
    b.Size = UDim2.new(1,-10,0,40)
    b.BackgroundColor3 = Color3.fromRGB(12,12,12)
    b.Text = "  "..text
    b.Font = Enum.Font.Code
    b.TextSize = 13
    b.TextXAlignment = Left
    Instance.new("UICorner", b)

    local function refresh()
        b.TextColor3 = path[key] and XS.UI.Accent or Color3.fromRGB(120,120,120)
    end
    refresh()

    b.MouseButton1Click:Connect(function()
        path[key] = not path[key]
        refresh()
    end)
end

local function Slider(tab,text,min,max,path,key)
    local f = Instance.new("Frame", Tabs[tab])
    f.Size = UDim2.new(1,-10,0,55)
    f.BackgroundTransparency = 1

    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1,0,0,20)
    t.Text = text..": "..math.floor(path[key])
    t.Font = Enum.Font.Code
    t.TextSize = 13
    t.TextColor3 = Color3.fromRGB(200,200,200)
    t.BackgroundTransparency = 1
    t.TextXAlignment = Left

    local bar = Instance.new("Frame", f)
    bar.Position = UDim2.new(0,0,0,30)
    bar.Size = UDim2.new(1,0,0,6)
    bar.BackgroundColor3 = Color3.fromRGB(30,30,30)
    Instance.new("UICorner", bar)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((path[key]-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = XS.UI.Accent
    Instance.new("UICorner", fill)

    local drag = false
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)

    RunService.RenderStepped:Connect(function()
        if drag then
            local p = math.clamp((UIS:GetMouseLocation().X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local v = min+(max-min)*p
            path[key]=v
            fill.Size = UDim2.new(p,0,1,0)
            t.Text = text..": "..math.floor(v)
        end
    end)
end

-- INIT UI
CreateTab("Combat")
CreateTab("Visuals")

Tabs.Combat.Visible = true

Toggle("Combat","AIMBOT",XS.Combat,"Enabled")
Toggle("Combat","TEAM CHECK",XS.Combat,"TeamCheck")
Toggle("Combat","WALL CHECK",XS.Combat,"WallCheck")
Slider("Combat","FOV",20,800,XS.Combat,"FOV")
Slider("Combat","SMOOTH",1,100,XS.Combat,"Smooth")

Toggle("Visuals","BOX ESP",XS.Visuals,"BoxESP")
Toggle("Visuals","CHAMS",XS.Visuals,"Chams")
Toggle("Visuals","FOV CIRCLE",XS.Visuals,"ShowFOV")

-- ESP DATA
local ESP = {}

local function SetupESP(p)
    local box = Drawing.new("Square")
    box.Thickness = 1.5
    box.Visible = false

    ESP[p] = {Box=box}
end

for _,p in pairs(Players:GetPlayers()) do
    if p~=LP then SetupESP(p) end
end

Players.PlayerAdded:Connect(SetupESP)
Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then
        ESP[p].Box:Remove()
        ESP[p]=nil
    end
end)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    local m = UIS:GetMouseLocation()
    FOV.Visible = XS.Visuals.ShowFOV
    FOV.Radius = XS.Combat.FOV
    FOV.Position = Vector2.new(m.X, m.Y-36)

    local target,nearest=nil,XS.Combat.FOV

    for p,data in pairs(ESP) do
        local char=p.Character
        if char and char:FindFirstChild("HumanoidRootPart") and IsEnemy(p) then
            local root=char.HumanoidRootPart
            local pos,on=Camera:WorldToViewportPoint(root.Position)
            if XS.Visuals.BoxESP and on then
                local h=(Camera:WorldToViewportPoint(root.Position+Vector3.new(0,3,0)).Y-
                        Camera:WorldToViewportPoint(root.Position-Vector3.new(0,3,0)).Y)
                data.Box.Size=Vector2.new(h/1.6,h)
                data.Box.Position=Vector2.new(pos.X-h/3.2,pos.Y-h/2)
                data.Box.Color=XS.UI.Accent
                data.Box.Visible=true
            else data.Box.Visible=false end

            if XS.Combat.Enabled and UIS:IsMouseButtonPressed(XS.Combat.MouseKey) then
                local head=char:FindFirstChild("Head")
                if head then
                    local hp,on2=Camera:WorldToViewportPoint(head.Position)
                    if on2 and IsVisible(head) then
                        local d=(Vector2.new(hp.X,hp.Y)-Vector2.new(m.X,m.Y)).Magnitude
                        if d<nearest then nearest=d; target=head end
                    end
                end
            end
        else data.Box.Visible=false end
    end

    if target then
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, target.Position),
            XS.Combat.Smooth
        )
    end
end)

-- DRAG
local drag,sp,ip
Main.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        drag=true; ip=i.Position; sp=Main.Position
    end
end)
Main.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
UIS.InputChanged:Connect(function(i)
    if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-ip
        Main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)
