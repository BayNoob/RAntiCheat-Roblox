local startedsearchingat = os.clock()
repeat
    task.wait(.1)
until (_G.VendoredRAntiCheat and typeof(_G.VendoredRAntiCheat) == "Instance") or ((os.clock() - startedsearchingat) > 5)
if _G.VendoredRAntiCheat then
    require(_G.VendoredRAntiCheat).Load(script)
else
    require(76526215675460).Load(script)
end
