local module = {}

module.Version = "v0.6.13"

function module.Load(loader:Instance)
	local Funcs = script:WaitForChild("Funcs")
	local RCheatModel = loader.Parent
	local Config = RCheatModel:WaitForChild("Configuration"):WaitForChild("Config")
	_G.ConfigRCheat = require(Config)
	_G.FuncsRCheat = require(Funcs)
	local funcsmodule = _G.FuncsRCheat
	funcsmodule.AntiDistanceRemove()
	funcsmodule.RemoteEventProtection()
	RCheatModel.Parent = game:GetService("ServerScriptService")
	pcall(function()
		RCheatModel.DELETETHIS:Destroy()
	end)
	pcall(function()
		RCheatModel.README:Destroy()
	end)
	print("RCheat module is loaded version: "..module.Version)
end

return module
