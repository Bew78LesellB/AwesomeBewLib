--[[ bewlib.utils ]]--


-- Grab environement
local capi = {
	timer = timer
}

-- Module dependencies
local naughty = require("naughty")

-- Module environement
local mod = {}

--- Create a notification with text 'text'
-- @param text The content of the notification
-- @param options The args like naughty.notify
-- @see naughty
function mod.toast(text, options)
	local options = options or {}
	options.text = text
	return naughty.notify(options)
end

--- Run a callback after N milliseconds
-- @param callback The function that'll be called
-- @param timeout N milliseconds to wait before callback exec
-- @return The new timer
function mod.setTimeout(callback, timeout)
	local theTimer = capi.timer({ timeout = timeout })
	theTimer:connect_signal("timeout", function()
		theTimer:stop()
		callback()
	end)
	theTimer:start()
	return theTimer
end

--- Run a callback every N milliseconds
-- @param callback The function that'll be called
-- @param timeout N milliseconds between callback exec
-- @param callAtStart if set, callback will be called at timer start
-- @return The new timer
function mod.setInterval(callback, interval, callAtStart)
	local theTimer = capi.timer({ timeout = interval })
	theTimer:connect_signal("timeout", callback)
	theTimer:start()
	if callAtStart then
		callback()
	end
	return theTimer
end

--- Read a N lines of a given file
-- @param path The file path to read
-- @param nbLine The number of lines to read
--    default: read all
-- @return a table containing the lines read from the file
function mod.readFile(path, nbLine)
	nbLine = type(nbLine) == "number" and nbLine or false
	local f = io.open(path)
	if not f then return nil end
	local tab = {}
	if not nbLine then
		for line in f:lines() do
			table.insert(tab, line)
		end
	else
		local i = 1
		for line in f:lines() do
			table.insert(tab, line)
			if nbLine == i then
				break
			end
			i = i + 1
		end
	end
	return tab
end

mod.async = require("bewlib.utils.async")

return mod
