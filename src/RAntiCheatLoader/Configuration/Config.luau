local config = {}

config.RateLimits = {
	--[[
		["RemoteFunctionCallPS"] = {20,"KICK","Custom Message"}
		change value of 20 to rating tolerance
		change "KICK" to one of "KICK" or "BAN" for punishment
		change or add "Custom Message" for punishment's reason if you want so
		make the number values math.huge to disable them
	]]
	["RemoteFunctionCallPS"] = {20,"KICK","Due to spamming Remote Functions"},
	["MaxVariableCount"] = {70,"KICK"},
	["MaxTableLength"] = {1000,"KICK"},
	["MaxTableDepth"] = {20,"KICK"},
	["MaxStringLength"] = {4000,"KICK"},
	["RemoteEventCallPS"] = {300,"KICK"},
	["UnReliableRemoteEventCallPS"] = {300,"KICK"},
}

config.Protections = {
	["AntiDistanceRemove"] = {true,"KICK"},  --to disable change true with false
	["RemoteEventProtection"] = {true,"KICK"},
	["RemoteFunctionProtection"] = {true,"KICK"},
	["UnReliableRemoteEventProtection"] = {true,"KICK"}
}

config.Defaults = {
	["DefaultKickMessage"] = "You are kicked by RAntiCheat",
	["ExcludeAltAccountsOnBan"] = true,
	["ApplyToUniverseOnBan"] = true,
	["DefaultTimeOnBan"] = -1,
}

return config