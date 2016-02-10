--TODO: copy the default _ENV

local capi = {
	timer = timer,
}

local Eventemitter = require("bewlib.eventemitter")

-- TODO: make this require safe
-- if the 'socket' module isn't not available,
-- this will throw an exception...
local LuaSocket = require("socket")
local MsgPack = require("MessagePack")

local RemoteSocket = Eventemitter{}

local serverSock = nil
local serverPort = nil
local connectedClients = {}

local remotePortDir = "/tmp/awesome-remote"

local checker = {
	interval = 0.5,
	timer = nil,
}

local ClientState = {
	-- length
	WAITING_LENGTH = 0,
	RECEIVING_LENGTH = 1,

	-- packet
	WAITING_PACKET = 2,
	RECEIVING_PACKET = 3,

	CLOSED = 42,
}


-- Event format :
--
-- event = {
-- .   name = "network::wifi" or "sound::output::headphone" or ...,
-- .   args = {
-- .       key1 = "value1",
-- .       key2 = "value2",
-- .   }
-- }
local function dispatchEvent(event)
	Eventemitter.emit(event.name, event.args)
end

-- Packet format :
--
-- packet = {
-- .   format = "awesome",
-- .   type = "event"
-- .   data = ...     -- Put the data you want here
-- }
local function dispatchPacket(packet, client)
	if not type(packet) == "table" then return end

	if not packet.format or packet.format ~= "awesome" then
		return
	end

	if packet.type == "event" then

		dispatchEvent(packet.data)

	end
	-- We do not handle other packet type currently
	-- (And don't want to handle 'eval' security breaches)
end

------------------------------------------
--
------------------------------------------
local function canAcceptClient(server)
	local readSocks = LuaSocket.select({serverSock}, nil, 0)
	if readSocks[server] then
		return true
	end
	return false
end

------------------------------------------
--
------------------------------------------
local function canReadClient(client)
	local readClient = LuaSocket.select({client}, nil, 0)
	if readClient[client] then
		return true
	end
	return false
end

------------------------------------------
--
------------------------------------------
local function addClient(client)
	if not client or connectedClients[client] then
		return
	end

	table.insert(connectedClients, client)
	connectedClients[client] = {
		position = #connectedClients,
		state = ClientState.WAITING_LENGTH,
	}
end

------------------------------------------
--
------------------------------------------
local function removeClient(client)
	client:close()

	local clientInfo = connectedClients[client]
	if clientInfo then
		table.remove(connectedClients, clientInfo.position)
		connectedClients[client] = nil
	end
end

------------------------------------------
--
------------------------------------------
local function clientReceive(client, info)
	if not client or not info then return end
	client:settimeout(0)

	if info.state == ClientState.WAITING_LENGTH or info.state == ClientState.RECEIVING_LENGTH then
		-- Receive Length

		local packet, status, partialPacket = client:receive("*l") -- receive the length
		if status == "timeout" and partialPacket then

			info.partial = (info.partial or "") .. partialPacket
			info.state = ClientState.RECEIVING_LENGTH

		elseif packet then

			local length = tonumber(packet)
			if not length then
				-- There is an error here, how do we handle it ? ignore ?
				info.state = ClientState.WAITING_LENGTH
				info.partial = nil
				return
			end
			info.packetLength = length
			info.state = ClientState.WAITING_PACKET
			info.partial = nil

		else
			info.state = ClientState.CLOSED
		end

	elseif info.state == ClientState.WAITING_PACKET or info.state == ClientState.RECEIVING_PACKET then
		-- Receive Packet

		local packet, status, partialPacket = client:receive(info.packetLength)

		if status == "timeout" and partialPacket then

			info.partial = (info.partial or "") .. partialPacket
			info.state = ClientState.RECEIVING_PACKET

		elseif packet then

			if info.partial then
				packet = info.partial .. packet
				info.partial = nil
			end
			dispatchPacket(MsgPack.unpack(packet))

			info.state = ClientState.WAITING_LENGTH

		else
			info.state = ClientState.CLOSED
		end
	end
end

------------------------------------------
--
------------------------------------------
local function checkSocketCallback()

	-- Do we have a new client who wants to connect ?
	if canAcceptClient(serverSock) then
		serverSock:settimeout(0) -- non blocking accept
		local newClient = serverSock:accept()
		if newClient then
			-- We have a new client
			addClient(newClient)
		end
	end

	if #connectedClients == 0 then
		return
	end

	-- Do we have clients who wants to talk to us ?
	local readClients = LuaSocket.select(connectedClients, nil, 0)
	for i, client in ipairs(readClients) do
		-- Read as much as possible each clients input
		while canReadClient(client) do

			local clientInfo = connectedClients[client]
			clientReceive(client, clientInfo)

			if clientInfo.state == ClientState.CLOSED then
				removeClient(client)
				break
			end

		end
	end

end


------------------------------------------
--
------------------------------------------
local function setServerPort(port)

	local function getPortPath(p)
		return remotePortDir .. "/" .. tostring(p)
	end

	local oldPort = serverPort
	serverPort = port

	if oldPort then
		-- remove old server port
		local oldPortPath = getPortPath(oldPort)
		os.remove(oldPortPath)
	end

	-- reset to nil
	if not port then
		return true
	end

	-- save server port
	if not os.execute("mkdir -p " .. remotePortDir) then
		-- Cannot create dir for server port
		return false
	end

	local file = io.open(getPortPath(port), "w")
	-- TODO: put/get more infos to/from /tmp/awesome-remote-bewlib/* files
	file:write(tostring(port))
	file:close()

	return true
end


------------------------------------------
--
------------------------------------------
local function initSocket()

	serverSock = LuaSocket.tcp()

	local success, err = serverSock:bind("localhost", 0) -- select a random port
	if err then
		return nil, err
	end

	local success, err = serverSock:listen(256)
	if err then
		return nil, err
	end

	local _, port = serverSock:getsockname()
	setServerPort(port)

	return true
end

------------------------------------------
--
------------------------------------------
local function closeSocket()
	if serverSock then
		serverSock:close()
		serverSock = nil

		connectedClients = {} -- forget all still connected clients
	end
	setServerPort(nil)
end



------------------------------------------
--
------------------------------------------
local function isRunning()
	if checker.timer and checker.timer.started then
		return true
	end
	return false
end


------------------------------------------
--
------------------------------------------
function RemoteSocket.enable()
	if not isRunning() then
		checker.timer = capi.timer({ timeout = checker.interval })
		checker.timer:connect_signal("timeout", checkSocketCallback)
		checker.timer:start()

		local success, err = initSocket()
		if err then
			checker.timer:stop()
			checker.timer = nil
			return false
		end

	end
	return true
end

------------------------------------------
--
------------------------------------------
function RemoteSocket.disable()
	if isRunning() then
		checker.timer:stop()
		checker.timer = nil
		closeSocket()
	end
end

------------------------------------------
--
------------------------------------------
function RemoteSocket.isEnable()
	return isRunning()
end

------------------------------------------
--
------------------------------------------
function RemoteSocket.getPort()
	return serverPort
end


awesome.connect_signal("exit", function(restart)
	RemoteSocket.disable()
end)


return RemoteSocket
