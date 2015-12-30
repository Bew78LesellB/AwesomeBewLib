--[[ bewlib.utils.toast ]]--

-- Grab environement
local std = {
	debug = debug,
}

-- Module dependencies
local naughty = require("naughty")
local dump = require("gears.debug").dump_return
local merge = require("bewlib.utils.table").merge

-- Module environement
local toast = {}

--- Create a notification with text 'text'
-- @param text The content of the notification
-- @param options The args like naughty.notify
-- @return The notification table
-- @see naughty
local function dotoast(text, options)
	local options = options or {}
	options.text = text
	return naughty.notify(options)
end

function toast.debug(obj, options)
	local default = {
		timeout = 30,
		bg = "#0277BD",
		fg = "#FFFFFF",
	}
	options = merge(options or {}, default)
	return dotoast(dump(obj), options)
end

function toast.error(text, options)
	local default = {
		timeout = 0,
		border_width = 0,
		bg = "#F44336",
		fg = "#FFEBEE",
	}
	options = merge(options or {}, default)
	text = tostring(text) .. "\n\n" .. std.debug.traceback()
	return dotoast(text, options)
end

function toast.warning(text, options)
	local default = {
		timeout = 20,
		border_width = 0,
		bg = "#FFEA00",
		fg = "#424242",
	}
	options = merge(options or {}, default)
	return dotoast(text, options)
end

return setmetatable(toast, {
	__call = function(_, ...)
		return dotoast(...)
	end
})
