
-- Grab dependencies
local spawn_with_shell = require("awful.util").spawn_with_shell
--local Object = require("object")
local Eventemitter = require("bewlib.eventemitter")

-- Module environement
local Autorun = {} -- must be Object{} ?


-- Private attributes

local listCmdRunOnce = {}
local listCmdRun = {}



local function runOnce(cmd)
	if not cmd then return end

	findme = cmd
	firstspace = cmd:find(" ")
	if firstspace then
		findme = cmd:sub(0, firstspace - 1)
	end
	awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

local function run(cmd)
	if not cmd then return end

	awful.util.spawn_with_shell(cmd)
end




function Autorun.add(cmd)
	if not cmd then return end

	if listCmdRun[cmd] then
		return
	end
	table.insert(listCmdRun, cmd)
	listCmdRun[cmd] = #listCmdRun
end

function Autorun.addOnce()
	if not cmd then return end

	if listCmdRunOnce[cmd] then
		return
	end
	table.insert(listCmdRunOnce, cmd)
	listCmdRunOnce[cmd] = #listCmdRunOnce
end


Eventemitter.on("config%loaded", function()
	for _, cmd in ipairs(listCmdRunOnce) do
		runOnce(cmd)
	end
	for _, cmd in ipairs(listCmdRun) do
		run(cmd)
	end
end)


return Autorun
