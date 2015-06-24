-- Module dependencies
local awful = require("awful")

local toast = require("bewlib.utils").toast

-- Module environement
local keymap = {}

--[[ Apply flags ]]--
keymap.SET = 0x1
keymap.MERGE = 0x2
keymap.KEYGRABBER = 0x3

function keymap.new (keymapName, options)
	self.name = keymapName
	self.parent = options.parent or nil
	self.binds = {}
	self.modifiers = {}
end

--[[ call: 
keymap:setModifiers( {
	"M" = modkey,
	"S" = "Shift"
})
--]]
function keymap:setModifiers (modifiersTable)
	if type(modifiersTable) == "table" then
		self.modifiers = modifiersTable
		return self -- to chain commands (or return modifiersTable)
	end
	return nil
end

function keymap:addBind (bindOpt)
	if type(bindOpt) ~= "table" then
		return nil
	end
	local bind = {}
	bind.ctrl = type(bindOpt.ctrl) == "table" and bindOpt.ctrl or nil
	if bind.ctrl == nil then
		return nil
	end

	bind.comment = type(bindOpt.comment) == "string" and bindOpt.comment or ""
	bind.hashtags = type(bindOpt.hashtags) == "string" and bindOpt.hashtags or ""
	bind.cmd = type(bindOpt.cmd) == "string" and bindOpt.cmd or nil
	bind.callback = type(bindOpt.cmd) == "function" and bindOpt.cmd or nil

	table.insert(self.binds, bind)
	return bind
end




function keymap:apply(flag)
	if flag == keymap.SET then -- replace the current keymap
	else if flag == keymap.MERGE then -- add to the current keymap
	else if flag == keymap.KEYGRABBER then -- replace like in keygrabber (for a moment)
	end
end


return keymap
