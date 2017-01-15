local ItemConst = require 'item_const'

local M = ConfigBase:new()

ConfigArmy = M

M:set_origin(config_armies)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:find_by_level( level )
  if self.__LEVELS then return self.__LEVELS[level] end
  self.__LEVELS = {}
  for k,v in pairs(self:all()) do
    self.__LEVELS[v.level] = v
  end
  return self.__LEVELS[level]   
end

function M:get_technologies( )
  if self._technologies then return self._technologies end
  self._technologies = {}
  for k,str in pairs(Tool:split(self.technology, ',')) do
    t = Tool:split(str, ':')
    table.insert(self._technologies, {level = tonumber(t[1]), rate = tonumber(t[2])/100})
  end
  return self._technologies  
end

function M:refresh(  )
  local result = {}
  local total_might = Tool:rand_range(self.might_min, self.might_max)
  local config_program = ConfigProgram:find_by_id(Tool:rand(self:get_progams()))
  for k,m in pairs(config_program:generate_sun()) do
    local might = tonumber(total_might * m.rate)
    for k,t in pairs(self:get_technologies()) do
      local cm = ConfigMonster:find_by_type_and_level(m.type, t.level)
      if cm then
        local amount = tonumber(tonumber((might * t.rate)) / cm.might)
        table.insert(result, {config_id = cm._id, amount = math.ceil(amount)})
      end  
    end
  end 
  return result
end

function M:get_progams(  )
  local rates = {}
  for k,v in pairs(Tool:split(self.program, ',')) do
    local t = Tool:split(v, ':')
    local cg = t[1]
    local rate = tonumber(t[2])
    table.insert(rates, tonumber(cg))
  end
  return rates
end

function M:drop_equipment( armies, user_id)
  if Tool:random_event_100(self.drop_chance, user_id .. '-drop-equip') then
    return self:get_drop_equipment(armies, user_id)
  else
    return
  end
end

function M:get_drop_items ()
  if self.__drop_items then return self.__drop_items end
  local t = Tool:split(self.item, '-')
  local rate = tonumber(t[1])
  local items = {}
  for i,v in ipairs(Tool:split(t[2], ',')) do
    local items_t = Tool:split(v, ":")
    table.insert(items, {item_id = tonumber(items_t[1]), min = tonumber(items_t[2]), max = tonumber(items_t[3]), rate = tonumber(items_t[4])}) 
  end
  self.__drop_items = {rate = rate, items = items}
  return self.__drop_items
end

function M:get_drop_equipment( armies, user_id)
  local army = armies[1]
  local uid = army._id or army.config_id
  local ci = ConfigMonster:find_by_id(uid)
  local part = ConfigMonsterType:find_by_id(ci.belong):drop_equipment_part(user_id)
  local ce = ConfigEquipment:find_by_level_and_part(self:rand_drop_equipment_level(user_id), part)
  if ce then return ce end
  for k,level in pairs(self:get_drop_equipment_levels()) do
    ce = ConfigEquipment:find_by_level_and_part(level, part)
    if ce then return ce end
  end
  local ces = {}
  for part,rate in pairs(ConfigMonsterType:find_by_id(ci.belong):get_equipment_parts()) do
    for k,level in pairs(self:get_drop_equipment_levels()) do
      ce = ConfigEquipment:find_by_level_and_part(level, tonumber(part))
      if ce then
        table.insert(ces, ce)
      end
    end
  end
  return Tool:rand(ces)
end

function M:rand_drop_equipment_level( user_id )
  log.d('rand_drop_equipment_level')
  local rate = {}
  for k,v in pairs(Tool:split(self.equipment_level, ',')) do
    local t = Tool:split(v, ':')
    rate[tonumber(t[1])] = tonumber(t[2])
  end

  log.d('rand_drop_equipment_level')
  log.dr(rate)
  local ret = Tool:lottery(rate)--, user_id .. "drop-level")
  -- local ret = Tool:lottery(rate, user_id .. "drop-level")
  log.d('rand_drop_equipment_level =  ' .. ret)
  return ret
end

function M:get_drop_equipment_levels(  )
  -- return Tool:map(Tool:split(self.equipment_level, ','), function ( str )
  --   return tonumber(str)
  -- end)
  local levels = {}
  for k,v in pairs(Tool:split(self.equipment_level, ',')) do
    local t = Tool:split(v, ':')
    levels[#levels+1] = tonumber(t[1])
  end
  log.d('--- get_drop_equipment_levels leves --')
  log.dr(levels)
  return levels
end

function M:get_drop_equipment_list(armies)
  local army = armies[1]
  local uid = army._id or army.config_id
  local ci = ConfigMonster:find_by_id(uid)
  log.d('get_drop_equipment_list')
  log.d('uid = ' .. uid)
  log.d('config_id = ' .. army.config_id)
  log.d('ci.belong = ' .. ci.belong)
  local part_list = ConfigMonsterType:find_by_id(ci.belong):get_equipment_parts()
  log.d('the part list')
  log.dr(part_list)
  local equipment_list = {}
  for part, rate in pairs(part_list) do
    for k, level in pairs(self:get_drop_equipment_levels()) do
      log.d(string.format('finding ... level, part = %d, %d', level, part))
      local item = ConfigEquipment:find_by_level_and_part(level, tonumber(part))
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
  for i,v in ipairs(self:get_drop_items().items) do
    table.insert(result, {item_id = v.item_id, amount = v.min})
  end
  return result
end

function M:drop( armies, user_id )
  local i = self:get_drop_items()
  local result = {}
  if Tool:random_event_100(i.rate, user_id .. '-test-drop') then
    for k,v in pairs(i.items) do
      if Tool:random_event_100(v.rate, user_id .. '-drop-item') then
        table.insert(result, {item_id = v.item_id, amount = Tool:rand_range(v.min, v.max)})
        break
      end
    end
  end
  local drop_equip = self:drop_equipment(armies, user_id)
  if drop_equip then
    table.insert(result, {item_id = drop_equip._id, amount = 1})
  end
  local gold = Tool:rand_range(tonumber(self.gold_min), tonumber(self.gold_max))
  if gold > 0 then
    table.insert(result, {item_id = ItemConst.GOLD_ID, amount = gold})
  end
  return result
end

M:load()

return M
