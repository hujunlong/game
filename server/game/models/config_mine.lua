local M = ConfigBase:new()

ConfigMine = M

M:set_origin(config_mines)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:load()
  self.__records = {}
  for k, v in ipairs(self:get_origin()) do
    self.__records[v.type] = self.__records[v.type] or {}
    self.__records[v.type][v.level] = self:new(v)
  end
end

function M:find_by_level_and_type (level, type)
  if self.__records[type] and self.__records[type][level] then
    return self.__records[type][level]
  end
end

function M:get_drop_items()
  if self.__drop_items then return self.__drop_items end
  local t = Tool:split(self.item, '-')
  local rate = tonumber(t[1])
  local items = {}
  for i,v in ipairs(Tool:split(t[2], ',')) do
    local items_t = Tool:split(v, ":")
    table.insert(items, {
      item_id = tonumber(items_t[1]),
      min = tonumber(items_t[2]),
      max = tonumber(items_t[3]),
      rate = tonumber(items_t[4]),
    }) 
  end
  self.__drop_items = {rate = rate, items = items}
  return self.__drop_items
end

function M:get_drop_equips()
  if self.__drop_equips then return self.__drop_equips end
  local t = Tool:split(self.drop_chance, '-')
  local rate = tonumber(t[1])
  local items = {}
  for i,v in ipairs(Tool:split(t[2], ',')) do
    local items_t = Tool:split(v, ":")
    table.insert(items, {
      level = tonumber(items_t[1]),
      rate = tonumber(items_t[2]),
    }) 
  end
  self.__drop_equips = {rate = rate, items = items}
  return self.__drop_equips
end

function M:get_drop_item(drop_res)
  if Tool:random_event_100(drop_res.rate) then
    for k, v in pairs(drop_res.items) do
      if Tool:random_event_100(v.rate) then
        return v
      end
    end
  end

  return nil
end

function M:drop()
  local result = {}

  local drop_items = self:get_drop_items()
  local item = M:get_drop_item(drop_items)
  if item then
    table.insert(result, {
      item_id = item.item_id,
      amount = math.random(item.min, item.max),
    })
    return result --掉了物品就不掉装备
  end
  
  local drop_equips = self:get_drop_equips()
  local equip = M:get_drop_item(drop_equips)
  if equip then
    local item_id = ConfigEquipment:get_random_id_by_level(equip.level)
    if item_id then
      table.insert(result, {
        item_id = item_id,
        amount = 1,
      })
    end
  end

  return result
end

M:load()

return M