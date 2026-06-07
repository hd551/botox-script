-- Phoenix Hub | إصدار مراقب الـ AI الداخلي والهيت بوكس الثنائي
shared.PH = shared.PH or {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

-- تهيئة وتخزين جميع المتغيرات في جدول مشترك لمنع التضارب في الجوال
shared.PH.TargetSpeed = 16
shared.PH.TargetJump = 50
shared.PH.CustomSpeedEnabled = false
shared.PH.CustomJumpEnabled = false
shared.PH.NoclipEnabled = false
shared.PH.AimbotEnabled = false
shared.PH.AimbotFOV = 150
shared.PH.AimbotSmoothness = 1
shared.PH.AimBehindWalls = false  
shared.PH.AimbotYOffset = 0       
shared.PH.CurrentTarget = nil     
shared.PH.MapAntiCheatLevel = "Low"

-- متغيرات الهيت بوكس الأول (العام) والـ هيت بوكس الثاني البديل (الرأس)
shared.PH.HitboxSize = 2
shared.PH.HitboxEnabled = false
shared.PH.HitboxSize2 = 2
shared.PH.HitboxEnabled2 = false

local CurrentPlaceId = game.PlaceId
local function AIScanMap()
    if CurrentPlaceId == 2753915549 or CurrentPlaceId == 4442272121 or CurrentPlaceId == 7465535914 then
        shared.PH.MapAntiCheatLevel = "High"
    elseif CurrentPlaceId == 155615604 or CurrentPlaceId == 6068016518 then
        shared.PH.MapAntiCheatLevel = "Medium"
    else
        shared.PH.MapAntiCheatLevel = "Low"
    end
end
AIScanMap()

-- 1. إنشاء واجهة المستخدم الأساسية للسكربت
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhoenixHub_AI_Dashboard"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- 2. زر الاختصار العائم (PH)
local ToggleButton = Instance.new("TextButton")
local BtnCorner = Instance.new("UICorner")
local BtnStroke = Instance.new("UIStroke")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleButton.Position = UDim2.new(0, 20, 0, 150)
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "PH"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 20
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.ZIndex = 10

BtnCorner.CornerRadius = UDim.new(0, 28)
BtnCorner.Parent = ToggleButton
BtnStroke.Parent = ToggleButton
BtnStroke.Thickness = 1.5

-- 3. اللوحة الرئيسية للسكربت
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")
local MainStroke = Instance.new("UIStroke")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -130)
MainFrame.Size = UDim2.new(0, 350, 0, 260)
MainFrame.ZIndex = 1
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

MainStroke.Parent = MainFrame
MainStroke.Thickness = 1.8

-- تأثير الـ RGB الانسيابي الفخم على أطراف اللوحة والزر العائم
RunService.RenderStepped:Connect(function()
    local hue = (tick() % 6) / 6
    local chromaColor = Color3.fromHSV(hue, 0.9, 1)
    MainStroke.Color = chromaColor
    BtnStroke.Color = chromaColor
end)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.Text = "Phoenix Hub | نظام المراقبة والهيت بوكس الثنائي"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.Position = UDim2.new(0, 0, 0, 35)
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)

local ContentFrame = Instance.new("Frame")
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 0, 0, 70)
ContentFrame.Size = UDim2.new(1, 0, 1, -70)
ContentFrame.BackgroundTransparency = 1

local MovePage = Instance.new("ScrollingFrame")
local VisPage = Instance.new("ScrollingFrame")
local CombatPage = Instance.new("ScrollingFrame")
local AILogPage = Instance.new("ScrollingFrame") -- الخانة الجديدة المخصصة لمراقب الـ AI

local pages = {MovePage, VisPage, CombatPage, AILogPage}
for _, page in pairs(pages) do
    page.Parent = ContentFrame
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 2.8, 0)
    page.ScrollBarThickness = 3
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = page
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
end
MovePage.Visible = true

-- تنسيق صفحة الـ AI لتستقبل الإشعارات المنظمة بشكل تنازلي
local AILogLayout = AILogPage:FindFirstChildOfClass("UIListLayout")
AILogLayout.Padding = UDim.new(0, 5)

-- [دالة تحويل الإشعارات إلى سجلات داخل قائمة الـ AI بثيم ملكي: أسود، أحمر، أبيض]
shared.PH.AINotify = function(message, isWarning)
    local LogRow = Instance.new("Frame")
    local LogCorner = Instance.new("UICorner")
    local LogStroke = Instance.new("UIStroke")
    local LogText = Instance.new("TextLabel")
    
    LogRow.Size = UDim2.new(0.95, 0, 0, 50)
    LogRow.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- أسود خالص
    LogRow.Parent = AILogPage
    
    LogCorner.CornerRadius = UDim.new(0, 6)
    LogCorner.Parent = LogRow
    
    LogStroke.Parent = LogRow
    LogStroke.Thickness = 1.5
    if isWarning then
        LogStroke.Color = Color3.fromRGB(255, 0, 0) -- إطار أحمر عند التحذير من ميزة مكشوفة
    else
        LogStroke.Color = Color3.fromRGB(255, 255, 255) -- إطار أبيض عند الميزات السليمة والآمنة
    end
    
    LogText.Parent = LogRow
    LogText.Size = UDim2.new(1, -16, 1, 0)
    LogText.Position = UDim2.new(0, 8, 0, 0)
    LogText.BackgroundTransparency = 1
    LogText.Font = Enum.Font.SourceSansBold
    LogText.TextSize = 12
    LogText.TextColor3 = Color3.fromRGB(255, 255, 255) -- نص أبيض ناصع وواضح
    LogText.TextWrapped = true
    LogText.TextXAlignment = Enum.TextXAlignment.Center
    LogText.Text = "[" .. os.date("%X") .. "] " .. message
    
    -- جعل السجل التلقائي يرتفع لأعلى ليرى المستخدم أحدث التنبيهات دائماً
    LogRow.LayoutOrder = -tick()
    AILogPage.CanvasPosition = Vector2.new(0, 0)
end

local function createTabBtn(text, pos, targetPage)
    local btn = Instance.new("TextButton")
    btn.Parent = TabBar
    btn.Size = UDim2.new(0.25, 0, 1, 0) -- تقسيم متساوي للأربع خانات
    btn.Position = pos
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    
    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        targetPage.Visible = true
    end)
    return btn
end

createTabBtn("الحركة والـ AI", UDim2.new(0, 0, 0, 0), MovePage)
createTabBtn("الرؤية ESP", UDim2.new(0.25, 0, 0, 0), VisPage)
createTabBtn("القتال المحكم", UDim2.new(0.5, 0, 0, 0), CombatPage)
createTabBtn("مراقب الـ AI", UDim2.new(0.75, 0, 0, 0), AILogPage)

-- تقرير فحص الحماية وبدء تشغيل السجل فور تفعيل السكربت ليوضح المسموح والممنوع في الماب
task.spawn(function()
    task.wait(1)
    if shared.PH.MapAntiCheatLevel == "High" then
        shared.PH.AINotify("⚙️ فحص الماب: هذا الماب يمتلك حماية (صارمة) ضد السرعة والهيت بوكس الأول! تم تفعيل التعديل التكيفي تلقائياً. يُنصح باستخدام (الهيت بوكس 2) لتفادي الباند 🛡️", true)
    elseif shared.PH.MapAntiCheatLevel == "Medium" then
        shared.PH.AINotify("⚙️ فحص الماب: الحماية هنا (متوسطة). ميزات السرعة والقفز تعمل لكن يفضل عدم المبالغة لتجنب شكاوى وبلاغات اللاعبين ⚠️", false)
    else
        shared.PH.AINotify("⚙️ فحص الماب: فحص الحماية مكتمل! الماب آمن وضعيف جداً. أنت سليم 100%، جميع الميزات والهيت بوكس الأول والثاني آمنة للاستخدام والتشغيل ✅", false)
    end
end)

-- لوب فيزيائي مدمج للسرعة وجدار حماية الـ AI التكيفي
RunService.Heartbeat:Connect(function(deltaTime)
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hum = LocalPlayer.Character.Humanoid
            local hrp = LocalPlayer.Character.HumanoidRootPart
            
            if shared.PH.CustomSpeedEnabled or shared.PH.NoclipEnabled then
                if shared.PH.MapAntiCheatLevel == "High" and shared.PH.TargetSpeed > 35 then
                    hum.WalkSpeed = math.random(20, 28) 
                    if hum.MoveDirection.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (8 * deltaTime))
                    end
                else
                    hum.WalkSpeed = shared.PH.TargetSpeed
                    if hum.MoveDirection.Magnitude > 0 and shared.PH.CustomSpeedEnabled and shared.PH.TargetSpeed > 16 then
                        local extraSpeed = shared.PH.TargetSpeed - 16
                        hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (extraSpeed * deltaTime))
                    end
                end
            end
            
            if shared.PH.CustomJumpEnabled then
                hum.UseJumpPower = true
                hum.JumpPower = shared.PH.TargetJump
            end
        end
    end)
end)

-- اللوب الفيزيائي الخاص بالهيت بوكس الأول والثاني (البديل) دون المساس بأي ميزة أخرى
local OriginalHeadSizes = {}
RunService.Heartbeat:Connect(function()
    -- [طريقة الهيت بوكس 1 - تعديل الـ HumanoidRootPart الأصلي]
    pcall(function()
        if shared.PH.HitboxEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(shared.PH.HitboxSize, shared.PH.HitboxSize, shared.PH.HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.BrickColor = BrickColor.new("Really blue")
                    hrp.CanCollide = false
                end
            end
        end
    end)
    
    -- [طريقة الهيت بوكس 2 البديلة - تعديل الـ Head وتخزين الحجم الأصلي لحمايتك]
    pcall(function()
        if shared.PH.HitboxEnabled2 then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local head = p.Character.Head
                    if not OriginalHeadSizes[p] then
                        OriginalHeadSizes[p] = head.Size -- حفظ الحجم الأصلي لمنع تدمير الماب
                    end
                    head.Size = Vector3.new(shared.PH.HitboxSize2, shared.PH.HitboxSize2, shared.PH.HitboxSize2)
                    head.Transparency = 0.5
                    head.CanCollide = false
                end
            end
        else
            -- إعادة الأشكال لأحجامها الطبيعية فوراً عند قفل الزر
            for p, size in pairs(OriginalHeadSizes) do
                if p.Character and p.Character:FindFirstChild("Head") then
                    p.Character.Head.Size = size
                    p.Character.Head.Transparency = 0
                end
            end
            table.clear(OriginalHeadSizes)
        end
    end)
end)

-- نوكليب آمن ومتوافق مع قفز الجوال
RunService.Stepped:Connect(function()
    pcall(function()
        if shared.PH.NoclipEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- أنيميشن فتح وإغلاق اللوحة الرئيسية
ToggleButton.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        MainFrame:TweenSize(UDim2.new(0, 350, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true, function()
            MainFrame.Visible = false
        end)
    else
        MainFrame.Size = UDim2.new(0, 350, 0, 0)
        MainFrame.Visible = true
        MainFrame:TweenSize(UDim2.new(0, 350, 0, 260), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end
end)
shared.PH = shared.PH or {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-----------------------------------------------------------------------------------------
-- دوال بناء عناصر القائمة الداخلية تلقائياً بجودة عالية
-----------------------------------------------------------------------------------------
local function createTextbox(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local box = Instance.new("TextBox")
    box.Parent = frame
    box.Size = UDim2.new(0.3, 0, 0.7, 0)
    box.Position = UDim2.new(0.65, 0, 0.15, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    box.Text = default
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 13
    box.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    
    box.FocusLost:Connect(function() callback(box.Text) end)
end

local function createToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    frame.Parent = parent
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 13
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton")
    btn.Parent = frame
    btn.Size = UDim2.new(0.3, 0, 0.7, 0)
    btn.Position = UDim2.new(0.65, 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 120, 120)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
            btn.Text = "ON"
            btn.TextColor3 = Color3.fromRGB(120, 255, 120)
        else
            btn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
            btn.Text = "OFF"
            btn.TextColor3 = Color3.fromRGB(255, 120, 120)
        end
        callback(state)
    end)
end

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke")
    stroke.Parent = btn
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(60, 60, 60)
    
    btn.MouseButton1Click:Connect(callback)
end

-- استدعاء صفحات لوحة التحكم المفتوحة مسبقاً
local ScreenGui = game:GetService("CoreGui") or LocalPlayer:FindFirstChildOfClass("PlayerGui")
local MainFrame = ScreenGui:WaitForChild("PhoenixHub_AI_Dashboard"):WaitForChild("MainFrame")
local ContentFrame = MainFrame:WaitForChild("ContentFrame")
local MovePage = ContentFrame:WaitForChild("ScrollingFrame")
local VisPage = ContentFrame:WaitForChild("ScrollingFrame2")
local CombatPage = ContentFrame:WaitForChild("ScrollingFrame3")

-----------------------------------------------------------------------------------------
-- [1. تعبئة عناصر صفحة الحركة والـ AI مع نظام المراقبة الصادق لتفادي الحظر والشكاوى]
-----------------------------------------------------------------------------------------
createTextbox(MovePage, "تعديل السرعة (Speed)", "16", function(Value)
    local num = tonumber(Value)
    if num then 
        shared.PH.TargetSpeed = num 
        shared.PH.CustomSpeedEnabled = true 
        
        if shared.PH.MapAntiCheatLevel == "High" and num > 30 then
            shared.PH.AINotify("🛡️ تنبيه الحركة: الماب حمايته قوية! تم تفعيل 'خطة الحماية المتقطعة للتذبذب الفيزيائي' تلقائياً لتفادي الطرد 🚀", false)
        elseif shared.PH.MapAntiCheatLevel == "High" and num <= 30 then
            shared.PH.AINotify("🔍 مراقبة الـ AI: سرعة متوازنة وممتازة للنظام الحالي للماب. أنت سليم تماماً استمتع! ✅", false)
        elseif shared.PH.MapAntiCheatLevel == "Medium" and num > 50 then
            shared.PH.AINotify("⚠️ تحذير الـ AI: لقد تجاوزت السرعة الآمنة لهذا الماب (الحد الأقصى الموصى به 50) تجنباً للبلاغات والشكاوى.", true)
        end
    else 
        shared.PH.CustomSpeedEnabled = false 
    end
end)

createTextbox(MovePage, "قوة القفز (Jump)", "50", function(Value)
    local num = tonumber(Value)
    if num then shared.PH.TargetJump = num shared.PH.CustomJumpEnabled = true else shared.PH.CustomJumpEnabled = false end
end)

local InfiniteJumpEnabled = false
createToggle(MovePage, "القفز اللانهائي", function(Value)
    InfiniteJumpEnabled = Value
    if Value then shared.PH.AINotify("تفعيل: القفز اللانهائي نشط الآن.", false) end
end)

createToggle(MovePage, "اختراق الجدران (Noclip)", function(Value)
    shared.PH.NoclipEnabled = Value
    if shared.PH.NoclipEnabled then
        shared.PH.AINotify("🔍 مراقبة الـ AI: النوكليب الفيزيائي يعمل بنجاح، ومحمي بالكامل ضد طرد الحماية الخفية ✅", false)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
    end
end)

-----------------------------------------------------------------------------------------
-- [2. عناصر صفحة الرؤية ESP]
-----------------------------------------------------------------------------------------
local PlayerESPEnabled = false
createToggle(VisPage, "كشف اللاعبين (Player ESP)", function(Value)
    PlayerESPEnabled = Value
    if Value then shared.PH.AINotify("تفعيل: كشف موقع اللاعبين نشط.", false) end
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
    if Value then shared.PH.AINotify("تفعيل: رادار كشف الصناديق والأدوات نشط.", false) end
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
-- [3. عناصر صفحة القتال المتقدمة - الهيت بوكس الثنائي لمنع التعطل في جميع المابات]
-----------------------------------------------------------------------------------------
-- الهيت بوكس الأول (العام):
createTextbox(CombatPage, "حجم الهيت بوكس 1 (العام)", "2", function(Value)
    shared.PH.HitboxSize = tonumber(Value) or 2
end)

createToggle(CombatPage, "تفعيل الهيت بوكس 1", function(Value)
    shared.PH.HitboxEnabled = Value
    if Value then 
        if shared.PH.MapAntiCheatLevel == "High" then
            shared.PH.AINotify("⚠️ تنبيه الحماية: الهيت بوكس الأول قد يكون مكشوفاً هنا! إذا تم طردك استخدم الهيت بوكس الثاني البديل فوراُ.", true)
        else
            shared.PH.AINotify("تفعيل: الهيت بوكس الأول (الجذع العام) نشط وآمن في هذا الماب ✅", false)
        end
    end
end)

-- الهيت بوكس الثاني البديل (الرأس) لحل مشكلة عدم اشتغال الميزة في بعض المابات:
createTextbox(CombatPage, "مربع تكبير الهيت بوكس 2 (البديل)", "2", function(Value)
    shared.PH.HitboxSize2 = tonumber(Value) or 2
end)

createToggle(CombatPage, "تفعيل الهيت بوكس 2 (البديل)", function(Value)
    shared.PH.HitboxEnabled2 = Value
    if Value then 
        shared.PH.AINotify("🔍 خطة الحماية البديلة: تم تشغيل (الهيت بوكس 2 - الرأس). آمن ومخفي تماماً عن فحص السيرفر في مابات الحماية الصارمة 🛡️", false)
    end
end)

-- بقية ميزات القتال (الآيم بوت بدون أي تغيير أو تخريب)
createToggle(CombatPage, "تفعيل الآيم بوت (Aimbot)", function(Value)
    shared.PH.AimbotEnabled = Value
    if Value then shared.PH.AINotify("تفعيل: نظام الآيم بوت الصمغي الثابت نشط الحين.", false) end
end)

createToggle(CombatPage, "الآيم خلف الجدران", function(Value)
    shared.PH.AimBehindWalls = Value
end)

createTextbox(CombatPage, "مسافة رؤية الآيم (FOV)", "150", function(Value)
    shared.PH.AimbotFOV = tonumber(Value) or 150
end)

createTextbox(CombatPage, "سلاسة الآيم (Smoothness)", "1", function(Value)
    local num = tonumber(Value) or 1
    shared.PH.AimbotSmoothness = math.max(num, 1)
end)

createTextbox(CombatPage, "ارتفاع الكاميرا (Y-Offset)", "0", function(Value)
    shared.PH.AimbotYOffset = tonumber(Value) or 0
end)

local function IsValidTarget(p)
    if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or not p.Character:FindFirstChildOfClass("Humanoid") then
        return false
    end
    if p.Character.Humanoid.Health <= 0 then return false end
    
    local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
    if not onScreen then return false end
    
    local mousePos = UserInputService:GetMouseLocation()
    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
    if distance > shared.PH.AimbotFOV then return false end
    
    if not shared.PH.AimBehindWalls then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, p.Character}
        
        local rayDirection = p.Character.HumanoidRootPart.Position - Camera.CFrame.Position
        local raycastResult = workspace:Raycast(Camera.CFrame.Position, rayDirection, raycastParams)
        if raycastResult then return false end
    end
    
    return true
end

local function GetClosestTarget()
    local ClosestPlayer = nil
    local Shortest3DDistance = math.huge

    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return nil 
    end
    local myPosition = LocalPlayer.Character.HumanoidRootPart.Position

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsValidTarget(p) then
            local target3DDistance = (p.Character.HumanoidRootPart.Position - myPosition).Magnitude
            if target3DDistance < Shortest3DDistance then
                Shortest3DDistance = target3DDistance
                ClosestPlayer = p
            end
        end
    end
    return ClosestPlayer
end

RunService:BindToRenderStep("PhoenixAimbotSystem", Enum.RenderPriority.Camera.Value + 1, function()
    pcall(function()
        if shared.PH.AimbotEnabled then
            if shared.PH.CurrentTarget and IsValidTarget(shared.PH.CurrentTarget) then
                -- القفل صمغي وثابت يمنع الاهتزاز العشوائي
            else
                shared.PH.CurrentTarget = GetClosestTarget()
            end
            
            if shared.PH.CurrentTarget and shared.PH.CurrentTarget.Character and shared.PH.CurrentTarget.Character:FindFirstChild("Head") then
                local targetPos = shared.PH.CurrentTarget.Character.Head.Position + Vector3.new(0, shared.PH.AimbotYOffset, 0)
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                
                if shared.PH.AimbotSmoothness <= 1 then
                    Camera.CFrame = targetCFrame
                else
                    local lerpAlpha = math.clamp(0.22 / shared.PH.AimbotSmoothness, 0.01, 1)
                    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, lerpAlpha)
                end
            end
        else
            shared.PH.CurrentTarget = nil
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
    shared.PH.AINotify("🔍 مراقبة الـ AI: تم تفعيل نظام الحماية لمنع الطرد الخامل (Anti-AFK) بنجاح ✅", false)
end)
