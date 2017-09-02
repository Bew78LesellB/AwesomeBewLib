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

--- Merge a table into another, does not overwrite values in *tbl*
-- @param tbl (table) the base table
-- @param defaults (table) contain the fields to set/add in tbl
-- @param deep (boolean) Go recursive through tables ? (default: false)
-- @param new (boolean) Return a clone of base table ? (default: false)
-- @return (table) a merge of tbl and defaults tables
function table.merge(tbl, defaults, options)
	local opt = options or {}
	opt.deep = opt.deep ~= nil or false
	opt.new = opt.new ~= nil or false

	if not table.is_table(tbl) then
		tbl = {}
	end
	if type(defaults) ~= "table" then
		return nil -- return tbl ?
	end
	if opt.new then
		tbl = table.clone(tbl, true)
	end
	for k, v in pairs(defaults) do
		if type(v) == "table" then
			if tbl[k] and opt.deep then
				tbl[k] = table.merge(tbl[k], v, {deep = true, new = true})
			else
				tbl[k] = table.clone(v, true)
			end
        elseif tbl[k] == nil then
			tbl[k] = v
		end
	end
	return tbl
end

function table.is_iempty(tbl)
	local inext = ipairs(tbl)

	return inext(tbl) == nil
end

function table.is_empty(tbl)
	return next(tbl) == nil
end

function table.is_table(tbl)
	return tbl and type(tbl) == "table"
end

function table.get_ipos(tbl, value)
	for i, v in ipairs(tbl) do
		if v == value then
			return i
		end
	end
	return nil
end

function table.get_key_for(tbl, value)
	for k, v in pairs(tbl) do
		if v == value then
			return k
		end
	end
	return nil
end

function table.has_ivalue(tbl, value)
	return table.get_ipos(tbl, value) and true or false
end

function table.has_ipairs(tbl)
	return #tbl > 0
end

function table.has_pairs(tbl)
	return next(tbl) ~= nil
end

return table
