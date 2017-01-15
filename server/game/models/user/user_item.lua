

function User:get_items_info () 
  local items = {}
  for item_id,amount in pairs(self.items) do
    local is_new = true
    if self.item_status[item_id] then
      if self.item_status[item_id] == ItemConst.ITEM_STATUS_NEW then
        is_new = true
      else
        is_new = false
      end
    end
    if item_id and item_id ~= "nil" and amount > 0 then
      table.insert(items, {uid = tonumber(item_id), amount = amount, is_new = is_new})
    end
  end
  return {items = items}
end  

function User:add_item (item_id, amount) 
  if not item_id then return end
  item_id = tostring(item_id)
  amount = amount or 1
  if item_id == tostring(ItemConst.GEM_ID) then
    self:add_gems(amount)
    return
  elseif item_id == tostring(ItemConst.GOLD_ID) then
    self.gold = self.gold + amount
    return
  end
  if not self.items[item_id] then
    self.items[item_id] = 0
  end  
  self.items[item_id] = self.items[item_id] + amount
  self.item_status[item_id] = ItemConst.ITEM_STATUS_NEW
end

function User:add_items( items )
  for k,v in pairs(items) do
    self:add_item(v.item_id, v.amount)
  end

  local msg = self:get_items_info() --wx add for skynet
  local info = self:get_resources_info()
  msg.resources = info.resources

  return msg
end

function User:mark_item_status(item_type)
  for k, v in pairs(self.items) do
    local item_id = tonumber(k)
    if item_type == ItemConst.TYPE_ITEMS then

      if item_id < ItemConst.EQUP_ID_START 
        or item_id > ItemConst.SCROLL_ID_END then
         self.item_status[k] = ItemConst.ITEM_STATUS_READ
      end
    elseif item_type == ItemConst.TYPE_EQUPMENTS then
      if item_id >= ItemConst.EQUP_ID_START 
        and item_id <= ItemConst.EQUP_ID_END then
         self.item_status[k] = ItemConst.ITEM_STATUS_READ
      end
    elseif item_type == ItemConst.TYPE_SCORLL then
      if item_id >= ItemConst.SCROLL_ID_START 
        and item_id <= ItemConst.SCROLL_ID_END then
         self.item_status[k] = ItemConst.ITEM_STATUS_READ
      end
    end
  end
  return true
end

function User:use_item (item_id, amount) 
  item_id = tostring(item_id)
  amount = amount or 1
  self.items[item_id] = self.items[item_id] or 0
  if self.items[item_id] < amount then return false end
  self.items[item_id] = self.items[item_id] - amount
  if amount == 0 then
    self.item_status[item_id] = nil
  end
  return true
end  

function User:use_items (items) 
  for k,v in pairs(items) do
    self:use_item(v.item_id, v.amount)
  end
  return true
end

function User:get_soul (config_hero_id) 
  return self.items[ConfigHero:find_by_id(config_hero_id).soul] or 0
end  

function User:has_item (item_id, amount)
  amount = amount or 1
  item_id = tostring(item_id) 
  if not self.items[item_id] then return false end
  return self.items[item_id] >= amount
end

function User:has_items (items) 
  for k,v in pairs(items) do
    if self:get_item_amount(v.item_id) < v.amount then return false end
  end  
  return true
end  

function User:get_item_amount (item_id)   
  item_id = tostring(item_id)
  return self.items[item_id] or 0
end  

function User:get_up_item_info (items)   
  return {
    items = Tool:map(items, function ( i )
      return {uid = i, amount = self:get_item_amount(i)}
    end)
  }
end    

function User:add_resources (res)
  if res.food then
    self:consume_army_food() --先刷新消耗，再增加粮食，以防表象上粮食减成了负数
  end
  for k,v in pairs(res) do
    self[k] = self[k] + v
  end
  return self:get_resources_info()--wx add for skynet
end

function User:get_updated_resources(res)
  local resources = {}
  for k, v in pairs(res) do
    if v ~= 0 then
      resources[k] = math.floor(self[k])
    end
  end

  return next(resources) and resources or {}
end

function User:has_resources (res)
  if res.food then
    self:consume_army_food() --检测前先刷新消耗
  end
  for k,v in pairs(res) do
    if k == "items" then
      return self:has_items(v)
    else
      if self[k] < v then 
        return false 
      end
    end
  end
  return true
end  

function User:get_real_rob(res)
  local r = {}
  if self:has_resources(res) then
    r = res
  else
    for k,v in pairs(res) do
      r[k] = v
      if self[k] - r[k] < 0 then
        r[k] = self[k]
      end
    end
  end
  return r
end

function User:use_resources (res) 
  for k, v in pairs(res) do
    if k == "gem" then
      self:use_gems(v)
    else
      self[k] = self[k] - v
      if self[k] < 0 then
        self[k] = 0
      end
    end
  end
  -- self:consume_army_food() --has_resources()中刷新粮食消耗
  return self:get_resources_info()
end
  
function User:get_resources_info () 
  local info = {}
  for k,res in pairs(MapConst.RESOURCE.TYPES) do
    info[res] = math.floor(self[res])
  end
  return {resources = info}
end

function User:push_resources_info(consume_army_food)
  if consume_army_food then
    self:consume_army_food()
  end
  self:send_push(self:get_resources_info())
end

function User:get_resources(  )
  return {gold = self.gold, wood = self.wood, stone = self.stone, ore = self.ore, food = self.food}
end 

function User:use_gems (amount)
  if amount < 0 then amount = 0 end 
  if self.gem < amount then return false end
  self.gem = self.gem - amount
  self:add_vip_exp(amount)
  self:push_resources_info()
  return true
end  

function User:add_gems( amount )
  amount = amount or 0
  self.gem = self.gem + amount
  return true
end
function User:has_gems (amount) 
  return self.gem >= amount  
end  

function User:use_currency (price)
  if price.type == BasicConst.CURRENCY.GEM then
    return self:use_gems(price.amount)
  end
  return true
end

function User:has_currency (price) 
  if price.type == BasicConst.CURRENCY.GEM then
    return self:has_gems(price.amount)
  elseif price.type == BasicConst.CURRENCY.UNION_CONTRI then
    return self:has_ucontri(price.amount)  
  elseif price.type == BasicConst.CURRENCY.PERSON_UNION_CONTRI then
    return self:has_pcontri(price.amount)
  else
    return false  
  end
end  
      
function User:send_use_info( t )
  self:send_push({reward = t})
  return true
end

function User:get_total_resource_amount(  )
  return self.wood + self.food + self.gold + self.ore + self.stone
end

function User:time2gems(workType, timeLength)
  if timeLength < 0 then timeLength = 0 end
  local priceTable = config_time_worths2
  if not config_time_worths2.funcs then
    function config_time_worths2.funcs ( )
      if config_time_worths2.__funcs then return config_time_worths2.__funcs end
      config_time_worths2.__funcs = {}
      for k,v in pairs(config_time_worths2[1]) do
        config_time_worths2.__funcs[k] = loadstring("return function (n) return math.ceil("..v..") ; end")()
    end
      return config_time_worths2.__funcs
    end
  end

  local timeInSeconds = tonumber(timeLength)
  return config_time_worths2.funcs()[workType](timeLength)
end
                
function User:use_currency_by_type (type, amount)
  local res = {}
  res[type] = amount
  self:use_resources(res)
  return true
end
    
function User:has_currency_by_type( type, amount )
  local res = {}
  res[type] = amount
  return self:has_resources(res)
end
  
function User:can_use_item( ci )
  if not ci.level_limit then return true end
  return ci.level_limit <= self.level
end

function User:can_buy_item( ci )
  if ci.sub_type == ItemConst.SUB_TYPES.AC then
    return self:get_buy_ac_times() > 0
  end
  return true
end

function User:after_buy_item( ci )
  if ci.sub_type == ItemConst.SUB_TYPES.AC then
    self.buy_ac_times = self.buy_ac_times + 1 
  end
  return self.buy_ac_times
end


function User:convert_res2gems( res )
  local extra = {}
  local consume = {}
  for k,v in pairs(res) do
    if self[k] < v then
      extra[k] = v - self[k]
      consume[k] = self[k]
    else
      consume[k] = v        
    end 
  end
  consume.gem = Tool:ress2gems(extra)
  return consume
end

function User:can_use_gold(  )
  return self.level >= UserConst.OPEN_GOLD_LEVEL_LIMIT
end

function User:can_use_stone( )
  return self.level >= UserConst.OPEN_STONE_LEVEL_LIMIT
end

function User:can_use_ore( )
  return self.level >= UserConst.OPEN_ORE_LEVEL_LIMIT
end

function User:open_chest( chest_id )
  ConfigChestItem:find_by_id(chest_id):used(self)
end

function User:get_buy_ac_times(  )
  return self:get_config_vip().buy_energy_times - self.buy_ac_times
end

function User:get_hour_res( hour )
  local u_buildings = self.buildings
  local res = {}
  for k,v in pairs(u_buildings) do
    if v.get_res_type then
      local res_config = v:get_res_type(v)
      res[res_config.res] = res[res_config.res] or 0
      res[res_config.res] = res[res_config.res] + res_config.income * hour
    end
  end
  return res
end
