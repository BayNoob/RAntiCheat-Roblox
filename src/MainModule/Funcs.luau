--!strict

local Players = game:GetService("Players")

local config = _G.ConfigRAntiCheat

local funcs = {}
local limitsPerPlayer = {}

Players.PlayerAdded:Connect(function(plr)
	limitsPerPlayer[plr] = {
		["RemoteFunctionCall"] = {0, os.clock()},
		["RemoteEventCall"] = {0, os.clock()},
		["UnReliableRemoteEventCall"] = {0, os.clock()},
	}
end)

Players.PlayerRemoving:Connect(function(plr)
	limitsPerPlayer[plr] = nil
end)

for _, plr in Players:GetPlayers() do
	limitsPerPlayer[plr] = {
		["RemoteFunctionCall"] = {0, os.clock()},
		["RemoteEventCall"] = {0, os.clock()},
		["UnReliableRemoteEventCall"] = {0, os.clock()},
	}
end

function funcs.punish(plr: Player, punishment: string, reason: string?)
	if not config.Defaults.DefaultKickMessage then
		config.Defaults.DefaultKickMessage = "You have been kicked by RAntiCheat"
	end

	if punishment == "KICK" then
		if reason then
			if reason:sub(1, 2) == ".." then
				plr:Kick((config.Defaults.DefaultKickMessage..reason:sub(3)) or "")
			elseif reason:sub(-2) == ".." then
				plr:Kick((reason:sub(1, -3) or "") .. config.Defaults.DefaultKickMessage)
			else
				plr:Kick(reason or config.Defaults.DefaultKickMessage)
			end
		else
			plr:Kick(config.Defaults.DefaultKickMessage)
		end
	elseif punishment:sub(1, 3) == "BAN" then

		local banConfig = {
			UserIds = {plr.UserId},
			Duration = config.Defaults.DefaultTimeOnBan or -1,
			DisplayReason = config.Defaults.DefaultKickMessage or "You are banned by RAntiCheat", 
			PrivateReason = config.Defaults.DefaultKickMessage or "Please put reasons :P",
			ExcludeAltAccounts = config.Defaults.ExcludeAltAccountsOnBan, 
			ApplyToUniverse = config.Defaults.ApplyToUniverseOnBan, 
		}:: any
		
		local parsed = string.split(punishment, ":")
		if parsed[2] and tonumber(parsed[2]) then
			banConfig.Duration = tonumber(parsed[2])
		end
		if parsed[3] then
			banConfig.PrivateReason = parsed[3]
		end
		if parsed[4] then
			banConfig.ExcludeAltAccounts = "true" == string.lower(parsed[4])
		end
		if parsed[5] then
			banConfig.ApplyToUniverse = "true" == string.lower(parsed[5])
		end
		local boolean = pcall(function()
			if reason then
				if reason:sub(1,2) == ".." then
					banConfig.DisplayReason = reason:sub(3, -1) .. config.Defaults.DefaultKickMessage
					Players:BanAsync(banConfig)
				elseif reason:sub(-2) == ".." then
					banConfig.DisplayReason = reason:sub(1, -3) .. config.Defaults.DefaultKickMessage
					Players:BanAsync(banConfig)
				else
					banConfig.DisplayReason = reason
					Players:BanAsync(banConfig)
				end
			else
				Players:BanAsync(banConfig)
			end
		end)
		if boolean == false then
			plr:Kick(config.Defaults.DefaultKickMessage)
		end
	end
end


local function Validate(value: any, depth: number, plr: Player, length: { [string]: number }, visited: {[any]: boolean})
	length.count += 1
	if typeof(value) == "string" then
		if #value > config.RateLimits.MaxStringLength[1] then
			funcs.punish(plr, config.RateLimits.MaxStringLength[2] or "KICK", config.RateLimits.MaxStringLength[3] or nil)
			return false
		end
	elseif typeof(value) == "number" then
		if value == math.huge or value == -math.huge or value ~= value then
			funcs.punish(plr, "KICK", ".. Invalid Number")
			return false
		end
	end
	if length.count > config.RateLimits.MaxTableLength[1] then
		funcs.punish(plr, config.RateLimits.MaxTableLength[2] or "KICK", config.RateLimits.MaxTableLength[3] or nil)
		return false
	end
	
	if depth > config.RateLimits.MaxTableDepth[1] then
		funcs.punish(plr, config.RateLimits.MaxTableDepth[2] or "KICK", config.RateLimits.MaxTableDepth[3] or nil)
		return false
	end

	if typeof(value) == "table" and not visited[value] then
		visited[value] = true
		for key, child in value do

			if not Validate(key, depth+1, plr, length, visited) then
				return false
			end

			if not Validate(child, depth+1, plr, length, visited) then
				return false
			end
		end
	end

	return true
end


function funcs.remoteEventProtection()
	if config.Protections.RemoteEventProtection[1] ~= true then
		return
	end
	
	local remoteConnections = {}
	
	local function connectRemote(event: RemoteEvent)
		local connect = event.OnServerEvent:Connect(function(plr,...)
			if (os.clock() - limitsPerPlayer[plr].RemoteEventCall[2]) > 1 then
				limitsPerPlayer[plr].RemoteEventCall = {0, os.clock()}
			end
			limitsPerPlayer[plr].RemoteEventCall[1] += 1
			if limitsPerPlayer[plr].RemoteEventCall[1] > config.RateLimits.RemoteEventCallPS[1] then
				funcs.punish(plr, config.RateLimits.RemoteEventCallPS[2] or "KICK",config.RateLimits.RemoteEventCallPS[3] or nil)
				return
			end
			local variables = {...}

			if table.pack(...).n > config.RateLimits.MaxVariableCount[1] then
				funcs.punish(plr, config.RateLimits.MaxVariableCount[2] or "KICK",config.RateLimits.MaxVariableCount[3] or nil)
				return
			end
			
			local length = {count = 0}

			for _, variable in variables do
				if typeof(variable) == "table" then
					if not Validate(variable, 1, plr, length, {}) then
						return
					end
					length.count = 0
				elseif typeof(variable) == "string" then
					if #variable > config.RateLimits.MaxStringLength[1] then
						funcs.punish(plr, config.RateLimits.MaxStringLength[2] or "KICK", config.RateLimits.MaxStringLength[3] or nil)
						return
					end
				elseif typeof(variable) == "number" then
					if variable == math.huge or variable == -math.huge or variable ~= variable then
						funcs.punish(plr, "KICK", ".. Invalid Number")
						return
					end
				end
			end
		end)
		return connect
	end
	
	for _, i in game:GetDescendants() do
		if i:IsA("RemoteEvent") then
			remoteConnections[i] = connectRemote(i)
		end
	end
	
	game.DescendantAdded:Connect(function(i)
		if i:IsA("RemoteEvent") then
			local connect = connectRemote(i)
			remoteConnections[i] = connect
		end
	end)
	
	game.DescendantRemoving:Connect(function(i)
		if i:IsA("RemoteEvent") then
			pcall(function()
				remoteConnections[i]:Disconnect()
				remoteConnections[i] = nil
			end)
		end
	end)
end

function funcs.unreliableRemoteEventProtection()
	if config.Protections.UnReliableRemoteEventProtection[1] ~= true then
		return
	end
	
	local remoteConnections = {}
	
	local function connectRemote(event: UnreliableRemoteEvent)
		local connect = event.OnServerEvent:Connect(function(plr, ...)
			if (os.clock() - limitsPerPlayer[plr].UnReliableRemoteEventCall[2]) > 1 then
				limitsPerPlayer[plr].UnReliableRemoteEventCall = {0,os.clock()}
			end
			limitsPerPlayer[plr].UnReliableRemoteEventCall[1] += 1
			if limitsPerPlayer[plr].UnReliableRemoteEventCall[1] > config.RateLimits.UnReliableRemoteEventCallPS[1] then
				funcs.punish(plr, config.RateLimits.UnReliableRemoteEventCallPS[2] or "KICK", config.RateLimits.UnReliableRemoteEventCallPS[3] or nil)
				return
			end
			local variables = {...}

			if table.pack(...).n > config.RateLimits.MaxVariableCount[1] then
				funcs.punish(plr, config.RateLimits.MaxVariableCount[2] or "KICK", config.RateLimits.MaxVariableCount[3] or nil)
				return
			end
			
			local length = {count = 0}

			for _, variable in variables do
				if typeof(variable) == "table" then
					if not Validate(variable, 1, plr, length, {}) then
						return
					end
					length.count = 0
				elseif typeof(variable) == "string" then
					if #variable > config.RateLimits.MaxStringLength[1] then
						funcs.punish(plr, config.RateLimits.MaxStringLength[2] or "KICK", config.RateLimits.MaxStringLength[3] or nil)
						return
					end
				elseif typeof(variable) == "number" then
					if variable == math.huge or variable == -math.huge or variable ~= variable then
						funcs.punish(plr, "KICK", ".. Invalid Number")
						return
					end
				end
			end
		end)
		return connect
	end
	
	for _, i in game:GetDescendants() do
		if i:IsA("UnreliableRemoteEvent") then
			remoteConnections[i] = connectRemote(i)
		end
	end
	
	game.DescendantAdded:Connect(function(i)
		if i:IsA("UnreliableRemoteEvent") then
			local connect = connectRemote(i)
			remoteConnections[i] = connect
		end
	end)
	
	game.DescendantRemoving:Connect(function(i)
		if i:IsA("UnreliableRemoteEvent") then
			pcall(function()
				remoteConnections[i]:Disconnect()
				remoteConnections[i] = nil
			end)
		end
	end)
end

function funcs.antiDistanceRemove()
	if config.Protections.AntiDistanceRemove[1] ~= true then
		return
	end
	local proximityPrompts = {}
	local clickDetectors = {}
	
	local function onconnect(plr: Player, prompt: ProximityPrompt | ClickDetector)
		local char = plr.Character
		if char then
			local humanoidRootPart = char:FindFirstChild("HumanoidRootPart"):: BasePart
			local promptPart = prompt
			promptPart = (promptPart:FindFirstAncestorWhichIsA("Attachment") or promptPart:FindFirstAncestorWhichIsA("BasePart") or promptPart:FindFirstAncestorWhichIsA("Model")) :: any
			
			if not promptPart then
				return
			end
			
			if humanoidRootPart then
				if promptPart:IsA("BasePart") then
					if (humanoidRootPart.Position - promptPart.Position).Magnitude > (prompt.MaxActivationDistance * 1.25)+3 then
						funcs.punish(plr, config.Protections.AntiDistanceRemove[2] or "KICK", config.Protections.AntiDistanceRemove[3] or nil)
						return
					end
				elseif promptPart:IsA("Attachment") then
					if (humanoidRootPart.Position - promptPart.WorldPosition).Magnitude > (prompt.MaxActivationDistance * 1.25)+3 then
						funcs.punish(plr, config.Protections.AntiDistanceRemove[2] or "KICK", config.Protections.AntiDistanceRemove[3] or nil)
						return
					end
				elseif promptPart:IsA("Model") then
					if (humanoidRootPart.Position - promptPart:GetPivot().Position).Magnitude > (prompt.MaxActivationDistance * 1.25)+3 then
						funcs.punish(plr, config.Protections.AntiDistanceRemove[2] or "KICK", config.Protections.AntiDistanceRemove[3] or nil)
						return
					end
				end
			end
		end
	end

	
	local function promptConnector(prompt: ProximityPrompt)
		local connection = prompt.Triggered:Connect(function(plr)
			onconnect(plr, prompt)
		end)
		return connection
	end
	
	local function clickConnector(clickdetector: ClickDetector)
		local connection = clickdetector.MouseClick:Connect(function(plr)
			onconnect(plr, clickdetector)
		end)
		return connection
	end
	
	for _, i in game:GetDescendants() do
		if i:IsA("ClickDetector") then
			clickDetectors[i] = clickConnector(i)
		elseif i:IsA("ProximityPrompt") then
			proximityPrompts[i] = promptConnector(i)
		end
	end
	
	game.DescendantAdded:Connect(function(i)
		if i:IsA("ClickDetector") then
			local connection = clickConnector(i)
			clickDetectors[i] = connection
		elseif i:IsA("ProximityPrompt") then
			local connection = promptConnector(i)
			proximityPrompts[i] = connection
		end
	end)
	
	game.DescendantRemoving:Connect(function(i)
		if i:IsA("ClickDetector") then
			pcall(function()
				(clickDetectors[i]:: any):Disconnect() --
				clickDetectors[i] = nil
			end)
		elseif i:IsA("ProximityPrompt") then
			pcall(function()
				proximityPrompts[i]:Disconnect()
				proximityPrompts[i] = nil				
			end)
		end
	end)
end

function funcs.OnServerInvoke(func)
	if config.Protections.RemoteFunctionProtection[1] == true then
		return function(plr: Player, ...) -- returning the function OnServerInvoke =, waits
			
			if (os.clock() - limitsPerPlayer[plr]["RemoteFunctionCall"][2]) > 1 then
				limitsPerPlayer[plr]["RemoteFunctionCall"][1] = 0
				limitsPerPlayer[plr]["RemoteFunctionCall"][2] = os.clock()
			end
			
			limitsPerPlayer[plr]["RemoteFunctionCall"][1] += 1
			
			if limitsPerPlayer[plr]["RemoteFunctionCall"][1] > config.RateLimits.RemoteFunctionCallPS[1] then
				funcs.punish(plr, config.RateLimits.RemoteFunctionCallPS[2] or "KICK" , config.RateLimits.RemoteFunctionCallPS[3] or nil)
				return
			end
			
			local variables = {...}
			
			if table.pack(...).n > config.RateLimits.MaxVariableCount[1] then
				funcs.punish(plr, config.RateLimits.MaxVariableCount[2] or "KICK", config.RateLimits.MaxVariableCount[3] or nil)
				return
			end
			
			local length = {count = 0}

			
			for _, variable in variables do
				if typeof(variable) == "table" then
					if not Validate(variable, 1, plr, length, {}) then
						return
					end
					length.count = 0
				elseif typeof(variable) == "string" then
					if #variable > config.RateLimits.MaxStringLength[1] then
						funcs.punish(plr, config.RateLimits.MaxStringLength[2] or "KICK", config.RateLimits.MaxStringLength[3] or nil)
						return
					end
				elseif typeof(variable) == "number" then
					if variable == math.huge or variable == -math.huge or variable ~= variable then
						funcs.punish(plr, "KICK", ".. Invalid Number")
						return
					end
				end
			end
					
			return func(plr, ...)
		end
	else
		return function(plr: Player,...)
			return func(plr, ...)
		end
	end
end

return funcs