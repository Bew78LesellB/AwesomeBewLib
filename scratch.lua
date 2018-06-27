-------------------------------------------------------------------
-- Drop-down applications manager for the awesome window manager
-------------------------------------------------------------------
-- Inspired by https://github.com/proteansec/awesome-scratch
-------------------------------------------------------------------
--
-- local Scratch = require("bewlib.scratch")
--
-- Scratch.toggle()
-- Scratch.toggle(options)
--
-- Scratch.make_scratch(some_client)
-- Scratch.disable_current()
-- Scratch.swap_with(other_client)
--
-- Option table can have:
--   vert   - Vertical; "bottom", "center" or "top" (default)
--   horiz  - Horizontal; "left", "right" or "center" (default)
--   width  - Width in absolute pixels, or width percentage
--            when <= 1 (1 (100% of the screen) by default)
--   height - Height in absolute pixels, or height percentage
--            when <= 1 (0.25 (25% of the screen) by default)
--   sticky - Visible on all tags, false by default
--   screen - Screen (optional), mouse.screen by default
-------------------------------------------------------------------

-- TODO: rework this API
-- For example nasty things can happen (e.g: lost client) if you call
-- Scratch.disable_current if there is no current scratch client, same if you
-- call Scratch.make_scratch if there is already a scratch client.

-- Grab environment
local pairs = pairs
local awful = require("awful")

local capi = {
    mouse = mouse,
    client = client,
    screen = screen
}
local attach_signal = capi.client.connect_signal
local detach_signal = capi.client.disconnect_signal

local fallback_options = {
    vert = "top",
    horiz = "center",
    width = 1,
    height = 0.25,
    sticky = false,
}

-- Scratch: drop-down applications manager for the awesome window manager
local Scratch = {
    prog = "xterm",
    default_options = {table.unpack(fallback_options)}, -- quick copy of fallback_options
}


-- Storage for drop clients: screen => {client, options}
local drop_clients = {}

--- Add unmanage signal for scratchdrop programs
attach_signal("unmanage", function (c)
    for scr, scratch_info in pairs(drop_clients) do
        if scratch_info.client == c then
            drop_clients[scr] = nil
        end
    end
end)

local function get_options(opt)
    local function get(field)
        if opt[field] ~= nil then
            return opt[field]
        end
        if Scratch.default_options[field] ~= nil then
            return Scratch.default_options[field]
        end
        return fallback_options[field]
    end

    opt = opt or {}
    opt.vert   = get("vert")
    opt.horiz  = get("horiz")
    opt.width  = get("width")
    opt.height = get("height")
    opt.sticky = get("sticky")
    opt.screen = opt.screen or capi.mouse.screen
    return opt
end

local function setup_client(c, opt)
    -- Scratchdrop clients are floaters
    c.floating = true

    -- Client geometry and placement
    local warea = capi.screen[opt.screen].workarea

    if opt.width  <= 1 then opt.width  = warea.width  * opt.width  end
    if opt.height <= 1 then opt.height = warea.height * opt.height end

    local x, y
    if opt.horiz == "left"  then
        x = warea.x
    elseif opt.horiz == "right" then
        x = warea.width - opt.width
    else
        x = warea.x + (warea.width - opt.width) / 2
    end
    if opt.vert == "bottom" then
        y = warea.height + warea.y - opt.height
    elseif opt.vert == "center" then
        y = warea.y + (warea.height - opt.height) / 2
    else
        y = warea.y - warea.y
    end

    -- Client properties
    c:geometry({ x = x, y = y, width = opt.width, height = opt.height })
    c.ontop = true
    c.above = true
    c.skip_taskbar = true
    if opt.sticky then
        c.sticky = true
    end
end

local function enable_client(c, options)
    drop_clients[options.screen] = {
        client = c,
        options = options,
    }

    setup_client(c, options)

    c:raise()
    capi.client.focus = c
end

local function disable_client(screen)
    local scratch_info = drop_clients[screen]
    local c = scratch_info.client

    drop_clients[screen] = nil

    c.floating = false -- FIXME: this should depend on the target tag

    c.ontop = false
    c.above = false
    c.sticky = false
    c.hidden = false -- TODO: investigate on what this does exactly
    if c:isvisible() == false then
        c:move_to_tag(capi.mouse.screen.selected_tag)
    end
end

--- Create a new window for the drop-down application when it doesn't
-- exist, or toggle between hidden and visible states when it exists.
function Scratch.toggle(opt)
    local o = get_options(opt)

    -- Get a running client
    local scratch_info = drop_clients[o.screen]

    if not scratch_info then
        -- Spawn a client & manage it
        local function first_manager(new_c)
            detach_signal("manage", first_manager)

            enable_client(new_c, o)
        end
        attach_signal("manage", first_manager)
        awful.spawn(Scratch.prog, false)
    else
        local c = scratch_info.client
        -- Switch the client to the current workspace
        if c:isvisible() == false then
            c.hidden = true
            c:move_to_tag(capi.mouse.screen.selected_tag)
        end

        -- Focus and raise if hidden
        if c.hidden then
            -- Make sure it is centered
            if o.vert  == "center" then awful.placement.center_vertical(c)   end
            if o.horiz == "center" then awful.placement.center_horizontal(c) end
            c.hidden = false
            c:raise()
            capi.client.focus = c
        else -- Hide and detach tags if not
            c.hidden = true
            local ctags = c:tags()
            for i, _ in pairs(ctags) do
                ctags[i] = nil
            end
            c:tags(ctags)
        end
    end
end

function Scratch.make_scratch(target_client, opt)
    local o = get_options(opt)

    enable_client(target_client, o)
end

function Scratch.disable_current()
    disable_client(capi.mouse.screen)
end

function Scratch.get_client(screen)
    screen = screen or capi.mouse.screen
    local scratch_info = drop_clients[screen]
    return scratch_info and scratch_info.client
end

--- Swap current scratch client with given client
function Scratch.swap_with(target_client, scr)
    local screen = scr or capi.mouse.screen

    local old_scratch_info = drop_clients[screen]
    if old_scratch_info then
        -- disable current scratch client
        disable_client(screen)

        -- activate scratch for current selected client, with options
        -- of previous scratch client
        enable_client(target_client, old_scratch_info.options)
        return true
    else
        return false
    end
end

return Scratch
