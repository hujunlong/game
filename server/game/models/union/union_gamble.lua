

function Union:get_gamble_info( user )
  local union = Union:get_union_by_id(user.union_id)
  return {
    union_gamble = {
      items = union.gamble_items
    }
  }  
end

function Union:refresh_gamble_items(user)
  local union = Union:get_union_by_id(user.union_id)
  local index = 0
  for k,r in pairs(ConfigGamblingPrize:get_union()) do
    local items = r:get_items()
    for i=1,r.prizes_quantity do
      index = index + 1
      table.insert(union.gamble_items, {index = index, level = r.level, item = Tool:rand(items), get = false})
    end
  end
  Tool:shuffle_t(union.gamble_items)
  return union.gamble_items
end

function Union:next_gamble_coins( user )
  local union = Union:get_union_by_id(user.union_id)
  return ConfigGambling:get_union():get_coins_by_times(union.gamble_times + 1)
end

function Union:rand_gamble_level( user  )
  local union = Union:get_union_by_id(user.union_id)
  local types = {}
  for k,v in pairs(union.gamble_items) do
    if not v.get then
      types[v.level] = true
    end
  end
  for k,v in pairs(types) do
    types[k] = ConfigGamblingPrize:find_by_union_level(k).chance
  end
  return Tool:gamble(types)
end

function Union:gamble( user )
  local union = Union:get_union_by_id(user.union_id)
  local coins = union:next_gamble_coins()
  if not coins then return false end
  if not user:has_union_gamble_coins(coins) then return false end
  user:use_union_gamble_coins(coins)
  local level = union:rand_gamble_level()
  local prizes = Tool:select(union.gamble_items, function ( r )
    return r.level == level
  end)
  local prize = Tool:rand(prizes)
  prize.get = true
  user:add_item(prize.item, prize.amount)
  union.total_gamble_times = union.total_gamble_times + 1
  return prize
end

