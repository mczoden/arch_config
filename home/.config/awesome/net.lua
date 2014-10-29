local sugar = require("sugar")
local textbox = require("wibox.widget.textbox")
local awful = require("awful")
local naughty = require("naughty")

local capi = {timer = timer}
local ETH_IF_NAME = "enp0s25"
local st_info_tbl = {
  st_init = nil,
  st_phy_down = {
    color = "red",
    notify = "No Physical connection",
    timeout = 0
  },
  st_phy_up = {
    notify = "No IP address",
    timeout = 0
  },
  st_has_ip = {
    color = "green",
    notify = "Obtains IP address",
    timeout = 3
  }
}
local eth_last_state = "st_init"
local eth_curr_state = "st_init"
local notify_obj = nil
local w = textbox()
local net = {mt = {}}

local function get_state()
  eth_last_state = eth_curr_state

  local raw_input = awful.util.pread("ip addr show " .. ETH_IF_NAME)
  if string.find(raw_input, "inet") then
    eth_curr_state = "st_has_ip"
    return
  end

  if string.find(raw_input, "state UP") then
    eth_curr_state = "st_phy_up"
  else
    eth_curr_state = "st_phy_down"
  end
end

local function display()
  w:set_markup(sugar.span_str(ETH_IF_NAME,
                              {color = st_info_tbl[eth_curr_state].color}))
end

local function notify()
  if notify_obj then
    naughty.destroy(notify_obj)
  end

  notify_obj = naughty.notify({title = nil,
                              text = ETH_IF_NAME .. " " ..
                                     st_info_tbl[eth_curr_state].notify,
                              fg = "#ffffff",
                              timeout = st_info_tbl[eth_curr_state].timeout})
end

local function update()
  get_state()

  if eth_last_state == "st_init" then
    display()
    if eth_curr_state ~= "st_has_ip" then
      notify()
    end
  elseif eth_curr_state ~= eth_last_state then
    display()
    notify()
  end
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
