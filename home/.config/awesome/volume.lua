local setmetatable = setmetatable
local string = {
  find = string.find,
  match = string.match,
  format = string.format,
}
local textbox = require("wibox.widget.textbox")
local awful = require("awful")
local sugar = require("sugar")

local vol = ""
local is_mute = false
local w = textbox()
local volume = {mt = {}}

local function amixer_paser (amixer_output)
  vol = string.match(amixer_output, "(%d?%d?%d)%%") or "0"

  local state = string.match(amixer_output, "%[(o[^%]]*)%]") or "off"
  is_mute = string.find(state, "off", 1, true) and true or false
end

local function display ()
  w:set_markup(sugar.span_str("Vol", {color = "white"}) ..
  sugar.span_str(is_mute and " --" or string.format("%3d", vol)))
end

function volume.adjust_and_display (op)
  local cmd = ""

  if op == nil then
    cmd = "amixer get Master"
  elseif op == "mute" then
    cmd = "amixer set Master toggle"
  else
    cmd = string.format("amixer set Master 5%%%s", op == "up" and "+" or "-")
    if is_mute then
      cmd = cmd .. " toggle"
    end
  end

  amixer_paser(awful.util.pread(cmd))
  display()
end

local function mouse_opt ()
  w:buttons(awful.util.table.join(
    awful.button({}, 1, function () volume.adjust_and_display("mute") end),
    awful.button({}, 4, function () volume.adjust_and_display("up") end),
    awful.button({}, 5, function () volume.adjust_and_display("down") end)))
end

function volume.new ()
  volume.adjust_and_display()

  mouse_opt()
  return w
end

function volume.mt:__call (...)
  return volume.new(...)
end

return setmetatable(volume, volume.mt)
