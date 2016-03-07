--local Object = require("object")
local Eventemitter = require("bewlib.eventemitter")

-- Module environement
local Themer = {} -- must be Object{} ?


-- Private attributes


-- Private functions


-- Public methods

function Themer.new()
end

-- etc...

-- Event configuration

Eventemitter.on("config::load", function()
	-- update theme ? (maybe useless..)
	-- TODO: TODO TODO
end)


return Themer
