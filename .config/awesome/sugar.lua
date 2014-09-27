local sugar = {}

function sugar.span_str(args)
  str = "<span "

  if args.font then
    str = str .. "font='" .. args.font
  else
    str = str .. "font='terminus"
  end

  if args.size then
    str = str .. " " .. args.size .. "'"
  else
    str = str .. " 10'"
  end

  if args.color then
    str = str .. " color='" .. args.color .. "'"
  end

  str = str .. ">" .. args.fmt .. "</span>"

  return str
end

return sugar
