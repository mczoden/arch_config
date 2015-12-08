local setmetatable = setmetatable
local string = {
  match = string.match
}
local table = {
  insert = table.insert
}
local io = {
  popen = io.popen
}
local Interface = require('interface')
local sugar = require("sugar")
local capi = {timer = timer}
local textbox = require("wibox.widget.textbox")
local naughty = require("naughty")
local capi = {timer = timer}

-- state_info_tbl
--
-- infomation about text color, notify method
local state_info_tbl = {
  hw_down = {
    color = "#ff6565", -- red
    notify = "No Physical connection",
    timeout = 0
  },
  has_route = {
    color = "#93d44f", -- green
    notify = "Obtains IP address",
    timeout = 3
  },
  no_route = {
    color = "#eab93d", -- yellow
    notify = "No IP address",
    timeout = 0
  }
}

-- InterfaceWidgetEntry
--
-- one single physical device information and its awesome widget
local InterfaceWidgetEntry = {mt = {}}

function InterfaceWidgetEntry:new (index, name, hw_state)
  local o = {}
  o.interface = Interface(index, name, hw_state)
  o.widget = textbox()

  return o
end

function InterfaceWidgetEntry.mt:__call (...)
  return InterfaceWidgetEntry:new(...)
end

setmetatable(InterfaceWidgetEntry, InterfaceWidgetEntry.mt)

-- Widgets
--
-- all instance of InterfaceWidgetEntry
local Widgets = {i_w_list = {}}

function Widgets:get_entry_by_name (name)
  for _, entry in pairs(self.i_w_list) do
    if entry.interface.name == name then
      return entry
    end
  end
end

function Widgets:add_entry(index, name, hw_state)
  local entry = InterfaceWidgetEntry(index, name, hw_state)
  table.insert(self.i_w_list, entry)

  return entry
end

function Widgets:update_ip_addr_info ()
  local current_interface = nil
  local f = io.popen('ip addr show')

  for line in f:lines() do
    local index, name, hw_state = string.match(
      line, '^(%d+): (%g+): .- state (%a+)')

    if index then
      if name == 'lo' then
        -- information about loopback will be stored in this table,
        -- but will not be inserted into i_w_list
        -- good or bad solution?
        --
        -- add other interface name if it should be skipped
        current_interface = Interface(index, name, hw_state)
      else -- name ~= 'lo'
        local entry = self:get_entry_by_name(name)
        if entry then
          entry.interface.addr_list = {}
          entry.interface.hw_state = hw_state
        else
          -- create a new Widget
          local entry = self:add_entry(index, name, hw_state)
          current_interface = entry.interface
        end
      end
    else -- not index, means the detail of interface
      local ip = string.match(line, '[%d%.]*/%d+')
      if ip then
        assert(current_interface):append_addr(ip)
      end
    end
  end
  f:close()
end

function Widgets:update_ip_route_info ()
  local f = io.popen('ip route')

  for _, entry in pairs(self.i_w_list) do
    entry.interface.default_route = nil
  end

  for line in f:lines() do
    local default_route, name = string.match(line,
                                             'def.-([%d%.]+%d+) dev (%g+)')
    if default_route then
      local interface = assert(self:get_entry_by_name(name)).interface
      interface.default_route = default_route
    end
  end
  f:close()
end

function Widgets:update_state ()
  for _, entry in pairs(self.i_w_list) do
    if entry.interface.hw_state == 'DOWN' then
      entry.interface:update_state('hw_down')
    elseif entry.interface.default_route then
      entry.interface:update_state('has_route')
    else
      entry.interface:update_state('no_route')
    end
  end
end

function Widgets:all_widgets ()
  local i = 0
  return function ()
    i = i + 1
    if i > #self.i_w_list then
      return nil
    end
    return self.i_w_list[i].widget
  end
end

local net2 = {mt = {}}

local function display ()
  for _, entry in pairs(Widgets.i_w_list) do
    if entry.interface.curr_state ~= entry.interface.prev_state then
      local color = state_info_tbl[entry.interface.curr_state].color

      entry.widget:set_markup(sugar.span_str(entry.interface.name,
                                             {color = color}))
    end
  end
end

local function update ()
  Widgets:update_ip_addr_info()
  Widgets:update_ip_route_info()
  Widgets:update_state()
  display()
end

function net2:new ()
  local timer = capi.timer({timeout = 3})

  timer:connect_signal("timeout", update)
  timer:start()
  timer:emit_signal("timeout")

  return Widgets:all_widgets()
end

function net2.mt:__call (...)
  return net2:new (...)
end

return setmetatable(net2, net2.mt)
