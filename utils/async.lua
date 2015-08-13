--[[ bewlib.utils.async ]]--


-- Grab environement

-- Module dependencies
local lain_async = require("lain.asyncshell")

-- Module environement
local async = {}

function async.getAll(cmd, callback)
	lain_async.request(cmd, function(file_out)
		local stdout = file_out:read("*all")
		file_out:close()
		callback(stdout)
	end)
end

function async.getLine(cmd, lineNo, callback)
	lain_async.request(cmd, function(file_out)
		local i = 1
		local line = nil
		while i <= lineNo do
			line = file_out:read("*line")
			i = i + 1
		end
		file_out:close()
		callback(line)
	end)
end

function async.getFirstLine(cmd, callback)
	lain_async.request(cmd, function(file_out)
		local line = file_out:read("*line")
		file_out:close()
		callback(line)
	end)
end

function async.justExec(cmd, callback)
	lain_async.request(cmd, function(file_out)
		file_out:close()
		callback()
	end)
end

return setmetatable(async, { __call = async.just_exec })
