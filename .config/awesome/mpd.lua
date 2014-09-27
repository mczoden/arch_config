local awful = require("awful")

local function get_mpd_play_pause_state()
  fd = assert(io.popen("mpc"))
  state = fd:read("*a")
  fd:close()

  return string.match(state, "%[.*%]")
end

function mpd_play_pause()
  state = get_mpd_play_pause_state()
  if state == "[playing]" then
    awful.util.spawn("mpc pause -q")
  else
    -- [pause]
    -- nil not playing
    awful.util.spawn("mpc play -q")
  end
end

mpd_play_pause()
