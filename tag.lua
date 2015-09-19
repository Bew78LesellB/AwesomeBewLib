-- Module dependencies
local awful = require("awful")
local utils = require("bewlib.utils")
local Eventemitter = require("bewlib.eventemitter")

local debug = require("gears.debug").dump_return

-- Module environement
local Tag = {
	mt = {},
	prototype = {
		mt = {},
	},
	_list = {},
}
Tag = Eventemitter(Tag)

local prototype = Eventemitter({})


function Tag.mt:__call(...)
	--Tag.new(...)
end

Tag = setmetatable(Tag, Tag.mt)

--[[example/ideas
local ws = Tag.add({ -- add ? new ?
	name = "Default",
	screen = 1,
	position = "left", --( possible : "right" "begin" "end" "2" "42"(end) )
	relative = "end", -- position relative par rapport au dernier (la position sera donc : avant dernier)
})
--end example/ideas ]]

return Tag

