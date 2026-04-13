local cloneref = cloneref or function(v) return v end
local HttpService = cloneref(game:GetService'HttpService')
local Players = cloneref(game:GetService'Players')
local LogService = cloneref(game:GetService'LogService')
local RunService = cloneref(game:GetService'RunService')
local CoreGui = pcall(game.GetService, game, 'CoreGui') and cloneref(game:GetService'CoreGui') or nil
local nativePrint = print
local nativeWarn = warn
local BRIDGE_ID = tostring(math.random(1, 999999999))
if getgenv and getgenv()._UWUPAWZ_BRIDGE then
	local old = getgenv()._UWUPAWZ_BRIDGE
	if old.nativePrint then pcall(function() _G.print = old.nativePrint end) end
	if old.nativeWarn then pcall(function() _G.warn = old.nativeWarn end) end
	if getgenv()._RBXDEV_OUTPUT_HOOKED then getgenv()._RBXDEV_OUTPUT_HOOKED = nil end
	_G._RBXDEV_OUTPUT_HOOKED = nil
	if old.connection then pcall(old.connection.Close, old.connection) end
	for _, conn in ipairs(old.refreshConnections or {}) do pcall(conn.Disconnect, conn) end
	old.alive = false
end
local userConfig = (...) or {}
local CONFIG = {
host              = 'ws://127.0.0.1:21324',
reconnectDelay    = 5,
reconnectDelayMax = 60,
enableHealthProbe = true,
firstConnectDepth = 1,
updateTreeDepth   = 2,
expandedTreeDepth = 1,
suppressGameConsoleLog = true,
gameTreeServices  = {
'Workspace', 'Players', 'ReplicatedStorage', 'ReplicatedFirst',
'StarterGui', 'StarterPack', 'StarterPlayer', 'Lighting', 'CoreGui',
},
}
for k, v in pairs(userConfig) do CONFIG[k] = v end
local DEFAULT_PROPERTIES = {
    Instance              = { 'Name', 'Parent', 'Archivable', 'ClassName' },
    BasePart              = { 'Name', 'Transparency', 'Color', 'Material', 'MaterialVariant', 'Reflectance', 'Anchored', 'CanCollide', 'CanTouch', 'CanQuery', 'Locked', 'CastShadow', 'Massless', 'Position', 'Size', 'Rotation', 'CFrame', 'AssemblyLinearVelocity', 'AssemblyAngularVelocity', 'CollisionGroup', 'CollisionGroupId', 'CustomPhysicalProperties', 'EnableFluidForces', 'FluidFidelity', 'CollisionFidelity' },
    Part                  = { 'Name', 'Transparency', 'Color', 'Material', 'Reflectance', 'Anchored', 'CanCollide', 'CanTouch', 'CanQuery', 'Locked', 'CastShadow', 'Position', 'Size', 'Rotation', 'Shape' },
    MeshPart              = { 'Name', 'Transparency', 'Color', 'Material', 'Reflectance', 'Anchored', 'CanCollide', 'CanTouch', 'CanQuery', 'Locked', 'CastShadow', 'Position', 'Size', 'Rotation' },
    UnionOperation        = { 'Name', 'Transparency', 'Color', 'Material', 'Reflectance', 'Anchored', 'CanCollide', 'CanTouch', 'CanQuery', 'Locked', 'CastShadow', 'Position', 'Size', 'Rotation' },
    SpawnLocation         = { 'Name', 'Transparency', 'Color', 'Material', 'Anchored', 'CanCollide', 'Position', 'Size', 'Enabled', 'TeamColor', 'AllowTeamChangeOnTouch', 'Neutral' },
    Model                 = { 'Name', 'PrimaryPart', 'LevelOfDetail' },
    Folder                = { 'Name' },
    Configuration         = { 'Name' },
    Script                = { 'Name', 'Enabled', 'RunContext' },
    LocalScript           = { 'Name', 'Enabled' },
    ModuleScript          = { 'Name' },
    IntValue              = { 'Name', 'Value' },
    NumberValue           = { 'Name', 'Value' },
    StringValue           = { 'Name', 'Value' },
    BoolValue             = { 'Name', 'Value' },
    ObjectValue           = { 'Name', 'Value' },
    Color3Value           = { 'Name', 'Value' },
    BrickColorValue       = { 'Name', 'Value' },
    Vector3Value          = { 'Name', 'Value' },
    CFrameValue           = { 'Name', 'Value' },
    RayValue              = { 'Name', 'Value' },
    IntConstrainedValue   = { 'Name', 'Value', 'MinValue', 'MaxValue' },
    DoubleConstrainedValue = { 'Name', 'Value', 'MinValue', 'MaxValue' },
    Sound                 = { 'Name', 'Volume', 'Playing', 'SoundId', 'TimePosition', 'Looped', 'PlaybackSpeed', 'RollOffMaxDistance', 'RollOffMinDistance', 'RollOffMode' },
    PointLight            = { 'Name', 'Enabled', 'Brightness', 'Color', 'Range', 'Shadows' },
    SpotLight             = { 'Name', 'Enabled', 'Brightness', 'Color', 'Range', 'Angle', 'Shadows', 'Face' },
    SurfaceLight          = { 'Name', 'Enabled', 'Brightness', 'Color', 'Range', 'Angle', 'Shadows', 'Face' },
    Frame                 = { 'Name', 'Visible', 'BackgroundColor3', 'BackgroundTransparency', 'BorderSizePixel', 'BorderColor3', 'Position', 'Size', 'AnchorPoint', 'ZIndex', 'LayoutOrder', 'Rotation', 'AutomaticSize', 'ClipsDescendants', 'Interactable', 'Selectable' },
    ScrollingFrame        = { 'Name', 'Visible', 'BackgroundColor3', 'BackgroundTransparency', 'Position', 'Size', 'CanvasSize', 'ScrollingDirection', 'ScrollBarThickness' },
    ScreenGui             = { 'Name', 'Enabled', 'ResetOnSpawn', 'ZIndexBehavior', 'DisplayOrder', 'IgnoreGuiInset' },
    BillboardGui          = { 'Name', 'Enabled', 'Size', 'StudsOffset', 'MaxDistance', 'AlwaysOnTop', 'Adornee' },
    SurfaceGui            = { 'Name', 'Enabled', 'Face', 'PixelsPerStud', 'AlwaysOnTop', 'Adornee' },
    ViewportFrame         = { 'Name', 'Visible', 'BackgroundColor3', 'BackgroundTransparency', 'Position', 'Size', 'Ambient', 'LightColor' },
    TextLabel             = { 'Name', 'Visible', 'Text', 'TextColor3', 'TextTransparency', 'TextSize', 'Font', 'FontFace', 'TextScaled', 'TextWrapped', 'RichText', 'TextXAlignment', 'TextYAlignment', 'LineHeight', 'MaxVisibleGraphemes', 'TextStrokeTransparency', 'TextStrokeColor3', 'AutoLocalize' },
    TextButton            = { 'Name', 'Visible', 'Text', 'TextColor3', 'TextTransparency', 'TextSize', 'Font', 'TextScaled', 'TextWrapped' },
    TextBox               = { 'Name', 'Visible', 'Text', 'TextColor3', 'TextTransparency', 'TextSize', 'Font', 'PlaceholderText', 'ClearTextOnFocus' },
    ImageLabel            = { 'Name', 'Visible', 'Image', 'ImageColor3', 'ImageTransparency', 'ScaleType', 'TileSize' },
    ImageButton           = { 'Name', 'Visible', 'Image', 'ImageColor3', 'ImageTransparency', 'ScaleType' },
    UIListLayout          = { 'Name', 'FillDirection', 'HorizontalAlignment', 'VerticalAlignment', 'SortOrder', 'Padding' },
    UIGridLayout          = { 'Name', 'CellPadding', 'CellSize', 'FillDirection', 'HorizontalAlignment', 'VerticalAlignment', 'SortOrder' },
    UITableLayout         = { 'Name', 'FillDirection', 'HorizontalAlignment', 'VerticalAlignment', 'SortOrder' },
    UIPageLayout          = { 'Name', 'Animated', 'Circular', 'EasingDirection', 'EasingStyle', 'Padding', 'TweenTime' },
    UIAspectRatioConstraint = { 'Name', 'AspectRatio', 'AspectType', 'DominantAxis' },
    UISizeConstraint      = { 'Name', 'MaxSize', 'MinSize' },
    UITextSizeConstraint  = { 'Name', 'MaxTextSize', 'MinTextSize' },
    UICorner              = { 'Name', 'CornerRadius' },
    UIGradient            = { 'Name', 'Color', 'Enabled', 'Offset', 'Rotation', 'Transparency' },
    UIPadding             = { 'Name', 'PaddingTop', 'PaddingBottom', 'PaddingLeft', 'PaddingRight' },
    UIScale               = { 'Name', 'Scale' },
    UIStroke              = { 'Name', 'Color', 'Enabled', 'Thickness', 'Transparency', 'ApplyStrokeMode', 'LineJoinMode' },
    RemoteEvent           = { 'Name' },
    RemoteFunction        = { 'Name' },
    BindableEvent         = { 'Name' },
    BindableFunction      = { 'Name' },
    Humanoid              = { 'Name', 'Health', 'MaxHealth', 'WalkSpeed', 'JumpPower', 'JumpHeight', 'HipHeight', 'AutoRotate', 'AutoJumpEnabled', 'UseJumpPower', 'DisplayName', 'MaxSlopeAngle', 'BrakeForceOnJump', 'HealthDisplayType', 'RigType', 'NameDisplayDistance', 'CameraOffset', 'BodyTypeScale', 'HeadScale', 'DepthScale', 'HeightScale', 'WidthScale', 'ProportionScale', 'MoveDirection' },
    HumanoidDescription   = { 'Name', 'HeadColor', 'TorsoColor', 'LeftArmColor', 'RightArmColor', 'LeftLegColor', 'RightLegColor' },
    Animation             = { 'Name', 'AnimationId' },
    ParticleEmitter       = { 'Name', 'Enabled', 'Rate', 'Lifetime', 'Speed', 'Color', 'Size', 'Transparency', 'Acceleration', 'Texture', 'SpreadAngle' },
    Beam                  = { 'Name', 'Enabled', 'Color', 'Transparency', 'Width0', 'Width1', 'CurveSize0', 'CurveSize1', 'Texture', 'TextureMode', 'TextureSpeed' },
    Trail                 = { 'Name', 'Enabled', 'Color', 'Transparency', 'Lifetime', 'MinLength', 'WidthScale', 'Texture', 'TextureMode' },
    Fire                  = { 'Name', 'Enabled', 'Color', 'SecondaryColor', 'Heat', 'Size' },
    Smoke                 = { 'Name', 'Enabled', 'Color', 'Opacity', 'RiseVelocity', 'Size' },
    Sparkles              = { 'Name', 'Enabled', 'SparkleColor' },
    Highlight             = { 'Name', 'Enabled', 'FillColor', 'FillTransparency', 'OutlineColor', 'OutlineTransparency', 'DepthMode', 'Adornee' },
    Decal                 = { 'Name', 'Texture', 'Transparency', 'Color3', 'Face' },
    Texture               = { 'Name', 'Texture', 'Transparency', 'Color3', 'Face', 'StudsPerTileU', 'StudsPerTileV' },
    Attachment            = { 'Name', 'Position', 'Orientation', 'Visible', 'WorldPosition', 'WorldOrientation' },
    Weld                  = { 'Name', 'Part0', 'Part1', 'C0', 'C1', 'Enabled' },
    WeldConstraint        = { 'Name', 'Part0', 'Part1', 'Enabled' },
    Motor6D               = { 'Name', 'Part0', 'Part1', 'C0', 'C1', 'CurrentAngle', 'MaxVelocity' },
    ProximityPrompt       = { 'Name', 'Enabled', 'ActionText', 'ObjectText', 'KeyboardKeyCode', 'HoldDuration', 'MaxActivationDistance', 'RequiresLineOfSight' },
    Tool                  = { 'Name', 'Enabled', 'CanBeDropped', 'RequiresHandle', 'ToolTip' },
    Camera                = { 'Name', 'CameraType', 'FieldOfView', 'CFrame', 'Focus', 'MaxZoomDistance', 'MinZoomDistance', 'CameraSubject', 'DiagonalFieldOfView', 'FieldOfViewMode' },
    Lighting              = { 'Name', 'Ambient', 'Brightness', 'ColorShift_Bottom', 'ColorShift_Top', 'OutdoorAmbient', 'ClockTime', 'GeographicLatitude', 'EnvironmentDiffuseScale', 'EnvironmentSpecularScale', 'ExposureCompensation', 'FogColor', 'FogEnd', 'FogStart', 'GlobalShadows', 'Technology', 'TimeOfDay' },
    Atmosphere            = { 'Name', 'Color', 'Decay', 'Density', 'Glare', 'Haze', 'Offset' },
    Sky                   = { 'Name', 'SkyboxBk', 'SkyboxDn', 'SkyboxFt', 'SkyboxLf', 'SkyboxRt', 'SkyboxUp', 'SunAngularSize', 'MoonAngularSize', 'StarCount', 'CelestialBodiesShown' },
    BloomEffect           = { 'Name', 'Enabled', 'Intensity', 'Size', 'Threshold' },
    BlurEffect            = { 'Name', 'Enabled', 'Size' },
    ColorCorrectionEffect = { 'Name', 'Enabled', 'Brightness', 'Contrast', 'Saturation', 'TintColor' },
    DepthOfFieldEffect    = { 'Name', 'Enabled', 'FarIntensity', 'FocusDistance', 'InFocusRadius', 'NearIntensity' },
    SunRaysEffect         = { 'Name', 'Enabled', 'Intensity', 'Spread' },
    Terrain               = { 'Name', 'Decoration', 'GrassLength', 'WaterColor', 'WaterReflectance', 'WaterTransparency', 'WaterWaveSize', 'WaterWaveSpeed' },
    RopeConstraint        = { 'Name', 'Enabled', 'Visible', 'Color', 'Thickness', 'Length', 'Restitution', 'WinchEnabled', 'WinchTarget', 'WinchForce', 'WinchSpeed' },
    SpringConstraint      = { 'Name', 'Enabled', 'Visible', 'Color', 'Thickness', 'Damping', 'MaxForce', 'Radius', 'Stiffness' },
    RodConstraint         = { 'Name', 'Enabled', 'Visible', 'Color', 'Thickness', 'Length' },
    PrismaticConstraint   = { 'Name', 'Enabled', 'Visible', 'Color', 'Thickness', 'ActuatorType', 'Speed', 'ServoMaxForce', 'LowerLimit', 'UpperLimit' },
    HingeConstraint       = { 'Name', 'Enabled', 'Visible', 'Color', 'Thickness', 'ActuatorType', 'AngularSpeed', 'MotorMaxTorque', 'ServoMaxTorque', 'LowerAngle', 'UpperAngle' },
    BallSocketConstraint  = { 'Name', 'Enabled', 'Visible', 'Color', 'Thickness', 'LimitsEnabled', 'TwistLimitsEnabled', 'Radius' },
    AlignPosition         = { 'Name', 'Enabled', 'ApplyAtCenterOfMass', 'MaxForce', 'MaxVelocity', 'ReactionForceEnabled', 'RigidityEnabled', 'Position', 'Responsiveness' },
    AlignOrientation      = { 'Name', 'Enabled', 'AlignTorque', 'MaxTorque', 'MaxAngularVelocity', 'ReactionTorqueEnabled', 'Responsiveness', 'PrimaryAxisOnly' },
    LinearVelocity        = { 'Name', 'Enabled', 'MaxForce', 'VectorVelocity', 'LineVelocity', 'LineDirection', 'RelativeTo' },
    AngularVelocity       = { 'Name', 'Enabled', 'MaxTorque', 'AngularVelocity', 'RelativeTo' },
    LineForce             = { 'Name', 'Enabled', 'ApplyAtCenterOfMass', 'InverseSquareLaw', 'Magnitude', 'MaxForce', 'ReactionForceEnabled' },
    VectorForce           = { 'Name', 'Enabled', 'ApplyAtCenterOfMass', 'Force', 'RelativeTo' },
    Torque                = { 'Name', 'Enabled', 'Torque', 'RelativeTo' },
    BodyPosition          = { 'Name', 'MaxForce', 'Position', 'P', 'D' },
    BodyGyro              = { 'Name', 'MaxTorque', 'CFrame', 'P', 'D' },
    BodyVelocity          = { 'Name', 'MaxForce', 'Velocity', 'P' },
    BodyAngularVelocity   = { 'Name', 'MaxTorque', 'AngularVelocity', 'P' },
    VideoFrame            = { 'Name', 'Visible', 'Video', 'Looped', 'Playing', 'TimePosition', 'Volume', 'BackgroundColor3', 'BackgroundTransparency', 'Position', 'Size', 'AnchorPoint', 'ZIndex' },
    CanvasGroup           = { 'Name', 'Visible', 'GroupColor3', 'GroupTransparency', 'BackgroundColor3', 'BackgroundTransparency', 'Position', 'Size', 'AnchorPoint', 'ZIndex', 'ClipsDescendants' },
}
local CLASS_PATTERNS = {
    { pattern = 'Value',      props = { 'Name', 'Value' } },
    { pattern = 'Part',       props = DEFAULT_PROPERTIES.BasePart },
    { pattern = 'Union',      props = DEFAULT_PROPERTIES.BasePart },
    { pattern = 'Mesh',       props = DEFAULT_PROPERTIES.BasePart },
    { pattern = 'Gui',        props = DEFAULT_PROPERTIES.Frame },
    { pattern = 'Frame',      props = DEFAULT_PROPERTIES.Frame },
    { pattern = 'Text',       props = DEFAULT_PROPERTIES.TextLabel },
    { pattern = 'Image',      props = DEFAULT_PROPERTIES.ImageLabel },
    { pattern = 'Video',      props = DEFAULT_PROPERTIES.ImageLabel },
    { pattern = 'Light',      props = DEFAULT_PROPERTIES.PointLight },
    { pattern = 'Constraint', props = { 'Name', 'Enabled', 'Visible' } },
    { pattern = 'Emitter',    props = DEFAULT_PROPERTIES.ParticleEmitter },
    { pattern = 'Particle',   props = DEFAULT_PROPERTIES.ParticleEmitter },
}
local VALUE_SERIALIZERS = {
string    = function(v) return v, 'string' end,
number    = function(v) return tostring(v), 'number' end,
boolean   = function(v) return tostring(v), 'boolean' end,
Instance  = function(v)
	local ok, path = pcall(function() return v:GetFullName() end)
	local cn = 'Instance'
	local ok2, c = pcall(function() return v.ClassName end)
	if ok2 and type(c) == 'string' then cn = c end
	return (ok and path or '[Instance]'), 'Instance', cn
end,
Font = function(v) return tostring(v), 'other' end,
FontFace = function(v) return tostring(v), 'other' end,
ColorSequence = function(v) return tostring(v), 'other' end,
NumberSequence = function(v) return tostring(v), 'other' end,
Content = function(v) return tostring(v), 'other' end,
DateTime = function(v) return tostring(v), 'other' end,
Rect = function(v) return tostring(v), 'other' end,
Region3 = function(v) return tostring(v), 'other' end,
Region3int16 = function(v) return tostring(v), 'other' end,
Vector3int16 = function(v) return tostring(v), 'other' end,
BinaryString = function(v)
	local ok, n = pcall(function() return #v end)
	return '[BinaryString len=' .. tostring(ok and n or 0) .. ']', 'other'
end,
Vector3   = function(v) return string.format('%.3f, %.3f, %.3f', v.X, v.Y, v.Z), 'Vector3' end,
Vector2   = function(v) return string.format('%.3f, %.3f', v.X, v.Y), 'Vector2' end,
CFrame    = function(v)
local c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12 = v:GetComponents()
local t = { c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12 }
local p = {}
for i = 1, 12 do p[i] = string.format('%.6g', t[i]) end
return table.concat(p, ', '), 'CFrame'
end,
Color3    = function(v) return string.format('%.3f, %.3f, %.3f', v.R, v.G, v.B), 'Color3' end,
BrickColor = function(v) return v.Name, 'BrickColor' end,
UDim      = function(v) return string.format('%.3f, %d', v.Scale, v.Offset), 'UDim' end,
UDim2     = function(v) return string.format('{%.3f, %d}, {%.3f, %d}', v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset), 'UDim2' end,
EnumItem  = function(v) return tostring(v), 'EnumItem' end,
PhysicalProperties = function(v)
return string.format('%.6g, %.6g, %.6g, %.6g, %.6g', v.Density, v.Friction, v.Elasticity, v.FrictionWeight, v.ElasticityWeight), 'PhysicalProperties'
end,
NumberRange = function(v) return string.format('%.6g, %.6g', v.Min, v.Max), 'NumberRange' end,
Ray = function(v)
return string.format('%.6g, %.6g, %.6g, %.6g, %.6g, %.6g', v.Origin.X, v.Origin.Y, v.Origin.Z, v.Direction.X, v.Direction.Y, v.Direction.Z), 'Ray'
end,
}
local VALUE_PARSERS = {
string  = function(v) return v end,
number  = function(v) return tonumber(v) end,
boolean = function(v) return v == 'true' end,
['nil'] = function() return nil end,
Vector3 = function(v)
local nums = {}
for part in v:gmatch('([^,]+)') do
	local n = tonumber((part:gsub('^%s*(.-)%s*$', '%1')))
	if n ~= nil then table.insert(nums, n) end
end
if #nums >= 3 then return Vector3.new(nums[1], nums[2], nums[3]) end
return nil
end,
CFrame = function(v)
local nums = {}
for part in v:gmatch('([^,]+)') do
	local n = tonumber((part:gsub('^%s*(.-)%s*$', '%1')))
	if n ~= nil then table.insert(nums, n) end
end
if #nums >= 12 then return CFrame.new(unpack(nums)) end
if #nums >= 3 then return CFrame.new(nums[1], nums[2], nums[3]) end
return nil
end,
PhysicalProperties = function(v)
local a, b, c, d, e = v:match('^%s*([^,]+)%s*,%s*([^,]+)%s*,%s*([^,]+)%s*,%s*([^,]+)%s*,%s*([^,]+)%s*$')
if a == nil then return nil end
return PhysicalProperties.new(tonumber(a), tonumber(b), tonumber(c), tonumber(d), tonumber(e))
end,
NumberRange = function(v)
local a, b = v:match('^%s*([^,]+)%s*,%s*([^,]+)%s*$')
if a == nil then return nil end
return NumberRange.new(tonumber(a), tonumber(b))
end,
Ray = function(v)
local nums = {}
for part in v:gmatch('([^,]+)') do
	local n = tonumber((part:gsub('^%s*(.-)%s*$', '%1')))
	if n ~= nil then table.insert(nums, n) end
end
if #nums >= 6 then return Ray.new(Vector3.new(nums[1], nums[2], nums[3]), Vector3.new(nums[4], nums[5], nums[6])) end
return nil
end,
Vector2 = function(v)
local x, y = v:match'([^,]+),%s*([^,]+)'
return Vector2.new(tonumber(x), tonumber(y))
end,
Color3 = function(v)
local r, g, b = v:match'([^,]+),%s*([^,]+),%s*([^,]+)'
return Color3.new(tonumber(r), tonumber(g), tonumber(b))
end,
BrickColor = function(v) return BrickColor.new(v) end,
UDim2 = function(v)
local xs, xo, ys, yo = v:match'{([^,]+),%s*([^}]+)},%s*{([^,]+),%s*([^}]+)}'
return UDim2.new(tonumber(xs), tonumber(xo), tonumber(ys), tonumber(yo))
end,
UDim = function(v)
local s, o = v:match'([^,]+),%s*([^,]+)'
return UDim.new(tonumber(s), tonumber(o))
end,
EnumItem = function(v)
local enumPath = v:match'Enum%.(.+)'
if enumPath == nil then return nil end
local parts = {}
for part in enumPath:gmatch'[^%.]+' do table.insert(parts, part) end
if #parts ~= 2 then return nil end
return Enum[parts[1]][parts[2]]
end,
}
local WebSocket = WebSocket
or (syn and syn.websocket)
or (Fluxus and Fluxus.websocket)
or (krnl and krnl.websocket)
or (Xeno and Xeno.websocket)
or websocket
local HttpRequest = request
or http_request
or syn_request
or (syn and syn.request)
or (http and http.request)
if WebSocket == nil then
	nativeWarn'[rbxdev-bridge] No WebSocket implementation found!'
	return
end
local executorName, executorVersion = (function()
if identifyexecutor == nil then return 'Unknown', '1.0' end
local name, version = identifyexecutor()
return name or 'Unknown', version or '1.0'
end)()
local connection = nil
local connected = false
local refreshConnections = {}
local bridgeAlive = true
local reconnectScheduled = false
local reconnectAttemptDelay = CONFIG.reconnectDelay
local healthProbeFailures = 0
local remoteSpyEnabled = false
local remoteSpyFilter = ''
local remoteSpyBlockedNames = {}
local remoteSpyBlockedPaths = {}
local spyCleanup = nil
local autoRefreshEnabled = false
local autoRefreshIntervalSec = 5.0
local autoRefreshDirty = false
local autoRefreshLastFlush = 0
local MIN_AUTO_REFRESH_INTERVAL_SEC = 2.0
local MAX_COALESCE_SEC = 30.0

if getgenv then
	getgenv()._UWUPAWZ_BRIDGE = {
	id = BRIDGE_ID,
	connection = nil,
	refreshConnections = refreshConnections,
	alive = true,
	nativePrint = nativePrint,
	nativeWarn = nativeWarn,
	}
end
local isBridgeAlive = function()
if getgenv == nil then return bridgeAlive end
local bridge = getgenv()._UWUPAWZ_BRIDGE
return bridge ~= nil and bridge.id == BRIDGE_ID and bridge.alive
end
-- HttpService:JSONEncode 对非法 UTF-8、userdata 等会失败；CoreGui 下名称/属性常见异常字节或未覆盖类型。
local jsonSafeString = function(s)
if type(s) ~= 'string' then
	s = tostring(s)
end
s = s:gsub("%z", ""):gsub("[%c]", function(c)
	if c == "\n" or c == "\t" or c == "\r" then return c end
	return ""
end)
if utf8 ~= nil and utf8.len ~= nil then
	local guard = 0
	while guard < 64 do
		guard = guard + 1
		local len, badPos = utf8.len(s)
		if len ~= nil then break end
		if type(badPos) ~= 'number' or badPos < 1 or badPos > #s then
			s = s:gsub("[\128-\255]", "?")
			break
		end
		s = s:sub(1, badPos - 1) .. "?" .. s:sub(badPos + 1)
	end
end
return s
end
local sanitizeForJson
sanitizeForJson = function(v, depth, seen)
depth = depth or 0
seen = seen or {}
if depth > 80 then return '[depth-limit]' end
local ty = typeof(v)
if v == nil or ty == 'nil' then
	return nil
end
if ty == 'string' then
	return jsonSafeString(v)
end
if ty == 'number' then
	if v ~= v or v == math.huge or v == -math.huge then return 0 end
	return v
end
if ty == 'boolean' then
	return v
end
if ty == 'function' then
	return '[function]'
end
if ty == 'table' then
	if seen[v] == true then return '[cycle]' end
	seen[v] = true
	local clean = {}
	local len = #v
	local count = 0
	for _ in pairs(v) do count = count + 1 end
	local isDenseArray = len > 0 and count == len
	if isDenseArray then
		for i = 1, len do
			local val = sanitizeForJson(v[i], depth + 1, seen)
			if val ~= nil then table.insert(clean, val) end
		end
	else
		local keyIdx = 0
		for k, val in pairs(v) do
			keyIdx = keyIdx + 1
			local cleanVal = sanitizeForJson(val, depth + 1, seen)
			if cleanVal ~= nil then
				local cleanKey
				if type(k) == 'string' then
					cleanKey = k:gsub("[^%w_]", "")
				else
					cleanKey = tostring(k)
				end
				if cleanKey == '' then cleanKey = '_k' .. tostring(keyIdx) end
				clean[cleanKey] = cleanVal
			end
		end
	end
	seen[v] = nil
	return clean
end
if ty == 'Instance' then
	local ok, path = pcall(function() return v:GetFullName() end)
	return jsonSafeString(ok and path or '[Instance]')
end
if ty == 'buffer' then
	return '[buffer]'
end
if ty == 'thread' then
	return '[thread]'
end
if ty == 'userdata' then
	local ok, s = pcall(tostring, v)
	return jsonSafeString(ok and s or '[userdata]')
end
local ok, s = pcall(tostring, v)
return jsonSafeString(ok and s or ('[' .. ty .. ']'))
end
-- 二次兜底：仍无法编码时把所有非 JSON 原生类型压成字符串（避免 CoreGui 等漏网之鱼）。
local bleachJsonValue
bleachJsonValue = function(v, depth)
depth = depth or 0
if depth > 100 then return '[depth]' end
local ty = typeof(v)
if v == nil or ty == 'nil' then return nil end
if ty == 'string' then return jsonSafeString(v) end
if ty == 'number' then
	if v ~= v or v == math.huge or v == -math.huge then return 0 end
	return v
end
if ty == 'boolean' then return v end
if ty == 'table' then
	local len = #v
	local count = 0
	for _ in pairs(v) do count = count + 1 end
	if len > 0 and count == len then
		local out = {}
		for i = 1, len do
			out[i] = bleachJsonValue(v[i], depth + 1)
		end
		return out
	end
	local out = {}
	local keyIdx = 0
	for k, val in pairs(v) do
		keyIdx = keyIdx + 1
		local cleanKey
		if type(k) == 'string' then
			cleanKey = jsonSafeString(k):gsub("[^%w_]", "")
		else
			cleanKey = 'k' .. tostring(k)
		end
		if cleanKey == '' then cleanKey = '_k' .. tostring(keyIdx) end
		out[cleanKey] = bleachJsonValue(val, depth + 1)
	end
	return out
end
local ok, s = pcall(tostring, v)
return jsonSafeString(ok and s or ('[' .. ty .. ']'))
end
local jsonEncode = function(data)
local safe = sanitizeForJson(data)
local ok, result = pcall(HttpService.JSONEncode, HttpService, safe)
if ok then return result end
nativeWarn('[rbxdev-bridge] JSONEncode failed (first pass): ' .. tostring(result))
local bleached = bleachJsonValue(safe, 0)
local ok2, result2 = pcall(HttpService.JSONEncode, HttpService, bleached)
if ok2 then return result2 end
nativeWarn('[rbxdev-bridge] JSONEncode failed (second pass): ' .. tostring(result2))
return nil
end
local jsonDecode = function(data)
local success, result = pcall(HttpService.JSONDecode, HttpService, data)
if not success then return nil end
return result
end
local getHealthUrl = function()
if type(CONFIG.healthUrl) == 'string' and CONFIG.healthUrl ~= '' then
	return CONFIG.healthUrl
end
local base = CONFIG.host:gsub('^wss://', 'https://'):gsub('^ws://', 'http://')
local origin = base:match'^(https?://[^/]+)'
if origin == nil then return nil end
return origin .. '/health'
end
local canAttemptConnect = function()
if CONFIG.enableHealthProbe == false or HttpRequest == nil then
	return true
end
local healthUrl = getHealthUrl()
if healthUrl == nil then
	return true
end
local ok, response = pcall(HttpRequest, {
Url = healthUrl,
Method = 'GET',
Headers = {
['Cache-Control'] = 'no-cache',
},
})
if not ok or type(response) ~= 'table' then
	healthProbeFailures = healthProbeFailures + 1
	return healthProbeFailures % 3 == 0
end
local statusCode = response.StatusCode or response.Status or response.status_code
if statusCode == 200 then
	healthProbeFailures = 0
	return true
end
healthProbeFailures = healthProbeFailures + 1
return healthProbeFailures % 3 == 0
end
local send = function(data)
if connection == nil or not connected then return end
local encoded = jsonEncode(data)
if encoded == nil then return end
if #encoded > 1000000 then
	nativeWarn("[rbxdev-bridge] Packet too large to send safely (" .. (#encoded/1024) .. " KB). Skipping.")
	return
end
if #encoded > 50000 then
	nativePrint(string.format("[rbxdev-bridge] Sending large packet: %.1f KB", #encoded / 1024))
end
local ok, err = pcall(function() connection:Send(encoded) end)
if not ok then
	nativeWarn("[rbxdev-bridge] Send failed: " .. tostring(err))
end
end
local sendResult = function(messageType, id, success, payload)
local result = { type = messageType, id = id, success = success }
for k, v in pairs(payload or {}) do result[k] = v end
send(result)
end
local resolveInstancePath = function(path)
local instance = game
for _, segment in ipairs(path) do
	local sep = segment:find("\0", 1, true)
	if sep then
		local name = segment:sub(1, sep - 1)
		local idx = tonumber(segment:sub(sep + 1))
		if idx == nil then return nil end
		local count = 0
		local found = nil
		for _, child in ipairs(instance:GetChildren()) do
			if child.Name == name then
				if count == idx then
					found = child
					break
				end
				count = count + 1
			end
		end
		if found == nil then return nil end
		instance = found
	else
		local ok, child = pcall(instance.FindFirstChild, instance, segment)
		if not ok or child == nil then return nil end
		instance = child
	end
end
return instance
end
local getInstancePath = function(instance)
local path = {}
local current = instance
while current ~= nil and current ~= game do
	table.insert(path, 1, current.Name)
	current = current.Parent
end
return path
end
local instanceToPath = function(instance)
if instance == nil then return 'nil' end
if instance == game then return 'game' end
local parts = {}
local current = instance
while current ~= nil and current ~= game do
	table.insert(parts, 1, current)
	current = current.Parent
end
if current == nil then
	return 'nil '
end
local out = ''
for i, part in ipairs(parts) do
	if i == 1 then
		local ok, service = pcall(game.FindService, game, part.ClassName)
		if ok and service ~= nil then
			out = part.ClassName == 'Workspace' and 'workspace' or ('game:GetService("' .. part.ClassName .. '")')
		elseif part.Name:match'^[%a_][%w_]*$' then
			out = 'game.' .. part.Name
		else
			out = 'game:FindFirstChild("' .. part.Name:gsub('\\', '\\\\'):gsub('"', '\\"') .. '")'
		end
	elseif part.Name:match'^[%a_][%w_]*$' then
		out = out .. '.' .. part.Name
	else
		out = out .. ':FindFirstChild("' .. part.Name:gsub('\\', '\\\\'):gsub('"', '\\"') .. '")'
	end
end
return out
end
local valueToLua
local tableToLua
valueToLua = function(v, depth, seen)
depth = depth or 0
seen = seen or {}
local t = typeof(v)
if v == nil then return 'nil' end
if t == 'boolean' then return tostring(v) end
if t == 'number' then
	if v ~= v then return '0/0' end
	if v == math.huge then return 'math.huge' end
	if v == -math.huge then return '-math.huge' end
	return tostring(v)
end
if t == 'string' then
	return '"' .. v:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t'):gsub('\0', '\\0') .. '"'
end
if t == 'Instance' then return instanceToPath(v) end
if t == 'Vector3'  then return string.format('Vector3.new(%s, %s, %s)', tostring(v.X), tostring(v.Y), tostring(v.Z)) end
if t == 'Vector2'  then return string.format('Vector2.new(%s, %s)', tostring(v.X), tostring(v.Y)) end
if t == 'CFrame' then
	local c = { v:GetComponents() }
	if c[4] == 1 and c[5] == 0 and c[6] == 0
		and c[7] == 0 and c[8] == 1 and c[9] == 0
		and c[10] == 0 and c[11] == 0 and c[12] == 1 then
		return string.format('CFrame.new(%s, %s, %s)', tostring(v.X), tostring(v.Y), tostring(v.Z))
	end
	local p = {}
	for _, comp in ipairs(c) do table.insert(p, tostring(comp)) end
	return 'CFrame.new(' .. table.concat(p, ', ') .. ')'
end
if t == 'Color3'     then return string.format('Color3.new(%s, %s, %s)', tostring(v.R), tostring(v.G), tostring(v.B)) end
if t == 'BrickColor' then return 'BrickColor.new("' .. v.Name .. '")' end
if t == 'UDim'       then return string.format('UDim.new(%s, %s)', tostring(v.Scale), tostring(v.Offset)) end
if t == 'UDim2'      then return string.format('UDim2.new(%s, %s, %s, %s)', tostring(v.X.Scale), tostring(v.X.Offset), tostring(v.Y.Scale), tostring(v.Y.Offset)) end
if t == 'Rect'       then return string.format('Rect.new(%s, %s, %s, %s)', tostring(v.Min.X), tostring(v.Min.Y), tostring(v.Max.X), tostring(v.Max.Y)) end
if t == 'Ray' then
	return string.format('Ray.new(Vector3.new(%s, %s, %s), Vector3.new(%s, %s, %s))',
	tostring(v.Origin.X), tostring(v.Origin.Y), tostring(v.Origin.Z),
	tostring(v.Direction.X), tostring(v.Direction.Y), tostring(v.Direction.Z))
end
if t == 'Region3' then
	local cf, size = v.CFrame, v.Size
	local min, max = cf.Position - size / 2, cf.Position + size / 2
	return string.format('Region3.new(Vector3.new(%s, %s, %s), Vector3.new(%s, %s, %s))',
	tostring(min.X), tostring(min.Y), tostring(min.Z),
	tostring(max.X), tostring(max.Y), tostring(max.Z))
end
if t == 'NumberSequence' then
	local kps = {}
	for _, kp in ipairs(v.Keypoints) do
		table.insert(kps, string.format('NumberSequenceKeypoint.new(%s, %s, %s)', tostring(kp.Time), tostring(kp.Value), tostring(kp.Envelope)))
	end
	return 'NumberSequence.new({' .. table.concat(kps, ', ') .. '})'
end
if t == 'ColorSequence' then
	local kps = {}
	for _, kp in ipairs(v.Keypoints) do
		table.insert(kps, string.format('ColorSequenceKeypoint.new(%s, Color3.new(%s, %s, %s))', tostring(kp.Time), tostring(kp.Value.R), tostring(kp.Value.G), tostring(kp.Value.B)))
	end
	return 'ColorSequence.new({' .. table.concat(kps, ', ') .. '})'
end
if t == 'NumberRange' then return string.format('NumberRange.new(%s, %s)', tostring(v.Min), tostring(v.Max)) end
if t == 'EnumItem'    then return tostring(v) end
if t == 'TweenInfo'   then return string.format('TweenInfo.new(%s, %s, %s, %s, %s, %s)', tostring(v.Time), tostring(v.EasingStyle), tostring(v.EasingDirection), tostring(v.RepeatCount), tostring(v.Reverses), tostring(v.DelayTime)) end
if t == 'table'       then return tableToLua(v, depth, seen) end
if t == 'function'    then return 'function() end' end
if t == 'thread'      then return 'nil' end
local ok, str = pcall(tostring, v)
if ok then return 'nil ' end
return 'nil '
end
tableToLua = function(t, depth, seen)
depth = depth or 0
seen = seen or {}
if depth > 5 then return '{}' end
if seen[t] then return '{}' end
seen[t] = true
local parts = {}
local arrayLen = #t
local isArray = arrayLen > 0
local indent = string.rep('    ', depth + 1)
local closingIndent = string.rep('    ', depth)
local count = 0
if isArray then
	for i = 1, arrayLen do
		count = count + 1
		if count > 50 then break end
		table.insert(parts, indent .. valueToLua(t[i], depth + 1, seen))
	end
end
for k, v in pairs(t) do
	if isArray and type(k) == 'number' and k >= 1 and k <= arrayLen and math.floor(k) == k then
		continue
	end
	count = count + 1
	if count > 50 then break end
	local keyStr
	if type(k) == 'string' and k:match'^[%a_][%w_]*$' then
		keyStr = k
	else
		keyStr = '[' .. valueToLua(k, depth + 1, seen) .. ']'
	end
	table.insert(parts, indent .. keyStr .. ' = ' .. valueToLua(v, depth + 1, seen))
end
seen[t] = nil
if #parts == 0 then return '{}' end
return '{\n' .. table.concat(parts, ',\n') .. '\n' .. closingIndent .. '}'
end
local generateRemoteCode = function(remote, method, ...)
local args = { ... }
local numArgs = select('#', ...)
local remotePath = instanceToPath(remote)
if numArgs == 0 then
	return remotePath .. ':' .. method .. '()'
end
local argParts = {}
local hasComplexArgs = false
for i = 1, numArgs do
	local t = typeof(args[i])
	if t == 'table' or t == 'CFrame' or t == 'NumberSequence' or t == 'ColorSequence' or t == 'TweenInfo' then
		hasComplexArgs = true
	end
	table.insert(argParts, valueToLua(args[i], hasComplexArgs and 1 or 0))
end
if not hasComplexArgs and numArgs <= 5 then
	return remotePath .. ':' .. method .. '(' .. table.concat(argParts, ', ') .. ')'
end
local indented = {}
for _, part in ipairs(argParts) do table.insert(indented, '    ' .. part) end
return remotePath .. ':' .. method .. '(\n' .. table.concat(indented, ',\n') .. '\n)'
end
local serializeArguments = function(...)
local args = { ... }
local parts = {}
for i = 1, select('#', ...) do table.insert(parts, valueToLua(args[i])) end
return table.concat(parts, ', ')
end
local rebuildRemoteSpyBlockMaps = function(blocks)
remoteSpyBlockedNames = {}
remoteSpyBlockedPaths = {}
if type(blocks) ~= 'table' then return end
for _, entry in ipairs(blocks) do
	if type(entry) ~= 'table' then continue end
	if type(entry.type) ~= 'string' or type(entry.value) ~= 'string' then continue end
	if entry.type == 'name' then
		remoteSpyBlockedNames[entry.value] = true
	elseif entry.type == 'path' then
		remoteSpyBlockedPaths[entry.value] = true
	end
end
end
local getRemoteBlockState = function(remote)
if typeof(remote) ~= 'Instance' then
	return false, '', {}
end
local remotePath = getInstancePath(remote)
local remotePathString = table.concat(remotePath, '.')
local remoteName = remote.Name
local blocked = remoteSpyBlockedNames[remoteName] == true or remoteSpyBlockedPaths[remotePathString] == true
return blocked, remoteName, remotePath
end
local tryExecutorPropertyList = function(instance)
local tryFns = {}
if type(getproperties) == 'function' then table.insert(tryFns, getproperties) end
if type(getprops) == 'function' then table.insert(tryFns, getprops) end
if type(syn) == 'table' and type(syn.get_properties) == 'function' then table.insert(tryFns, syn.get_properties) end
for _, fn in ipairs(tryFns) do
	local ok, plist = pcall(fn, instance)
	if ok and type(plist) == 'table' then
		local names = {}
		local seen = {}
		local function addName(n)
			if type(n) ~= 'string' or n == 'Parent' then return end
			if not seen[n] then seen[n] = true; table.insert(names, n) end
		end
		local count = 0
		for i = 1, #plist do
			local item = plist[i]
			if type(item) == 'string' then
				addName(item)
				count = count + 1
			elseif type(item) == 'table' and type(item.Name) == 'string' then
				addName(item.Name)
				count = count + 1
			end
		end
		if count == 0 then
			for k in pairs(plist) do
				if type(k) == 'string' then addName(k); count = count + 1 end
			end
		end
		if #names > 0 then
			table.sort(names)
			return names
		end
	end
end
return nil
end
local mergePropsForInstance = function(instance)
local fromExec = tryExecutorPropertyList(instance)
if fromExec ~= nil then return fromExec end
local names = {}
local seen = {}
local function addProp(n)
	if type(n) ~= 'string' or n == 'Parent' then return end
	if not seen[n] then seen[n] = true; table.insert(names, n) end
end
local classes = {}
for className in pairs(DEFAULT_PROPERTIES) do
	if instance:IsA(className) then table.insert(classes, className) end
end
table.sort(classes)
for _, className in ipairs(classes) do
	for _, p in ipairs(DEFAULT_PROPERTIES[className]) do addProp(p) end
end
local cn = instance.ClassName
for _, entry in ipairs(CLASS_PATTERNS) do
	if cn:find(entry.pattern) ~= nil then
		for _, p in ipairs(entry.props) do addProp(p) end
	end
end
if #names == 0 then
	addProp('Name')
	addProp('ClassName')
end
if #names > 1 then table.sort(names) end
return names
end
local serializePropertyValue = function(name, value)
local ok, result = pcall(function()
	if value == nil then return { name = name, value = 'nil', valueType = 'nil' } end
	local valueType = typeof(value)
	local serializer = VALUE_SERIALIZERS[valueType]
	if serializer == nil then
		local tsOk, ts = pcall(tostring, value)
		return { name = name, value = tsOk and ts or ('[' .. valueType .. ']'), valueType = 'other' }
	end
	local serializedValue, typeName, className = serializer(value)
	local out = { name = name, value = serializedValue, valueType = typeName }
	if className ~= nil then out.className = className end
	return out
end)
if ok and type(result) == 'table' then return result end
return { name = name, value = '[read error]', valueType = 'other' }
end
local parseValue = function(value, valueType)
local parser = VALUE_PARSERS[valueType]
if parser == nil then return value end
return parser(value)
end
local parseError = function(errorString)
local file, line, message = errorString:match'(%S+):(%d+): (.+)'
return {
message = message or errorString,
file = file,
line = line and tonumber(line) or nil,
}
end
local getInstanceProperties = function(instance, requestedProps)
    local props = {}
    local propsToGet = requestedProps or mergePropsForInstance(instance)

    -- Basic properties
    for _, propName in ipairs(propsToGet) do
        local ok, value = pcall(function() return instance[propName] end)
        if ok then table.insert(props, serializePropertyValue(propName, value)) end
    end

    -- Attributes
    local ok, attributes = pcall(instance.GetAttributes, instance)
    if ok and attributes then
        for attrName, attrValue in pairs(attributes) do
            local serialized = serializePropertyValue("[Attr] " .. attrName, attrValue)
            table.insert(props, serialized)
        end
    end

    return props
end
local function serializeInstance(instance: Instance, depth: number): table?
if depth <= 0 then return nil end
local ok, name = pcall(function() return instance.Name end)
local ok2, className = pcall(function() return instance.ClassName end)
if not (ok and ok2) then return nil end
local function cleanString(s: string): string
if type(s) ~= 'string' then return 'UnnamedInstance' end
return jsonSafeString(s)
end
local node = { name = cleanString(name), className = cleanString(className) }
local ok3, children = pcall(instance.GetChildren, instance)
if not ok3 or not children then
	return node
end
if depth == 1 and #children > 0 then
	node.hasChildren = true
	return node
end
if #children > 0 then
	local serialized = {}
	for _, child in ipairs(children) do
		local childNode = serializeInstance(child, depth - 1)
		if childNode then table.insert(serialized, childNode) end
	end
	if #serialized > 0 then node.children = serialized end
end
return node
end
local getChildrenAtPath = function(path, depth)
local instance = resolveInstancePath(path)
if instance == nil then return nil end
local result = {}
for _, child in ipairs(instance:GetChildren()) do
	local childNode = serializeInstance(child, depth)
	if childNode ~= nil then table.insert(result, childNode) end
end
return result
end
local function getGameTree(services: {string}?, depth: number?): table
local tree = {}
local treeDepth = depth or CONFIG.updateTreeDepth
local added = {}
nativePrint("[rbxdev-bridge] Serializing game tree, depth:", treeDepth)
for _, serviceName in ipairs(services or CONFIG.gameTreeServices) do
	local ok, service = pcall(game.GetService, game, serviceName)
	if ok and service then
		local okS, node = pcall(serializeInstance, service, treeDepth)
		if okS and node then
			table.insert(tree, node)
			added[service] = true
		end
	end
end
nativePrint("[rbxdev-bridge] Root services serialized:", #tree)
return tree
end
local getTargetPosition = function(instance)
if instance:IsA'Player' then
	local char = instance.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then return root.Position + Vector3.new(0, 5, 0) end
	error"Player character not found"
end
if instance:IsA'BasePart' then return instance.Position + Vector3.new(0, 5, 0) end
if instance:IsA'Model' then
	local primaryPart = instance.PrimaryPart
	if primaryPart ~= nil then return primaryPart.Position + Vector3.new(0, 5, 0) end
	local part = instance:FindFirstChildWhichIsA('BasePart', true)
	if part ~= nil then return part.Position + Vector3.new(0, 5, 0) end
	error'Model has no parts to teleport to'
end
if instance:IsA'Attachment' then return instance.WorldPosition + Vector3.new(0, 5, 0) end
error('Cannot teleport to ' .. instance.ClassName)
end
local reflectModuleInterface = function(module)
local moduleType = type(module)
local interface = { kind = moduleType }
if moduleType == 'function' then
	local info = debug.getinfo(module, 'u')
	interface.functionArity = info and info.nparams or 0
	return interface
end
if moduleType == 'table' then
	local props = {}
	for key, value in pairs(module) do
		if type(key) ~= 'string' then continue end
		local prop = { name = key, valueKind = type(value) }
		if type(value) == 'function' then
			local info = debug.getinfo(value, 'u')
			prop.functionArity = info and info.nparams or 0
		end
		table.insert(props, prop)
	end
	interface.properties = props
	return interface
end
interface.kind = 'other'
return interface
end
local markAutoRefreshDirty = function()
	autoRefreshDirty = true
end
local attachAutoRefreshListeners
local detachAutoRefreshListeners
attachAutoRefreshListeners = function(instance)
	local addedConn = instance.DescendantAdded:Connect(markAutoRefreshDirty)
	local removingConn = instance.DescendantRemoving:Connect(markAutoRefreshDirty)
	table.insert(refreshConnections, addedConn)
	table.insert(refreshConnections, removingConn)
end
detachAutoRefreshListeners = function()
	for i = #refreshConnections, 1, -1 do
		refreshConnections[i] = nil
	end
end
local shutdownAutoRefresh = function()
	autoRefreshEnabled = false
	detachAutoRefreshListeners()
end
local autoRefreshHeartbeatTick = function()
	if not autoRefreshEnabled or not connected or not autoRefreshDirty then return end
	local now = os.clock()
	local elapsed = now - autoRefreshLastFlush
	if elapsed >= autoRefreshIntervalSec or elapsed >= MAX_COALESCE_SEC then
		autoRefreshDirty = false
		autoRefreshLastFlush = now
		local ok, tree = pcall(getGameTree, nil, CONFIG.updateTreeDepth)
		if ok then send{ type = 'gameTree', data = tree } end
	end
end
local setAutoRefresh = function(enabled, intervalMs)
	shutdownAutoRefresh()
	autoRefreshEnabled = enabled
	if enabled then
		autoRefreshIntervalSec = math.max(MIN_AUTO_REFRESH_INTERVAL_SEC, (intervalMs or 5000) / 1000)
		for _, serviceName in ipairs(CONFIG.gameTreeServices) do
			local ok, service = pcall(game.GetService, game, serviceName)
			if ok and service then attachAutoRefreshListeners(service) end
		end
		local autoRefreshHeartbeat = RunService.Heartbeat:Connect(autoRefreshHeartbeatTick)
		local autoRefreshTopLevel = game.ChildAdded:Connect(function(child)
			if table.find(CONFIG.gameTreeServices, child.Name) then
				attachAutoRefreshListeners(child)
				markAutoRefreshDirty()
			end
		end)
		table.insert(refreshConnections, autoRefreshHeartbeat)
		table.insert(refreshConnections, autoRefreshTopLevel)
	end
end
-- Dex 风格：SelectionBox 线框（非 Highlight 填充）；挂 Workspace 避免 CoreGui/gethui 下闪退。
local selectionAdorns = {}
local MAX_SELECTION_BOXES = 100
local function clearSelectionAdorns()
	for _, ad in ipairs(selectionAdorns) do
		if ad ~= nil then
			pcall(function()
				ad:Destroy()
			end)
		end
	end
	selectionAdorns = {}
end
local MESSAGE_HANDLERS = {}
MESSAGE_HANDLERS.selectInstance = function(message)
	clearSelectionAdorns()
	local okRun, errRun = pcall(function()
		local path = message.path
		if type(path) ~= 'table' or #path == 0 then return end
		local instance = resolveInstancePath(path)
		if instance == nil then return end
		local alive = pcall(function()
			return instance.Parent
		end)
		if not alive then return end
		local okPv, isPv = pcall(function()
			return instance:IsA('PVInstance')
		end)
		if not okPv or isPv ~= true then return end
		local adornParent = workspace
		local dexOrange = Color3.fromRGB(255, 178, 64)
		local function tryAddBox(adornee)
			if adornee == nil or #selectionAdorns >= MAX_SELECTION_BOXES then return false end
			local ok, box = pcall(function()
				local b = Instance.new('SelectionBox')
				b.Name = '_UwUPawzSelection'
				b.Adornee = adornee
				b.LineThickness = 0.05
				b.SurfaceTransparency = 1
				b.Color3 = dexOrange
				b.Parent = adornParent
				return b
			end)
			if ok and box ~= nil then
				table.insert(selectionAdorns, box)
				return true
			end
			return false
		end
		if tryAddBox(instance) then return end
		local okM, isModel = pcall(function()
			return instance:IsA('Model')
		end)
		if not okM or isModel ~= true then return end
		local okDesc, desc = pcall(function()
			return instance:GetDescendants()
		end)
		if not okDesc or type(desc) ~= 'table' then return end
		for _, d in ipairs(desc) do
			if #selectionAdorns >= MAX_SELECTION_BOXES then break end
			local okBp, isBp = pcall(function()
				return d:IsA('BasePart')
			end)
			if okBp and isBp == true then tryAddBox(d) end
		end
	end)
	if not okRun then nativeWarn('[rbxdev-bridge] selectInstance: ' .. tostring(errRun)) end
end

MESSAGE_HANDLERS.fireRemote = function(message)
	local instance = resolveInstancePath(message.path)
	if instance == nil or not (instance:IsA('RemoteEvent') or instance:IsA('UnreliableRemoteEvent')) then
		sendResult('fireRemoteResult', message.id, false, { error = 'RemoteEvent not found' })
		return
	end
	local ok, err = pcall(function()
		instance:FireServer(unpack(message.arguments or {}))
	end)
	sendResult('fireRemoteResult', message.id, ok, { error = not ok and tostring(err) or nil })
end

MESSAGE_HANDLERS.invokeRemote = function(message)
	local instance = resolveInstancePath(message.path)
	if instance == nil or not instance:IsA('RemoteFunction') then
		sendResult('invokeRemoteResult', message.id, false, { error = 'RemoteFunction not found' })
		return
	end
	local ok, result = pcall(function()
		return instance:InvokeServer(unpack(message.arguments or {}))
	end)
	sendResult('invokeRemoteResult', message.id, ok, { 
		result = ok and serializeArguments(result) or nil,
		error = not ok and tostring(result) or nil 
	})
end
MESSAGE_HANDLERS.setAutoRefresh = function(message)
	setAutoRefresh(message.enabled, message.intervalMs)
end
MESSAGE_HANDLERS.execute = function(message)
local fn, loadError = loadstring(message.code)
if fn == nil then
	sendResult('executeResult', message.id, false, { error = parseError(tostring(loadError)) })
	return
end
local ok, result = pcall(fn)
if not ok then
	sendResult('executeResult', message.id, false, { error = parseError(tostring(result)) })
	return
end
sendResult('executeResult', message.id, true, { result = result ~= nil and tostring(result) or nil })
end
MESSAGE_HANDLERS.requestGameTree = function(message)
local depth = message.depth or CONFIG.updateTreeDepth
send{ type = 'gameTree', data = getGameTree(message.services, depth) }
end
MESSAGE_HANDLERS.requestChildren = function(message)
local children = getChildrenAtPath(message.path, message.depth or CONFIG.expandedTreeDepth)
if children == nil then
	sendResult('childrenResult', message.id, false, { error = 'Instance not found at: ' .. table.concat(message.path, '.') })
	return
end
sendResult('childrenResult', message.id, true, { path = message.path, children = children })
end
MESSAGE_HANDLERS.requestProperties = function(message)
local instance = resolveInstancePath(message.path)
if instance == nil then
	sendResult('propertiesResult', message.id, false, { error = 'Instance not found at: ' .. table.concat(message.path, '.') })
	return
end
sendResult('propertiesResult', message.id, true, { properties = getInstanceProperties(instance, message.properties) })
end
MESSAGE_HANDLERS.requestModuleInterface = function(message)
local moduleRef = message.moduleRef
local module = nil
if moduleRef.kind == 'path' then
	local instance = resolveInstancePath(moduleRef.path)
	if instance == nil then
		sendResult('moduleInterface', message.id, false, { error = 'Module not found at: ' .. table.concat(moduleRef.path, '.') })
		return
	end
	if not instance:IsA'ModuleScript' then
		sendResult('moduleInterface', message.id, false, { error = 'Instance is not a ModuleScript' })
		return
	end
	local ok, result = pcall(require, instance)
	if not ok then
		sendResult('moduleInterface', message.id, false, { error = tostring(result) })
		return
	end
	module = result
elseif moduleRef.kind == 'assetId' then
	local ok, result = pcall(require, moduleRef.id)
	if not ok then
		sendResult('moduleInterface', message.id, false, { error = tostring(result) })
		return
	end
	module = result
end
if module == nil then
	sendResult('moduleInterface', message.id, false, { error = 'Failed to load module' })
	return
end
sendResult('moduleInterface', message.id, true, { interface = reflectModuleInterface(module) })
end
MESSAGE_HANDLERS.setProperty = function(message)
    local instance = resolveInstancePath(message.path)
    if instance == nil then
        sendResult('setPropertyResult', message.id, false, { error = 'Instance not found at: ' .. table.concat(message.path, '.') })
        return
    end

    local propertyName = message.property
    local attrName = propertyName:match("^%[Attr%]%s+(.+)$")

    local ok, err
    if attrName then
        ok, err = pcall(function()
            instance:SetAttribute(attrName, parseValue(message.value, message.valueType))
        end)
    else
        ok, err = pcall(function()
            instance[propertyName] = parseValue(message.value, message.valueType)
        end)
    end

    if not ok then
        sendResult('setPropertyResult', message.id, false, { error = tostring(err) })
        return
    end
    sendResult('setPropertyResult', message.id, true)
end
MESSAGE_HANDLERS.teleportTo = function(message)
local instance = resolveInstancePath(message.path)
if instance == nil then
	sendResult('teleportToResult', message.id, false, { error = 'Instance not found at: ' .. table.concat(message.path, '.') })
	return
end
local ok, err = pcall(function()
local player = Players.LocalPlayer
if player == nil then error'No local player' end
local character = player.Character
if character == nil then error'No character' end
local hrp = character:FindFirstChild'HumanoidRootPart'
if hrp == nil then error'No HumanoidRootPart' end
hrp.CFrame = CFrame.new(getTargetPosition(instance))
end)
if not ok then
	sendResult('teleportToResult', message.id, false, { error = tostring(err) })
	return
end
sendResult('teleportToResult', message.id, true)
end
MESSAGE_HANDLERS.deleteInstance = function(message)
local instance = resolveInstancePath(message.path)
if instance == nil then
	sendResult('deleteInstanceResult', message.id, false, { error = 'Instance not found at: ' .. table.concat(message.path, '.') })
	return
end
local ok, err = pcall(instance.Destroy, instance)
if not ok then
	sendResult('deleteInstanceResult', message.id, false, { error = tostring(err) })
	return
end
sendResult('deleteInstanceResult', message.id, true)
end
MESSAGE_HANDLERS.dumpModule = function(message)
local instance = resolveInstancePath(message.path)
if not (instance and instance:IsA"ModuleScript") then
	sendResult("dumpModuleResult", message.id, false, { error = "Module not found" })
	return
end
local ok, result = pcall(require, instance)
if not ok then
	sendResult("dumpModuleResult", message.id, false, { error = tostring(result) })
	return
end
local dumped = tableToLua(result)
sendResult("dumpModuleResult", message.id, true, { data = dumped })
end
MESSAGE_HANDLERS.decompileScript = function(message)
local instance = resolveInstancePath(message.path)
if not instance then
	sendResult("decompileResult", message.id, false, { error = "Script not found" })
	return
end
local decompiler = decompile or (syn and syn.decompile) or (Fluxus and Fluxus.decompile) or (GetExecutor and GetExecutor().decompile)
if not decompiler then
	sendResult("decompileResult", message.id, false, { error = "Decompiler not supported" })
	return
end
local ok, source = pcall(decompiler, instance)
if not ok then
	sendResult("decompileResult", message.id, false, { error = tostring(source) })
	return
end
sendResult("decompileResult", message.id, true, { data = source })
end
MESSAGE_HANDLERS.reparentInstance = function(message)
local source = resolveInstancePath(message.sourcePath)
if source == nil then
	sendResult('reparentInstanceResult', message.id, false, { error = 'Source not found at: ' .. table.concat(message.sourcePath, '.') })
	return
end
local target = resolveInstancePath(message.targetPath)
if target == nil then
	sendResult('reparentInstanceResult', message.id, false, { error = 'Target not found at: ' .. table.concat(message.targetPath, '.') })
	return
end
local ok, err = pcall(function() source.Parent = target end)
if not ok then
	sendResult('reparentInstanceResult', message.id, false, { error = tostring(err) })
	return
end
sendResult('reparentInstanceResult', message.id, true)
end
MESSAGE_HANDLERS.requestScriptSource = function(message)
local instance = resolveInstancePath(message.path)
if instance == nil then
	sendResult('scriptSourceResult', message.id, false, { error = 'Instance not found at: ' .. table.concat(message.path, '.') })
	return
end
if not (instance:IsA'LocalScript' or instance:IsA'ModuleScript' or instance:IsA'Script') then
	sendResult('scriptSourceResult', message.id, false, { error = instance.ClassName .. ' is not a script type' })
	return
end
local decompilerFunc = decompile or decompilescript or getscriptsource or getsourcescript or get_script_source or nil
if decompilerFunc == nil then
	sendResult('scriptSourceResult', message.id, false, { error = 'No decompiler available in this executor' })
	return
end
local ok, source = pcall(decompilerFunc, instance)
if not ok then
	sendResult('scriptSourceResult', message.id, false, { error = 'Decompilation failed: ' .. tostring(source) })
	return
end
sendResult('scriptSourceResult', message.id, true, { source = source, scriptType = instance.ClassName })
end
MESSAGE_HANDLERS.createInstance = function(message)
local parent = resolveInstancePath(message.parentPath)
if parent == nil then
	sendResult('createInstanceResult', message.id, false, { error = 'Parent not found at: ' .. table.concat(message.parentPath, '.') })
	return
end
local ok, result = pcall(function()
local inst = Instance.new(message.className)
if message.name ~= nil then inst.Name = message.name end
inst.Parent = parent
return inst.Name
end)
if not ok then
	sendResult('createInstanceResult', message.id, false, { error = tostring(result) })
	return
end
sendResult('createInstanceResult', message.id, true, { instanceName = result })
end
MESSAGE_HANDLERS.cloneInstance = function(message)
local instance = resolveInstancePath(message.path)
if instance == nil then
	sendResult('cloneInstanceResult', message.id, false, { error = 'Instance not found at: ' .. table.concat(message.path, '.') })
	return
end
local ok, result = pcall(function()
local clone = instance:Clone()
if clone == nil then error('Instance cannot be cloned') end
clone.Parent = instance.Parent
return clone.Name
end)
if not ok then
	sendResult('cloneInstanceResult', message.id, false, { error = tostring(result) })
	return
end
sendResult('cloneInstanceResult', message.id, true, { cloneName = result })
end
MESSAGE_HANDLERS.setRemoteSpyEnabled = function(message)
if oth == nil and hookmetamethod == nil then
	sendResult('setRemoteSpyEnabledResult', message.id, false, { error = 'No hooking method available in this executor' })
	return
end
local ok, err = pcall(function()
if message.enabled and not remoteSpyEnabled then
	local logRemoteCall = function(self, method, blocked, remoteName, remotePath, ...)
	local args = { ... }
	pcall(function()
	if not remoteSpyEnabled or not connected then return end
	if typeof(self) ~= 'Instance' then return end
	local className = self.ClassName
	if className ~= 'RemoteEvent' and className ~= 'RemoteFunction' and className ~= 'UnreliableRemoteEvent' then return end
	if blocked ~= true and remoteSpyFilter ~= '' and remoteName:lower():find(remoteSpyFilter:lower()) == nil then return end
	send({
	type = 'remoteSpy',
	call = {
	remoteName = remoteName,
	remotePath = remotePath,
	remoteType = className,
	method = method,
	arguments = serializeArguments(unpack(args)),
	code = generateRemoteCode(self, method, unpack(args)),
	timestamp = os.time(),
	_blocked = blocked == true,
	},
	})
end)
end
if oth ~= nil and type(oth.hook) == 'function' then
	local mt = getrawmetatable(game)
	local ncFunc = rawget(mt, '__namecall')
	local oldNamecall
	oldNamecall = oth.hook(ncFunc, function(self, ...)
	local method = getnamecallmethod()
	if method == 'FireServer' or method == 'InvokeServer' then
		local blocked, remoteName, remotePath = getRemoteBlockState(self)
		logRemoteCall(self, method, blocked, remoteName, remotePath, ...)
		if blocked then
			setnamecallmethod(method)
			return nil
		end
	end
	setnamecallmethod(method)
	return oldNamecall(self, ...)
end)
spyCleanup = function()
if type(oth.unhook) == 'function' then
	oth.unhook(ncFunc)
else
	oth.hook(ncFunc, oldNamecall)
end
end
nativePrint'[rbxdev-bridge] Remote spy enabled (oth)'
else
	local oldNamecall
	oldNamecall = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
	local method = getnamecallmethod()
	if method == 'FireServer' or method == 'InvokeServer' then
		local blocked, remoteName, remotePath = getRemoteBlockState(self)
		logRemoteCall(self, method, blocked, remoteName, remotePath, ...)
		if blocked then
			setnamecallmethod(method)
			return nil
		end
	end
	setnamecallmethod(method)
	return oldNamecall(self, ...)
end))
spyCleanup = function()
hookmetamethod(game, '__namecall', oldNamecall)
end
nativePrint'[rbxdev-bridge] Remote spy enabled (hookmetamethod)'
end
remoteSpyEnabled = true
elseif not message.enabled and remoteSpyEnabled then
	if spyCleanup ~= nil then
		pcall(spyCleanup)
		spyCleanup = nil
	end
	remoteSpyEnabled = false
	nativePrint'[rbxdev-bridge] Remote spy disabled'
end
end)
if not ok then
	sendResult('setRemoteSpyEnabledResult', message.id, false, { error = tostring(err) })
	return
end
sendResult('setRemoteSpyEnabledResult', message.id, true, { enabled = remoteSpyEnabled })
end
MESSAGE_HANDLERS.setRemoteSpyFilter = function(message)
remoteSpyFilter = message.filter or ''
sendResult('setRemoteSpyFilterResult', message.id, true)
end
MESSAGE_HANDLERS.setRemoteSpyBlockList = function(message)
rebuildRemoteSpyBlockMaps(message.blocks)
sendResult('setRemoteSpyBlockListResult', message.id, true)
end
local handleMessage = function(rawMessage)
local message = jsonDecode(rawMessage)
if message == nil then return end
local handler = MESSAGE_HANDLERS[message.type]
if handler == nil then return end
handler(message)
end
local setupLogHooks = function()
if not (getgenv and getgenv()._RBXDEV_LOG_HOOKED) then
	LogService.MessageOut:Connect(function(message, messageType)
		if not connected then return end
		local level = "info"
		if messageType == Enum.MessageType.MessageError then
			level = "error"
		elseif messageType == Enum.MessageType.MessageWarning then
			level = "warn"
		end
		pcall(send, {
			type = "log",
			level = level,
			message = typeof(message) == "string" and message or tostring(message),
			timestamp = os.time(),
		})
	end)
	if getgenv then getgenv()._RBXDEV_LOG_HOOKED = true end
end
if CONFIG.suppressGameConsoleLog then
	local outHooked = (getgenv and getgenv()._RBXDEV_OUTPUT_HOOKED) or _G._RBXDEV_OUTPUT_HOOKED
	if not outHooked then
		local function formatPrintArgs(...)
			local n = select('#', ...)
			local t = {}
			for i = 1, n do
				t[i] = tostring(select(i, ...))
			end
			return table.concat(t, '\t')
		end
		_G.print = function(...)
			nativePrint(...)
		end
		_G.warn = function(...)
			nativeWarn(...)
		end
		if getgenv then getgenv()._RBXDEV_OUTPUT_HOOKED = true end
		_G._RBXDEV_OUTPUT_HOOKED = true
	end
end
end
local connect
local scheduleReconnect
scheduleReconnect = function()
if reconnectScheduled or connected or not isBridgeAlive() then return end
reconnectScheduled = true
local delay = math.max(0, reconnectAttemptDelay or CONFIG.reconnectDelay or 0)
task.delay(delay, function()
reconnectScheduled = false
if connected or not isBridgeAlive() then return end
local connectState = connect(false)
if connectState == 'connected' then
	reconnectAttemptDelay = CONFIG.reconnectDelay
	return
end
if connectState == 'blocked' then
	scheduleReconnect()
	return
end
local nextDelay = reconnectAttemptDelay
if nextDelay == nil or nextDelay <= 0 then
	nextDelay = CONFIG.reconnectDelay
elseif nextDelay < CONFIG.reconnectDelayMax then
	nextDelay = math.min(nextDelay * 2, CONFIG.reconnectDelayMax)
end
reconnectAttemptDelay = nextDelay
scheduleReconnect()
end)
end
connect = function(scheduleOnFailure)
if not isBridgeAlive() then return false end
if scheduleOnFailure == nil then scheduleOnFailure = true end
if not canAttemptConnect() then
	if scheduleOnFailure then
		scheduleReconnect()
	end
	return 'blocked'
end
local ok, ws = pcall(WebSocket.connect, CONFIG.host)
if not ok or ws == nil then
	if scheduleOnFailure then
		scheduleReconnect()
	end
	return 'failed'
end
connection = ws
connected = true
reconnectScheduled = false
reconnectAttemptDelay = CONFIG.reconnectDelay
healthProbeFailures = 0
if getgenv and getgenv()._UWUPAWZ_BRIDGE then
	getgenv()._UWUPAWZ_BRIDGE.connection = ws
end
send{ type = 'connected', executorName = executorName, version = executorVersion }
send{ type = 'gameTree', data = getGameTree(nil, CONFIG.firstConnectDepth) }
ws.OnMessage:Connect(handleMessage)
ws.OnClose:Connect(function()
	connected = false
	connection = nil
	clearSelectionAdorns()
	shutdownAutoRefresh()
	scheduleReconnect()
end)
return 'connected'
end
task.defer(connect)
setupLogHooks()
