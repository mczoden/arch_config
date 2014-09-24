local naughty = require("naughty")

local eth_if_name = "enp0s25"
local last_eth_stat = "up"
local obj = nil

local function trim(s)
  return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

function eth_stat()
  fd = assert(io.open("/sys/class/net/" .. eth_if_name .. "/operstate", "r"))
  curr_stat = trim(fd:read("*all"))
  fd:close()

  if curr_stat ~= last_eth_stat then
    if curr_stat == "up" and obj then
      naughty.destroy(obj)
    end
    obj = naughty.notify({ title = nil,
                           text = eth_if_name .. " " .. curr_stat,
                           fg = "#ffffff",
                           timeout = curr_stat == "up" and 3 or 0
                         })
    last_eth_stat = curr_stat
  end
end

mytimer = timer({timeout = 1})
mytimer:connect_signal("timeout", function () eth_stat() end)
mytimer:start()
