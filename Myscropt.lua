-- ═══════════════════════════════════════════════════════════════
-- SPECTRE MOTO FARM v2.0 (NOCLIP CORRIGIDO)
-- ═══════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer
local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")

local isRunning = false

local function getHRP() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end

local function findPart(index)
    local formattedName = string.format("Coleta_%02d", index)
    local ilegal = Workspace:FindFirstChild("Ilegal")
    local farm = ilegal and ilegal:FindFirstChild("PartsFarmSettings")
    return farm and farm:FindFirstChild(formattedName)
end

-- ── FUNÇÃO DO VOO DA MOTO ──────────────────────────────────
local function goToPart(index)
    if isRunning then return end
    local hum = getHum()
    if not hum then return end

    local part = findPart(index)
    if not part then return end

    local seatPart = hum.SeatPart
    if not seatPart then
        StarterGui:SetCore("SendNotification", {Title="Aviso", Text="Sobe na moto primeiro!", Duration=3})
        return
    end

    local vehicle = seatPart:FindFirstAncestorOfClass("Model") or seatPart.Parent
    if not vehicle then return end

    isRunning = true
    local targetPos = part.Position + Vector3.new(0, 3, 0)
    local mainPart = vehicle.PrimaryPart or seatPart
    
    -- 1. Salva a colisão original de TODAS as partes do veículo
    local originalCollisions = {}
    for _, v in ipairs(vehicle:GetDescendants()) do
        if v:IsA("BasePart") then
            originalCollisions[v] = v.CanCollide
            v.CanCollide = false -- Atravessa paredes
        end
    end

    -- 2. Cria o motor do voo
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FarmMotoVelocity"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = mainPart

    local conn
    conn = RunService.Heartbeat:Connect(function()
        -- Se o script parou ou o jogador caiu da moto
        if not isRunning or hum.SeatPart ~= seatPart then
            isRunning = false
            if bv then bv:Destroy() end
            -- Devolve a colisão pra não cair no void
            for p, c in pairs(originalCollisions) do if p.Parent then p.CanCollide = c end end
            if conn then conn:Disconnect() end
            return
        end

        local dist = (targetPos - mainPart.Position).Magnitude
        
        -- 3. Chegou na peça: Para o voo e pousa
        if dist <= 10 then
            isRunning = false
            if bv then bv:Destroy() end
            
            -- Trava a velocidade
            mainPart.AssemblyLinearVelocity = Vector3.zero
            mainPart.AssemblyAngularVelocity = Vector3.zero
            
            -- Devolve a colisão pra moto cair no chão
            for p, c in pairs(originalCollisions) do 
                if p.Parent then p.CanCollide = c end 
            end
            
            if conn then conn:Disconnect() end
            return
        end

        -- 4. Calcula a velocidade (se tiver perto, vai devagar; se tiver longe, vai rápido)
        local direction = (targetPos - mainPart.Position).Unit
        local speed = math.clamp(dist * 2, 50, 200) 
        
        bv.Velocity = direction * speed
        mainPart.CFrame = CFrame.lookAt(mainPart.Position, targetPos)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- UI CONSTRUCTION
-- ═══════════════════════════════════════════════════════════════
local guiName = "MotoFarmMenu_" .. LP.UserId
local old = CoreGui:FindFirstChild(guiName)
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end

local ACCENT = Color3.fromRGB(0, 255, 150)
local BG = Color3.fromRGB(15, 15, 15)

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 220, 0, 400)
main.Position = UDim2.new(0.5, -110, 0.5, -200)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mStroke = Instance.new("UIStroke", main)
mStroke.Color = ACCENT
mStroke.Thickness = 2

local top = Instance.new("Frame", main)
top.Size = UDim2.new(1, 0, 0, 40)
top.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
top.BorderSizePixel = 0
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "MOTO FARM v2.0"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 12

local closeBtn = Instance.new("TextButton", top)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16

-- Botão flutuante de toggle
local floatBtn = Instance.new("TextButton", gui)
floatBtn.Size = UDim2.new(0, 45, 0, 45)
floatBtn.Position = UDim2.new(0, 20, 0.5, -20)
floatBtn.BackgroundColor3 = BG
floatBtn.Text = "AF"
floatBtn.TextColor3 = ACCENT
floatBtn.Font = Enum.Font.GothamBold
floatBtn.TextSize = 16
floatBtn.BorderSizePixel = 0
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
local fStroke = Instance.new("UIStroke", floatBtn)
fStroke.Color = ACCENT; fStroke.Thickness = 2
floatBtn.Visible = false

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    floatBtn.Visible = true
end)

floatBtn.MouseButton1Click:Connect(function()
    main.Visible = true
    floatBtn.Visible = false
end)

-- Container de scroll
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 45)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2
scroll.ScrollBarImageColor3 = ACCENT
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local ll = Instance.new("UIListLayout", scroll)
ll.Padding = UDim.new(0, 6)
ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y)
end)

-- Arrastar GUI
local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
top.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Botões das Peças
for i = 1, 14 do
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = "Voar p/ Coleta " .. string.format("%02d", i)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Color3.fromRGB(60, 60, 60)
    bStroke.Thickness = 1

    btn.MouseButton1Click:Connect(function()
        bStroke.Color = ACCENT
        task.delay(0.5, function() bStroke.Color = Color3.fromRGB(60, 60, 60) end)
        goToPart(i)
    end)
end
