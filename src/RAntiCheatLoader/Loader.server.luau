local startedSearchingAt = os.clock()

repeat
	task.wait(0.1)
until (_G.VendoredRAntiCheat and typeof(_G.VendoredRAntiCheat) == "Instance")
	or ((os.clock() - startedSearchingAt) > 5)

if _G.VendoredRAntiCheat then
	require(_G.VendoredRAntiCheat).Load(script)
else
	local success, module = pcall(require, 76526215675460)

	if success then
		module.Load(script)
	else
		local backupSuccess, backupModule = pcall(require, 121782559013421)

		if backupSuccess then
			backupModule.Load(script)
		else
			warn("RAntiCheat could not be loaded from either require.")
		end
	end
end