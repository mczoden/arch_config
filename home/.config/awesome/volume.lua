local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local util = require("awful.util")
local sugar = require("sugar")

local w = textbox()
local is_mute = false
local volume = {mt = {}}

function volume.display_volume(widget)
	local raw_input = util.pread("amixer sget Master")
  local volume_str = string.match(raw_input, "(%d?%d?%d)%%") or "0"
  volume_str = string.format("% 3d", volume_str)

  local output = ""
  local state = string.match(raw_input, "%[(o[^%]]*)%]") or "off"
  if string.find(state, "on", 1, true) then
    output = sugar.span_str("Vol", {color = "white"}) ..
             sugar.span_str(volume_str)
		is_mute = false
  else
    output = sugar.span_str("Mute", {color = "white"})
		is_mute = true
  end

  widget:set_markup(output)
end

function volume.new()
	volume.display_volume(w)

	return w
end

function volume.update(op)
	if op == "up" then
		util.spawn_with_shell("amixer set Master 5%+ > /dev/null")
		if is_mute then
			util.spawn_with_shell("amixer set Master toggle > /dev/null")
		end
	elseif op == "down" then
		util.spawn_with_shell("amixer set Master 5%- > /dev/null")
		if is_mute then
			util.spawn_with_shell("amixer set Master toggle > /dev/null")
		end
	elseif op == "mute" then
		util.spawn_with_shell("amixer set Master toggle > /dev/null")
	end

	volume.display_volume(w)
end

function volume.mt:__call(...)
	return volume.new(...)
end

return setmetatable(volume, volume.mt)
