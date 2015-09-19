local Tag = require("bewlib.tag")

Tag.setDefaultProperties({
	layout = awful.layout.suit.tile,
	name = function() return "| tag " .. self.id .. " |" end,
	keymap = Keymap("my-key-map-for-tag"),
	workspace = Workspace.find("my-custom-default"),
})


--Tag.new ?
Tag.batchAdd({
	"Web", "Web", "Web", "				  ",
	"Divers", "Divers", "				  ",
	"Code", "CODE", "Code", "				  ",
	"Misc", "Misc",
	{ id = "my-tag", name = "My SUper Tag" },
})


Tag.rename("new name for current tag")
Tag.rename({ id = "my-tag", name = "New Name For my-tag Tag" })













-- TAG INIT IN DEFAULT AWESOME'S RC.LUA


-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
-- Each screen has its own tag table.
-- tags[s] = awful.tag({ "Web", "Divers", 3, 4, 5, "Code", "Code", 8, "Misc" }, s, layouts[1])
tags[1] = awful.tag({
	"Web", "Web", "Web", "				  ",
	"Divers", "Divers", "				  ",
	"Code", "CODE", "Code", "				  ",
	"Misc", "Misc"
}, s, global.layouts[1])
-- }}}








