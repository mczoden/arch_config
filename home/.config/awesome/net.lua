local sugar = require("sugar")
local textbox = require("wibox.widget.textbox")
local awful = require("awful")
local naughty = require("naughty")

local capi = {timer = timer}
local st_info_tbl = {
  st_init = nil,
  st_phy_down = {
    color = "#ff6565",
    notify = "No Physical connection",
    timeout = 0
  },
  st_phy_up = {
    color = "#eab93d",
    notify = "No IP address",
    timeout = 0
  },
  st_has_ip = {
    color = "#93d44f",
    notify = "Obtains IP address",
    timeout = 3
  }
}
local eth = {
  ifname = "enp0s25",
  st_prev = "st_init",
  st_curr = "st_init",
  notify_obj = nil
}
local w = textbox()
local net = {mt = {}}

local function get_state()
  eth.st_prev = eth.st_curr

  local raw_input = awful.util.pread("ip addr show " .. eth.ifname)
  if string.find(raw_input, "inet") then
    eth.st_curr = "st_has_ip"
    return
  end

  if string.find(raw_input, "state UP") then
    eth.st_curr = "st_phy_up"
  else
    eth.st_curr = "st_phy_down"
  end
end

local function display()
  if eth.st_curr == eth.st_prev then
    return
  end

  w:set_markup(sugar.span_str(eth.ifname,
                              {color = st_info_tbl[eth.st_curr].color}))
end

local function notify()
  if eth.st_prev == "st_init" or eth.st_curr == eth.st_prev then
    return
  end

  if notify_obj then
    naughty.destroy(notify_obj)
  end

  notify_obj = naughty.notify({title = eth.ifname,
                              text = st_info_tbl[eth.st_curr].notify,
                              fg = st_info_tbl[eth.st_curr].color,
                              timeout = st_info_tbl[eth.st_curr].timeout})
end

local function update()
  get_state()
  display()
  notify()
end

function net.new()
  local timer = capi.timer({timeout = 2})
  timer:connect_signal("timeout", update)
  timer:start()
  timer:emit_signal("timeout")

  return w
end

function net.mt:__call(...)
  return net.new(...)
end

return setmetatable(net, net.mt)
