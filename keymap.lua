-- Module dependencies
local awful = {}
awful.key = require("awful.key")
local utils = require("bewlib.utils")
local Eventemitter = require("bewlib.eventemitter")

local debug = require("gears.debug").dump_return

-- Module environement
local Keymap = {
	mt = {},
	_keymaps = {},
}
Keymap = Eventemitter(Keymap)

Keymap.prototype = Eventemitter({})

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
	ctrl = { mod = "MS", key = "c" },
	press = function(bind, c)
		c:kill()
	end,
})
]]--
function Keymap.prototype:add(bind)
	if not bind or not type(bind) == "table" or not type(bind.ctrl) == "table" then
		return
	end

	local modifier = parseModifiers(self._modifiers, bind.ctrl.mod) or {}
	table.insert(self._keys, {
		bind = bind,
		--TODO: awful.button for buttons
		key = awful.key(modifier, bind.ctrl.key, function(...) bind.press(self, ...) end, function(...) bind.release(self, ...) end)
	})

	return self
end



function Keymap.prototype:get() end --TODO: c'est quoi cette fonction ?

function Keymap.prototype:apply(options) --TODO: refactor
	if not options then options = {} end

	local mode = options.mode or "normal"
	local filter = options.filter or "key"
	local result = {}

	if mode == "normal" then
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
	end
	return result
end









function Keymap.apply(name, options)
	if not name or not Keymap._keymaps[name] then
		return nil
	end
	return Keymap._keymaps[name]:apply(options)
end



-- Keymap stack system

-- Example stack (high to low priority) :
-- {
--   { name = "high.priority.keymap", keymap = {} },
--   { name = "client.navigation", keymap = {} },
--   { name = "tag.navigation", keymap = {} },
--   { name = "layout.changer", keymap = {} },
--   { name = "awesome.base", keymap = {} },
-- }

-- Idea :
-- Keymap.stack.add(newStackID)
-- Keymap.stack.push(keymapName, options)
-- Keymap.stack.pop(keymapName, stackID)

Keymap._stackList = {
	root = {}
}

function Keymap.addStack(stackID)
	if not stackID or Keymap._stackList[stackID] then
		return false
	end

	Keymap._stackList[stackID] = {}
	return true
end

function Keymap.push(name, options)
	if not name or not Keymap._keymaps[name] then
		return false
	end

	local options = options or {}

	local stackID = options.stack or "root"
	local priority = options.priority or "high"

	if not Keymap._stackList[stackID] then
		utils.toast.error("In Keymap.push : cannot find stack with id " .. stackID)
		return false
	end

	if priority == "high" then -- put the keymap on top of the global stack
		table.insert(Keymap._stack, 1, {
			name = name,
			keymap = Keymap._keymaps[name],
		})
	elseif priority == "low" then -- put the Keymap on bottom of the global stack
		table.insert(Keymap._stack, {
			name = name,
			keymap = Keymap._keymaps[name],
		})
	else
		return false
	end
	return true
end

function Keymap.pop(name)
	if not name or not Keymap._keymaps[name] then
		return false
	end

	for k, v in Keymap._stack do
		if type(v) == "table" and v.name == name then
			table.remove(Keymap._stack, k)
			return true
		end
	end
	return false
end


-- Keymap keygrabber mode

-- Keymap.grabber.push(keymapName, options)
-- Keymap.grabber.pop(grabber)
-- Keymap.grabber.popAll()

function Keymap.set(name, options)
end

function Keymap.unset(name)
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

	km = utils.table.merge(km, Keymap.prototype)
	Keymap._keymaps[name] = km
	return km
end

function Keymap.mt:__call(...)
	Keymap.new(...)
end

Keymap = setmetatable(Keymap, Keymap.mt)

return Keymap
