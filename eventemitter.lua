--[[ EventEmitter ]]--

local Eventemitter = { mt = {} }

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

	function newobj:on(...)
		on(newobj, ...)
	end

	function newobj:off(...)
		off(newobj, ...)
	end

	function newobj:emit(...)
		emit(newobj, ...)
	end

	return newobj
end

function Eventemitter.mt:__call(...)
	return Eventemitter.new(...)
end

return setmetatable(Eventemitter, Eventemitter.mt)
--return setmetatable({}, { __call = function(_, ...) return Eventemitter:new(...) end })
