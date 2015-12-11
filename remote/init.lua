local Remote = {}

local debug = require("bewlib.utils").toast.debug

debug("in require Remote")

function Remote.init(...)
	local modes = {...}

	debug("init with modes")
	debug(modes)

	for _, mode in ipairs(modes) do
		if mode == "socket" then

			-- Launch Remote system by sockets
			Remote.Socket = require("bewlib.remote.socket")
			Remote.Socket.enable()

		elseif mode == "dbus" then
			-- Launch Remote system by dbus (like awful.remote)
		end
	end
end


return Remote
