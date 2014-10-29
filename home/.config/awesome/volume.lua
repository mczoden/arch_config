local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local util = require("awful.util")
local sugar = require("sugar")

local vol = ""
local is_mute = false
local w = textbox()
local volume = {mt = {}}

function volume.get_state()
	local raw_input = util.pread("amixer get Master")
	vol = string.match(raw_input, "(%d?%d?%d)%%") or "0"
  vol = string.format("% 3d", vol)

  local state = string.match(raw_input, "%[(o[^%]]*)%]") or "off"
	is_mute = string.find(state, "off", 1, true) and true or false
end

function volume.display(widget)
  local output = ""
  if is_mute then
    output = sugar.span_str("Mute", {color = "white"})
  else
    output = sugar.span_str("Vol", {color = "white"}) ..
             sugar.span_str(vol)
  end

  widget:set_markup(output)
end

function volume.adjust(op)
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

	volume.get_state()
	volume.display(w)
end

function volume.new()
	volume.get_state()
	volume.display(w)

	return w
end

function volume.mt:__call(...)
	return volume.new(...)
end

return setmetatable(volume, volume.mt)
