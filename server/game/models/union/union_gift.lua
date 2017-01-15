require "config_league_gifts"
local skynet = require "skynet"

function Union:add_gift(union_id, user_id, gift_id, user_name)
	local union = Union:get_union_by_id(union_id)
	if union == nil then
		return false
	end

	local config = Union:get_gift_config(gift_id)
	if config == nil then
		return false
	end

	if config.items then
		local items = config.items
		local item = items[math.random(1, #items)]
		local gift = {
			uid = Tool:guid(),
			gift_id = gift_id,
			gift_from = user_name,
			contribution = config.contribution,
			items = {
				[1] = {
					uid = item._id,
					amount = item.amount,
				}
			},
			members = {}, 	--未领取gift的user_id
		}
		
		union.gifts = union.gifts or {}
		union.gifts[gift.uid] = gift

		local member_list = Union:get_memeber_list(union_id)
		for i, member_id in ipairs(member_list) do
			if user_id ~= member_id then
				gift.members[member_id] = true
				Union:push_gift_nums(union_id, member_id)
			end
		end

		Union:save(union)
	end

	return true
end

function Union:get_gifts(union, user_id)
	local gifts = {}

	if union and union.gifts then
		for k, gift in pairs(union.gifts) do
			if gift.members[user_id] then
				table.insert(gifts, {
					gift_id = gift.gift_id,
					gift_from = gift.gift_from,
					items = gift.items,
					uid = gift.uid,
					contribution = gift.contribution,
				})
			end
		end
	end

	return gifts
end

function Union:get_gift_num(union_id, user_id)
	local num = 0
	local union = Union:get_union_by_id(union_id)
	if union and union.gifts then
		for k, gift in pairs(union.gifts) do
			if gift.members[user_id] then
				num = num + 1
			end
		end
	end

	return num
end

function Union:remove_gift(union_id, user_id)
	local union = Union:get_union_by_id(union_id)
	if union and union.gifts then
		for k, gift in pairs(union.gifts) do
			if gift.members[user_id] then
				gift.members[user_id] = nil
			end
		end
		--Union:save(union)
	end
end

function Union:collect_gift(union, user_id, gift_id)
	local msg = {}

	if union and union.gifts and gift_id then
		local gift = union.gifts[gift_id]
		if gift and gift.members[user_id] then
			for k, item in pairs(gift.items) do
				game_cmd:exc_user_cmd(user_id, "add_item", item.uid, item.amount)
			end
			Union:add_contribution(union, user_id, gift.contribution)
			local items = game_cmd:exc_user_cmd(user_id, "get_items_info")
			game_cmd:send_user_cmd(user_id, "send_push", items)
			msg.union_gifts = {
				[1] = {
					uid = gift.uid,
					_del = true,
				}
			}

			gift.members[user_id] = nil
			Union:save(union)
			Union:push_gift_nums(union._id, user_id)
		end
	end

	return msg
end

function Union:push_gift_nums(union_id, user_id)
	if skynet.call('watchdog', 'lua', 'is_online', user_id) then
    	game_cmd:send_user_cmd(user_id, "send_push", {
    		union_nums = {
    			gift = Union:get_gift_num(union_id, user_id),
    		}
    	})
    end
end

function Union:get_gift_config(gift_id)
	if self.config_gifts == nil then
		self.config_gifts = {}
		for k, config in pairs(config_league_gifts) do
			local gift = {
				_id = config._id,
				contribution = config.person_contribution,
				honor = config.league_contribution,
				items = {},
			}
			local items = Tool:split(config.items, ",")
			for i = 1, #items do
				local item = Tool:split(items[i], ":")
				table.insert(gift.items, {
					_id = tonumber(item[1]),
					amount = tonumber(item[2]),
				})
			end
			self.config_gifts[gift._id] = gift
		end
	end

	return self.config_gifts[gift_id]
end
