-- Join my discord server for more scripts https://discord.gg/5GeQAXYYcW --
-- Created By @xLunarxZzRbxx --
-- Press F to unlock mouse -- 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local TOGGLE_MOUSE_KEY = Enum.KeyCode.F
local SENSITIVITY = 0.25
local SMOOTHNESS = 0.15
local FOV = 90

local character
local humanoid
local root
local head

local yaw, targetYaw = 0, 0
local pitch, targetPitch = 0, 0
local freeMouse = false
local active = false

local function hideHeadCosmetics(char)
	local headPart = char:FindFirstChild("Head")
	if not headPart then return end

	for _, accessory in ipairs(char:GetChildren()) do
		if accessory:IsA("Accessory") then
			local handle = accessory:FindFirstChild("Handle")
			if handle then
				local weld = handle:FindFirstChildWhichIsA("Weld")
				if weld and weld.Part1 == headPart then
					handle.LocalTransparencyModifier = 1
				end
			end
		end
	end
end

local function setupCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
	head = char:WaitForChild("Head")

	yaw, targetYaw = 0, 0
	pitch, targetPitch = 0, 0
	active = true

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CameraSubject = humanoid
	camera.FieldOfView = FOV

	humanoid.AutoRotate = false

	hideHeadCosmetics(char)

	humanoid.Died:Connect(function()
		active = false
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	end)
end

UserInputService.InputChanged:Connect(function(input)
	if not active then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		targetYaw -= input.Delta.X * SENSITIVITY
		targetPitch -= input.Delta.Y * SENSITIVITY
		targetPitch = math.clamp(targetPitch, -80, 80)
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == TOGGLE_MOUSE_KEY then
		freeMouse = not freeMouse
	end
end)

RunService.RenderStepped:Connect(function()
	if not active or not character or not character.Parent then return end

	yaw += (targetYaw - yaw) * SMOOTHNESS
	pitch += (targetPitch - pitch) * SMOOTHNESS

	camera.CFrame =
		CFrame.new(head.Position)
		* CFrame.Angles(0, math.rad(yaw), 0)
		* CFrame.Angles(math.rad(pitch), 0, 0)
		* CFrame.new(0, 0.6, 0)

	root.CFrame =
		CFrame.new(root.Position)
		* CFrame.Angles(0, math.rad(yaw), 0)

	UserInputService.MouseBehavior =
		freeMouse and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
end)

if player.Character then
	setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(char)
	task.wait(0.1)
	setupCharacter(char)
end)
