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

local prototype = Eventemitter({})

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
function prototype:add(bind)
	if not bind or not type(bind) == "table" or not type(bind.ctrl) == "table" then
		return
	end

	local modifier = Keymap.parseModifiers(self._modifiers, bind.ctrl.mod) or {}
	table.insert(self._keys, {
		bind = bind,
		--TODO: awful.button for buttons
		key = awful.key(modifier, bind.ctrl.key, bind.press, bind.release)
	})

	return self
end



function prototype:get() end

function prototype:apply(opt) --TODO: refactor
	if not opt then opt = {} end

	local mode = opt.mode or "normal"
	local filter = opt.filter or "key"

	if mode == "normal" then
		local ret = {}

		for _, info in ipairs(self._keys) do
			local tab
			if filter == "key" and info.key then
				tab = info.key
			elseif filter == "button" and info.button then
				tab = info.button
			end
			for k, v in ipairs(tab) do
				table.insert(ret, v)
			end
		end
		return ret
	end
end














-- >> exemple params :
--
-- modifiers = {
--     M = "Mod4",
--     C = "Control",
--     S = "Shift",
--     A = "Mod1",
-- }
--
-- bindMod = "MS"
--
-- >> Return :
-- return = {
--     "Mod4",
--     "Shift",
-- }
function Keymap.parseModifiers(modifiers, bindMod)
	local mod = {}
	if not modifiers or not bindMod then
		return nil
	end

	for i = 1, #bindMod do
		local char = string.sub(bindMod, i, i)
		if modifiers[char] then
			table.insert(mod, modifiers[char])
		end
	end
	return mod
end





function Keymap.apply(name, opt)
	if not name or not Keymap._keymaps[name] then
		return nil
	end
	return Keymap._keymaps[name]:apply(opt)
end








-- call:
--
-- Keymap("name")		=> new (done)
-- Keymap.new("name")	=> new (done)
-- mykeymap:clone("new name")	=> clone (TODO)

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

	km = utils.table.merge(km, prototype)
	Keymap._keymaps[name] = km
	return km
end

function Keymap.mt:__call(...)
	Keymap.new(...)
end

Keymap = setmetatable(Keymap, Keymap.mt)

return Keymap
