-- Module dependencies
local utils = require("bewlib.utils")

-- Module environement
local Command = {
	mt = {},
	_commandGroups = {},
}
--Command = Eventemitter(Command)
-- events:
-- * "run"
-- * "register"

--local grpPrototype = Eventemitter({})
local grpPrototype = {}

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

local function registerAction(actionName, grpName, callback, condition)
	local cmd = {
		_name = actionName,
		callback = callback,
		condition = condition,
	}
	Command._commandGroups[grpName]._actions[actionName] = cmd
	return cmd
end







function grpPrototype:register(name, callback, condition)
	if not name or type(callback) ~= "function" then
		return nil
	end
	name = {
		action = name,
		grp = self._name,
	}
	return registerAction(name.action, name.grp, callback, condition)
end

function Command.register(name, callback, condition)
	name = splitCommandName(name)
	local grp

	if not name then return nil end
	if name.grp then
		grp = registerGroup(name.grp)
	end
	if not name.action or type(callback) ~= "function" then
		return grp
	end
	return registerAction(name.action, name.grp, callback, condition)
end

function Command.run(name, options)
	local default = {
		force = false,
		args = {},
	}
	options = utils.table.merge(options or {}, default, true)
	local cmd = findCommandByName(name)

	if not cmd then return nil end
	if not options.force and type(cmd.condition) == "function" then
		if not cmd.condition() then
			return nil
		end
	end
	return cmd.callback(options.args)
end

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
	--utils.toast.debug(Command._commandGroups, {timeout = 30})
	Command.run("superGroup.action4")
end




Command = setmetatable(Command, Command.mt)

return Command
