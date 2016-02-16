-- Grab environement
local capi = {
	keygrabber = keygrabber,
}

-- Grab dependencies
local Keymap = require("bewlib.keymap")
local Key = require("bewlib.keymap.key")
local Type = require("bewlib.type")

local Grabber = {}

-- Module environement
local Grabber = Eventemitter({})
Type.registerType("Grabber")

-- Private environement

--- Table of grabbers registered with an ID, to run later
local registeredGrabbers = {}

--- Ordered list of grabbers
-- @order first == last added
local runningGrabbers = {}

local isRunning = false

Grabber.prototype = {
	_type = Type.Grabber,
	cancel = { key = "any" },
}


Grabber.prototype.mt = {
	__index = function(self, key)
		return Grabber.prototype[key]
	end,
}


-- Private functions

local function canSelectGrabber(currentGrabber, key)
	if type(grabber.selector.condition) == "function" then
		if not condition(grabber, key) then
			return false
		end
	end

	--TODO: check selector policy

	return true
end

local function grabberSelectorMustStop(grabber, match)
	-- TODO: check the grabber selector policy, to see if the event must be transfered to other grabbers, or blocked

	-- TODO to improve for better condition (try and/or pass/block, etc)

	if match and grabber.policy.block then
		return true
	end

	if match and grabber.policy.pass then
		return false
	end

	return false
end

local function dispatcher(mod, key, event)
	local key = Key.new(mod, key)

	--TODO: can we have a grabber with method ONCE, alongside other grabbers ?

	for i, grabber in ipairs(runningGrabbers) do

		local match = false

		-- check if we can use this grabber (grabber selector, policy, etc...)
		if canSelectGrabber(grabber, key) then


			-- check if key is a cancel key
			if key:match(grabber.cancel) then
				grabber:stop()
			end


			-- TODO: how do we get the functions press/release we need to execute ?
			if grabber:matchKey(key) then
				match = true
			end


			if grabberSelectorMustStop(grabber, match) then
				return		-- block event propagation
			end

		end

	end

	-- end of dispatcher
	-- do something ?
end




-- Public common prototype functions

function Grabber.prototype:run()
	return Grabber.run(self)
end

function Grabber.prototype:stop()
	return Grabber.stop(self)
end

-- TODO: how do we get the function press/release we need to do ?
function Grabber.prototype:matchKey(key)
	local t = Type(self.keymap)
	if t == "table" then
		for _, keymap in ipairs(self.keymap) do
			if keymap:findKey(key) then
				return true
			end
		end
		return false
	end
	return self.keymap:matchKey(key)
end

-- Public module functions

--- brief
function Grabber.grab(...)
	Grabber.run(Grabber.new(...))
end

--- brief
function Grabber.register(grabberID, grabber)
	if not grabberID or not grabber or Type(grabber) ~= Type.Grabber then
		--warning
		return
	end
	registeredGrabbers[grabberID] = grabber
	return grabber
end

--- brief
function Grabber.run(grabberOrGrabberID)
	local grabber = Grabber.find(grabberOrGrabberID)
	if not grabber then return end

	-- Remove from runningGrabbers if already running
	for i, g in ipairs(runningGrabbers) do
		if g == grabber then
			table.remove(runningGrabbers, i)
		end
	end

	-- Add the grabber in the beginning of the grabber stack
	table.insert(runningGrabbers, 1, grabber)

	if not isRunning then
		capi.keygrabber.run(dispatcher)
	end

	Grabber:emit("start", grabber)
	return grabber
end

--- brief
function Grabber.stop(grabberOrGrabberID)
	local grabber = Grabber.find(grabberOrGrabberID)
	if not grabber then return end

	--if not isRunning then
	if #runningGrabbers == 0 then
		-- There is no grabber running, so no grabber to stop...
		return
	end

	for i, g in ipairs(runningGrabbers) do
		if g == grabber then
			table.remove(runningGrabbers, i)
			Grabber:emit("stop", grabber)
		end
	end

	if #runningGrabbers == 0 then
		capi.keygrabber.stop()
	end
end

--- brief
function Grabber.find(grabberOrGrabberID)
	if not grabberOrGrabberID then
		--warning
		return
	end
	local grabber = grabberOrGrabberID
	if Type(grabberOrGrabberID) == Type.Grabber then
		return grabber
	end

	grabber = registeredGrabbers[grabberOrGrabberID]
	if grabber then
		return grabber
	end
	-- No grabber found
	--TODO: warning (each time ? really ?)
	return
end


--- Create a new grabber, and return it
-- @param keymapName (string or {string, ...}) : keymaps to use in this grabber
-- @param opt.method (const string) : The grab method
-- @param opt.cancel (function or Keybind) : TODO
-- @param opt.select.func (function) : TODO
-- @param opt.select.policy ({string, ..}) : TODO
-- @param opt.policy ({string, ..}) : TODO
function Grabber.new(keymapName, opt)
	--TODO (maybe): Args.check({keymapName, method, cancelKeybind}, {"string", "string", "table", (etc...)})

	local keymap

	if type(keymapName) == "table" then
		keymap = {}
		for i, kmName in ipairs(keymapName) do
			local km = Keymap.find(kmName)
			if km then
				table.insert(keymap, km)
			end
		end
		if #keymap == 0 then
			-- problem: there is no valid keymap given
			return
		end

	elseif type(keymapName) == "string" then
		keymap = Keymap.find(keymapName)
		if not keymap then
			-- problem: there is no valid keymap given
			return
		end

	else
		-- bad keymapName type...
		return
	end

	-- TODO:
	--if not checkCancelKeybind(cancelKeybind) then
	--	--warning
	--	return
	--end
	--TODO: check method exists      (later note: whatt ???)
	local name = keymapName
	if Type(name) == "table" then
		local str = ""
		for _, v in ipairs(name) do
			local space = ""
			if #str > 0 then
				space = " "
			end
			str = str .. space .. tostring(v)
		end
		name = str
	end

	-- TODO: init selector and policy with default if needed

	local newGrabber = Eventemitter({ --TODO: this is a read only object
		name = name,
		cancelKeybind = cancelKeybind,
		_method = method,
		_keymap = keymap,
		selector = (opt.selector or {}),
		policy = (opt.policy or {}),
	})
	return setmetatable(newGrabber, Grabber.prototype.mt)
end




-- Register to some events

Grabber:on("start", function(grabber)
	grabber:emit("start", grabber)
end)

Grabber:on("stop", function(grabber)
	grabber:emit("stop", grabber)
end)

Grabber:on("cancel", function(grabber)
	grabber:emit("cancel", grabber)
end)

Grabber:on("match", function(grabber)
	grabber:emit("match", grabber)
end)

return Grabber
