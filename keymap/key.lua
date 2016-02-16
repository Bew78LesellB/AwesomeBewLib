-- Grab dependencies
local Type = require("bewlib.type")

-- Module Public environement
local Key = {}
Type.registerType("Key")

Key.prototype = {
	_type = Type.Key,
}

Key.prototype.mt = {
	__index = function(self, key)
		return Key.prototype[key]
	end,
}

-- Exemple key
--
-- key = {
--   key = "Left",
--   mod = {
--     "Mod4" = true,
--     "Control" = true,
--   }
-- }

-- Private functions

-- nop





-- Public common prototype functions

--- Try to match the key instance with a single other instance of Key
-- @param singleKey (Key) : The key to match with the instance
-- @return true if match, or false
function Key.prototype:matchSingleKey(singleKey)
	if Type(singleKey) ~= Type.Key then return false end

	-- Compare key
	if self.key == "any" or singleKey.key == "any" then
		return true
	end

	if self.key ~= singleKey.key then
		return false
	end

	-- Compare modifiers
	for modifier in pairs(singleKey.mod) do
		if not self.mod[modifier] then
			return false
		end
	end
	-- Check they have the same number of modifiers
	return #self.mod == #singleKey.mod
end


--- Try to match the key instance with another key, or a table of keys
-- @param keyOrKeys (Key or { Key, Key, ...}) : The key(s) to match with the instance
-- @return the matched key or false
function Key.prototype:match(keyOrKeys)
	local t = Type(keyOrKeys)
	if t == Type.Key then
		return self:matchSingleKey(keyOrKeys)
	end
	if t == "table" then
		for _, key in ipairs(keyOrKeys) do
			if self:matchSingleKey(key) then
				return key
			end
		end
	end
	return false
end



-- Public module functions

--- Try to match a Key with another Key, or a set of Keys
function Key.match(key, keyOrKeys)
	if Type(key) ~= Type.Key then return false end

	return key:match(keyOrKeys)
end


--- Create a new Key instance and return it
-- @param mod ({string, ...}) The key modifiers
-- @param keyOrKeys (string or {string, ...}) The string representing the key
--   ex: "m" "e" "period" "Super_L" (can be found with program 'xev'
function Key.new(mod, keyOrKeys)
	local t = Type(keyOrKeys)

	if t == "table" then
		local lastKey
		for i, singleKey in ipairs(keyOrKeys) do
			lastKey = Key.new(mod, singleKey)
		end
		return lastKey
	end

	if not mod then
		mod = {}
	end

	local newkey = Eventemitter({
		mod = mod,
		key = keyOrKeys,
	})

	return setmetatable(newkey, Key.prototype.mt)
end


return Key
