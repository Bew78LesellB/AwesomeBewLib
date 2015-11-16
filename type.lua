-- Grab environement
local native = {
	type = type,
}

-- Public Module environement
local Type = {}

-- Private environement
local typeList = {}

function getTypeOfAnything(object)
	local nativeType = native.type(object)
	if nativeType ~= "table" then
		return nativeType
	end
	if not object._type then
		return "table"
	end
	return object._type
end


function Type.registerType(key)
	typeList[key] = key
	return key
end

Type.mt = {
	__index = function(self, key)
		return typeList[key]
	end,

	__newindex = function(self, key, value)
		-- disable future modifications
		return nil
	end,

	__call = function(self, object)
		return getTypeOfAnything(object)
	end,
}

return setmetatable(Type, Type.mt)
