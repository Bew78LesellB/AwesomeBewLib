local utils = require("bewlib.utils")
local Keymap = require("bewlib.keymap.keymap")
local Type = require("bewlib.type")





-- Stack public namespace
Type.registerType("KeymapStack")
local Stack = {
	prototype = {
		_type = Type.KeymapStack,
	},
}




-- TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
--
--  Can we make a generic STACK system, then a specific one for keymap stack ?
--
--  Mybe not, as the keymap stack system, is not really a stack..... TODO: rename this module
--
-- TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO



-- Keymap stack system

-- Example _stackList :
-- {
--   high = {
--     { name = "high.priority.keymap", keymap = {} },
--   },
--   low = {
--     clientNavKeymap,		-- ("client.navigation")
--     tagNavKeymap,		-- ("tag.navigation")
--     layoutChangerKeymap,	-- ("layout.changer")
--   },
-- }
--
-- Example _stackListFallback :
-- {
--   high = {
--     functionKeysKeymap,	-- ("function-keys")
--   },
--   low = {},
-- }

--FIXME: this could be private (local), maybe...
Stack._stackList = {}

--FIXME: this has to be a table ?
Stack._stackListFallback = {
	safe = {
		high = {},
		low = {},
	}
}


--- TODO: brief
-- @param stackID (any, TODO:maybe not ?)
function Stack.new(stackID)
	if not stackID then
		return nil
	end
	if not Stack._stackList[stackID] then
		local newStack = {
			_id = stackID,
			high = {},
			low = {},
		}

		Stack._stackList[stackID] = setmetatable(newStack, Stack.prototype.mt)
	end

	return Stack._stackList[stackID]
end

--- TODO: brief
function Stack.get(stackID)
	if not stackID then
		return nil
	end

	local stack = Stack._stackList[stackID]
	if not stack and type(stackID) == "string" then
		utils.toast.error("Stack.get : Cannot find a stack with id '" .. stackID .. "'")
		return nil
	end
	return stack
end



--- TODO: brief
--@param name :
--@param priority :
function Stack.prototype:push(name, priority)
	local keymap = Keymap.get(name)
	if not keymap then return nil end

	local priority = priority or "high"

	if not (priority == "high" or priority == "low") then
		return false
	end

	table.insert(self[priority], 1, keymap)
	return true
end

--- TODO: brief
--@param name :
function Stack.prototype:pop(name)
	local keymap = Keymap.get(name)
	if not keymap then return nil end

	for _, priority in { "high", "low" } do

		for k, v in self[priority] do
			if keymap == v then
				table.remove(self[priority], k)
				return true
			end
		end

	end
	return false
end

Stack.prototype.mt = {
	__index = function(self, key)
		-- try to find key in prototype
		return Stack.prototype[key]
	end,
}

Stack.mt = {}

return setmetatable(Stack, Stack.mt)
