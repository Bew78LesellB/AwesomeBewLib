--[[ bewlib.utils.async ]]--


-- Grab environement

-- Module dependencies
local lain_async = require("lain.asyncshell")

-- Module environement
local async = {}

local function lain_async_request(cmd, callback)
	return lain_async.request(cmd, callback)
end

function async.getAll(cmd, callback)
	lain_async_request(cmd, callback)
end


function async.getLine(cmd, lineNo, callback)
	return lain_async_request(cmd, function(stdout)
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
		callback(line)
	end)
end

function async.getFirstLine(cmd, callback)
	return lain_async_request(cmd, function(stdout)
		local line = stdout:match("^[^\n]*")
		callback(line)
	end)
end

function async.justExec(cmd, callback)
	return lain_async_request(cmd, function(stdout)
		callback()
	end)
end

return setmetatable(async, { __call = async.just_exec })
