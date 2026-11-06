-- [VOID HUB] Inicializando...
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not PlayerGui then warn("[VOID HUB] ERRO: PlayerGui não encontrado.") return end
print("[VOID HUB] PlayerGui encontrado.")

local Camera = Workspace.CurrentCamera
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() 
    if Workspace.CurrentCamera then Camera = Workspace.CurrentCamera end 
end)

local CONFIG_IMAGE_ID = "https://www.roblox.com/asset-thumbnail/image?assetId=96737736900809&width=420&height=420&format=png"

-- ==========================================
-- TRADUÇÕES
-- ==========================================
local Language = "pt-br"
local Translations = {
    ["pt-br"] = {
        tab_aimbot="Aimbot", tab_esp="ESP", tab_fps="FPS", tab_visual="Visual", tab_mira="Mira", tab_ia="Assistente IA", tab_bypass="Bypass", tab_smart="Smart", tab_save="Salvar", tab_config="Configurações",
        aim_title="Aimbot", aim_sub="Configuração de mira assistida",
        esp_title="ESP", esp_sub="Visualização de jogadores",
        fps_title="FPS", fps_sub="Desempenho e otimização",
        vis_title="Visual", vis_sub="Iluminação e ambiente",
        mira_title="Mira", mira_sub="Crosshair customizado",
        ia_title="Assistente IA", ia_sub="Pergunte qualquer coisa",
        bypass_title="Bypass", bypass_sub="Controle de visibilidade",
        smart_title="Smart", smart_sub="Otimização adaptativa",
        save_title="Salvar", save_sub="Gerenciar configurações",
        config_title="Configurações", config_sub="Preferências do script",
        aim_assist="Aim Assist", aim_assist_desc="Ativa a mira assistida",
        aim_fov="Campo de Visão", aim_show_circle="Mostrar Círculo",
        aim_color="Cor do FOV", aim_camera_lock="Camera Lock", aim_legit="Legit Aim",
        aim_smoothness="Smoothness", aim_humanize="Humanize", aim_predict="Auto-Predict",
        aim_team="Team Check", aim_team_desc="Ignora aliados",
        aim_los="Line of Sight", aim_los_desc="Só mira se visível",
        esp_master="Master ESP", esp_master_desc="Liga/desliga tudo",
        esp_highlight="Highlight", esp_box="Box ESP", esp_name="Nome",
        esp_dist="Distância", esp_transparency="Transparência",
        fps_preset="Preset", fps_monitor="FPS HUD", fps_monitor_desc="Contador em tempo real",
        fps_stretch="Esticar Tela", fps_render="Renderização", fps_sat="Saturação",
        fps_potato="Gráfico Batata", fps_potato_desc="Remove até a grama",
        vis_fullbright="Fullbright", vis_fullbright_desc="Remove sombras",
        vis_fog="Remove Fog", vis_fog_desc="Remove névoa",
        mira_crosshair="Mira Custom", mira_style="Estilo", mira_size="Tamanho",
        ia_input="Digite sua pergunta...", ia_send="Enviar",
        bypass_hide="ESCONDER MENU", bypass_kill="⛔ ENCERRAR SCRIPT",
        smart_aim="Smart Aim 2.0", smart_aim_desc="Adapta suavidade ao FPS",
        smart_boost="Smart Boost", smart_boost_desc="Otimização adaptativa",
        save_save="SALVAR", save_load="CARREGAR", save_saved="✔ Salvo!", save_loaded="✔ Carregado!", save_error="✖ Erro",
        config_version="Versão", config_language="Idioma",
        config_about="Sobre o VOID HUB",
        config_about_text="VOID HUB é um script de automação e otimização para Roblox.\n\n• Aimbot inteligente com Smart Aim\n• ESP completo com highlights\n• Otimização de FPS avançada\n• Assistente IA integrada\n\nDesenvolvido com carinho ❤",
        section_general="Geral", section_target="Alvo", section_visual="Visual", section_perf="Desempenho"
    }
}
local function T(key) return Translations[Language][key] or key end

-- ==========================================
-- CONFIG + PALETA
-- ==========================================
local Config = {
    Colors = { 
        BG = Color3.fromRGB(8,6,16), Panel = Color3.fromRGB(16,12,28), Card = Color3.fromRGB(24,20,42), 
        CardHover = Color3.fromRGB(34,28,58), Accent = Color3.fromRGB(168,92,255), AccentLight = Color3.fromRGB(210,150,255),
        AccentDim = Color3.fromRGB(110,50,180), Text = Color3.fromRGB(245,240,255), TextDim = Color3.fromRGB(140,130,170), 
        Danger = Color3.fromRGB(255,70,90), Success = Color3.fromRGB(80,255,140), Warning = Color3.fromRGB(255,200,80),
        ToggleOff = Color3.fromRGB(40,34,60) 
    },
    AimAssist=false, TeamCheck=true, LOSCheck=true, AutoPredict=true, TargetPart="Head", Priority=1, FOV=150, FOVCircle=true, FOVColorMode="RGB", Smoothness=50, Humanize=3, DistSmooth=true, LegitAim=false, CameraLock=false,
    SmartAim=false, ESP=false, ESP_Box=false, ESP_Tracer=false, ESP_Name=false, ESP_Dist=true, ESP_Highlight=true, ESP_Color=Color3.fromRGB(168,92,255), ESP_Transparency=0.5,
    Fullbright=false, RemoveFog=false, PotatoColorful=false, Crosshair=false, CH_Size=40, CH_Style="+",
    RenderDistance=1000, Saturation=1.0, StretchFOV=70, FPSMonitor=true, FPSPreset="Medium",
    ActiveTab=1, Language="pt-br"
}

-- ==========================================
-- SAVE
-- ==========================================
local SaveSystem = {}
local CONFIG_FILE = "voidhub7_config.json"
function SaveSystem:HasSupport() return type(writefile)=="function" and type(readfile)=="function" and type(isfile)=="function" end
function SaveSystem:Serialize() local d={} for k,v in pairs(Config) do if type(v)=="boolean" or type(v)=="number" or type(v)=="string" then d[k]=v elseif typeof(v)=="Color3" then d[k]={__color=true,r=v.R,g=v.G,b=v.B} end end return HttpService:JSONEncode(d) end
function SaveSystem:Deserialize(j) local ok,data=pcall(function() return HttpService:JSONDecode(j) end) if not ok or type(data)~="table" then return false end for k,v in pairs(data) do if Config[k]~=nil then if type(v)=="table" and v.__color then Config[k]=Color3.new(v.r,v.g,v.b) elseif type(v)==type(Config[k]) then Config[k]=v end end end return true end
function SaveSystem:Save() if not self:HasSupport() then return false end return pcall(function() writefile(CONFIG_FILE,self:Serialize()) end) end
function SaveSystem:Load() if not self:HasSupport() or not isfile(CONFIG_FILE) then return false end local ok,c=pcall(function() return readfile(CONFIG_FILE) end) if not ok then return false end return self:Deserialize(c) end

-- ==========================================
-- CONEXÕES E UTILS
-- ==========================================
local ActiveConnections = {}
local function Connect(sig,fn) local c=sig:Connect(fn) table.insert(ActiveConnections,c) return c end
local function CleanupAll() for _,c in ipairs(ActiveConnections) do if c.Connected then c:Disconnect() end end ActiveConnections={} end

local Utils = {}
function Utils.Tween(obj,t,p,e) if not obj then return end return TweenService:Create(obj,TweenInfo.new(t or 0.2,e or Enum.EasingStyle.Quart),p):Play() end
function Utils.Corner(obj,r) local c=Instance.new("UICorner",obj) c.CornerRadius=UDim.new(0,r or 8) return c end
function Utils.Stroke(obj,col,th,tr) local s=Instance.new("UIStroke",obj) s.Color=col or Config.Colors.Accent s.Thickness=th or 1 s.Transparency=tr or 0.5 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border return s end

-- ==========================================
-- IA
-- ==========================================
local function GetAIResponse(question)
    local q = string.lower(question)
    if q:find("oi") or q:find("ola") or q:find("olá") or q:find("hello") then return "🤖 Olá! Sou o assistente do VOID HUB. Como posso te ajudar?" end
    if q:find("aimbot") or q:find("mira") or q:find("acertar") or q:find("mata") then return "🎯 Config ideal: Aba Aimbot > Ative Aim Assist > FOV 150-200 > Smoothness 50 > Legit ON." end
    if q:find("fps") or q:find("lag") or q:find("trava") or q:find("leve") or q:find("desempenho") then return "⚡ Ative Gráfico Batata, Render 300-500, Smart Boost ON." end
    if q:find("esp") or q:find("ver") or q:find("inimigo") then return "👁️ Aba ESP > Master ESP > Highlight > Distance." end
    if q:find("config") or q:find("melhor") or q:find("ideal") then return "⚙️ FOV 180, Smoothness 45, Legit ON, Gráfico Batata ON." end
    if q:find("mobile") or q:find("celular") or q:find("android") then return "📱 Gráfico Batata ON, Render 300, Saturação 1.5." end
    return "🤔 Não entendi. Tente: Aimbot, FPS, ESP, Config."
end

-- ==========================================
-- SMART
-- ==========================================
local SmartAim = { Enabled=false, LastFPS=60, CurrentSmooth=0.5, TargetSmooth=0.5 }
function SmartAim:GetSmoothedFPS(dt) if dt>0 then self.LastFPS=self.LastFPS*0.9+(1/dt)*0.1 end return self.LastFPS end
function SmartAim:CalculateSmoothFactor(dt) 
    local fps=self:GetSmoothedFPS(dt); local bf=1-Config.Smoothness/100; local fm=1.0 
    if fps>=50 then fm=1.0 elseif fps>=30 then fm=1.0+(50-fps)/100 elseif fps>=15 then fm=1.0+(50-fps)/70 else fm=1.5 end 
    return math.clamp(bf*fm,0.15,0.85) 
end
function SmartAim:Update(dt) if not self.Enabled then return self.CurrentSmooth end self.TargetSmooth=self:CalculateSmoothFactor(dt) self.CurrentSmooth=self.CurrentSmooth+(self.TargetSmooth-self.CurrentSmooth)*0.3 return self.CurrentSmooth end
function SmartAim:GetSmoothFactor(dt,fb) if not self.Enabled then return fb end return self:Update(dt) end

local SmartBoost = { Enabled=false, Mode="NORMAL", Orig=setmetatable({},{__mode="k"}) }
function SmartBoost:SV(inst,p,v) if not inst or not inst.Parent then return end if self.Orig[inst]==nil then self.Orig[inst]={} end if self.Orig[inst][p]==nil then local ok,val=pcall(function() return inst[p] end) if ok then self.Orig[inst][p]=val end end pcall(function() inst[p]=v end) end
function SmartBoost:Apply(inst,m) 
    if not inst or not inst.Parent then return end 
    if m=="LIGHT" then if inst:IsA("BasePart") then self:SV(inst,"CastShadow",false) elseif inst:IsA("ParticleEmitter") then self:SV(inst,"Enabled",false) end 
    elseif m=="MEDIUM" then if inst:IsA("BasePart") then self:SV(inst,"CastShadow",false) elseif inst:IsA("ParticleEmitter") or inst:IsA("Smoke") or inst:IsA("Fire") then self:SV(inst,"Enabled",false) elseif inst:IsA("Texture") then self:SV(inst,"Transparency",1) end 
    elseif m=="EXTREME" then if inst:IsA("BasePart") then self:SV(inst,"CastShadow",false) self:SV(inst,"Material",Enum.Material.SmoothPlastic) else if inst:IsA("ParticleEmitter") or inst:IsA("Smoke") or inst:IsA("Fire") then self:SV(inst,"Enabled",false) elseif inst:IsA("Texture") then self:SV(inst,"Transparency",1) end end end 
end
function SmartBoost:Mode_(m) if self.Mode==m then return end self.Mode=m if m~="NORMAL" then self:SV(Lighting,"GlobalShadows",false) end task.spawn(function() for i,inst in ipairs(Workspace:GetDescendants()) do self:Apply(inst,m) if i%500==0 then task.wait() end end end) end
function SmartBoost:Restore() self.Enabled=false self.Mode="NORMAL" for inst,props in pairs(self.Orig) do if inst and inst.Parent then for p,v in pairs(props) do pcall(function() inst[p]=v end) end end end self.Orig=setmetatable({},{__mode="k"}) end

-- ==========================================
-- INTRO ULTRA-PREMIUM (7 CENAS)
-- ==========================================
local function PlayIntro(onComplete)
    print("[VOID HUB] Iniciando introdução ULTRA-PREMIUM.")
    for _, v in ipairs(PlayerGui:GetChildren()) do if v.Name == "VoidIntro" then v:Destroy() end end

    local completed = false
    local function Complete()
        if completed then return end
        completed = true
        if onComplete then local ok, e = pcall(onComplete); if not ok then warn("[VOID HUB] onComplete: "..tostring(e)) end end
    end

    local success, err = pcall(function()
        local IntroGui = Instance.new("ScreenGui")
        IntroGui.Name = "VoidIntro"; IntroGui.IgnoreGuiInset = true; IntroGui.ResetOnSpawn = false
        IntroGui.DisplayOrder = 999; IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; IntroGui.Parent = PlayerGui

        local vp = Camera.ViewportSize
        local vpW = math.max(vp.X, 1); local vpH = math.max(vp.Y, 1)
        local isMobile = vpW < 800

        local function nF(props)
            local f = Instance.new("Frame"); f.BorderSizePixel = 0; f.BackgroundColor3 = Color3.new(0,0,0); f.BackgroundTransparency = 1
            for k, v in pairs(props or {}) do f[k] = v end
            f.Parent = IntroGui; return f
        end
        local function nL(props)
            local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.BorderSizePixel = 0
            for k, v in pairs(props or {}) do t[k] = v end
            t.Parent = IntroGui; return t
        end
        local function tw(o, time, props, style, dir)
            if not o or not o.Parent then return nil end
            return TweenService:Create(o, TweenInfo.new(time, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
        end
        local function cr(inst, r) local c = Instance.new("UICorner", inst); c.CornerRadius = UDim.new(0, r or 4); return c end

        -- CAMADA 0: BASE
        local Bg = nF({Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0, ZIndex=1})

        -- CAMADA 1: RADIAL
        local RadialBg = nF({Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(15,0,35), BackgroundTransparency=1, ZIndex=2})
        local RadialGrad = Instance.new("UIGradient", RadialBg)
        RadialGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(140,30,255)),
            ColorSequenceKeypoint.new(0.15, Color3.fromRGB(90,15,180)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(45,8,100)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(20,3,50)),
            ColorSequenceKeypoint.new(1.0, Color3.new(0,0,0))
        })

        -- CAMADA 2: STARFIELD
        local StarsLayer = nF({Size=UDim2.new(1,0,1,0), ZIndex=3})
        local starData = {}
        local starCount = isMobile and 60 or 120
        for i = 1, starCount do
            local sz = math.random(1, 3)
            local s = Instance.new("Frame", StarsLayer)
            s.Size = UDim2.new(0, sz, 0, sz)
            s.Position = UDim2.new(math.random(), 0, math.random(), 0)
            local b = math.random(180, 255)
            s.BackgroundColor3 = Color3.fromRGB(b, b, 255)
            s.BackgroundTransparency = math.random(30, 85)/100
            s.BorderSizePixel = 0; s.ZIndex = 3
            cr(s, 100)
            starData[i] = {obj=s, baseX=s.Position.X.Scale, baseY=s.Position.Y.Scale, spd=math.random(5,25)/1000, phase=math.random()*6.28}
        end

        -- CAMADA 3: MATRIX RAIN
        local MatrixLayer = nF({Size=UDim2.new(1,0,1,0), ZIndex=4})
        local matrixCols = {}
        local colCount = isMobile and 12 or 24
        local chars = {"0","1","V","O","I","D","H","U","B","7","ᚠ","ᚢ","ᚦ","ᚨ","ᚱ","ᚲ","ᚷ","ᚹ","⚡","✧","◆","▣"}
        for i = 1, colCount do
            local colX = (i-1)/colCount
            local drop = nF({Position=UDim2.new(colX, 0, -0.5, 0), ZIndex=4})
            drop.Size = UDim2.new(0, 16, 0, 300)
            local col = {obj=drop, chars={}, speed=math.random(120,280)/2000, offset=math.random()}
            for j = 1, 12 do
                local c = nL({Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,j*18,0), Text=chars[math.random(#chars)], Font=Enum.Font.Code, TextSize=13, TextColor3=Color3.fromRGB(80,255,150), TextTransparency=0.6, ZIndex=4+j%3})
                c.Parent = drop
                col.chars[j] = c
            end
            matrixCols[i] = col
        end

        -- CAMADA 4: NEURAL NET
        local NeuralLayer = nF({Size=UDim2.new(1,0,1,0), ZIndex=5})
        local neuralNodes = {}; local neuralLines = {}
        local nodeCount = isMobile and 12 or 20
        for i = 1, nodeCount do
            local x = 0.15 + math.random()*0.7; local y = 0.15 + math.random()*0.7
            local node = Instance.new("Frame", NeuralLayer)
            local sz = math.random(3, 6)
            node.Size = UDim2.new(0, sz, 0, sz)
            node.Position = UDim2.new(x, 0, y, 0)
            node.BackgroundColor3 = Color3.fromRGB(168, 92, 255)
            node.BackgroundTransparency = 1
            node.BorderSizePixel = 0; node.ZIndex = 5
            cr(node, 100)
            neuralNodes[i] = {obj=node, px=x, py=y, phase=math.random()*6.28}
        end
        for i = 1, #neuralNodes do
            for j = i+1, #neuralNodes do
                local n1 = neuralNodes[i]; local n2 = neuralNodes[j]
                local dx = (n1.px - n2.px) * vpW; local dy = (n1.py - n2.py) * vpH
                local dist = math.sqrt(dx*dx + dy*dy)
                if dist < 300 then
                    local line = Instance.new("Frame", NeuralLayer)
                    line.AnchorPoint = Vector2.new(0, 0.5)
                    line.Position = UDim2.new(n1.px, 0, n1.py, 0)
                    line.Size = UDim2.new(0, dist, 0, 1)
                    line.Rotation = math.deg(math.atan2(dy, dx))
                    line.BackgroundColor3 = Color3.fromRGB(168, 92, 255)
                    line.BackgroundTransparency = 1
                    line.BorderSizePixel = 0; line.ZIndex = 5
                    table.insert(neuralLines, line)
                end
            end
        end

        -- CAMADA 5: PARTÍCULAS
        local ParticleLayer = nF({Size=UDim2.new(1,0,1,0), ZIndex=6})
        local particles = {}
        local pCount = isMobile and 40 or 80
        for i = 1, pCount do
            local sz = math.random(2, 5)
            local p = Instance.new("Frame", ParticleLayer)
            p.Size = UDim2.new(0, sz, 0, sz)
            p.Position = UDim2.new(0.5, 0, 0.5, 0)
            p.BackgroundColor3 = Color3.fromRGB(math.random(180,240), math.random(100,160), 255)
            p.BackgroundTransparency = 1
            p.BorderSizePixel = 0; p.ZIndex = 6
            cr(p, 100)
            particles[i] = {obj=p, ang=math.random()*6.28, dist=math.random(280,1400), spd=math.random(100,280)}
        end

        -- CAMADA 6: RAIOS
        local RaysLayer = nF({Size=UDim2.new(1,0,1,0), ZIndex=7})
        local rayData = {}
        for i = 1, 30 do
            local ang = (i/30)*360
            local ray = Instance.new("Frame", RaysLayer)
            ray.AnchorPoint = Vector2.new(0.5, 0.5)
            ray.Position = UDim2.new(0.5, 0, 0.5, 0)
            ray.Size = UDim2.new(0, 2, 0, 0)
            ray.BackgroundColor3 = Color3.fromRGB(168, 92, 255)
            ray.BackgroundTransparency = 1
            ray.BorderSizePixel = 0; ray.Rotation = ang; ray.ZIndex = 7
            cr(ray, 100)
            rayData[i] = {obj=ray, delay=i*0.012}
        end

        -- CAMADA 7: GLITCH
        local GlitchLayer = nF({Size=UDim2.new(1,0,1,0), ZIndex=8})
        local glitchBars = {}
        for i = 1, 10 do
            local bar = Instance.new("Frame", GlitchLayer)
            bar.Size = UDim2.new(0, 0, 0, math.random(2, 10))
            bar.Position = UDim2.new(0, 0, math.random(), 0)
            bar.BackgroundColor3 = Color3.fromRGB(math.random(100,255), math.random(0,120), 255)
            bar.BorderSizePixel = 0; bar.BackgroundTransparency = 1; bar.ZIndex = 8
            glitchBars[i] = bar
        end

        -- CAMADA 8: SCANLINES
        local Scanlines = nF({Size=UDim2.new(1,0,1,0), ZIndex=9})
        for i = 0, 100 do
            local line = Instance.new("Frame", Scanlines)
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, i/100, 0)
            line.BackgroundColor3 = Color3.new(0,0,0)
            line.BackgroundTransparency = 1
            line.BorderSizePixel = 0; line.ZIndex = 9
        end

        -- CAMADA 9: RINGS
        local Portal = nF({Size=UDim2.new(1,0,1,0), ZIndex=11})
        local rings = {}
        for i = 1, 5 do
            local baseSz = 50 + i * 65
            local ring = Instance.new("Frame", Portal)
            ring.AnchorPoint = Vector2.new(0.5, 0.5)
            ring.Position = UDim2.new(0.5, 0, 0.5, 0)
            ring.Size = UDim2.new(0, 0, 0, 0)
            ring.BackgroundTransparency = 1; ring.BorderSizePixel = 0; ring.ZIndex = 11 + i
            cr(ring, 1000)
            local stk = Instance.new("UIStroke", ring)
            stk.Color = Color3.fromRGB(160 + i*10, 80 + i*12, 255)
            stk.Thickness = 3.5 - i*0.4
            stk.Transparency = 1
            stk.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            local dot = Instance.new("Frame", ring)
            dot.AnchorPoint = Vector2.new(0.5, 0.5)
            dot.Size = UDim2.new(0, math.max(6, 10 - i), 0, math.max(6, 10 - i))
            dot.Position = UDim2.new(0.5, 0, 0, 0)
            dot.BackgroundColor3 = Color3.fromRGB(230, 200, 255)
            dot.BackgroundTransparency = 1
            dot.BorderSizePixel = 0; dot.ZIndex = 21 + i
            cr(dot, 100)
            local ds = Instance.new("UIStroke", dot)
            ds.Color = Color3.fromRGB(255, 220, 255); ds.Thickness = 2; ds.Transparency = 1
            rings[i] = {f=ring, s=stk, dot=dot, ds=ds, baseSz=baseSz, rotSpd=math.random(25,70)/100 * (i%2==0 and 1 or -1)}
        end

        -- CAMADA 10: CORE
        local Core = Instance.new("Frame", Portal)
        Core.AnchorPoint = Vector2.new(0.5, 0.5)
        Core.Position = UDim2.new(0.5, 0, 0.5, 0)
        Core.Size = UDim2.new(0, 0, 0, 0)
        Core.BackgroundColor3 = Color3.fromRGB(220, 180, 255)
        Core.BackgroundTransparency = 1
        Core.BorderSizePixel = 0; Core.ZIndex = 10
        cr(Core, 1000)
        local CoreGrad = Instance.new("UIGradient", Core)
        CoreGrad.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(100,30,180))
        CoreGrad.Rotation = 45
        local CoreGlow = Instance.new("Frame", Core)
        CoreGlow.Size = UDim2.new(2.5, 0, 2.5, 0)
        CoreGlow.Position = UDim2.new(-0.75, 0, -0.75, 0)
        CoreGlow.BackgroundColor3 = Color3.fromRGB(168, 92, 255)
        CoreGlow.BackgroundTransparency = 1
        CoreGlow.BorderSizePixel = 0; CoreGlow.ZIndex = 9
        cr(CoreGlow, 1000)
        local CGG = Instance.new("UIGradient", CoreGlow)
        CGG.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 0.6),
            NumberSequenceKeypoint.new(1, 1)
        })

        -- CAMADA 11: RUNAS
        local RunesLayer = nF({Size=UDim2.new(1,0,1,0), ZIndex=25})
        local runes = {}
        local runeSyms = {"ᚠ","ᚢ","ᚦ","ᚨ","ᚱ","ᚲ","ᚷ","ᚹ","ᚺ","ᚾ","ᛁ","ᛃ"}
        for i = 1, 12 do
            local ang = (i/12)*6.28
            local r = nL({Size=UDim2.new(0, 40, 0, 40), Position=UDim2.new(0.5, math.cos(ang)*240 - 20, 0.5, math.sin(ang)*240 - 20), Text=runeSyms[i], Font=Enum.Font.GothamBold, TextSize=22, TextColor3=Color3.fromRGB(200, 150, 255), TextTransparency=1, ZIndex=25})
            local rs = Instance.new("UIStroke", r)
            rs.Color = Color3.fromRGB(168, 92, 255); rs.Thickness = 1; rs.Transparency = 1
            runes[i] = {obj=r, st=rs, ang=ang}
        end

        -- CAMADA 12: LOGO LETRA POR LETRA
        local LogoCont = nF({Size=UDim2.new(1,0,0,180), Position=UDim2.new(0,0,0.5,-150), ZIndex=22})
        local logoText = "VOID HUB"
        local letters = {}
        local baseSz = math.min(130, vpW/9)
        local totalW = 0
        local wids = {}
        for i = 1, #logoText do
            local ch = string.sub(logoText, i, i)
            local w = (ch == " ") and baseSz*0.35 or baseSz*0.72
            wids[i] = {c=ch, w=w}; totalW = totalW + w
        end
        local curX = (vpW - totalW)/2
        for i = 1, #logoText do
            if wids[i].c ~= " " then
                local letter = Instance.new("TextLabel", LogoCont)
                letter.Size = UDim2.new(0, wids[i].w * 1.3, 1, 0)
                letter.Position = UDim2.new(0, curX - 20 + math.random(-vpW, vpW), 0, math.random(-vpH, vpH))
                letter.BackgroundTransparency = 1
                letter.Text = wids[i].c
                letter.TextColor3 = Color3.fromRGB(245, 220, 255)
                letter.Font = Enum.Font.GothamBlack
                letter.TextSize = baseSz
                letter.TextTransparency = 1
                letter.TextStrokeColor3 = Color3.fromRGB(168, 92, 255)
                letter.TextStrokeTransparency = 1
                letter.Rotation = math.random(-180, 180)
                letter.ZIndex = 22 + i
                local gr = Instance.new("UIGradient", letter)
                gr.Color = ColorSequence.new(Color3.fromRGB(255,230,255), Color3.fromRGB(160,80,240))
                gr.Rotation = 45
                local trailR = letter:Clone(); trailR.Parent = LogoCont
                trailR.TextColor3 = Color3.fromRGB(255, 80, 120); trailR.TextTransparency = 1
                trailR.TextStrokeTransparency = 1; trailR.ZIndex = 21
                local trailB = letter:Clone(); trailB.Parent = LogoCont
                trailB.TextColor3 = Color3.fromRGB(80, 160, 255); trailB.TextTransparency = 1
                trailB.TextStrokeTransparency = 1; trailB.ZIndex = 21
                letters[i] = {main=letter, tr=trailR, tb=trailB, targetX=curX - 20}
            end
            curX = curX + wids[i].w
        end

        -- CAMADA 13: SUBTITLE
        local Subtitle = nL({Size=UDim2.new(1,0,0,26), Position=UDim2.new(0,0,0.5,60), Text="", TextColor3=Color3.fromRGB(220,190,255), Font=Enum.Font.GothamBold, TextSize=16, TextTransparency=1, ZIndex=32})
        local SubGlow = Instance.new("UIStroke", Subtitle)
        SubGlow.Color = Color3.fromRGB(168, 92, 255); SubGlow.Thickness = 1; SubGlow.Transparency = 1

        -- CAMADA 14: VERSION
        local Version = nL({Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0.5,140), Text="v  7  .  0", TextColor3=Color3.fromRGB(180,120,240), Font=Enum.Font.GothamBold, TextSize=13, TextTransparency=1, ZIndex=32})

        -- CAMADA 15: ARCS
        local ArcsLayer = nF({Size=UDim2.new(0, 600, 0, 200), Position=UDim2.new(0.5,-300,0.5,-160), ZIndex=24})
        local arcs = {}
        for i = 1, 12 do
            local a = Instance.new("Frame", ArcsLayer)
            a.AnchorPoint = Vector2.new(0, 0.5)
            a.Position = UDim2.new(0.5, 0, 0.5, 0)
            a.Size = UDim2.new(0, 0, 0, 2)
            a.BackgroundColor3 = Color3.fromRGB(200, 150, 255)
            a.BackgroundTransparency = 1
            a.BorderSizePixel = 0
            a.Rotation = math.random(-50, 50); a.ZIndex = 24
            cr(a, 100)
            local as_ = Instance.new("UIStroke", a)
            as_.Color = Color3.fromRGB(255, 220, 255); as_.Thickness = 1; as_.Transparency = 1
            arcs[i] = {obj=a, st=as_}
        end

        -- CAMADA 16: PROGRESS
        local ProgBg = nF({Size=UDim2.new(0, 340, 0, 4), Position=UDim2.new(0.5,-170,0.5,200), BackgroundColor3=Color3.fromRGB(40,30,60), BackgroundTransparency=1, ZIndex=33})
        cr(ProgBg, 100)
        local ProgFill = Instance.new("Frame", ProgBg)
        ProgFill.Size = UDim2.new(0, 0, 1, 0)
        ProgFill.BackgroundColor3 = Color3.fromRGB(168, 92, 255)
        ProgFill.BorderSizePixel = 0; ProgFill.ZIndex = 34
        cr(ProgFill, 100)
        local PFG = Instance.new("UIGradient", ProgFill)
        PFG.Color = ColorSequence.new(Color3.fromRGB(140,60,220), Color3.fromRGB(255,200,255))
        local ProgText = nL({Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,0.5,212), Text="", TextColor3=Color3.fromRGB(160,110,220), Font=Enum.Font.GothamBold, TextSize=10, TextTransparency=1, ZIndex=33})

        -- CAMADA 17: SHOCKWAVE
        local ShockFrame = newproxy and nil or Instance.new("Frame", IntroGui)
        ShockFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        ShockFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        ShockFrame.Size = UDim2.new(0, 0, 0, 0)
        ShockFrame.BackgroundTransparency = 1; ShockFrame.BorderSizePixel = 0; ShockFrame.ZIndex = 35
        cr(ShockFrame, 1000)
        local ShockStroke = Instance.new("UIStroke", ShockFrame)
        ShockStroke.Color = Color3.fromRGB(220,180,255); ShockStroke.Thickness = 6; ShockStroke.Transparency = 1

        -- CAMADA 18: VIGNETTE
        local Vig = nF({Size=UDim2.new(1,0,1,0), ZIndex=40})
        for _, cfgV in ipairs({{Size=UDim2.new(1,0,0,160), Pos=UDim2.new(0,0,0,0), Rot=90},{Size=UDim2.new(1,0,0,160), Pos=UDim2.new(0,0,1,-160), Rot=270},{Size=UDim2.new(0,180,1,0), Pos=UDim2.new(0,0,0,0), Rot=0},{Size=UDim2.new(0,180,1,0), Pos=UDim2.new(1,-180,0,0), Rot=180}}) do
            local v = Instance.new("Frame", Vig)
            v.Size = cfgV.Size; v.Position = cfgV.Pos
            v.BackgroundColor3 = Color3.new(0,0,0); v.BorderSizePixel = 0; v.ZIndex = 40
            local g = Instance.new("UIGradient", v); g.Rotation = cfgV.Rot
            g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1)})
        end

        -- CAMADA 19: FLASH
        local Flash = nF({Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(240,220,255), BackgroundTransparency=1, ZIndex=50})

        -- SKIP
        local Skip = Instance.new("TextButton", IntroGui)
        Skip.Size = UDim2.new(0, 90, 0, 26)
        Skip.Position = UDim2.new(1, -110, 1, -42)
        Skip.BackgroundColor3 = Color3.fromRGB(30,20,50); Skip.BackgroundTransparency = 0.4
        Skip.Text = "SKIP ▶▶"; Skip.TextColor3 = Color3.fromRGB(180,150,220)
        Skip.Font = Enum.Font.GothamBold; Skip.TextSize = 11; Skip.ZIndex = 100
        cr(Skip, 6)
        local skipReq = false
        Skip.MouseButton1Click:Connect(function() skipReq = true end)

        -- LOOP REALTIME
        local animating = true
        local st = tick()
        task.spawn(function()
            while animating and IntroGui.Parent do
                local dt = RunService.RenderStepped:Wait()
                local el = tick() - st
                for i, s in ipairs(starData) do
                    if s.obj.Parent then s.obj.Position = UDim2.new((s.baseX + el*s.spd) % 1, 0, s.baseY + math.sin(el*0.5 + s.phase)*0.005, 0) end
                end
                for i, col in ipairs(matrixCols) do
                    if col.obj.Parent then
                        local y = col.obj.Position.Y.Scale + dt * col.speed
                        if y > 1.5 then y = -0.5; col.offset = math.random() end
                        col.obj.Position = UDim2.new(col.obj.Position.X.Scale, 0, y, 0)
                        for j, ch in ipairs(col.chars) do
                            if ch.Parent and math.random() < 0.05 then ch.Text = chars[math.random(#chars)] end
                        end
                    end
                end
                for i, n in ipairs(neuralNodes) do
                    if n.obj.Parent and n.obj.BackgroundTransparency < 1 then
                        n.obj.BackgroundTransparency = math.min(1, 1 - (0.5 + math.sin(el*3 + n.phase)*0.5)*0.7)
                    end
                end
                for i, p in ipairs(particles) do
                    if p.obj.Parent and p.dist > 0 then
                        p.dist = math.max(0, p.dist - p.spd * dt)
                        p.ang = p.ang + dt * 0.5
                        p.obj.Position = UDim2.new(0.5 + math.cos(p.ang)*p.dist/vpW, 0, 0.5 + math.sin(p.ang)*p.dist/vpH, 0)
                        if p.dist < 30 then
                            p.obj.BackgroundTransparency = 1; p.dist = -1
                        end
                    end
                end
                for i, r in ipairs(rings) do
                    if r.f.Parent and r.f.Size.X.Offset > 5 then
                        local ang = el * r.rotSpd % 6.28
                        r.dot.Position = UDim2.new(0.5 + math.cos(ang)*0.5, 0, 0.5 + math.sin(ang)*0.5, 0)
                    end
                end
                for i, r in ipairs(runes) do
                    if r.obj.Parent and r.obj.TextTransparency < 1 then
                        local a = r.ang + el*0.15
                        r.obj.Position = UDim2.new(0.5, math.cos(a)*240 - 20, 0.5, math.sin(a)*240 - 20)
                    end
                end
            end
        end)

        -- ===== ANIMAÇÃO (7 CENAS) =====
        task.spawn(function()
            pcall(function()
                -- CENA 1: VOID
                task.wait(0.05)
                local dot = nF({Size=UDim2.new(0,4,0,4), Position=UDim2.new(0.5,-2,0.5,-2), BackgroundColor3=Color3.fromRGB(220,180,255), BackgroundTransparency=0, ZIndex=10})
                cr(dot, 100)
                tw(dot, 0.4, {Size=UDim2.new(0,20,0,20), Position=UDim2.new(0.5,-10,0.5,-10)})
                task.wait(0.4)
                if skipReq then animating=false; IntroGui:Destroy(); Complete(); return end

                -- CENA 2: AWAKENING
                tw(RadialBg, 1.3, {BackgroundTransparency=0})
                tw(dot, 0.3, {BackgroundTransparency=1, Size=UDim2.new(0,60,0,60), Position=UDim2.new(0.5,-30,0.5,-30)})
                for i, r in ipairs(rayData) do
                    task.spawn(function()
                        task.wait(r.delay)
                        tw(r.obj, 0.8, {Size=UDim2.new(0, 2, 0, math.max(vpH/2, 300)), BackgroundTransparency=0.85})
                    end)
                end
                task.spawn(function()
                    task.wait(0.3)
                    for i, p in ipairs(particles) do task.wait(0.008); if p.obj.Parent then p.obj.BackgroundTransparency = 0.15 end end
                end)
                task.spawn(function()
                    task.wait(0.5)
                    for _, n in ipairs(neuralNodes) do if n.obj.Parent then tw(n.obj, 0.5, {BackgroundTransparency=0.3}) end end
                    for _, l in ipairs(neuralLines) do if l.Parent then tw(l, 0.8, {BackgroundTransparency=0.85}) end end
                end)
                task.spawn(function()
                    task.wait(1)
                    for _, c in ipairs(matrixCols) do if c.obj.Parent then tw(c.obj, 0.5, {BackgroundTransparency=0}) end end
                    for _, c in ipairs(matrixCols) do for _, ch in ipairs(c.chars) do if ch.Parent then tw(ch, 0.5, {TextTransparency=math.random(20,60)/100}) end end end
                end)
                task.wait(2)

                -- CENA 3: GLITCH
                if skipReq then animating=false; IntroGui:Destroy(); Complete(); return end
                for _, l in ipairs(Scanlines:GetChildren()) do if l:IsA("Frame") then tw(l, 0.3, {BackgroundTransparency=0.85}) end end
                task.spawn(function()
                    local endT = tick() + 0.9
                    while tick() < endT and IntroGui.Parent and not skipReq do
                        for i, bar in ipairs(glitchBars) do
                            if math.random() < 0.4 then
                                bar.Size = UDim2.new(math.random(20,60)/100, 0, 0, math.random(2,10))
                                bar.Position = UDim2.new(math.random(0,30)/100, 0, math.random(), 0)
                                bar.BackgroundTransparency = 0.3
                            end
                        end
                        task.wait(0.05)
                    end
                    for _, bar in ipairs(glitchBars) do tw(bar, 0.15, {BackgroundTransparency=1}) end
                end)
                local hacker = {"SYS.INIT","V0ID","LOADING","SEGFAULT","ROOT>","010101","//ACCESS"}
                task.spawn(function()
                    local endT = tick() + 0.9
                    while tick() < endT and IntroGui.Parent and not skipReq do
                        local txt = Instance.new("TextLabel", IntroGui)
                        txt.Size = UDim2.new(0, math.random(80,200), 0, 20)
                        txt.Position = UDim2.new(math.random(10,80)/100, 0, math.random(10,90)/100, 0)
                        txt.BackgroundTransparency = 1
                        txt.Text = hacker[math.random(#hacker)]
                        txt.TextColor3 = Color3.fromRGB(math.random(100,255), math.random(0,150), 255)
                        txt.Font = Enum.Font.Code; txt.TextSize = math.random(10,16)
                        txt.TextTransparency = 0.3; txt.ZIndex = 8
                        TweenService:Create(txt, TweenInfo.new(0.1), {TextTransparency=1}):Play()
                        task.delay(0.15, function() if txt then txt:Destroy() end end)
                        task.wait(0.04)
                    end
                end)
                Flash.BackgroundTransparency = 0.3
                tw(Flash, 0.2, {BackgroundTransparency=1})
                task.wait(1)

                -- CENA 4: PORTAL
                if skipReq then animating=false; IntroGui:Destroy(); Complete(); return end
                tw(Core, 0.6, {Size=UDim2.new(0, 50, 0, 50), BackgroundTransparency=0.3})
                tw(CoreGlow, 0.8, {BackgroundTransparency=0.6})
                for i, r in ipairs(rings) do
                    task.spawn(function()
                        task.wait(i * 0.12)
                        tw(r.f, 0.9, {Size=UDim2.new(0, r.baseSz, 0, r.baseSz)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        tw(r.s, 0.9, {Transparency=0.2})
                        tw(r.dot, 0.7, {BackgroundTransparency=0})
                        tw(r.ds, 0.7, {Transparency=0.3})
                    end)
                end
                for i, r in ipairs(runes) do
                    task.spawn(function()
                        task.wait(i * 0.05)
                        tw(r.obj, 0.6, {TextTransparency=0.15})
                        tw(r.st, 0.6, {Transparency=0.6})
                    end)
                end
                task.spawn(function()
                    for k = 1, 3 do
                        tw(Core, 0.25, {BackgroundTransparency=0.1}); task.wait(0.25)
                        tw(Core, 0.25, {BackgroundTransparency=0.5}); task.wait(0.25)
                    end
                end)
                task.wait(1.5)

                -- CENA 5: LOGO ASSEMBLY
                if skipReq then animating=false; IntroGui:Destroy(); Complete(); return end
                Flash.BackgroundTransparency = 0.2
                tw(Flash, 0.25, {BackgroundTransparency=1})
                for i, l in ipairs(letters) do
                    task.spawn(function()
                        task.wait((i-1) * 0.08)
                        tw(l.main, 0.6, {Position=UDim2.new(0, l.targetX, 0, 0), Rotation=0, TextTransparency=0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        tw(l.tr, 0.6, {Position=UDim2.new(0, l.targetX, 0, 0), Rotation=0, TextTransparency=0.6}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        tw(l.tb, 0.6, {Position=UDim2.new(0, l.targetX, 0, 0), Rotation=0, TextTransparency=0.6}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                        task.wait(0.3)
                        tw(l.tr, 0.4, {TextTransparency=1})
                        tw(l.tb, 0.4, {TextTransparency=1})
                    end)
                end
                task.wait(1.0)
                -- Screen shake
                local orig = LogoCont.Position
                for k = 1, 12 do
                    LogoCont.Position = orig + UDim2.new(0, math.random(-8,8), 0, math.random(-8,8))
                    task.wait(0.025)
                end
                LogoCont.Position = orig
                -- Arcs flare
                task.spawn(function()
                    for i, a in ipairs(arcs) do
                        task.wait(0.04)
                        tw(a.obj, 0.3, {Size=UDim2.new(0, math.random(80,220), 0, 2), BackgroundTransparency=0.3})
                        task.delay(0.3, function() if a.obj.Parent then tw(a.obj, 0.4, {Size=UDim2.new(0, 0, 0, 2), BackgroundTransparency=1}) end end)
                    end
                end)
                task.wait(0.2)
                tw(Version, 0.35, {TextTransparency=0})

                -- CENA 6: POWER
                if skipReq then animating=false; IntroGui:Destroy(); Complete(); return end
                task.wait(0.3)
                Subtitle.TextTransparency = 0
                local tag = "AIMBOT  •  DESEMPENHO  •  IA"
                for i = 1, #tag do Subtitle.Text = string.sub(tag, 1, i); task.wait(0.025) end
                task.wait(0.15)
                ProgText.TextTransparency = 0
                tw(ProgBg, 0.3, {BackgroundTransparency=0.2})
                local stages = {"INICIALIZANDO...","CARREGANDO MÓDULOS...","ATIVANDO AIMBOT...","OTIMIZANDO FPS...","CONECTANDO IA...","PRONTO."}
                for i, s in ipairs(stages) do
                    ProgText.Text = s
                    tw(ProgFill, 0.2, {Size=UDim2.new(i / #stages, 0, 1, 0)})
                    task.wait(0.22)
                end
                task.wait(0.1)
                tw(CoreGrad, 0.3, {Rotation=90})
                task.wait(0.4)

                -- CENA 7: COLLAPSE
                animating = false
                for _, p in ipairs(particles) do if p.obj.Parent then tw(p.obj, 0.5, {BackgroundTransparency=1, Size=UDim2.new(0,0,0,0)}) end end
                for _, r in ipairs(rings) do
                    tw(r.f, 0.5, {Size=UDim2.new(0,0,0,0)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                    tw(r.s, 0.5, {Transparency=1}); tw(r.dot, 0.4, {BackgroundTransparency=1})
                end
                for _, l in ipairs(letters) do
                    tw(l.main, 0.5, {TextTransparency=1, Position=UDim2.new(0, l.targetX, 0, -50)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                end
                for _, r in ipairs(runes) do if r.obj.Parent then tw(r.obj, 0.4, {TextTransparency=1}) end end
                tw(Core, 0.4, {Size=UDim2.new(0,0,0,0), BackgroundTransparency=1})
                tw(CoreGlow, 0.4, {BackgroundTransparency=1})
                tw(Subtitle, 0.4, {TextTransparency=1}); tw(SubGlow, 0.4, {Transparency=1})
                tw(Version, 0.4, {TextTransparency=1})
                task.wait(0.2)
                ShockStroke.Transparency = 0
                tw(ShockFrame, 0.7, {Size=UDim2.new(0, vpW*2.5, 0, vpW*2.5)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                tw(ShockStroke, 0.7, {Transparency=1, Thickness=1})
                Flash.BackgroundColor3 = Color3.fromRGB(255,255,255)
                tw(Flash, 0.1, {BackgroundTransparency=0})
                task.wait(0.1)
                Flash.BackgroundColor3 = Color3.new(0,0,0)
                tw(Flash, 0.3, {BackgroundTransparency=0.5})
                task.wait(0.3)
                for _, s in ipairs(starData) do if s.obj.Parent then tw(s.obj, 0.3, {BackgroundTransparency=1}) end end
                for _, r in ipairs(rayData) do if r.obj.Parent then tw(r.obj, 0.3, {BackgroundTransparency=1}) end end
                for _, l in ipairs(Scanlines:GetChildren()) do if l:IsA("Frame") then tw(l, 0.3, {BackgroundTransparency=1}) end end
                tw(RadialBg, 0.4, {BackgroundTransparency=1})
                tw(ProgBg, 0.4, {BackgroundTransparency=1})
                tw(ProgFill, 0.4, {BackgroundTransparency=1})
                tw(ProgText, 0.4, {TextTransparency=1})
                tw(Flash, 0.4, {BackgroundTransparency=1})
                tw(Bg, 0.5, {BackgroundTransparency=1})
                task.wait(0.6)
            end)
            if IntroGui and IntroGui.Parent then IntroGui:Destroy() end
            Complete()
        end)

        task.delay(13, function() if IntroGui and IntroGui.Parent then IntroGui:Destroy() end; Complete() end)
    end)

    if not success then warn("[VOID HUB] Erro intro ULTRA-PREMIUM: "..tostring(err)); Complete() end
end

-- ==========================================
-- CONSTRUÇÃO DA INTERFACE (PREMIUM COMPACTA 480x360)
-- ==========================================
local function BuildUI()
    print("[VOID HUB] Construindo interface premium compacta.")
    local success, err = pcall(function()
        for _,v in ipairs(PlayerGui:GetChildren()) do if v.Name=="VoidHub7" then v:Destroy() end end

        local C = Config.Colors
        local SG = Instance.new("ScreenGui")
        SG.Name="VoidHub7"; SG.IgnoreGuiInset=true; SG.ResetOnSpawn=false
        SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; SG.Parent=PlayerGui

        local BD = Instance.new("Frame", SG)
        BD.Size=UDim2.new(1,0,1,0); BD.BackgroundColor3=Color3.fromRGB(5,3,12)
        BD.BackgroundTransparency=0.35; BD.BorderSizePixel=0; BD.ZIndex=1

        local BgFx = Instance.new("Frame", BD)
        BgFx.Size=UDim2.new(1,0,1,0); BgFx.BackgroundColor3=Color3.new(1,1,1)
        BgFx.BackgroundTransparency=0.5; BgFx.BorderSizePixel=0; BgFx.ZIndex=2
        local BgFxGrad = Instance.new("UIGradient", BgFx)
        BgFxGrad.Color = ColorSequence.new(Color3.fromRGB(60,20,120), Color3.fromRGB(120,40,200), Color3.fromRGB(40,10,80))
        BgFxGrad.Rotation = 45
        task.spawn(function() while BgFx.Parent do BgFxGrad.Rotation = (BgFxGrad.Rotation + 0.3) % 360; task.wait(0.05) end end)

        local ToastStack = Instance.new("Frame", SG)
        ToastStack.Size = UDim2.new(0, 240, 0, 400)
        ToastStack.Position = UDim2.new(1, -260, 1, -420)
        ToastStack.BackgroundTransparency = 1; ToastStack.ZIndex = 300
        local TL = Instance.new("UIListLayout", ToastStack)
        TL.VerticalAlignment = Enum.VerticalAlignment.Bottom; TL.Padding = UDim.new(0, 6)

        local function Toast(title, subtitle, kind)
            local accent = kind=="success" and C.Success or (kind=="error" and C.Danger or (kind=="warning" and C.Warning or C.Accent))
            local t = Instance.new("Frame", ToastStack)
            t.Size = UDim2.new(1, 0, 0, 46); t.BackgroundColor3 = C.Panel; t.BackgroundTransparency = 0.05; t.BorderSizePixel = 0; t.ZIndex = 301
            Utils.Corner(t, 8)
            local ts = Instance.new("UIStroke", t); ts.Color = accent; ts.Thickness = 1.5; ts.Transparency = 0.3
            local bar = Instance.new("Frame", t); bar.Size = UDim2.new(0, 3, 1, -10); bar.Position = UDim2.new(0, 0, 0, 5); bar.BackgroundColor3 = accent; bar.BorderSizePixel = 0; bar.ZIndex = 302
            Utils.Corner(bar, 2)
            local ttl = Instance.new("TextLabel", t); ttl.Size = UDim2.new(1, -24, 0, 18); ttl.Position = UDim2.new(0, 12, 0, 6); ttl.BackgroundTransparency = 1; ttl.Text = title; ttl.TextColor3 = C.Text; ttl.Font = Enum.Font.GothamBold; ttl.TextSize = 11; ttl.TextXAlignment = Enum.TextXAlignment.Left; ttl.ZIndex = 302
            local sub = Instance.new("TextLabel", t); sub.Size = UDim2.new(1, -24, 0, 14); sub.Position = UDim2.new(0, 12, 0, 24); sub.BackgroundTransparency = 1; sub.Text = subtitle or ""; sub.TextColor3 = C.TextDim; sub.Font = Enum.Font.Gotham; sub.TextSize = 9; sub.TextXAlignment = Enum.TextXAlignment.Left; sub.ZIndex = 302
            local sc = Instance.new("UIScale", t); sc.Scale = 0.7
            TweenService:Create(sc, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Scale=1}):Play()
            task.delay(2.8, function()
                if t and t.Parent then
                    TweenService:Create(sc, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Scale=0.7}):Play()
                    TweenService:Create(t, TweenInfo.new(0.3), {BackgroundTransparency=1}):Play()
                    TweenService:Create(ts, TweenInfo.new(0.3), {Transparency=1}):Play()
                    task.delay(0.35, function() if t then t:Destroy() end end)
                end
            end)
        end

        local FH = Instance.new("Frame", SG)
        FH.Size=UDim2.new(0,200,0,58); FH.Position=UDim2.new(1,-218,0,16)
        FH.BackgroundColor3=C.Panel; FH.BackgroundTransparency=0.1; FH.ZIndex=200
        Utils.Corner(FH,10)
        local FHStroke = Utils.Stroke(FH,C.Accent,1.5,0.5)
        local FHIcon = Instance.new("TextLabel", FH); FHIcon.Size=UDim2.new(0,26,0,26); FHIcon.Position=UDim2.new(0,8,0,6); FHIcon.BackgroundTransparency=1; FHIcon.Text="⚡"; FHIcon.Font=Enum.Font.GothamBold; FHIcon.TextSize=17; FHIcon.TextColor3=C.AccentLight; FHIcon.ZIndex=201
        local FHLabel = Instance.new("TextLabel", FH); FHLabel.Size=UDim2.new(1,-42,0,22); FHLabel.Position=UDim2.new(0,38,0,6); FHLabel.BackgroundTransparency=1; FHLabel.Text="FPS: --"; FHLabel.TextColor3=C.Success; FHLabel.Font=Enum.Font.GothamBold; FHLabel.TextSize=13; FHLabel.TextXAlignment=Enum.TextXAlignment.Left; FHLabel.ZIndex=201
        local FHStatus = Instance.new("TextLabel", FH); FHStatus.Size=UDim2.new(1,-42,0,12); FHStatus.Position=UDim2.new(0,38,0,27); FHStatus.BackgroundTransparency=1; FHStatus.Text="—"; FHStatus.TextColor3=C.TextDim; FHStatus.Font=Enum.Font.Gotham; FHStatus.TextSize=9; FHStatus.TextXAlignment=Enum.TextXAlignment.Left; FHStatus.ZIndex=201
        local FHBarBg = Instance.new("Frame", FH); FHBarBg.Size=UDim2.new(1,-16,0,3); FHBarBg.Position=UDim2.new(0,8,1,-8); FHBarBg.BackgroundColor3=C.ToggleOff; FHBarBg.BorderSizePixel=0; FHBarBg.ZIndex=201; Utils.Corner(FHBarBg,2)
        local FHBarFill = Instance.new("Frame", FHBarBg); FHBarFill.Size=UDim2.new(0,0,1,0); FHBarFill.BackgroundColor3=C.Success; FHBarFill.BorderSizePixel=0; FHBarFill.ZIndex=202; Utils.Corner(FHBarFill,2)

        local FB = Instance.new("TextButton", SG)
        FB.Size=UDim2.new(0,48,0,48); FB.Position=UDim2.new(0,18,0.5,-24)
        FB.BackgroundColor3=C.Panel; FB.Text=""; FB.Visible=false; FB.ZIndex=100
        Utils.Corner(FB,14); Utils.Stroke(FB,C.Accent,2,0.3)
        local FI = Instance.new("ImageLabel", FB); FI.Size=UDim2.new(1,0,1,0); FI.BackgroundTransparency=1; FI.Image=CONFIG_IMAGE_ID; FI.ScaleType=Enum.ScaleType.Crop; FI.ZIndex=101; Utils.Corner(FI,14)

        local MN = Instance.new("Frame", SG)
        MN.Size=UDim2.new(0,480,0,360); MN.Position=UDim2.new(0.5,-240,0.5,-180)
        MN.BackgroundColor3=C.BG; MN.BackgroundTransparency=0.02; MN.ClipsDescendants=true; MN.ZIndex=2; MN.Visible=false
        Utils.Corner(MN,14); Utils.Stroke(MN,C.Accent,1.5,0.5)
        local MNGrad = Instance.new("UIGradient", MN); MNGrad.Color = ColorSequence.new(C.BG, C.Panel); MNGrad.Rotation = 135

        local function Min()
            Utils.Tween(MN,0.25,{Size=UDim2.new(0,0,0,0)})
            Utils.Tween(BD,0.25,{BackgroundTransparency=1})
            task.delay(0.26,function() MN.Visible=false; BD.Visible=false; FB.Visible=true end)
        end
        local function Res()
            MN.Visible=true; BD.Visible=true; MN.Size=UDim2.new(0,0,0,0)
            Utils.Tween(MN,0.28,{Size=UDim2.new(0,480,0,360)})
            Utils.Tween(BD,0.28,{BackgroundTransparency=0.35})
            FB.Visible=false
        end
        Connect(FB.MouseButton1Click, Res)

        local HD = Instance.new("Frame", MN); HD.Size=UDim2.new(1,0,0,48); HD.BackgroundTransparency=1; HD.ZIndex=3
        local LF = Instance.new("Frame", HD); LF.Size=UDim2.new(0,28,0,28); LF.Position=UDim2.new(0,14,0.5,-14); LF.BackgroundColor3=C.Accent; LF.ZIndex=3; Utils.Corner(LF,7)
        local LFGrad = Instance.new("UIGradient", LF); LFGrad.Color = ColorSequence.new(C.Accent, C.AccentLight); LFGrad.Rotation = 45
        local LI = Instance.new("ImageLabel", LF); LI.Size=UDim2.new(1,0,1,0); LI.BackgroundTransparency=1; LI.Image=CONFIG_IMAGE_ID; LI.ScaleType=Enum.ScaleType.Crop; LI.ZIndex=4; Utils.Corner(LI,7)
        local TT = Instance.new("TextLabel", HD); TT.Size=UDim2.new(0,110,0,18); TT.Position=UDim2.new(0,50,0,12); TT.BackgroundTransparency=1; TT.Text="VOID HUB"; TT.TextColor3=C.Text; TT.Font=Enum.Font.GothamBlack; TT.TextSize=14; TT.TextXAlignment=Enum.TextXAlignment.Left; TT.ZIndex=3
        local TTGrad = Instance.new("UIGradient", TT); TTGrad.Color = ColorSequence.new(C.Text, C.AccentLight); TTGrad.Rotation = 45
        local VB = Instance.new("Frame", HD); VB.Size=UDim2.new(0,36,0,15); VB.Position=UDim2.new(0,98,0,15); VB.BackgroundColor3=C.Accent; VB.BackgroundTransparency=0.7; VB.ZIndex=3; Utils.Corner(VB,7)
        local VBT = Instance.new("TextLabel", VB); VBT.Size=UDim2.new(1,0,1,0); VBT.BackgroundTransparency=1; VBT.Text="v7.0"; VBT.TextColor3=C.AccentLight; VBT.Font=Enum.Font.GothamBold; VBT.TextSize=9; VBT.ZIndex=4
        local ST = Instance.new("TextLabel", HD); ST.Size=UDim2.new(0,170,0,12); ST.Position=UDim2.new(0,50,0,30); ST.BackgroundTransparency=1; ST.Text="Aimbot • Desempenho • IA"; ST.TextColor3=C.TextDim; ST.Font=Enum.Font.Gotham; ST.TextSize=9; ST.TextXAlignment=Enum.TextXAlignment.Left; ST.ZIndex=3

        local BM = Instance.new("TextButton", HD); BM.Size=UDim2.new(0,28,0,28); BM.Position=UDim2.new(1,-70,0.5,-14); BM.BackgroundColor3=C.Card; BM.Text="—"; BM.TextColor3=C.TextDim; BM.Font=Enum.Font.GothamBold; BM.TextSize=13; BM.ZIndex=3; Utils.Corner(BM,7)
        Connect(BM.MouseButton1Click, Min)
        Connect(BM.MouseEnter, function() TweenService:Create(BM, TweenInfo.new(0.15), {BackgroundColor3=C.Accent, TextColor3=C.Text}):Play() end)
        Connect(BM.MouseLeave, function() TweenService:Create(BM, TweenInfo.new(0.15), {BackgroundColor3=C.Card, TextColor3=C.TextDim}):Play() end)

        local BC = Instance.new("TextButton", HD); BC.Size=UDim2.new(0,28,0,28); BC.Position=UDim2.new(1,-38,0.5,-14); BC.BackgroundColor3=C.Card; BC.Text="✕"; BC.TextColor3=C.Danger; BC.Font=Enum.Font.GothamBold; BC.TextSize=12; BC.ZIndex=3; Utils.Corner(BC,7)
        Connect(BC.MouseEnter, function() TweenService:Create(BC, TweenInfo.new(0.15), {BackgroundColor3=C.Danger, TextColor3=C.Text}):Play() end)
        Connect(BC.MouseLeave, function() TweenService:Create(BC, TweenInfo.new(0.15), {BackgroundColor3=C.Card, TextColor3=C.Danger}):Play() end)

        local Divider = Instance.new("Frame", MN); Divider.Size=UDim2.new(1,-28,0,1); Divider.Position=UDim2.new(0,14,0,48); Divider.BackgroundColor3=C.Accent; Divider.BackgroundTransparency=0.7; Divider.BorderSizePixel=0; Divider.ZIndex=3

        local SB_Bg = Instance.new("Frame", MN); SB_Bg.Size=UDim2.new(0,150,1,-49); SB_Bg.Position=UDim2.new(0,0,0,49); SB_Bg.BackgroundColor3=C.Panel; SB_Bg.BackgroundTransparency=0.7; SB_Bg.BorderSizePixel=0; SB_Bg.ZIndex=2
        local SBDiv = Instance.new("Frame", MN); SBDiv.Size=UDim2.new(0,1,1,-49); SBDiv.Position=UDim2.new(0,150,0,49); SBDiv.BackgroundColor3=C.Accent; SBDiv.BackgroundTransparency=0.7; SBDiv.BorderSizePixel=0; SBDiv.ZIndex=3

        local SB_ = Instance.new("ScrollingFrame", MN); SB_.Size=UDim2.new(0,150,1,-49); SB_.Position=UDim2.new(0,0,0,49); SB_.BackgroundTransparency=1; SB_.ScrollBarThickness=0; SB_.CanvasSize=UDim2.new(0,0,0,500); SB_.ZIndex=3
        local SBL = Instance.new("UIListLayout", SB_); SBL.Padding = UDim.new(0, 2); SBL.SortOrder = Enum.SortOrder.LayoutOrder

        local CT = Instance.new("Frame", MN); CT.Size=UDim2.new(1,-150,1,-49); CT.Position=UDim2.new(0,150,0,49); CT.BackgroundTransparency=1; CT.ClipsDescendants=true; CT.ZIndex=5
        local PT = Instance.new("TextLabel", CT); PT.Size=UDim2.new(1,-40,0,22); PT.Position=UDim2.new(0,18,0,12); PT.BackgroundTransparency=1; PT.Text=T("aim_title"); PT.TextColor3=C.Text; PT.Font=Enum.Font.GothamBlack; PT.TextSize=14; PT.TextXAlignment=Enum.TextXAlignment.Left; PT.ZIndex=6
        local PTSub = Instance.new("TextLabel", CT); PTSub.Size=UDim2.new(1,-40,0,14); PTSub.Position=UDim2.new(0,18,0,32); PTSub.BackgroundTransparency=1; PTSub.Text=T("aim_sub"); PTSub.TextColor3=C.TextDim; PTSub.Font=Enum.Font.Gotham; PTSub.TextSize=10; PTSub.TextXAlignment=Enum.TextXAlignment.Left; PTSub.ZIndex=6

        local UI = {}

        function UI.Section(parent, title)
            local s = Instance.new("Frame", parent); s.Size = UDim2.new(1, -10, 0, 18); s.BackgroundTransparency = 1; s.ZIndex = 6
            local lbl = Instance.new("TextLabel", s); lbl.Size = UDim2.new(0, 70, 1, 0); lbl.BackgroundTransparency = 1; lbl.Text = title:upper(); lbl.TextColor3 = C.AccentLight; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 9; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 7
            local line = Instance.new("Frame", s); line.Size = UDim2.new(1, -78, 0, 1); line.Position = UDim2.new(0, 72, 0.5, 0); line.BackgroundColor3 = C.Accent; line.BackgroundTransparency = 0.7; line.BorderSizePixel = 0; line.ZIndex = 7
        end

        function UI.TG(parent,label,desc,key,cb)
            local r=Instance.new("Frame",parent); r.Size=UDim2.new(1,-10,0,44); r.BackgroundColor3=C.Card; r.BackgroundTransparency=0.15; r.ZIndex=6; Utils.Corner(r,8)
            local rs = Instance.new("UIStroke", r); rs.Color = C.Accent; rs.Thickness = 1; rs.Transparency = 1
            local bar = Instance.new("Frame", r); bar.Size = UDim2.new(0, 3, 1, -10); bar.Position = UDim2.new(0, 0, 0, 5); bar.BackgroundColor3 = C.Accent; bar.BorderSizePixel = 0; bar.BackgroundTransparency = 1; bar.ZIndex = 7; Utils.Corner(bar, 2)
            local l=Instance.new("TextLabel",r); l.Size=UDim2.new(1,-68,0,16); l.Position=UDim2.new(0,12,0,6); l.BackgroundTransparency=1; l.Text=label; l.TextColor3=C.Text; l.Font=Enum.Font.GothamBold; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=7
            local s=Instance.new("TextLabel",r); s.Size=UDim2.new(1,-68,0,12); s.Position=UDim2.new(0,12,0,22); s.BackgroundTransparency=1; s.Text=desc or ""; s.TextColor3=C.TextDim; s.Font=Enum.Font.Gotham; s.TextSize=9; s.TextXAlignment=Enum.TextXAlignment.Left; s.ZIndex=7
            local tr=Instance.new("Frame",r); tr.Size=UDim2.new(0,34,0,18); tr.Position=UDim2.new(1,-46,0.5,-9); tr.BackgroundColor3=C.ToggleOff; tr.ZIndex=7; Utils.Corner(tr,9)
            local trs = Instance.new("UIStroke", tr); trs.Color = C.Accent; trs.Thickness = 1.5; trs.Transparency = 1
            local kn=Instance.new("Frame",tr); kn.Size=UDim2.new(0,14,0,14); kn.Position=UDim2.new(0,2,0.5,-7); kn.BackgroundColor3=C.TextDim; kn.ZIndex=8; Utils.Corner(kn,7)
            local st=Config[key] or false
            local function Set(v)
                st=v; Config[key]=v
                if st then
                    TweenService:Create(tr, TweenInfo.new(0.2, Enum.EasingStyle.Back), {BackgroundColor3=C.Accent}):Play()
                    TweenService:Create(trs, TweenInfo.new(0.2), {Transparency=0.3}):Play()
                    TweenService:Create(kn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position=UDim2.new(1,-16,0.5,-7), BackgroundColor3=C.Text}):Play()
                    TweenService:Create(bar, TweenInfo.new(0.2), {BackgroundTransparency=0}):Play()
                    TweenService:Create(rs, TweenInfo.new(0.2), {Transparency=0.7}):Play()
                else
                    TweenService:Create(tr, TweenInfo.new(0.2), {BackgroundColor3=C.ToggleOff}):Play()
                    TweenService:Create(trs, TweenInfo.new(0.2), {Transparency=1}):Play()
                    TweenService:Create(kn, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Position=UDim2.new(0,2,0.5,-7), BackgroundColor3=C.TextDim}):Play()
                    TweenService:Create(bar, TweenInfo.new(0.2), {BackgroundTransparency=1}):Play()
                    TweenService:Create(rs, TweenInfo.new(0.2), {Transparency=1}):Play()
                end
                if cb then cb(st) end
            end
            if st then Set(true) end
            local h=Instance.new("TextButton",r); h.Size=UDim2.new(1,0,1,0); h.BackgroundTransparency=1; h.Text=""; h.ZIndex=20
            Connect(h.MouseButton1Click,function() Set(not st) end)
            Connect(h.MouseEnter, function() TweenService:Create(r, TweenInfo.new(0.15), {BackgroundColor3=C.CardHover}):Play() end)
            Connect(h.MouseLeave, function() TweenService:Create(r, TweenInfo.new(0.15), {BackgroundColor3=C.Card}):Play() end)
        end

        function UI.SL(parent,label,mn,mx,key,cb)
            local r=Instance.new("Frame",parent); r.Size=UDim2.new(1,-10,0,44); r.BackgroundColor3=C.Card; r.BackgroundTransparency=0.15; r.ZIndex=6; Utils.Corner(r,8)
            local l=Instance.new("TextLabel",r); l.Size=UDim2.new(1,-72,0,16); l.Position=UDim2.new(0,12,0,6); l.BackgroundTransparency=1; l.Text=label; l.TextColor3=C.Text; l.Font=Enum.Font.GothamBold; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=7
            local cv=Config[key] or mn
            local vt=Instance.new("TextLabel",r); vt.Size=UDim2.new(0,44,0,16); vt.Position=UDim2.new(1,-58,0,6); vt.BackgroundColor3=C.Accent; vt.BackgroundTransparency=0.8; vt.Text=tostring(cv); vt.TextColor3=C.AccentLight; vt.Font=Enum.Font.GothamBold; vt.TextSize=10; vt.ZIndex=7; Utils.Corner(vt,4)
            local bb=Instance.new("Frame",r); bb.Size=UDim2.new(1,-24,0,3); bb.Position=UDim2.new(0,12,1,-9); bb.BackgroundColor3=C.ToggleOff; bb.BorderSizePixel=0; bb.ZIndex=7; Utils.Corner(bb,2)
            local fl=Instance.new("Frame",bb); fl.Size=UDim2.new((cv-mn)/(mx-mn),0,1,0); fl.BackgroundColor3=C.Accent; fl.BorderSizePixel=0; fl.ZIndex=8; Utils.Corner(fl,2)
            local fg = Instance.new("UIGradient", fl); fg.Color = ColorSequence.new(C.AccentDim, C.AccentLight)
            local kn=Instance.new("Frame",bb); kn.Size=UDim2.new(0,14,0,14); kn.Position=UDim2.new((cv-mn)/(mx-mn),-7,0.5,-7); kn.BackgroundColor3=C.Text; kn.ZIndex=9; Utils.Corner(kn,7)
            local kns = Instance.new("UIStroke", kn); kns.Color = C.Accent; kns.Thickness = 2; kns.Transparency = 0.3
            local h=Instance.new("TextButton",r); h.Size=UDim2.new(1,0,1,0); h.BackgroundTransparency=1; h.Text=""; h.ZIndex=20
            local dr=false
            local function Up(x)
                local rel=math.clamp((x-bb.AbsolutePosition.X)/math.max(bb.AbsoluteSize.X,1),0,1)
                local v=math.floor(mn+(mx-mn)*rel+0.5)
                fl.Size=UDim2.new(rel,0,1,0); kn.Position=UDim2.new(rel,-7,0.5,-7); vt.Text=tostring(v); Config[key]=v
                if cb then cb(v) end
            end
            Connect(h.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=true; Up(i.Position.X) end end)
            Connect(UserInputService.InputChanged,function(i) if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then Up(i.Position.X) end end)
            Connect(UserInputService.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end end)
        end

        function UI.DP(parent,label,opts,key,cb)
            local r=Instance.new("Frame",parent); r.Size=UDim2.new(1,-10,0,44); r.BackgroundColor3=C.Card; r.BackgroundTransparency=0.15; r.ClipsDescendants=true; r.ZIndex=6; Utils.Corner(r,8)
            local l=Instance.new("TextLabel",r); l.Size=UDim2.new(1,-116,0,18); l.Position=UDim2.new(0,12,0,13); l.BackgroundTransparency=1; l.Text=label; l.TextColor3=C.Text; l.Font=Enum.Font.GothamBold; l.TextSize=11; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=7
            local cur=Config[key] or opts[1]
            local btn=Instance.new("TextButton",r); btn.Size=UDim2.new(0,96,0,26); btn.Position=UDim2.new(1,-104,0.5,-13); btn.BackgroundColor3=C.Accent; btn.BackgroundTransparency=0.85; btn.Text=cur.." ▾"; btn.TextColor3=C.AccentLight; btn.Font=Enum.Font.GothamBold; btn.TextSize=10; btn.ZIndex=20; Utils.Corner(btn,6)
            local btns = Instance.new("UIStroke", btn); btns.Color = C.Accent; btns.Thickness = 1; btns.Transparency = 0.5
            local op=false
            local li=Instance.new("Frame",r); li.Size=UDim2.new(1,-16,0,0); li.Position=UDim2.new(0,8,0,44); li.BackgroundColor3=C.Panel; li.ClipsDescendants=true; li.ZIndex=25; Utils.Corner(li,6)
            local la=Instance.new("UIListLayout",li); la.Padding=UDim.new(0,2)
            for _,o in ipairs(opts) do
                local ob=Instance.new("TextButton",li); ob.Size=UDim2.new(1,-6,0,26); ob.BackgroundTransparency=1; ob.Text=o; ob.TextColor3=C.TextDim; ob.Font=Enum.Font.Gotham; ob.TextSize=10; ob.ZIndex=26; Utils.Corner(ob,4)
                Connect(ob.MouseButton1Click,function() btn.Text=o.." ▾"; op=false; Config[key]=o; Utils.Tween(li,0.2,{Size=UDim2.new(1,-16,0,0)}); Utils.Tween(r,0.2,{Size=UDim2.new(1,-10,0,44)}); if cb then cb(o) end end)
                Connect(ob.MouseEnter, function() TweenService:Create(ob, TweenInfo.new(0.1), {BackgroundTransparency=0.85, BackgroundColor3=C.Accent, TextColor3=C.Text}):Play() end)
                Connect(ob.MouseLeave, function() TweenService:Create(ob, TweenInfo.new(0.1), {BackgroundTransparency=1, TextColor3=C.TextDim}):Play() end)
            end
            Connect(btn.MouseButton1Click,function() 
                op=not op
                if op then Utils.Tween(li,0.25,{Size=UDim2.new(1,-16,0,#opts*28+6)}); Utils.Tween(r,0.25,{Size=UDim2.new(1,-10,0,44+#opts*28+6)}) 
                else Utils.Tween(li,0.25,{Size=UDim2.new(1,-16,0,0)}); Utils.Tween(r,0.25,{Size=UDim2.new(1,-10,0,44)}) end 
            end)
        end

        function UI.BTN(parent, label, color, cb)
            local b=Instance.new("TextButton",parent); b.Size=UDim2.new(1,-10,0,38); b.BackgroundColor3=color or C.Accent; b.Text=label; b.TextColor3=C.Text; b.Font=Enum.Font.GothamBold; b.TextSize=11; b.ZIndex=6; Utils.Corner(b,8)
            local bs = Instance.new("UIStroke", b); bs.Color = Color3.new(1,1,1); bs.Thickness = 1; bs.Transparency = 0.85
            Connect(b.MouseButton1Click, cb)
            Connect(b.MouseEnter, function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency=0.15}):Play() end)
            Connect(b.MouseLeave, function() TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency=0}):Play() end)
            return b
        end

        local TABS = {
            { icon="🎯", title=T("aim_title"), sub=T("aim_sub") },
            { icon="👁", title=T("esp_title"), sub=T("esp_sub") },
            { icon="⚡", title=T("fps_title"), sub=T("fps_sub") },
            { icon="✨", title=T("vis_title"), sub=T("vis_sub") },
            { icon="⊕", title=T("mira_title"), sub=T("mira_sub") },
            { icon="🤖", title=T("ia_title"), sub=T("ia_sub") },
            { icon="🚪", title=T("bypass_title"), sub=T("bypass_sub") },
            { icon="🧠", title=T("smart_title"), sub=T("smart_sub") },
            { icon="💾", title=T("save_title"), sub=T("save_sub") },
            { icon="⚙", title=T("config_title"), sub=T("config_sub") }
        }

        local PG={}
        for i=1,#TABS do
            local p=Instance.new("ScrollingFrame",CT); p.Size=UDim2.new(1,-30,1,-62); p.Position=UDim2.new(0,15,0,54)
            p.BackgroundTransparency=1; p.ScrollBarThickness=3; p.ScrollBarImageColor3=C.Accent; p.BorderSizePixel=0; p.Visible=false; p.ZIndex=6; PG[i]=p
            local la=Instance.new("UIListLayout",p); la.Padding=UDim.new(0,6)
            Connect(la:GetPropertyChangedSignal("AbsoluteContentSize"),function() p.CanvasSize=UDim2.new(0,0,0,la.AbsoluteContentSize.Y+16) end)
        end

        UI.Section(PG[1], T("section_general"))
        UI.TG(PG[1],T("aim_assist"),T("aim_assist_desc"),"AimAssist")
        UI.TG(PG[1],T("aim_legit"),"Mira suave com humanização","LegitAim")
        UI.TG(PG[1],T("aim_camera_lock"),"Trava câmera no alvo","CameraLock")
        UI.Section(PG[1], T("section_target"))
        UI.SL(PG[1],T("aim_fov"),30,400,"FOV")
        UI.SL(PG[1],T("aim_smoothness"),0,100,"Smoothness")
        UI.DP(PG[1],T("aim_color"),{"RGB","Roxo","Vermelho","Verde","Azul"},"FOVColorMode")
        UI.TG(PG[1],T("aim_show_circle"),"Exibe o raio do FOV","FOVCircle")
        UI.Section(PG[1], "Filtros")
        UI.TG(PG[1],T("aim_team"),T("aim_team_desc"),"TeamCheck")
        UI.TG(PG[1],T("aim_los"),T("aim_los_desc"),"LOSCheck")
        UI.TG(PG[1],T("aim_predict"),"Prever movimento","AutoPredict")

        UI.Section(PG[2], "Master")
        UI.TG(PG[2],T("esp_master"),T("esp_master_desc"),"ESP")
        UI.TG(PG[2],T("esp_highlight"),"Brilho no corpo","ESP_Highlight")
        UI.TG(PG[2],T("esp_box"),"Caixa delimitadora","ESP_Box")
        UI.Section(PG[2], "Info")
        UI.TG(PG[2],T("esp_name"),"Nome do jogador","ESP_Name")
        UI.TG(PG[2],T("esp_dist"),"Distância até o alvo","ESP_Dist")
        UI.SL(PG[2],T("esp_transparency"),0,100,"ESP_Transparency")

        UI.Section(PG[3], T("section_perf"))
        UI.DP(PG[3],T("fps_preset"),{"Low","Medium","High","Extreme"},"FPSPreset", function(v) SmartBoost:Mode_(v) end)
        UI.TG(PG[3],T("fps_monitor"),T("fps_monitor_desc"),"FPSMonitor", function(v) FH.Visible=v end)
        UI.TG(PG[3],T("fps_potato"),T("fps_potato_desc"),"PotatoColorful", function(v) 
            if v then SmartBoost:Mode_("EXTREME"); local t=Workspace:FindFirstChildOfClass("Terrain"); if t then t.Decoration=false end; local cc=Lighting:FindFirstChild("VoidSat"); if not cc then cc=Instance.new("ColorCorrectionEffect"); cc.Name="VoidSat"; cc.Parent=Lighting end; cc.Saturation=2.5; cc.Enabled=true else SmartBoost:Restore() end 
        end)
        UI.Section(PG[3], "Ajustes")
        UI.SL(PG[3],T("fps_stretch"),40,120,"StretchFOV", function(v) Camera.FieldOfView=v end)
        UI.SL(PG[3],T("fps_render"),100,3000,"RenderDistance", function(v) if v>=3000 then Lighting.FogStart=0; Lighting.FogEnd=100000 else Lighting.FogStart=v*0.8; Lighting.FogEnd=v end end)
        UI.SL(PG[3],T("fps_sat"),0,300,"Saturation", function(v) local cc=Lighting:FindFirstChild("VoidSat") if not cc then cc=Instance.new("ColorCorrectionEffect"); cc.Name="VoidSat"; cc.Parent=Lighting end cc.Saturation=v/100; cc.Enabled=true end)

        UI.Section(PG[4], "Iluminação")
        UI.TG(PG[4],T("vis_fullbright"),T("vis_fullbright_desc"),"Fullbright", function(v) Lighting.Brightness=v and 3 or 1 end)
        UI.TG(PG[4],T("vis_fog"),T("vis_fog_desc"),"RemoveFog", function(v) Lighting.FogEnd=v and 100000 or 1000 end)

        UI.Section(PG[5], "Crosshair")
        UI.TG(PG[5],T("mira_crosshair"),"Ativa mira customizada","Crosshair")
        UI.DP(PG[5],T("mira_style"),{"+","•","⨁","🎯","✛"},"CH_Style")
        UI.SL(PG[5],T("mira_size"),10,100,"CH_Size")

        local CS=Instance.new("ScrollingFrame",PG[6]); CS.Size=UDim2.new(1,-10,0,190); CS.BackgroundColor3=C.Panel; CS.BackgroundTransparency=0.3; CS.ScrollBarThickness=3; CS.ScrollBarImageColor3=C.Accent; CS.BorderSizePixel=0; Utils.Corner(CS,8); CS.ZIndex=6
        local CL=Instance.new("UIListLayout",CS); CL.Padding=UDim.new(0,4); Connect(CL:GetPropertyChangedSignal("AbsoluteContentSize"),function() CS.CanvasSize=UDim2.new(0,0,0,CL.AbsoluteContentSize.Y+8) end)
        local function AM(text, isUser)
            local m=Instance.new("Frame",CS); m.Size=UDim2.new(isUser and 0.75 or 0.85,-8,0,0); m.Position=UDim2.new(isUser and 0.25 or 0,0,0,0); m.BackgroundColor3=isUser and C.Accent or C.Card; m.BackgroundTransparency=isUser and 0.3 or 0.2; m.AutomaticSize=Enum.AutomaticSize.Y; Utils.Corner(m,8); m.ZIndex=7
            local ml=Instance.new("TextLabel",m); ml.Size=UDim2.new(1,-12,0,0); ml.Position=UDim2.new(0,6,0,5); ml.BackgroundTransparency=1; ml.Text=text; ml.TextColor3=C.Text; ml.Font=Enum.Font.Gotham; ml.TextSize=10; ml.TextWrapped=true; ml.TextXAlignment=Enum.TextXAlignment.Left; ml.AutomaticSize=Enum.AutomaticSize.Y; ml.ZIndex=8
            task.defer(function() CS.CanvasPosition=Vector2.new(0,CS.CanvasSize.Y.Offset) end)
        end
        task.delay(0.5,function() AM("🤖 Olá! Sou a Assistente IA do VOID HUB.",false); AM("Pergunte sobre Aimbot, FPS, ESP ou Config.",false) end)
        local IB=Instance.new("TextBox",PG[6]); IB.Size=UDim2.new(1,-68,0,34); IB.BackgroundColor3=C.Card; IB.BackgroundTransparency=0.2; IB.PlaceholderText=T("ia_input"); IB.Text=""; IB.TextColor3=C.Text; IB.PlaceholderColor3=C.TextDim; IB.Font=Enum.Font.Gotham; IB.TextSize=10; Utils.Corner(IB,8); IB.Position=UDim2.new(0,0,0,198); IB.ZIndex=6
        local IBStroke = Instance.new("UIStroke", IB); IBStroke.Color = C.Accent; IBStroke.Thickness = 1; IBStroke.Transparency = 0.7
        local SNB=Instance.new("TextButton",PG[6]); SNB.Size=UDim2.new(0,60,0,34); SNB.BackgroundColor3=C.Accent; SNB.Text=T("ia_send"); SNB.TextColor3=C.Text; SNB.Font=Enum.Font.GothamBold; SNB.TextSize=10; Utils.Corner(SNB,8); SNB.Position=UDim2.new(1,-64,0,198); SNB.ZIndex=10
        Connect(SNB.MouseButton1Click,function() local q=IB.Text; if q=="" then return end; AM(q,true); IB.Text=""; task.wait(0.3); AM(GetAIResponse(q),false) end)

        UI.BTN(PG[7], T("bypass_hide"), C.Accent, Min)
        local KillB = UI.BTN(PG[7], T("bypass_kill"), C.Danger, nil)
        local confirmKill=false
        Connect(KillB.MouseButton1Click,function()
            if not confirmKill then
                confirmKill=true; KillB.Text="⚠ CONFIRMAR? CLIQUE DE NOVO"
                task.delay(3,function() if KillB and KillB.Parent then confirmKill=false; KillB.Text=T("bypass_kill") end end)
                return
            end
            for _,c in ipairs(ActiveConnections) do if c.Connected then c:Disconnect() end end
            ActiveConnections={}; if SG then SG:Destroy() end
        end)

        UI.Section(PG[8], "Inteligência")
        UI.TG(PG[8],T("smart_aim"),T("smart_aim_desc"),"SmartAim", function(v) SmartAim.Enabled=v end)
        UI.TG(PG[8],T("smart_boost"),T("smart_boost_desc"),"SmartBoost", function(v) SmartBoost.Enabled=v end)

        UI.BTN(PG[9], T("save_save"), C.Accent, function()
            local ok=SaveSystem:Save()
            Toast(ok and T("save_saved") or T("save_error"), "Configurações salvas", ok and "success" or "error")
        end)
        UI.BTN(PG[9], T("save_load"), C.AccentDim, function()
            local ok=SaveSystem:Load()
            Toast(ok and T("save_loaded") or T("save_error"), "Configurações carregadas", ok and "success" or "error")
        end)

        local VL=Instance.new("Frame",PG[10]); VL.Size=UDim2.new(1,-10,0,44); VL.BackgroundColor3=C.Card; VL.BackgroundTransparency=0.15; VL.ZIndex=6; Utils.Corner(VL,8)
        local VLL=Instance.new("TextLabel",VL); VLL.Size=UDim2.new(0.5,-12,1,0); VLL.Position=UDim2.new(0,12,0,0); VLL.BackgroundTransparency=1; VLL.Text=T("config_version"); VLL.TextColor3=C.Text; VLL.Font=Enum.Font.GothamBold; VLL.TextSize=11; VLL.TextXAlignment=Enum.TextXAlignment.Left; VLL.ZIndex=7
        local VLV=Instance.new("TextLabel",VL); VLV.Size=UDim2.new(0.5,-12,1,0); VLV.Position=UDim2.new(0.5,0,0,0); VLV.BackgroundTransparency=1; VLV.Text="VOID HUB 7.0"; VLV.TextColor3=C.AccentLight; VLV.Font=Enum.Font.GothamBold; VLV.TextSize=11; VLV.TextXAlignment=Enum.TextXAlignment.Right; VLV.ZIndex=7
        UI.DP(PG[10],T("config_language"),{"Português (BR)","English","Español","Français","Deutsch"},"Language", function(v)
            local map={["Português (BR)"]="pt-br",["English"]="en",["Español"]="es",["Français"]="fr",["Deutsch"]="de"}
            Language=map[v] or "pt-br"; Config.Language=Language
            task.wait(0.1); CleanupAll(); SG:Destroy(); BuildUI()
        end)
        local AL=Instance.new("Frame",PG[10]); AL.Size=UDim2.new(1,-10,0,0); AL.BackgroundColor3=C.Card; AL.BackgroundTransparency=0.15; AL.AutomaticSize=Enum.AutomaticSize.Y; AL.ZIndex=6; Utils.Corner(AL,8)
        local ALT=Instance.new("TextLabel",AL); ALT.Size=UDim2.new(1,-20,0,0); ALT.Position=UDim2.new(0,10,0,10); ALT.BackgroundTransparency=1; ALT.Text=T("config_about_text"); ALT.TextColor3=C.TextDim; ALT.Font=Enum.Font.Gotham; ALT.TextSize=10; ALT.TextWrapped=true; ALT.TextXAlignment=Enum.TextXAlignment.Left; ALT.TextYAlignment=Enum.TextYAlignment.Top; ALT.AutomaticSize=Enum.AutomaticSize.Y; ALT.ZIndex=7

        local TB={}
        local function SwitchTab(index)
            Config.ActiveTab=index
            PT.Text = TABS[index].title
            PTSub.Text = TABS[index].sub
            for i,p in pairs(PG) do p.Visible=(i==index) end
            PG[index].Position=UDim2.new(0,15,0,64); Utils.Tween(PG[index],0.25,{Position=UDim2.new(0,15,0,54)})
            for i,b in pairs(TB) do
                local a=(i==index)
                TweenService:Create(b.f, TweenInfo.new(0.2), {BackgroundColor3=a and C.Card or C.Panel, BackgroundTransparency=a and 0 or 1}):Play()
                TweenService:Create(b.l, TweenInfo.new(0.2), {TextColor3=a and C.Text or C.TextDim}):Play()
                TweenService:Create(b.ic, TweenInfo.new(0.2), {TextColor3=a and C.AccentLight or C.TextDim}):Play()
                TweenService:Create(b.i, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Size=UDim2.new(0,3,0,a and 20 or 0)}):Play()
            end
        end

        for i, tab in ipairs(TABS) do
            local f=Instance.new("TextButton",SB_); f.Size=UDim2.new(1,-16,0,36); f.Position=UDim2.new(0,8,0,6+(i-1)*38); f.BackgroundColor3=C.Panel; f.BackgroundTransparency=1; f.Text=""; f.ZIndex=10; Utils.Corner(f,7)
            f.LayoutOrder = i
            local ind=Instance.new("Frame",f); ind.Size=UDim2.new(0,3,0,0); ind.Position=UDim2.new(0,0,0.5,0); ind.AnchorPoint=Vector2.new(0,0.5); ind.BackgroundColor3=C.Accent; ind.ZIndex=11; Utils.Corner(ind,2)
            local ic=Instance.new("TextLabel",f); ic.Size=UDim2.new(0,22,1,0); ic.Position=UDim2.new(0,12,0,0); ic.BackgroundTransparency=1; ic.Text=tab.icon; ic.TextColor3=C.TextDim; ic.Font=Enum.Font.GothamBold; ic.TextSize=12; ic.TextXAlignment=Enum.TextXAlignment.Left; ic.ZIndex=11
            local l=Instance.new("TextLabel",f); l.Size=UDim2.new(1,-42,1,0); l.Position=UDim2.new(0,38,0,0); l.BackgroundTransparency=1; l.Text=tab.title; l.TextColor3=C.TextDim; l.Font=Enum.Font.GothamBold; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=11
            TB[i]={f=f,l=l,i=ind,ic=ic}
            Connect(f.MouseButton1Click,function() SwitchTab(i) end)
            Connect(f.MouseEnter, function() if Config.ActiveTab~=i then TweenService:Create(f, TweenInfo.new(0.15), {BackgroundColor3=C.Card, BackgroundTransparency=0.7}):Play(); TweenService:Create(l, TweenInfo.new(0.15), {TextColor3=C.Text}):Play() end end)
            Connect(f.MouseLeave, function() if Config.ActiveTab~=i then TweenService:Create(f, TweenInfo.new(0.15), {BackgroundTransparency=1}):Play(); TweenService:Create(l, TweenInfo.new(0.15), {TextColor3=C.TextDim}):Play() end end)
        end

        local function MD(fr,h) 
            local d,ds,sp
            Connect(h.InputBegan,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true; ds=i.Position; sp=fr.Position end end)
            Connect(UserInputService.InputChanged,function(i) if d and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local dl=i.Position-ds; fr.Position=UDim2.new(sp.X.Scale,sp.X.Offset+dl.X,sp.Y.Scale,sp.Y.Offset+dl.Y) end end)
            Connect(UserInputService.InputEnded,function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end end) 
        end
        MD(MN,HD); MD(FB,FB); MD(FH,FH)

        local RN={Cache={}}; local jT=0; local eA=0
        
        function RN:Clear() for p,d in pairs(self.Cache) do if d.bb then d.bb:Destroy() end; if d.h then d.h:Destroy() end; self.Cache[p]=nil end end
        
        function RN:UpdateESP() 
            if not Config.ESP then self:Clear(); return end
            for _,p in ipairs(Players:GetPlayers()) do 
                if p~=LocalPlayer and p.Character then 
                    local ch=p.Character; local h=ch:FindFirstChildOfClass("Humanoid"); local r=ch:FindFirstChild("HumanoidRootPart")
                    if h and h.Health>0 and r then 
                        if not self.Cache[p] then 
                            local hd=ch:FindFirstChild("Head") or r
                            local bb=Instance.new("BillboardGui",hd); bb.Size=UDim2.new(0,200,0,200); bb.AlwaysOnTop=true
                            local nm=Instance.new("TextLabel",bb); nm.Size=UDim2.new(1,0,0,20); nm.Position=UDim2.new(0,0,0,-30); nm.BackgroundTransparency=1; nm.Font=Enum.Font.GothamBold; nm.TextSize=12; nm.TextStrokeTransparency=0.5
                            local ds=Instance.new("TextLabel",bb); ds.Size=UDim2.new(1,0,0,15); ds.Position=UDim2.new(0,0,0,-15); ds.BackgroundTransparency=1; ds.TextColor3=Color3.new(1,1,1); ds.Font=Enum.Font.Gotham; ds.TextSize=11; ds.TextStrokeTransparency=0.5
                            local hg=Instance.new("Highlight",ch); hg.FillTransparency=1; hg.OutlineTransparency=1
                            self.Cache[p]={bb=bb,n=nm,d=ds,h=hg}
                        end
                        local d=self.Cache[p]
                        d.n.Text=p.Name; d.n.TextColor3=Config.ESP_Color; d.n.Visible=Config.ESP_Name
                        d.d.Text=string.format("[%d m]",math.floor((Camera.CFrame.Position-r.Position).Magnitude)); d.d.Visible=Config.ESP_Dist
                        d.h.OutlineColor=Config.ESP_Color; d.h.FillColor=Config.ESP_Color; d.h.FillTransparency=Config.ESP_Transparency; d.h.Enabled=Config.ESP_Highlight
                    else 
                        if self.Cache[p] then self.Cache[p].bb:Destroy(); self.Cache[p].h:Destroy(); self.Cache[p]=nil end
                    end 
                end 
            end 
        end

        Connect(RunService.RenderStepped,function(dt)
            if Config.AimAssist then 
                local cen=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
                local bt,bs,bd=nil,9999,0
                for _,p in ipairs(Players:GetPlayers()) do 
                    if p~=LocalPlayer and p.Character then 
                        local ch=p.Character; local h=ch:FindFirstChildOfClass("Humanoid"); local tp=ch:FindFirstChild(Config.TargetPart) or ch:FindFirstChild("Head")
                        if h and h.Health>0 and tp then 
                            local it=Config.TeamCheck and p.Team and LocalPlayer.Team and p.Team==LocalPlayer.Team
                            if not it then 
                                local sp,on=Camera:WorldToViewportPoint(tp.Position)
                                if on then 
                                    local d2=(Vector2.new(sp.X,sp.Y)-cen).Magnitude; local d3=(Camera.CFrame.Position-tp.Position).Magnitude
                                    local sc=(Config.Priority==2) and d3 or d2
                                    if d2<=Config.FOV and sc<bs then 
                                        local iv=true
                                        if Config.LOSCheck then 
                                            local ray=RaycastParams.new(); ray.FilterDescendantsInstances={LocalPlayer.Character,Camera}; ray.FilterType=Enum.RaycastFilterType.Exclude
                                            local hit=Workspace:Raycast(Camera.CFrame.Position,tp.Position-Camera.CFrame.Position,ray); iv=(hit and hit.Instance:IsDescendantOf(ch)) or not hit 
                                        end
                                        if iv then bs=sc; bt=tp; bd=d3 end 
                                    end 
                                end 
                            end 
                        end 
                    end 
                end
                if bt then 
                    local tpp=bt.Position
                    if Config.AutoPredict and bt.Parent:FindFirstChild("HumanoidRootPart") then tpp=tpp+bt.Parent.HumanoidRootPart.AssemblyLinearVelocity*0.05 end
                    if Config.CameraLock then Camera.CFrame=CFrame.new(Camera.CFrame.Position,tpp)
                    else 
                        local bsm
                        if Config.LegitAim then 
                            local ss=math.clamp(Config.Smoothness,1,100); bsm=(1-(ss/100))*0.85; bsm=math.max(bsm,0.08)
                            if Config.DistSmooth then bsm=bsm*(1-math.clamp(bd/500,0,0.8)) end
                            if Config.Humanize>0 then jT=jT+dt; tpp=tpp+Vector3.new(math.noise(jT*2,0)*(Config.Humanize*0.2),math.noise(0,jT*2)*(Config.Humanize*0.2),0) end 
                        else bsm=math.clamp(1-(Config.Smoothness/100),0.05,0.95) end
                        local fs=SmartAim:GetSmoothFactor(dt,bsm); Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,tpp),fs) 
                    end 
                end 
            end
            eA=eA+dt; if eA>=1/30 then RN:UpdateESP(); eA=0 end
        end)

        task.spawn(function() 
            while FH and FH.Parent do 
                local t1=tick(); RunService.RenderStepped:Wait(); local dt=tick()-t1; local fps=math.floor(1/math.max(dt,0.001))
                local ev="HORRÍVEL"; local cl=C.Danger; local pct = math.clamp(fps/120,0,1)
                if fps>=60 then ev="ULTRA"; cl=C.Success
                elseif fps>=40 then ev="BOM"; cl=Color3.fromRGB(180,255,80)
                elseif fps>=20 then ev="MÉDIO"; cl=C.Warning end
                if FH and FH.Parent then 
                    FHLabel.Text=string.format("FPS: %d",fps)
                    FHLabel.TextColor3=cl
                    FHStatus.Text=ev
                    FHBarFill.Size=UDim2.new(pct,0,1,0)
                    FHBarFill.BackgroundColor3=cl
                    FHStroke.Color=cl
                end 
            end 
        end)

        Connect(BC.MouseButton1Click, Min)
        
        SwitchTab(Config.ActiveTab or 1)
        MN.Visible=true
        TweenService:Create(MN,TweenInfo.new(0.6,Enum.EasingStyle.Quint),{Size=UDim2.new(0,480,0,360)}):Play()
        TweenService:Create(BD,TweenInfo.new(0.4),{BackgroundTransparency=0.35}):Play()
    end)
    
    if success then print("[VOID HUB] Interface premium compacta carregada.") 
    else warn("[VOID HUB] ERRO UI: "..tostring(err)) end
end

PlayIntro(function() BuildUI() end)
