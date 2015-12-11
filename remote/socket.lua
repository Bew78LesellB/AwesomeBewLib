local capi = {
	timer = timer,
}

local Eventemitter = require("bewlib.eventemitter")

-- TODO: debug
local debug = require("bewlib.utils").toast.debug

-- TODO: make this require safe
-- if the 'socket' module isn't not available,
-- this will throw an exception...
local LuaSocket = require("socket")
local MsgPack = require("MessagePack")

local RemoteSocket = Eventemitter{}

local serverSock = nil
local serverPort = nil
local serverClients = {}

local remotePortDir = "/tmp/awesome-remote-bewlib"

local checker = {
	interval = 0.5,
	timer = nil,
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
--
-- the args table will be unpack then send :
-- eventHandler(event.name, unpack(event.args))
local function dispatchEvent(event)
	debug("dispatchEvent")
	debug(event)
	debug("emitting event " .. event.name)
	Eventemitter.emit(event.name, event.args)
end

-- Packet format :
--
-- packet = {
-- .   format = "awesome",
-- .   type = "event" or "eval",
-- .   data = {
--         -- Put the data you want here
-- .   }
-- }
local function dispatchPacket(packet, client)
	debug("dispatchPacket")
	if not type(packet) == "table" then return end

	if not packet.format or packet.format ~= "awesome" then
		return
	end

	if packet.type == "event" then

		dispatchEvent(packet.data)

	elseif packet.type == "eval" then

		local f, err = load(packet.data)
		if f then
			local ret, err = pcall(f)
			if err then return { error = e } end
			return { ret }
		elseif e then
			return { error = e }
		end

	end
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
	if not client or serverClients[client] then
		return
	end

	table.insert(serverClients, client)
	serverClients[client] = #serverClients
end

------------------------------------------
--
------------------------------------------
local function removeClient(client)
	client:close()

	local i = serverClients[client]
	if i then
		table.remove(serverClients, i)
		serverClients[client] = nil
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

	if #serverClients == 0 then
		return
	end

	-- Do we have clients who wants to talk to us ?
	local readClients = LuaSocket.select(serverClients, nil, 0)
	for i, client in ipairs(readClients) do
		-- Read as much as possible each clients input
		while canReadClient(client) do

			client:settimeout(0)
			local packet, status = client:receive("*l") -- receive a line
			if packet then

				local ret = dispatchPacket(MsgPack.unpack(packet), client)
				if ret then
					client:settimeout(0.5) -- We give only 0.5 sec to send the msg
					local _, status = client:send(MsgPack.pack(ret))
					if status == "closed" then
						removeClient(client)
						break
					end
				end

			end

			if status == "closed" then
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
		local file = io.open(oldPortPath, "r")
		if file then
			file:close()
			os.remove(oldPortPath)
		end
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

		serverClients = {} -- forget all still connected clients
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
