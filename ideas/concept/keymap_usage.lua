-- Keymap Usage:


--[[											]]--
--[[			idea 1 - simple idea			]]--
--[[											]]--


local km = require("bewlib.keymap")


local first = km.new("Applications")
first:addBind({ }, "c", {
	description = "Launch Chrome",
	cmd = "chromium"
})

first:addBind({ }, "f", {
	description = "Fake",
	cmd = function (keymap)
		utils.toast("Current Keymap: " .. keymap)
		awful.utils.spawn("echo bla")
	end
})

first:setExitBind({ }, "Escape", {
	description = "Exit this keymap",
	cmd = function (keymap)
		utils.toast("Exiting from keymap : " .. keymap)
	end
})







--[[											]]--
--[[			idea 1.5 - mix idea 1 + 2		]]--
--[[											]]--


local km = require("bewlib.keymap")


-- local first = km.new("Tag Control", { parent = km.safe.tag })

local first = km.new("Applications")

first:setModifiers({
	M = modkey,
	C = "Control"
	-- "S" = "Shift",
	-- "A" = "Mod1"
})

first:addBind({
	ctrl = { mod = "M", key = "c" },
	comment = "Launch Chrome",
	hashtags = "#web #launch",
	cmd = "chromium"
})

first:setExitBind({
	ctrl = { key = "Escape" },
	comment = "Exit this keymap",
	cmd = function (keymap)
		utils.toast("Exiting from keymap : " .. keymap)
	end
})









--[[											]]--
--[[			idea 2 - more options			]]--
--[[											]]--


inputControl = Event:newList({
	M = modkey,
	C = "Control",
	S = "Shift",
	A = "Mod1" --Alt
},
{
	----##> This will create 2 EventBlock, for the 2 keybinds (and place them in global.EventModule)
	-- begin block
	{
		ctrl = {
			{ mod = "M", key = "Left" },		-- modkey & Left KEY
			{ button = "ScrollUp" }				-- ScrollUp MOUSE BUTTON)
		},
		context = root,
		comment = "View previous tag",
		hashtags = "#tag #move",
		callback = awful.tag.viewprev
	},
	-- end block



	{
		ctrl = { mod = "MS", key = "Left" },	  -- modkey + Shift & Left KEY
		context = root,
		comment = "Move focused client to previous tag",
		hashtags = "#client #focus #move",
		callback = function ()
			if not client.focus then
				return
			end
			local c = client.focus
			local idx = awful.tag.getidx()
			local new_idx = (idx == 1 and #tags[c.screen] or idx - 1)
			awful.client.movetotag(tags[c.screen][new_idx])
			awful.tag.viewonly(tags[c.screen][new_idx])
			client.focus = c
		end
	},

	---------------
	---- IDEAS ----
	---------------

	--{
		--ctrl = { mod = "M", key = "" },
		--context = ,
		--comment = "",
		--hashtags = "#",
		--callback = nil --TODO
	--},

	{
		ctrl = { mod = "M", key = "c" },
		context = client,
		comment = "Open client configuration",
		hashtags = "#client #config",
		callback = nil --TODO
	},

	{
		ctrl = { mod = "M", key = "PageUp" },
		context = root,
		comment = "Go to top most workspace",
		hashtags = "#workspace #move",
		callback = nil --TODO
	},

	{
		ctrl = { mod = "M", key = "Up" },
		-- context = root,							-- context not defined, take the last context (root)
		comment = "Go to previous workspace",
		hashtags = "#workspace #move",
		callback = nil --TODO
	},

	-----------------------------------
	----- Complete key config ---------
	-----------------------------------
	{
		ctrl = {
			{ mod = "M", key = "w" },			-- modkey & W
			{ mod = "CM", key = "h" }, 			-- modkey + ctrl & H
			{ mod = "AS", button = "Middle" },	-- alt + shift & Mouse Middle
			{ key = "F4" }						-- only F4
		},
		context = client,							-- default context
		comment = "Mon super <em>Commentaire</em>",	-- short comment of what the keybind is doing
		hashtags = "#client #multi-bind",			-- Used to filter commands when searching for one
		callback = function (c, my_data, event) print(my_data.bla) print(event:tostring()) end,
		raw_data = { bla = "bla from raw_data" },	-- Optionnal raw_data to send to the function
		enabled = true								-- whatever the keybinding(s) is enabled
	}
})

-- apply with filters
inputControl:apply({ ctrl = "key"})
inputControl:apply({
	ctrl = { "key", "mouse" }
})
inputControl:apply({ hashtag = "#launch" })

-- generate the table with filter
root.buttons(inputControl:get_table({
	context = root,
	ctrl = "mouse",
	hashtag = "#move"
}))
