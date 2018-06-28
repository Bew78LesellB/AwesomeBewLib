--[[ bewlib.utils ]]--


-- Grab environement
local gears = require("gears")

-- Module environement
local utils = {}

--- Run a callback after N seconds
-- @param callback The function that'll be called
-- @param timeout time to wait before callback exec in second (can be a float)
-- @return The new timer
function utils.setTimeout(callback, timeout)
	local timer = gears.timer({ timeout = timeout })
	timer:connect_signal("timeout", function()
		timer:stop()
		callback()
	end)
	timer:start()
	return timer
end

--- Run a callback every N seconds
-- @param callback The function that'll be called
-- @param interval time to wait between callback exec in second (can be a float)
-- @param callAtStart if set, callback will be called at timer start
-- @return The new timer
function utils.setInterval(callback, interval, callAtStart)
	local timer = gears.timer({ timeout = interval })
	timer:connect_signal("timeout", callback)
	timer:start()
	if callAtStart == true then
		callback()
	end
	return timer
end

--- Read N lines of a given file
-- @param path The file path to read
-- @param nbLine The number of lines to read
--    default: read all
-- @return (table) containing the lines read from file
function utils.readFile(path, nbLine)
	nbLine = type(nbLine) == "number" and nbLine or false

	local f = io.open(path)
	if not f then return nil end

	local lines = {}
	local line_num = 1
	for line in f:lines() do
		table.insert(lines, line)
		if nbLine and nbLine == line_num then
			break
		end
		line_num = line_num + 1
	end
	f:close()
	return lines
end

utils.dump = require("gears.debug").dump_return
utils.inspect = require("inspect")

local logpath = "/tmp/awesome.log"
local logfile = io.open(logpath, "a+")
if logfile then
	logfile:write("#==> Awesome start [" .. os.date() .. "]\n")
end

function utils.log(...)
	if not logfile then return end

	logfile:write("LOG " .. os.date("%H:%M") .. " > ")
	io.stderr:write("LOG " .. os.date("%H:%M") .. " > ")
	for _, obj in ipairs({...}) do
		logfile:write(utils.inspect(obj))
		io.stderr:write(utils.inspect(obj))
	end
	logfile:write("\n");
	io.stderr:write("\n");
	logfile:flush();
end


utils.async = require("bewlib.utils.async")
utils.table = require("bewlib.utils.table")
utils.toast = require("bewlib.utils.toast")

return utils
