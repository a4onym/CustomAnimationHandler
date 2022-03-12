--[[

    
         _  _    ____  _   ___     ____  __ 
     /\ | || |  / __ \| \ | \ \   / /  \/  |
    /  \| || |_| |  | |  \| |\ \_/ /| \  / |
   / /\ \__   _| |  | | . ` | \   / | |\/| |
  / ____ \ | | | |__| | |\  |  | |  | |  | |
 /_/    \_\|_|  \____/|_| \_|  |_|  |_|  |_|
                                            
                                            
    *CustomAnimationHandler - lets you load, preload, play and do much more else with the module!

]]

local ContentProviderService = game:GetService("ContentProvider")
local Class = {}

Class["__index"] = Class

function Class.new(Model: Model, yieldTimeForComponents: number)
	assert(Model ~= nil, script.Name .. " | Failed to load first argument")
	assert(typeof(Model) == "Instance", script.Name .. " | First argument is required to be an Instance")

	local isaModel = nil

	local Success, Respond = pcall(function()
		if Model:IsA("Model") then
			isaModel = true
		end
	end)

	if typeof(Model) == "Instance" then
		if isaModel == true and Success then
			local Humanoid: Humanoid = Model:FindFirstChildWhichIsA("Humanoid")
				or Model:WaitForChild(
					"Humanoid",
					(typeof(yieldTimeForComponents) == "number" and yieldTimeForComponents) or 5
				)

			if Humanoid then
				local Animator: Animator = Humanoid:FindFirstAncestorOfClass("Animator")
					or Humanoid:WaitForChild(
						"Animator",
						(typeof(yieldTimeForComponents) == "number" and yieldTimeForComponents) or 5
					)

				if Animator then
					local classObject = {}
					classObject["Animator"] = Animator
					classObject["LoadedAnimations"] = {}

					setmetatable(classObject, Class)

					return classObject
				end
			end
		end
	end
end

function Class:PreLoadAnimations(AnimationTable: table, CSPCallback: thread)
	assert(AnimationTable ~= nil, script.Name .. " | Failed to find first argument, function: PreLoadAnimations")
	assert(
		typeof(AnimationTable) == "table",
		script.Name .. " | First argument should be a table, function: PreLoadAnimations"
	)

	if CSPCallback ~= nil then
		assert(
			typeof(CSPCallback) == "function",
			script.Name .. " | Second argument should be a function, function: PreLoadAnimations"
		)
	end

	local WhitelistedAnimationTable = {}

	for Key, Value in pairs(AnimationTable) do
		if (typeof(Value) == "string") or (typeof(Value) == "Instance" and Value:IsA("Animation")) then
			table.insert(WhitelistedAnimationTable, Value)
		end
	end

	if #WhitelistedAnimationTable > 0 then
		local DeltaTime = os.clock()

		local Success, Respond = pcall(function()
			ContentProviderService:PreloadAsync(WhitelistedAnimationTable, CSPCallback)
		end)

		if Success then
			return Success, os.clock() - DeltaTime
		else
			return Success
		end
	end
end

function Class:LoadAnimations(AnimationTable: table)
	local Animator: Animator = nil

	local Success, Respond = pcall(function()
		Animator = self["Animator"]
	end)

	assert(Animator ~= nil, script.Name .. " | No animator found in object, function: LoadAnimations")
	assert(
		Success ~= nil,
		script.Name .. " | An error occured while attempting to index Animator, function: LoadAnimations"
	)
	assert(AnimationTable ~= nil, script.Name .. " | Failed to find first argument, function: LoadAnimations")
	assert(
		typeof(AnimationTable) == "table",
		script.Name .. " | First argument should be a table, function: LoadAnimations"
	)
	assert(
		Animator:IsA("Animator") == true,
		script.Name .. " | self / Animator is not an Animator instance, function: LoadAnimations"
	)

	local Success, Respond = pcall(function()
		for Key, Value: string | Animation? in pairs(AnimationTable) do
			local Check = false

			if typeof(Value) == "Instance" then
				if Value:IsA("Animation") then
					Check = true
				end
			elseif typeof(Value) == "string" then
				local Success, Respond = pcall(function()
					local AnimationInstance: Animation = Instance.new("Animation")
					AnimationInstance["AnimationId"] = Value
					AnimationInstance["Name"] = Value
					AnimationTable[Key] = AnimationInstance
				end)

				if not Success then
					AnimationTable[Key] = nil
				end
			end
		end
	end)

	if Success then
		local DeltaTime = os.clock()

		local Success, Respond = pcall(function()
			for Key, Value: Animation in pairs(AnimationTable) do
				local Success_2, Respond_2 = pcall(function()
					local AnimationTrack = Animator:LoadAnimation(Value)
					table.insert(self["LoadedAnimations"], AnimationTrack)
				end)
			end
		end)

		if Success then
			return Success, os.clock() - DeltaTime
		else
			return Success
		end
	end
end

function Class:PlayAnimation(AnimationName: string, SettingTable: table)
	local LoadedAnimations: table = self["LoadedAnimations"]
	local Animator: Animator = self["Animator"]

	assert(AnimationName ~= nil, script.Name .. "| First argument is required")
	assert(SettingTable ~= nil, script.Name .. "| Second argument is required")
	assert(LoadedAnimations ~= nil, script.Name .. "| Animator property not found in object")
	assert(Animator ~= nil, script.Name .. "| LoadedAnimations property not found in object")
	assert(
		typeof(AnimationName) == "string",
		script.Name .. "| First argument is required to be the name of the animation"
	)

	if SettingTable ~= nil then
		assert(typeof(SettingTable) == "table", script.Name .. "| Second argument is required to be a table")
	end

	local isFound: boolean, AnimationTrack: AnimationTrack = false, nil

	local Success, Respond = pcall(function()

		for Key, Value in pairs(LoadedAnimations) do

			if Value.Name == AnimationName then

				isFound, AnimationTrack = true, Value

			end

		end

	end)

	if isFound and AnimationTrack and Success then

		local speed, fadeTime, weight = nil, nil, nil

		for Key, Value in pairs(SettingTable) do
			local Success, Respond = pcall(function()
				if
					tostring(string.lower(Key)) ~= "weight"
					and tostring(string.lower(Key)) ~= "speed"
					and tostring(string.lower(Key)) ~= "fadetime"
				then
					AnimationTrack[Key] = Value
				else
					if tostring(string.lower(Key)) == "weight" then
						weight = Value
					elseif tostring(string.lower(Key)) == "speed" then
						speed = Value
					elseif tostring(string.lower(Key)) == "fadetime" then
						fadeTime = Value
					end
				end
			end)
		end

		local Success_2, Respond_2 = pcall(function()
			AnimationTrack:Play(fadeTime, weight, speed)
		end)

		return Success_2
	end
end

function Class:StopAnimation(AnimationName: string, fadeTime : number)
	
	local LoadedAnimations: table = self["LoadedAnimations"]

	assert(
		typeof(AnimationName) == "string",
		script.Name .. "| First argument is required to be the name of the animation"
	)
	assert(LoadedAnimations ~= nil, script.Name .. "| Animator property not found in object")
	assert(typeof(LoadedAnimations) == "table", script.Name .. "| Second argument is required to be a table")

	if fadeTime then
		
		assert(typeof(fadeTime) == "number", script.Name .. "| Second argument is required to be a number")

	end

	for Key, Value : AnimationTrack in pairs(LoadedAnimations) do
		
		local Success, Respond = pcall(function()
			
			if Value.Name == AnimationName and Value.IsPlaying then
				
				Value:Stop(fadeTime)

			end

		end)

	end

end

return Class
