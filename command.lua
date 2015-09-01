-- Module dependencies
local utils = require("bewlib.utils")

-- Module environement
local Command = {
	_commandGroups = {},
}
--Command = Eventemitter(Command)
-- events:
-- * "run"
-- * "register"

--local grpPrototype = Eventemitter({})
local grpPrototype = {}

-- TODO: cmdPrototype functions
--local cmdPrototype = {}


-- LOCAL FUNCTIONS

local function splitCommandName(name)
	local wordPattern = "[%w_%-]*"
	local grp, action
	grp, action = string.match(name, "^[%s]*(" .. wordPattern .. ")%.(" .. wordPattern .. ")[%s]*$")
	local word = string.match(name, "^(" .. wordPattern .. ")$")

	local name = {
		grp = grp ~= "" and grp or "nogroup",
		action = (action ~= "" and action) or word or nil,
	}
	if not name.action and not name.grp then
		return nil
	end
	return name
end

local function findCommandByName(name)
	name = splitCommandName(name)

	if not name then return nil end
	if not name.action or not Command._commandGroups[name.grp] then
		return nil
	end
	return Command._commandGroups[name.grp]._actions[name.action]
end

local function registerGroup(grpName)
	if not grpName then return nil end

	local function getNewGroup(name)
		local grp = {
			_name = name,
			_actions = {}
		}
		grp = utils.table.merge(grp, grpPrototype)
		return grp
	end

	if not Command._commandGroups[grpName] then
		Command._commandGroups[grpName] = getNewGroup(grpName)
	end
	return Command._commandGroups[grpName]
end

local function registerAction(actionName, grpName, options)
	local cmd = {
		_name = actionName,
		callback = options.callback,
		condition = options.condition,
		argsFilter = options.argsFilter,
	}
	Command._commandGroups[grpName]._actions[actionName] = cmd
	return cmd
end

local function runCommand(cmd, givenArgs, force)
	local finalArgs = {}

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
	if not options or type(options) ~= "table" then
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

function grpPrototype:register(name, options)
	if not name then
		return nil
	end
	if type(options) == "function" then
		options = {
			callback = options,
		}
	elseif not checkRegisterOptionsOK(options) then
		return nil
	end

	return registerAction(name, self._name, options)
end

function Command.register(name, options)
	name = splitCommandName(name)
	local grp

	if not name then return nil end
	if type(options) == "function" then
		options = {
			callback = options,
		}
	elseif not checkRegisterOptionsOK(options) then
		return nil
	end

	if name.grp then
		grp = registerGroup(name.grp)
	end
	if not name.action then
		return grp
	end
	return registerAction(name.action, name.grp, options)
end

function Command.run(name, args)
	local cmd = findCommandByName(name)

	return runCommand(cmd, args, false)
end

function Command.forceRun(name, args)
	local cmd = findCommandByName(name)

	return runCommand(cmd, args, true)
end

function Command.getFunction(name)
	local cmd = findCommandByName(name)

	if not cmd then return nil end
	return cmd.callback
end


-- TEST

function Command.test()
	Command.register("myStandaloneAction", function()
		utils.toast("toast from myStandaloneAction")
	end)
	Command.register("superGroup.action1", function() end)
	Command.register("superGroup.action2", function()
		utils.toast("from superGroup.Action2")
	end)
	Command.register("superGroup.action3", function()
		utils.toast("from superGroup.Action3")
	end, function() return true end)
	Command.register("superGroup.action4", function()
		utils.toast("from superGroup.Action4")
	end, function() return false end)
	Command.register("mynewgroup.")
	utils.toast.debug(Command._commandGroups, {timeout = 30})
	Command.run("superGroup.action4")
end


Command = setmetatable(Command, {
	__call = function(_, ...)
		return Command.register(...)
	end,
})

return Command
