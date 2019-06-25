local wibox = require("wibox")
local io = {
  popen = io.popen
}

local sugar = {}

sugar.space = wibox.widget.textbox("  ", true)

function sugar.span_str (str, style)
  output = "<span "

  if not style then
    style = {}
  end

  if style.font then
    output = output .. "font='" .. style.font .. "'"
  elseif theme and theme.font then
    output = output .. "font='" .. theme.font .. "'"
  end

  if style.color then
    output = output .. " color='" .. style.color .. "'"
  end

  output = output .. ">" .. str .. "</span>"

  return output
end

function sugar.pread (cmd)
  local result = ''

  local f = io.popen(cmd)
  if f then
    result = f:read('*all')
    f:close()
  end

  return result
end

return sugar
