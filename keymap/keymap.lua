-- Module dependencies
local awful = {}
awful.key = require("awful.key")
local utils = require("bewlib.utils")
local Type = require("bewlib.type")
local Eventemitter = require("bewlib.eventemitter")

local debug = require("gears.debug").dump_return

-- Module environement
local Keymap = Eventemitter({})
Type.registerType("Keymap")

-- Private environement
local registeredKeymaps = {}

Keymap.prototype = Eventemitter({
	_type = Type.Keymap,
})

local defaultModifiers = {
	m = "Mod3",
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






function Keymap.prototype:merge(otherKeymap)
	if not otherKeymap then return nil end

	--if Type(otherKeymap) ~= "Keymap" then
	if Type(otherKeymap) ~= Type.Keymap then
		--warning
		return nil
	end
	--TODO ...
	return self
end



-- Usage
--[[
mykeymap:add({
ctrl = {
--TODO: multi bind
{ mod = "MS", key = "c" },
{ mode = "M", mouse = "middle" }
},
press = function(self, c)
c:kill()
end,
})
--]]
function Keymap.prototype:add(bind)
	if not bind or not Type(bind) == "table" then return nil end

	-- FIXME: CA SERT A QUOI CA ?		ça sert a géré le cas ou bind est une table de bind
	if utils.table.hasIPairs(bind) then
		for _, v in ipairs(bind) do
			self:add(v)
		end
		return self
	end

	local press = nil
	if bind.press then
		press = function(...)
			bind.press(self, ...)
		end
	end

	local release = nil
	if bind.release then
		release = function(...)
			bind.release(self, ...)
		end
	end

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

	--TODO: ignore modifiers => ignore all modifiers (any)
	local modifiers = parseModifiers(self._modifiers, bind.ctrl.mod) or {}
	table.insert(self._keys, {
		bind = bind,
		--TODO: awful.button for buttons

		-- TODO: THIS MUST BE DONE IN KEYMAP.PROTOTYPE.APPLY, NOT HERE !!
		key = awful.key(modifiers, bind.ctrl.key, press, release)
	})

	return self
end

--[[
-- CAPI.KEY
--
-- FIXME: This is only revelant when using the keymap
-- in the root window, not in a grabber...
--TODO: see modifiers below
local keyObj = capi.key({ modifiers = util.table.join(mod, set), key = _key })

keyObj:connect_signal("press", function() -- (kobj, ...)
newkey:emit("press", newkey)
end)
keyObj:connect_signal("release", function()
newkey:emit("release", newkey)
end)
--TODO (maybe): handle longpress, so it doesnt call press a lot of times...

-- keep track of the association between newkey and keyObj
keysList[newkey] = keyObj
]]--

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


Keymap.prototype.mt = {
	__index = function(self, key)
		-- try to find key in prototype
		return Keymap.prototype[key]
	end,
}



function Keymap.getCApiKeys(name, options)
	local keymap = Keymap.find(name)
	if not keymap then
		return nil
	end
	return keymap:apply(options)
end

function Keymap.find(name)
	if not name then return nil end

	if Type(name) ~= "table" then
		return registeredKeymaps[name]
	end

	local allKeymaps = Keymap.new("noname", { alone = true, })
	for _, v in ipairs(name) do
		if Type(v) ~= "table" then
			allKeymaps:merge(Keymap.find(name)) --TODO
		end
	end
	return allKeymaps
end


-- call:
--
-- Keymap("name")		=> new (done)
-- Keymap.new("name")	=> new (done)

-- local first = Keymap.new("Tag Control", { parent = Keymap.safe.tag })
function Keymap.new(name, options)
	local modifiers = defaultModifiers
	local options = options or {}
	if options.modifiers then
		modifiers = utils.table.merge(modifiers, options.modifiers)
	end

	-- create the new keymap
	local newKeymap = {
		name = name,	-- if this is changed externaly, we need to change the keymap index in _keymaps table
		_modifiers = modifiers,		-- private
		_keys = {},					-- private
	}

	newKeymap = setmetatable(newKeymap, Keymap.prototype.mt)
	if not options.alone then
		registeredKeymaps[name] = newKeymap
	end
	return newKeymap
end

-- disable this ? (ambiguous...)
Keymap.mt = {
	--	__call = function(_, ...)
	--		Keymap.new(...)
	--		--change to Keymap.find(...) ?
	--	end,
}

Keymap = setmetatable(Keymap, Keymap.mt)

return Keymap
