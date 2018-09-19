--[[ bewlib.computer.battery ]]--

--[[ Battery management ]]--

-- Grab environement
-- nothing

-- Module dependencies
local utils = require("bewlib.utils")
local Eventemitter = require("bewlib.eventemitter")

-- Module environement
-- Values will be initiated in Battery.init()
local Battery = {
	name = nil,
	path = nil,
    disabled = false,
}
Battery = Eventemitter(Battery)

Battery.DISCHARGING = "Discharging"
Battery.CHARGING = "Charging"
Battery.NOTPRESENT = "Not Present"
Battery.UNKNOWN_STATUS = "Unknown"

-- private vars
local defaultInfos = {
	present = false,
	status = Battery.NOTPRESENT,
	perc = "N/A",
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
	return firstline(Battery.path .. "/status") or defaultInfos.status
end

--- Test if there is a battery
-- @return (boolean) true if there is a battery, false otherwise
local function isPresent()
	local present = firstline(Battery.path .. "/present")
	return present == "1" and true or false
end

--- Get battery percentage
-- @return (number) the battery capacity percentage
local function getPercentage()
	local path = Battery.path
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
}

--- Update all battery dynamics informations
local function updateDynamicsInfos()
	local old = utils.table.clone(infos)

	-- get the new infos
    if Battery.disabled then
        -- While ACPI is broken, don't update battery info so we don't freeze awesome
        -- TODO: FIX ACPI ISSUES!!!!
        infos.perc = 0
        infos.status = "ACPI BROKEN"
    else
        for _, u in pairs(updateTab) do
            infos[u.fieldname] = infos.present and u.func() or defaultInfos[u.fieldname]
        end
    end

	-- emit event for changes if any
	for key, u in pairs(updateTab) do
		if old[u.fieldname] and old[u.fieldname] ~= infos[u.fieldname] then
			local param = nil
			if key == "percentage" then param = infos.perc end
			Battery:emit(u.eventname .. "::changed", infos[u.fieldname], param)
		end
	end
end

--- Update all battery infos
local function updateAll()
	infos.present = isPresent()
	updateDynamicsInfos()
end

--- Public function to update battery infos
-- @param 'what' (string) or (table of strings) specifies what to update,
--        can be :
--          - "all"
--          - "percentage"
--          - "status"
-- @return (table) the battery infos
function Battery.update(what)
	if what == "all" then
		updateAll()
	elseif type(what) == "string" and updateTab[what] then
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
function Battery.init(options)
	options = options or {}
	Battery.name = options.name or "BAT0"
	Battery.path = options.path or "/sys/class/power_supply/" .. Battery.name

	local updateTime = options.update or 30

	updateAll()
	utils.setInterval(function ()
		updateDynamicsInfos()
	end, updateTime)
end

Battery.infos = infos

Eventemitter.on("config::load", function()
	Battery:emit("percentage::changed", Battery.infos.perc)
	Battery:emit("status::changed", Battery.infos.status)
end)

return setmetatable(Battery, {
	__call = function(_, ...)
		return Battery.init(...)
	end
})
