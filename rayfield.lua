-- ═══════════════════════════════════════════════════════════════
-- JOAOZIN MENU — Rayfield UI
-- ═══════════════════════════════════════════════════════════════

-- ── GameId check ───────────────────────────────────────────
local secureTargetId = tonumber("6490016198")
if game.GameId ~= secureTargetId and game.PlaceId ~= secureTargetId then
    warn("[joaozin menu] Jogo errado. PlaceId: " .. tostring(game.PlaceId))
    return
end

-- ── Carrega Rayfield com fallback ──────────────────────────
local Rayfield
local sources = {
    "https://raw.githubusercontent.com/shlexware/Rayfield/main/source",
    "https://sirius.menu/rayfield",
    "https://raw.githubusercontent.com/Footagesus/Rayfield/main/source",
}
for _, url in ipairs(sources) do
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if ok and res and type(res) == "table" and res.CreateWindow then
        Rayfield = res
        print("[joaozin] Rayfield OK: " .. url)
        break
    end
end
if not Rayfield then
    warn("[joaozin] Nenhuma URL do Rayfield funcionou. Verifica conexão do executor.")
    return
end

-- ── Janela ─────────────────────────────────────────────────
local Window = Rayfield:CreateWindow({
    Name = "joaozin menu",
    LoadingTitle = "joaozin menu",
    LoadingSubtitle = "carregando...",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = nil,
        FileName = "joaozin_cfg"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false,
})

-- ── Serviços ───────────────────────────────────────────────
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Workspace  = game:GetService("Workspace")
local Lighting   = game:GetService("Lighting")
local LP         = Players.LocalPlayer

-- ── Kill Basic Admin ───────────────────────────────────────
task.spawn(function()
    local ps = LP:WaitForChild("PlayerScripts", 10)
    if not ps then return end
    local ba = ps:FindFirstChild("Basic Admin Client")
    if ba then ba:Destroy() return end
    ba = ps:WaitForChild("Basic Admin Client", 10)
    if ba then ba:Destroy() end
end)

-- ── Helpers ────────────────────────────────────────────────
local function getChar() return LP.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function hasTool(name)
    local c = getChar()
    if c and c:FindFirstChild(name) then return c:FindFirstChild(name) end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp and bp:FindFirstChild(name) then return bp:FindFirstChild(name) end
    return nil
end
local function equip(tool)
    local hum = getHum()
    if hum and tool then pcall(function() hum:EquipTool(tool) end) end
end
local function useTool(tool)
    if not tool then return end
    local atk = tool:FindFirstChild("Attack")
    if atk and atk:IsA("RemoteEvent") then
        pcall(function() atk:FireServer() end)
    else
        pcall(function() tool:Activate() end)
    end
end
local function firePrompt(prompt)
    if not prompt then return end
    pcall(function() fireproximityprompt(prompt) end)
    pcall(function()
        if prompt.Triggered then
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end
    end)
end
local function fireTouch(part, obj)
    if not firetouchinterest then return end
    pcall(function()
        firetouchinterest(part, obj, 0)
        task.wait(0.05)
        firetouchinterest(part, obj, 1)
    end)
end

-- ── Tabs ───────────────────────────────────────────────────
local MainTab     = Window:CreateTab("Main", 4483362458)
local AutofarmTab = Window:CreateTab("Autofarm", 4483362458)
local PlayerTab   = Window:CreateTab("Player", 4483362458)
local MiscTab     = Window:CreateTab("Misc", 4483362458)
local PvpTab      = Window:CreateTab("PvP", 4483362458)
local VisualsTab  = Window:CreateTab("Visuals", 4483362458)

Rayfield:Notify({
    Title = "joaozin menu",
    Content = "Carregado com sucesso.",
    Duration = 4,
    Image = 4483362458,
})

-- ── MAIN ACTIONS ───────────────────────────────────────────
local function StealMoneyAction()
    local ts = Workspace:FindFirstChild("TycoonSets")
    if not ts then return end
    local hrp = getHRP()
    if not hrp then return end
    for _, obj in ipairs(ts:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Giver" then
            fireTouch(hrp, obj)
        end
    end
end

local function BringToolsAction()
    local hrp = getHRP()
    if not hrp then return end
    local names = { ["Wood"] = true, ["Mishirin Ore"] = true, ["Raw Meat"] = true }
    for _, obj in ipairs(Workspace:GetChildren()) do
        if names[obj.Name] and obj:IsA("Tool") then
            local h = obj:FindFirstChild("Handle")
            if h and h:IsA("BasePart") and not h.Anchored then
                pcall(function()
                    if h.CanSetNetworkOwnership and h:CanSetNetworkOwnership() then
                        h:SetNetworkOwner(LP)
                    end
                    local old = hrp.CFrame
                    hrp.CFrame = h.CFrame
                    task.wait(0.05)
                    hrp.CFrame = old
                end)
            end
        end
    end
end

local function SetPlayersVisible(v)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    pcall(function() part.Transparency = v and 0 or 1 end)
                end
            end
        end
    end
end

local function SellMaterialsAction()
    local ls = LP:FindFirstChild("leaderstats")
    local cash = ls and ls:FindFirstChild("Cash")
    local ic = cash and tostring(cash.Value) or nil
    local hrp = getHRP()
    if not hrp then return end
    local old = hrp.CFrame
    SetPlayersVisible(false)

    hrp.CFrame = CFrame.new(-512, 392, -152)
    task.wait(0.1)
    local lj = Workspace:FindFirstChild("Lumberjack")
    local p1 = lj and lj:FindFirstChild("ProxPrompt", true)
    if p1 and p1:IsA("ProximityPrompt") then
        p1.HoldDuration = 0
        p1.MaxActivationDistance = 10000
        p1.KeyboardKeyCode = Enum.KeyCode.F
        local t = tick()
        while tick() - t < 1.5 do
            firePrompt(p1)
            if cash and tostring(cash.Value) ~= ic then break end
            task.wait(0.05)
        end
    end

    ic = cash and tostring(cash.Value) or ic
    hrp.CFrame = CFrame.new(-87, 395, 57)
    task.wait(0.1)
    local mn = Workspace:FindFirstChild("Miner")
    local p2 = mn and mn:FindFirstChild("ProxPrompt", true)
    if p2 and p2:IsA("ProximityPrompt") then
        p2.RequiresLineOfSight = false
        p2.KeyboardKeyCode = Enum.KeyCode.F
        p2.HoldDuration = 0
        p2.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
        p2.MaxActivationDistance = 100
        local t = tick()
        while tick() - t < 1.5 do
            firePrompt(p2)
            if cash and tostring(cash.Value) ~= ic then break end
            task.wait(0.05)
        end
    end

    hrp.CFrame = old
    SetPlayersVisible(true)
end

MainTab:CreateButton({
    Name = "Steal Money",
    Callback = function()
        StealMoneyAction()
        Rayfield:Notify({ Title = "joaozin", Content = "Steal Money executado", Duration = 2 })
    end
})
MainTab:CreateButton({
    Name = "Sell Materials",
    Callback = function()
        SellMaterialsAction()
        Rayfield:Notify({ Title = "joaozin", Content = "Materiais vendidos", Duration = 2 })
    end
})
MainTab:CreateButton({
    Name = "Bring Dropped Items",
    Callback = function()
        BringToolsAction()
        Rayfield:Notify({ Title = "joaozin", Content = "Itens trazidos", Duration = 2 })
    end
})

-- ── AUTO STEAL ─────────────────────────────────────────────
local autoSteal = false
AutofarmTab:CreateToggle({
    Name = "Auto Steal",
    CurrentValue = false,
    Flag = "autosteal",
    Callback = function(state)
        autoSteal = state
        Rayfield:Notify({ Title = "joaozin", Content = state and "Auto Steal ON" or "Auto Steal OFF", Duration = 2 })
        if state then
            task.spawn(function()
                while autoSteal do
                    pcall(StealMoneyAction)
                    task.wait(60)
                end
            end)
        end
    end
})

-- ── AUTO WOODS ─────────────────────────────────────────────
local autoWoods = false
local modTrees = {}
local woodsFloat

local function getHatchet()
    local c = getChar()
    if not c then return nil end
    local bp = LP:FindFirstChildOfClass("Backpack")
    return c:FindFirstChild("Sun Hatchet")
        or (bp and bp:FindFirstChild("Sun Hatchet"))
        or c:FindFirstChild("Hatchet")
        or (bp and bp:FindFirstChild("Hatchet"))
end
local function equipHatchet()
    local t = getHatchet()
    if t then equip(t); useTool(t) end
end

AutofarmTab:CreateToggle({
    Name = "Auto Woods",
    CurrentValue = false,
    Flag = "autowoods",
    Callback = function(state)
        autoWoods = state
        Rayfield:Notify({ Title = "joaozin", Content = state and "Auto Woods ON" or "Auto Woods OFF", Duration = 2 })
        if not state then
            pcall(function()
                for p, d in pairs(modTrees) do
                    if p and p.Parent then
                        p.Size = d.Size
                        if d.MeshObj and d.MeshScale then d.MeshObj.Scale = d.MeshScale end
                    end
                end
                modTrees = {}
            end)
            if woodsFloat then woodsFloat:Destroy() woodsFloat = nil end
            local hrp = getHRP()
            if hrp then hrp.Anchored = false end
            return
        end
        task.spawn(function()
            while autoWoods do
                local hrp = getHRP()
                local hum = getHum()
                if not hrp or not hum then task.wait(1) continue end
                local orig = hrp.CFrame
                if not woodsFloat or not woodsFloat.Parent then
                    woodsFloat = Instance.new("Part")
                    woodsFloat.Size = Vector3.new(6, 1, 6)
                    woodsFloat.Transparency = 1
                    woodsFloat.CanCollide = true
                    woodsFloat.Anchored = true
                    woodsFloat.Parent = Workspace
                end
                local map = Workspace:FindFirstChild("Map")
                if map then
                    local tnames = {
                        ["MtnTree"]=true, ["SnowTree"]=true, ["RiceFieldTree"]=true,
                        ["BETTER TREE"]=true, ["SpruceTree"]=true, ["WisteriaTree"]=true
                    }
                    local lastH = hum.Health
                    local dmg = false
                    local cn = hum.HealthChanged:Connect(function(nh)
                        if nh < lastH then dmg = true end
                        lastH = nh
                    end)
                    for _, tm in ipairs(map:GetDescendants()) do
                        if not autoWoods then break end
                        if tm:IsA("Model") and tnames[tm.Name] then
                            local hit = tm:FindFirstChild("WoodHitPart", true)
                            if hit and hit:IsA("BasePart") and hit.Transparency < 1 then
                                pcall(function()
                                    if not modTrees[hit] then
                                        local mesh = hit:FindFirstChildOfClass("SpecialMesh")
                                            or hit:FindFirstChildOfClass("BlockMesh")
                                            or hit:FindFirstChildOfClass("CylinderMesh")
                                        modTrees[hit] = {
                                            Size = hit.Size,
                                            MeshObj = mesh,
                                            MeshScale = mesh and mesh.Scale or nil
                                        }
                                    end
                                    local mesh = hit:FindFirstChildOfClass("SpecialMesh")
                                        or hit:FindFirstChildOfClass("BlockMesh")
                                        or hit:FindFirstChildOfClass("CylinderMesh")
                                    if mesh then mesh.Scale = Vector3.new(5,5,5) end
                                    hit.Size = Vector3.new(5,5,5)
                                    local function countWood()
                                        local n = 0
                                        local bp = LP:FindFirstChildOfClass("Backpack")
                                        if bp then for _, i in ipairs(bp:GetChildren()) do
                                            if i.Name == "Wood" then n = n + 1 end
                                        end end
                                        local c = getChar()
                                        if c then for _, i in ipairs(c:GetChildren()) do
                                            if i.Name == "Wood" then n = n + 1 end
                                        end end
                                        return n
                                    end
                                    local ini = countWood()
                                    local angs = {0, math.pi/2, math.pi, 3*math.pi/2}
                                    local r = 3.5
                                    local i = 1
                                    while autoWoods and hit and hit.Parent and hit.Transparency < 1 do
                                        if dmg then
                                            if woodsFloat then woodsFloat.CFrame = CFrame.new(0,-5000,0) end
                                            hrp.CFrame = orig
                                            task.wait(1)
                                            dmg = false
                                            lastH = hum.Health
                                        end
                                        local a = angs[i]
                                        local off = Vector3.new(math.cos(a)*r, 0, math.sin(a)*r)
                                        local tgt = hit.Position + off
                                        hrp.CFrame = CFrame.new(tgt, Vector3.new(hit.Position.X, tgt.Y, hit.Position.Z))
                                        if woodsFloat then woodsFloat.CFrame = hrp.CFrame - Vector3.new(0,3.5,0) end
                                        equipHatchet()
                                        if countWood() > ini then break end
                                        i = i % #angs + 1
                                        task.wait(0.15)
                                    end
                                end)
                            end
                        end
                    end
                    if cn then cn:Disconnect() end
                end
                if woodsFloat then woodsFloat.CFrame = CFrame.new(0,-5000,0) end
                if hrp then hrp.Anchored = false; hrp.CFrame = orig end
                task.wait(1)
            end
        end)
    end
})

-- ── AUTO ORE ───────────────────────────────────────────────
local autoOre = false
local oreFloat

local function getPickaxe()
    local c = getChar()
    if not c then return nil end
    local bp = LP:FindFirstChildOfClass("Backpack")
    return c:FindFirstChild("Sun Pickaxe")
        or (bp and bp:FindFirstChild("Sun Pickaxe"))
        or c:FindFirstChild("Pickaxe")
        or (bp and bp:FindFirstChild("Pickaxe"))
end
local function equipPickaxe()
    local t = getPickaxe()
    if t then equip(t); useTool(t) end
end

AutofarmTab:CreateToggle({
    Name = "Auto Ore",
    CurrentValue = false,
    Flag = "autoore",
    Callback = function(state)
        autoOre = state
        Rayfield:Notify({ Title = "joaozin", Content = state and "Auto Ore ON" or "Auto Ore OFF", Duration = 2 })
        if not state then
            if oreFloat then oreFloat:Destroy() oreFloat = nil end
            local hrp = getHRP()
            if hrp then hrp.Anchored = false end
            return
        end
        task.spawn(function()
            while autoOre do
                local hrp = getHRP()
                local hum = getHum()
                if not hrp or not hum then task.wait(1) continue end
                local orig = hrp.CFrame
                if not oreFloat or not oreFloat.Parent then
                    oreFloat = Instance.new("Part")
                    oreFloat.Size = Vector3.new(6,1,6)
                    oreFloat.Transparency = 1
                    oreFloat.CanCollide = true
                    oreFloat.Anchored = true
                    oreFloat.Parent = Workspace
                end
                local lastH = hum.Health
                local dmg = false
                local cn = hum.HealthChanged:Connect(function(nh)
                    if nh < lastH then dmg = true end
                    lastH = nh
                end)
                for _, hit in ipairs(Workspace:GetDescendants()) do
                    if not autoOre then break end
                    if hit:IsA("BasePart") and hit.Name == "RockHitPart" and hit.Transparency < 1 then
                        pcall(function()
                            local function countOre()
                                local n = 0
                                local bp = LP:FindFirstChildOfClass("Backpack")
                                if bp then for _, i in ipairs(bp:GetChildren()) do
                                    if i.Name == "Mishirin Ore" or i.Name:match("Ore") then n = n + 1 end
                                end end
                                local c = getChar()
                                if c then for _, i in ipairs(c:GetChildren()) do
                                    if i.Name == "Mishirin Ore" or i.Name:match("Ore") then n = n + 1 end
                                end end
                                return n
                            end
                            local ini = countOre()
                            local angs = {0, math.pi/2, math.pi, 3*math.pi/2}
                            local r = 3.5
                            local i = 1
                            while autoOre and hit and hit.Parent and hit.Transparency < 1 do
                                if dmg then
                                    if oreFloat then oreFloat.CFrame = CFrame.new(0,-5000,0) end
                                    hrp.CFrame = orig
                                    task.wait(1)
                                    dmg = false
                                    lastH = hum.Health
                                end
                                local a = angs[i]
                                local off = Vector3.new(math.cos(a)*r, 0, math.sin(a)*r)
                                local tgt = hit.Position + off
                                hrp.CFrame = CFrame.new(tgt, Vector3.new(hit.Position.X, tgt.Y, hit.Position.Z))
                                if oreFloat then oreFloat.CFrame = hrp.CFrame - Vector3.new(0,3.5,0) end
                                equipPickaxe()
                                if countOre() > ini then break end
                                i = i % #angs + 1
                                task.wait(0.15)
                            end
                        end)
                    end
                end
                if cn then cn:Disconnect() end
                if oreFloat then oreFloat.CFrame = CFrame.new(0,-5000,0) end
                if hrp then hrp.Anchored = false; hrp.CFrame = orig end
                task.wait(1)
            end
        end)
    end
})

-- ── AUTO MOBS / BOSS ───────────────────────────────────────
local function hasToolNamed(n)
    local c = getChar()
    if c and c:FindFirstChild(n) then return true end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp and bp:FindFirstChild(n) then return true end
    return false
end

local function processStrongSoul(hrp)
    if hasToolNamed("Strong Soul") then return end
    local g = Workspace:FindFirstChild("StrongSoulGroup")
    if not g then return end
    for _, core in ipairs(g:GetChildren()) do
        local cp = core:FindFirstChild("Core")
        local p = cp and cp:FindFirstChild("ProximityPrompt")
        if cp and cp:IsA("BasePart") and p and p:IsA("ProximityPrompt") then
            p.MaxActivationDistance = 1000
            p.HoldDuration = 0
            p.RequiresLineOfSight = false
            p.KeyboardKeyCode = Enum.KeyCode.F
            local t = tick()
            while cp.Parent and not hasToolNamed("Strong Soul") and tick()-t < 3 do
                hrp.CFrame = cp.CFrame + Vector3.new(0,3,0)
                firePrompt(p)
                task.wait(0.1)
            end
        end
    end
end

local function processDrops(hrp)
    local ls = LP:FindFirstChild("leaderstats")
    local cash = ls and ls:FindFirstChild("Cash")
    local names = { ["MoneyBag"]=true, ["RawMeatPart"]=true, ["OrePart"]=true }
    for _, obj in ipairs(Workspace:GetChildren()) do
        if names[obj.Name] and obj:IsA("BasePart") then
            local p = obj:FindFirstChildOfClass("ProximityPrompt")
                or obj:FindFirstChild("ProximityPrompt", true)
            if p and p:IsA("ProximityPrompt") then
                p.MaxActivationDistance = 1000
                p.HoldDuration = 0
                p.RequiresLineOfSight = false
                p.KeyboardKeyCode = Enum.KeyCode.F
                local ic = cash and cash.Value or 0
                local t = tick()
                while obj.Parent and tick()-t < 3 do
                    hrp.CFrame = obj.CFrame + Vector3.new(0,3,0)
                    firePrompt(p)
                    if cash and cash.Value ~= ic then break end
                    task.wait(0.1)
                end
            end
        end
    end
end

local function processBigMoneyBag(hrp)
    local bmb = Workspace:FindFirstChild("BigMoneyBag")
    if bmb and bmb:IsA("BasePart") then
        local p = bmb:FindFirstChildOfClass("ProximityPrompt")
            or bmb:FindFirstChild("ProximityPrompt", true)
        if p and p:IsA("ProximityPrompt") then
            p.MaxActivationDistance = 1000
            p.HoldDuration = 0
            p.RequiresLineOfSight = false
            p.KeyboardKeyCode = Enum.KeyCode.F
            local t = tick()
            while bmb.Parent and tick()-t < 3 do
                hrp.CFrame = bmb.CFrame + Vector3.new(0,3,0)
                firePrompt(p)
                task.wait(0.1)
            end
        end
    end
end

local function makeAutoKill(holderName, isBoss)
    return function(state)
        local enabled = state
        Rayfield:Notify({ Title = "joaozin", Content = state and (holderName.." ON") or (holderName.." OFF"), Duration = 2 })
        if not state then return end
        task.spawn(function()
            while enabled do
                local holder = Workspace:FindFirstChild(holderName)
                if not holder then task.wait(1) continue end
                local hrp = getHRP()
                if not hrp then task.wait(1) continue end
                local orig = hrp.CFrame
                local flt = Instance.new("Part")
                flt.Size = Vector3.new(6,1,6)
                flt.Transparency = 1
                flt.CanCollide = true
                flt.Anchored = true
                flt.Parent = Workspace
                local cam = Workspace.CurrentCamera
                local targets = {}
                for _, ch in ipairs(holder:GetChildren()) do
                    if ch:IsA("Model") then
                        local h = ch:FindFirstChildOfClass("Humanoid")
                        local thrp = ch:FindFirstChild("HumanoidRootPart")
                        if h and thrp and h.Health > 0 then
                            local torso = ch:FindFirstChild("Torso") or ch:FindFirstChild("UpperTorso")
                            if ch.Name == "Boar" or torso then
                                table.insert(targets, ch)
                            end
                        end
                    end
                end
                for _, tgt in ipairs(targets) do
                    if not enabled then break end
                    local th = tgt:FindFirstChildOfClass("Humanoid")
                    local thrp = tgt:FindFirstChild("HumanoidRootPart")
                    if th and thrp and th.Health > 0 then
                        cam.CameraSubject = th
                        local isBoar = (tgt.Name == "Boar")
                        local torso = not isBoar and (tgt:FindFirstChild("Torso") or tgt:FindFirstChild("UpperTorso"))
                        if torso then
                            torso.Size = Vector3.new(isBoss and 6 or 4, isBoss and 180 or 90, isBoss and 6 or 4)
                            torso.Transparency = 1
                            torso.CanCollide = false
                            torso.Anchored = true
                        end
                        thrp.Anchored = true
                        local angs = {0, math.pi/2, math.pi, 3*math.pi/2}
                        local r = isBoss and 6 or 3.5
                        local i = 1
                        while enabled and th.Health > 0 and tgt.Parent do
                            local cTorso = not isBoar and (tgt:FindFirstChild("Torso") or tgt:FindFirstChild("UpperTorso"))
                            local cHrp = tgt:FindFirstChild("HumanoidRootPart")
                            local mHrp = getHRP()
                            local mHum = getHum()
                            if cHrp and mHrp and mHum then
                                for _, part in ipairs(getChar():GetDescendants()) do
                                    if part:IsA("BasePart") then part.CanCollide = false end
                                end
                                local base
                                if isBoar then
                                    base = cHrp.Position
                                else
                                    base = (cTorso and cTorso.Position or cHrp.Position)
                                        - Vector3.new(0, isBoss and 90 or 40, 0)
                                end
                                local a = angs[i]
                                local off = Vector3.new(math.cos(a)*r, 0, math.sin(a)*r)
                                local tp = base + off
                                mHrp.CFrame = CFrame.new(tp, Vector3.new(base.X, tp.Y, base.Z))
                                flt.CFrame = mHrp.CFrame - Vector3.new(0,3.5,0)
                                processStrongSoul(mHrp)
                                processDrops(mHrp)
                                processBigMoneyBag(mHrp)
                                local axe = getHatchet()
                                if axe then equip(axe); useTool(axe) end
                                i = i % #angs + 1
                            end
                            task.wait(0.15)
                        end
                        local fHrp = getHRP()
                        if fHrp then
                            processStrongSoul(fHrp)
                            processDrops(fHrp)
                            processBigMoneyBag(fHrp)
                        end
                    end
                end
                local hum = getHum()
                if hum then cam.CameraSubject = hum end
                flt:Destroy()
                local h2 = getHRP()
                if h2 then h2.CFrame = orig end
                task.wait(1)
            end
        end)
    end
end

AutofarmTab:CreateToggle({ Name = "Auto Mobs", CurrentValue = false, Flag = "automobs", Callback = makeAutoKill("MobsHolder", false) })
AutofarmTab:CreateToggle({ Name = "Auto Boss", CurrentValue = false, Flag = "autoboss", Callback = makeAutoKill("BossHolder", true) })

-- ── PLAYER TAB ─────────────────────────────────────────────
PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = "ws",
    CurrentValue = 16,
    Flag = "ws",
    Callback = function(v)
        local hum = getHum(); if hum then hum.WalkSpeed = v end
    end
})
PlayerTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 1,
    Suffix = "jp",
    CurrentValue = 50,
    Flag = "jp",
    Callback = function(v)
        local hum = getHum()
        if hum then hum.UseJumpPower = true; hum.JumpPower = v end
    end
})
PlayerTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 196},
    Increment = 1,
    Suffix = "g",
    CurrentValue = 196,
    Flag = "gravity",
    Callback = function(v) Workspace.Gravity = v end
})

local tpWalk = false
local tpWalkSpd = 1
local tpConn
PlayerTab:CreateSlider({
    Name = "TPWalk Speed",
    Range = {1, 20},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "tpwspeed",
    Callback = function(v) tpWalkSpd = v end
})
PlayerTab:CreateToggle({
    Name = "TPWalk",
    CurrentValue = false,
    Flag = "tpwalk",
    Callback = function(state)
        tpWalk = state
        Rayfield:Notify({ Title = "joaozin", Content = state and "TPWalk ON" or "TPWalk OFF", Duration = 2 })
        if tpConn then tpConn:Disconnect() tpConn = nil end
        if state then
            tpConn = RunService.RenderStepped:Connect(function(dt)
                if not tpWalk then return end
                local hrp = getHRP()
                local hum = getHum()
                if hrp and hum and hum.MoveDirection.Magnitude > 0 then
                    local dir = hum.MoveDirection.Unit
                    local off = dir * tpWalkSpd * (dt * 60)
                    hrp.CFrame = hrp.CFrame:Lerp(hrp.CFrame + off, 0.35)
                end
            end)
        end
    end
})

local infJumpConn
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "infjump",
    Callback = function(state)
        Rayfield:Notify({ Title = "joaozin", Content = state and "InfJump ON" or "InfJump OFF", Duration = 2 })
        if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
        if state then
            infJumpConn = UIS.JumpRequest:Connect(function()
                local hum = getHum()
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end
})

local flyConn
PlayerTab:CreateToggle({
    Name = "Fly (WASD + Space/Ctrl)",
    CurrentValue = false,
    Flag = "fly",
    Callback = function(state)
        Rayfield:Notify({ Title = "joaozin", Content = state and "Fly ON" or "Fly OFF", Duration = 2 })
        if flyConn then flyConn:Disconnect() flyConn = nil end
        local hrp = getHRP(); local hum = getHum()
        if not hrp or not hum then return end
        if state then
            local bg = Instance.new("BodyGyro")
            bg.Name = "FlyGyro"; bg.MaxTorque = Vector3.new(9e4,9e4,9e4); bg.P = 2e4
            bg.CFrame = hrp.CFrame; bg.Parent = hrp
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyVelocity"; bv.Velocity = Vector3.new(0,0.1,0)
            bv.MaxForce = Vector3.new(9e4,9e4,9e4); bv.Parent = hrp
            hum.PlatformStand = true
            flyConn = RunService.RenderStepped:Connect(function()
                if not hrp.Parent then return end
                local mv = Vector3.new()
                local cam = Workspace.CurrentCamera
                if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.new(0,1,0) end
                if mv.Magnitude > 0 then bv.Velocity = mv.Unit * 50
                else bv.Velocity = Vector3.new(0,0.1,0) end
                bg.CFrame = cam.CFrame
            end)
        else
            local bg = hrp:FindFirstChild("FlyGyro"); if bg then bg:Destroy() end
            local bv = hrp:FindFirstChild("FlyVelocity"); if bv then bv:Destroy() end
            if hum then hum.PlatformStand = false end
        end
    end
})

local noclipConn
PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "noclip",
    Callback = function(state)
        Rayfield:Notify({ Title = "joaozin", Content = state and "No Clip ON" or "No Clip OFF", Duration = 2 })
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if state then
            noclipConn = RunService.Stepped:Connect(function()
                local c = getChar()
                if c then
                    for _, part in ipairs(c:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        end
    end
})

local safeConn
PlayerTab:CreateToggle({
    Name = "Safe Mode",
    CurrentValue = false,
    Flag = "safemode",
    Callback = function(state)
        Rayfield:Notify({ Title = "joaozin", Content = state and "Safe Mode ON" or "Safe Mode OFF", Duration = 2 })
        if safeConn then safeConn:Disconnect() safeConn = nil end
        local spots = {
            CFrame.new(310, 492, 378),
            CFrame.new(-776, 560, 946),
            CFrame.new(-1339, 503, -1213)
        }
        local ret = CFrame.new(-382, 382, 26)
        if state then
            local trig = false
            safeConn = RunService.Heartbeat:Connect(function()
                if trig then return end
                local hum = getHum(); local hrp = getHRP()
                if hum and hrp and hum.Health > 0 and hum.Health / hum.MaxHealth < 0.10 then
                    trig = true
                    Rayfield:Notify({ Title = "joaozin", Content = "Safe Mode ativado!", Duration = 2 })
                    hrp.CFrame = spots[math.random(1, #spots)]
                    task.spawn(function()
                        task.wait(8)
                        local h2 = getHRP()
                        if h2 then h2.CFrame = ret end
                        Rayfield:Notify({ Title = "joaozin", Content = "Retorno do Safe Mode.", Duration = 2 })
                        task.wait(2)
                        trig = false
                    end)
                end
            end)
        end
    end
})

-- ── MISC TAB ───────────────────────────────────────────────
local autoBring = false
MiscTab:CreateToggle({
    Name = "Auto Bring Dropped Items",
    CurrentValue = false,
    Flag = "autobring",
    Callback = function(state)
        autoBring = state
        Rayfield:Notify({ Title = "joaozin", Content = state and "Auto Bring ON" or "Auto Bring OFF", Duration = 2 })
        if state then
            task.spawn(function()
                while autoBring do
                    pcall(BringToolsAction)
                    task.wait(1)
                end
            end)
        end
    end
})

local barrierStates = {}
local barrierConn
MiscTab:CreateToggle({
    Name = "Remove Barrier",
    CurrentValue = false,
    Flag = "barrier",
    Callback = function(state)
        Rayfield:Notify({ Title = "joaozin", Content = state and "Barrier ON" or "Barrier OFF", Duration = 2 })
        if barrierConn then barrierConn:Disconnect() barrierConn = nil end
        local function apply()
            local ts = Workspace:FindFirstChild("TycoonSets")
            if not ts then return end
            for _, d in ipairs(ts:GetDescendants()) do
                if d:IsA("Model") and d.Name == "Lasers" then
                    for _, p in ipairs(d:GetDescendants()) do
                        if p:IsA("BasePart") then
                            if barrierStates[p] == nil then barrierStates[p] = p.CanTouch end
                            p.CanTouch = false
                        end
                    end
                end
            end
        end
        if state then
            apply()
            barrierConn = RunService.Heartbeat:Connect(function() apply() end)
        else
            for p, ct in pairs(barrierStates) do
                if p and p.Parent then p.CanTouch = ct end
            end
            barrierStates = {}
        end
    end
})

-- ── PVP TAB ────────────────────────────────────────────────
local selUser = ""
PvpTab:CreateInput({
    Name = "User",
    CurrentValue = "",
    PlaceholderText = "Digite 3+ chars...",
    RemoveTextAfterFocusLost = false,
    Flag = "pvpuser",
    Callback = function(text)
        local q = text:lower()
        if #q >= 3 then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name:lower():sub(1, #q) == q
                    or p.DisplayName:lower():sub(1, #q) == q then
                    selUser = p.Name
                    Rayfield:Notify({ Title = "joaozin", Content = "Alvo: " .. p.Name, Duration = 2 })
                    break
                end
            end
        else
            selUser = text
        end
    end
})

local autoKillPvp = false
PvpTab:CreateToggle({
    Name = "Auto Kill Player",
    CurrentValue = false,
    Flag = "autokillpvp",
    Callback = function(state)
        autoKillPvp = state
        Rayfield:Notify({ Title = "joaozin", Content = state and "Auto Kill ON" or "Auto Kill OFF", Duration = 2 })
        if not state then return end
        task.spawn(function()
            while autoKillPvp do
                local tgt = Players:FindFirstChild(selUser)
                if not tgt or not tgt.Character then task.wait(1) continue end
                local th = tgt.Character:FindFirstChildOfClass("Humanoid")
                local thrp = tgt.Character:FindFirstChild("HumanoidRootPart")
                if not th or not thrp or th.Health <= 0 then task.wait(1) continue end
                local mHrp = getHRP()
                if not mHrp then task.wait(1) continue end
                local orig = mHrp.CFrame
                local cam = Workspace.CurrentCamera
                cam.CameraSubject = th
                local flt = Instance.new("Part")
                flt.Size = Vector3.new(6,1,6)
                flt.Transparency = 1
                flt.CanCollide = true
                flt.Anchored = true
                flt.Parent = Workspace
                thrp.Size = Vector3.new(4, 90, 4)
                thrp.Massless = false
                thrp.CanCollide = false
                local angs = {0, math.pi/2, math.pi, 3*math.pi/2}
                local r = 3.5
                local i = 1
                local tChar = tgt.Character
                while autoKillPvp and th and th.Health > 0 and tChar and tChar.Parent do
                    local cHrp = tChar:FindFirstChild("HumanoidRootPart")
                    local mHrp2 = getHRP()
                    local mHum = getHum()
                    if cHrp and mHrp2 and mHum then
                        for _, part in ipairs(getChar():GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                        local base = cHrp.Position - Vector3.new(0, 40, 0)
                        local a = angs[i]
                        local off = Vector3.new(math.cos(a)*r, 0, math.sin(a)*r)
                        local tp = base + off
                        mHrp2.CFrame = CFrame.new(tp, Vector3.new(base.X, tp.Y, base.Z))
                        flt.CFrame = mHrp2.CFrame - Vector3.new(0,3.5,0)
                        local axe = getHatchet()
                        if axe then equip(axe); useTool(axe) end
                        i = i % #angs + 1
                    end
                    task.wait(0.15)
                end
                local hum = getHum()
                if hum then cam.CameraSubject = hum end
                flt:Destroy()
                local h2 = getHRP()
                if h2 then h2.CFrame = orig end
                task.wait(1)
            end
        end)
    end
})

-- ── VISUALS TAB ────────────────────────────────────────────
local function getEspParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return game:GetService("CoreGui")
end
local espCache = { Players = {}, Mobs = {}, Bosses = {}, Ores = {}, Trees = {}, Items = {} }
local function addESP(cat, obj, adorn, label, color)
    if not obj or not adorn or espCache[cat][obj] then return end
    local parent = getEspParent()
    local esp = Instance.new("Highlight")
    esp.Adornee = adorn
    esp.FillColor = color
    esp.OutlineColor = color
    esp.FillTransparency = 0.6
    esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    esp.Parent = parent
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 20)
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.Adornee = adorn
    bb.Parent = parent
    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1,0,1,0)
    txt.Text = label
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0
    txt.BackgroundTransparency = 1
    txt.TextScaled = true
    espCache[cat][obj] = { Highlight = esp, Billboard = bb }
end
local function clearESP(cat)
    for _, c in pairs(espCache[cat]) do
        if c.Highlight then c.Highlight:Destroy() end
        if c.Billboard then c.Billboard:Destroy() end
    end
    espCache[cat] = {}
end

local espP = false
VisualsTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "espplayers",
    Callback = function(state)
        espP = state
        if not state then clearESP("Players") return end
        task.spawn(function()
            while espP do
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        addESP("Players", p.Character, p.Character, p.Name, Color3.fromRGB(255,255,255))
                    end
                end
                for ch, c in pairs(espCache.Players) do
                    if not ch.Parent then
                        if c.Highlight then c.Highlight:Destroy() end
                        if c.Billboard then c.Billboard:Destroy() end
                        espCache.Players[ch] = nil
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local espM = false
VisualsTab:CreateToggle({
    Name = "ESP Mobs",
    CurrentValue = false,
    Flag = "espmobs",
    Callback = function(state)
        espM = state
        if not state then clearESP("Mobs") return end
        task.spawn(function()
            while espM do
                local h = Workspace:FindFirstChild("MobsHolder")
                if h then
                    for _, m in ipairs(h:GetChildren()) do
                        if m:IsA("Model") and (m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso")) then
                            addESP("Mobs", m, m, m.Name, Color3.fromRGB(255,100,100))
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local espB = false
VisualsTab:CreateToggle({
    Name = "ESP Bosses",
    CurrentValue = false,
    Flag = "espbosses",
    Callback = function(state)
        espB = state
        if not state then clearESP("Bosses") return end
        task.spawn(function()
            while espB do
                local h = Workspace:FindFirstChild("BossHolder")
                if h then
                    for _, b in ipairs(h:GetChildren()) do
                        if b:IsA("Model") and (b:FindFirstChild("HumanoidRootPart") or b:FindFirstChild("Torso")) then
                            addESP("Bosses", b, b, b.Name, Color3.fromRGB(255,0,0))
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local espO = false
VisualsTab:CreateToggle({
    Name = "ESP Ores",
    CurrentValue = false,
    Flag = "espores",
    Callback = function(state)
        espO = state
        if not state then clearESP("Ores") return end
        task.spawn(function()
            while espO do
                for _, hit in ipairs(Workspace:GetDescendants()) do
                    if hit:IsA("BasePart") and hit.Name == "RockHitPart" and hit.Transparency < 1 then
                        addESP("Ores", hit, hit, "Ore", Color3.fromRGB(150,150,150))
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local espT = false
VisualsTab:CreateToggle({
    Name = "ESP Trees",
    CurrentValue = false,
    Flag = "esptrees",
    Callback = function(state)
        espT = state
        if not state then clearESP("Trees") return end
        local names = {
            ["MtnTree"]=true, ["SnowTree"]=true, ["RiceFieldTree"]=true,
            ["BETTER TREE"]=true, ["SpruceTree"]=true, ["WisteriaTree"]=true
        }
        task.spawn(function()
            while espT do
                local map = Workspace:FindFirstChild("Map")
                if map then
                    for _, m in ipairs(map:GetDescendants()) do
                        if m:IsA("Model") and names[m.Name] then
                            local hp = m:FindFirstChild("WoodHitPart", true)
                            if hp and hp.Transparency < 1 then
                                addESP("Trees", m, m, m.Name, Color3.fromRGB(50,255,50))
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local espI = false
VisualsTab:CreateToggle({
    Name = "ESP Items",
    CurrentValue = false,
    Flag = "espitems",
    Callback = function(state)
        espI = state
        if not state then clearESP("Items") return end
        local names = {
            ["Wood"]=true, ["Mishirin Ore"]=true, ["Raw Meat"]=true,
            ["MoneyBag"]=true, ["RawMeatPart"]=true, ["OrePart"]=true,
            ["BigMoneyBag"]=true, ["Strong Soul"]=true
        }
        task.spawn(function()
            while espI do
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if names[obj.Name] then
                        local adorn = obj:IsA("Tool") and obj:FindFirstChild("Handle") or obj
                        if adorn and adorn:IsA("BasePart") then
                            addESP("Items", obj, adorn, obj.Name, Color3.fromRGB(255,255,0))
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
})

local oAmb = Lighting.Ambient
local oCSB = Lighting.ColorShift_Bottom
local oCST = Lighting.ColorShift_Top
VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "fullbright",
    Callback = function(state)
        if state then
            Lighting.Ambient = Color3.fromRGB(255,255,255)
            Lighting.ColorShift_Bottom = Color3.fromRGB(255,255,255)
            Lighting.ColorShift_Top = Color3.fromRGB(255,255,255)
        else
            Lighting.Ambient = oAmb
            Lighting.ColorShift_Bottom = oCSB
            Lighting.ColorShift_Top = oCST
        end
    end
})

local oFog = Lighting.FogEnd
local atmosB
VisualsTab:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Flag = "nofog",
    Callback = function(state)
        local at = Lighting:FindFirstChildOfClass("Atmosphere")
        if state then
            Lighting.FogEnd = 100000
            if at then atmosB = at:Clone(); at:Destroy() end
        else
            Lighting.FogEnd = oFog
            if atmosB and not Lighting:FindFirstChildOfClass("Atmosphere") then
                atmosB:Clone().Parent = Lighting
            end
        end
    end
})

print("[joaozin menu] Carregado. PlaceId:", game.PlaceId)