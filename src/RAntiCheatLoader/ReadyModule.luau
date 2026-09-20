local module = {}

function module.OnServerInvoke(vfunc)
	if _G.FuncsRAntiCheat then
		--
	else
		repeat 
			task.wait()
		until _G.FuncsRAntiCheat
	end
	
	return _G.FuncsRAntiCheat.OnServerInvoke(vfunc)
end

return module