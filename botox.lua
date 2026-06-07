-- Phoenix Hub - التحديث الجديد والمصلح بالكامل (Aimbot Lock & Universal Noclip)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- متغيرات الحركة والسرعة
local TargetSpeed = 16
local TargetJump = 50
local CustomSpeedEnabled = false
local CustomJumpEnabled = false
local NoclipEnabled = false
local currentY = nil -- ميزان الارتفاع للنوكليب العالمي

-- متغيرات الآيم بوت وإعداداته المتقدمة
local AimbotEnabled = false
local AimbotFOV = 150
local AimbotSmoothness = 1
local AimBehindWalls = false  -- خيار التصويب خلف الجدران
local AimbotYOffset = 0       -- ميزة التحكم بارتفاع وانخفاض الآيم للمابات المخصصة
local CurrentTarget = nil     -- نظام حفظ الهدف الحالي لضمان عدم الفصل

-- لوب فائق السرعة لتثبيت السرعة والقفز ومنع الارتداد عند اختراق الجدران
RunService.Heartbeat:Connect(function(deltaTime)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hum = LocalPlayer.Character.Humanoid
            local hrp = LocalPlayer.Character.HumanoidRootPart
            
            if CustomSpeedEnabled or NoclipEnabled then
                hum.WalkSpeed = TargetSpeed
                if hum.MoveDirection.Magnitude > 0 then
                    local extraSpeed = 0
                    if CustomSpeedEnabled and TargetSpeed > 16 then
                        extraSpeed = TargetSpeed - 16
                    end
                    if NoclipEnabled then
                        -- دفعة تدفق CFrame لمنع الحماية من إرجاع اللاعب للخلف عند عبور الحائط
                        extraSpeed = extraSpeed + 6
                    end
                    if extraSpeed > 0 then
                        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (extraSpeed * deltaTime))
                    end
                end
            end
            
            if CustomJumpEnabled then
                hum.UseJumpPower = true
                hum.JumpPower = TargetJump
            end
        end
    end)
end)

-- لوب اختراق الجدران العالمي المطور (ثبات كامل على الأرض ومنع السقوط)
RunService.Stepped:Connect(function()
    pcall(function()
        if NoclipEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            
            -- إلغاء اصطدام جميع أجزاء الجسم دون التأثير على الجاذبية الدولية
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            
            -- نظام تثبيت الارتفاع لمنع الهبوط التلقائي وتحت الأرض
            if hum.Jump then
                currentY = nil -- السماح بالصعود عند القفز
            else
                if not currentY then 
                    currentY = hrp.Position.Y 
                end
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                hrp.CFrame = CFrame.new(hrp.Position.X, currentY, hrp.Position.Z) * hrp.CFrame.Rotation
            end
        else
            currentY = nil
        end
    end)
end)

-- 1. إنشاء الـ GUI الأساسي وحفظه في مكان آمن بالجوال
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhoenixHub_Instant"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- 2. تصميم الزر العائم (PH) وجعله يظهر دائماً فوق القائمة
local ToggleButton = Instance.new("TextButton")
local BtnCorner = Instance.new("UICorner")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Position = UDim2.new(0, 20, 0, 150)
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "PH"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 130)
ToggleButton.TextSize = 20
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.ZIndex = 10

BtnCorner.CornerRadius = UDim.new(0, 28)
BtnCorner.Parent = ToggleButton

-- 3. اللوحة الرئيسية للسكربت (نفس الشكل والحجم والألوان تماماً ليرضى المتابعين)
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -130)
MainFrame.Size = UDim2.new(0, 350, 0, 260)
MainFrame.ZIndex = 1
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Title.Text = "Phoenix Hub | فوري لـ Delta"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.Position = UDim2.new(0, 0, 0, 35)
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 0, 0, 70)
ContentFrame.Size = UDim2.new(1, 0, 1, -70)
ContentFrame.BackgroundTransparency = 1

local MovePage = Instance.new("ScrollingFrame")
local VisPage = Instance.new("ScrollingFrame")
local CombatPage = Instance.new("ScrollingFrame")

local pages = {MovePage, VisPage, CombatPage}
for _, page in pairs(pages) do
    page.Parent = ContentFrame
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 2.8, 0) -- زيادة مساحة السكرول لتستوعب الخصائص الإضافية بشكل مريح
    page.ScrollBarThickness = 4
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
end
MovePage.Visible = true

local function createTabBtn(text, pos, targetPage)
    local btn = Instance.new("TextButton")
    btn.Parent = TabBar
    btn.Size = UDim2.new(0.333, 0, 1, 0)
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        targetPage.Visible = true
    end)
    return btn
end

createTabBtn("الحركة", UDim2.new(0, 0, 0, 0), MovePage)
createTabBtn("الرؤية (ESP)", UDim2.new(0.333, 0, 0, 0), VisPage)
createTabBtn("القتال والميزات", UDim2.new(0.666, 0, 0, 0), CombatPage)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-----------------------------------------------------------------------------------------
-- دوال التصميم الداخلي الثابتة
-----------------------------------------------------------------------------------------
local function createTextbox(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox")
    box.Parent = frame
    box.Size = UDim2.new(0.3, 0, 0.7, 0)
    box.Position = UDim2.new(0.65, 0, 0.15, 0)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    box.Text = default
    box.TextColor3 = Color3.fromRGB(0, 255, 130)
    box.TextSize = 14
    box.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    
    box.FocusLost:Connect(function()
        callback(box.Text)
    end)
end

local function createToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0.3, 0, 0.7, 0)
    btn.Position = UDim2.new(0.65, 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 25, 25)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(25, 60, 25)
            btn.Text = "ON"
            btn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 25, 25)
            btn.Text = "OFF"
            btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
        callback(state)
    end)
end

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
end
-----------------------------------------------------------------------------------------
-- [1. خانة الحركة]
-----------------------------------------------------------------------------------------
createTextbox(MovePage, "تعديل السرعة (Speed)", "16", function(Value)
    local num = tonumber(Value)
    if num then TargetSpeed = num CustomSpeedEnabled = true else CustomSpeedEnabled = false end
end)

createTextbox(MovePage, "قوة القفز (Jump)", "50", function(Value)
    local num = tonumber(Value)
    if num then TargetJump = num CustomJumpEnabled = true else CustomJumpEnabled = false end
end)

local InfiniteJumpEnabled = false
createToggle(MovePage, "القفز اللانهائي", function(Value)
    InfiniteJumpEnabled = Value
end)

createToggle(MovePage, "اختراق الجدران (Noclip)", function(Value)
    NoclipEnabled = Value
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
    end
end)

-----------------------------------------------------------------------------------------
-- [2. خانة الرؤية ESP]
-----------------------------------------------------------------------------------------
local PlayerESPEnabled = false
createToggle(VisPage, "كشف اللاعبين (Player ESP)", function(Value)
    PlayerESPEnabled = Value
    if not PlayerESPEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("ESPHighlight") then v.Character.ESPHighlight:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if PlayerESPEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if not p.Character:FindFirstChild("ESPHighlight") then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESPHighlight"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.Parent = p.Character
                    end
                end
            end
        end
    end
end)

local ChestESPEnabled = false
createToggle(VisPage, "كشف الصناديق والأدوات", function(Value)
    ChestESPEnabled = Value
    if not ChestESPEnabled then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Highlight") and v.Name == "ChestHighlight" then v:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if ChestESPEnabled then
            for _, v in pairs(workspace:GetDescendants()) do
                pcall(function()
                    local isDroppedItem = v:IsA("Tool") and v.Parent == workspace
                    local isTargetPart = v:IsA("BasePart") and (v.Name:lower():find("chest") or v.Name:lower():find("box") or v.Name:lower():find("tool") or v.Name:lower():find("drop") or v.Name:lower():find("fruit"))
                    
                    if isDroppedItem or isTargetPart then
                        if not v:FindFirstChild("ChestHighlight") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ChestHighlight"
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.4
                            highlight.Parent = v
                        end
                    end
                end)
            end
        end
    end
end)

-----------------------------------------------------------------------------------------
-- [3. خانة القتال] - مضاف إليها ميزة الارتفاع الرأسي للآيم بوت الجديد وعلاج النوكليب
-----------------------------------------------------------------------------------------
local HitboxSize = 2
local HitboxEnabled = false
local LastHitboxState = false

createTextbox(CombatPage, "حجم الهيت بوكس (Size)", "2", function(Value)
    HitboxSize = tonumber(Value) or 2
end)

createToggle(CombatPage, "تفعيل تكبير الهيت بوكس", function(Value)
    HitboxEnabled = Value
end)

RunService.Heartbeat:Connect(function()
    pcall(function()
        if HitboxEnabled then
            LastHitboxState = true
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.BrickColor = BrickColor.new("Really blue")
                    hrp.CanCollide = false
                end
            end
        elseif LastHitboxState then
            LastHitboxState = false
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(2, 2, 2)
                    hrp.Transparency = 1
                    hrp.CanCollide = true
                end
            end
        end
    end)
end)

createToggle(CombatPage, "تفعيل الآيم بوت (Aimbot)", function(Value)
    AimbotEnabled = Value
end)

createToggle(CombatPage, "الآيم خلف الجدران", function(Value)
    AimBehindWalls = Value
end)

createTextbox(CombatPage, "مسافة رؤية الآيم (FOV)", "150", function(Value)
    AimbotFOV = tonumber(Value) or 150
end)

createTextbox(CombatPage, "سلاسة الآيم (Smoothness)", "1", function(Value)
    local num = tonumber(Value) or 1
    AimbotSmoothness = math.max(num, 1)
end)

-- إضافة إعداد تعديل ارتفاع الآيم (Y-Offset) الجديد بدون لمس تصميم الواجهة
createTextbox(CombatPage, "ارتفاع الكاميرا (Y-Offset)", "0", function(Value)
    AimbotYOffset = tonumber(Value) or 0
end)

-- دالة فحص وتأكيد صلاحية الهدف الحالي
local function IsValidTarget(p)
    if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or not p.Character:FindFirstChildOfClass("Humanoid") then
        return false
    end
    if p.Character.Humanoid.Health <= 0 then return false end
    
    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
    if not onScreen then return false end
    
    local mousePos = UserInputService:GetMouseLocation()
    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
    if distance > AimbotFOV then return false end
    
    if not AimBehindWalls then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, p.Character}
        
        local rayDirection = p.Character.HumanoidRootPart.Position - Camera.CFrame.Position
        local raycastResult = workspace:Raycast(Camera.CFrame.Position, rayDirection, raycastParams)
        if raycastResult then return false end
    end
    
    return true
end

-- دالة البحث عن أقرب هدف جديد
local function GetClosestTarget()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsValidTarget(p) then
            local pos = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
            if distance < ShortestDistance then
                ShortestDistance = distance
                ClosestPlayer = p
            end
        end
    end
    return ClosestPlayer
end

-- كود تتبع وتثبيت الكاميرا السلس والمستمر مع دمج قيمة الـ Y-Offset المخصصة للمابات
RunService.RenderStepped:Connect(function()
    pcall(function()
        if AimbotEnabled then
            if CurrentTarget and IsValidTarget(CurrentTarget) then
                -- الهدف مقفل ومستقر
            else
                CurrentTarget = GetClosestTarget()
            end
            
            if CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("Head") then
                -- دمج الارتفاع المكتوب في خانة الـ Y-Offset لمعادلة كاميرا الماب تلقائياً
                local targetPos = CurrentTarget.Character.Head.Position + Vector3.new(0, AimbotYOffset, 0)
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                
                if AimbotSmoothness <= 1 then
                    Camera.CFrame = targetCFrame
                else
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / AimbotSmoothness)
                end
            end
        else
            CurrentTarget = nil
        end
    end)
end)

createButton(CombatPage, "تفعيل منع الطرد (Anti-AFK)", function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)
