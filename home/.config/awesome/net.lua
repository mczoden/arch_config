local setmetatable = setmetatable
local sugar = require("sugar")
local textbox = require("wibox.widget.textbox")
local naughty = require("naughty")
local capi = {timer = timer}

local ETH_IF_NAME = "enp0s25"
local eth_last_state = "UNKNOW"
local eth_curr_state = "UNKNOW"
local notify_obj = nil
local w = textbox()
local net = {mt = {}}

local function get_state()
	eth_last_state = eth_curr_state
  local f = assert(io.open("/sys/class/net/" .. ETH_IF_NAME .. "/operstate", "r"))
  eth_curr_state = f:read()
  f:close()
end

local function display()
	w:set_markup(sugar.span_str("Net ", {color = "white"}) .. 
	             sugar.span_str(eth_curr_state))
end

local function notify()
	if eth_curr_state == "up" and notify_obj then
		naughty.destroy(notify_obj)
	end

   notify_obj = naughty.notify({title = nil,
														   text = ETH_IF_NAME .. " " .. eth_curr_state,
															 fg = "#ffffff",
															 timeout = eth_curr_state == "up" and 3 or 0})
end

local function update()
	get_state()

	if eth_last_state == "UNKNOW" then
		-- awesome setup
		display()
		if eth_curr_state ~= "up" then
			notify()
		end
	elseif eth_curr_state ~= eth_last_state then
		display()
		notify()
	end
end

function net.new()
	local timer = capi.timer({timeout = 1})
	timer:connect_signal("timeout", update)
	timer:start()
	timer:emit_signal("timeout")

	return w
end

function net.mt:__call(...)
	return net.new(...)
end

return setmetatable(net, net.mt)
