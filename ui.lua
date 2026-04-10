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
        Ripple.ImageColor3 = zyColor
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
local function switchTab(new)
    if switchingTabs or (library.currentTab and library.currentTab[1] == new[1]) then return end
    switchingTabs = true
    local old = library.currentTab
    library.currentTab = new
    
    if old then
        Tween(old[1], {0.2, 'Quad', 'Out'}, {ImageTransparency = 0.2})
        Tween(old[1].TabText, {0.2, 'Quad', 'Out'}, {TextTransparency = 0.2})
        Tween(old[2], {0.15, 'Quad', 'Out'}, {Position = UDim2_new(0, 0, 0, 10), GroupTransparency = 1})
        task.wait(0.15)
        old[2].Visible = false
    end
    
    new[2].Visible = true
    new[2].Position = UDim2_new(0, 0, 0, -10)
    new[2].GroupTransparency = 1
    Tween(new[1], {0.2, 'Quad', 'Out'}, {ImageTransparency = 0})
    Tween(new[1].TabText, {0.2, 'Quad', 'Out'}, {TextTransparency = 0})
    Tween(new[2], {0.2, 'Quad', 'Out'}, {Position = UDim2_new(0, 0, 0, 0), GroupTransparency = 0})
    
    -- Cascading Effect for Children
    for i, v in ipairs(new[2]:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextButton") then
            v.GroupTransparency = 1
            v.Position = v.Position + UDim2_new(0, 0, 0, 15)
            task.spawn(function()
                task.wait(i * 0.04)
                Tween(v, {0.3, 'Quad', 'Out'}, {GroupTransparency = 0, Position = v.Position - UDim2_new(0, 0, 0, 15)})
            end)
        end
    end
    
    task.wait(0.2)
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
    local MainColor = Color3_fromRGB(32, 32, 32)
    local Background = Color3_fromRGB(38, 38, 38)
    local zyColor = Color3_fromRGB(255, 255, 255)
    local beijingColor = Color3_fromRGB(48, 48, 48)
  
    local dogent = Instance_new("ScreenGui")
    dogent.IgnoreGuiInset = true
    dogent.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance_new("Frame")
    local TabMain = Instance_new("CanvasGroup")
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

    if syn and syn.protect_gui then
        syn.protect_gui(dogent)
    end

    dogent.Name = "frosty is cute"
    dogent.Parent = services.CoreGui

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
    Main.ClipsDescendants = true
    
    local MainScale = Instance_new("UIScale")
    MainScale.Parent = Main
    MainScale.Scale = 0.95
    Main.GroupTransparency = 1
    
    Tween(MainScale, {0.3, 'Back', 'Out'}, {Scale = 1})
    Tween(Main, {0.2, 'Quad', 'Out'}, {GroupTransparency = 0})

    services.UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            Main.Visible = not Main.Visible
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
    ScriptTitle.TextColor3 = zyColor
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
        local offset = {Offset = Vector2.new(1, 0)}
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
    Open.TextColor3 = zyColor
    Open.TextSize = 14.000
    Open.Active = true
    Open.Draggable = true
    Open.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end)
    UIG.Parent = Open
    local window = {}

    function window.Tab(window, name, icon)
        local Tab = Instance_new("ScrollingFrame")
        -- Use CanvasGroup workaround for overall transparency if needed, but ScrollingFrame allows content visibility
        Tab.Name = "Tab"
        Tab.Parent = TabMain
        Tab.BackgroundColor3 = Background
        Tab.BackgroundTransparency = 1.000
        Tab.Size = UDim2_new(1, 0, 1, 0)
        Tab.Visible = false
        Tab.ScrollBarThickness = 0
        Tab.CanvasSize = UDim2_new(0, 0, 0, 0)
        Tab.ScrollingDirection = Enum.ScrollingDirection.Y

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
        TabText.BackgroundColor3 = beijingColor
        TabText.BackgroundTransparency = 1.000
        TabText.Position = UDim2_new(1.41666663, 0, 0, 0)
        TabText.Size = UDim2_new(0, 76, 0, 24)
        TabText.Font = Enum.Font.GothamSemibold
        TabText.Text = name
        TabText.TextColor3 = zyColor
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
        TabBtn.Text = ""
        TabBtnScale.Parent = TabBtn

        TabBtn.MouseButton1Down:Connect(function() Tween(TabBtnScale, {0.1, 'Quad', 'Out'}, {Scale = 0.95}) end)
        TabBtn.MouseButton1Up:Connect(function() Tween(TabBtnScale, {0.1, 'Quad', 'Out'}, {Scale = 1}) end)
        TabBtn.MouseButton1Click:Connect(function()
            Ripple(TabBtn)
            switchTab({TabIco, Tab})
        end)

        TabL.Name = "TabL"
        TabL.Parent = Tab
        TabL.SortOrder = Enum.SortOrder.LayoutOrder
        TabL.Padding = UDim.new(0, 4)

        if library.currentTab == nil then
            switchTab({TabIco, Tab})
        end

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
            SectionText.TextColor3 = zyColor
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

            ObjsL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if open then
                    Section:TweenSize(UDim2_new(0.981, 0, 0, 36 + ObjsL.AbsoluteContentSize.Y + 8), "Out", "Quad", 0.3, true)
                end
            end)

            SectionToggle.MouseButton1Click:Connect(function()
                open = not open
                Tween(SectionOpened, {0.3, 'Quad', 'Out'}, {ImageTransparency = (open and 0 or 1), Rotation = (open and 0 or -90)})
                Tween(SectionOpen, {0.3, 'Quad', 'Out'}, {ImageTransparency = (open and 1 or 0)})
                Section:TweenSize(UDim2_new(0.981, 0, 0, open and 36 + ObjsL.AbsoluteContentSize.Y + 8 or 36), "Out", "Quad", 0.3, true)
            end)

            TabL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Tab.CanvasSize = UDim2_new(0, 0, 0, TabL.AbsoluteContentSize.Y + 10)
            end)

            local section = {}
            function section.Button(section, text, callback)
                local BtnModule = Instance_new("Frame")
                local Btn = Instance_new("TextButton")
                local BtnScale = Instance_new("UIScale")
                local BtnC = Instance_new("UICorner")

                BtnModule.Name = "BtnModule"
                BtnModule.Parent = Objs
                BtnModule.BackgroundTransparency = 1.000
                BtnModule.Size = UDim2_new(0, 428, 0, 38)

                Btn.Name = "Btn"
                Btn.Parent = BtnModule
                Btn.BackgroundColor3 = beijingColor
                Btn.BorderSizePixel = 0
                Btn.Size = UDim2_new(0, 428, 0, 38)
                Btn.AutoButtonColor = false
                Btn.Font = Enum.Font.GothamSemibold
                Btn.Text = "   " .. text
                Btn.TextColor3 = zyColor
                Btn.TextSize = 16.000
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                BtnScale.Parent = Btn
                BtnC.Parent = Btn

                Btn.MouseButton1Down:Connect(function() Tween(BtnScale, {0.1, 'Quad', 'Out'}, {Scale = 0.96}) end)
                Btn.MouseButton1Up:Connect(function() Tween(BtnScale, {0.1, 'Quad', 'Out'}, {Scale = 1}) end)
                Btn.MouseButton1Click:Connect(function()
                    Ripple(Btn)
                    callback()
                end)
            end

            function section.Toggle(section, text, flag, enabled, callback)
                library.flags[flag] = enabled or false
                local ToggleModule = Instance_new("Frame")
                local ToggleBtn = Instance_new("TextButton")
                local ToggleView = Instance_new("Frame")
                local ToggleIndicator = Instance_new("Frame")
                
                ToggleModule.Name = "ToggleModule"
                ToggleModule.Parent = Objs
                ToggleModule.BackgroundTransparency = 1
                ToggleModule.Size = UDim2_new(0, 428, 0, 38)
                
                ToggleBtn.Name = "ToggleBtn"
                ToggleBtn.Parent = ToggleModule
                ToggleBtn.BackgroundColor3 = beijingColor
                ToggleBtn.Size = UDim2_new(0, 428, 0, 38)
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Text = "   " .. text
                ToggleBtn.TextColor3 = zyColor
                ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
                Instance_new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)
                
                ToggleView.Name = "ToggleView"
                ToggleView.Parent = ToggleBtn
                ToggleView.BackgroundColor3 = beijingColor
                ToggleView.Position = UDim2_new(0.9, 0, 0.2, 0)
                ToggleView.Size = UDim2_new(0, 36, 0, 22)
                Instance_new("UICorner", ToggleView).CornerRadius = UDim.new(0, 6)
                
                ToggleIndicator.Name = "ToggleIndicator"
                ToggleIndicator.Parent = ToggleView
                ToggleIndicator.BackgroundColor3 = zyColor
                ToggleIndicator.Size = UDim2_new(0, 18, 0, 18)
                Instance_new("UICorner", ToggleIndicator).CornerRadius = UDim.new(0, 6)
                
                local function updateToggle(state)
                    if state then
                        Tween(ToggleView, {0.2, 'Quad', 'Out'}, {BackgroundColor3 = zyColor})
                        Tween(ToggleIndicator, {0.2, 'Back', 'Out'}, {Position = UDim2_new(1, -20, 0.5, -9)})
                    else
                        Tween(ToggleView, {0.2, 'Quad', 'Out'}, {BackgroundColor3 = beijingColor})
                        Tween(ToggleIndicator, {0.2, 'Back', 'Out'}, {Position = UDim2_new(0, 2, 0.5, -9)})
                    end
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    library.flags[flag] = not library.flags[flag]
                    updateToggle(library.flags[flag])
                    callback(library.flags[flag])
                end)
                updateToggle(library.flags[flag])
            end

            function section.Keybind(section, text, default, callback)
                local bindKey = typeof(default) == "string" and Enum.KeyCode[default] or default
                local keyTxt = bindKey and bindKey.Name or "None"
                local banned = {Return = true, Space = true, Tab = true, Backquote = true, CapsLock = true, Escape = true, Unknown = true}
                local shortNames = {RightControl = 'Right Ctrl', LeftControl = 'Left Ctrl', LeftShift = 'Left Shift', RightShift = 'Right Shift'}

                local KeybindModule = Instance_new("Frame")
                local KeybindBtn = Instance_new("TextButton")
                local KeybindValue = Instance_new("TextButton")

                KeybindModule.Name = "KeybindModule"
                KeybindModule.Parent = Objs
                KeybindModule.BackgroundTransparency = 1
                KeybindModule.Size = UDim2_new(0, 428, 0, 38)

                KeybindBtn.Name = "KeybindBtn"
                KeybindBtn.Parent = KeybindModule
                KeybindBtn.BackgroundColor3 = beijingColor
                KeybindBtn.Size = UDim2_new(0, 428, 0, 38)
                KeybindBtn.AutoButtonColor = false
                KeybindBtn.Text = "   " .. text
                KeybindBtn.TextColor3 = zyColor
                KeybindBtn.TextXAlignment = Enum.TextXAlignment.Left
                Instance_new("UICorner", KeybindBtn).CornerRadius = UDim.new(0, 6)

                KeybindValue.Name = "KeybindValue"
                KeybindValue.Parent = KeybindBtn
                KeybindValue.BackgroundColor3 = Background
                KeybindValue.Size = UDim2_new(0, 80, 0, 28)
                KeybindValue.Position = UDim2_new(1, -86, 0.5, -14)
                KeybindValue.Text = keyTxt
                KeybindValue.TextColor3 = zyColor
                Instance_new("UICorner", KeybindValue).CornerRadius = UDim.new(0, 6)

                services.UserInputService.InputBegan:Connect(function(inp, gpe)
                    if not gpe and inp.KeyCode == bindKey then callback(bindKey.Name) end
                end)

                KeybindValue.MouseButton1Click:Connect(function()
                    KeybindValue.Text = "..."
                    local key = services.UserInputService.InputEnded:Wait()
                    if key.UserInputType == Enum.UserInputType.Keyboard and not banned[key.KeyCode.Name] then
                        bindKey = key.KeyCode
                        keyTxt = shortNames[bindKey.Name] or bindKey.Name
                    end
                    KeybindValue.Text = keyTxt
                end)
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
                TextboxBack.TextColor3 = zyColor
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
                BoxBG.TextColor3 = zyColor
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
                TextBox.TextColor3 = zyColor
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
                SliderBack.TextColor3 = zyColor
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
                SliderValBG.TextColor3 = zyColor
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
                SliderValue.TextColor3 = zyColor
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
                MinSlider.TextColor3 = zyColor
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
                AddSlider.TextColor3 = zyColor
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
                DropdownTop.TextColor3 = zyColor
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
                DropdownOpen.TextColor3 = zyColor
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
                DropdownText.TextColor3 = zyColor
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
                    Option.TextColor3 = zyColor
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
