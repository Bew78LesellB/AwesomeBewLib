-- Module dependencies
local awful = require("awful")
local utils = require("bewlib.utils")
local Eventemitter = require("bewlib.eventemitter")

local debug = require("gears.debug").dump_return

-- Module environement
local Workspace = {
	mt = {},
	prototype = {
		mt = {},
	},
	_list = {},
}
Workspace = Eventemitter(Workspace)

local prototype = Eventemitter({})


function Workspace.mt:__call(...)
	--Workspace.new(...)
end

Workspace = setmetatable(Workspace, Workspace.mt)

--example/ideas
local ws = Workspace.add({ -- add ? new ?
	name = "Default",
	screen = 1,
	position = "left", --( possible : "right" "begin" "end" "2" "42"(end) )
	relative = "end", -- position relative par rapport au dernier (la position sera donc : avant dernier)
})
--end example/ideas

return Workspace
