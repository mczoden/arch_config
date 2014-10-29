local setmetatable = setmetatable
local sugar = require("sugar")
local textbox = require("wibox.widget.textbox")
local util = require("awful.util")
local naughty = require("naughty")
local capi = {timer = timer}

local BAT_LOW_THRESHOLD = 15
local has_battery = false
local has_adapter = false
local is_charging = false
local cap = ""
local w = textbox()
local power = {mt = {}}

local function get_state()
  local raw_input = util.pread("acpi -ab")
  has_battery = string.match(raw_input, "Battery") and true or false
  has_adapter = string.match(raw_input, "on%-line") and true or false
  is_charging = string.match(raw_input, "Charging") and true or false
  cap = string.match(raw_input, "(%d?%d?%d)%%")
end

local function display()
  local output = sugar.span_str("Bat ", {color = "white"})

  if has_battery then
    if has_adapter then
      output = output .. sugar.span_str("⌁⌁")
    else
      output = output .. sugar.span_str(cap)
    end
  else
    output = output .. sugar.span_str("no")
  end

  w:set_markup(output)
end

local function notify()
  if not has_adapter and tonumber(cap) < 15 then
    naughty.notify({title = nil,
                    text = "Battery low! " .. cap .."%" .. " left",
                    fg = "#ffffff",
                    bg = "#C91C1C",
                    timeout = 5})
  end
end

local function update()
  get_state()
  display()
  notify()
end

function power.new()
  local timer = capi.timer({timeout = 5})
  timer:connect_signal("timeout", update)
  timer:start()
  timer:emit_signal("timeout")

  return w
end

function power.mt:__call(...)
  return power.new(...)
end

return setmetatable(power, power.mt)
