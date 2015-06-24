--[[ bewlib.computer.battery ]]--

--[[ Battery management ]]--

-- Grab environement
local capi = {
	timer = timer
}

-- Module dependencies
local utils = require("bewlib.utils")

-- Module environement
local mod = {}

-- config vars
local settings = {
	name = "BAT0"
}

-- private vars
local bat_info = {
	present = false,
	techno = "",
	serial_nb = "",
	manufacturer = "",
	modelName = "",
	status = "Not present",
	perc = "N/A",
	time = "N/A",
	watt = "N/A"
}

local function updateBatteryInfos()
	function firstline(path)
		return utils.readFile(path, 1)[1]
	end

	local bpath  = "/sys/class/power_supply/" .. settings.name

	local present = firstline(bpath .. "/present")
	bat_info.present = present == "1" and true or false

	if bat_info.present then
		local rate  = firstline(bpath .. "/power_now") or firstline(bpath .. "/current_now")
		local ratev = firstline(bpath .. "/voltage_now")
		local rem   = firstline(bpath .. "/energy_now") or firstline(bpath .. "/charge_now")
		local tot   = firstline(bpath .. "/energy_full") or firstline(bpath .. "/charge_full")

		-- Status
		bat_info.status = firstline(bpath .. "/status") or "N/A"

		-- Time to empty/full
		rate  = tonumber(rate) or 1
		ratev = tonumber(ratev)
		rem   = tonumber(rem)
		tot   = tonumber(tot)

		local time_rat = 0
		if bat_info.status == "Charging" then
			time_rat = (tot - rem) / rate
		elseif bat_info.status == "Discharging" then
			time_rat = rem / rate
		end

		local hrs = math.floor(time_rat)
		if hrs < 0 then hrs = 0 elseif hrs > 23 then hrs = 23 end

		local min = math.floor((time_rat - hrs) * 60)
		if min < 0 then min = 0 elseif min > 59 then min = 59 end

		bat_info.time = string.format("%02d:%02d", hrs, min)

		-- Percentage
		bat_info.perc = tonumber(firstline(bpath .. "/capacity") or "0")
		if not bat_infos.perc then
			local rem   = firstline(bpath .. "/energy_now") or firstline(bpath .. "/charge_now")
			local tot   = firstline(bpath .. "/energy_full") or firstline(bpath .. "/charge_full")

			local perc = (rem / tot) * 100
			if perc <= 100 then
				bat_info.perc = perc
			elseif perc > 100 then
				bat_info.perc = 100
			elseif perc < 0 then
				bat_info.perc = 0
			end
		end

		-- Watt
		if rate ~= nil and ratev ~= nil then
			bat_infos.watt = string.format("%.2fW", (rate * ratev) / 1e12)
		else
			bat_infos.watt = "N/A"
		end
	end
end

function mod.getInfos(forceUpdate)
	if forceUpdate then
		updateBatteryInfos()
	end
	return bat_info
end

function mod.init()
	updateBatteryInfos()
	--TODO: init timers
end

return mod
