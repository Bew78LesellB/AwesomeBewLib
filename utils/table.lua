--[[ bewlib.utils.table ]]--

-- Module environement
local table = {}

--- Clone a table
-- @param tbl (table) the table to clone
-- @param deep (boolean) Go recursive through tables ? (default: false)
-- @return (table) a clone of tbl
function table.clone(tbl, deep)
    local c = {}
	for k, v in pairs(tbl) do
        if deep and type(v) == "table" then
            c[k] = table.clone(v)
        else
            c[k] = v
        end
    end
    return c
end





local toast = require("bewlib.utils.toast")
local debug = require("gears.debug").dump_return

--- Merge a table into another
-- @param tbl (table) the base table
-- @param toMerge (table) contain the fields to set/add in tbl
-- @param new (boolean) Return a clone of base table ? (default: false)
-- @param deep (boolean) Go recursive through tables ? (default: false)
-- @return (table) a merge of tbl and toMerge tables
function table.merge(tbl, toMerge, new, deep)
	if new then
		tbl = table.clone(tbl, true)
	end
	for k, v in pairs(toMerge) do
		if type(v) == "table" then
			if tbl[k] and deep then
				tbl[k] = table.merge(tbl[k], v, true, true)
			else
				tbl[k] = table.clone(v, true)
			end
		else
			tbl[k] = v
		end
	end
	return tbl
end

return table
