-- prototype: Interface
local Interface = {mt={}}

function Interface.mt:__call (...)
  return Interface:new(...)
end

function Interface:new (index, name, hw_state)
  local o = {
    index = index,
    name = name,
    hw_state = hw_state,
    addr_list = {},
    prev_state = 'init',
    curr_state = 'init',
    default_route = nil
  }

  self.__index = self
  self.__tostring = function (self)
    local outbuf = tostring(self.index) .. ' ' .. self.name .. ': ' .. '\n' ..
             self.hw_state .. '\n'
    for _, v in pairs(self.addr_list) do
      outbuf = outbuf .. v .. '\n'
    end
    outbuf = outbuf .. self.prev_state .. ', ' ..
             self.curr_state .. '\n' .. (self.default_route or 'null')
    return outbuf
  end

  return setmetatable(o, self)
end

function Interface:append_addr (ip)
  table.insert(self.addr_list, ip)
end

function Interface:update_state (state)
  self.prev_state = self.curr_state
  self.curr_state = state
end

function Interface:display ()
  debug(tostring(self))
end

return setmetatable(Interface, Interface.mt)
