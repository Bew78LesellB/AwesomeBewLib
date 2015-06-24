--[[ Battery API usage ]]--


local battery = require("bewlib.computer.battery")

--[[

]]--

battery.connect_signal("state::changed", function(batInfos)
	if batInfos.perc > 10 then return end
	-- do something with the battery infos when battery < 10%
end)


