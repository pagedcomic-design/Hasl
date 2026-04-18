local repo = "https://github.com/pagedcomic-design/Hasl/blob/main/LinoriaLib/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Players_Service = game:GetService("Players")
local Run_Service = game:GetService("RunService")
local User_Input_Service = game:GetService("UserInputService")
local Local_Player = Players_Service.LocalPlayer
local Current_Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")

local Tracer_Container = CoreGui:FindFirstChild("Tracer_Overlay")
if Tracer_Container then Tracer_Container:Destroy() end

Tracer_Container = Instance.new("ScreenGui")
Tracer_Container.Name = "Tracer_Overlay"
Tracer_Container.DisplayOrder = 100
Tracer_Container.IgnoreGuiInset = true
Tracer_Container.Parent = CoreGui

local ESP_Config_Settings = {
Master_Enabled = false,
Lock_Tracer_Active = false,
Lock_Tracer_Core_Color = Color3.fromRGB(255, 255, 0),
Target_Hit_Part = "HumanoidRootPart",
Base_Tracer_Active = false,
Base_Tracer_Origin = "Bottom",
Base_Tracer_Core_Color = Color3.fromRGB(255, 100, 200),
Base_Tracer_Alpha = 1.0,
FOV_Visual_Enabled = false,
FOV_Circle_Radius = 110,
FOV_Color_Idle = Color3.fromRGB(255, 255, 255),
FOV_Color_Locked = Color3.fromRGB(255, 0, 100),
Main_Theme_Color = Color3.fromRGB(255, 100, 200),
Box_Shadow_Enabled = false,
Box_Shadow_Color = Color3.fromRGB(255, 100, 200),
Health_Segments_Count = 10,
Text_Pixel_Size = 13,
Bar_Side_Padding = 8,
Show_Preview_Window = false
}

local function Update_GUI_Line(Gui_Frame, Start_Pos, End_Pos, Thickness)
local Distance = (End_Pos - Start_Pos).Magnitude
Gui_Frame.Size = UDim2.fromOffset(Distance, Thickness)
Gui_Frame.Position = UDim2.fromOffset((Start_Pos.X + End_Pos.X) / 2, (Start_Pos.Y + End_Pos.Y) / 2)
Gui_Frame.Rotation = math.deg(math.atan2(End_Pos.Y - Start_Pos.Y, End_Pos.X - Start_Pos.X))
end

local Is_Mobile = User_Input_Service.TouchEnabled
local function Get_Target_Origin()
if Is_Mobile then return Current_Camera.ViewportSize / 2 end
return User_Input_Service:GetMouseLocation()
end

local function Calculate_Smooth_Health_Color(Ratio)
Ratio = math.clamp(Ratio, 0, 1)
if Ratio < 0.5 then
	return Color3.new(1, 0, 0):Lerp(Color3.new(1, 1, 0), Ratio * 2)
else
	return Color3.new(1, 1, 0):Lerp(Color3.new(0, 1, 0), (Ratio - 0.5) * 2)
end
end

local function Create_GUI_FOV(Name, Thickness, ZIndex)
local F = Instance.new("Frame")
F.Name = Name
F.AnchorPoint = Vector2.new(0.5, 0.5)
F.BackgroundTransparency = 1
F.ZIndex = ZIndex
F.Parent = Tracer_Container
local C = Instance.new("UICorner")
C.CornerRadius = UDim.new(1, 0)
C.Parent = F
local S = Instance.new("UIStroke")
S.Thickness = Thickness
S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
S.Parent = F
return F, S
end

local Global_FOV_Edge_Out, Global_FOV_Stroke_Out = Create_GUI_FOV("FOV_Out", 1, 100)
local Global_FOV_Main, Global_FOV_Stroke_Main = Create_GUI_FOV("FOV_Main", 1, 101)
local Global_FOV_Edge_In, Global_FOV_Stroke_In = Create_GUI_FOV("FOV_In", 1, 102)
Global_FOV_Stroke_Out.Color = Color3.new(0, 0, 0)
Global_FOV_Stroke_In.Color = Color3.new(0, 0, 0)

local ESP_Player_Controller = {}
local Active_ESP_Cache = {}
ESP_Player_Controller.__index = ESP_Player_Controller

function ESP_Player_Controller.Create_New_Instance(Target_Player)
	local Object = setmetatable({}, ESP_Player_Controller)
	Object.Player_Ref = Target_Player
	Object.Is_Targeted = false

	Object.Visual_Assets = {
	Lock_Line_Edge = Instance.new("Frame"),
	Lock_Line_Core = Instance.new("Frame"),
	Base_Line_Edge = Instance.new("Frame"),
	Base_Line_Core = Instance.new("Frame"),
	Box_Outer = Drawing.new("Square"),
	Box_Main = Drawing.new("Square"),
	Box_Inner = Drawing.new("Square"),
	Health_Outer = Drawing.new("Square"),
	Health_Chunks = {},
	Txt_Name = Drawing.new("Text"),
	Txt_Health = Drawing.new("Text"),
	Txt_Dist = Drawing.new("Text")
	}

	local Assets = Object.Visual_Assets
	local function Setup_GUI_Tracer(Frame, ZIndex)
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.BorderSizePixel = 0
	Frame.ZIndex = ZIndex
	Frame.Visible = false
	Frame.Parent = Tracer_Container
end
Setup_GUI_Tracer(Assets.Base_Line_Edge, 18); Assets.Base_Line_Edge.BackgroundColor3 = Color3.new(0,0,0)
Setup_GUI_Tracer(Assets.Base_Line_Core, 19); Assets.Base_Line_Core.BackgroundColor3 = ESP_Config_Settings.Base_Tracer_Core_Color
Setup_GUI_Tracer(Assets.Lock_Line_Edge, 20); Assets.Lock_Line_Edge.BackgroundColor3 = Color3.new(0,0,0)
Setup_GUI_Tracer(Assets.Lock_Line_Core, 21); Assets.Lock_Line_Core.BackgroundColor3 = ESP_Config_Settings.Lock_Tracer_Core_Color

Assets.Box_Outer.ZIndex = 4; Assets.Box_Outer.Filled = false; Assets.Box_Outer.Color = Color3.new(0, 0, 0); Assets.Box_Outer.Thickness = 1
Assets.Box_Main.ZIndex = 3; Assets.Box_Main.Filled = false; Assets.Box_Main.Thickness = 1
Assets.Box_Inner.ZIndex = 2; Assets.Box_Inner.Filled = false; Assets.Box_Inner.Color = Color3.new(0, 0, 0); Assets.Box_Inner.Thickness = 1
Assets.Health_Outer.ZIndex = 5; Assets.Health_Outer.Filled = false

for i = 1, ESP_Config_Settings.Health_Segments_Count do
	local Seg = Drawing.new("Square")
	Seg.Filled = true; Seg.Thickness = 0; Seg.ZIndex = 6; Seg.Visible = false
	table.insert(Assets.Health_Chunks, Seg)
end

local function Prepare_Text(Obj)
Obj.Size = ESP_Config_Settings.Text_Pixel_Size; Obj.Center = true; Obj.Outline = true; Obj.Font = 3
Obj.Color = Color3.new(1, 1, 1); Obj.ZIndex = 7; Obj.Visible = false
end
Prepare_Text(Assets.Txt_Name); Prepare_Text(Assets.Txt_Dist); Prepare_Text(Assets.Txt_Health)
Assets.Txt_Health.Center = false

return Object
end

function ESP_Player_Controller:Sync_Frame(Cursor_Pos, Screen_Center, Screen_Bottom, Screen_Top)
	local Character = self.Player_Ref.Character
	local Root_Part = Character and Character:FindFirstChild("HumanoidRootPart")
	local Aim_Part = Character and Character:FindFirstChild(ESP_Config_Settings.Target_Hit_Part)
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	if not (Root_Part and Aim_Part and Humanoid and Humanoid.Health > 0 and ESP_Config_Settings.Master_Enabled) then
		self:Toggle_Visibility(false); self.Is_Targeted = false; return
	end

	local Screen_Pos, On_View = Current_Camera:WorldToViewportPoint(Root_Part.Position)
	local Aim_Screen_Pos, _ = Current_Camera:WorldToViewportPoint(Aim_Part.Position)

	if not On_View then
		self:Toggle_Visibility(false); self.Is_Targeted = false; return
	end

	local UI = self.Visual_Assets
	local Target_Point_V2 = Vector2.new(Aim_Screen_Pos.X, Aim_Screen_Pos.Y)
	self.Is_Targeted = (Target_Point_V2 - Cursor_Pos).Magnitude <= ESP_Config_Settings.FOV_Circle_Radius

	if ESP_Config_Settings.Lock_Tracer_Active and self.Is_Targeted then
		UI.Lock_Line_Edge.Visible = true
		Update_GUI_Line(UI.Lock_Line_Edge, Cursor_Pos, Target_Point_V2, 3)
		UI.Lock_Line_Core.Visible = true
		Update_GUI_Line(UI.Lock_Line_Core, Cursor_Pos, Target_Point_V2, 1)
		UI.Lock_Line_Core.BackgroundColor3 = ESP_Config_Settings.Lock_Tracer_Core_Color
	else
		UI.Lock_Line_Edge.Visible = false; UI.Lock_Line_Core.Visible = false
	end

	local Head_Project = Current_Camera:WorldToViewportPoint(Root_Part.Position + Vector3.new(0, 3, 0))
	local Foot_Project = Current_Camera:WorldToViewportPoint(Root_Part.Position - Vector3.new(0, 3.5, 0))
	local Box_H = math.floor(math.abs(Head_Project.Y - Foot_Project.Y))
	local Box_W = math.floor(Box_H * 0.6)
	local Top_Left = Vector2.new(math.floor(Screen_Pos.X - Box_W/2), math.floor(Screen_Pos.Y - Box_H/2))
	local Box_Bottom_Point = Vector2.new(Screen_Pos.X, Top_Left.Y + Box_H)

	if ESP_Config_Settings.Base_Tracer_Active then
		local Origin = Screen_Bottom
		if ESP_Config_Settings.Base_Tracer_Origin == "Top" then Origin = Screen_Top
		elseif ESP_Config_Settings.Base_Tracer_Origin == "Center" then Origin = Screen_Center end
			UI.Base_Line_Edge.Visible = true
			Update_GUI_Line(UI.Base_Line_Edge, Origin, Box_Bottom_Point, 3)
			UI.Base_Line_Core.Visible = true
			Update_GUI_Line(UI.Base_Line_Core, Origin, Box_Bottom_Point, 1)
			UI.Base_Line_Core.BackgroundColor3 = ESP_Config_Settings.Base_Tracer_Core_Color
		else
			UI.Base_Line_Edge.Visible = false; UI.Base_Line_Core.Visible = false
		end

		UI.Box_Outer.Visible, UI.Box_Outer.Size, UI.Box_Outer.Position = true, Vector2.new(Box_W + 2, Box_H + 2), Top_Left - Vector2.new(1, 1)
		UI.Box_Main.Visible, UI.Box_Main.Size, UI.Box_Main.Position = true, Vector2.new(Box_W, Box_H), Top_Left
		UI.Box_Main.Color = ESP_Config_Settings.Main_Theme_Color
		UI.Box_Inner.Visible, UI.Box_Inner.Size, UI.Box_Inner.Position = true, Vector2.new(Box_W - 2, Box_H - 2), Top_Left + Vector2.new(1, 1)

		local HP_Ratio = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
		local Bar_X = Top_Left.X - ESP_Config_Settings.Bar_Side_Padding
		UI.Health_Outer.Visible, UI.Health_Outer.Size, UI.Health_Outer.Position = true, Vector2.new(5, Box_H + 2), Vector2.new(Bar_X - 1, Top_Left.Y - 1)

		local Chunk_Height = Box_H / ESP_Config_Settings.Health_Segments_Count
		for i = 1, ESP_Config_Settings.Health_Segments_Count do
			local Chunk = UI.Health_Chunks[i]
			local Threshold = i / ESP_Config_Settings.Health_Segments_Count
			if HP_Ratio >= (Threshold - (1/ESP_Config_Settings.Health_Segments_Count)) then
				Chunk.Visible = true; Chunk.Position = Vector2.new(Bar_X, Top_Left.Y + (Box_H - (i * Chunk_Height)))
				Chunk.Size = Vector2.new(3, math.ceil(Chunk_Height)); Chunk.Color = Calculate_Smooth_Health_Color(Threshold)
			else Chunk.Visible = false end
			end

			UI.Txt_Name.Visible, UI.Txt_Name.Text, UI.Txt_Name.Position = true, self.Player_Ref.Name, Top_Left + Vector2.new(Box_W/2, -18)
			local Dist_Num = math.floor((Current_Camera.CFrame.Position - Root_Part.Position).Magnitude)
			UI.Txt_Dist.Visible, UI.Txt_Dist.Text, UI.Txt_Dist.Position = true, Dist_Num.."st", Top_Left + Vector2.new(Box_W/2, Box_H + 5)
			UI.Txt_Health.Visible, UI.Txt_Health.Text, UI.Txt_Health.Color = true, tostring(math.floor(Humanoid.Health)), Calculate_Smooth_Health_Color(HP_Ratio)
			UI.Txt_Health.Position = Vector2.new(Bar_X - 22, Top_Left.Y)
		end

		function ESP_Player_Controller:Toggle_Visibility(State)
			for Key, Assets in pairs(self.Visual_Assets) do
				if Key == "Health_Chunks" then for _, C in ipairs(Assets) do C.Visible = State end
			else Assets.Visible = State end
			end
		end

		function ESP_Player_Controller:Cleanup()
			for Key, Assets in pairs(self.Visual_Assets) do
				if Key == "Health_Chunks" then for _, C in ipairs(Assets) do C:Remove() end
			elseif typeof(Assets) == "Instance" then Assets:Destroy()
			else Assets:Remove() end
			end
		end

		
		local PreviewWindow = nil
		local PreviewConn = nil

		local function CreatePreviewWindow()
		if PreviewWindow then return end

		local MainOuter = Library.Window.Holder

		
		PreviewWindow = Instance.new("Frame")
		PreviewWindow.Name = "ESP_Preview_Window"
		PreviewWindow.BackgroundColor3 = Color3.new(0, 0, 0)
		PreviewWindow.BorderSizePixel = 0
		PreviewWindow.Size = UDim2.new(0, 220, 0, 320)
		PreviewWindow.ZIndex = 1
		PreviewWindow.Parent = MainOuter.Parent

		local Inner = Instance.new("Frame")
		Inner.BackgroundColor3 = Library.MainColor
		Inner.BorderColor3 = Library.AccentColor
		Inner.BorderMode = Enum.BorderMode.Inset
		Inner.Position = UDim2.new(0, 1, 0, 1)
		Inner.Size = UDim2.new(1, -2, 1, -2)
		Inner.Parent = PreviewWindow

		local Title = Instance.new("TextLabel")
		Title.Text = "视觉预览"
		Title.Size = UDim2.new(1, 0, 0, 25)
		Title.BackgroundTransparency = 1
		Title.TextColor3 = Color3.new(1, 1, 1)
		Title.Font = Enum.Font.Code
		Title.TextSize = 14
		Title.Parent = Inner

		local ContentArea = Instance.new("Frame")
		ContentArea.BackgroundColor3 = Library.BackgroundColor
		ContentArea.BorderColor3 = Library.OutlineColor
		ContentArea.Position = UDim2.new(0, 6, 0, 25)
		ContentArea.Size = UDim2.new(1, -12, 1, -31)
		ContentArea.Parent = Inner

		local ContentInner = Instance.new("Frame")
		ContentInner.BackgroundColor3 = Library.BackgroundColor
		ContentInner.BorderColor3 = Color3.new(0, 0, 0)
		ContentInner.BorderMode = Enum.BorderMode.Inset
		ContentInner.Size = UDim2.new(1, 0, 1, 0)
		ContentInner.Parent = ContentArea

		
		local Viewport = Instance.new("ViewportFrame")
		Viewport.Size = UDim2.new(1, -10, 1, -10)
		Viewport.Position = UDim2.new(0, 5, 0, 5)
		Viewport.BackgroundTransparency = 1
		Viewport.Ambient = Color3.fromRGB(160, 160, 160)
		Viewport.LightColor = Color3.new(1, 1, 1)
		Viewport.Parent = ContentInner

		local WorldModel = Instance.new("WorldModel")
		WorldModel.Parent = Viewport

		local Camera = Instance.new("Camera")
		Camera.FieldOfView = 50
		Camera.CFrame = CFrame.new(Vector3.new(0, 0, 12), Vector3.new(0, 0, 0))
		Camera.Parent = Viewport
		Viewport.CurrentCamera = Camera

		
		local Model = Instance.new("Model")
		local function CreatePart(Name, Size, Pos)
		local P = Instance.new("Part")
		P.Name = Name; P.Size = Size; P.CFrame = CFrame.new(Pos); P.Color = Color3.fromRGB(180, 180, 180); P.Parent = Model

		local Line = Instance.new("SelectionBox")
		Line.Adornee = P
		Line.Color3 = Color3.new(0, 0, 0)
		Line.LineThickness = 0.15
		Line.Transparency = 0
		Line.SurfaceTransparency = 1
		Line.Parent = P

		return P
	end
	CreatePart("HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0))
	CreatePart("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 1.6, 0))
	CreatePart("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 0, 0))
	CreatePart("Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 0, 0))
	CreatePart("Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 0, 0))
	CreatePart("Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, -2, 0))
	CreatePart("Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, -2, 0))
	Model.Parent = WorldModel

	
	local Overlay = Instance.new("CanvasGroup")
	Overlay.Size = UDim2.new(1, 0, 1, 0)
	Overlay.BackgroundTransparency = 1
	Overlay.Parent = Viewport

	local B_Box = Instance.new("Frame")
	B_Box.Size = UDim2.fromOffset(115, 170)
	B_Box.Position = UDim2.new(0.5, -57.5, 0.5, -85)
	B_Box.BackgroundTransparency = 1
	B_Box.Parent = Overlay

	local B_Stroke = Instance.new("UIStroke")
	B_Stroke.Thickness = 1
	B_Stroke.Color = ESP_Config_Settings.Main_Theme_Color
	B_Stroke.Parent = B_Box

	local B_HP_BG = Instance.new("Frame")
	B_HP_BG.Size = UDim2.fromOffset(3, 170)
	B_HP_BG.Position = UDim2.new(0.5, -68, 0.5, -85)
	B_HP_BG.BackgroundColor3 = Color3.new(0, 0, 0)
	B_HP_BG.BorderSizePixel = 0
	B_HP_BG.Parent = Overlay

	local B_HP = Instance.new("Frame")
	B_HP.Size = UDim2.new(1, 0, 0.85, 0)
	B_HP.Position = UDim2.new(0, 0, 0.15, 0)
	B_HP.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	B_HP.BorderSizePixel = 0
	B_HP.Parent = B_HP_BG

	local B_Name = Instance.new("TextLabel")
	B_Name.Text = "dummy"
	B_Name.Size = UDim2.new(1, 0, 0, 20)
	B_Name.Position = UDim2.new(0, 0, 0.5, -110)
	B_Name.BackgroundTransparency = 1
	B_Name.TextColor3 = Color3.new(1, 1, 1)
	B_Name.Font = Enum.Font.Code
	B_Name.TextSize = 10
	B_Name.Parent = Overlay

	local B_Dist = Instance.new("TextLabel")
	B_Dist.Text = "100st"
	B_Dist.Size = UDim2.new(1, 0, 0, 20)
	B_Dist.Position = UDim2.new(0, 0, 0.5, 92)
	B_Dist.BackgroundTransparency = 1
	B_Dist.TextColor3 = Color3.new(1, 1, 1)
	B_Dist.Font = Enum.Font.Code
	B_Dist.TextSize = 10
	B_Dist.Parent = Overlay

	
	PreviewConn = Run_Service.RenderStepped:Connect(function()
	if not MainOuter or not MainOuter.Parent then return end
	PreviewWindow.Visible = MainOuter.Visible and ESP_Config_Settings.Show_Preview_Window
	PreviewWindow.Position = MainOuter.Position + UDim2.fromOffset(MainOuter.AbsoluteSize.X, 0)

	B_Stroke.Color = ESP_Config_Settings.Main_Theme_Color
	Overlay.Visible = ESP_Config_Settings.Master_Enabled
end)
end

local function CleanupPreviewWindow()
if PreviewConn then PreviewConn:Disconnect(); PreviewConn = nil end
if PreviewWindow then PreviewWindow:Destroy(); PreviewWindow = nil end
end

local Window = Library:CreateWindow({
Title = "ESP 控制面板",
Center = true,
AutoShow = true,
Resizable = true,
ShowCustomCursor = true,
NotifySide = "Left",
TabPadding = 1,
MenuFadeTime = 0.2
})

local Tabs = {
Main = Window:AddTab("Main"),
["UI Settings"] = Window:AddTab("UI Settings"),
}

local ESPGroup = Tabs.Main:AddLeftGroupbox("ESP 主设置")
local VisualGroup = Tabs.Main:AddRightGroupbox("视觉外观")

ESPGroup:AddToggle("ESPMaster", {
Text = "开启 ESP",
Default = false,
Callback = function(Value) ESP_Config_Settings.Master_Enabled = Value end
})

ESPGroup:AddToggle("ESPTracer", {
Text = "开启 追踪线",
Default = false,
Callback = function(Value) ESP_Config_Settings.Base_Tracer_Active = Value end
}):AddColorPicker("TracerColor", {
Default = ESP_Config_Settings.Base_Tracer_Core_Color,
Title = "预览线颜色",
Callback = function(Value) ESP_Config_Settings.Base_Tracer_Core_Color = Value end
})

ESPGroup:AddDropdown("TracerOrigin", {
Values = { "Top", "Center", "Bottom" },
Default = 3,
Multi = false,
Text = "追踪线起点",
Callback = function(Value) ESP_Config_Settings.Base_Tracer_Origin = Value end
})

ESPGroup:AddToggle("ESPLockTracer", {
Text = "开启 锁定线",
Default = false,
Callback = function(Value) ESP_Config_Settings.Lock_Tracer_Active = Value end
}):AddColorPicker("LockTracerColor", {
Default = ESP_Config_Settings.Lock_Tracer_Core_Color,
Title = "锁定线颜色",
Callback = function(Value) ESP_Config_Settings.Lock_Tracer_Core_Color = Value end
})

VisualGroup:AddToggle("ESPFov", {
Text = "显示 FOV 圆环",
Default = false,
Callback = function(Value) ESP_Config_Settings.FOV_Visual_Enabled = Value end
}):AddColorPicker("FovColor", {
Default = ESP_Config_Settings.FOV_Color_Idle,
Title = "FOV 颜色",
Callback = function(Value) ESP_Config_Settings.FOV_Color_Idle = Value end
})

VisualGroup:AddSlider("FovRadius", {
Text = "FOV 半径",
Default = 110,
Min = 10,
Max = 800,
Rounding = 0,
Callback = function(Value) ESP_Config_Settings.FOV_Circle_Radius = Value end
})

VisualGroup:AddLabel("框颜色"):AddColorPicker("BoxColor", {
Default = ESP_Config_Settings.Main_Theme_Color,
Title = "透视框颜色",
Callback = function(Value) ESP_Config_Settings.Main_Theme_Color = Value end
})

VisualGroup:AddToggle("ShowPrevUI", {
Text = "辅助调节预览面板",
Default = false,
Callback = function(Value)
ESP_Config_Settings.Show_Preview_Window = Value
if Value then CreatePreviewWindow() else CleanupPreviewWindow() end
end
})

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("菜单设置")
MenuGroup:AddButton("卸载脚本", function() Library:Unload() end)
MenuGroup:AddLabel("菜单键位"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder("MyESPConfig")
SaveManager:SetFolder("MyESPConfig/Game")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

local function Initial_Setup_Player(P)
if P ~= Local_Player then Active_ESP_Cache[P] = ESP_Player_Controller.Create_New_Instance(P) end
end

local PlayerAddedConn = Players_Service.PlayerAdded:Connect(Initial_Setup_Player)
local PlayerRemovingConn = Players_Service.PlayerRemoving:Connect(function(P)
if Active_ESP_Cache[P] then Active_ESP_Cache[P]:Cleanup(); Active_ESP_Cache[P] = nil end
end)

for _, P in ipairs(Players_Service:GetPlayers()) do Initial_Setup_Player(P) end

local RenderConnection = Run_Service.RenderStepped:Connect(function()
local Target_Pos = Get_Target_Origin()
local Screen_Res = Current_Camera.ViewportSize
local Center_V2 = Screen_Res / 2
local Bottom_V2 = Vector2.new(Center_V2.X, Screen_Res.Y)
local Top_V2 = Vector2.new(Center_V2.X, 0)
local Global_Lock_Found = false

for _, ESP in pairs(Active_ESP_Cache) do
	local success, _ = pcall(function()
	ESP:Sync_Frame(Target_Pos, Center_V2, Bottom_V2, Top_V2)
end)
if not success and ESP.Player_Ref then
	ESP:Cleanup()
	Active_ESP_Cache[ESP.Player_Ref] = nil
end
if ESP.Is_Targeted then Global_Lock_Found = true end
end

if ESP_Config_Settings.FOV_Visual_Enabled then
	local Target_Color = Global_Lock_Found and ESP_Config_Settings.FOV_Color_Locked or ESP_Config_Settings.FOV_Color_Idle
	local Radius = ESP_Config_Settings.FOV_Circle_Radius
	local Pos = UDim2.fromOffset(Target_Pos.X, Target_Pos.Y)

	local function Sync_FOV_Layer(Frame, Stroke, R, Color)
	Frame.Visible, Frame.Size, Frame.Position = true, UDim2.fromOffset(R * 2, R * 2), Pos
	Stroke.Color = Color; Stroke.Transparency = 0
end

Sync_FOV_Layer(Global_FOV_Edge_Out, Global_FOV_Stroke_Out, Radius + 1, Color3.new(0,0,0))
Sync_FOV_Layer(Global_FOV_Main, Global_FOV_Stroke_Main, Radius, Target_Color)
Sync_FOV_Layer(Global_FOV_Edge_In, Global_FOV_Stroke_In, Radius - 1, Color3.new(0,0,0))
else
	Global_FOV_Edge_Out.Visible = false; Global_FOV_Main.Visible = false; Global_FOV_Edge_In.Visible = false
end
end)

Library:OnUnload(function()
RenderConnection:Disconnect()
PlayerAddedConn:Disconnect()
PlayerRemovingConn:Disconnect()
for _, ESP in pairs(Active_ESP_Cache) do ESP:Cleanup() end
CleanupPreviewWindow()
if Tracer_Container then Tracer_Container:Destroy() end
print("ESP Unloaded!")
Library.Unloaded = true
end)

SaveManager:LoadAutoloadConfig()
