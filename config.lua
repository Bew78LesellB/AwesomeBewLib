-- Resolve dependencies
local utils = require("bewlib.utils")

-- Module environement
local Config = {
	_config = {},
}

local configPrototype = {}

-- Local Functions

local function add(selfConfig, name, default)
end

local function set(selfConfig, name, value)
end

local function get(selfConfig, name)
end

-- Config Instance Functions

function configPrototype:addConfig(name, default)
	return add(self._config, name, default)
end

function configPrototype:setConfig(name, value)
	return set(self._config, name, value)
end

function configPrototype:getConfig(name)
	return get(self._config, name)
end

-- PUBLIC
-- Global Config Functions

function Config.add(name, default)
	return add(Config._config, name, default)
end

function Config.set(name, value)
	return set(self._config, name, value)
end

function Config.get(name)
	return get(self._config, name)
end

--- Attach the config system to any table
-- @return The new table with the config system
function Config.attachConfiguration(baseTable, options)
	options = type(options) == "table" and options or {}

	if baseTable and baseTable._config then
		return baseTable
	end
	if not options.parent then
		options.parent = Config
	end

	local function getNewConfig(baseTable, options)
		local newConfig = {
			_parent = options and options.parent or nil,
			_childs = {},
			keys = {},
		}
		--FIXME: not sure about this
		if options.parent and options.parent._config then
			table.insert(options.parent._config._childs, baseTable)
		end
		return newConfig
	end

	local newConfig = getNewConfig(baseTable, options)
	baseTable._config = newConfig
	return utils.table.merge(baseTable, configPrototype)
end

Config = setmetatable(Config, {
	__call = function(_, ...)
		Config.get(...)
	end,
})

return Config
