local aspawn = require("awful.spawn")

local WallCache = {
	prototype = {},
}

--- Scan a specific directory for wallpapers.
-- @tparam dir string The directory to scan.
-- @tparam callback function Function called after scan finished. This function
--   gets the found wallpapers as first parameter.
function WallCache.prototype:scan_dir(dir, callback)
	local cmd = "find '" .. dir .. "' -type f -name '*.png' -o -name '*.jpg'"

	local wallpapers_found = {}

	aspawn.with_line_callback(cmd, {
		stdout = function(wall_path)
			table.insert(wallpapers_found, wall_path)
		end,
		output_done = function()
			callback(wallpapers_found)
		end
	})
end

--- Scan saved directories.
-- @tparam callback function Function called after scan finished. This function
--   gets the found wallpapers as first parameter.
function WallCache.prototype:scan(callback)
	local nb_dir_scan_finished = 0

	local function on_dir_scanned(walls)
		nb_dir_scan_finished = nb_dir_scan_finished + 1

		for _, wall_path in ipairs(walls) do
			table.insert(self.wallpapers, wall_path)
		end

		if nb_dir_scan_finished == #self.wallpaper_dirs then
			-- all wallpapers directories have been scanned, trigger the callback
			callback(self.wallpapers)
		end
	end

	for _, dir in ipairs(self.wallpaper_dirs) do
		self:scan_dir(dir, on_dir_scanned)
	end
end

--- Scan saved directories, reset the wallpapers cache.
-- @tparam callback function Function called after scan finished. This function
--   gets the found wallpapers as first parameter.
function WallCache.prototype:rescan(callback)
	self.wallpapers = {}
	self:scan(callback)
end

--- Create a wallpaper cache.
function WallCache.new(config)
	config = config or {}

	local instance = {
		wallpaper_dirs = {},
		wallpapers = {},
	}

	if config.where then
		if type(config.where) == "string" then
			table.insert(instance.wallpaper_dirs, config.where)
		elseif type(config.where) == "table" then
			for _, where in ipairs(config.where) do
				table.insert(instance.wallpaper_dirs, where)
			end
		end
	end

	if config.cache_instance then
		instance.cache_instance = config.cache_instance
	end

	return setmetatable(instance, { __index = WallCache.prototype })
end

return WallCache
