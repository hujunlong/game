
function Union:init_store(union)
	if union == nil or next(union.items.basic) ~= nil then
		return false
	end

	for k, config in pairs(ConfigUnionStore:all()) do
		if config.type == UnionConst.ITEM_BASIC then
			table.insert(union.items.basic, config._id)
		else
			table.insert(union.items.allies_store, config._id)
		end
	end	
	return true
end

function Union:get_store_items(union)
	local items = {}

	if union ~= nil then
		for k, v in pairs(union.items) do
			items[k] = v
		end
	end

	return items
end

function Union:replenish_stock(union, item_id, item_num)
	local config = ConfigUnionStore:find_by_id(item_id)
	if union and config and config.type == UnionConst.ITEM_STORE then
		local price = config.price * item_num
		if price <= union.contribution then
			local store = union.items.store
			local uid = tostring(item_id)
			if store[uid] then
				store[uid].amount = store[uid].amount + item_num
			else
				store[uid] = {
					item_id = uid,
					amount = item_num,
				}
			end
			union.contribution = union.contribution - price
		end
	end
	return true
end

function Union:buy_item(union, user_id, item_id, item_num)
	local config = ConfigUnionStore:find_by_id(item_id)
	if union == nil or user_id == nil or config == nil then
		return
	end

	local price = config.contribution * item_num
	local union_contribution = Union:get_user_contribution(user_id)
	if price > union_contribution then
		return union_contribution
	end

	if config.type == UnionConst.ITEM_STORE then
		local store = union.items.store
		local uid = tostring(item_id)
		store[uid].amount = store[uid].amount - item_num
	end
	
	game_cmd:exc_user_cmd(user_id, "add_item", item_id, item_num)
	return game_cmd:exc_user_cmd(user_id, "use_union_contribution", price)
end
