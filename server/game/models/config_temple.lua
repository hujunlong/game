local M = ConfigBase:new()

ConfigTemple = M

M:set_origin(config_temples)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end


function M:get_current_config()
    local _, t = next(self:all())
    return t
end

function M:get_temple_buff_list()
    if self.__buff then return self.__buff end
    self.__buff = {}
    local config = self:get_current_config()
    local t = Tool:split(config.buff, ',')
    for i,v in ipairs(t) do
        local items_t = Tool:split(v, ":")
        table.insert(self.__buff, {_id = tonumber(items_t[1]), rate = tonumber(items_t[2])}) 
    end
    return self.__buff
end

function M:get_current_random_buff()
    local buff_list = self:get_temple_buff_list()
    local buff = nil
    while not buff do
        for k , v in pairs(buff_list) do
            if Tool:random_event_100(v.rate) then
                buff = v
                break
            end
        end
    end
    return buff
end

function M:get_next_refresh_time()
    local config = self:get_current_config()
    return math.random(config.refresh_min, config.refresh_max)
end

M:load()

return M