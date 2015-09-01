--TODO: make impossible to reset a constant
local Const = {}

local constID = 0

local function addConst()
	constID = constID + 1
	return constID
end

Const.LEFT = addConst()
Const.RIGHT = addConst()

Const.PREVIOUS = addConst()
Const.NEXT = addConst()
Const.LAST = addConst()

Const.UP = addConst()
Const.DOWN = addConst()

return Const
