local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local awful = require("awful")
local sugar = require("sugar")

local vol = ""
local is_mute = false
local w = textbox()
local volume = {mt = {}}

local function get_state()
  local raw_input = awful.util.pread("amixer get Master")
  vol = string.match(raw_input, "(%d?%d?%d)%%") or "0"

  local state = string.match(raw_input, "%[(o[^%]]*)%]") or "off"
  is_mute = string.find(state, "off", 1, true) and true or false
end

local function display()
  w:set_markup(sugar.span_str("Vol", {color = "white"}) ..
               sugar.span_str(is_mute and " --" or string.format("%3d", vol)))
end

function volume.adjust(op)
  if op == "up" then
    awful.util.spawn_with_shell("amixer set Master 5%+ > /dev/null")
    if is_mute then
      awful.util.spawn_with_shell("amixer set Master toggle > /dev/null")
    end
  elseif op == "down" then
    awful.util.spawn_with_shell("amixer set Master 5%- > /dev/null")
    if is_mute then
      awful.util.spawn_with_shell("amixer set Master toggle > /dev/null")
    end
  elseif op == "mute" then
    awful.util.spawn_with_shell("amixer set Master toggle > /dev/null")
  end

  get_state()
  display()
end

local function bindkey()
  w:buttons(awful.util.table.join(
                awful.button({}, 1, function () volume.adjust("mute") end),
                awful.button({}, 4, function () volume.adjust("up") end),
                awful.button({}, 5, function () volume.adjust("down") end)))
end

function volume.new()
  get_state()
  display()

  bindkey()
  return w
end

function volume.mt:__call(...)
  return volume.new(...)
end

return setmetatable(volume, volume.mt)
