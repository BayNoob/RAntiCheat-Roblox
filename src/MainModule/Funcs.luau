local funcs = {}
local LimitsPerPlayer = {}
local config = _G.ConfigRAntiCheat


game:GetService("Players").PlayerAdded:Connect(function(plr)
	LimitsPerPlayer[plr.Name] = {
		["RemoteFunctionCall"] = {0,os.clock()},
		["RemoteEventCall"] = {0,os.clock()},
		["UnReliableRemoteEventCall"] = {0,os.clock()},
	}
end)

game:GetService("Players").PlayerRemoving:Connect(function(plr)
	LimitsPerPlayer[plr.Name] = nil

end)

for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
	LimitsPerPlayer[plr.Name] = {
		["RemoteFunctionCall"] = {0,os.clock()},
		["RemoteEventCall"] = {0,os.clock()},
		["UnReliableRemoteEventCall"] = {0,os.clock()},
	}
end

function funcs.Punish(plr:Player,punishment:string,reason: string?)
	if not config.Defaults.DefaultKickMessage then
		config.Defaults.DefaultKickMessage = "You have been kicked by RAntiCheat"
	end
	if punishment == "KICK" then
		if reason then
			if reason:sub(1,2) == ".." then
				plr:Kick((config.Defaults.DefaultKickMessage..reason:sub(3)) or "")
			elseif reason:sub(-2) == ".." then
				plr:Kick((reason:sub(1,-3) or "") .. config.Defaults.DefaultKickMessage)
			else
				plr:Kick(reason or config.Defaults.DefaultKickMessage)
			end
		else
			plr:Kick(config.Defaults.DefaultKickMessage)
		end
	elseif punishment:sub(1,3) == "BAN" then
		
		local banconfig = {
			UserIds = {plr.UserId},
			Duration = config.Defaults.DefaultTimeOnBan or -1,
			DisplayReason = config.Defaults.DefaultKickMessage or "You are banned by RAntiCheat", 
			PrivateReason = config.Defaults.DefaultKickMessage or "Please put reasons :P",
			ExcludeAltAccounts = config.Defaults.ExcludeAltAccountsOnBan, 
			ApplyToUniverse = config.Defaults.ApplyToUniverseOnBan, 
		}
		
		local parsed = string.split(punishment,":")
		if parsed[2] and tonumber(parsed[2]) then
			banconfig.Duration = tonumber(parsed[2])
		end
		if parsed[3] then
			banconfig.PrivateReason = parsed[3]
		end
		if parsed[4] then
			banconfig.ExcludeAltAccounts = "true" == string.lower(parsed[4])
		end
		if parsed[5] then
			banconfig.ApplyToUniverse = "true" == string.lower(parsed[5])
		end
		local boolean = pcall(function()
			if reason then
				if reason:sub(1,2) == ".." then
					banconfig.DisplayReason = reason:sub(3,-1) .. config.Defaults.DefaultKickMessage
					game.Players:BanAsync(banconfig)
				elseif reason:sub(-2) == ".." then
					banconfig.DisplayReason = reason:sub(1,-3) .. config.Defaults.DefaultKickMessage
					game.Players:BanAsync(banconfig)
				else
					banconfig.DisplayReason = reason
					game.Players:BanAsync(banconfig)
				end
			else
				game.Players:BanAsync(banconfig)
			end
		end)
		if boolean == false then
			plr:Kick(config.Defaults.DefaultKickMessage)
		end
	end
end


local function Validate(value,depth,plr,length,visited)
	length.count += 1
	if typeof(value) == "string" then
		if #value > config.RateLimits.MaxStringLength[1] then
			funcs.Punish(plr,config.RateLimits.MaxStringLength[2] or "KICK",config.RateLimits.MaxStringLength[3] or nil)
			return false
		end
	elseif typeof(value) == "number" then
		if value == math.huge or value == -math.huge or value ~= value then
			funcs.Punish(plr,"KICK",".. Invalid Number")
			return false
		end
	end
	if length.count > config.RateLimits.MaxTableLength[1] then
		funcs.Punish(plr,config.RateLimits.MaxTableLength[2] or "KICK",config.RateLimits.MaxTableLength[3] or nil)
		return false
	end
	
	if depth > config.RateLimits.MaxTableDepth[1] then
		funcs.Punish(plr,config.RateLimits.MaxTableDepth[2] or "KICK",config.RateLimits.MaxTableDepth[3] or nil)
		return false
	end

	if typeof(value) == "table" and not visited[value] then
		visited[value] = true
		for key,child in value do

			if not Validate(key,depth+1,plr,length,visited) then
				return false
			end

			if not Validate(child,depth+1,plr,length,visited) then
				return false
			end
		end
	end

	return true
end

function funcs.RemoteEventProtection()
	if config.Protections.RemoteEventProtection[1] ~= true then
		return
	end
	
	local remoteconnections = {}
	
	local function connectremote(event:RemoteEvent)
		local connect = event.OnServerEvent:Connect(function(plr,...)
			if (os.clock() - LimitsPerPlayer[plr.Name].RemoteEventCall[2]) > 1 then
				LimitsPerPlayer[plr.Name].RemoteEventCall = {0,os.clock()}
			end
			LimitsPerPlayer[plr.Name].RemoteEventCall[1] += 1
			if LimitsPerPlayer[plr.Name].RemoteEventCall[1] > config.RateLimits.RemoteEventCallPS[1] then
				funcs.Punish(plr,config.RateLimits.RemoteEventCallPS[2] or "KICK",config.RateLimits.RemoteEventCallPS[3] or nil)
				return
			end
			local variables = {...}

			if table.pack(...).n > config.RateLimits.MaxVariableCount[1] then
				funcs.Punish(plr,config.RateLimits.MaxVariableCount[2] or "KICK",config.RateLimits.MaxVariableCount[3] or nil)
				return
			end
			
			local length = {count = 0}

			for _, variable in ipairs(variables) do
				if typeof(variable) == "table" then
					if not Validate(variable,1,plr,length,{}) then
						return
					end
					length.count = 0
				elseif typeof(variable) == "string" then
					if #variable > config.RateLimits.MaxStringLength[1] then
						funcs.Punish(plr,config.RateLimits.MaxStringLength[2] or "KICK",config.RateLimits.MaxStringLength[3] or nil)
						return
					end
				elseif typeof(variable) == "number" then
					if variable == math.huge or variable == -math.huge or variable ~= variable then
						funcs.Punish(plr,"KICK",".. Invalid Number")
						return
					end
				end
			end
		end)
		return connect
	end
	
	for _, i in pairs(game:GetDescendants()) do
		if i:IsA("RemoteEvent") then
			remoteconnections[i] = connectremote(i)
		end
	end
	
	game.DescendantAdded:Connect(function(i)
		if i:IsA("RemoteEvent") then
			local connect = connectremote(i)
			remoteconnections[i] = connect
		end
	end)
	
	game.DescendantRemoving:Connect(function(i)
		if i:IsA("RemoteEvent") then
			pcall(function()
				remoteconnections[i]:Disconnect()
				remoteconnections[i] = nil
			end)
		end
	end)
end

function funcs.UnReliableRemoteEventProtection()
	if config.Protections.UnReliableRemoteEventProtection[1] ~= true then
		return
	end
	
	local remoteconnections = {}
	
	local function connectremote(event:UnreliableRemoteEvent)
		local connect = event.OnServerEvent:Connect(function(plr,...)
			if (os.clock() - LimitsPerPlayer[plr.Name].UnReliableRemoteEventCall[2]) > 1 then
				LimitsPerPlayer[plr.Name].UnReliableRemoteEventCall = {0,os.clock()}
			end
			LimitsPerPlayer[plr.Name].UnReliableRemoteEventCall[1] += 1
			if LimitsPerPlayer[plr.Name].UnReliableRemoteEventCall[1] > config.RateLimits.UnReliableRemoteEventCallPS[1] then
				funcs.Punish(plr,config.RateLimits.UnReliableRemoteEventCallPS[2] or "KICK",config.RateLimits.UnReliableRemoteEventCallPS[3] or nil)
				return
			end
			local variables = {...}

			if table.pack(...).n > config.RateLimits.MaxVariableCount[1] then
				funcs.Punish(plr,config.RateLimits.MaxVariableCount[2] or "KICK",config.RateLimits.MaxVariableCount[3] or nil)
				return
			end
			
			local length = {count = 0}

			for _, variable in ipairs(variables) do
				if typeof(variable) == "table" then
					if not Validate(variable,1,plr,length,{}) then
						return
					end
					length.count = 0
				elseif typeof(variable) == "string" then
					if #variable > config.RateLimits.MaxStringLength[1] then
						funcs.Punish(plr,config.RateLimits.MaxStringLength[2] or "KICK",config.RateLimits.MaxStringLength[3] or nil)
						return
					end
				elseif typeof(variable) == "number" then
					if variable == math.huge or variable == -math.huge or variable ~= variable then
						funcs.Punish(plr,"KICK",".. Invalid Number")
						return
					end
				end
			end
		end)
		return connect
	end
	
	for _, i in pairs(game:GetDescendants()) do
		if i:IsA("UnreliableRemoteEvent") then
			remoteconnections[i] = connectremote(i)
		end
	end
	
	game.DescendantAdded:Connect(function(i)
		if i:IsA("UnreliableRemoteEvent") then
			local connect = connectremote(i)
			remoteconnections[i] = connect
		end
	end)
	
	game.DescendantRemoving:Connect(function(i)
		if i:IsA("UnreliableRemoteEvent") then
			pcall(function()
				remoteconnections[i]:Disconnect()
				remoteconnections[i] = nil
			end)
		end
	end)
end

function funcs.AntiDistanceRemove()
	if config.Protections.AntiDistanceRemove[1] ~= true then
		return
	end
	local proximityprompts = {}
	local clickdetectors = {}
	
	local function promptconnector(prompt:ProximityPrompt)
		local connection = prompt.Triggered:Connect(function(plr)
			local char = plr.Character or false
			if char then
				local humanoidrp = char.HumanoidRootPart or false
				local promptpart = prompt
				promptpart = promptpart:FindFirstAncestorWhichIsA("BasePart") or promptpart:FindFirstAncestorWhichIsA("Attachment") or promptpart:FindFirstAncestorWhichIsA("Model")
				
				if not promptpart then
					return
				end

				if humanoidrp ~= false then
					if promptpart:IsA("BasePart") then
						if (humanoidrp.Position - promptpart.Position).Magnitude > (prompt.MaxActivationDistance * 1.25)+3 then
							funcs.Punish(plr,config.Protections.AntiDistanceRemove[2] or "KICK",config.Protections.AntiDistanceRemove[3] or nil)
							return
						end
					elseif promptpart:IsA("Attachment") then
						if (humanoidrp.Position - promptpart.WorldPosition).Magnitude > (prompt.MaxActivationDistance * 1.25)+3 then
							funcs.Punish(plr,config.Protections.AntiDistanceRemove[2] or "KICK",config.Protections.AntiDistanceRemove[3] or nil)
							return
						end
					elseif promptpart:IsA("Model") then
						if (humanoidrp.Position - promptpart:GetPivot().Position).Magnitude > (prompt.MaxActivationDistance * 1.25)+3 then
							funcs.Punish(plr,config.Protections.AntiDistanceRemove[2] or "KICK",config.Protections.AntiDistanceRemove[3] or nil)
							return
						end
					end
				end
			end
		end)
		return connection
	end
	
	local function clickconnector(clickdetector)
		local connection = clickdetector.MouseClick:Connect(function(plr)
			local char = plr.Character or false
			if char then
				local humanoidrp = char.HumanoidRootPart or false
				local promptpart = clickdetector
				promptpart = promptpart:FindFirstAncestorWhichIsA("BasePart") or promptpart:FindFirstAncestorWhichIsA("Attachment") or promptpart:FindFirstAncestorWhichIsA("Model")
				
				if not promptpart then
					return
				end
				
				if humanoidrp ~= false then
					if promptpart:IsA("BasePart") then
						if (humanoidrp.Position - promptpart.Position).Magnitude > (clickdetector.MaxActivationDistance * 1.25)+3 then
							funcs.Punish(plr,config.Protections.AntiDistanceRemove[2] or "KICK",config.Protections.AntiDistanceRemove[3] or nil)
							return
						end
					elseif promptpart:IsA("Attachment") then
						if (humanoidrp.Position - promptpart.WorldPosition).Magnitude > (clickdetector.MaxActivationDistance * 1.25)+3 then
							funcs.Punish(plr,config.Protections.AntiDistanceRemove[2] or "KICK",config.Protections.AntiDistanceRemove[3] or nil)
							return
						end
					elseif promptpart:IsA("Model") then
						if (humanoidrp.Position - promptpart:GetPivot().Position).Magnitude > (clickdetector.MaxActivationDistance * 1.25)+3 then
							funcs.Punish(plr,config.Protections.AntiDistanceRemove[2] or "KICK",config.Protections.AntiDistanceRemove[3] or nil)
							return
						end
					end
				end
			end
		end)
		return connection
	end
	
	for _, i in pairs(game:GetDescendants()) do
		if i:IsA("ClickDetector") then
			clickdetectors[i] = clickconnector(i)
		elseif i:IsA("ProximityPrompt") then
			proximityprompts[i] = promptconnector(i)
		end
	end
	
	game.DescendantAdded:Connect(function(i)
		if i:IsA("ClickDetector") then
			local connection = clickconnector(i)
			clickdetectors[i] = connection
		elseif i:IsA("ProximityPrompt") then
			local connection = promptconnector(i)
			proximityprompts[i] = connection
		end
	end)
	
	game.DescendantRemoving:Connect(function(i)
		if i:IsA("ClickDetector") then
			pcall(function()
				clickdetectors[i]:Disconnect()
				clickdetectors[i] = nil
			end)
		elseif i:IsA("ProximityPrompt") then
			pcall(function()
				proximityprompts[i]:Disconnect()
				proximityprompts[i] = nil				
			end)
		end
	end)
end

function funcs.OnServerInvoke(func)
	if config.Protections.RemoteFunctionProtection[1] == true then
		return function(plr:Player,...) -- returning the function OnServerInvoke =, waits
			
			if (os.clock() - LimitsPerPlayer[plr.Name]["RemoteFunctionCall"][2]) > 1 then
				LimitsPerPlayer[plr.Name]["RemoteFunctionCall"][1] = 0
				LimitsPerPlayer[plr.Name]["RemoteFunctionCall"][2] = os.clock()
			end
			
			LimitsPerPlayer[plr.Name]["RemoteFunctionCall"][1] += 1
			
			if LimitsPerPlayer[plr.Name]["RemoteFunctionCall"][1] > config.RateLimits.RemoteFunctionCallPS[1] then
				funcs.Punish(plr,config.RateLimits.RemoteFunctionCallPS[2] or "KICK" ,config.RateLimits.RemoteFunctionCallPS[3] or nil)
				return
			end
			
			local variables = {...}
			
			if table.pack(...).n > config.RateLimits.MaxVariableCount[1] then
				funcs.Punish(plr,config.RateLimits.MaxVariableCount[2] or "KICK",config.RateLimits.MaxVariableCount[3] or nil)
				return
			end
			
			local length = {count = 0}

			
			for _, variable in ipairs(variables) do
				if typeof(variable) == "table" then
					if not Validate(variable,1,plr,length,{}) then
						return
					end
					length.count = 0
				elseif typeof(variable) == "string" then
					if #variable > config.RateLimits.MaxStringLength[1] then
						funcs.Punish(plr,config.RateLimits.MaxStringLength[2] or "KICK",config.RateLimits.MaxStringLength[3] or nil)
						return
					end
				elseif typeof(variable) == "number" then
					if variable == math.huge or variable == -math.huge or variable ~= variable then
						funcs.Punish(plr,"KICK",".. Invalid Number")
						return
					end
				end
			end
					
			return func(plr,...)
		end
	else
		return function(plr:Player,...)
			return func(plr,...)
		end
	end
end


return funcs