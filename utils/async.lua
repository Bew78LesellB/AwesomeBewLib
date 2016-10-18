--[[ bewlib.utils.async ]]--


-- Grab environement

-- Module dependencies
local awful_spawn = require("awful.spawn")

-- Module environement
local async = {}

local function async_request(cmd, callback)
	return awful_spawn.easy_async(cmd, function(stdout)
		if #stdout == 0 then
			callback(nil)
		end
		callback(stdout)
	end)
end

function async.getAll(cmd, userCallback, allowNil)
	async_request(cmd, function(stdout)
		if not stdout then
			if allowNil then
				userCallback(nil)
			end
			return
		end
		userCallback(stdout)
	end)
end

function async.getLine(cmd, lineNo, userCallback, allowNil)
	return async_request(cmd, function(stdout)
		if not stdout then
			if allowNil then
				userCallback(nil)
			end
			return
		end

		local line_num = 1
		for line in stdout:gmatch("[^\r\n]+") do
			if line_num == lineNo then
				userCallback(line)
				break
			end
			line_num = line_num + 1
		end
	end)
end

function async.getFirstLine(cmd, userCallback, allowNil)
	return async_request(cmd, function(stdout)
		if not stdout then
			if allowNil then
				userCallback(nil)
			end
			return
		end

		local line = stdout:match("^[^\n]*")
		userCallback(line)
	end)
end

return async
