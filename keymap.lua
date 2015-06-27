-- Module dependencies
local awful = require("awful")
local utils = require("bewlib.utils")
local Eventemitter = require("bewlib.eventemitter")

local debug = require("gears.debug").dump_return

-- Module environement
local Keymap = {
	mt = {},
	_keymaps = {},
}
Keymap = Eventemitter(Keymap)

local kmMethods = Eventemitter({})

local defaultModifiers = {
	M = "Mod4",
	C = "Control",
	S = "Shift",
	A = "Mod1",
}

--[[ Usage
mykeymap:add({
	ctrl = { mod = "MS", key = "c" },
	press = function(bind, c)
		c:kill()
	end,
})
]]--
function kmMethods:add(bind)
	if not bind then
		return
	end

	local modifier = Keymap.parseModifiers(self._modifiers, bind.ctrl.mod) or {}
	table.insert(self._keys, {
		bind = bind,
		key = awful.key(modifier, bind.ctrl.key, bind.press, bind.release)
	})

	return self
end

















function Keymap.parseModifiers(modifiers, bindMod)
	if not modifiers or not bindMod then
		return nil
	end
end










-- call:
--
-- Keymap("name")		=> new
-- Keymap.new("name")	=> new
-- mykeymap:clone("name")	=> clone

-- local first = Keymap.new("Tag Control", { parent = Keymap.safe.tag })
function Keymap.new(name, options)
	local modifiers = defaultModifiers
	if options and options.modifiers then
		modifiers = utils.table.merge(modifiers, options.modifiers)
	end

	-- create the new keymap
	local km = {
		name = name,
		_modifiers = modifiers,
		_keys = {},
	}

	km = utils.table.merge(km, kmMethods)
	Keymap._keymaps[name] = km
	return km
end

function Keymap.mt:__call(...)
	Keymap.new(...)
end

Keymap = setmetatable(Keymap, Keymap.mt)

return Keymap






-- SAVE
--[[

function keymap:addBind (bindOpt)
	if type(bindOpt) ~= "table" then
		return nil
	end
	local bind = {}
	bind.ctrl = type(bindOpt.ctrl) == "table" and bindOpt.ctrl or nil
	if bind.ctrl == nil then
		return nil
	end

	--TODO: bind.modifier
	bind.comment = type(bindOpt.comment) == "string" and bindOpt.comment or ""
	bind.hashtags = type(bindOpt.hashtags) == "string" and bindOpt.hashtags or ""
	bind.cmd = type(bindOpt.cmd) == "string" and bindOpt.cmd or nil
	bind.callback = type(bindOpt.cmd) == "function" and bindOpt.cmd or nil

	table.insert(self.binds, bind)
	return bind
end
--]]
