--[[ EventEmitter ]]--

local Eventemitter = { mt = {} }

local function on(self, event, func)
	if not self._events[event] then
		self._events[event] = {}
	end
	self._events[event][func] = func
end

local function emit(self, event, ...)
	if not self._events[event] then
		return
	end
	for func in pairs(self._events[event]) do
        func(self, ...)
    end
end

function Eventemitter:new(obj)
	local newobj = obj or {}
	newobj._events = {}

	function newobj:on(event, func)
		on(self, event, func)
	end

	function newobj:emit(event, ...)
		emit(self, event, ...)
	end

	return newobj
end

function Eventemitter.mt:__call(...)
	return Eventemitter:new(...)
end

return setmetatable(Eventemitter, Eventemitter.mt)
--return setmetatable({}, { __call = function(_, ...) return Eventemitter:new(...) end })
