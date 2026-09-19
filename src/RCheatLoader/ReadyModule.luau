local module = {}

function module.OnServerInvoke(vfunc)
	if _G.FuncsRCheat then
		--
	else
		repeat 
			task.wait()
		until _G.FuncsRCheat
	end
	
	return _G.FuncsRCheat.OnServerInvoke(vfunc)
end

return module