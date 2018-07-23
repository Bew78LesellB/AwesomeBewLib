local capi = {
  keygrabber = keygrabber,
}
local wibox = require("wibox")
local awful = require("awful")

local Array = require("bewlib.std.array")

------------------------------------------

local ActionMenu = { prototype = {}, }

function ActionMenu.new()
  local instance = {
    __class = ActionMenu,
    _actions = Array.new(),
    _header_text = nil,
    _footer_text = nil,
    _title = nil,
    _wibox = nil,
  }

  return setmetatable(instance, { __index = ActionMenu.prototype })
end

function ActionMenu.prototype:add_action(key, text, callback)
  local action = {
    key = key,
    text = text,
    callback = callback,
  }

  self._actions:append(action)
end

function ActionMenu.prototype:set_header(header)
  self._header_text = header
end

function ActionMenu.prototype:set_footer(footer)
  self._footer_text = footer
end

function ActionMenu.prototype:set_title(title)
  self._title = title
end

function ActionMenu.prototype:_build_menu()
  local actions_setup = Array.from_table {
    layout = wibox.layout.fixed.vertical,
  }
  self._actions.each(function(act)
    actions_setup:append({
      {
        text = act.key,
        font = "Awesome 20", -- TODO: tweak size!
        widget = wibox.widget.textbox,

        width = 10, -- TODO: tweak size!
      },
      {
        text = act.text,
        widget = wibox.widget.textbox,
      },
      layout = wibox.layout.fixed.horizontal,
    })
  end)

  local actions_list_wibox = wibox.widget(actions_setup:to_table())
  local w

  -- Add title, header & footer

  w = actions_list_wibox -- tmp
  return w
end

function Array.prototype:_make_grabber()
  return function(mods, key, event)
    mods = Array.from_table(mods)

    -- Wait for a "press" event, discard the rest
    if not event == "press" then return true end


    -- Shifted key does't close the menu
    if not mods:includes "shift" then
      capi.keygrabber.stop()
    end

    -- ...
  end
end

function ActionMenu.prototype:show(config)
  config = config or {}
  local placement = config.placement or awful.placement.centered

  if not self._wibox then
    self._wibox = self:_build_menu()
  end
  placement(self._wibox)
  self._wibox.visible = true

  -- TODO: Start keyboard grabber...
end

function ActionMenu.prototype:hide()
  if not self._wibox then
    return
  end
  self._wibox.visible = false
end

return ActionMenu
