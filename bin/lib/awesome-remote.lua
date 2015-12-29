-- Module environment
local AwesomeRemote = {}

-- Grab dependancies
local Socket = require("socket")
local MsgPack = require("MessagePack")

-- Private variables

local host = "localhost"
local remotePortDir = "/tmp/awesome-remote"

local servers = {}

-- Private functions

local function extractServerInfo(fileName)
	if not fileName then return end

	local file = io.open(fileName, "r")
	if not file then return end

	local infos = {}
	-- no infos to extract right now...
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

	-- empty the list of servers
	servers = {}

	for _, port in ipairs(files) do
		table.insert(servers, {
			port = port,
			info = extractServerInfo(port),
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
end

local function sendToAllServers(data)
	for _, serverInfo in ipairs(servers) do
		sendToServer(serverInfo, data)
	end
end

-- Public functions

function AwesomeRemote.init()

end

function AwesomeRemote.sendEvent(name, data)
end

return AwesomeRemote
