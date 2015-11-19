-- Module dependencies
local utils = require("bewlib.utils")

-- Module environement
local Command = {
	_commands = {},
}
--Command = Eventemitter(Command)
-- TODO events:
-- * "run"
-- * "register"

-- TODO: cmdPrototype functions
--local cmdPrototype = {}

-- TODO: remove 'group' concept ? no but do it differently

-- LOCAL FUNCTIONS

local function findCommandByName(cmdID)
	if not cmdID then return nil end
	if not Command._commands[cmdID] then
		return nil
	end
	return Command._commands[cmdID]
end

local function registerAction(cmdID, options)
	local cmd = {
		_name = cmdID,
		callback = options.callback,
		condition = options.condition,
		argsFilter = options.argsFilter,
	}
	Command._commands[cmdID] = cmd
	return cmd
end

local function runCommand(cmd, givenArgs, force)
	local finalArgs = givenArgs or {}

	if not cmd then return nil end

	if not force and type(cmd.condition) == "function" then
		if not cmd.condition() then
			return nil
		end
	end

	if givenArgs and cmd.argsFilter then
		for _, autorizedKey in ipairs(cmd.argsFilter) do
			if givenArgs[autorizedKey] then
				finalArgs[autorizedKey] = givenArgs[autorizedKey]
			end
		end
	end
	return cmd.callback(finalArgs)
end

local function checkRegisterOptionsOK(options)
	if not options then
		return nil
	end
	if type(options) ~= "table" then
		return false
	end
	if not options.callback or not type(options.callback) == "function" then
		return false
	end
	if options.condition and not type(options.condition) == "function" then
		return false
	end
	if options.argsFilter then
		if not type(options.argsFilter) == "table" then
			return false
		end
		do -- check that argsFilter have only ipairs values
			local i = 0
			for _, _ in ipairs(options.argsFilter) do
				i = i + 1
			end
			if not #options.argsFilter == i then
				return false
			end
		end
	end
	return true
end




-- PUBLIC FUNCTIONS

function Command.register(cmdID, options)
	print("Command.register " .. cmdID)
	local grp

	if not options then
		print("No options given")
		return nil
	end
	if type(options) == "function" then
		options = {
			callback = options,
		}
	elseif not checkRegisterOptionsOK(options) then
		print("Cannot register '" .. cmdID .. "', bad params")
		utils.toast.error("Cannot register '" .. cmdID .. "', bad params")
		return nil
	end

	print("registering action")
	return registerAction(cmdID, options)
end

function Command.run(name, args)
	local cmd = findCommandByName(name)

	if not cmd then
		utils.toast.error("Command '" .. tostring(name) .. "' not found")
		return nil
	end

	return runCommand(cmd, args, false)
end

function Command.forceRun(name, args)
	local cmd = findCommandByName(name)

	if not cmd then
		utils.toast.error("Command '" .. tostring(name) .. "' not found")
		return nil
	end

	return runCommand(cmd, args, true)
end

function Command.getFunction(name)
	local cmd = findCommandByName(name)

	if not cmd then
		utils.toast.error("Command '" .. tostring(name) .. "' not found")
		return nil
	end

	return cmd.callback
end


-- TEST

function Command.test()
	Command.register("myStandaloneAction", function()
		utils.toast("toast from myStandaloneAction")
	end)
	Command.register("superGroup.action1", function() end)
	Command.register("superGroup.action2", function()
		utils.toast("from superGroup.action2")
	end)
	Command.register("superGroup.action3", function()
		utils.toast("from superGroup.action3")
	end, function() return true end)
	Command.register("superGroup.action4", function()
		utils.toast("from superGroup.action4")
	end, function() return false end)
	Command.register("mynewgroup.")
	utils.toast.debug(Command._commands, {timeout = 30})
	Command.run("superGroup.action4")
end


Command = setmetatable(Command, {
	__call = function(_, ...)
		return Command.register(...)
	end,
})

return Command
