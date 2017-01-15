local M = ConfigBase:new()

ConfigProgram = M

M:set_origin(config_programs)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:_generate( monster_config )
  local first = Tool:slice(monster_config, 0, -1)
  local last = Tool:last(monster_config)
  local result = {}
  local last_rate = 100
  for i,m in ipairs(first) do
    local rate = Tool:rand_range(m.min, m.max)
    local last_rate = last_rate - rate
    table.insert(result, {type = m.type, rate = rate / 100})
  end
  return result  
end

function M:generate_sun(  )
  return ConfigProgram:_generate(self:get_sun_monsters())
end

function M:generate_rain(  )
  local rain_monsters = self:convert_monster_config('monster_rain', '_rain_monsters');
  return ConfigProgram:_generate(rain_monsters);
end

function M:get_sun_monsters( )
  return self:convert_monster_config('monster_sun', '_sun_monsters')
end

function M:convert_monster_config( col_name, name )
  if self[name] then return self[name] end
  self[name] = {}
  for k,str in pairs(Tool:split(self[col_name], ',')) do
    local t = Tool:split(str, ':')
    local t1 = Tool:split(t[2], '-')
    table.insert(self[name], {type = tonumber(t[1]), min = tonumber(t1[1]), max = tonumber(t1[2])})
  end
  return self[name]
end

M:load()

return M

