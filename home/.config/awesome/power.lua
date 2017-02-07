local setmetatable = setmetatable
local string = {
  match = string.match,
  sub = string.sub,
}
local timer = require("gears.timer")
local sugar = require("sugar")
local textbox = require("wibox.widget.textbox")
local util = require("awful.util")
local naughty = require("naughty")

local UPDATE_TIMEOUT_IN_SECOND = 5
local BAT_LOW_THRESHOLD = 15
local bat = {
  cap = "",
  st_prev = "st_init",
  st_curr = "st_init",
  info_obj = nil
}
local st_info_tbl = {
  st_init = nil,
  st_no_bat = {
    display = function () return "DC" end,
    color = function () end
  },
  st_discharge = {
    display = function () return bat.cap end,
    color = function ()
      return tonumber(bat.cap) < BAT_LOW_THRESHOLD and "#ff6565" or nil
    end
  },
  st_charging = {
    display = function () return "⌁⌁" end,
    color = function () return "#93d44f" end
  },
  st_uncharge = {
    display = function () return "⌁⌁" end,
    color = function () end
  }
}
local w = textbox()
local power = {mt = {}}

local function mouse_enter ()
  bat.info_obj = naughty.notify({title = nil,
                                 text = string.sub(sugar.pread("acpi"), 0, -2),
                                 timeout = 0})
end

local function mouse_leave ()
  naughty.destroy(bat.info_obj)
end

local function mouse_opt ()
  w:connect_signal("mouse::enter", mouse_enter)
  w:connect_signal("mouse::leave", mouse_leave)
end

local function get_state ()
  bat.st_prev = bat.st_curr

  local raw_input = sugar.pread("acpi -ab")
  local has_battery = string.match(raw_input, "Battery") and true or false
  local has_adapter = string.match(raw_input, "on%-line") and true or false
  local is_charging = string.match(raw_input, "Charging") and true or false
  bat.cap = string.match(raw_input, "(%d?%d?%d)%%")

  if has_battery then
    if has_adapter then
      if is_charging then
        bat.st_curr = "st_charging"
      else
        bat.st_curr = "st_uncharge"
      end
    else
      bat.st_curr = "st_discharge"
    end
  else
    bat.st_curr = "st_no_bat"
  end
end

local function display ()
  if bat.st_curr == bat.st_prev then
    if bat.st_curr ~= "st_discharge" then
      return
    end
  end

  w:set_markup(sugar.span_str("Bat ", {color = "white"})
               .. sugar.span_str(st_info_tbl[bat.st_curr].display(),
                                 {color = st_info_tbl[bat.st_curr].color()}))
end

local function notify ()
  if bat.st_curr == "st_discharge"
      and tonumber(bat.cap) < BAT_LOW_THRESHOLD then
    naughty.notify({title = nil,
                    text = "Battery low! " .. bat.cap .. "%" .. " left",
                    fg = "#ffffff",
                    bg = "#C91C1C",
                    timeout = 5})
  end
end

local function update ()
  get_state()
  display()
  notify()
end

function power.new ()
  local t

  function w._private_power_update_cb ()
    update()
    t.timeout = UPDATE_TIMEOUT_IN_SECOND
    t:again()

    return true
  end

  t = timer.start_new(UPDATE_TIMEOUT_IN_SECOND, w._private_power_update_cb)
  t:emit_signal('timeout')

  mouse_opt()

  return w
end

function power.mt:__call (...)
  return power.new(...)
end

return setmetatable(power, power.mt)
