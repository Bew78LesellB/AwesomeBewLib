local Const = {}

local constList = {}

local constID = 0

function Const.add(constantName)
	if not constList[constantName] then
		constID = constID + 1
		constList[constantName] = constID
		return constID
	end
	return nil
end

Const.add("LEFT")
Const.add("RIGHT")

Const.add("PREVIOUS")
Const.add("NEXT")
Const.add("LAST")

Const.add("UP")
Const.add("DOWN")

Const.mt = {
	__index = function(self, key)
		return constList[key]
	end,

	__newindex = function(self, key, value)
		-- do nothing
	end,
}

return setmetatable(Const, Const.mt)
