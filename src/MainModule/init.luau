local module = {}

module.Version = "v0.7.25"

function module.Load(loader:Instance)
	local Funcs = script:WaitForChild("Funcs")
	local RAntiCheatModel = loader.Parent
	local Config = RAntiCheatModel:WaitForChild("Configuration"):WaitForChild("Config")
	_G.ConfigRAntiCheat = require(Config)
	_G.FuncsRAntiCheat = require(Funcs)
	local funcsmodule = _G.FuncsRAntiCheat
	funcsmodule.AntiDistanceRemove()
	funcsmodule.RemoteEventProtection()
	RAntiCheatModel.Parent = game:GetService("ServerScriptService")
	pcall(function()
		RAntiCheatModel.DELETETHIS:Destroy()
	end)
	pcall(function()
		RAntiCheatModel.README:Destroy()
	end)
	print("RAntiCheat module is loaded version: "..module.Version)
end

return module
