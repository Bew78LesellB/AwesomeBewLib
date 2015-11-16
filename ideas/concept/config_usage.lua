local Config = require("bewlib.config")

local tag -- a tag instance
local workspace --a workspace instance

--TODO: add custom config


-- init config

workspace = Config.attachConfiguration(workspace, { parent = Config, name = "workspace" })

tag = Config.attachConfiguration(tag, { parent = workspace , name = "tag" })

-- Add config keys

-- Config.add(<key>, <defaultState>)

Config.add("clipboard.share", "unset")
-- or
Config.add("clipboard.share", Config.UNSET)


Config.add("terminal.startPath", Config.UNSET) -- or Env.HOME



-- get config

Config.get("terminal.startPath")

Config.getDefault("terminal.startPath")







-- set config

Config.set("terminal.startPath", currentPath, "tag")
-- or
Tag:setConfig("terminal.startPath", currentPath, "myTagName")
-- or
myCurrentTag:setConfig("terminal.startPath", currentPath)


-- reset config to default

Config.reset("terminal.startPath")


-- React on config changed

-- Maybe not...... (or maybe yes :p)
Config.on("change", "terminal.startPath", function()
end)

Config.on("reset", "terminal.startPath", function()
end)

Config.on("use", "terminal.startPath", function()
end)


