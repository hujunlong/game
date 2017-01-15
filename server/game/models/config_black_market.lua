local M = ConfigBase:new()

ConfigBlackMarket = M

M:set_origin(config_black_markets)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:get_items(  )
  if self.__items then return self.__items end
  self.__items = Tool:map(Tool:split(self.goods, ','), function ( str )
    local t = Tool:split(str, ':')
    return {
      item_id = tonumber(t[1]),
      amount = tonumber(t[2])
    }
  end) 
  return self.__items
end

function M:rand_item( user )
  local level = user.level
  local items = {}
  if level then
    for k,v in pairs(self:get_items()) do
      if ConfigItem:find_by_id(v.item_id) and level >= (ConfigItem:find_by_id(v.item_id).level_limit or 0) then
        table.insert(items, v)
      end
    end
  else
    items = self:get_items()
  end
  local item = Tool:rand(items)
  if not item then return end
  local result = {item_id = item.item_id, amount = item.amount}
  local ci = ConfigItem:find_by_id(result.item_id)  
  local ct = self:rand_currency_type(user, ci.resource)
  result.price_t = ct
  local sale = self:rand_sale()
  if ct == ItemConst.CURRENCY.GEM then
    result.price_a = math.ceil(ci.black_market_price * sale / 100 * item.amount)
  else
    result.price_a = math.ceil((ci.gold_price or 0) * sale / 100 * item.amount * config_resource_worths[1][ct] / config_resource_worths[1].gold)
  end
  result.best = (sale == self.best_percent)
  return result
end

function M:rand_currency_type( user, except )
  local types = Tool:clone(self:get_currency_types())
  if not user:can_use_gold() then
    types.gold = nil
  end
  if not user:can_use_ore() then
    types.ore = nil
  end
  if not user:can_use_stone() then
    types.stone = nil
  end
  if except then
    types[except] = nil
  end
  return Tool:gamble(types)
end

function M:get_currency_types(  )
  if self.__currency_types then return self.__currency_types end
  self.__currency_types = {}
  for k,v in pairs(Tool:split(self.currency_type, ',')) do
     local t = Tool:split(v, ':')
     self.__currency_types[t[1]] = tonumber(t[2])
  end 
  return self.__currency_types
end

function M:rand_sale(  )
  return tonumber(Tool:rand(Tool:split(self.percent, ','))) 
end

function M:rand( user )
  local result = {}
  Tool:map(self:sall(), function ( r )
    local item = r:rand_item(user)
    if item then
      table.insert(result, {
        item_id = item.item_id, 
        price_a = item.price_a, 
        price_t = item.price_t, 
        amount = item.amount, 
        currency_type = r.currency_type, 
        best = item.best,
        get = false
      })
    end      
  end)
  return result
end

M:load()

return M
