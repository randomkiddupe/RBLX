local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer

local NPCFolder = Workspace.Custom:FindFirstChild("-1") or Workspace.Custom:FindFirstChild("1")

if not getgenv().Config then
getgenv().Config = {
	CircleVisible = true,
	CircleTransparency = 1,
	CircleColor = Color3.fromRGB(255,128,64),
	CircleThickness = 1,
	CircleNumSides = 30,
	CircleFilled = false,

	SilentAim = true,
	TeamCheck = false,
	FieldOfView = 100,
	TargetMode = "NPC",
	AimHitbox = "Head",
	Wallcheck = false
}
end

local UIConfig = {
    WindowName = "Blackhawk Rescue Mission 5",
	Color = Color3.fromRGB(255,128,64),
	Keybind = Enum.KeyCode.RightShift
}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/randomkiddupe/RBLX/main/Brckt.lua"))()
local Window = Library:CreateWindow(UIConfig, game:GetService("CoreGui"))

local MainTab = Window:CreateTab("Main")
local UITab = Window:CreateTab("UI Settings")

local AimbotSection = MainTab:CreateSection("Aimbot")
local CircleSection = MainTab:CreateSection("Circle")
local MenuSection = UITab:CreateSection("Menu")
local BackgroundSection = UITab:CreateSection("Background")

local SilentAimToggle = AimbotSection:CreateToggle("Silent Aim", nil, function(State)
	Config.SilentAim = State
end)
SilentAimToggle:SetState(Config.SilentAim)

local TeamCheckToggle = AimbotSection:CreateToggle("Team Check", nil, function(State)
	Config.TeamCheck = State
end)
TeamCheckToggle:SetState(Config.TeamCheck)

local WallcheckToggle = AimbotSection:CreateToggle("Wallcheck", nil, function(State)
	Config.Wallcheck = State
end)
WallcheckToggle:SetState(Config.Wallcheck)

local FoVSlider = AimbotSection:CreateSlider("Field Of View", 0,1000,nil,true, function(Value)
	Config.FieldOfView = Value
end)
FoVSlider:SetValue(Config.FieldOfView)

local TargetDropdown = AimbotSection:CreateDropdown("Target", {"NPC","Player"}, function(String)
	if String == "NPC" then
		Config.TargetMode = "NPC"
	elseif String == "Player" then
		Config.TargetMode = "Player"
	end
end, Config.TargetMode)

local AimHitboxDropdown = AimbotSection:CreateDropdown("Aim Hitbox", {"Head","Torso"}, function(String)
    if String == "Head" then
        Config.AimHitbox = "Head"
    elseif String == "Torso" then
        Config.AimHitbox = "Torso"
    end
end, Config.AimHitbox)

local CircleVisibleToggle = CircleSection:CreateToggle("Enable Circle", nil, function(State)
	Config.CircleVisible = State
end)
CircleVisibleToggle:SetState(Config.CircleVisible)

local CircleTransparencySlider = CircleSection:CreateSlider("Circle Transparency", 0,1,nil,false, function(Value)
	Config.CircleTransparency = Value
end)
CircleTransparencySlider:SetValue(Config.CircleTransparency)

local CircleColorpicker = CircleSection:CreateColorpicker("Circle Color", function(Color)
	Config.CircleColor = Color
end)
CircleColorpicker:UpdateColor(Config.CircleColor)

local CircleThicknessSlider = CircleSection:CreateSlider("Circle Thickness", 1,5,nil,true, function(Value)
	Config.CircleThickness = Value
end)
CircleThicknessSlider:SetValue(Config.CircleThickness)

local CircleNumSidesSlider = CircleSection:CreateSlider("Circle NumSides", 3,100,nil,true, function(Value)
	Config.CircleNumSides = Value
end)
CircleNumSidesSlider:SetValue(Config.CircleNumSides)

local CircleFilledToggle = CircleSection:CreateToggle("Circle Filled", nil, function(State)
	Config.CircleFilled = State
end)
CircleFilledToggle:SetState(Config.CircleFilled)


local UIToggle = MenuSection:CreateToggle("UI Toggle", nil, function(State)
	Window:Toggle(State)
end)
UIToggle:CreateKeybind(tostring(UIConfig.Keybind):gsub("Enum.KeyCode.", ""), function(Key)
	UIConfig.Keybind = Enum.KeyCode[Key]
end)
UIToggle:SetState(false)

local UIColor = MenuSection:CreateColorpicker("UI Color", function(Color)
	Window:ChangeColor(Color)
end)
UIColor:UpdateColor(UIConfig.Color)

-- credits to jan for patterns
local PatternBackground = BackgroundSection:CreateDropdown("Image", {"Default","Hearts","Abstract","Hexagon","Circles","Lace With Flowers","Floral"}, function(Name)
	if Name == "Default" then
		Window:SetBackground("2151741365")
	elseif Name == "Hearts" then
		Window:SetBackground("6073763717")
	elseif Name == "Abstract" then
		Window:SetBackground("6073743871")
	elseif Name == "Hexagon" then
		Window:SetBackground("6073628839")
	elseif Name == "Circles" then
		Window:SetBackground("6071579801")
	elseif Name == "Lace With Flowers" then
		Window:SetBackground("6071575925")
	elseif Name == "Floral" then
		Window:SetBackground("5553946656")
	end
end, "Default")

local BackgroundColorpicker = BackgroundSection:CreateColorpicker("Color", function(Color)
	Window:SetBackgroundColor(Color)
end)
BackgroundColorpicker:UpdateColor(Color3.new(1,1,1))

local BackgroundTransparencySlider = BackgroundSection:CreateSlider("Transparency",0,1,nil,false, function(Value)
	Window:SetBackgroundTransparency(Value)
end)
BackgroundTransparencySlider:SetValue(0)

local TileSizeSlider = BackgroundSection:CreateSlider("Tile Scale",0,1,nil,false, function(Value)
	Window:SetTileScale(Value)
end)
TileSizeSlider:SetValue(0.5)

local function TeamCheck(Target)
    if Config.TeamCheck then
        if LocalPlayer.Team ~= Target.Team then
            return true
        else
            return false
        end
    end
    return true
end

local function WallCheck(Part)
	if Config.Wallcheck and Part then
		local Camera = Workspace.CurrentCamera
		local CameraPosition = Camera.CFrame.Position
		local RaycastParameters = RaycastParams.new()
		RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
		RaycastParameters.FilterDescendantsInstances = {LocalPlayer.Character,Part.Parent}
		RaycastParameters.IgnoreWater = true
		
		if Workspace:Raycast(CameraPosition, Part.Position - CameraPosition, RaycastParameters) then
			return false
		end
	end
	return true
end

function GetTarget()
	local Camera = Workspace.CurrentCamera
	if Config.TargetMode == "NPC" then
		if NPCFolder then
			for _, NPC in pairs(NPCFolder:GetChildren()) do
				if NPC:FindFirstChildOfClass("Humanoid") and not NPC:FindFirstChildOfClass("Humanoid"):FindFirstChild("Free") and NPC:FindFirstChild(Config.AimHitbox) then
					if NPC:FindFirstChildOfClass("Humanoid") and NPC:FindFirstChildOfClass("Humanoid").Health ~= 0 then
						local Vector, OnScreen = Camera:WorldToViewportPoint(NPC:FindFirstChild(Config.AimHitbox).Position)
						if OnScreen and WallCheck(NPC:FindFirstChild(Config.AimHitbox)) then
							local VectorMagnitude = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
							if VectorMagnitude <= Config.FieldOfView then
								return NPC:FindFirstChild(Config.AimHitbox)
							end
						end
					end
				end
			end
		end
	elseif Config.TargetMode == "Player" then
		for _, Player in pairs(PlayerService:GetPlayers()) do
			if Player ~= LocalPlayer and TeamCheck(Player) then
				if Player.Character and Player.Character:FindFirstChild(Config.AimHitbox) then
					if Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChildOfClass("Humanoid").Health ~= 0 then
						local Vector, OnScreen = Camera:WorldToViewportPoint(Player.Character:FindFirstChild(Config.AimHitbox).Position)
						if OnScreen and WallCheck(Player.Character:FindFirstChild(Config.AimHitbox)) then
							local VectorMagnitude = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Vector.X, Vector.Y)).Magnitude
							if VectorMagnitude <= Config.FieldOfView then
								return Player.Character:FindFirstChild(Config.AimHitbox)
							end
						end
					end
				end
			end
		end
	end
end

-- silent aim
local function returnHit(hit, args)
	local Camera = Workspace.CurrentCamera
	local CameraPosition = Camera.CFrame.Position
	if args[1].Origin == CameraPosition then
		args[1] = Ray.new(CameraPosition, hit.Position - CameraPosition)
		return
	end
end

namecall = hookmetamethod(game, "__namecall", function(self, ...)
    local namecallmethod = getnamecallmethod()
    local args = {...}
    if namecallmethod == "FindPartOnRayWithIgnoreList" then
        if hit then
            returnHit(hit, args)
        end
    end
    return namecall(self, unpack(args))
end)

local Circle = Drawing.new("Circle")
RunService.Heartbeat:Connect(function()
	Circle.Visible = Config.CircleVisible
    Circle.Transparency = Config.CircleTransparency
    Circle.Color = Config.CircleColor

    Circle.Thickness = Config.CircleThickness
    Circle.NumSides = Config.CircleNumSides
    Circle.Radius = Config.FieldOfView
    Circle.Filled = Config.CircleFilled
    Circle.Position = UserInputService:GetMouseLocation()

	if Config.SilentAim then
		hit = GetTarget()
	else
		hit = nil
	end
end)
