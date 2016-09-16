-- Module dependencies
local awful = {}
awful.key = require("awful.key")
local utils = require("bewlib.utils")
local Eventemitter = require("bewlib.eventemitter")

local debug = require("gears.debug").dump_return

-- Module environement
local Keymap = {
	mt = {},
}
Keymap = Eventemitter(Keymap)

Keymap.prototype = Eventemitter({})

local keymaps = {}

local defaultModifiers = {
	M = "Mod4",
	C = "Control",
	S = "Shift",
	A = "Mod1",
}







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
local function parseModifiers(modifiers, bindMod)
	local mod = {}
	if not modifiers or not bindMod then
		return {}
	end

	for i = 1, #bindMod do
		local char = string.sub(bindMod, i, i)
		if modifiers[char] then
			table.insert(mod, modifiers[char])
		end
	end
	return mod
end







--[[ Usage
mykeymap:add({
.   ctrl = { mod = "MS", key = "c" },
.   press = function(self, c)
.   .   c:kill()
.   end,
})
]]--
function Keymap.prototype:add(bind)
	if not bind or not type(bind) == "table" or not type(bind.ctrl) == "table" then
		return
	end

	-- TODO: handle : ctrl = {
	--     { mod = "M", key = "j" },
	--     { mod = "M", key = "Left" },
	-- }

	local modifier = parseModifiers(self._modifiers, bind.ctrl.mod) or {}

	local press_callback = nil
	local release_callback = nil

	if bind.press then
		press_callback = function(...)
			bind.press(self, ...)
		end
	end

	if bind.release then
		release_callback = function(...)
			bind.release(self, ...)
		end
	end

	table.insert(self._keys, {
		bind = bind,
		--TODO: awful.button for buttons

		-- TODO: directly use capi.key() ?
		-- FIXME: awful.key can return multiple keys !!
		key = awful.key(modifier, bind.ctrl.key, press_callback , release_callback)
	})

	return self
end


function Keymap.prototype:apply(options) --TODO: refactor
	if not options then options = {} end

	local filter = options.filter or "key"
	local result = {}

	for _, info in ipairs(self._keys) do
		local tab
		if filter == "key" and info.key then
			tab = info.key
		elseif filter == "button" and info.button then
			tab = info.button
		end
		if tab then
			for _, v in ipairs(tab) do
				table.insert(result, v)
			end
		end
	end
	return result
end



function Keymap.getCApiKeys(name, options)
	local keymap = Keymap.get(name)
	if not keymap then
		return nil
	end
	return keymap:apply(options)
end

function Keymap.get(name)
	if not name then
		return nil
	end
	return keymaps[name]
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
	local newKeymap = {
		name = name,
		_modifiers = modifiers,
		_keys = {},
	}

	newKeymap = utils.table.merge(newKeymap, Keymap.prototype)
	keymaps[name] = newKeymap
	return newKeymap
end

-- disable this ? (ambiguous...)
function Keymap.mt:__call(...)
	Keymap.new(...)
	--change to Keymap.get(...) ?
	--or new if Keymap with the given name doesnt exist
end

Keymap = setmetatable(Keymap, Keymap.mt)

return Keymap
