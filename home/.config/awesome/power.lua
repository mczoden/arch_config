local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local sugar = require("sugar")

power_widget = wibox.widget.textbox()
power_widget:set_align("right")

local function trim(s)
  return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

function update_power(widget)
  cap = 0
  adapter = false
  text = sugar.span_str("Bat", {color = "white"})

  f = io.popen("acpi -ab", "r")
  acpi = f:read("*all")
  f:close()

  if string.match(acpi, "on%-line") then
    adapter = true
  end

  cap = tonumber(string.match(acpi, "(%d?%d?%d)%%"))

  if not cap then
    text = text .. sugar.span_str(" ⌁⌁")
  else
    if adapter then
      text = text .. sugar.span_str(" " .. cap)
    else
      text = text .. sugar.span_str("↯" .. cap)
    end
  end

  widget:set_markup(text)

  if not adapter and cap < 15 then
    naughty.notify({ title = "Battery Warning",
                     text = "Battery low! " .. cap .."%" .. " left",
                     fg = "#ffffff",
                     bg = "#C91C1C",
                     timeout = 5,
                   })
  end
end

update_power(power_widget)

mytimer = timer({timeout = 5})
mytimer:connect_signal("timeout", function () update_power(power_widget) end)
mytimer:start()
