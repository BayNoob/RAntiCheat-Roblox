local module = {}

module.Version = "v0.8.27"

function module.Load(loader:Instance)
	local Funcs = script:WaitForChild("Funcs")
	local RAntiCheatModel = loader.Parent
	local Config = RAntiCheatModel:WaitForChild("Configuration"):WaitForChild("Config")
	_G.ConfigRAntiCheat = require(Config)
	_G.FuncsRAntiCheat = require(Funcs)
	local funcsmodule = _G.FuncsRAntiCheat
	funcsmodule.antiDistanceRemove()
	funcsmodule.remoteEventProtection()
	funcsmodule.unreliableRemoteEventProtection()
	RAntiCheatModel.Parent = game:GetService("ServerScriptService")
	pcall(function()
		RAntiCheatModel.DELETETHIS:Destroy()
	end)
	pcall(function()
		RAntiCheatModel.README:Destroy()
	end)
	RAntiCheatModel.Parent = game:GetService("ServerScriptService")
	script.Parent = game:GetService("ServerScriptService")
	print("RAntiCheat module is loaded version: "..module.Version)
end

return module
