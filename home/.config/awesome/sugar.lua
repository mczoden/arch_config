local wibox = require("wibox")

local sugar = {}

sugar.DFL_FONT = "Dina"
sugar.DFL_FONT_SIZE = "10"
sugar.space = wibox.widget.textbox()
sugar.space:set_text("  ")

function sugar.span_str(str, style)
    output = "<span "

    if not style then
        style = {}
    end

    if style.font then
        output = output.. "font='" .. style.font
    else
        output = output .. "font='" .. sugar.DFL_FONT
    end

    if style.size then
        output = output .. " " .. style.size .. "'"
    else
        output = output .. " " .. sugar.DFL_FONT_SIZE .. "'"
    end

    if style.color then
        output = output .. " color='" .. style.color .. "'"
    end

    output = output .. ">" .. str .. "</span>"

    return output
end

return sugar
