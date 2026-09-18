--[[
 .S_sSSs      sSSs   .S    S.     sSSs   .S_SSSs    sdSS_SSSSSSbs
.SS~YS%%b    d%%SP  .SS    SS.   d%%SP  .SS~SSSSS   YSSS~S%SSSSSP
S%S   `S%b  d%S'    S%S    S%S  d%S'    S%S   SSSS       S%S
S%S    S%S  S%S     S%S    S%S  S%S     S%S    S%S       S%S
S%S    d*S  S&S     S%S SSSS%S  S&S     S%S SSSS%S       S&S
S&S   .S*S  S&S     S&S  SSS&S  S&S_Ss  S&S  SSS%S       S&S
S&S_sdSSS   S&S     S&S    S&S  S&S~SP  S&S    S&S       S&S
S&S~YSY%b   S&S     S&S    S&S  S&S     S&S    S&S       S&S
S*S   `S%b  S*b     S*S    S*S  S*b     S*S    S&S       S*S
S*S    S%S  S*S.    S*S    S*S  S*S.    S*S    S*S       S*S
S*S    S&S   SSSbs  S*S    S*S   SSSbs  S*S    S*S       S*S
S*S    SSS    YSSP  SSS    S*S    YSSP  SSS    S*S       S*S
SP                         SP                  SP        SP

Made by Bay_NoobTR


We recommend you to enable \ workspace.AuthorityMode since RCheat is not built for physichs-based anticheat.

You can add .. in your text if you want use default reason and custom reason at the same time for example>

config.RateLimits = {
	["RemoteFunctionCallPS"] = {20,"KICK","Due to spamming Remote Functions"},
}
kicks as > Due to spamming Remote Functions
"..Due to spamming Remote Functions"
kicks as > You are kicked by RCheat Due to spamming Remote Functions
"Due to spamming Remote Functions.."
kicks as > Due to spamming Remote Functions You are kicked by RCheat
{20,"KICK"}
kicks as > You are kicked by RCheat (or specific default message you configured)


To use RemoteFunction Wrapper in your script here is example what to do as an example >

local Funcs = _G.FuncsRCheat or require(game.ServerScriptService.RCheat.Manager.Funcs)
RemoteFunction.OnServerInvoke = Funcs.OnServerInvoke(function(player,...)
	print("Hello World "..player.Name.."!")
end)


You can safely delete this script


RCheat v0.6
]]