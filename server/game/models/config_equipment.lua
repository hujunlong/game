local M = ConfigBase:new()

ConfigEquipment = M

M:set_origin(config_equipments)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:get_effects(  )
  return self:convert_effects_col("__effects", "attribute")
end

function M:get_effects_t()
  if self.__effects_t then return self.__effects_t end
  self.__effects_t = {}
  for k,e in pairs(self:get_effects()) do
    self.__effects_t[e.effect_id] = {effect_id = e.effect_id, num = e.num}
  end
  return self.__effects_t
end

function M:get_formulas(  )
  return self:convert_items_col('__formulas', 'formula')
end

function M:find_by_level_and_part( level, part )
  if level == 0 then return nil end
  if self.__level_and_part and self.__level_and_part[level] then
    return self.__level_and_part[level][part]
  end
  self.__level_and_part = {}
  for k,v in pairs(self:all()) do
    if v.can_drop == 1 then
      self.__level_and_part[v.equipment_level] = self.__level_and_part[v.equipment_level] or {}
      self.__level_and_part[v.equipment_level][v.part] = v
    end
  end
  print('find_by_level_and_part. level, part = ', level, part)
  local level_data = self.__level_and_part[level]
  for k,v in pairs(level_data) do
    print(k, v)
  end
  return self.__level_and_part[level][part]
end

function M:get_random_id_by_level(level)
  if self.__level == nil then
    self.__level = {}
    for k, v in pairs(self:all()) do
      if v.can_drop == 1 then
        self.__level[v.equipment_level] = self.__level[v.equipment_level] or {}
        table.insert(self.__level[v.equipment_level], v._id)
      end
    end
  end

  local list = self.__level[level]
  if list and #list > 0 then
    local index = math.random(1, #list)
    return list[index]
  end
end

M:load()

return M
