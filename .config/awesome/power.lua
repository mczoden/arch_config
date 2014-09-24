local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

power_widget = wibox.widget.textbox()
power_widget:set_align("right")

local function trim(s)
  return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

function update_power(widget)
  fd = assert(io.open("/sys/class/power_supply/BAT1/capacity", "r"))
  capacity = tonumber(fd:read("*all"))
  fd:close()

  fd = assert(io.open("/sys/class/power_supply/BAT1/status", "r"))
  status = trim(fd:read("*all"))
  fd:close()

  widget:set_markup("<span color='white'>Bat</span> " .. capacity)

  if capacity < 15 and status == "Discharging" then
    naughty.notify({ title = "Battery Warning",
                     text = "Battery low! " .. capacity .."%" .. " left",
                     fg = "#ffffff",
                     bg = "#C91C1C",
                     timeout = 59,
                   })
  end
end

update_power(power_widget)

mytimer = timer({timeout = 60})
mytimer:connect_signal("timeout", function () update_power(power_widget) end)
mytimer:start()
