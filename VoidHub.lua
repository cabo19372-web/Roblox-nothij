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
        aim_title="Aimbot", aim_sub="Configuração de mira assistida",
        esp_title="ESP", esp_sub="Visualização de jogadores",
        fps_title="Desempenho", fps_sub="Otimização e FPS",
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
        aim_smoothness="Smoothness", aim_predict="Auto-Predict",
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
        bypass_hide="ESCONDER MENU", bypass_kill="ENCERRAR SCRIPT",
        smart_aim="Smart Aim 2.0", smart_aim_desc="Adapta suavidade ao FPS",
        smart_boost="Smart Boost", smart_boost_desc="Otimização adaptativa",
        save_save="SALVAR", save_load="CARREGAR", save_saved="Salvo!", save_loaded="Carregado!", save_error="Erro",
        config_version="Versão", config_language="Idioma",
        config_about_text="VOID HUB é um script de automação e otimização para Roblox.\n\n• Aimbot inteligente com Smart Aim\n• ESP completo com highlights\n• Otimização de FPS avançada\n• Assistente IA integrada",
        section_general="Geral", section_target="Alvo", section_visual="Visual", section_perf="Desempenho"
    }
}
local function T(key) return Translations[Language][key] or key end

-- ==========================================
-- CONFIG + PALETA PREMIUM
-- ==========================================
local Config = {
    Colors = { 
        BG = Color3.fromRGB(6, 4, 12),
        Panel = Color3.fromRGB(12, 8, 20),
        Card = Color3.fromRGB(20, 15, 32),
        CardHover = Color3.fromRGB(28, 22, 44),
        Accent = Color3.fromRGB(157, 78, 221),
        AccentLight = Color3.fromRGB(200, 140, 255),
        AccentDim = Color3.fromRGB(100, 45, 165),
        Text = Color3.fromRGB(245, 240, 255),
        TextDim = Color3.fromRGB(130, 120, 155),
        Danger = Color3.fromRGB(255, 60, 90),
        Success = Color3.fromRGB(80, 255, 140),
        Warning = Color3.fromRGB(255, 200, 80),
        ToggleOff = Color3.fromRGB(38, 32, 52)
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
    if q:find("oi") or q:find("ola") or q:find("olá") or q:find("hello") then return "Olá! Sou o assistente do VOID HUB. Como posso ajudar?" end
    if q:find("aimbot") or q:find("mira") or q:find("acertar") then return "Config ideal: Aba Aimbot > Ative Aim Assist > FOV 150-200 > Smoothness 50 > Legit ON." end
    if q:find("fps") or q:find("lag") or q:find("trava") then return "Ative Gráfico Batata, Render 300-500, Smart Boost ON." end
    if q:find("esp") or q:find("ver") or q:find("inimigo") then return "Aba ESP > Master ESP > Highlight > Distance." end
    if q:find("config") or q:find("melhor") or q:find("ideal") then return "FOV 180, Smoothness 45, Legit ON, Gráfico Batata ON." end
    return "Não entendi. Tente: Aimbot, FPS, ESP, Config."
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
-- INTRO LIMPA
-- ==========================================
local function PlayIntro(onComplete)
    print("[VOID HUB] Iniciando intro.")
    for _, v in ipairs(PlayerGui:GetChildren()) do if v.Name == "VoidIntro" then v:Destroy() end end
    local completed = false
    local function Complete()
        if completed then return end
        completed = true
        if onComplete then pcall(onComplete) end
    end
    local ok, err = pcall(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "VoidIntro"; gui.IgnoreGuiInset = true; gui.ResetOnSpawn = false
        gui.DisplayOrder = 999; gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = PlayerGui
        local function mkFrame(props) local f = Instance.new("Frame"); f.BorderSizePixel = 0; for k, v in pairs(props) do f[k] = v end; f.Parent = gui; return f end
        local function mkLabel(props) local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.BorderSizePixel = 0; for k, v in pairs(props) do t[k] = v end; t.Parent = gui; return t end
        local function tw(obj, t, props, style, dir) if not obj or not obj.Parent then return end; TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play() end
        local Bg = mkFrame({Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(2,0,8), ZIndex=1})
        local Radial = mkFrame({Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(25,5,55), BackgroundTransparency=1, ZIndex=2})
        local RG = Instance.new("UIGradient", Radial)
        RG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(140,30,255)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(60,15,130)), ColorSequenceKeypoint.new(0.7, Color3.fromRGB(25,5,60)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))})
        local StarsLayer = mkFrame({Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, ZIndex=3})
        local stars = {}
        for i = 1, 60 do
            local s = Instance.new("Frame", StarsLayer); local sz = math.random(1, 3)
            s.Size = UDim2.new(0, sz, 0, sz); s.Position = UDim2.new(math.random(), 0, math.random(), 0)
            s.BackgroundColor3 = Color3.fromRGB(200, 180, 255); s.BackgroundTransparency = 1; s.BorderSizePixel = 0; s.ZIndex = 3
            local c = Instance.new("UICorner", s); c.CornerRadius = UDim.new(1,0); stars[i] = s
        end
        local TC = mkFrame({Size=UDim2.new(1,0,0,180), Position=UDim2.new(0,0,0.5,-140), BackgroundTransparency=1, ZIndex=10})
        local function makeTitle(color, zi) local t = Instance.new("TextLabel", TC); t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1; t.Text = "VOID HUB"; t.TextColor3 = color; t.Font = Enum.Font.GothamBlack; t.TextSize = 140; t.TextTransparency = 1; t.ZIndex = zi; return t end
        local TR = makeTitle(Color3.fromRGB(255, 60, 120), 9)
        local TB = makeTitle(Color3.fromRGB(60, 140, 255), 9)
        local T = makeTitle(Color3.fromRGB(245, 220, 255), 10)
        local TG = Instance.new("UIGradient", T); TG.Color = ColorSequence.new(Color3.fromRGB(255,230,255), Color3.fromRGB(160,80,240)); TG.Rotation = 45
        local TStroke = Instance.new("UIStroke", T); TStroke.Color = Color3.fromRGB(168, 92, 255); TStroke.Thickness = 3; TStroke.Transparency = 1; TStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        local Sub = mkLabel({Size=UDim2.new(1,0,0,30), Position=UDim2.new(0,0,0.5,60), Text="", TextColor3=Color3.fromRGB(220,190,255), Font=Enum.Font.GothamBold, TextSize=18, TextTransparency=1, ZIndex=10})
        local Ver = mkLabel({Size=UDim2.new(1,0,0,20), Position=UDim2.new(0,0,0.5,140), Text="v 7.0", TextColor3=Color3.fromRGB(180,120,240), Font=Enum.Font.GothamBold, TextSize=14, TextTransparency=1, ZIndex=10})
        local PB = mkFrame({Size=UDim2.new(0,320,0,4), Position=UDim2.new(0.5,-160,0.5,200), BackgroundColor3=Color3.fromRGB(40,30,60), BackgroundTransparency=1, ZIndex=10})
        local PBC = Instance.new("UICorner", PB); PBC.CornerRadius = UDim.new(1,0)
        local PF = Instance.new("Frame", PB); PF.Size = UDim2.new(0,0,1,0); PF.BackgroundColor3 = Color3.fromRGB(168, 92, 255); PF.BorderSizePixel = 0; PF.ZIndex = 11
        local PFC = Instance.new("UICorner", PF); PFC.CornerRadius = UDim.new(1,0)
        local PFG = Instance.new("UIGradient", PF); PFG.Color = ColorSequence.new(Color3.fromRGB(140,60,220), Color3.fromRGB(255,200,255))
        local PT = mkLabel({Size=UDim2.new(1,0,0,18), Position=UDim2.new(0,0,0.5,212), Text="", TextColor3=Color3.fromRGB(160,110,220), Font=Enum.Font.GothamBold, TextSize=11, TextTransparency=1, ZIndex=10})
        local Flash = mkFrame({Size=UDim2.new(1,0,1,0), BackgroundColor3=Color3.fromRGB(240,220,255), BackgroundTransparency=1, ZIndex=50})
        local Skip = Instance.new("TextButton", gui); Skip.Size = UDim2.new(0,90,0,26); Skip.Position = UDim2.new(1,-110,1,-42)
        Skip.BackgroundColor3 = Color3.fromRGB(30,20,50); Skip.BackgroundTransparency = 0.4; Skip.Text = "SKIP ▶▶"; Skip.TextColor3 = Color3.fromRGB(180,150,220)
        Skip.Font = Enum.Font.GothamBold; Skip.TextSize = 11; Skip.ZIndex = 100
        local SC = Instance.new("UICorner", Skip); SC.CornerRadius = UDim.new(0,6)
        local skipReq = false
        Skip.MouseButton1Click:Connect(function() skipReq = true end)
        task.spawn(function()
            local function alive() return gui and gui.Parent and not skipReq end
            task.wait(0.4)
            for i, s in ipairs(stars) do task.spawn(function() task.wait(i * 0.008); if s.Parent then tw(s, 0.6, {BackgroundTransparency = math.random(30, 70)/100}) end end) end
            task.wait(0.3); if not alive() then if gui and gui.Parent then gui:Destroy() end; Complete(); return end
            tw(Radial, 1.0, {BackgroundTransparency = 0})
            task.wait(0.8); if not alive() then if gui and gui.Parent then gui:Destroy() end; Complete(); return end
            tw(T, 0.8, {TextTransparency = 0}, Enum.EasingStyle.Back); tw(TStroke, 0.8, {Transparency = 0.2})
            task.wait(0.2); if not alive() then if gui and gui.Parent then gui:Destroy() end; Complete(); return end
            TR.Position = UDim2.new(0, -8, 0, 0); TB.Position = UDim2.new(0, 8, 0, 0)
            tw(TR, 0.3, {TextTransparency = 0.5}); tw(TB, 0.3, {TextTransparency = 0.5})
            task.wait(0.2); tw(TR, 0.4, {Position = UDim2.new(0,0,0,0), TextTransparency = 1}); tw(TB, 0.4, {Position = UDim2.new(0,0,0,0), TextTransparency = 1})
            task.wait(0.5); if not alive() then if gui and gui.Parent then gui:Destroy() end; Complete(); return end
            tw(Ver, 0.4, {TextTransparency = 0})
            task.wait(0.2); if not alive() then if gui and gui.Parent then gui:Destroy() end; Complete(); return end
            Sub.TextTransparency = 0; local tag = "AIMBOT  •  DESEMPENHO  •  IA"
            for i = 1, #tag do if skipReq then break end; Sub.Text = string.sub(tag, 1, i); task.wait(0.025) end
            task.wait(0.2); if not alive() then if gui and gui.Parent then gui:Destroy() end; Complete(); return end
            tw(PB, 0.3, {BackgroundTransparency = 0.2}); PT.TextTransparency = 0
            local stages = {"INICIALIZANDO...", "CARREGANDO MÓDULOS...", "ATIVANDO AIMBOT...", "OTIMIZANDO FPS...", "CONECTANDO IA...", "PRONTO."}
            for i, s in ipairs(stages) do if skipReq then break end; PT.Text = s; tw(PF, 0.25, {Size = UDim2.new(i / #stages, 0, 1, 0)}); task.wait(0.25) end
            task.wait(0.2); Flash.BackgroundTransparency = 0.4; tw(Flash, 0.2, {BackgroundTransparency = 1}); task.wait(0.3)
            tw(T, 0.4, {TextTransparency = 1}); tw(TStroke, 0.4, {Transparency = 1}); tw(Sub, 0.3, {TextTransparency = 1}); tw(Ver, 0.3, {TextTransparency = 1})
            tw(PB, 0.3, {BackgroundTransparency = 1}); tw(PF, 0.3, {BackgroundTransparency = 1}); tw(PT, 0.3, {TextTransparency = 1})
            for _, s in ipairs(stars) do if s.Parent then tw(s, 0.3, {BackgroundTransparency = 1}) end end
            task.wait(0.3); Flash.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Flash.BackgroundTransparency = 0
            tw(Flash, 0.15, {BackgroundTransparency = 0.3}); task.wait(0.15); Flash.BackgroundColor3 = Color3.new(0,0,0); tw(Flash, 0.35, {BackgroundTransparency = 0.5})
            task.wait(0.2); tw(Radial, 0.4, {BackgroundTransparency = 1}); tw(Flash, 0.4, {BackgroundTransparency = 1}); tw(Bg, 0.5, {BackgroundTransparency = 1})
            task.wait(0.6)
            if gui and gui.Parent then gui:Destroy() end
            Complete()
        end)
        task.delay(10, function() if gui and gui.Parent then gui:Destroy() end; Complete() end)
    end)
    if not ok then warn("[VOID HUB] Erro intro: " .. tostring(err)); Complete() end
end

-- ==========================================
-- BUILDUI — REDESIGN PROFISSIONAL
-- ==========================================
local function BuildUI()
    print("[VOID HUB] Construindo interface premium.")
    
    for _,v in ipairs(PlayerGui:GetChildren()) do if v.Name=="VoidHub7" then v:Destroy() end end

    local C = Config.Colors
    
    -- Ícones geométricos profissionais (SEM EMOJIS)
    local ICONS = { "◉", "◎", "◆", "✦", "⊕", "▣", "▥", "◈", "▤", "▦" }
    
    local success, err = pcall(function()
        -- ============ SCREEN GUI ============
        local SG = Instance.new("ScreenGui")
        SG.Name = "VoidHub7"
        SG.IgnoreGuiInset = true
        SG.ResetOnSpawn = false
        SG.DisplayOrder = 100
        SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        SG.Parent = PlayerGui
        
        -- ============ BACKDROP ============
        local BD = Instance.new("Frame", SG)
        BD.Size = UDim2.new(1, 0, 1, 0)
        BD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        BD.BackgroundTransparency = 1
        BD.BorderSizePixel = 0
        BD.ZIndex = 1
        
        local BgGlow = Instance.new("Frame", BD)
        BgGlow.Size = UDim2.new(1, 0, 1, 0)
        BgGlow.BackgroundColor3 = Color3.fromRGB(20, 10, 40)
        BgGlow.BackgroundTransparency = 0.85
        BgGlow.BorderSizePixel = 0
        BgGlow.ZIndex = 2
        local BgGlowGrad = Instance.new("UIGradient", BgGlow)
        BgGlowGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 20, 80)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 10, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 20, 80))
        })
        BgGlowGrad.Rotation = 45
        
        -- ============ MAIN WINDOW ============
        local MN = Instance.new("Frame", SG)
        MN.Size = UDim2.new(0, 520, 0, 400)
        MN.Position = UDim2.new(0.5, -260, 0.5, -200)
        MN.BackgroundColor3 = C.BG
        MN.BackgroundTransparency = 0.05
        MN.BorderSizePixel = 0
        MN.ClipsDescendants = true
        MN.Visible = true
        MN.ZIndex = 3
        Utils.Corner(MN, 16)
        
        local MNStroke = Instance.new("UIStroke", MN)
        MNStroke.Color = C.Accent
        MNStroke.Thickness = 1
        MNStroke.Transparency = 0.6
        MNStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        local MNGrad = Instance.new("UIGradient", MN)
        MNGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 10, 24)),
            ColorSequenceKeypoint.new(0.5, C.BG),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 6, 18))
        })
        MNGrad.Rotation = 135
        
        -- UIScale para entrada
        local MNScale = Instance.new("UIScale", MN)
        MNScale.Scale = 0.92
        
        -- ============ HEADER (COMPACTO 52px) ============
        local HD = Instance.new("Frame", MN)
        HD.Size = UDim2.new(1, 0, 0, 52)
        HD.BackgroundTransparency = 1
        HD.ZIndex = 4
        
        -- Logo
        local LogoBox = Instance.new("Frame", HD)
        LogoBox.Size = UDim2.new(0, 30, 0, 30)
        LogoBox.Position = UDim2.new(0, 18, 0.5, -15)
        LogoBox.BackgroundColor3 = C.Accent
        LogoBox.BorderSizePixel = 0
        LogoBox.ZIndex = 4
        Utils.Corner(LogoBox, 8)
        local LogoGrad = Instance.new("UIGradient", LogoBox)
        LogoGrad.Color = ColorSequence.new(C.Accent, C.AccentLight)
        LogoGrad.Rotation = 45
        
        local LogoIcon = Instance.new("ImageLabel", LogoBox)
        LogoIcon.Size = UDim2.new(1, 0, 1, 0)
        LogoIcon.BackgroundTransparency = 1
        LogoIcon.Image = CONFIG_IMAGE_ID
        LogoIcon.ScaleType = Enum.ScaleType.Crop
        LogoIcon.ZIndex = 5
        Utils.Corner(LogoIcon, 8)
        
        -- Title
        local Title = Instance.new("TextLabel", HD)
        Title.Size = UDim2.new(0, 180, 0, 20)
        Title.Position = UDim2.new(0, 58, 0, 10)
        Title.BackgroundTransparency = 1
        Title.Text = "VOID HUB"
        Title.TextColor3 = C.Text
        Title.Font = Enum.Font.GothamBlack
        Title.TextSize = 16
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 4
        
        -- Version badge
        local VerBadge = Instance.new("Frame", HD)
        VerBadge.Size = UDim2.new(0, 40, 0, 16)
        VerBadge.Position = UDim2.new(0, 58, 0, 32)
        VerBadge.BackgroundColor3 = C.Accent
        VerBadge.BackgroundTransparency = 0.75
        VerBadge.BorderSizePixel = 0
        VerBadge.ZIndex = 4
        Utils.Corner(VerBadge, 8)
        local VerLbl = Instance.new("TextLabel", VerBadge)
        VerLbl.Size = UDim2.new(1, 0, 1, 0)
        VerLbl.BackgroundTransparency = 1
        VerLbl.Text = "v7.0"
        VerLbl.TextColor3 = C.AccentLight
        VerLbl.Font = Enum.Font.GothamBold
        VerLbl.TextSize = 9
        VerLbl.ZIndex = 5
        
        -- Subtitle
        local Subtitle = Instance.new("TextLabel", HD)
        Subtitle.Size = UDim2.new(0, 150, 0, 16)
        Subtitle.Position = UDim2.new(0, 104, 0, 32)
        Subtitle.BackgroundTransparency = 1
        Subtitle.Text = "Premium Edition"
        Subtitle.TextColor3 = C.TextDim
        Subtitle.Font = Enum.Font.Gotham
        Subtitle.TextSize = 10
        Subtitle.TextXAlignment = Enum.TextXAlignment.Left
        Subtitle.ZIndex = 4
        
        -- Minimize
        local MinBtn = Instance.new("TextButton", HD)
        MinBtn.Size = UDim2.new(0, 30, 0, 30)
        MinBtn.Position = UDim2.new(1, -76, 0.5, -15)
        MinBtn.BackgroundColor3 = C.Card
        MinBtn.BackgroundTransparency = 0.3
        MinBtn.BorderSizePixel = 0
        MinBtn.Text = "—"
        MinBtn.TextColor3 = C.TextDim
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.TextSize = 16
        MinBtn.ZIndex = 4
        Utils.Corner(MinBtn, 8)
        
        -- Close
        local CloseBtn = Instance.new("TextButton", HD)
        CloseBtn.Size = UDim2.new(0, 30, 0, 30)
        CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
        CloseBtn.BackgroundColor3 = C.Card
        CloseBtn.BackgroundTransparency = 0.3
        CloseBtn.BorderSizePixel = 0
        CloseBtn.Text = "✕"
        CloseBtn.TextColor3 = C.Danger
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.TextSize = 14
        CloseBtn.ZIndex = 4
        Utils.Corner(CloseBtn, 8)
        
        -- Divider
        local Divider = Instance.new("Frame", MN)
        Divider.Size = UDim2.new(1, -32, 0, 1)
        Divider.Position = UDim2.new(0, 16, 0, 52)
        Divider.BackgroundColor3 = C.Accent
        Divider.BackgroundTransparency = 0.85
        Divider.BorderSizePixel = 0
        Divider.ZIndex = 4
        
        -- ============ SIDEBAR ============
        local SBBg = Instance.new("Frame", MN)
        SBBg.Size = UDim2.new(0, 160, 1, -53)
        SBBg.Position = UDim2.new(0, 0, 0, 53)
        SBBg.BackgroundColor3 = C.Panel
        SBBg.BackgroundTransparency = 0.4
        SBBg.BorderSizePixel = 0
        SBBg.ZIndex = 3
        local SBBgGrad = Instance.new("UIGradient", SBBg)
        SBBgGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 10, 26)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 6, 18))
        })
        SBBgGrad.Rotation = 90
        
        local SBDivider = Instance.new("Frame", MN)
        SBDivider.Size = UDim2.new(0, 1, 1, -53)
        SBDivider.Position = UDim2.new(0, 160, 0, 53)
        SBDivider.BackgroundColor3 = C.Accent
        SBDivider.BackgroundTransparency = 0.85
        SBDivider.BorderSizePixel = 0
        SBDivider.ZIndex = 4
        
        local SBScroll = Instance.new("ScrollingFrame", MN)
        SBScroll.Size = UDim2.new(0, 160, 1, -53)
        SBScroll.Position = UDim2.new(0, 0, 0, 53)
        SBScroll.BackgroundTransparency = 1
        SBScroll.BorderSizePixel = 0
        SBScroll.ScrollBarThickness = 0
        SBScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        SBScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        SBScroll.ZIndex = 4
        
        local SBLayout = Instance.new("UIListLayout", SBScroll)
        SBLayout.Padding = UDim.new(0, 2)
        SBLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local SBPadding = Instance.new("UIPadding", SBScroll)
        SBPadding.PaddingTop = UDim.new(0, 8)
        SBPadding.PaddingLeft = UDim.new(0, 10)
        SBPadding.PaddingRight = UDim.new(0, 10)
        
        -- ============ CONTENT AREA ============
        local CT = Instance.new("Frame", MN)
        CT.Size = UDim2.new(1, -160, 1, -53)
        CT.Position = UDim2.new(0, 160, 0, 53)
        CT.BackgroundTransparency = 1
        CT.ClipsDescendants = true
        CT.ZIndex = 5
        
        -- Page title
        local PTitle = Instance.new("TextLabel", CT)
        PTitle.Size = UDim2.new(1, -48, 0, 24)
        PTitle.Position = UDim2.new(0, 24, 0, 14)
        PTitle.BackgroundTransparency = 1
        PTitle.Text = "Aimbot"
        PTitle.TextColor3 = C.Text
        PTitle.Font = Enum.Font.GothamBlack
        PTitle.TextSize = 16
        PTitle.TextXAlignment = Enum.TextXAlignment.Left
        PTitle.ZIndex = 6
        
        local PSubtitle = Instance.new("TextLabel", CT)
        PSubtitle.Size = UDim2.new(1, -48, 0, 14)
        PSubtitle.Position = UDim2.new(0, 24, 0, 38)
        PSubtitle.BackgroundTransparency = 1
        PSubtitle.Text = "Configuração de mira assistida"
        PSubtitle.TextColor3 = C.TextDim
        PSubtitle.Font = Enum.Font.Gotham
        PSubtitle.TextSize = 10
        PSubtitle.TextXAlignment = Enum.TextXAlignment.Left
        PSubtitle.ZIndex = 6
        
        -- ============ UI COMPONENTS ============
        local UI = {}
        
        function UI.Section(parent, title)
            local s = Instance.new("Frame", parent)
            s.Size = UDim2.new(1, -10, 0, 20)
            s.BackgroundTransparency = 1
            s.ZIndex = 6
            local lbl = Instance.new("TextLabel", s)
            lbl.Size = UDim2.new(0, 100, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = title:upper()
            lbl.TextColor3 = C.AccentLight
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 7
            local line = Instance.new("Frame", s)
            line.Size = UDim2.new(1, -110, 0, 1)
            line.Position = UDim2.new(0, 104, 0.5, 0)
            line.BackgroundColor3 = C.Accent
            line.BackgroundTransparency = 0.75
            line.BorderSizePixel = 0
            line.ZIndex = 7
        end
        
        function UI.Toggle(parent, label, desc, key, cb)
            local r = Instance.new("Frame", parent)
            r.Size = UDim2.new(1, -10, 0, 46)
            r.BackgroundColor3 = C.Card
            r.BackgroundTransparency = 0.35
            r.BorderSizePixel = 0
            r.ZIndex = 6
            Utils.Corner(r, 10)
            
            local rs = Instance.new("UIStroke", r)
            rs.Color = C.Accent
            rs.Thickness = 1
            rs.Transparency = 1
            
            local bar = Instance.new("Frame", r)
            bar.Size = UDim2.new(0, 3, 1, -12)
            bar.Position = UDim2.new(0, 0, 0, 6)
            bar.BackgroundColor3 = C.Accent
            bar.BorderSizePixel = 0
            bar.BackgroundTransparency = 1
            bar.ZIndex = 7
            Utils.Corner(bar, 2)
            
            local lbl = Instance.new("TextLabel", r)
            lbl.Size = UDim2.new(1, -80, 0, 18)
            lbl.Position = UDim2.new(0, 14, 0, 7)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = C.Text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 7
            
            local sub = Instance.new("TextLabel", r)
            sub.Size = UDim2.new(1, -80, 0, 14)
            sub.Position = UDim2.new(0, 14, 0, 25)
            sub.BackgroundTransparency = 1
            sub.Text = desc or ""
            sub.TextColor3 = C.TextDim
            sub.Font = Enum.Font.Gotham
            sub.TextSize = 9
            sub.TextXAlignment = Enum.TextXAlignment.Left
            sub.ZIndex = 7
            
            local track = Instance.new("Frame", r)
            track.Size = UDim2.new(0, 38, 0, 20)
            track.Position = UDim2.new(1, -52, 0.5, -10)
            track.BackgroundColor3 = C.ToggleOff
            track.BorderSizePixel = 0
            track.ZIndex = 7
            Utils.Corner(track, 10)
            
            local trackStroke = Instance.new("UIStroke", track)
            trackStroke.Color = C.Accent
            trackStroke.Thickness = 1.5
            trackStroke.Transparency = 1
            
            local knob = Instance.new("Frame", track)
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = UDim2.new(0, 2, 0.5, -8)
            knob.BackgroundColor3 = C.TextDim
            knob.BorderSizePixel = 0
            knob.ZIndex = 8
            Utils.Corner(knob, 8)
            
            local state = Config[key] or false
            local function setValue(v)
                state = v
                Config[key] = v
                
                if state then
                    TweenService:Create(track, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = C.Accent}):Play()
                    TweenService:Create(trackStroke, TweenInfo.new(0.25), {Transparency = 0.3}):Play()
                    TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(1, -18, 0.5, -8),
                        BackgroundColor3 = C.Text
                    }):Play()
                    TweenService:Create(bar, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
                    TweenService:Create(rs, TweenInfo.new(0.2), {Transparency = 0.6}):Play()
                    -- Knob bounce
                    local origSize = UDim2.new(0, 16, 0, 16)
                    knob.Size = UDim2.new(0, 18, 0, 18)
                    knob.Position = UDim2.new(1, -19, 0.5, -9)
                    task.delay(0.15, function()
                        if knob.Parent then
                            TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                                Size = origSize,
                                Position = UDim2.new(1, -18, 0.5, -8)
                            }):Play()
                        end
                    end)
                else
                    TweenService:Create(track, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {BackgroundColor3 = C.ToggleOff}):Play()
                    TweenService:Create(trackStroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
                    TweenService:Create(knob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0, 2, 0.5, -8),
                        BackgroundColor3 = C.TextDim
                    }):Play()
                    TweenService:Create(bar, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(rs, TweenInfo.new(0.2), {Transparency = 1}):Play()
                end
                
                if cb then cb(state) end
            end
            
            if state then setValue(true) end
            
            local hitbox = Instance.new("TextButton", r)
            hitbox.Size = UDim2.new(1, 0, 1, 0)
            hitbox.BackgroundTransparency = 1
            hitbox.Text = ""
            hitbox.ZIndex = 20
            Connect(hitbox.MouseButton1Click, function() setValue(not state) end)
            Connect(hitbox.MouseEnter, function()
                TweenService:Create(r, TweenInfo.new(0.15), {BackgroundColor3 = C.CardHover, BackgroundTransparency = 0.25}):Play()
            end)
            Connect(hitbox.MouseLeave, function()
                TweenService:Create(r, TweenInfo.new(0.15), {BackgroundColor3 = C.Card, BackgroundTransparency = 0.35}):Play()
            end)
        end
        
        function UI.Slider(parent, label, mn, mx, key, cb)
            local r = Instance.new("Frame", parent)
            r.Size = UDim2.new(1, -10, 0, 46)
            r.BackgroundColor3 = C.Card
            r.BackgroundTransparency = 0.35
            r.BorderSizePixel = 0
            r.ZIndex = 6
            Utils.Corner(r, 10)
            
            local lbl = Instance.new("TextLabel", r)
            lbl.Size = UDim2.new(1, -80, 0, 18)
            lbl.Position = UDim2.new(0, 14, 0, 7)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = C.Text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 7
            
            local currentVal = Config[key] or mn
            local valBadge = Instance.new("Frame", r)
            valBadge.Size = UDim2.new(0, 48, 0, 18)
            valBadge.Position = UDim2.new(1, -62, 0, 7)
            valBadge.BackgroundColor3 = C.Accent
            valBadge.BackgroundTransparency = 0.75
            valBadge.BorderSizePixel = 0
            valBadge.ZIndex = 7
            Utils.Corner(valBadge, 5)
            
            local valTxt = Instance.new("TextLabel", valBadge)
            valTxt.Size = UDim2.new(1, 0, 1, 0)
            valTxt.BackgroundTransparency = 1
            valTxt.Text = tostring(currentVal)
            valTxt.TextColor3 = C.AccentLight
            valTxt.Font = Enum.Font.GothamBold
            valTxt.TextSize = 10
            valTxt.ZIndex = 8
            
            local track = Instance.new("Frame", r)
            track.Size = UDim2.new(1, -28, 0, 3)
            track.Position = UDim2.new(0, 14, 1, -12)
            track.BackgroundColor3 = C.ToggleOff
            track.BorderSizePixel = 0
            track.ZIndex = 7
            Utils.Corner(track, 2)
            
            local fill = Instance.new("Frame", track)
            fill.Size = UDim2.new((currentVal - mn) / (mx - mn), 0, 1, 0)
            fill.BackgroundColor3 = C.Accent
            fill.BorderSizePixel = 0
            fill.ZIndex = 8
            Utils.Corner(fill, 2)
            local fillGrad = Instance.new("UIGradient", fill)
            fillGrad.Color = ColorSequence.new(C.AccentDim, C.AccentLight)
            
            local handle = Instance.new("Frame", track)
            handle.Size = UDim2.new(0, 14, 0, 14)
            handle.Position = UDim2.new((currentVal - mn) / (mx - mn), -7, 0.5, -7)
            handle.BackgroundColor3 = C.Text
            handle.BorderSizePixel = 0
            handle.ZIndex = 9
            Utils.Corner(handle, 7)
            
            local handleStroke = Instance.new("UIStroke", handle)
            handleStroke.Color = C.Accent
            handleStroke.Thickness = 2
            handleStroke.Transparency = 0.3
            
            local hitbox = Instance.new("TextButton", r)
            hitbox.Size = UDim2.new(1, 0, 1, 0)
            hitbox.BackgroundTransparency = 1
            hitbox.Text = ""
            hitbox.ZIndex = 20
            
            local dragging = false
            local function update(x)
                local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                local v = math.floor(mn + (mx - mn) * rel + 0.5)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                handle.Position = UDim2.new(rel, -7, 0.5, -7)
                valTxt.Text = tostring(v)
                Config[key] = v
                if cb then cb(v) end
            end
            
            Connect(hitbox.InputBegan, function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(i.Position.X)
                end
            end)
            Connect(UserInputService.InputChanged, function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    update(i.Position.X)
                end
            end)
            Connect(UserInputService.InputEnded, function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            Connect(hitbox.MouseEnter, function()
                TweenService:Create(handle, TweenInfo.new(0.15), {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(handle.Position.X.Scale, -8, 0.5, -8)}):Play()
                TweenService:Create(r, TweenInfo.new(0.15), {BackgroundColor3 = C.CardHover, BackgroundTransparency = 0.25}):Play()
            end)
            Connect(hitbox.MouseLeave, function()
                if not dragging then
                    TweenService:Create(handle, TweenInfo.new(0.15), {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(handle.Position.X.Scale, -7, 0.5, -7)}):Play()
                end
                TweenService:Create(r, TweenInfo.new(0.15), {BackgroundColor3 = C.Card, BackgroundTransparency = 0.35}):Play()
            end)
        end
        
        function UI.Dropdown(parent, label, opts, key, cb)
            local r = Instance.new("Frame", parent)
            r.Size = UDim2.new(1, -10, 0, 46)
            r.BackgroundColor3 = C.Card
            r.BackgroundTransparency = 0.35
            r.BorderSizePixel = 0
            r.ClipsDescendants = true
            r.ZIndex = 6
            Utils.Corner(r, 10)
            
            local lbl = Instance.new("TextLabel", r)
            lbl.Size = UDim2.new(1, -130, 0, 18)
            lbl.Position = UDim2.new(0, 14, 0, 14)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = C.Text
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 7
            
            local current = Config[key] or opts[1]
            local btn = Instance.new("TextButton", r)
            btn.Size = UDim2.new(0, 100, 0, 26)
            btn.Position = UDim2.new(1, -114, 0.5, -13)
            btn.BackgroundColor3 = C.Accent
            btn.BackgroundTransparency = 0.8
            btn.BorderSizePixel = 0
            btn.Text = current .. " ▾"
            btn.TextColor3 = C.AccentLight
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 10
            btn.ZIndex = 20
            Utils.Corner(btn, 6)
            
            local btnStroke = Instance.new("UIStroke", btn)
            btnStroke.Color = C.Accent
            btnStroke.Thickness = 1
            btnStroke.Transparency = 0.5
            
            local isOpen = false
            local list = Instance.new("Frame", r)
            list.Size = UDim2.new(1, -16, 0, 0)
            list.Position = UDim2.new(0, 8, 0, 46)
            list.BackgroundColor3 = C.Panel
            list.BackgroundTransparency = 0.15
            list.BorderSizePixel = 0
            list.ClipsDescendants = true
            list.ZIndex = 25
            Utils.Corner(list, 8)
            
            local listLayout = Instance.new("UIListLayout", list)
            listLayout.Padding = UDim.new(0, 2)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local listPad = Instance.new("UIPadding", list)
            listPad.PaddingTop = UDim.new(0, 4)
            listPad.PaddingBottom = UDim.new(0, 4)
            
            for i, opt in ipairs(opts) do
                local ob = Instance.new("TextButton", list)
                ob.Size = UDim2.new(1, -8, 0, 28)
                ob.BackgroundTransparency = 1
                ob.Text = opt
                ob.TextColor3 = C.TextDim
                ob.Font = Enum.Font.Gotham
                ob.TextSize = 11
                ob.ZIndex = 26
                ob.LayoutOrder = i
                Utils.Corner(ob, 5)
                
                Connect(ob.MouseButton1Click, function()
                    btn.Text = opt .. " ▾"
                    isOpen = false
                    Config[key] = opt
                    TweenService:Create(list, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -16, 0, 0)}):Play()
                    TweenService:Create(r, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 46)}):Play()
                    if cb then cb(opt) end
                end)
                Connect(ob.MouseEnter, function()
                    TweenService:Create(ob, TweenInfo.new(0.1), {BackgroundTransparency = 0.8, BackgroundColor3 = C.Accent, TextColor3 = C.Text}):Play()
                end)
                Connect(ob.MouseLeave, function()
                    TweenService:Create(ob, TweenInfo.new(0.1), {BackgroundTransparency = 1, TextColor3 = C.TextDim}):Play()
                end)
            end
            
            Connect(btn.MouseButton1Click, function()
                isOpen = not isOpen
                if isOpen then
                    local h = #opts * 30 + 12
                    TweenService:Create(list, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -16, 0, h)}):Play()
                    TweenService:Create(r, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -10, 0, 46 + h)}):Play()
                else
                    TweenService:Create(list, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {Size = UDim2.new(1, -16, 0, 0)}):Play()
                    TweenService:Create(r, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 46)}):Play()
                end
            end)
        end
        
        function UI.Button(parent, label, color, cb)
            local b = Instance.new("TextButton", parent)
            b.Size = UDim2.new(1, -10, 0, 40)
            b.BackgroundColor3 = color or C.Accent
            b.BorderSizePixel = 0
            b.Text = label
            b.TextColor3 = C.Text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.ZIndex = 6
            Utils.Corner(b, 10)
            
            local bStroke = Instance.new("UIStroke", b)
            bStroke.Color = Color3.fromRGB(255, 255, 255)
            bStroke.Thickness = 1
            bStroke.Transparency = 0.85
            
            if cb then Connect(b.MouseButton1Click, cb) end
            
            Connect(b.MouseButton1Down, function()
                TweenService:Create(b, TweenInfo.new(0.1), {Size = UDim2.new(1, -14, 0, 38), Position = UDim2.new(0, 2, 0, 1)}):Play()
            end)
            Connect(b.MouseButton1Up, function()
                TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Back), {Size = UDim2.new(1, -10, 0, 40), Position = UDim2.new(0, 0, 0, 0)}):Play()
            end)
            Connect(b.MouseEnter, function()
                TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
            end)
            Connect(b.MouseLeave, function()
                TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
            end)
            
            return b
        end
        
        -- ============ TABS CONFIG ============
        local TABS = {
            {icon="◉", title="Aimbot", sub="Configuração de mira assistida"},
            {icon="◎", title="ESP", sub="Visualização de jogadores"},
            {icon="◆", title="Desempenho", sub="Otimização e FPS"},
            {icon="✦", title="Visual", sub="Iluminação e ambiente"},
            {icon="⊕", title="Mira", sub="Crosshair customizado"},
            {icon="▣", title="Assistente IA", sub="Pergunte qualquer coisa"},
            {icon="▥", title="Bypass", sub="Controle de visibilidade"},
            {icon="◈", title="Smart", sub="Otimização adaptativa"},
            {icon="▤", title="Salvar", sub="Gerenciar configurações"},
            {icon="▦", title="Configurações", sub="Preferências do script"}
        }
        
        -- ============ PAGES ============
        local Pages = {}
        for i = 1, #TABS do
            local p = Instance.new("ScrollingFrame", CT)
            p.Size = UDim2.new(1, -40, 1, -70)
            p.Position = UDim2.new(0, 20, 0, 62)
            p.BackgroundTransparency = 1
            p.BorderSizePixel = 0
            p.ScrollBarThickness = 2
            p.ScrollBarImageColor3 = C.Accent
            p.ScrollBarImageTransparency = 0.5
            p.Visible = false
            p.ZIndex = 6
            p.CanvasSize = UDim2.new(0, 0, 0, 0)
            p.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Pages[i] = p
            
            local layout = Instance.new("UIListLayout", p)
            layout.Padding = UDim.new(0, 6)
            layout.SortOrder = Enum.SortOrder.LayoutOrder
        end
        
        -- ============ POPULATE PAGES ============
        -- AIMBOT
        UI.Section(Pages[1], "Geral")
        UI.Toggle(Pages[1], "Aim Assist", "Ativa a mira assistida", "AimAssist")
        UI.Toggle(Pages[1], "Legit Aim", "Mira suave com humanização", "LegitAim")
        UI.Toggle(Pages[1], "Camera Lock", "Trava câmera no alvo", "CameraLock")
        UI.Section(Pages[1], "Alvo")
        UI.Slider(Pages[1], "Campo de Visão", 30, 400, "FOV")
        UI.Slider(Pages[1], "Smoothness", 0, 100, "Smoothness")
        UI.Dropdown(Pages[1], "Cor do FOV", {"RGB","Roxo","Vermelho","Verde","Azul"}, "FOVColorMode")
        UI.Toggle(Pages[1], "Mostrar Círculo", "Exibe o raio do FOV", "FOVCircle")
        UI.Section(Pages[1], "Filtros")
        UI.Toggle(Pages[1], "Team Check", "Ignora aliados", "TeamCheck")
        UI.Toggle(Pages[1], "Line of Sight", "Só mira se visível", "LOSCheck")
        UI.Toggle(Pages[1], "Auto-Predict", "Prever movimento", "AutoPredict")
        
        -- ESP
        UI.Section(Pages[2], "Master")
        UI.Toggle(Pages[2], "Master ESP", "Liga/desliga tudo", "ESP")
        UI.Toggle(Pages[2], "Highlight", "Brilho no corpo", "ESP_Highlight")
        UI.Toggle(Pages[2], "Box ESP", "Caixa delimitadora", "ESP_Box")
        UI.Section(Pages[2], "Informações")
        UI.Toggle(Pages[2], "Nome", "Nome do jogador", "ESP_Name")
        UI.Toggle(Pages[2], "Distância", "Distância até o alvo", "ESP_Dist")
        UI.Slider(Pages[2], "Transparência", 0, 100, "ESP_Transparency")
        
        -- FPS
        UI.Section(Pages[3], "Desempenho")
        UI.Dropdown(Pages[3], "Preset", {"Low","Medium","High","Extreme"}, "FPSPreset", function(v) SmartBoost:Mode_(v) end)
        UI.Toggle(Pages[3], "FPS HUD", "Contador em tempo real", "FPSMonitor", function(v) FH.Visible = v end)
        UI.Toggle(Pages[3], "Gráfico Batata", "Remove até a grama", "PotatoColorful", function(v)
            if v then
                SmartBoost:Mode_("EXTREME")
                local t = Workspace:FindFirstChildOfClass("Terrain"); if t then t.Decoration = false end
                local cc = Lighting:FindFirstChild("VoidSat"); if not cc then cc = Instance.new("ColorCorrectionEffect"); cc.Name = "VoidSat"; cc.Parent = Lighting end
                cc.Saturation = 2.5; cc.Enabled = true
            else
                SmartBoost:Restore()
            end
        end)
        UI.Section(Pages[3], "Ajustes")
        UI.Slider(Pages[3], "Esticar Tela", 40, 120, "StretchFOV", function(v) Camera.FieldOfView = v end)
        UI.Slider(Pages[3], "Renderização", 100, 3000, "RenderDistance", function(v) 
            if v >= 3000 then Lighting.FogStart = 0; Lighting.FogEnd = 100000 
            else Lighting.FogStart = v * 0.8; Lighting.FogEnd = v end 
        end)
        UI.Slider(Pages[3], "Saturação", 0, 300, "Saturation", function(v) 
            local cc = Lighting:FindFirstChild("VoidSat")
            if not cc then cc = Instance.new("ColorCorrectionEffect"); cc.Name = "VoidSat"; cc.Parent = Lighting end
            cc.Saturation = v / 100; cc.Enabled = true
        end)
        
        -- VISUAL
        UI.Section(Pages[4], "Iluminação")
        UI.Toggle(Pages[4], "Fullbright", "Remove sombras", "Fullbright", function(v) Lighting.Brightness = v and 3 or 1 end)
        UI.Toggle(Pages[4], "Remove Fog", "Remove névoa", "RemoveFog", function(v) Lighting.FogEnd = v and 100000 or 1000 end)
        
        -- MIRA
        UI.Section(Pages[5], "Crosshair")
        UI.Toggle(Pages[5], "Mira Custom", "Ativa mira customizada", "Crosshair")
        UI.Dropdown(Pages[5], "Estilo", {"+","•","⨁","🎯","✛"}, "CH_Style")
        UI.Slider(Pages[5], "Tamanho", 10, 100, "CH_Size")
        
        -- IA
        local CSChat = Instance.new("ScrollingFrame", Pages[6])
        CSChat.Size = UDim2.new(1, -10, 0, 200)
        CSChat.BackgroundColor3 = C.Panel
        CSChat.BackgroundTransparency = 0.4
        CSChat.BorderSizePixel = 0
        CSChat.ScrollBarThickness = 2
        CSChat.ScrollBarImageColor3 = C.Accent
        CSChat.ZIndex = 6
        Utils.Corner(CSChat, 10)
        local cl = Instance.new("UIListLayout", CSChat)
        cl.Padding = UDim.new(0, 6)
        CSChat.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local function AddMessage(text, isUser)
            local m = Instance.new("Frame", CSChat)
            m.Size = UDim2.new(isUser and 0.75 or 0.85, -8, 0, 0)
            m.Position = UDim2.new(isUser and 0.25 or 0, 0, 0, 0)
            m.BackgroundColor3 = isUser and C.Accent or C.Card
            m.BackgroundTransparency = isUser and 0.35 or 0.25
            m.AutomaticSize = Enum.AutomaticSize.Y
            m.ZIndex = 7
            Utils.Corner(m, 10)
            
            local mlbl = Instance.new("TextLabel", m)
            mlbl.Size = UDim2.new(1, -16, 0, 0)
            mlbl.Position = UDim2.new(0, 8, 0, 6)
            mlbl.BackgroundTransparency = 1
            mlbl.Text = text
            mlbl.TextColor3 = C.Text
            mlbl.Font = Enum.Font.Gotham
            mlbl.TextSize = 11
            mlbl.TextWrapped = true
            mlbl.TextXAlignment = Enum.TextXAlignment.Left
            mlbl.AutomaticSize = Enum.AutomaticSize.Y
            mlbl.ZIndex = 8
            local mlblPad = Instance.new("UIPadding", mlbl)
            mlblPad.PaddingBottom = UDim.new(0, 6)
            
            task.defer(function()
                CSChat.CanvasPosition = Vector2.new(0, CSChat.CanvasSize.Y.Offset)
            end)
        end
        
        task.delay(0.5, function()
            AddMessage("Olá! Sou a Assistente IA do VOID HUB.", false)
            AddMessage("Pergunte sobre Aimbot, FPS, ESP ou Config.", false)
        end)
        
        local inputBox = Instance.new("TextBox", Pages[6])
        inputBox.Size = UDim2.new(1, -76, 0, 36)
        inputBox.Position = UDim2.new(0, 0, 0, 210)
        inputBox.BackgroundColor3 = C.Card
        inputBox.BackgroundTransparency = 0.3
        inputBox.BorderSizePixel = 0
        inputBox.PlaceholderText = "Digite sua pergunta..."
        inputBox.PlaceholderColor3 = C.TextDim
        inputBox.Text = ""
        inputBox.TextColor3 = C.Text
        inputBox.Font = Enum.Font.Gotham
        inputBox.TextSize = 11
        inputBox.TextXAlignment = Enum.TextXAlignment.Left
        inputBox.ClearTextOnFocus = false
        inputBox.ZIndex = 6
        Utils.Corner(inputBox, 10)
        local inputPad = Instance.new("UIPadding", inputBox)
        inputPad.PaddingLeft = UDim.new(0, 12)
        
        local sendBtn = Instance.new("TextButton", Pages[6])
        sendBtn.Size = UDim2.new(0, 68, 0, 36)
        sendBtn.Position = UDim2.new(1, -70, 0, 210)
        sendBtn.BackgroundColor3 = C.Accent
        sendBtn.BorderSizePixel = 0
        sendBtn.Text = "Enviar"
        sendBtn.TextColor3 = C.Text
        sendBtn.Font = Enum.Font.GothamBold
        sendBtn.TextSize = 11
        sendBtn.ZIndex = 10
        Utils.Corner(sendBtn, 10)
        
        Connect(sendBtn.MouseButton1Click, function()
            local q = inputBox.Text
            if q == "" then return end
            AddMessage(q, true)
            inputBox.Text = ""
            task.wait(0.3)
            AddMessage(GetAIResponse(q), false)
        end)
        
        -- BYPASS
        UI.Button(Pages[7], "ESCONDER MENU", C.Accent, function() Min() end)
        local killBtn = UI.Button(Pages[7], "ENCERRAR SCRIPT", C.Danger, nil)
        local confirmKill = false
        Connect(killBtn.MouseButton1Click, function()
            if not confirmKill then
                confirmKill = true
                killBtn.Text = "CONFIRMAR? CLIQUE DE NOVO"
                task.delay(3, function()
                    if killBtn and killBtn.Parent then
                        confirmKill = false
                        killBtn.Text = "ENCERRAR SCRIPT"
                    end
                end)
                return
            end
            for _, c in ipairs(ActiveConnections) do if c.Connected then c:Disconnect() end end
            ActiveConnections = {}
            if SG then SG:Destroy() end
        end)
        
        -- SMART
        UI.Section(Pages[8], "Inteligência")
        UI.Toggle(Pages[8], "Smart Aim 2.0", "Adapta suavidade ao FPS", "SmartAim", function(v) SmartAim.Enabled = v end)
        UI.Toggle(Pages[8], "Smart Boost", "Otimização adaptativa", "SmartBoost", function(v) SmartBoost.Enabled = v end)
        
        -- SAVE
        UI.Button(Pages[9], "SALVAR", C.Accent, function()
            local ok = SaveSystem:Save()
            Toast(ok and "Salvo!" or "Erro", "Configurações salvas", ok and "success" or "error")
        end)
        UI.Button(Pages[9], "CARREGAR", C.AccentDim, function()
            local ok = SaveSystem:Load()
            Toast(ok and "Carregado!" or "Erro", "Configurações carregadas", ok and "success" or "error")
        end)
        
        -- CONFIG
        local verCard = Instance.new("Frame", Pages[10])
        verCard.Size = UDim2.new(1, -10, 0, 46)
        verCard.BackgroundColor3 = C.Card
        verCard.BackgroundTransparency = 0.35
        verCard.BorderSizePixel = 0
        verCard.ZIndex = 6
        Utils.Corner(verCard, 10)
        local verLbl1 = Instance.new("TextLabel", verCard)
        verLbl1.Size = UDim2.new(0.5, -14, 1, 0)
        verLbl1.Position = UDim2.new(0, 14, 0, 0)
        verLbl1.BackgroundTransparency = 1
        verLbl1.Text = "Versão"
        verLbl1.TextColor3 = C.Text
        verLbl1.Font = Enum.Font.GothamBold
        verLbl1.TextSize = 12
        verLbl1.TextXAlignment = Enum.TextXAlignment.Left
        verLbl1.ZIndex = 7
        local verLbl2 = Instance.new("TextLabel", verCard)
        verLbl2.Size = UDim2.new(0.5, -14, 1, 0)
        verLbl2.Position = UDim2.new(0.5, 0, 0, 0)
        verLbl2.BackgroundTransparency = 1
        verLbl2.Text = "VOID HUB 7.0"
        verLbl2.TextColor3 = C.AccentLight
        verLbl2.Font = Enum.Font.GothamBold
        verLbl2.TextSize = 12
        verLbl2.TextXAlignment = Enum.TextXAlignment.Right
        verLbl2.ZIndex = 7
        
        UI.Dropdown(Pages[10], "Idioma", {"Português (BR)","English","Español","Français","Deutsch"}, "Language", function(v)
            local map = {["Português (BR)"]="pt-br",["English"]="en",["Español"]="es",["Français"]="fr",["Deutsch"]="de"}
            Language = map[v] or "pt-br"
            Config.Language = Language
            task.wait(0.1)
            CleanupAll()
            SG:Destroy()
            BuildUI()
        end)
        
        local aboutCard = Instance.new("Frame", Pages[10])
        aboutCard.Size = UDim2.new(1, -10, 0, 0)
        aboutCard.AutomaticSize = Enum.AutomaticSize.Y
        aboutCard.BackgroundColor3 = C.Card
        aboutCard.BackgroundTransparency = 0.35
        aboutCard.BorderSizePixel = 0
        aboutCard.ZIndex = 6
        Utils.Corner(aboutCard, 10)
        local aboutPad = Instance.new("UIPadding", aboutCard)
        aboutPad.PaddingTop = UDim.new(0, 12)
        aboutPad.PaddingBottom = UDim.new(0, 12)
        aboutPad.PaddingLeft = UDim.new(0, 14)
        aboutPad.PaddingRight = UDim.new(0, 14)
        local aboutText = Instance.new("TextLabel", aboutCard)
        aboutText.Size = UDim2.new(1, 0, 0, 0)
        aboutText.AutomaticSize = Enum.AutomaticSize.Y
        aboutText.BackgroundTransparency = 1
        aboutText.Text = T("config_about_text")
        aboutText.TextColor3 = C.TextDim
        aboutText.Font = Enum.Font.Gotham
        aboutText.TextSize = 11
        aboutText.TextWrapped = true
        aboutText.TextXAlignment = Enum.TextXAlignment.Left
        aboutText.TextYAlignment = Enum.TextYAlignment.Top
        aboutText.ZIndex = 7
        
        -- ============ SIDEBAR BUTTONS ============
        local tabBtns = {}
        
        local function SwitchTab(index)
            Config.ActiveTab = index
            
            -- Content transition
            local page = Pages[index]
            page.Visible = true
            page.Position = UDim2.new(0, 20, 0, 68)
            TweenService:Create(page, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 20, 0, 62)}):Play()
            
            for i, p in pairs(Pages) do
                if i ~= index then p.Visible = false end
            end
            
            -- Header transition
            PTitle.TextTransparency = 0.5
            PSubtitle.TextTransparency = 0.5
            PTitle.Text = TABS[index].title
            PSubtitle.Text = TABS[index].sub
            TweenService:Create(PTitle, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
            TweenService:Create(PSubtitle, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
            
            -- Sidebar buttons
            for i, b in pairs(tabBtns) do
                local active = (i == index)
                if active then
                    TweenService:Create(b.f, TweenInfo.new(0.2), {BackgroundColor3 = C.Card, BackgroundTransparency = 0.15}):Play()
                    TweenService:Create(b.lbl, TweenInfo.new(0.2), {TextColor3 = C.Text}):Play()
                    TweenService:Create(b.icon, TweenInfo.new(0.2), {TextColor3 = C.AccentLight}):Play()
                    TweenService:Create(b.ind, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 3, 0, 22), BackgroundTransparency = 0}):Play()
                    TweenService:Create(b.stroke, TweenInfo.new(0.2), {Transparency = 0.6}):Play()
                else
                    TweenService:Create(b.f, TweenInfo.new(0.2), {BackgroundColor3 = C.Panel, BackgroundTransparency = 1}):Play()
                    TweenService:Create(b.lbl, TweenInfo.new(0.2), {TextColor3 = C.TextDim}):Play()
                    TweenService:Create(b.icon, TweenInfo.new(0.2), {TextColor3 = C.TextDim}):Play()
                    TweenService:Create(b.ind, TweenInfo.new(0.25), {Size = UDim2.new(0, 3, 0, 0), BackgroundTransparency = 0}):Play()
                    TweenService:Create(b.stroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
                end
            end
        end
        
        for i, tab in ipairs(TABS) do
            local f = Instance.new("TextButton", SBScroll)
            f.Size = UDim2.new(1, 0, 0, 38)
            f.BackgroundColor3 = C.Panel
            f.BackgroundTransparency = 1
            f.BorderSizePixel = 0
            f.Text = ""
            f.LayoutOrder = i
            f.ZIndex = 8
            Utils.Corner(f, 8)
            
            local stroke = Instance.new("UIStroke", f)
            stroke.Color = C.Accent
            stroke.Thickness = 1
            stroke.Transparency = 1
            
            local ind = Instance.new("Frame", f)
            ind.Size = UDim2.new(0, 3, 0, 0)
            ind.Position = UDim2.new(0, 0, 0.5, 0)
            ind.AnchorPoint = Vector2.new(0, 0.5)
            ind.BackgroundColor3 = C.Accent
            ind.BorderSizePixel = 0
            ind.ZIndex = 9
            Utils.Corner(ind, 2)
            
            local icon = Instance.new("TextLabel", f)
            icon.Size = UDim2.new(0, 20, 1, 0)
            icon.Position = UDim2.new(0, 12, 0, 0)
            icon.BackgroundTransparency = 1
            icon.Text = tab.icon
            icon.TextColor3 = C.TextDim
            icon.Font = Enum.Font.GothamBold
            icon.TextSize = 14
            icon.TextXAlignment = Enum.TextXAlignment.Center
            icon.ZIndex = 9
            
            local lbl = Instance.new("TextLabel", f)
            lbl.Size = UDim2.new(1, -40, 1, 0)
            lbl.Position = UDim2.new(0, 38, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = tab.title
            lbl.TextColor3 = C.TextDim
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 9
            
            tabBtns[i] = {f=f, lbl=lbl, icon=icon, ind=ind, stroke=stroke}
            
            Connect(f.MouseButton1Click, function() SwitchTab(i) end)
            Connect(f.MouseEnter, function()
                if Config.ActiveTab ~= i then
                    TweenService:Create(f, TweenInfo.new(0.15), {BackgroundColor3 = C.Card, BackgroundTransparency = 0.7}):Play()
                    TweenService:Create(lbl, TweenInfo.new(0.15), {TextColor3 = C.Text}):Play()
                end
            end)
            Connect(f.MouseLeave, function()
                if Config.ActiveTab ~= i then
                    TweenService:Create(f, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(lbl, TweenInfo.new(0.15), {TextColor3 = C.TextDim}):Play()
                end
            end)
        end
        
        -- ============ FPS HUD ============
        local FH = Instance.new("Frame", SG)
        FH.Size = UDim2.new(0, 200, 0, 56)
        FH.Position = UDim2.new(1, -218, 0, 16)
        FH.BackgroundColor3 = C.Panel
        FH.BackgroundTransparency = 0.15
        FH.BorderSizePixel = 0
        FH.ZIndex = 200
        Utils.Corner(FH, 12)
        local FHStroke = Instance.new("UIStroke", FH)
        FHStroke.Color = C.Accent
        FHStroke.Thickness = 1.5
        FHStroke.Transparency = 0.5
        
        local FHLabel = Instance.new("TextLabel", FH)
        FHLabel.Size = UDim2.new(1, -20, 0, 22)
        FHLabel.Position = UDim2.new(0, 12, 0, 8)
        FHLabel.BackgroundTransparency = 1
        FHLabel.Text = "FPS: --"
        FHLabel.TextColor3 = C.Success
        FHLabel.Font = Enum.Font.GothamBold
        FHLabel.TextSize = 14
        FHLabel.TextXAlignment = Enum.TextXAlignment.Left
        FHLabel.ZIndex = 201
        
        local FHStatus = Instance.new("TextLabel", FH)
        FHStatus.Size = UDim2.new(1, -20, 0, 12)
        FHStatus.Position = UDim2.new(0, 12, 0, 30)
        FHStatus.BackgroundTransparency = 1
        FHStatus.Text = "—"
        FHStatus.TextColor3 = C.TextDim
        FHStatus.Font = Enum.Font.Gotham
        FHStatus.TextSize = 9
        FHStatus.TextXAlignment = Enum.TextXAlignment.Left
        FHStatus.ZIndex = 201
        
        local FHBar = Instance.new("Frame", FH)
        FHBar.Size = UDim2.new(1, -20, 0, 3)
        FHBar.Position = UDim2.new(0, 10, 1, -8)
        FHBar.BackgroundColor3 = C.ToggleOff
        FHBar.BorderSizePixel = 0
        FHBar.ZIndex = 201
        Utils.Corner(FHBar, 2)
        
        local FHBarFill = Instance.new("Frame", FHBar)
        FHBarFill.Size = UDim2.new(0, 0, 1, 0)
        FHBarFill.BackgroundColor3 = C.Success
        FHBarFill.BorderSizePixel = 0
        FHBarFill.ZIndex = 202
        Utils.Corner(FHBarFill, 2)
        
        -- ============ FLOATING BALL ============
        local Ball = Instance.new("TextButton", SG)
        Ball.Size = UDim2.new(0, 48, 0, 48)
        Ball.Position = UDim2.new(0, 18, 0.5, -24)
        Ball.BackgroundColor3 = C.Panel
        Ball.BorderSizePixel = 0
        Ball.Text = ""
        Ball.Visible = false
        Ball.ZIndex = 100
        Utils.Corner(Ball, 14)
        local BallStroke = Instance.new("UIStroke", Ball)
        BallStroke.Color = C.Accent
        BallStroke.Thickness = 2
        BallStroke.Transparency = 0.3
        local BallIcon = Instance.new("ImageLabel", Ball)
        BallIcon.Size = UDim2.new(1, 0, 1, 0)
        BallIcon.BackgroundTransparency = 1
        BallIcon.Image = CONFIG_IMAGE_ID
        BallIcon.ScaleType = Enum.ScaleType.Crop
        BallIcon.ZIndex = 101
        Utils.Corner(BallIcon, 14)
        
        -- ============ TOAST SYSTEM ============
        local ToastStack = Instance.new("Frame", SG)
        ToastStack.Size = UDim2.new(0, 240, 0, 400)
        ToastStack.Position = UDim2.new(1, -260, 1, -420)
        ToastStack.BackgroundTransparency = 1
        ToastStack.ZIndex = 300
        local ToastLayout = Instance.new("UIListLayout", ToastStack)
        ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        ToastLayout.Padding = UDim.new(0, 6)
        
        function Toast(title, subtitle, kind)
            local accent = kind == "success" and C.Success or (kind == "error" and C.Danger or C.Accent)
            local t = Instance.new("Frame", ToastStack)
            t.Size = UDim2.new(1, 0, 0, 46)
            t.BackgroundColor3 = C.Panel
            t.BackgroundTransparency = 0.1
            t.BorderSizePixel = 0
            t.ZIndex = 301
            Utils.Corner(t, 10)
            local ts = Instance.new("UIStroke", t)
            ts.Color = accent
            ts.Thickness = 1.5
            ts.Transparency = 0.3
            local bar = Instance.new("Frame", t)
            bar.Size = UDim2.new(0, 3, 1, -10)
            bar.Position = UDim2.new(0, 0, 0, 5)
            bar.BackgroundColor3 = accent
            bar.BorderSizePixel = 0
            bar.ZIndex = 302
            Utils.Corner(bar, 2)
            local ttl = Instance.new("TextLabel", t)
            ttl.Size = UDim2.new(1, -24, 0, 18)
            ttl.Position = UDim2.new(0, 12, 0, 6)
            ttl.BackgroundTransparency = 1
            ttl.Text = title
            ttl.TextColor3 = C.Text
            ttl.Font = Enum.Font.GothamBold
            ttl.TextSize = 11
            ttl.TextXAlignment = Enum.TextXAlignment.Left
            ttl.ZIndex = 302
            local sub = Instance.new("TextLabel", t)
            sub.Size = UDim2.new(1, -24, 0, 14)
            sub.Position = UDim2.new(0, 12, 0, 24)
            sub.BackgroundTransparency = 1
            sub.Text = subtitle or ""
            sub.TextColor3 = C.TextDim
            sub.Font = Enum.Font.Gotham
            sub.TextSize = 9
            sub.TextXAlignment = Enum.TextXAlignment.Left
            sub.ZIndex = 302
            local sc = Instance.new("UIScale", t)
            sc.Scale = 0.7
            TweenService:Create(sc, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Scale = 1}):Play()
            task.delay(2.8, function()
                if t and t.Parent then
                    TweenService:Create(sc, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Scale = 0.7}):Play()
                    TweenService:Create(t, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                    TweenService:Create(ts, TweenInfo.new(0.3), {Transparency = 1}):Play()
                    task.delay(0.35, function() if t then t:Destroy() end end)
                end
            end)
        end
        
        -- ============ MINIMIZE / RESTORE ============
        local function Min()
            MNScale.Scale = 1
            TweenService:Create(MN, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            TweenService:Create(BD, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
            task.delay(0.26, function()
                MN.Visible = false
                BD.Visible = false
                Ball.Visible = true
            end)
        end
        
        local function Restore()
            MN.Visible = true
            BD.Visible = true
            MN.Size = UDim2.new(0, 0, 0, 0)
            MNScale.Scale = 1
            TweenService:Create(MN, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 520, 0, 400)}):Play()
            TweenService:Create(BD, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
            Ball.Visible = false
        end
        
        Connect(Ball.MouseButton1Click, Restore)
        
        -- ============ WINDOW CONTROLS ============
        Connect(MinBtn.MouseButton1Click, Min)
        Connect(MinBtn.MouseEnter, function()
            TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.Accent, TextColor3 = C.Text}):Play()
        end)
        Connect(MinBtn.MouseLeave, function()
            TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.Card, TextColor3 = C.TextDim}):Play()
        end)
        
        Connect(CloseBtn.MouseButton1Click, Min)
        Connect(CloseBtn.MouseEnter, function()
            TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.Danger, TextColor3 = C.Text}):Play()
        end)
        Connect(CloseBtn.MouseLeave, function()
            TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = C.Card, TextColor3 = C.Danger}):Play()
        end)
        
        -- ============ DRAG ============
        local function MakeDraggable(frame, handle)
            local dragging, dragStart, startPos
            Connect(handle.InputBegan, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = frame.Position
                end
            end)
            Connect(UserInputService.InputChanged, function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            Connect(UserInputService.InputEnded, function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end
        MakeDraggable(MN, HD)
        MakeDraggable(FH, FH)
        MakeDraggable(Ball, Ball)
        
        -- ============ RENDER LOGIC ============
        local RenderCache = {}
        local jitterT = 0
        local espAccum = 0
        
        local function ClearESP()
            for p, d in pairs(RenderCache) do
                if d.bb then d.bb:Destroy() end
                if d.h then d.h:Destroy() end
                RenderCache[p] = nil
            end
        end
        
        local function UpdateESP()
            if not Config.ESP then ClearESP(); return end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local ch = p.Character
                    local h = ch:FindFirstChildOfClass("Humanoid")
                    local r = ch:FindFirstChild("HumanoidRootPart")
                    if h and h.Health > 0 and r then
                        if not RenderCache[p] then
                            local hd = ch:FindFirstChild("Head") or r
                            local bb = Instance.new("BillboardGui", hd)
                            bb.Size = UDim2.new(0, 200, 0, 200)
                            bb.AlwaysOnTop = true
                            local nm = Instance.new("TextLabel", bb)
                            nm.Size = UDim2.new(1, 0, 0, 20)
                            nm.Position = UDim2.new(0, 0, 0, -30)
                            nm.BackgroundTransparency = 1
                            nm.Font = Enum.Font.GothamBold
                            nm.TextSize = 12
                            nm.TextStrokeTransparency = 0.5
                            local ds = Instance.new("TextLabel", bb)
                            ds.Size = UDim2.new(1, 0, 0, 15)
                            ds.Position = UDim2.new(0, 0, 0, -15)
                            ds.BackgroundTransparency = 1
                            ds.TextColor3 = Color3.new(1, 1, 1)
                            ds.Font = Enum.Font.Gotham
                            ds.TextSize = 11
                            ds.TextStrokeTransparency = 0.5
                            local hl = Instance.new("Highlight", ch)
                            hl.FillTransparency = 1
                            hl.OutlineTransparency = 1
                            RenderCache[p] = {bb=bb, n=nm, d=ds, h=hl}
                        end
                        local d = RenderCache[p]
                        d.n.Text = p.Name
                        d.n.TextColor3 = Config.ESP_Color
                        d.n.Visible = Config.ESP_Name
                        d.d.Text = string.format("[%d m]", math.floor((Camera.CFrame.Position - r.Position).Magnitude))
                        d.d.Visible = Config.ESP_Dist
                        d.h.OutlineColor = Config.ESP_Color
                        d.h.FillColor = Config.ESP_Color
                        d.h.FillTransparency = Config.ESP_Transparency
                        d.h.Enabled = Config.ESP_Highlight
                    else
                        if RenderCache[p] then
                            RenderCache[p].bb:Destroy()
                            RenderCache[p].h:Destroy()
                            RenderCache[p] = nil
                        end
                    end
                end
            end
        end
        
        Connect(RunService.RenderStepped, function(dt)
            if Config.AimAssist then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local bestTarget, bestScore, bestDist = nil, 9999, 0
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local ch = p.Character
                        local h = ch:FindFirstChildOfClass("Humanoid")
                        local tp = ch:FindFirstChild(Config.TargetPart) or ch:FindFirstChild("Head")
                        if h and h.Health > 0 and tp then
                            local ignore = Config.TeamCheck and p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team
                            if not ignore then
                                local sp, onScreen = Camera:WorldToViewportPoint(tp.Position)
                                if onScreen then
                                    local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                    local worldDist = (Camera.CFrame.Position - tp.Position).Magnitude
                                    local score = (Config.Priority == 2) and worldDist or screenDist
                                    if screenDist <= Config.FOV and score < bestScore then
                                        local visible = true
                                        if Config.LOSCheck then
                                            local rp = RaycastParams.new()
                                            rp.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                                            rp.FilterType = Enum.RaycastFilterType.Exclude
                                            local hit = Workspace:Raycast(Camera.CFrame.Position, tp.Position - Camera.CFrame.Position, rp)
                                            visible = (hit and hit.Instance:IsDescendantOf(ch)) or not hit
                                        end
                                        if visible then
                                            bestScore = score
                                            bestTarget = tp
                                            bestDist = worldDist
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if bestTarget then
                    local targetPos = bestTarget.Position
                    if Config.AutoPredict and bestTarget.Parent:FindFirstChild("HumanoidRootPart") then
                        targetPos = targetPos + bestTarget.Parent.HumanoidRootPart.AssemblyLinearVelocity * 0.05
                    end
                    if Config.CameraLock then
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
                    else
                        local baseSmooth
                        if Config.LegitAim then
                            local s = math.clamp(Config.Smoothness, 1, 100)
                            baseSmooth = (1 - s / 100) * 0.85
                            baseSmooth = math.max(baseSmooth, 0.08)
                            if Config.DistSmooth then
                                baseSmooth = baseSmooth * (1 - math.clamp(bestDist / 500, 0, 0.8))
                            end
                            if Config.Humanize > 0 then
                                jitterT = jitterT + dt
                                targetPos = targetPos + Vector3.new(
                                    math.noise(jitterT * 2, 0) * (Config.Humanize * 0.2),
                                    math.noise(0, jitterT * 2) * (Config.Humanize * 0.2),
                                    0
                                )
                            end
                        else
                            baseSmooth = math.clamp(1 - Config.Smoothness / 100, 0.05, 0.95)
                        end
                        local smooth = SmartAim:GetSmoothFactor(dt, baseSmooth)
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), smooth)
                    end
                end
            end
            espAccum = espAccum + dt
            if espAccum >= 1/30 then
                UpdateESP()
                espAccum = 0
            end
        end)
        
        -- FPS Monitor
        task.spawn(function()
            while FH and FH.Parent do
                local t1 = tick()
                RunService.RenderStepped:Wait()
                local dt = tick() - t1
                local fps = math.floor(1 / math.max(dt, 0.001))
                local status = "HORRÍVEL"
                local color = C.Danger
                local pct = math.clamp(fps / 120, 0, 1)
                if fps >= 60 then status = "ULTRA"; color = C.Success
                elseif fps >= 40 then status = "BOM"; color = Color3.fromRGB(180, 255, 80)
                elseif fps >= 20 then status = "MÉDIO"; color = C.Warning end
                if FH and FH.Parent then
                    FHLabel.Text = string.format("FPS: %d", fps)
                    FHLabel.TextColor3 = color
                    FHStatus.Text = status
                    FHBarFill.Size = UDim2.new(pct, 0, 1, 0)
                    FHBarFill.BackgroundColor3 = color
                    FHStroke.Color = color
                end
            end
        end)
        
        -- ============ ENTRANCE ANIMATION ============
        MN.Visible = true
        BD.Visible = true
        BD.BackgroundTransparency = 1
        
        SwitchTab(1)
        
        TweenService:Create(BD, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.5}):Play()
        TweenService:Create(MNScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end)
    
    if success then
        print("[VOID HUB] Interface premium carregada.")
    else
        warn("[VOID HUB] ERRO UI: " .. tostring(err))
    end
end

PlayIntro(function() BuildUI() end)
