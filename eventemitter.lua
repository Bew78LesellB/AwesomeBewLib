--[[ EventEmitter ]]--

local Eventemitter = {
	_events = {},
	mt = {},
}

local function on(self, event, func)
	if not self._events[event] then
		self._events[event] = {}
	end
	self._events[event][func] = func
end

local function off(self, event, func)
	if not self._events[event] then
		return
	end
	self._events[event][func] = nil
end

local function emit(self, event, ...)
	if not self._events[event] then
		return
	end
	for func in pairs(self._events[event]) do
        func(self, ...)
    end
end

function Eventemitter.new(obj)
	local newobj = obj or {}
	newobj._events = {}

	newobj.on = on
	newobj.off = off
	newobj.emit = emit

	return newobj
end

function Eventemitter.on(...)
	on(Eventemitter, ...)
end
function Eventemitter.off(...)
	off(Eventemitter, ...)
end
function Eventemitter.emit(...)
	emit(Eventemitter, ...)
end

function Eventemitter.mt:__call(...)
	return Eventemitter.new(...)
end

return setmetatable(Eventemitter, Eventemitter.mt)
