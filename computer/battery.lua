--[[ bewlib.computer.battery ]]--

--[[ Battery management ]]--

-- Grab environement
-- nothing

-- Module dependencies
local utils = require("bewlib.utils")
local eventemitter = require("bewlib.eventemitter")

-- Module environement
local battery = {
	name = "BAT0",
}
battery.path = "/sys/class/power_supply/" .. battery.name
battery = eventemitter(battery)

-- private vars
local defaultInfos = {
	present = false,
	--techno = "Unknown",
	--serial_nb = "Unknown",
	--manufacturer = "Unknown",
	--modelName = "Unknown",
	status = "Not present",
	perc = "N/A",
	timeLeft = "N/A",
	watt = "N/A"
}
local infos = {}


--[[
TODO: make update time variable, ex :
update :
- status = 2 sec
- other = 15 sec

TODO: put getters in table, for easier and generic access
]]--

--- Get the first line of specified file
-- @param path the file path to read from
-- @return the first line
local function firstline(path)
	local file = utils.readFile(path, 1)
	return file and file[1] or nil
end

--- Get the battery status
-- @return the battery status ("Charging" "Discharging" "Full")
local function getStatus()
	return firstline(battery.path .. "/status") or defaultInfos.status
end

--- Test if there is a battery
-- @return (boolean) true if there is a battery, false otherwise
local function isPresent()
	local present = firstline(battery.path .. "/present")
	return present == "1" and true or false
end

--- Get time to full or time to empty
-- @return (string) time to full if charging, time to empty if discharging
local function getTimeLeft()
	if not infos.present then return defaultInfos.timeLeft end

	local path = battery.path
	local rem   = firstline(path .. "/energy_now") or firstline(path .. "/charge_now")
	local tot   = firstline(path .. "/energy_full") or firstline(path .. "/charge_full")
	local rate  = firstline(path .. "/power_now") or firstline(path .. "/current_now")

	rate  = tonumber(rate) or 1
	rem   = tonumber(rem)
	tot   = tonumber(tot)
	if not rem or not tot then
		return defaultInfos.timeLeft
	end

	local time_rat = 0
	if infos.status == "Charging" then
		time_rat = (tot - rem) / rate
	elseif infos.status == "Discharging" then
		time_rat = rem / rate
	end

	local hrs = math.floor(time_rat)
	if hrs < 0 then hrs = 0 elseif hrs > 23 then hrs = 23 end

	local min = math.floor((time_rat - hrs) * 60)
	if min < 0 then min = 0 elseif min > 59 then min = 59 end

	return string.format("%02d:%02d", hrs, min)
end

--- Get battery percentage
-- @return (number) the battery capacity percentage
local function getPercentage()
	local path = battery.path
	local perc = firstline(path .. "/capacity")

	if perc then
		return tonumber(perc)
	end

	local rem = firstline(path .. "/energy_now") or firstline(path .. "/charge_now")
	local tot = firstline(path .. "/energy_full") or firstline(path .. "/charge_full")

	if not tot or not rem then
		return defaultInfos.perc
	end

	perc = (rem / tot) * 100
	if perc > 100 then return 100 end
	if perc < 0 then return 0 end
	return perc
end

--- Get battery power
-- @return (string) the battery power
local function getWatt()
	local path  = battery.path
	local rate  = firstline(path .. "/power_now") or firstline(path .. "/current_now")
	local ratev = firstline(path .. "/voltage_now")

	rate  = tonumber(rate) or 1
	ratev = tonumber(ratev)

	if rate and ratev then
		return string.format("%.2fW", (rate * ratev) / 1e12)
	end
	return defaultInfos.watt
end

--battery:add_signal("status::changed")

--- Update all battery dynamics informations
local function updateDynamicsInfos()
	local old = utils.clone(infos)
	infos.status = infos.present and getStatus() or defaultInfos.status
	infos.timeLeft = infos.present and getTimeLeft() or defaultInfos.time 
	infos.perc = infos.present and getPercentage() or defaultInfos.perc
	infos.watt = infos.present and getWatt() or defaultInfos.watt

	--TODO: generic emitter
	if old.perc and old.perc ~= infos.perc then battery:emit("percentage::changed", infos.perc) end
	if old.timeLeft and old.timeLeft ~= infos.timeLeft then battery:emit("timeLeft::changed", infos.timeLeft) end
	if old.status and old.status ~= infos.status then battery:emit("status::changed", infos.status) end
	if old.watt and old.watt ~= infos.watt then battery:emit("watt::changed", infos.watt) end
end

--- Update all battery infos
function updateAll()
	infos.present = isPresent()
	--updateHardwareInfos() --TODO
	updateDynamicsInfos()
end

--- Public function to update battery infos
-- @param flag specify what to update ("all" | "dynamic" | "hardware")
-- @return (table) the battery infos
function battery.update(flag)
	if flag == "all" then
		updateAll()
		--elseif flag == "hardware" then
		--updateHardwareInfos()
	elseif flag == "dynamic" or not flag then
		updateDynamicsInfos()
	end
	return infos
end

--- Initialize battery module
function battery.init(options)
	if options then
		if options.name then
			battery.name = options.name
		end
		if options.path then
			battery.path = options.path
		end
	end
	local update = options and options.update or 30

	updateAll()
	-- init update timer
	utils.setInterval(function ()
		updateDynamicsInfos()
	end, update)
end

battery.infos = infos

return battery
