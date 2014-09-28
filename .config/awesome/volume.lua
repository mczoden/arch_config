local wibox = require("wibox")
local awful = require("awful")

local sugar = require("sugar")

volume_widget = wibox.widget.textbox()
volume_widget:set_align("right")

function update_volume(widget)
  fd = assert(io.popen("amixer sget Master"))
  status = fd:read("*all")
  fd:close()

  -- local volume = tonumber(string.match(status, "(%d?%d?%d)%%")) / 100
  volume = string.match(status, "(%d?%d?%d)%%")
  volume = string.format("% 3d", volume)

  status = string.match(status, "%[(o[^%]]*)%]")

  if string.find(status, "on", 1, true) then
    volume = sugar.span_str({fmt = "Vol", color = "white"}) ..
             sugar.span_str({fmt = volume})
  else
    volume = sugar.span_str({fmt = "Mute", color = "white"})
  end
  widget:set_markup(volume)
end

update_volume(volume_widget)

mytimer = timer({timeout = 0.5})
mytimer:connect_signal("timeout", function () update_volume(volume_widget) end)
mytimer:start()
