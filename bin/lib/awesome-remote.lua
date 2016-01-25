-- Module environment
local AwesomeRemote = {}

-- Grab environment
local capi = {
	print = print,
}

-- Grab dependancies
local Socket = require("socket")
local MsgPack = require("MessagePack")

-- Private variables

local config = {
	verbose = false,
}

local host = "localhost"
local remotePortDir = "/tmp/awesome-remote"

local servers = {}

-- Private functions

local function print(...)
	if not config.verbose then
		return false
	end
	return capi.print(...)
end

local function extractServerInfo(fileName)
	if not fileName then return end

	local file = io.open(fileName, "r")
	if not file then return end

	local infos = {
		port = file,
	}
	-- no more info to extract from file right now...
	file:close()

	return infos
end

local function lsFiles(directory)
	local files = {}
	for filename in io.popen('ls "' .. directory .. '"'):lines() do
		table.insert(files, filename)
	end
	return files
end

local function findRunningServers()
	local files = lsFiles(remotePortDir)

	print("finding running servers")

	-- empty the list of servers
	servers = {}

	for _, file in ipairs(files) do
		print("found " .. file)
		table.insert(servers, {
			port = file,
			info = extractServerInfo(file),
		})
	end
end

local function sendToServer(serverInfo, data)
	local tcp = Socket.tcp()
	if not tcp then return false end

	local success, status = tcp:connect(host, serverInfo.port)
	if not success then return false end

	local packet = MsgPack.pack(data)
	local sent, status = tcp:send(string.len(packet) .. "\n")
	local sent, status = tcp:send(packet)
	-- TODO: do something with sent & status
end

local function sendToAllServers(data)
	for _, serverInfo in ipairs(servers) do
		if not sendToServer(serverInfo, data) then
			return false
		end
		return true
	end
end

-- Public functions

function AwesomeRemote.init(conf)
	local conf = conf or {}
	config.verbose = conf.verbose or false
	findRunningServers()
end

function AwesomeRemote.sendEvent(eventName, eventArgs)
	local data = {
		format = "awesome",
		type = "event",
		data = {
			name = eventName,
			args = eventArgs,
		}
	}
	return sendToAllServers(data)
end

return AwesomeRemote
