--[[ bewlib.utils.async ]]--


-- Grab environement

-- Module dependencies
local lain_async = require("lain.asyncshell")

-- Module environement
local async = {}

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

return setmetatable(async, { __call = async.justExec })
