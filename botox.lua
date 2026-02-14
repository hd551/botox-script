--[[ 
   DIVINE DUALITY - OPTIMIZED VERSION
   - تم تحسين الأداء (Anti-Lag)
   - تم إضافة نظام حماية ضد الانهيار (Nil Checks)
   - الزر والواجهة بشكل أكثر استقراراً
]]

local MaxDistance = 150 
local AimEnabled = true

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- 1. إنشاء الواجهة (GUI)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Button = Instance.new("TextButton", ScreenGui)
local Corner = Instance.new("UICorner", Button)
local UIStroke = Instance.new("UIStroke", Button)

Button.Size = UDim2.new(0, 150, 0, 35)
Button.Position = UDim2.new(0.5, -75, 0.1, 0)
Button.Text = "SILENT AIM: ON"
Button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Button.TextColor3 = Color3.fromRGB(0, 255, 255)
Button.Font = Enum.Font.Code
Button.TextSize = 14
Button.Active = true
Button.Draggable = true -- ملاحظة: يفضل استخدام UIS مستقبلاً لكن أبقيتها لسهولة طلبك

Corner.CornerRadius = UDim.new(0, 10)
UIStroke.Color = Color3.fromRGB(0, 255, 255)
UIStroke.Thickness = 2

Button.MouseButton1Click:Connect(function()
    AimEnabled = not AimEnabled
    Button.Text = AimEnabled and "SILENT AIM: ON" or "SILENT AIM: OFF"
    Button.TextColor3 = AimEnabled and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 50, 50)
    UIStroke.Color = AimEnabled and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(255, 50, 50)
end)

-- 2. تحسين نظام الـ ESP (أكثر كفاءة)
local function AddESP(plr)
    local function CreateHighlight()
        if plr ~= player and plr.Character then
            local hl = plr.Character:FindFirstChild("SilentESP") or Instance.new("Highlight")
            hl.Name = "SilentESP"
            hl.Parent = plr.Character
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.5
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Enabled = true
        end
    end
    plr.CharacterAdded:Connect(function()
        task.wait(0.5) -- انتظار تحميل الشخصية
        CreateHighlight()
    end)
    if plr.Character then CreateHighlight() end
end

for _, v in pairs(game:GetService("Players"):GetPlayers()) do AddESP(v) end
game:GetService("Players").PlayerAdded:Connect(AddESP)

-- 3. وظيفة جلب الهدف مع "تحقق الأمان" (Safe Check)
local function getClosestPlayer()
    local target = nil
    local shortestDistance = math.huge
    
    -- تحقق إذا كانت شخصيتك موجودة لتجنب الانهيار (Error)
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                -- حساب المسافة بينك وبين الخصم
                local mag = (myRoot.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if mag <= MaxDistance then
                    -- حساب المسافة بين الماوس والخصم على الشاشة
                    local screenPos, onScreen = camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            target = v
                        end
                    end
                end
            end
        end
    end
    return target
end

-- 4. نظام الـ Silent Aim (Core)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, index)
    -- التحقق من أن السكربت هو من ينادي الوظيفة وليس اللعبة نفسها
    if AimEnabled and self == mouse and not checkcaller() then
        if index == "Hit" or index == "Target" then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local aimPos = target.Character.HumanoidRootPart.Position
                
                if index == "Hit" then
                    return CFrame.new(aimPos)
                elseif index == "Target" then
                    return target.Character.HumanoidRootPart
                end
            end
        end
    end
    return oldIndex(self, index)
end)
