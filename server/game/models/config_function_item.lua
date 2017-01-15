local UserConst = require 'user_const'

local M = ConfigBase:new()

ConfigFunctionItem = M

M:set_origin(config_function_items)

function M:new( o )
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:used( user, opts )
  opts = opts or {}
  opts.amount = opts.amount or 1
  if self.func == 13 then
    if not user:can_use_use_name(opts.user_name) then return {error = 'repeat_user_name'} end
    user.user_name = opts.user_name
    game_cmd:exc_wild_cmd("map", "update_user_info", user:get_uid(), {name = user.user_name})
    local pos_list = {
      [1] = {x = user.x, y = user.y}
    }
    if user.wild_build then
      for i, camp in pairs(user.wild_build) do
        table.insert(pos_list, {x = camp.x, y = camp.y})
      end
    end
    return nil, { map = game_cmd:exc_wild_cmd("map", "get_map_info", user._id, pos_list) }
  elseif self.func == 14 then
    user.head = opts.head  
  elseif self.func == 32 then
    if user.sex == UserConst.SEX_MALE then
      user.sex = UserConst.SEX_FEMALE
    else
      user.sex = UserConst.SEX_MALE
    end
  elseif self.func == 3 then
    user.desc = opts.desc   
  elseif string.find(self.func, "11:") then
    user.ac = user.ac + tonumber(Tool:split(self.func, ":")[2] * opts.amount)
  elseif string.find(self.func, "23:") then
    local hero = user:find_hero_by_config_id(opts.hero_id)
    if not hero then return end
    hero:add_exp(tonumber(Tool:split(self.func, ":")[2]) * opts.amount)
    return {heroes = {{uid = hero:get_uid(), exp = hero.exp, level = hero.level}}}
  elseif string.find(self.func, "2:") then
    user:repaire_city(tonumber(Tool:split(self.func, ":")[2]) * opts.amount)
    return Tool:merge({user:get_city_info(), user:get_city_broken_info()})
  elseif string.find(self.func, "26:") then
    local t = Tool:split(self.func, ":")
    user:add_item(tonumber(t[2]), tonumber(t[3]) * opts.amount)
    return user:get_items_info()
  elseif string.find(self.func, "4:") then
    local t = Tool:split(self.func, ":")
    user:add_build_queue_time(tonumber(t[2]) * opts.amount)
    return user:get_building_events_info()
  elseif self.func == 6 then --随机迁城
    return game_cmd:exc_wild_cmd("wild", "random_transfer_city", user._id) 
  elseif self.func == 25 then
    user:recover_union_quests()
    return user:get_quests_info()
  elseif string.find(self.func, "35:") then
    user:put_out_fire(tonumber(Tool:split(self.func, ":")[2]) * opts.amount)
    return user:get_city_info()
  elseif string.find(self.func, "36:") then --诡计之雾
    local amount = tonumber(Tool:split(self.func, ":")[2])
    user:add_march_hide(amount)
    return {}
  end
end

function M:get_price(item_id, shop_id)
  local price_typ, price;
  local item = M:find_by_id(tonumber(item_id));
  if item and type(item.shop) == "string" then
    local strs = Tool:split(item.shop, ":")
    if shop_id == nil or shop_id == tonumber(strs[1]) then
      price_typ = tonumber(strs[2])
      price = tonumber(strs[3])
    end
  end

  return price_typ, price;
end


M:load()

return M
