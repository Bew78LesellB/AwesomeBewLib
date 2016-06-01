-- Module dependencies
local awful = require("awful")
local utils = require("bewlib.utils")
local Eventemitter = require("bewlib.eventemitter")

local debug = require("gears.debug").dump_return

-- Module environement
local Workspace = Eventemitter({})

Workspace.prototype = Eventemitter({})


return Workspace
