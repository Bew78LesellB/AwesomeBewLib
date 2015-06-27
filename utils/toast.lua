--[[ bewlib.utils.toast ]]--

-- Module dependencies
local naughty = require("naughty")

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

return setmetatable(toast, { __call = function(_, ...) dotoast(...) end })