local History = {
	prototype = {},
}

function History.prototype:add_entry(entry)
	if not entry then return end

	if #self.entries == self.limit then
		table.remove(self.entries) -- remove oldest entry
	end
	table.insert(self.entries, 1, entry)
end

function History.prototype:get_nb_entries()
	return #self.entries
end

function History.prototype:get_at(nth)
	return self.entries[nth]
end

function History.prototype:last_entry()
	return self.entries[1]
end

function History.new(config)
	config = config or {}

	local instance = {
		entries = config.entries or {},
		limit = config.limit or 10,
	}

	return setmetatable(instance, { __index = History.prototype })
end

return History
