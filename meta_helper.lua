local MetaHelper = {}

function MetaHelper.new_metatable(config)
	config = config or {}

	local metatable = {}

	if config.index or config.indexes then
		metatable.__index = function(_, key)
			if config.index then
				return config.index[key]
			end

			if config.indexes then
				for _, index in ipairs(config.indexes) do
					local match = index[key]
					if match then
						return match
					end
				end
			end

			return nil
		end
	end

	return metatable
end

return MetaHelper
