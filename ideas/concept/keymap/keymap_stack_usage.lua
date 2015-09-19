

local Keymap = require("bewlib.keymap")

-- we assume some already built keymaps

local myStack = Keymap.stack.new("global-navigation")

myStack:push("tag.navigation", { priority = "low" }) --TODO: Const.priority.LOW
myStack:push("client.navigation", { priority = "low" })
myStack:push("layout.changer", { priority = "low" })




local Workspace = require("bewlib.workspace")

-- Adding root stack keys
Keymap.root:addKey("global")
Keymap.root:addKey("screen")
Keymap.root:addKey("workspace")
Keymap.root:addKey("tag")

--TODO: manage client stack dynamically if possible
Keymap.root:addKey("client", function(stackToApply)
	--FIXME: where do I get the 'c' client
	c:keys(stackToApply:apply({ filter = "keys" }))
	c:buttons(stackToApply:apply({ filter = "buttons" }))
end)





-- TODO: leave ability to add some other custom stack ?
Keymap.root:addKey("custom")
-- or: how to setup little custom keymap

Keymap.root:addStack("global", myStack)
Keymap.root:addStack("global", myStack) -- will do nothing

Keymap.root:removeStack("global", myStack)


-- usefull example
Workspace.on("change", function()
	local currentWorkspace = Workspace.get("current")

	-- set the workspace stack to the current workspace's stack
	Keymap.root:changeStack("workspace", currentWorkspace._stack)
	Keymap.root:apply()

	-- do the same :
	Keymap.root:changeStack("workspace", currentWorkspace._stack):apply()
end)


--TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
-- what is a stack ?
--
-- a stack is a group of keymaps.
-- a stack is used internally by workspace/tag/client to manage which keymaps are applied
--
--

-- Keymap.root					is an ordered list of stack :

-- example of Keymap.root dump
Keymap.root = {
	{
		keyNumber = 1,
		key = "global",
		stack = globalStack
	},
	{
		keyNumber = 2,
		key = "screen",
		stack = nil      -- currently no custom stack for screen
	},
	{
		keyNumber = 3,
		key = "workspace",
		stack = workspaceStack
	},
	{
		keyNumber = 4,
		key = "tag",
		stack = workspaceStack
	},
	--TODO: find a way to manage client stack dynamically if possible
	--{
	--	keyNumber = 5,
	--	key = "client",
	--	stack = workspaceStack,
	--	applyFunction = aFunction
	--},
}






-- Keymap.root:get("global")	is a stack
--
-- This change the stack pointed by "global" to newStack
Keymap.root:change("global", newStack)


