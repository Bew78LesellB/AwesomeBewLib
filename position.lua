local Validator = require("bewlib.validator")

local Position = {}

local private = setmetatable({}, { __mode = "k" })

local builtins = {}

------------------------------------------------------------------------------------
-- Public functions
------------------------------------------------------------------------------------

--- Apply a position on a list
--
-- @param pos (Position) The position to apply
-- @param list (table) The list to apply the position on
-- @param options (table)
--   @table idx (number) The current idx (in case of a relative position)
--   @table insert (boolean) true if the new position is for insertion purpose
--
-- @return (number) The new position
function Position.apply(pos, list, options)
	-- args checks
	if not Position.exists(pos) then
		-- raise("bad args")
		return 1
	end
	if not type(list) == "table" or #list == 0 then
		-- raise("bad args")
		return 1
	end

	local opt = options or {}
	local currentIdx = opt.idx or 1
	local last = #list + (opt.insert and 1 or 0)
	local newpos

	-- absolute
	if pos.abs then
		if pos.abs < 0 then
			-- note: if (pos.abs == -1) it must be the last one
			newpos = (last + 1) - math.abs(pos.abs)
		else
			newpos = pos.abs
		end
	end

	-- relative
	-- 1 [2] 3 4
	-- < -1 |> 1
	-- <  1 |> 3
	-- < -1 | insert |> 2
	-- FIXME: sure to keep like this ?
	if pos.rel then
		local rel = pos.rel

		if opt.insert then
			if rel < 0 then
				rel = rel - 1
			end
		end

		newpos = currentIdx + rel
	end

	-- bound check
	newpos = newpos > last and last or newpos
	newpos = newpos < 0 and 0 or newpos

	return newpos
end

-- Checkers
---------------------------------------------------------------

--- Check if a given instance exists
--
-- @param pos (Position) The instance to check
--
-- @return (boolean) true if exists, false otherwise
function Position.exists(pos)
	return private[pos] ~= nil
end

-- Builders
---------------------------------------------------------------

--- Build an absolute position
--
-- @param pos (number) The absolute position
--
-- @return (Position) The Position object
function Position.abs(pos)
	return Position.new({ abs = pos })
end

--- Build a relative position
--
-- @param pos (number) The relative position
--
-- @return (Position) The Position object
function Position.rel(pos)
	return Position.new({ rel = pos })
end

--- Add a builtin Position, accessible via Position.NAME
--
-- @param name (string) The name of the builtin. Must be a string. It will be format in UPPERCASE.
-- @param pos (Position|table) The builtin value. If it's not a Position instance,
--        it'll be passed to the Position.new constructor.
--
-- @return (Position) The Position object
function Position.addBuiltin(name, pos)
	if not type(name) == "string" and name ~= "" then
		error("Position name should be a valid string")
	end

	name = name:upper()

	if not Position.exists(pos) then
		pos = Position.new(pos)
	end

	if name and pos then
		builtins[name] = pos
	end
	return pos
end

-- Constructor
---------------------------------------------------------------

--- Create a new Position object
--
-- @param value (number|table) An absolute value,
--        or a table containing { abs = value } or { rel = value }
--
-- @return The Position object
function Position.new(value)
	local newPos = {}

	if type(value) == "table" then
		newPos.abs = value.abs or nil
		newPos.rel = value.rel or nil
	elseif type(value) == "number" then
		newPos.abs = value
	end

	if not newPos.rel and not newPos.abs then
		return nil
	end

	private[newPos] = true -- no private data
	return newPos
end

setmetatable(Position, {
	__index = function (self, key)
		return builtins[key]
	end
})


------------------------------------------------------------------------------------
-- Validator rule
------------------------------------------------------------------------------------

Validator.new("position", function(v)

	v:match("one")

	v:addRule("instance", function(pos)
		return Position.exists(pos)
	end)

	v:addRule("builtin", function(pos)
		if not type(pos) == "string" then return false end

		pos = pos:upper()
		return builtins[pos] ~= nil
	end)

	v:addRule("rel", function(pos)
		-- check if pos is a relative position (ex : "r-3")
	end)

	v:addRule("abs", function(pos)
		-- check if pos is an absolute position (ex : "a5")
	end)

end)

------------------------------------------------------------------------------------
-- Final init
------------------------------------------------------------------------------------

-- Define some BUILTINS
---------------------------------------------------------------

-- Base
------------------------------------------

Position.addBuiltin("NEXT", Position.rel(1))
Position.addBuiltin("PREV", Position.rel(-1))

Position.addBuiltin("BEGIN", Position.abs(1))
Position.addBuiltin("END", Position.abs(-1))

-- Aliases
------------------------------------------

Position.addBuiltin("RIGHT", Position.NEXT)
Position.addBuiltin("LEFT", Position.PREV)

return Position
