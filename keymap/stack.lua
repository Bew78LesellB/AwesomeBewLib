local utils = require("bewlib.utils")
local Keymap = require("bewlib.keymap.keymap")





-- Stack functions namespace
local Stack = {}




-- TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
--
--  Can we make a generic STACK system, then a specific one for keymap stack ?
--
--  Mybe not, as the keymap stack system, is not really a stack.....
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

Stack._stackList = {}

--
Stack._stackListFallback = {
	safe = {
		high = {},
		low = {},
	}
}


-- Keymap Stack prototype
Stack.prototype = {}

-- The stackID can be anything (string, object, tag, workspace, ...) (maybe not ?)
--- TODO: brief
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

		newStack = utils.table.merge(newStack, Stack.prototype)

		Stack._stackList[stackID] = newStack
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

