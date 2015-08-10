--[[ bewlib.computer.battery ]]--

--[[ Battery management ]]--

-- Grab environement
-- nothing

-- Module dependencies
local utils = require("bewlib.utils")
local eventemitter = require("bewlib.eventemitter")

-- Module environement
-- Values will be initiated in Battery.init()
local battery = {
	name = nil,
	path = nil,
}
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
	watt = "N/A",
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
-- @return (string) the battery power, in Watt
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

local updateTab = {
	percentage = {
		func = getPercentage,
		eventname = "percentage",
		fieldname = "perc"
	},
	status = {
		func = getStatus,
		eventname = "status",
		fieldname = "status"
	},
	timeLeft = {
		func = getTimeLeft,
		eventname = "timeLeft",
		fieldname = "timeLeft"
	},
	watt = {
		func = getWatt,
		eventname = "watt",
		fieldname = "watt"
	},
}

--- Update all battery dynamics informations
local function updateDynamicsInfos()
	local old = utils.table.clone(infos)

	-- get the new infos
	for _, u in pairs(updateTab) do
		infos[u.fieldname] = infos.present and u.func() or defaultInfos[u.fieldname]
	end

	local file = io.open("/home/lesell_b/awesome.debug", "a")

	-- emit event for changes if any
	for key, u in pairs(updateTab) do
		if old[u.fieldname] and old[u.fieldname] ~= infos[u.fieldname] then
			local param = nil
			if key == "percentage" then param = infos.perc end
			file:write("[" .. os.date() .. "] update: " .. key .. "\n")
			battery:emit(u.eventname .. "::changed", infos[u.fieldname], param)
		end
	end
	file:close()
end

--- Update all battery infos
function updateAll()
	infos.present = isPresent()
	updateDynamicsInfos()
end

--- Public function to update battery infos
-- @param 'what' (string) or (table of strings) specifies what to update,
--        can be :
--          - "all"
--          - "percentage"
--          - "timeLeft"
--          - "status"
--          - "watt"
-- @return (table) the battery infos
function battery.update(what)
	local oldvalue = nil
	if what == "all" then
		updateAll()
	elseif type(what) == "string" and updateTab[what] then
		oldvalue = infos[what]
		updateTab[what].func()
	elseif type(what) == "table" then
		for _, v in ipairs(what) do
			if updateTab[v] then
				updateTab[v].func()
			end
		end
	end
	return infos
end

--- Initialize battery module
function battery.init(options)
	options = options or {}
	battery.name = options.name or "BAT0"
	battery.path = options.path or "/sys/class/power_supply/" .. battery.name

	local updateTime = options.update or 30

	updateAll()
	utils.setInterval(function ()
		-- TODO: update only percentage ?
		updateDynamicsInfos()
	end, updateTime)
end

battery.infos = infos

return setmetatable(battery, {
	__call = function(_, ...)
		return battery.init(...)
	end
})
