local setmetatable = setmetatable
local sugar = require("sugar")
local textbox = require("wibox.widget.textbox")
local util = require("awful.util")
local naughty = require("naughty")
local capi = {timer = timer}

local has_battery = false
local has_adapter = false
local cap = ""
local w = textbox()
local power = {mt = {}}

function power.get_state()
	local raw_input = util.pread("acpi -ab")
	has_battery = string.match(raw_input, "Battery") and true or false
	has_adapter = string.match(raw_input, "on%-line") and true or false
	cap = string.match(raw_input, "(%d?%d?%d)%%")

	print(has_battery, has_adapter, cap)
end

function power.display(widget)
	local output = sugar.span_str("Bat", {color = "white"})

	if has_battery then
    if has_adapter then
      output = output .. sugar.span_str(" " .. cap)
    else
      output = output .. sugar.span_str("↯" .. cap)
    end
	else
		output = output .. sugar.span_str(" ⌁⌁")
	end

  widget:set_markup(output)
end

function power.notify()
  if not has_adapter and tonumber(cap) < 100 then
    naughty.notify({title = nil,
                    text = "Battery low! " .. cap .."%" .. " left",
                    fg = "#ffffff",
                    bg = "#C91C1C",
                    timeout = 0})
  end
end

function power.update()
	power.get_state()
	power.display(w)
	power.notify()
end

function power.new()
	local timer = capi.timer({timeout = 5})
	timer:connect_signal("timeout", power.update)
	timer:start()
	timer:emit_signal("timeout")

	return w
end

function power.mt:__call(...)
	return power.new(...)
end

return setmetatable(power, power.mt)
