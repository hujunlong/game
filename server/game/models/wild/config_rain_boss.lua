local M = ConfigBase:new()

ConfigRainBoss = M

M:set_origin(config_rain_bosses)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:load(  )
  self.__records = {}
  self.__levels = {}
  for k, v in ipairs(self:get_origin()) do
    local config = self:new(v)
    config:init_technology()
    config:init_program()
    config:init_equipment_level()
    config:init_soul()
    config:init_gold()
    config:init_rare_items()
    self.__records[v._id] = config
    self.__levels[v.level] = config
    table.insert(self.__srecords, self.__records[v._id])
  end
end

function M:find_by_level(level)
  return self.__levels[level]
end

function M:find_by_user_level(level)
  for i, v in ipairs(M:sall()) do
    if level < v.level_min then
      return nil;
    end 

    if level <= v.level_max then
      return v;
    end
  end
end

function M:init_technology()
  local technologies = {}
  for k, str in pairs(Tool:split(self.technology, ',')) do
    local strs = Tool:split(str, ':')
    table.insert(technologies, {level = tonumber(strs[1]), rate = tonumber(strs[2]) / 100})
  end

  self.__technology = technologies
end

function M:get_technology()
  return self.__technology
end

function M:init_program()
  local programs = {}
  for k, v in pairs(Tool:split(self.program, ',')) do
    local strs = Tool:split(v, ':')
    table.insert(programs, {program = tonumber(strs[1]), rate = tonumber(strs[2])})
  end
  
  self.__program = programs
end

function M:get_rand_progam()
  local rate = math.random(1, 100);

  for i, v in ipairs(self.__program) do
    if v.rate > 0 and v.rate >= rate then
      return v.program
    end

    rate = rate - v.rate;
  end
end

function M:init_equipment_level()
  local levels = {}
  for i, v in ipairs(Tool:split(self.drop_level, ',')) do
    table.insert(levels, tonumber(v));
  end

  self.__equipment_level = levels
end

function M:get_rand_equipment_level()
  local index = math.random(1, #self.__equipment_level)
  return self.__equipment_level[index]
end

function M:init_soul()
  local souls = {}
  for i, v in ipairs(Tool:split(self.soul, ',')) do
    local strs = Tool:split(v, ':')
    table.insert(souls, {
      item_id = tonumber(strs[1]),
      min     = tonumber(strs[2]),
      max     = tonumber(strs[3]),
      rate    = tonumber(strs[4]),
    })
  end

  self.__souls = souls
end

function M:get_rand_soul()
  local rate = math.random(1, 100)
  for i, soul in ipairs(self.__souls) do
    if soul.rate > 0 and soul.rate >= rate then
      return {
        item_id = soul.item_id,
        amount = Tool:rand_range(soul.min, soul.max),
      }
    end
  end
end

function M:init_gold()
  local strs = Tool:split(self.gold, ':')
  self.__gold = {
    item_id = tonumber(strs[1]),
    min     = tonumber(strs[2]),
    max     = tonumber(strs[3]),
  }
end

function M:get_rand_gold()
  local gold = self.__gold
  return {
    item_id = gold.item_id,
    amount = Tool:rand_range(gold.min, gold.max),
  }
end

function M:init_rare_items()
  local items = {}

  local list = Tool:split(self.drop_rare_items, ',')
  for i, str in ipairs(list) do
    local strs = Tool:split(str, ":")
    table.insert(items, {
      item_id = tonumber(strs[1]),
      min     = tonumber(strs[2]),
      max     = tonumber(strs[3]),
      rate    = tonumber(strs[4]),
    })
  end

  self.__rare_items = items
end

function M:get_rand_rare_item()
  local rate = math.random(1, 100)

  for i, item in ipairs(self.__rare_items) do
    if item.rate > 0 and item.rate >= rate then
      return {
        item_id = item.item_id,
        amount = Tool:rand_range(item.min, item.max),
      }
    end
  end
end

function M:refresh()
  local result = {}
  local total_might = Tool:rand_range(tonumber(self.might_min), tonumber(self.might_max))
  local config_program = ConfigProgram:find_by_id(self:get_rand_progam())
  for k, m in pairs(config_program:generate_sun()) do
    local might = tonumber(total_might * m.rate)
    for k, t in pairs(self:get_technology()) do
      local cm = ConfigMonster:find_by_type_and_level(m.type, t.level)
      if cm then
        local amount = tonumber(tonumber((might * t.rate)) / cm.might)
        table.insert(result, {config_id = cm._id, amount = math.ceil(amount)})
      else
        print("can not find monster config: type " .. m.type .. ", level " .. t.level)
      end  
    end
  end 
  return result
end

function M:drop_equipment( armies )
  if Tool:random_event_100(self.drop_chance) then
    return self:get_drop_equipment(armies)
  end

  return nil
end

function M:get_drop_equipment( armies )
  local army = armies[1]
  local ci = ConfigMonster:find_by_id(army._id or army.config_id)
  local part = ConfigMonsterType:find_by_id(ci.belong):drop_equipment_part()
  return ConfigEquipment:find_by_level_and_part(self:get_rand_equipment_level(), part)
end

function M:get_drop_equipment_list(armies)
  local army = armies[1]
  local ci = ConfigMonster:find_by_id(army._id or army.config_id)
  local part_list = ConfigMonsterType:find_by_id(ci.belong):get_equipment_parts()
  local equipment_list = {}
  for i, level in ipairs(self.__equipment_level) do
    for part, rate in ipairs(part_list) do
      local item = ConfigEquipment:find_by_level_and_part(level, part)
      if item then
        table.insert(equipment_list, {
          item_id = item._id,
          amount = 1,
        })
      end
    end
  end

  return equipment_list
end

function M:get_all_items( armies )
  local result = self:get_drop_equipment_list(armies)

  local gold = self.__gold;
  table.insert(result, {item_id = gold.item_id, amount = gold.min})

  for i, v in ipairs(self.__souls) do
    table.insert(result, {item_id = v.item_id, amount = v.min})
  end

  for i, v in ipairs(self.__rare_items) do
    table.insert(result, {item_id = v.item_id, amount = v.min})
  end
  
  return result
end

function M:drop( armies )
  local result = {}

  local gold_item = self:get_rand_gold()
  table.insert(result, gold_item)

  local soul = self:get_rand_soul()
  if soul then
    table.insert(result, soul)
  end

  local rare_items = self:get_rand_rare_item()
  if rare_items then
    table.insert(result, rare_items)
  end

  local drop_equip = self:drop_equipment(armies)
  if drop_equip then
    table.insert(result, {item_id = drop_equip._id, amount = 1})
  end

  return result
end

M:load()

return M