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


Config.add("terminal.beginPath", Config.UNSET)


-- get config

Config.get("terminal.beginPath")

Config.getDefault("terminal.beginPath")







-- set config

Config.set("terminal.beginPath", currentPath, "tag")
-- or
Tag:setConfig("terminal.beginPath", currentPath, "myTagName")
-- or
myCurrentTag:setConfig("terminal.beginPath", currentPath)


-- reset config to default

Config.reset("terminal.beginPath")


-- React on config changed

-- Maybe not......
Config.on("change", "terminal.beginPath", function()
end)

Config.on("reset", "terminal.beginPath", function()
end)

Config.on("use", "terminal.beginPath", function()
end)


