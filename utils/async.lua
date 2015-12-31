--[[ bewlib.utils.async ]]--


-- Grab environement

-- Module dependencies
local lain_async = require("lain.asyncshell")

-- Module environement
local async = {}

local debug = require("bewlib.utils.toast").debug

local function lain_async_request(cmd, callback)
	return lain_async.request(cmd, function(stdout)
		if #stdout == 0 then
			callback(nil)
		end
		callback(stdout)
	end)
end

function async.getAll(cmd, userCallback, allowNil)
	lain_async_request(cmd, function(stdout)
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
	return lain_async_request(cmd, function(stdout)
		if not stdout then
			if allowNil then
				userCallback(nil)
			end
			return
		end

		local i = 1
		local line
		for line in stdout:gmatch("[^\r\n]+") do
			if i == lineNo then
				break
			end
			i = i + 1
		end
		if not i == lineNo then
			return
		end
		userCallback(line)
	end)
end

function async.getFirstLine(cmd, userCallback, allowNil)
	return lain_async_request(cmd, function(stdout)
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

function async.justExec(cmd, userCallback)
	return lain_async_request(cmd, function(stdout)
		userCallback()
	end)
end

return setmetatable(async, { __call = async.just_exec })
