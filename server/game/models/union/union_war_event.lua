
function Union:add_war_event(union_id, war_event)
	local union = Union:get_union_by_id(union_id)
	if union then
		union.war_events[war_event.uid] = war_event
		Union:save(union)
		Union:push_war_nums(union_id)
	end
    return true
end

function Union:remove_war_event(e)
    local atk_union_id = game_cmd:exc_user_cmd(e.user_id, "get", "union_id")
	local attacker_union = Union:get_union_by_id(atk_union_id)
	if attacker_union and attacker_union.war_events[e._id] then
		attacker_union.war_events[e._id] = nil
		Union:save(attacker_union)
		Union:push_war_nums(atk_union_id)
	end

	if e.def_uid and string.len(e.def_uid) ~= 5 then 	-- 怪物id长度为5
		local def_union_id = game_cmd:exc_user_cmd(e.def_uid, "get", "union_id")
		local defender_union = Union:get_union_by_id(def_union_id)
		if defender_union and defender_union.war_events[e._id] then
			defender_union.war_events[e._id] = nil
			Union:save(defender_union)
			Union:push_war_nums(def_union_id)
		end
	end
    return true
end

function Union:get_war_list(union_id)
	local union = Union:get_union_by_id(union_id)
	if union then
		return union.war_events
	end
    return {}
end

function Union:add_war_event_to_union(e)
	if e.def_uid == nil
			or (string.len(e.def_uid) == 5 and e.action == WildConst.MARCH_ATTACK) --普通怪
			then
		return false
	end

	if Union:is_ally(e.user_id, e.def_uid) then
		return false
	end
    
    local info = {"user_name", "head", "union_id", "level"}
    local attacker = game_cmd:exc_user_cmd(e.user_id, "get", info)
	if attacker == nil then
		return false
	end

	local war_event = {
		uid 		= e._id,
		atk_name 	= attacker.user_name,
        atk_pos 	= e.from_pos,
        atk_log_id 	= attacker.head,
        def_pos 	= e.to_pos,
        start_time 	= e.start_time,
        end_time 	= e.finish_time,
        is_march 	= e.action == WildConst.MARCH_RALLY_MARCH,
	}

	local defender = nil
	if e.def_uid then
		if string.len(e.def_uid) == 5 then	--如果是怪物
			war_event.def_log_id = tonumber(e.def_uid)
		else
		    defender = game_cmd:exc_user_cmd(e.def_uid, "get", info)
	        war_event.def_log_id = defender.head
	        war_event.def_name = defender.user_name
	        war_event.def_level = defender.level
		end
	end

	if e.action == WildConst.MARCH_RALLY_MARCH then
	    local members = {
	        [1] = {
	        	user_id = e.user_id,
	            logid = attacker.head,
	            name = attacker.user_name,
	        },
	    }

	    for user_id, v in pairs(e.rallyer_list) do
	        if user_id == e.user_id then
	            members[1].armies = v.armies
	        else
	            local member = game_cmd:exc_user_cmd(user_id, "get", info)
	            if member then
	                table.insert(members, {
	                    logid = member.head,
	                    name = member.user_name,
	                    armies = v.armies,
	                    user_id = user_id,
	                })
	            end
	        end
	    end

	    war_event.atk_member = members
	end

	war_event.is_atker = 1
	Union:add_war_event(attacker.union_id, war_event)

	if e.action ~= WildConst.MARCH_RALLY_WAITING and defender then	-- 集结等待防守方不可见
		local defender_war_event = Tool:clone(war_event)
		defender_war_event.is_atker = 0
		Union:add_war_event(defender.union_id, defender_war_event)
	end
    return true
end

function Union:add_war_history(attacker_id, from_pos, defender_id, to_pos, is_win)
	local info = {"user_name", "union_id"}
	local attacker = game_cmd:exc_user_cmd(attacker_id, "get", info)
	local defender = game_cmd:exc_user_cmd(defender_id, "get", info)
	local history = {
		time = os.time(),
        is_atk_win = is_win and 1 or 0,
        atk_name = attacker.user_name,
        atk_union = attacker.union_id,
        atk_pos  = {
            x = from_pos.x,
            y = from_pos.y
        },
        def_name = defender.user_name,
        def_union = defender.union_id,
        def_pos  = {
            x = to_pos.x,
            y = to_pos.y
        },
    }

    local HISTORY_LENGTH = 20
	local attacker_union = Union:get_union_by_id(attacker.union_id)
	if attacker_union then
		attacker_union.war_history = attacker_union.war_history or {}
		table.insert(attacker_union.war_history, history)
		while #attacker_union.war_history > HISTORY_LENGTH do
			table.remove(attacker_union.war_history, 1)
		end
		Union:save(attacker_union)
 	end

 	local defender_union = Union:get_union_by_id(defender.union_id)
 	if defender_union then
 		defender_union.war_history = defender_union.war_history or {}
 		table.insert(defender_union.war_history, history)
 		while #defender_union.war_history > HISTORY_LENGTH do
			table.remove(defender_union.war_history, 1)
		end
 		Union:save(defender_union)
 	end
    return true
end

function Union:get_war_history(union_id)
	local union = Union:get_union_by_id(union_id)
	if union then
		union.war_history = union.war_history or {}
		return union.war_history;
	end
    return {}
end

function Union:update_rally_wait(tile, event_id)
	local user = tile.owner_id
	if user == nil then
		return false
	end

    local union_id = game_cmd:exc_user_cmd(user, "get", "union_id")
    local atk_war_events = Union:get_war_list(union_id)

    if atk_war_events and atk_war_events[event_id] then
		local members = game_cmd:exc_wild_cmd("wild", "get_attack_members", tile)
    	atk_war_events[event_id].atk_member = members
    end
    return true
end

function Union:get_rally_detail(union_id, event_id)
	local detail = {}
	local war_events = Union:get_war_list(union_id)

	if war_events and war_events[event_id] then
		for k, v in pairs(war_events[event_id]) do
			if k == 'uid' then
				detail.event_id = v
			elseif k == 'def_pos' then
				detail[k] = v
				local tile = game_cmd:exc_wild_cmd("map", "get_tile_by_xy", v.x, v.y)
				if tile then
					detail.target = {
						dec = tile.category,
						level = tile.level,
					}
				end
			else
				detail[k] = v
			end
		end

		local event = game_cmd:exc_event_cmd("get", event_id)
		if event then
			local hero = event.user_id and game_cmd:exc_user_cmd(event.user_id, "find_hero_by_config_id", event.hero_id)
			if hero then
				detail.hero = {
					uid = hero.config_id,
					quality = hero.quality,
					level = hero.level,
					star = hero.star,
				}
    		end

			detail.action = event.action
			detail.max_amount = game_cmd:exc_user_cmd(event.user_id, "get_max_rally_armies_amount")
		end
	end

	return detail
end

function Union:get_war_count(union_id)
	local war_events = Union:get_war_list(union_id)
	local war_nums = 0
	if war_events then
		for k, v in pairs(war_events) do
			war_nums = war_nums + 1
		end
	end

	return war_nums
end

function Union:push_war_nums(union_id)
	local war_nums = Union:get_war_count(union_id)
	local member_list = Union:get_memeber_list(union_id)
	local push_msg = {
		union_nums = {
			war = war_nums,
		}
	}
	for k, user_id in pairs(member_list) do
		Union:push_msg_to_user(user_id, push_msg)
	end
end

