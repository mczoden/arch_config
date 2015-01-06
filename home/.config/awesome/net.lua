local setmetatable = setmetatable
local string = {
  find = string.find,
  match = string.match,
  gmatch = string.gmatch,
  sub = string.sub,
}
local table = {
  concat = table.concat,
  insert = table.insert,
}
local io = {open = io.open}
local sugar = require("sugar")
local textbox = require("wibox.widget.textbox")
local util = require("awful.util")
local naughty = require("naughty")

local capi = {timer = timer}
local en = {
  ifname = "enp0s25",
  st_prev = "st_init",
  st_curr = "st_init",
  notify_obj = nil,
  info_obj = nil
}
local st_info_tbl = {
  st_init = nil,
  st_phy_down = {
    color = "#ff6565", -- red
    notify = "No Physical connection",
    timeout = 0
  },
  st_phy_up = {
    color = "#eab93d", -- yellow
    notify = "No IP address",
    timeout = 0
  },
  st_has_ip = {
    color = "#93d44f", -- green
    notify = "Obtains IP address",
    timeout = 3
  }
}
local w = textbox()
local net = {mt = {}}

local function get_addrs (t)
  local raw_input = util.pread("ip addr show " .. en.ifname)

  for ip in string.gmatch(raw_input, "[%d%.]*/%d+") do
    table.insert(t, ip)
  end
end

local function get_gw ()
  local raw_input = util.pread("ip route")
  raw_input = string.match(raw_input, "default.-[%d%.]+")
  return string.sub(raw_input, (string.find(raw_input, "%d")))
end

local function mouse_enter ()
  if en.st_curr ~= "st_has_ip" then
    return
  end

  local addrs = {}
  get_addrs(addrs)
  if #addrs == 0 then
    return
  end

  en.info_obj = naughty.notify({title = en.ifname,
                                text = "\nIP:\n"
                                       .. table.concat(addrs, "\n")
                                       .. "\nDefault Gateway:\n"
                                       .. get_gw(),
                                timeout = 0})
end

local function mouse_leave ()
  naughty.destroy(en.info_obj)
end

local function mouse_opt ()
  w:connect_signal("mouse::enter", mouse_enter)
  w:connect_signal("mouse::leave", mouse_leave)
end

local function get_state ()
  en.st_prev, en.st_curr = en.st_curr, "st_phy_down"

  local f = io.open("/sys/class/net/" .. en.ifname .. "/operstate", "r")
  if not f then
    return
  end
  local raw_input = f:read("*l")
  f:close()
  if string.find(raw_input, "down") then
    return
  end

  en.st_curr = "st_phy_up"

  raw_input = util.pread("journalctl -u netctl@endhcp.service -o cat -n 3")
  if string.find(raw_input, "leased")
      or string.find(raw_input, "Started")
      or string.find(raw_input, "rebinding") then
    en.st_curr = "st_has_ip"
  end
end

local function display ()
  if en.st_curr == en.st_prev then
    return
  end

  w:set_markup(sugar.span_str(en.ifname,
                              {color = st_info_tbl[en.st_curr].color}))
end

local function notify ()
  if en.st_curr == "st_has_ip" then
    if en.notify_obj then
      naughty.destroy(en.notify_obj)
    end
    return
  elseif en.st_curr == en.st_prev then
    return
  end

  if en.notify_obj then
    naughty.destroy(en.notify_obj)
  end

  en.notify_obj = naughty.notify({title = en.ifname,
                                  text = st_info_tbl[en.st_curr].notify,
                                  fg = st_info_tbl[en.st_curr].color,
                                  timeout = st_info_tbl[en.st_curr].timeout})
end

local function update ()
  get_state()
  display()
  notify()
end

function net.new ()
  local timer = capi.timer({timeout = 2})
  timer:connect_signal("timeout", update)
  timer:start()
  timer:emit_signal("timeout")

  mouse_opt()

  return w
end

function net.mt:__call (...)
  return net.new(...)
end

return setmetatable(net, net.mt)
