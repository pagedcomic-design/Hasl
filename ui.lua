repeat
    task.wait()
until game:IsLoaded()

local library = {}

local ToggleUI = false
library.currentTab = nil
library.flags = {}

local services = setmetatable({}, {
    __index = function(t, k)
        return game.GetService(game, k)
    end
})

local mouse = services.Players.LocalPlayer:GetMouse()
local UDim2_new = UDim2.new
local Color3_fromRGB = Color3.fromRGB
local Color3_fromHSV = Color3.fromHSV
local Color3_new = Color3.new
local Instance_new = Instance.new

function Tween(obj, t, data)
    services.TweenService:Create(obj, TweenInfo.new(t[1], Enum.EasingStyle[t[2]], Enum.EasingDirection[t[3]]), data)
        :Play()
    return true
end

function Ripple(obj)
    task.spawn(function()
        if obj.ClipsDescendants ~= true then
            obj.ClipsDescendants = true
        end
        local Ripple = Instance_new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
        Ripple.BackgroundTransparency = 1.000
        Ripple.ZIndex = 8
        Ripple.Image = "rbxassetid://2708891598"
        Ripple.ImageTransparency = 0.800
        Ripple.ScaleType = Enum.ScaleType.Fit
        Ripple.ImageColor3 = Color3_fromRGB(255, 255, 255)
        Ripple.Position = UDim2_new((mouse.X - Ripple.AbsolutePosition.X) / obj.AbsoluteSize.X, 0,
            (mouse.Y - Ripple.AbsolutePosition.Y) / obj.AbsoluteSize.Y, 0)
        Tween(Ripple, {.3, 'Linear', 'InOut'}, {
            Position = UDim2_new(-5.5, 0, -5.5, 0),
            Size = UDim2_new(12, 0, 12, 0)
        })
        task.wait(0.15)
        Tween(Ripple, {.3, 'Linear', 'InOut'}, {
            ImageTransparency = 1
        })
        task.wait(.3)
        Ripple:Destroy()
    end)
end

local toggled = false

-- # Switch Tabs # --
local switchingTabs = false
function switchTab(new)
    if switchingTabs then
        return
    end
    local old = library.currentTab
    if old == nil then
        new[2].Visible = true
        library.currentTab = new
        services.TweenService:Create(new[1], TweenInfo.new(0.1), {
            ImageTransparency = 0
        }):Play()
        services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), {
            TextTransparency = 0
        }):Play()
        return
    end

    if old[1] == new[1] then
        return
    end
    switchingTabs = true
    library.currentTab = new

    services.TweenService:Create(old[1], TweenInfo.new(0.1), {
        ImageTransparency = 0.2
    }):Play()
    services.TweenService:Create(new[1], TweenInfo.new(0.1), {
        ImageTransparency = 0
    }):Play()
    services.TweenService:Create(old[1].TabText, TweenInfo.new(0.1), {
        TextTransparency = 0.2
    }):Play()
    services.TweenService:Create(new[1].TabText, TweenInfo.new(0.1), {
        TextTransparency = 0
    }):Play()

    old[2].Visible = false
    new[2].Visible = true

    task.wait(0.1)

    switchingTabs = false
end

-- # Drag, Stolen from Kiriot or Wally # --
function drag(frame, hold)
    if not hold then
        hold = frame
    end
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2_new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
            startPos.Y.Offset + delta.Y)
    end

    hold.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function library.new(library, name, theme)
    for _, v in next, services.CoreGui:GetChildren() do
        if v.Name == "frosty is cute" then
            v:Destroy()
        end
    end
    local MainColor = Color3_fromRGB(37, 37, 37)
    local Background = Color3_fromRGB(42, 42, 42)
    local zyColor = Color3_fromRGB(255, 255, 255)
    local beijingColor = Color3_fromRGB(57, 57, 57)
  
    local dogent = Instance_new("ScreenGui")
    dogent.IgnoreGuiInset = true
    dogent.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance_new("Frame")
    local TabMain = Instance_new("Frame")
    local MainC = Instance_new("UICorner")
    local SB = Instance_new("Frame")
    local SBC = Instance_new("UICorner")
    local Side = Instance_new("Frame")
    local SideG = Instance_new("UIGradient")
    local TabBtns = Instance_new("ScrollingFrame")
    local TabBtnsL = Instance_new("UIListLayout")
    local ScriptTitle = Instance_new("TextLabel")
    local SBG = Instance_new("UIGradient")
    local Open = Instance_new("TextButton")
    local UIG = Instance_new("UIGradient")
    local DropShadowHolder = Instance_new("Frame")
    local DropShadow = Instance_new("ImageLabel")
    local UICornerMain = Instance_new("UICorner")
    local UIGradient = Instance_new("UIGradient")
    local UIGradientTitle = Instance_new("UIGradient")

    -- Floating Color Picker Shared Logic
    local ColorPickerPopup = Instance_new("Frame")
    local ColorPickerMask = Instance_new("TextButton")
    local CurrentCP_H, CurrentCP_S, CurrentCP_V = 0, 0, 0
    local CurrentCP_Flag = nil
    local CurrentCP_Callback = nil
    local OriginalCP_Color = nil
    local CP_Open = false
    local IsDraggingPicker = false





    ColorPickerMask.Name = "ColorPickerMask"
    ColorPickerMask.Size = UDim2_new(10, 0, 10, 0)
    ColorPickerMask.Position = UDim2_new(-5, 0, -5, 0)
    ColorPickerMask.BackgroundTransparency = 1
    ColorPickerMask.Visible = false
    ColorPickerMask.ZIndex = 999990
    ColorPickerMask.Parent = dogent

    ColorPickerPopup.Name = "ColorPickerPopup"
    ColorPickerPopup.BackgroundColor3 = Background
    ColorPickerPopup.BorderColor3 = MainColor
    ColorPickerPopup.BorderSizePixel = 1
    ColorPickerPopup.Size = UDim2_new(0, 240, 0, 250)
    ColorPickerPopup.Visible = false
    ColorPickerPopup.ZIndex = 999991
    local CPC = Instance_new("UICorner")
    CPC.CornerRadius = UDim.new(0, 6)
    CPC.Parent = ColorPickerPopup
    ColorPickerPopup.Parent = dogent
    drag(ColorPickerPopup, ColorPickerPopup)

    local CP_Header = Instance_new("Frame")
    CP_Header.Size = UDim2_new(1, 0, 0, 28)
    CP_Header.BackgroundTransparency = 1
    CP_Header.ZIndex = 999992
    CP_Header.Parent = ColorPickerPopup

    local CP_Title = Instance_new("TextLabel")
    CP_Title.Size = UDim2_new(1, 0, 1, 0)
    CP_Title.BackgroundTransparency = 1
    CP_Title.Font = Enum.Font.GothamSemibold
    CP_Title.Text = "色彩选择 / Color Picker"
    CP_Title.TextColor3 = zyColor
    CP_Title.TextSize = 14
    CP_Title.ZIndex = 999993
    CP_Title.Parent = CP_Header

    local SVMap = Instance_new("Frame")
    SVMap.Position = UDim2_new(0, 10, 0, 35)
    SVMap.Size = UDim2_new(0, 220, 0, 130)
    SVMap.ZIndex = 999992
    local SVMC = Instance_new("UICorner")
    SVMC.CornerRadius = UDim.new(0, 6)
    SVMC.Parent = SVMap
    SVMap.Parent = ColorPickerPopup
    
    local SatGFrame = Instance_new("Frame")
    SatGFrame.Size = UDim2_new(1, 0, 1, 0)
    SatGFrame.BackgroundColor3 = zyColor
    SatGFrame.ZIndex = 999993
    local SatG = Instance_new("UIGradient")
    SatG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
    SatG.Parent = SatGFrame
    local SGFC = Instance_new("UICorner")
    SGFC.CornerRadius = UDim.new(0, 6)
    SGFC.Parent = SatGFrame
    SatGFrame.Parent = SVMap

    local ValGFrame = Instance_new("Frame")
    ValGFrame.Size = UDim2_new(1, 0, 1, 0)
    ValGFrame.BackgroundColor3 = Color3_new(0,0,0)
    ValGFrame.ZIndex = 999994
    local ValG = Instance_new("UIGradient")
    ValG.Rotation = 90
    ValG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
    ValG.Parent = ValGFrame
    local VGFC = Instance_new("UICorner")
    VGFC.CornerRadius = UDim.new(0, 6)
    VGFC.Parent = ValGFrame
    ValGFrame.Parent = SVMap
    
    local SVBtn = Instance_new("TextButton")
    SVBtn.Size = UDim2_new(1, 0, 1, 0)
    SVBtn.BackgroundTransparency = 1
    SVBtn.Text = ""
    SVBtn.ZIndex = 999995
    SVBtn.Parent = SVMap

    local SVPointer = Instance_new("Frame")
    local SVPointerC = Instance_new("UICorner")
    local SVPointerStroke = Instance_new("UIStroke")

    SVPointer.Name = "SVPointer"
    SVPointer.Size = UDim2_new(0, 10, 0, 10)
    SVPointer.AnchorPoint = Vector2.new(0.5, 0.5)
    SVPointer.BackgroundColor3 = Color3_new(1, 1, 1)
    SVPointer.ZIndex = 999999
    SVPointer.Parent = SVMap

    SVPointerC.CornerRadius = UDim.new(1, 0)
    SVPointerC.Parent = SVPointer

    SVPointerStroke.Thickness = 1.5
    SVPointerStroke.Color = Color3_new(0, 0, 0)
    SVPointerStroke.Parent = SVPointer


    local HueSlider = Instance_new("Frame")
    HueSlider.Position = UDim2_new(0, 10, 0, 175)
    HueSlider.Size = UDim2_new(0, 220, 0, 20)
    HueSlider.ZIndex = 999992
    local HSC = Instance_new("UICorner")
    HSC.CornerRadius = UDim.new(0, 4)
    HSC.Parent = HueSlider
    local HueG = Instance_new("UIGradient")
    HueG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3_fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.16, Color3_fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3_fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3_fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.66, Color3_fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3_fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3_fromRGB(255, 0, 0))
    })
    HueG.Parent = HueSlider
    HueSlider.Parent = ColorPickerPopup

    local HueBtn = Instance_new("TextButton")
    HueBtn.Size = UDim2_new(1, 0, 1, 0)
    HueBtn.BackgroundTransparency = 1
    HueBtn.Text = ""
    HueBtn.ZIndex = 999995
    HueBtn.Parent = HueSlider

    local HuePointer = Instance_new("Frame")

    HuePointer.Size = UDim2_new(0, 4, 1, 4)
    HuePointer.Position = UDim2_new(0, 0, 0.5, 0)
    HuePointer.AnchorPoint = Vector2.new(0.5, 0.5)
    HuePointer.BackgroundColor3 = zyColor
    HuePointer.ZIndex = 999993
    local HPC = Instance_new("UICorner")
    HPC.CornerRadius = UDim.new(0, 2)
    HPC.Parent = HuePointer
    HuePointer.Parent = HueSlider

    local CP_Btns = Instance_new("Frame")
    CP_Btns.Position = UDim2_new(0, 10, 0, 205)
    CP_Btns.Size = UDim2_new(0, 220, 0, 35)
    CP_Btns.BackgroundTransparency = 1
    CP_Btns.ZIndex = 999992
    CP_Btns.Parent = ColorPickerPopup

    local ConfirmBtn = Instance_new("TextButton")
    ConfirmBtn.Size = UDim2_new(0.5, -5, 1, 0)
    ConfirmBtn.BackgroundColor3 = beijingColor
    ConfirmBtn.Font = Enum.Font.GothamSemibold
    ConfirmBtn.Text = "确定 / OK"
    ConfirmBtn.TextColor3 = zyColor
    ConfirmBtn.TextSize = 12
    ConfirmBtn.ZIndex = 999993
    local CBC1 = Instance_new("UICorner")
    CBC1.CornerRadius = UDim.new(0, 6)
    CBC1.Parent = ConfirmBtn
    ConfirmBtn.Parent = CP_Btns

    local CancelBtn = Instance_new("TextButton")
    CancelBtn.Position = UDim2_new(0.5, 5, 0, 0)
    CancelBtn.Size = UDim2_new(0.5, -5, 1, 0)
    CancelBtn.BackgroundColor3 = Color3_fromRGB(45, 45, 45)
    CancelBtn.Font = Enum.Font.GothamSemibold
    CancelBtn.Text = "取消 / Cancel"
    CancelBtn.TextColor3 = Color3_fromRGB(255, 100, 100)
    CancelBtn.TextSize = 12
    CancelBtn.ZIndex = 999993
    local CBC2 = Instance_new("UICorner")
    CBC2.CornerRadius = UDim.new(0, 6)
    CBC2.Parent = CancelBtn
    CancelBtn.Parent = CP_Btns


    local function updateCP()
        local color = Color3_fromHSV(CurrentCP_H, CurrentCP_S, CurrentCP_V)
        SVMap.BackgroundColor3 = Color3_fromHSV(CurrentCP_H, 1, 1)
        SVPointer.Position = UDim2_new(math.clamp(CurrentCP_S, 0, 1), 0, math.clamp(1 - CurrentCP_V, 0, 1), 0)
        HuePointer.Position = UDim2_new(math.clamp(CurrentCP_H, 0, 1), 0, 0.5, 0)
        task.spawn(function()
            if CurrentCP_Callback then
                CurrentCP_Callback(color)
            end
        end)
    end



    local draggingSV = false
    SVBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = true
            IsDraggingPicker = true
        end
    end)
    local draggingHue = false
    HueBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            IsDraggingPicker = true
        end
    end)
    services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSV = false
            draggingHue = false
            task.delay(0.1, function()
                IsDraggingPicker = false
            end)
        end
    end)

    services.UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            if draggingSV then
                local r = SVMap.AbsoluteSize
                local p = SVMap.AbsolutePosition
                CurrentCP_S = math.clamp((input.Position.X - p.X) / r.X, 0, 1)
                CurrentCP_V = math.clamp(1 - ((input.Position.Y - p.Y) / r.Y), 0, 1)
                updateCP()
            elseif draggingHue then
                local r = HueSlider.AbsoluteSize
                local p = HueSlider.AbsolutePosition
                CurrentCP_H = math.clamp((input.Position.X - p.X) / r.X, 0, 1)
                updateCP()
            end
        end
    end)

    local function closeCP(apply)
        if IsDraggingPicker then return end
        ColorPickerPopup.Visible = false
        ColorPickerMask.Visible = false
        if apply and CurrentCP_Callback then
            local color = Color3_fromHSV(CurrentCP_H, CurrentCP_S, CurrentCP_V)
            library.flags[CurrentCP_Flag] = color
            CurrentCP_Callback(color)
        elseif not apply and CurrentCP_Callback then
            library.flags[CurrentCP_Flag] = OriginalCP_Color
            CurrentCP_Callback(OriginalCP_Color)
        end
        CP_Open = false
    end

    ConfirmBtn.MouseButton1Click:Connect(function() closeCP(true) end)
    CancelBtn.MouseButton1Click:Connect(function() closeCP(false) end)
    ColorPickerMask.MouseButton1Down:Connect(function() 
        if not IsDraggingPicker then
            closeCP(false) 
        end
    end)



    if syn and syn.protect_gui then
        syn.protect_gui(dogent)
    end

    dogent.Name = "frosty is cute"
    dogent.Parent = services.CoreGui

    function UiDestroy()
        dogent:Destroy()
    end

    function ToggleUILib()
        if not ToggleUI then
            dogent.Enabled = false
            ToggleUI = true
        else
            ToggleUI = false
            dogent.Enabled = true
        end
    end

    Main.Name = "Main"
    Main.Parent = dogent
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Background
    Main.BorderColor3 = MainColor
    Main.Position = UDim2_new(0.5, 0, 0.5, 0)
    Main.Size = UDim2_new(0, 572, 0, 353)
    Main.ZIndex = 1
    Main.Active = true
    Main.Draggable = true
    services.UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            if Main.Visible == true then
                Main.Visible = false
            else
                Main.Visible = true
            end
        end
    end)
    drag(Main)

    UICornerMain.Parent = Main
    UICornerMain.CornerRadius = UDim.new(0, 3)

    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = Main
    DropShadowHolder.BackgroundTransparency = 1.000
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.Size = UDim2_new(1, 0, 1, 0)
    DropShadowHolder.BorderColor3 = Color3_fromRGB(255, 255, 255)
    DropShadowHolder.ZIndex = 0

    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1.000
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2_new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2_new(1, 43, 1, 43)
    DropShadow.ZIndex = 0
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3_fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.500
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

    function toggleui()
        toggled = not toggled
        task.spawn(function()
            if toggled then
                task.wait(0.3)
            end
        end)
        Tween(Main, {0.3, 'Sine', 'InOut'}, {
            Size = UDim2_new(0, 609, 0, (toggled and 505 or 0))
        })
    end

    TabMain.Name = "TabMain"
    TabMain.Parent = Main
    TabMain.BackgroundColor3 = MainColor
    TabMain.BackgroundTransparency = 1.000
    TabMain.Position = UDim2_new(0.217000037, 0, 0, 3)
    TabMain.Size = UDim2_new(0, 448, 0, 353)

    MainC.CornerRadius = UDim.new(0, 5.5)
    MainC.Name = "MainC"
    MainC.Parent = Main

    SB.Name = "SB"
    SB.Parent = Main
    SB.BackgroundColor3 = Background
    SB.BorderColor3 = MainColor
    SB.Size = UDim2_new(0, 8, 0, 353)

    SBC.CornerRadius = UDim.new(0, 6)
    SBC.Name = "SBC"
    SBC.Parent = SB

    Side.Name = "Side"
    Side.Parent = SB
    Side.BackgroundColor3 = Background
    Side.BorderColor3 = Background
    Side.BorderSizePixel = 0
    Side.ClipsDescendants = true
    Side.Position = UDim2_new(1, 0, 0, 0)
    Side.Size = UDim2_new(0, 110, 0, 353)

    SideG.Color = ColorSequence.new {ColorSequenceKeypoint.new(0.00, zyColor), ColorSequenceKeypoint.new(1.00, zyColor)}
    SideG.Rotation = 90
    SideG.Name = "SideG"
    SideG.Parent = Side

    TabBtns.Name = "TabBtns"
    TabBtns.Parent = Side
    TabBtns.Active = true
    TabBtns.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    TabBtns.BackgroundTransparency = 1.000
    TabBtns.BorderSizePixel = 0
    TabBtns.Position = UDim2_new(0, 0, 0.0973535776, 0)
    TabBtns.Size = UDim2_new(0, 110, 0, 318)
    TabBtns.CanvasSize = UDim2_new(0, 0, 1, 0)
    TabBtns.ScrollBarThickness = 0

    TabBtnsL.Name = "TabBtnsL"
    TabBtnsL.Parent = TabBtns
    TabBtnsL.SortOrder = Enum.SortOrder.LayoutOrder
    TabBtnsL.Padding = UDim.new(0, 12)

    ScriptTitle.Name = "ScriptTitle"
    ScriptTitle.Parent = Side
    ScriptTitle.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    ScriptTitle.BackgroundTransparency = 1.000
    ScriptTitle.Position = UDim2_new(0, 0, 0.00953488424, 0)
    ScriptTitle.Size = UDim2_new(0, 102, 0, 20)
    ScriptTitle.Font = Enum.Font.GothamSemibold
    ScriptTitle.Text = name
    ScriptTitle.TextColor3 = Color3_fromRGB(255, 255, 255)
    ScriptTitle.TextSize = 14.000
    ScriptTitle.TextScaled = true
    ScriptTitle.TextXAlignment = Enum.TextXAlignment.Left

    UIGradientTitle.Parent = ScriptTitle

    local function NPLHKB_fake_script()
        local script = Instance_new('LocalScript', ScriptTitle)

        local button = script.Parent
        local gradient = button.UIGradient
        local ts = game:GetService("TweenService")
        local ti = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local offset = {
            Offset = Vector2.new(1, 0)
        }
        local create = ts:Create(gradient, ti, offset)
        local startingPos = Vector2.new(-1, 0)
        local list = {}
        local s, kpt = ColorSequence.new, ColorSequenceKeypoint.new
        local counter = 0
        local status = "down"
        gradient.Offset = startingPos
        local function rainbowColors()
            local sat, val = 255, 255
            for i = 1, 10 do
                local hue = i * 17
                table.insert(list, Color3_fromHSV(hue / 255, sat / 255, val / 255))
            end
        end
        rainbowColors()
        gradient.Color = s({kpt(0, list[#list]), kpt(0.5, list[#list - 1]), kpt(1, list[#list - 2])})
        counter = #list
        local function animate()
            create:Play()
            create.Completed:Wait()
            gradient.Offset = startingPos
            gradient.Rotation = 180
            if counter == #list - 1 and status == "down" then
                gradient.Color = s({kpt(0, gradient.Color.Keypoints[1].Value), kpt(0.5, list[#list]), kpt(1, list[1])})
                counter = 1
                status = "up"
            elseif counter == #list and status == "down" then
                gradient.Color = s({kpt(0, gradient.Color.Keypoints[1].Value), kpt(0.5, list[1]), kpt(1, list[2])})
                counter = 2
                status = "up"
            elseif counter <= #list - 2 and status == "down" then
                gradient.Color = s({kpt(0, gradient.Color.Keypoints[1].Value), kpt(0.5, list[counter + 1]),
                                    kpt(1, list[counter + 2])})
                counter = counter + 2
                status = "up"
            end
            create:Play()
            create.Completed:Wait()
            gradient.Offset = startingPos
            gradient.Rotation = 0
            if counter == #list - 1 and status == "up" then
                gradient.Color = s({kpt(0, list[1]), kpt(0.5, list[#list]), kpt(1, gradient.Color.Keypoints[3].Value)})
                counter = 1
                status = "down"
            elseif counter == #list and status == "up" then
                gradient.Color = s({kpt(0, list[2]), kpt(0.5, list[1]), kpt(1, gradient.Color.Keypoints[3].Value)})
                counter = 2
                status = "down"
            elseif counter <= #list - 2 and status == "up" then
                gradient.Color = s({kpt(0, list[counter + 2]), kpt(0.5, list[counter + 1]),
                                    kpt(1, gradient.Color.Keypoints[3].Value)})
                counter = counter + 2
                status = "down"
            end
            animate()
        end
        animate()

    end
    coroutine.wrap(NPLHKB_fake_script)()

    SBG.Color = ColorSequence.new {ColorSequenceKeypoint.new(0.00, zyColor), ColorSequenceKeypoint.new(1.00, zyColor)}
    SBG.Rotation = 90
    SBG.Name = "SBG"
    SBG.Parent = SB

    TabBtnsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabBtns.CanvasSize = UDim2_new(0, 0, 0, TabBtnsL.AbsoluteContentSize.Y + 18)
    end)
    Open.Name = "Open"
    Open.Parent = dogent
    Open.BackgroundColor3 = Color3_fromRGB(25, 25, 25)
    Open.Position = UDim2_new(0.00829315186, 0, 0.31107837, 0)
    Open.Size = UDim2_new(0, 61, 0, 32)
    Open.Font = Enum.Font.SourceSans
    Open.Text = "隐藏/打开"
    Open.TextColor3 = Color3_fromRGB(255, 255, 255)
    Open.TextSize = 14.000
    Open.Active = true
    Open.Draggable = true
    Open.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
    UIG.Parent = Open
    local window = {}
    function window.openColorPicker(window, title, flag, default, callback, position)
        OriginalCP_Color = library.flags[flag] or default
        CurrentCP_H, CurrentCP_S, CurrentCP_V = Color3.toHSV(OriginalCP_Color)
        CurrentCP_Flag = flag
        CurrentCP_Callback = callback
        CP_Title.Text = title
        updateCP()
        ColorPickerPopup.Position = position or UDim2_new(0.5, -120, 0.5, -125)
        ColorPickerPopup.Visible = true
        ColorPickerMask.Visible = true
        CP_Open = true
    end
    function window.Tab(window, name, icon)
        local Tab = Instance_new("ScrollingFrame")
        local TabIco = Instance_new("ImageLabel")
        local TabText = Instance_new("TextLabel")
        local TabBtn = Instance_new("TextButton")
        local TabL = Instance_new("UIListLayout")

        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.Active = true
        Tab.BackgroundColor3 = Background
        Tab.BackgroundTransparency = 1.000
        Tab.Size = UDim2_new(1, 0, 1, 0)
        Tab.ScrollBarThickness = 2
        Tab.Visible = false

        TabIco.Name = "TabIco"
        TabIco.Parent = TabBtns
        TabIco.BackgroundTransparency = 1.000
        TabIco.BorderSizePixel = 0
        TabIco.Size = UDim2_new(0, 24, 0, 24)
        TabIco.Image = ("rbxassetid://%s"):format((icon or 4370341699))
        TabIco.ImageColor3 = zyColor
        TabIco.ImageTransparency = 0.2

        TabText.Name = "TabText"
        TabText.Parent = TabIco
        TabText.BackgroundColor3 =beijingColor
        TabText.BackgroundTransparency = 1.000
        TabText.Position = UDim2_new(1.41666663, 0, 0, 0)
        TabText.Size = UDim2_new(0, 76, 0, 24)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = Color3_fromRGB(255, 255, 255)
        TabText.TextSize = 14.000
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.TextTransparency = 0.2

        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabIco
        TabBtn.BackgroundColor3 = beijingColor
        TabBtn.BackgroundTransparency = 1.000
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2_new(0, 110, 0, 24)
        TabBtn.AutoButtonColor = false
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        TabBtn.TextColor3 = Color3_fromRGB(0, 0, 0)
        TabBtn.TextSize = 14.000

        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)

        TabBtn.MouseButton1Click:Connect(function()
            task.spawn(function()
                Ripple(TabBtn)
            end)
            switchTab({TabIco, Tab})
        end)

        if library.currentTab == nil then
            switchTab({TabIco, Tab})
        end

        TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Tab.CanvasSize = UDim2_new(0, 0, 0, TabL.AbsoluteContentSize.Y + 8)
        end)

        local tab = {}
        function tab.section(tab, name, TabVal)
            local Section = Instance_new("Frame")
            local SectionC = Instance_new("UICorner")
            local SectionText = Instance_new("TextLabel")
            local SectionOpen = Instance_new("ImageLabel")
            local SectionOpened = Instance_new("ImageLabel")
            local SectionToggle = Instance_new("ImageButton")
            local Objs = Instance_new("Frame")
            local ObjsL = Instance_new("UIListLayout")

            Section.Name = "Section"
            Section.Parent = Tab
            Section.BackgroundColor3 = zyColor
            Section.BackgroundTransparency = 1.000
            Section.BorderSizePixel = 0
            Section.ClipsDescendants = true
            Section.Size = UDim2_new(0.981000006, 0, 0, 36)

            SectionC.CornerRadius = UDim.new(0, 6)
            SectionC.Name = "SectionC"
            SectionC.Parent = Section

            SectionText.Name = "SectionText"
            SectionText.Parent = Section
            SectionText.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
            SectionText.BackgroundTransparency = 1.000
            SectionText.Position = UDim2_new(0.0887396261, 0, 0, 0)
            SectionText.Size = UDim2_new(0, 401, 0, 36)
            SectionText.Font = Enum.Font.GothamSemibold
            SectionText.Text = name
            SectionText.TextColor3 = Color3_fromRGB(255, 255, 255)
            SectionText.TextSize = 16.000
            SectionText.TextXAlignment = Enum.TextXAlignment.Left

            SectionOpen.Name = "SectionOpen"
            SectionOpen.Parent = SectionText
            SectionOpen.BackgroundTransparency = 1
            SectionOpen.BorderSizePixel = 0
            SectionOpen.Position = UDim2_new(0, -33, 0, 5)
            SectionOpen.Size = UDim2_new(0, 26, 0, 26)
            SectionOpen.Image = "http://www.roblox.com/asset/?id=6031302934"

            SectionOpened.Name = "SectionOpened"
            SectionOpened.Parent = SectionOpen
            SectionOpened.BackgroundTransparency = 1.000
            SectionOpened.BorderSizePixel = 0
            SectionOpened.Size = UDim2_new(0, 26, 0, 26)
            SectionOpened.Image = "http://www.roblox.com/asset/?id=6031302932"
            SectionOpened.ImageTransparency = 1.000

            SectionToggle.Name = "SectionToggle"
            SectionToggle.Parent = SectionOpen
            SectionToggle.BackgroundTransparency = 1
            SectionToggle.BorderSizePixel = 0
            SectionToggle.Size = UDim2_new(0, 26, 0, 26)

            Objs.Name = "Objs"
            Objs.Parent = Section
            Objs.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
            Objs.BackgroundTransparency = 1
            Objs.BorderSizePixel = 0
            Objs.Position = UDim2_new(0, 6, 0, 36)
            Objs.Size = UDim2_new(0.986347735, 0, 0, 0)

            ObjsL.Name = "ObjsL"
            ObjsL.Parent = Objs
            ObjsL.SortOrder = Enum.SortOrder.LayoutOrder
            ObjsL.Padding = UDim.new(0, 8)

            local open = TabVal
            if TabVal ~= false then
                Section.Size = UDim2_new(0.981000006, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
                SectionOpened.ImageTransparency = (open and 0 or 1)
                SectionOpen.ImageTransparency = (open and 1 or 0)
            end

            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                Section.Size = UDim2_new(0.981000006, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36)
                SectionOpened.ImageTransparency = (open and 0 or 1)
                SectionOpen.ImageTransparency = (open and 1 or 0)
            end)

            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not open then
                    return
                end
                Section.Size = UDim2_new(0.981000006, 0, 0, 36 + ObjsL.AbsoluteContentSize.Y + 8)
            end)

            local section = {}
            function section.Button(section, text, callback)
                local callback = callback or function()
                end

                local BtnModule = Instance_new("Frame")
                local Btn = Instance_new("TextButton")
                local BtnC = Instance_new("UICorner")

                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                BtnModule.BackgroundTransparency = 1.000
                BtnModule.BorderSizePixel = 0
                BtnModule.Position = UDim2_new(0, 0, 0, 0)
                BtnModule.Size = UDim2_new(0, 428, 0, 38)

                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = beijingColor
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2_new(0, 428, 0, 38)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = Color3_fromRGB(255, 255, 255)
                Btn.TextSize = 16.000
                Btn.TextXAlignment = Enum.TextXAlignment.Left

                BtnC.CornerRadius = UDim.new(0, 6)
                BtnC.Name = "BtnC"
                BtnC.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    task.spawn(function()
                        Ripple(Btn)
                    end)
                    task.spawn(callback)
                end)
            end

            function section:Label(text)
                local LabelModule = Instance_new("Frame")
                local TextLabel = Instance_new("TextLabel")
                local LabelC = Instance_new("UICorner")

                LabelModule.Name = "LabelModule"
                LabelModule.Parent = Objs
                LabelModule.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                LabelModule.BackgroundTransparency = 1.000
                LabelModule.BorderSizePixel = 0
                LabelModule.Position = UDim2_new(0, 0, NAN, 0)
                LabelModule.Size = UDim2_new(0, 428, 0, 19)

                TextLabel.Parent = LabelModule
                TextLabel.BackgroundColor3 = beijingColor
                TextLabel.Size = UDim2_new(0, 428, 0, 22)
                TextLabel.Font = Enum.Font.GothamSemibold
                TextLabel.Text = text
                TextLabel.TextColor3 = Color3_fromRGB(255, 255, 255)
                TextLabel.TextSize = 14.000

                LabelC.CornerRadius = UDim.new(0, 6)
                LabelC.Name = "LabelC"
                LabelC.Parent = TextLabel
                return TextLabel
            end

            function section.Toggle(section, text, flag, enabled, callback)
                local callback = callback or function()
                end
                local enabled = enabled or false
                assert(text, "No text provided")
                assert(flag, "No flag provided")

                library.flags[flag] = enabled

                local ToggleModule = Instance_new("Frame")
                local ToggleBtn = Instance_new("TextButton")
                local ToggleBtnC = Instance_new("UICorner")
                local ToggleDisable = Instance_new("Frame")
                local ToggleSwitch = Instance_new("Frame")
                local ToggleSwitchC = Instance_new("UICorner")
                local ToggleDisableC = Instance_new("UICorner")

                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = Objs
                ToggleModule.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                ToggleModule.BackgroundTransparency = 1.000
                ToggleModule.BorderSizePixel = 0
                ToggleModule.Position = UDim2_new(0, 0, 0, 0)
                ToggleModule.Size = UDim2_new(0, 428, 0, 38)

                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = beijingColor
                ToggleBtn.BorderSizePixel = 0
                ToggleBtn.Size = UDim2_new(0, 428, 0, 38)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Font = Enum.Font.GothamSemibold
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = Color3_fromRGB(255, 255, 255)
                ToggleBtn.TextSize = 16.000
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left

                ToggleBtnC.CornerRadius = UDim.new(0, 6)
                ToggleBtnC.Name = "ToggleBtnC"
                ToggleBtnC.Parent = ToggleBtn

                ToggleDisable.Name = "ToggleDisable"
                ToggleDisable.Parent = ToggleBtn
                ToggleDisable.BackgroundColor3 = Background
                ToggleDisable.BorderSizePixel = 0
                ToggleDisable.Position = UDim2_new(0.901869178, 0, 0.208881587, 0)
                ToggleDisable.Size = UDim2_new(0, 36, 0, 22)

                ToggleSwitch.Name = "ToggleSwitch"
                ToggleSwitch.Parent = ToggleDisable
                ToggleSwitch.BackgroundColor3 = beijingColor
                ToggleSwitch.Size = UDim2_new(0, 24, 0, 22)

                ToggleSwitchC.CornerRadius = UDim.new(0, 6)
                ToggleSwitchC.Name = "ToggleSwitchC"
                ToggleSwitchC.Parent = ToggleSwitch

                ToggleDisableC.CornerRadius = UDim.new(0, 6)
                ToggleDisableC.Name = "ToggleDisableC"
                ToggleDisableC.Parent = ToggleDisable

                local funcs = {
                    SetState = function(self, state)
                        if state == nil then
                            state = not library.flags[flag]
                        end
                        if library.flags[flag] == state then
                            return
                        end
                        services.TweenService:Create(ToggleSwitch, TweenInfo.new(0.2), {
                            Position = UDim2_new(0, (state and ToggleSwitch.Size.X.Offset / 2 or 0), 0, 0),
                            BackgroundColor3 = (state and Color3_fromRGB(255, 255, 255) or beijingColor)
                        }):Play()
                        library.flags[flag] = state
                        callback(state)
                    end,
                    Module = ToggleModule
                }

                if enabled ~= false then
                    funcs:SetState(flag, true)
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    funcs:SetState()
                end)
                return funcs
            end

            function section.Keybind(section, text, default, callback)
                local callback = callback or function()
                end
                assert(text, "No text provided")
                assert(default, "No default key provided")

                local default = (typeof(default) == "string" and Enum.KeyCode[default] or default)
                local banned = {
                    Return = true,
                    Space = true,
                    Tab = true,
                    Backquote = true,
                    CapsLock = true,
                    Escape = true,
                    Unknown = true
                }
                local shortNames = {
                    RightControl = 'Right Ctrl',
                    LeftControl = 'Left Ctrl',
                    LeftShift = 'Left Shift',
                    RightShift = 'Right Shift',
                    Semicolon = ";",
                    Quote = '"',
                    LeftBracket = '[',
                    RightBracket = ']',
                    Equals = '=',
                    Minus = '-',
                    RightAlt = 'Right Alt',
                    LeftAlt = 'Left Alt'
                }

                local bindKey = default
                local keyTxt = (default and (shortNames[default.Name] or default.Name) or "None")

                local KeybindModule = Instance_new("Frame")
                local KeybindBtn = Instance_new("TextButton")
                local KeybindBtnC = Instance_new("UICorner")
                local KeybindValue = Instance_new("TextButton")
                local KeybindValueC = Instance_new("UICorner")
                local KeybindL = Instance_new("UIListLayout")
                local UIPadding = Instance_new("UIPadding")

                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                KeybindModule.BackgroundTransparency = 1.000
                KeybindModule.BorderSizePixel = 0
                KeybindModule.Position = UDim2_new(0, 0, 0, 0)
                KeybindModule.Size = UDim2_new(0, 428, 0, 38)

                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = beijingColor
                KeybindBtn.BorderSizePixel = 0
                KeybindBtn.Size = UDim2_new(0, 428, 0, 38)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Font = Enum.Font.GothamSemibold
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = Color3_fromRGB(255, 255, 255)
                KeybindBtn.TextSize = 16.000
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left

                KeybindBtnC.CornerRadius = UDim.new(0, 6)
                KeybindBtnC.Name = "KeybindBtnC"
                KeybindBtnC.Parent = KeybindBtn

                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = Background
                KeybindValue.BorderSizePixel = 0
                KeybindValue.Position = UDim2_new(0.763033211, 0, 0.289473683, 0)
                KeybindValue.Size = UDim2_new(0, 100, 0, 28)
                KeybindValue.AutoButtonColor = false
                KeybindValue.Font = Enum.Font.Gotham
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = Color3_fromRGB(255, 255, 255)
                KeybindValue.TextSize = 14.000

                KeybindValueC.CornerRadius = UDim.new(0, 6)
                KeybindValueC.Name = "KeybindValueC"
                KeybindValueC.Parent = KeybindValue

                KeybindL.Name = "KeybindL"
                KeybindL.Parent = KeybindBtn
                KeybindL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                KeybindL.SortOrder = Enum.SortOrder.LayoutOrder
                KeybindL.VerticalAlignment = Enum.VerticalAlignment.Center

                UIPadding.Parent = KeybindBtn
                UIPadding.PaddingRight = UDim.new(0, 6)

                services.UserInputService.InputBegan:Connect(function(inp, gpe)
                    if gpe then
                        return
                    end
                    if inp.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end
                    if inp.KeyCode ~= bindKey then
                        return
                    end
                    callback(bindKey.Name)
                end)

                KeybindValue.MouseButton1Click:Connect(function()
                    KeybindValue.Text = "..."
                    task.wait()
                    local key, uwu = services.UserInputService.InputEnded:Wait()
                    local keyName = tostring(key.KeyCode.Name)
                    if key.UserInputType ~= Enum.UserInputType.Keyboard then
                        KeybindValue.Text = keyTxt
                        return
                    end
                    if banned[keyName] then
                        KeybindValue.Text = keyTxt
                        return
                    end
                    task.wait()
                    bindKey = Enum.KeyCode[keyName]
                    KeybindValue.Text = shortNames[keyName] or keyName
                end)

                KeybindValue:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    KeybindValue.Size = UDim2_new(0, KeybindValue.TextBounds.X + 30, 0, 28)
                end)
                KeybindValue.Size = UDim2_new(0, KeybindValue.TextBounds.X + 30, 0, 28)
            end

            function section.Textbox(section, text, flag, default, callback)
                local callback = callback or function()
                end
                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default text provided")

                library.flags[flag] = default

                local TextboxModule = Instance_new("Frame")
                local TextboxBack = Instance_new("TextButton")
                local TextboxBackC = Instance_new("UICorner")
                local BoxBG = Instance_new("TextButton")
                local BoxBGC = Instance_new("UICorner")
                local TextBox = Instance_new("TextBox")
                local TextboxBackL = Instance_new("UIListLayout")
                local TextboxBackP = Instance_new("UIPadding")

                TextboxModule.Name = "TextboxModule"
                TextboxModule.Parent = Objs
                TextboxModule.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                TextboxModule.BackgroundTransparency = 1.000
                TextboxModule.BorderSizePixel = 0
                TextboxModule.Position = UDim2_new(0, 0, 0, 0)
                TextboxModule.Size = UDim2_new(0, 428, 0, 38)

                TextboxBack.Name = "TextboxBack"
                TextboxBack.Parent = TextboxModule
                TextboxBack.BackgroundColor3 = beijingColor
                TextboxBack.BorderSizePixel = 0
                TextboxBack.Size = UDim2_new(0, 428, 0, 38)
                TextboxBack.AutoButtonColor = false
                TextboxBack.Font = Enum.Font.GothamSemibold
                TextboxBack.Text = "   " .. text
                TextboxBack.TextColor3 = Color3_fromRGB(255, 255, 255)
                TextboxBack.TextSize = 16.000
                TextboxBack.TextXAlignment = Enum.TextXAlignment.Left

                TextboxBackC.CornerRadius = UDim.new(0, 6)
                TextboxBackC.Name = "TextboxBackC"
                TextboxBackC.Parent = TextboxBack

                BoxBG.Name = "BoxBG"
                BoxBG.Parent = TextboxBack
                BoxBG.BackgroundColor3 = Background
                BoxBG.BorderSizePixel = 0
                BoxBG.Position = UDim2_new(0.763033211, 0, 0.289473683, 0)
                BoxBG.Size = UDim2_new(0, 100, 0, 28)
                BoxBG.AutoButtonColor = false
                BoxBG.Font = Enum.Font.Gotham
                BoxBG.Text = ""
                BoxBG.TextColor3 = Color3_fromRGB(255, 255, 255)
                BoxBG.TextSize = 14.000

                BoxBGC.CornerRadius = UDim.new(0, 6)
                BoxBGC.Name = "BoxBGC"
                BoxBGC.Parent = BoxBG

                TextBox.Parent = BoxBG
                TextBox.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                TextBox.BackgroundTransparency = 1.000
                TextBox.BorderSizePixel = 0
                TextBox.Size = UDim2_new(1, 0, 1, 0)
                TextBox.Font = Enum.Font.Gotham
                TextBox.Text = default
                TextBox.TextColor3 = Color3_fromRGB(255, 255, 255)
                TextBox.TextSize = 14.000

                TextboxBackL.Name = "TextboxBackL"
                TextboxBackL.Parent = TextboxBack
                TextboxBackL.HorizontalAlignment = Enum.HorizontalAlignment.Right
                TextboxBackL.SortOrder = Enum.SortOrder.LayoutOrder
                TextboxBackL.VerticalAlignment = Enum.VerticalAlignment.Center

                TextboxBackP.Name = "TextboxBackP"
                TextboxBackP.Parent = TextboxBack
                TextboxBackP.PaddingRight = UDim.new(0, 6)

                TextBox.FocusLost:Connect(function()
                    if TextBox.Text == "" then
                        TextBox.Text = default
                    end
                    library.flags[flag] = TextBox.Text
                    callback(TextBox.Text)
                end)

                TextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
                    BoxBG.Size = UDim2_new(0, TextBox.TextBounds.X + 30, 0, 28)
                end)
                BoxBG.Size = UDim2_new(0, TextBox.TextBounds.X + 30, 0, 28)
            end

            function section.Slider(section, text, flag, default, min, max, precise, callback)
                local callback = callback or function()
                end
                local min = min or 1
                local max = max or 10
                local default = default or min
                local precise = precise or false

                library.flags[flag] = default

                assert(text, "No text provided")
                assert(flag, "No flag provided")
                assert(default, "No default value provided")

                local SliderModule = Instance_new("Frame")
                local SliderBack = Instance_new("TextButton")
                local SliderBackC = Instance_new("UICorner")
                local SliderBar = Instance_new("Frame")
                local SliderBarC = Instance_new("UICorner")
                local SliderPart = Instance_new("Frame")
                local SliderPartC = Instance_new("UICorner")
                local SliderValBG = Instance_new("TextButton")
                local SliderValBGC = Instance_new("UICorner")
                local SliderValue = Instance_new("TextBox")
                local MinSlider = Instance_new("TextButton")
                local AddSlider = Instance_new("TextButton")

                SliderModule.Name = "SliderModule"
                SliderModule.Parent = Objs
                SliderModule.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                SliderModule.BackgroundTransparency = 1.000
                SliderModule.BorderSizePixel = 0
                SliderModule.Position = UDim2_new(0, 0, 0, 0)
                SliderModule.Size = UDim2_new(0, 428, 0, 38)

                SliderBack.Name = "SliderBack"
                SliderBack.Parent = SliderModule
                SliderBack.BackgroundColor3 = beijingColor
                SliderBack.BorderSizePixel = 0
                SliderBack.Size = UDim2_new(0, 428, 0, 38)
                SliderBack.AutoButtonColor = false
                SliderBack.Font = Enum.Font.GothamSemibold
                SliderBack.Text = "   " .. text
                SliderBack.TextColor3 = Color3_fromRGB(255, 255, 255)
                SliderBack.TextSize = 16.000
                SliderBack.TextXAlignment = Enum.TextXAlignment.Left

                SliderBackC.CornerRadius = UDim.new(0, 6)
                SliderBackC.Name = "SliderBackC"
                SliderBackC.Parent = SliderBack

                SliderBar.Name = "SliderBar"
                SliderBar.Parent = SliderBack
                SliderBar.AnchorPoint = Vector2.new(0, 0.5)
                SliderBar.BackgroundColor3 = Background
                SliderBar.BorderSizePixel = 0
                SliderBar.Position = UDim2_new(0.369000018, 40, 0.5, 0)
                SliderBar.Size = UDim2_new(0, 140, 0, 12)

                SliderBarC.CornerRadius = UDim.new(0, 4)
                SliderBarC.Name = "SliderBarC"
                SliderBarC.Parent = SliderBar

                SliderPart.Name = "SliderPart"
                SliderPart.Parent = SliderBar
                SliderPart.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                SliderPart.BorderSizePixel = 0
                SliderPart.Size = UDim2_new(0, 54, 0, 13)

                SliderPartC.CornerRadius = UDim.new(0, 4)
                SliderPartC.Name = "SliderPartC"
                SliderPartC.Parent = SliderPart

                SliderValBG.Name = "SliderValBG"
                SliderValBG.Parent = SliderBack
                SliderValBG.BackgroundColor3 = Background
                SliderValBG.BorderSizePixel = 0
                SliderValBG.Position = UDim2_new(0.883177578, 0, 0.131578952, 0)
                SliderValBG.Size = UDim2_new(0, 44, 0, 28)
                SliderValBG.AutoButtonColor = false
                SliderValBG.Font = Enum.Font.Gotham
                SliderValBG.Text = ""
                SliderValBG.TextColor3 = Color3_fromRGB(255, 255, 255)
                SliderValBG.TextSize = 14.000

                SliderValBGC.CornerRadius = UDim.new(0, 6)
                SliderValBGC.Name = "SliderValBGC"
                SliderValBGC.Parent = SliderValBG

                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderValBG
                SliderValue.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                SliderValue.BackgroundTransparency = 1.000
                SliderValue.BorderSizePixel = 0
                SliderValue.Size = UDim2_new(1, 0, 1, 0)
                SliderValue.Font = Enum.Font.Gotham
                SliderValue.Text = "1000"
                SliderValue.TextColor3 = Color3_fromRGB(255, 255, 255)
                SliderValue.TextSize = 14.000

                MinSlider.Name = "MinSlider"
                MinSlider.Parent = SliderModule
                MinSlider.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                MinSlider.BackgroundTransparency = 1.000
                MinSlider.BorderSizePixel = 0
                MinSlider.Position = UDim2_new(0.296728969, 40, 0.236842096, 0)
                MinSlider.Size = UDim2_new(0, 20, 0, 20)
                MinSlider.Font = Enum.Font.Gotham
                MinSlider.Text = "-"
                MinSlider.TextColor3 = Color3_fromRGB(255, 255, 255)
                MinSlider.TextSize = 24.000
                MinSlider.TextWrapped = true

                AddSlider.Name = "AddSlider"
                AddSlider.Parent = SliderModule
                AddSlider.AnchorPoint = Vector2.new(0, 0.5)
                AddSlider.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                AddSlider.BackgroundTransparency = 1.000
                AddSlider.BorderSizePixel = 0
                AddSlider.Position = UDim2_new(0.810906529, 0, 0.5, 0)
                AddSlider.Size = UDim2_new(0, 20, 0, 20)
                AddSlider.Font = Enum.Font.Gotham
                AddSlider.Text = "+"
                AddSlider.TextColor3 = Color3_fromRGB(255, 255, 255)
                AddSlider.TextSize = 24.000
                AddSlider.TextWrapped = true

                local funcs = {
                    SetValue = function(self, value)
                        local percent = (mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                        if value then
                            percent = (value - min) / (max - min)
                        end
                        percent = math.clamp(percent, 0, 1)
                        if precise then
                            value = value or tonumber(string.format("%.1f", tostring(min + (max - min) * percent)))
                        else
                            value = value or math.floor(min + (max - min) * percent)
                        end
                        library.flags[flag] = tonumber(value)
                        SliderValue.Text = tostring(value)
                        SliderPart.Size = UDim2_new(percent, 0, 1, 0)
                        callback(tonumber(value))
                    end
                }

                MinSlider.MouseButton1Click:Connect(function()
                    local currentValue = library.flags[flag]
                    currentValue = math.clamp(currentValue - 1, min, max)
                    funcs:SetValue(currentValue)
                end)

                AddSlider.MouseButton1Click:Connect(function()
                    local currentValue = library.flags[flag]
                    currentValue = math.clamp(currentValue + 1, min, max)
                    funcs:SetValue(currentValue)
                end)

                funcs:SetValue(default)

                local dragging, boxFocused, allowed = false, false, {
                    [""] = true,
                    ["-"] = true
                }

                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        funcs:SetValue()
                        dragging = true
                    end
                end)

                services.UserInputService.InputEnded:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                services.UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        funcs:SetValue()
                    end
                end)

                SliderBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch then
                        funcs:SetValue()
                        dragging = true
                    end
                end)

                services.UserInputService.InputEnded:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                services.UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.Touch then
                        funcs:SetValue()
                    end
                end)

                SliderValue.Focused:Connect(function()
                    boxFocused = true
                end)

                SliderValue.FocusLost:Connect(function()
                    boxFocused = false
                    if SliderValue.Text == "" then
                        funcs:SetValue(default)
                    end
                end)

                SliderValue:GetPropertyChangedSignal("Text"):Connect(function()
                    if not boxFocused then
                        return
                    end
                    SliderValue.Text = SliderValue.Text:gsub("%D+", "")

                    local text = SliderValue.Text

                    if not tonumber(text) then
                        SliderValue.Text = SliderValue.Text:gsub('%D+', '')
                    elseif not allowed[text] then
                        if tonumber(text) > max then
                            text = max
                            SliderValue.Text = tostring(max)
                        end
                        funcs:SetValue(tonumber(text))
                    end
                end)

                return funcs
            end
            function section.ColorPicker(section, text, flag, default, callback)
                local callback = callback or function() end
                local default = default or Color3_fromRGB(255, 255, 255)
                library.flags[flag] = default

                local ColorModule = Instance_new("Frame")
                local ColorTop = Instance_new("TextButton")
                local ColorTopC = Instance_new("UICorner")
                local ColorView = Instance_new("Frame")
                local ColorViewC = Instance_new("UICorner")

                ColorModule.Name = "ColorModule"
                ColorModule.Parent = Objs
                ColorModule.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                ColorModule.BackgroundTransparency = 1.000
                ColorModule.Size = UDim2_new(0, 428, 0, 38)

                ColorTop.Name = "ColorTop"
                ColorTop.Parent = ColorModule
                ColorTop.BackgroundColor3 = beijingColor
                ColorTop.Size = UDim2_new(1, 0, 0, 38)
                ColorTop.AutoButtonColor = false
                ColorTop.Font = Enum.Font.GothamSemibold
                ColorTop.Text = "   " .. text
                ColorTop.TextColor3 = Color3_fromRGB(255, 255, 255)
                ColorTop.TextSize = 16.000
                ColorTop.TextXAlignment = Enum.TextXAlignment.Left

                ColorTopC.CornerRadius = UDim.new(0, 6)
                ColorTopC.Parent = ColorTop

                ColorView.Name = "ColorView"
                ColorView.Parent = ColorTop
                ColorView.BackgroundColor3 = default
                ColorView.Position = UDim2_new(1, -40, 0.5, -10)
                ColorView.Size = UDim2_new(0, 30, 0, 20)
                
                ColorViewC.CornerRadius = UDim.new(0, 4)
                ColorViewC.Parent = ColorView

                ColorTop.MouseButton1Click:Connect(function()
                    local pos = ColorTop.AbsolutePosition
                    window:openColorPicker(text, flag, default, function(color)
                        ColorView.BackgroundColor3 = color
                        callback(color)
                    end, UDim2_new(0, pos.X + 440, 0, pos.Y - 50))
                end)
            end

            function section.Dropdown(section, text, flag, options, callback)
                local callback = callback or function()
                end
                local options = options or {}
                assert(text, "No text provided")
                assert(flag, "No flag provided")

                library.flags[flag] = nil

                local DropdownModule = Instance_new("Frame")
                local DropdownTop = Instance_new("TextButton")
                local DropdownTopC = Instance_new("UICorner")
                local DropdownOpen = Instance_new("TextButton")
                local DropdownText = Instance_new("TextBox")
                local DropdownModuleL = Instance_new("UIListLayout")
                local Option = Instance_new("TextButton")
                local OptionC = Instance_new("UICorner")

                DropdownModule.Name = "DropdownModule"
                DropdownModule.Parent = Objs
                DropdownModule.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                DropdownModule.BackgroundTransparency = 1.000
                DropdownModule.BorderSizePixel = 0
                DropdownModule.ClipsDescendants = true
                DropdownModule.Position = UDim2_new(0, 0, 0, 0)
                DropdownModule.Size = UDim2_new(0, 428, 0, 38)

                DropdownTop.Name = "DropdownTop"
                DropdownTop.Parent = DropdownModule
                DropdownTop.BackgroundColor3 = beijingColor
                DropdownTop.BorderSizePixel = 0
                DropdownTop.Size = UDim2_new(0, 428, 0, 38)
                DropdownTop.AutoButtonColor = false
                DropdownTop.Font = Enum.Font.GothamSemibold
                DropdownTop.Text = ""
                DropdownTop.TextColor3 = Color3_fromRGB(255, 255, 255)
                DropdownTop.TextSize = 16.000
                DropdownTop.TextXAlignment = Enum.TextXAlignment.Left

                DropdownTopC.CornerRadius = UDim.new(0, 6)
                DropdownTopC.Name = "DropdownTopC"
                DropdownTopC.Parent = DropdownTop

                DropdownOpen.Name = "DropdownOpen"
                DropdownOpen.Parent = DropdownTop
                DropdownOpen.AnchorPoint = Vector2.new(0, 0.5)
                DropdownOpen.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                DropdownOpen.BackgroundTransparency = 1.000
                DropdownOpen.BorderSizePixel = 0
                DropdownOpen.Position = UDim2_new(0.918383181, 0, 0.5, 0)
                DropdownOpen.Size = UDim2_new(0, 20, 0, 20)
                DropdownOpen.Font = Enum.Font.Gotham
                DropdownOpen.Text = "+"
                DropdownOpen.TextColor3 = Color3_fromRGB(255, 255, 255)
                DropdownOpen.TextSize = 24.000
                DropdownOpen.TextWrapped = true

                DropdownText.Name = "DropdownText"
                DropdownText.Parent = DropdownTop
                DropdownText.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
                DropdownText.BackgroundTransparency = 1.000
                DropdownText.BorderSizePixel = 0
                DropdownText.Position = UDim2_new(0.0373831764, 0, 0, 0)
                DropdownText.Size = UDim2_new(0, 184, 0, 38)
                DropdownText.Font = Enum.Font.GothamSemibold
                DropdownText.PlaceholderColor3 = Color3_fromRGB(255, 255, 255)
                DropdownText.PlaceholderText = text
                DropdownText.Text = ""
                DropdownText.TextColor3 = Color3_fromRGB(255, 255, 255)
                DropdownText.TextSize = 16.000
                DropdownText.TextXAlignment = Enum.TextXAlignment.Left

                DropdownModuleL.Name = "DropdownModuleL"
                DropdownModuleL.Parent = DropdownModule
                DropdownModuleL.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownModuleL.Padding = UDim.new(0, 4)

                local setAllVisible = function()
                    local options = DropdownModule:GetChildren()
                    for i = 1, #options do
                        local option = options[i]
                        if option:IsA("TextButton") and option.Name:match("Option_") then
                            option.Visible = true
                        end
                    end
                end

                local searchDropdown = function(text)
                    local options = DropdownModule:GetChildren()
                    for i = 1, #options do
                        local option = options[i]
                        if text == "" then
                            setAllVisible()
                        else
                            if option:IsA("TextButton") and option.Name:match("Option_") then
                                if option.Text:lower():match(text:lower()) then
                                    option.Visible = true
                                else
                                    option.Visible = false
                                end
                            end
                        end
                    end
                end

                local open = false
                local ToggleDropVis = function()
                    open = not open
                    if open then
                        setAllVisible()
                    end
                    DropdownOpen.Text = (open and "-" or "+")
                    DropdownModule.Size = UDim2_new(0, 428, 0,
                        (open and DropdownModuleL.AbsoluteContentSize.Y + 4 or 38))
                end

                DropdownOpen.MouseButton1Click:Connect(ToggleDropVis)
                DropdownText.Focused:Connect(function()
                    if open then
                        return
                    end
                    ToggleDropVis()
                end)

                DropdownText:GetPropertyChangedSignal("Text"):Connect(function()
                    if not open then
                        return
                    end
                    searchDropdown(DropdownText.Text)
                end)

                DropdownModuleL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if not open then
                        return
                    end
                    DropdownModule.Size = UDim2_new(0, 428, 0, (DropdownModuleL.AbsoluteContentSize.Y + 4))
                end)

                local funcs = {}
                funcs.AddOption = function(self, option)
                    local Option = Instance_new("TextButton")
                    local OptionC = Instance_new("UICorner")

                    Option.Name = "Option_" .. option
                    Option.Parent = DropdownModule
                    Option.BackgroundColor3 = beijingColor
                    Option.BorderSizePixel = 0
                    Option.Position = UDim2_new(0, 0, 0.328125, 0)
                    Option.Size = UDim2_new(0, 428, 0, 26)
                    Option.AutoButtonColor = false
                    Option.Font = Enum.Font.Gotham
                    Option.Text = option
                    Option.TextColor3 = Color3_fromRGB(255, 255, 255)
                    Option.TextSize = 14.000

                    OptionC.CornerRadius = UDim.new(0, 6)
                    OptionC.Name = "OptionC"
                    OptionC.Parent = Option

                    Option.MouseButton1Click:Connect(function()
                        ToggleDropVis()
                        callback(Option.Text)
                        DropdownText.Text = Option.Text
                        library.flags[flag] = Option.Text
                    end)
                end

                funcs.RemoveOption = function(self, option)
                    local option = DropdownModule:FindFirstChild("Option_" .. option)
                    if option then
                        option:Destroy()
                    end
                end

                funcs.SetOptions = function(self, options)
                    for _, v in next, DropdownModule:GetChildren() do
                        if v.Name:match("Option_") then
                            v:Destroy()
                        end
                    end
                    for _, v in next, options do
                        funcs:AddOption(v)
                    end
                end

                funcs:SetOptions(options)
                return funcs
            end

            return section
        end
        return tab
    end
    return window

end
return library
