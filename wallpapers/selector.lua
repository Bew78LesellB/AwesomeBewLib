local History = require("bewlib.history")
local WallCache = require("bewlib.wallpapers.cache")

local WallSelector = {
	prototype = {},
}

--- Gives a new wallpaper path on each call.
-- @treturn string A wallpaper path.
function WallSelector.prototype:generate_next()
	local selectable_walls = self.cache.wallpapers

	local new_idx = math.random(1, #self.cache.wallpapers + 1)
	return selectable_walls[new_idx]
end

--- Get the previous wallpaper.
-- @treturn string A wallpaper path.
function WallSelector.prototype:previous()
	if self.history_cursor < self.history:get_nb_entries() then
		self.history_cursor = self.history_cursor + 1
	end

	self:select()
end

--- Get a new wallpaper path or gives the next one if the history_cursor is not at the end.
-- @treturn string A wallpaper path.
function WallSelector.prototype:next()
	if self.history_cursor > 1 then
		self.history_cursor = self.history_cursor - 1
		self:select()
		return
	end

	local new_wall = self:generate_next()
	if not new_wall then
		-- TODO: trigger an error ? This could happen when the wallpapaer cache
		-- hasn't finished scanning, so the cache's wallpapers list is empty.
		--
		-- or if the selector has no explicitly spcified cache (a new empty one
		-- has been created)
		return
	end

	self.history:add_entry(new_wall)
	self:select()
end

function WallSelector.prototype:select(wall_path)
	if not wall_path then
		wall_path = self.history:get_at(self.history_cursor)
	end

	-- TODO: emit event "select"
	if self.on_select then
		self.on_select(wall_path)
	end
end

--- Create a wallpaper selector
function WallSelector.new(config)
	config = config or {}

	local instance = {
		history = History.new({ limit = 10, }),
		history_cursor = 1,
		cache = config.cache or WallCache.new(),
	}

	if config.on_select and type(config.on_select) == "function" then
		instance.on_select = config.on_select -- TODO: use event "select"
	end

	return setmetatable(instance, { __index = WallSelector.prototype })
end

return WallSelector
