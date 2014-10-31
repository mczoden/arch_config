local setmetatable = setmetatable
local string = {
    find = string.find,
    match = string.match,
    gmatch = string.gmatch,
    sub = string.sub,
}
local table = {
    concat = table.concat,
    insert = table.insert,
}
local io = {popen = io.popen}
local sugar = require("sugar")
local textbox = require("wibox.widget.textbox")
local awful = require("awful")
local naughty = require("naughty")

local capi = {timer = timer}
local eth = {
    ifname = "enp0s25",
    st_prev = "st_init",
    st_curr = "st_init",
    notify_obj = nil,
    info_obj = nil
}
local st_info_tbl = {
    st_init = nil,
    st_phy_down = {
        color = "#ff6565", -- red
        notify = "No Physical connection",
        timeout = 0
    },
    st_phy_up = {
        color = "#eab93d", -- yellow
        notify = "No IP address",
        timeout = 0
    },
    st_has_ip = {
        color = "#93d44f", -- green
        notify = "Obtains IP address",
        timeout = 3
    }
}
local w = textbox()
local net = {mt = {}}

local function get_addrs(t)
    local raw_input = awful.util.pread("ip addr show " .. eth.ifname)

    for ip in string.gmatch(raw_input, "[%d%.]*/%d+") do
        table.insert(t, ip)
    end
end

local function get_gw()
    local raw_input = awful.util.pread("ip route")
    raw_input = string.match(raw_input, "default.-[%d%.]+")
    return string.sub(raw_input, (string.find(raw_input, "%d")))
end

local function mouse_enter()
    if eth.st_curr ~= "st_has_ip" then
        return
    end

    local addrs = {}
    get_addrs(addrs)
    if #addrs == 0 then
        return
    end

    eth.info_obj = naughty.notify({title = eth.ifname,
                                   text = "\nIP:\n"
                                   .. table.concat(addrs, "\n")
                                   .. "\nDefault Gateway:\n"
                                   .. get_gw(),
                                   timeout = 0})
end

local function mouse_leave()
    naughty.destroy(eth.info_obj)
end

local function mouse_opt()
    w:connect_signal("mouse::enter", mouse_enter)
    w:connect_signal("mouse::leave", mouse_leave)
end

local function get_state()
    eth.st_prev = eth.st_curr

    local raw_input =
        awful.util.pread("journalctl -u netctl@network.service -o cat -n 3")
    if string.find(raw_input, "carrier lost") then
        eth.st_curr = "st_phy_down"
    elseif string.find(raw_input, "leased")
            or string.find(raw_input, "Started") then
        eth.st_curr = "st_has_ip"
    else
        eth.st_curr = "st_phy_up"
    end
end

local function display()
    if eth.st_curr == eth.st_prev then
        return
    end

    w:set_markup(sugar.span_str(eth.ifname,
                                {color = st_info_tbl[eth.st_curr].color}))
end

local function notify()
    if eth.st_curr == "st_has_ip" then
        if eth.notify_obj then
            naughty.destroy(eth.notify_obj)
        end
        return
    elseif eth.st_curr == eth.st_prev then
        return
    end

    if eth.notify_obj then
        naughty.destroy(eth.notify_obj)
    end

    eth.notify_obj = naughty.notify({title = eth.ifname,
                                     text = st_info_tbl[eth.st_curr].notify,
                                     fg = st_info_tbl[eth.st_curr].color,
                                     timeout = st_info_tbl[eth.st_curr].timeout})
end

local function update()
    get_state()
    display()
    notify()
end

function net.new()
    local timer = capi.timer({timeout = 2})
    timer:connect_signal("timeout", update)
    timer:start()
    timer:emit_signal("timeout")

    mouse_opt()

    return w
end

function net.mt:__call(...)
    return net.new(...)
end

return setmetatable(net, net.mt)
