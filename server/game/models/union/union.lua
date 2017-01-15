
Union = {}
Union.union_list = {}

local skynet = require "skynet"
require "config_alliance_func"
require "union_research"
require "union_war_event"
require "union_gamble"
require "union_store"
require "union_gift"

function Union:init_by_db(union_list)
	Union.union_list = union_list
	for k, union in pairs(union_list) do
		for i = 1, 7 do
			union.contributions[tostring(i)] = (union.contributions[i] or union.contributions[tostring(i)]) or {}
			union.contributions[i] = nil
		end

		if union.contributions.donate == nil then
			union.contributions.donate = {
				total = union.contributions.total,
			}
			for i = 1, 7 do
				union.contributions.donate[tostring(i)] = Tool:clone(union.contributions[tostring(i)])
				union.contributions.donate[i] = nil
			end
		end

		if union.items and union.items.store then
			for item_id, v in pairs(union.items.store) do
				if type(v) == "number" then
					local uid = tostring(item_id)
					union.items.store[uid] = {
						item_id = uid,
						amount = v,
					}
				else
					break;
				end
			end
		end

		union.invitation = union.invitation or {}

		--计算might, bp
		if true then	--兼容旧数据
			local ids = {}
			table.insert(ids, union.leader.user_id)
			for k, v in pairs(union.guidmember.members) do
				table.insert(ids, v.user_id)
			end
			local attrs = {might = 1, bp = 1}
			local users = skynet.call('database', 'lua', 'user', 'find_by_ids', ids, attrs)
			-- log.w("=======users = skynet.call")
			-- log.dr(users)
			union.might = 0
			union.bp = 0
			for k, user in pairs(users) do
				union.might = union.might + user.might
				union.bp = union.bp + user.bp
			end

			if union.logo == nil then
				union.logo = UnionConst.RANDOM_LOGO[math.random(1, #UnionConst.RANDOM_LOGO)]
				union.banner = UnionConst.RANDOM_BANNER[math.random(1, #UnionConst.RANDOM_BANNER)]
			end

			Union:save(union)
		end
	end

	return true
end

function Union:add_union(union)
	self.union_list[union._id] = union
	return true
end

function Union:remove_union(union)
	self.union_list[union._id] = nil
	skynet.send('database', 'lua', 'union', 'delete_with_id', union._id, single)
	return true
end

function Union:get_union_list()
	return self.union_list
end

function Union:get_union_by_id(union_id)
	return self.union_list[union_id]
end

function Union:get_union_by_name( name )
	for k,union in pairs(self.union_list) do
		if union_name == name then return union end
	end
end

function Union:is_ally(user_id, another_user_id)
	if user_id == nil or another_user_id == nil
			or string.len(user_id) ~= string.len(another_user_id) then
		return false;
	end

	if user_id == another_user_id then
		return true;
	end

	local user_union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local another_union_id = game_cmd:exc_user_cmd(another_user_id, "get", "union_id")
	if user_union_id == nil or another_union_id == nil then
		return false;
	end
	
	if user_union_id ~= nil and string.len(user_union_id) > 0 and user_union_id == another_union_id then
		return true;
	end

	return false;
end

function Union:create_union(user_id, name, short_name, slogan, verify)
	local union_id = Tool:guid()
	local short_name = "[" .. short_name .. "]"
	local union_researches = {}
 	game_cmd:exc_user_cmd(user_id, "add_union_info", name, union_id, UnionConst.LEADER, short_name, union_researches)

 	local need_info = {"might", "bp", "language"}
 	local user = game_cmd:exc_user_cmd(user_id, "get", need_info)
	local current_time = os.time()
	local union = {
		_id = union_id,
		name = name,
		language = user.language or BasicConst.LANG_EN,
		short_name = short_name,
		slogan = slogan,
		bulletin = '',
		logo = UnionConst.RANDOM_LOGO[math.random(1, #UnionConst.RANDOM_LOGO)],
		banner = UnionConst.RANDOM_BANNER[math.random(1, #UnionConst.RANDOM_BANNER)],
		member_count = 1,
		max_member = config_variable.get('alliance_member'),
		leader = {
			user_id = user_id,
			join_time = current_time,
		},
		might = user.might,
		might_rank = 0,
		bp = user.bp,
		bp_rank = 0,
		verify = verify or 0,
		war_events = {},
		war_history = {},
		guidwar = {},
		guidmember = {
			members = {},
		},
		battlehistory = {},
		gifts = {},
		help = {},
		mail = {},
		items = {
			basic = {},
			store = {},
			allies_store = {},
		},
		notices = { --创建联盟不记录
			-- [1] = {
			-- 	time = current_time,
			-- 	event = UnionConst.NOTICE_CREATE,
			-- 	user_id = user_id,
			-- },
		},
		total_contribution = 0,
		contribution = 0,
		contributions = {
			total = {[user_id] = 0},
			week = {[user_id] = 0},
			last_day_time = current_time - (current_time % (3600 * 24)),
			["1"] = {},
			["2"] = {},
			["3"] = {},
			["4"] = {},
			["5"] = {},
			["6"] = {},
			["7"] = {},
			donate = {	--捐赠统计
				total = {[user_id] = 0},
				["1"] = {},
				["2"] = {},
				["3"] = {},
				["4"] = {},
				["5"] = {},
				["6"] = {},
				["7"] = {},
			},
		},
		tech = {},
		gamble_items = {},
		gamble_times = 0,
		invitation = {},
	}
	game_cmd:exc_wild_cmd("map", "update_union_info", union_id, {
		name = union.name,
		language = union.language,
		short_name = union.short_name,
		logo = union.logo,
		banner = union.banner,
	})
	Union:init_store(union)
	Union:save(union)
	Union:add_union(union)
	game_cmd.Rank.add_union({_id = union._id, might = union.might, bp = union.bp})
	return union
end

function Union:get_union_info_for_mail(union)
	return {
		union_name = union.name,
		s_union_name = union.short_name,
		logo = union.logo,
		banner = union.banner,
		language = union.language,
		members = union.member_count,
		max_members = union.max_member,
		might = union.might,
		leader = game_cmd:exc_user_cmd(union.leader.user_id, "get", "user_name"),
		union_id = union._id,
	}
end

function Union:get_union_detail(union, user_id)
	local union_info = {
		uid = union._id,
		name = union.name,
		short_name = union.short_name,
		might = math.floor(union.might),
		might_rank = skynet.call("rank", "lua", "get_rank", "union_might_rank", union._id),
		bp = union.bp,
		bp_rank = skynet.call("rank", "lua", "get_rank", "union_bp_rank", union._id),
		logo = union.logo,
		banner = union.banner,
		language = union.language,
		member_count = union.member_count,
		max_member = union.max_member,
		leader = union.leader,
		slogan = union.slogan,
		bulletin = union.bulletin,
		notices = {},
		verify = union.verify,
	}
	union_info.leader.name = game_cmd:exc_user_cmd(union.leader.user_id, "get", "user_name")

	for i, notice in ipairs(union.notices or {}) do
		table.insert(union_info.notices, {
			time = notice.time,
			event = notice.event,
			user = game_cmd:exc_user_cmd(notice.user_id, "get", "user_name"),
			manager = notice.manager_id and game_cmd:exc_user_cmd(notice.manager_id, "get", "user_name"),
			item_id = notice.item_id,
			item_num = notice.item_num,
			position = notice.position,
		});
	end

	return union_info
end

function Union:get_union_info(union)
	local info = {
		uid = union._id,
		name = union.name,
		language = union.language,
		short_name = union.short_name,
		slogan = union.slogan,
		logo = union.logo,
		banner = union.banner,
		member_count = union.member_count,
		max_member = union.max_member,
		leader = union.leader,
		might = math.floor(union.might),
		might_rank = skynet.call("rank", "lua", "get_rank", "union_might_rank", union._id),
		bp = union.bp,
		bp_rank = skynet.call("rank", "lua", "get_rank", "union_bp_rank", union._id),
		verify = union.verify,
	}

	info.leader.name = game_cmd:exc_user_cmd(union.leader.user_id, "get", "user_name")
	return info
end

function Union:get_members_info(union)
	local list = {}

	if union then
		for k, member in pairs(union.guidmember.members) do
			list[member.user_id] = Union:get_memeber_info(member)
		end
	end

	return list
end

function Union:get_memeber_info(member)
	local need_info = {"might", "user_name", "head", "last_login_time", "level"}

 	local user = game_cmd:exc_user_cmd(member.user_id, "get", need_info)
	if user then
		return {
			user_id = member.user_id,
			logid = user.head,
			name = user.user_name,
			might = math.floor(user.might),
			online = skynet.call('watchdog', 'lua', 'is_online', member.user_id) and 1 or 0,
			union_pos = member.union_pos,
			last_login_time = user.last_login_time,
			level = user.level,
		}
	end

	return nil
end
function Union:get_memeber_list(union_id)
	local union = Union:get_union_by_id(union_id)
	local list = {}

	if union then
		table.insert(list, union.leader.user_id)
		for k ,v in pairs(union.guidmember.members) do
			table.insert(list, v.user_id)
		end	
	end

	return list
end

function Union:can_add_more_member(union_id)
	local union = Union:get_union_by_id(union_id)
	if union and union.member_count < union.max_member then
		return true
	end

	return false
end

function Union:add_union_event(union, time, user_id, event, manager_id, item_id, item_num, position)
	table.insert(union.notices, {
		time = time,
		user_id = user_id,
		event = event,
		manager_id = manager_id,
		item_id = item_id,
		item_num = item_num,
		position = position,
	});

	while #union.notices > UnionConst.NOTICE_MAX_COUNT do
		table.remove(union.notices, 1);
	end
	return true
end

function Union:save(union)
	if union ~= nil then
        skynet.send('database', 'lua', 'union', 'update_with_id', union._id, union)
    end
    return true
end

function Union:add_might(union_id, inc_might)
	local union = Union:get_union_by_id(union_id)
	if union then
		union.might = math.max(0, math.floor(union.might + inc_might))
		game_cmd.Rank.update_union_might({_id = union._id, might = union.might})
		Union:save(union)
	end
	return true
end

function Union:add_bp(union_id, inc_bp)
	local union = Union:get_union_by_id(union_id)
	if union then
		union.bp = math.max(0, math.floor(union.bp + inc_bp))
		game_cmd.Rank.update_union_bp({_id = union._id, bp = union.bp})
		Union:save(union)
	end
end

function Union:is_invited(union, user_id)
	if union and union.invitation and union.invitation[user_id] then
		return true;
	end

	return false
end

function Union:need_approval_to_join(union, user_id)
	if union and union.verify == 1 and not self:is_invited(union, user_id) then
		return true;
	end

	return false;
end

function Union:add_member(union_id, user_id, position)
	local union = Union:get_union_by_id(union_id)
	if union == nil then
		return "union_not_exist"
	end
	
	local skip_save = true
	Union:remove_invited_user(union_id, user_id, skip_save)

	local need_info = {"bp", "might", "union_id"}
	local user = game_cmd:exc_user_cmd(user_id, "get", 	need_info)
	if user == nil then
		return "user_not_exist"
	end

	if user.union_id ~= "" then
		return "user_joined_union"
	end

	if not Union:can_add_more_member(union_id) then
		return "add_member_max_members"
	end

	if union.guidmember.members[user_id] == nil
			or union.guidmember.members[user_id].union_pos == UnionConst.APPLICATION then
		if position == nil then
			position = UnionConst.MEMBER
		end

		local time = os.time();
		union.guidmember.members[user_id] = {
			user_id		= user_id,
			union_pos 	= position,
			join_time	= time,
		}

		if position ~= UnionConst.APPLICATION then
			union.member_count = union.member_count + 1;
			Union:add_might(union_id, user.might)
			Union:add_bp(union_id, user.bp)
			union.contributions.total[user_id] = union.contributions.total[user_id] or 0
			union.contributions.donate.total[user_id] = union.contributions.donate.total[user_id] or 0
			union.contributions.week[user_id] = union.contributions.week[user_id] or 0
			Union:add_union_event(union, time, user_id, UnionConst.NOTICE_JOIN)
			local union_researches = Union:get_research_levels(union_id)
			-- log.e("----------- union_researches")
			-- log.dr(union_researches)
			-- log.e("----------- union tech")
			-- log.dr(union.tech)
			game_cmd:exc_user_cmd(user_id, "add_union_info", union.name, union._id, position, union.short_name, union_researches)
		end

		Union:save(union)
	end
	return true
end

function Union:remove_invited_user(union_id, user_id, skip_save)
	local union = Union:get_union_by_id(union_id)
	if union and union.invitation and union.invitation[user_id] then
		union.invitation[user_id] = nil
		if not skip_save then
			Union:save(union)
		end
	end
end

function Union:add_contri( union_id, user_id, contri )
	local union = self:get_union_by_id(union_id)
	if union then
		Union:add_contribution(union, user_id, contri)
	end
	return true
end

function Union:get_member_count(union, level)
	local count = 0

	if union == nil then
		return count
	end

	if level == nil then
		return union.member_count
	end

	local list = Union:get_memeber_list(union)
	for i, user_id in ipairs(list) do
		local user_level = game_cmd:exc_user_cmd(user_id, "get", "level")
		if user_level >= level then
			count = count + 1
		end
	end

	return count
end

function Union:user_has_rights(union, user_id, position)
	if union == nil then return false end
	
	if union.leader.user_id == user_id then
		return true
	elseif union.guidmember.members[user_id] then
		return union.guidmember.members[user_id].union_pos <= position
	end

	return false
end

function Union:get_simple_info( union_id )
	local union = Union:get_union_by_id(union_id)
	if not union then return false end
	return true, {
		_id = union_id,
		name = union.name,
		short_name = union.short_name
	}
end

function Union:add_help(union_id, help)
	local union = self:get_union_by_id(union_id)
	if union == nil or union.help == nil then return false end

	union.help[help.uid] = help
	Union:push_help_nums(union_id)
end

function Union:remove_help(union_id, user_id, build_id)
	local union = self:get_union_by_id(union_id)
	if union == nil or union.help == nil then return false end

	for help_id, help in pairs(union.help) do
		if help.user_id == user_id and help.build_id == build_id then
			union.help[help_id] = nil
			Union:save(union)
			Union:push_help_nums(union_id)
			break
		end
	end

	return true
end

function Union:remove_helps(union_id, user_id)
	local union = self:get_union_by_id(union_id)
	if union == nil or union.help == nil then return false end

	for help_id, help in pairs(union.help) do
		if help.user_id == user_id then
			union.help[help_id] = nil
		end
	end

	Union:save(union)
	Union:push_help_nums(union_id)

	return true
end

function Union:add_help_contribution(union_id, user_id, help_times)
	local union = Union:get_union_by_id(union_id)
	if union then
		help_times = help_times or 1
		local contribution = config_variable.get('alliance_help_contribution') * help_times
		return Union:add_contribution(union, user_id, contribution, "help")
	end
end

function Union:get_help_count(union_id, user_id)
	local help_num = 0
	local union = self:get_union_by_id(union_id)
	if union then
		for k, help in pairs(union.help) do
			if help.help_count == 0 then
				union.help[k] = nil
			elseif help.user_id ~= user_id and help.users[user_id] == nil then
				help_num = help_num + 1
			end
		end
	end

	return help_num
end

function Union:push_help_nums(union_id)
	local union = self:get_union_by_id(union_id)
	if union == nil or union.help == nil or next(union.help) == nil then
		return
	end

	local member_list = Union:get_memeber_list(union_id)
	for k, user_id in pairs(member_list) do
		if skynet.call('watchdog', 'lua', 'is_online', user_id) then
        	game_cmd:send_user_cmd(user_id, "send_push", {
				union_nums = {
					help = Union:get_help_count(union_id, user_id),
				}
			})
        end
	end
end

function Union:push_msg_to_union(union_id, msg, excluded)
	local union = self:get_union_by_id(union_id)
	if union then
		local member_list = Union:get_memeber_list(union_id)
		for k, user_id in pairs(member_list) do
			if not (excluded and excluded[user_id])
					and skynet.call('watchdog', 'lua', 'is_online', user_id) then
	        	game_cmd:send_user_cmd(user_id, "send_push", msg)
	        end
		end
	end
end

-- func = function(union_id, user_id)
function Union:push_generated_msg_to_union(union_id, func)
	local union = self:get_union_by_id(union_id)
	if union then
		local member_list = Union:get_memeber_list(union_id)
		for k, user_id in pairs(member_list) do
			if skynet.call('watchdog', 'lua', 'is_online', user_id) then
				local msg = func(union_id, user_id)
	        	game_cmd:send_user_cmd(user_id, "send_push", msg)
	        end
		end
	end
end

function Union:find_by_ids( ids, attrs )
	local result = {}
	for i,id in ipairs(ids) do
		local union = self:get_union_by_id(id)
		if union then
			local info = {}
			info._id = union._id
			for attr,v in pairs(attrs) do
				info[attr] = union[attr]
			end
			table.insert(result, info)
		end
	end
	return result
end

function Union:get_master_name( union_id )
	local union = self:get_union_by_id(union_id)
	return game_cmd:exc_user_cmd(union.leader.user_id, "get","user_name")
end

function Union:find_match_name( name, attrs )
  return skynet.call('database', 'lua', 'union', 'find_match_name', name, attrs)
end

function Union:get_member_level_list(union_id)
	local list = {}
	local union = self:get_union_by_id(union_id)

	table.insert(list, game_cmd:exc_user_cmd(union.leader.user_id, "get", "level"))

	for k, member in pairs(union.guidmember.members) do
		table.insert(list, game_cmd:exc_user_cmd(member.user_id, "get", "level"))
	end

	return list

end

function Union:update_member_union_info(union_id, info)
	if info and next(info) then
		local member_list = Union:get_memeber_list(union_id)
		for k, user_id in pairs(member_list) do
			game_cmd:exc_user_cmd(user_id, "update_union_info", info)
		    if skynet.call('watchdog', 'lua', 'is_online', user_id) then
	    		local push_msg = {
					users = {
						[1] = game_cmd:exc_user_cmd(user_id, "get_union_info"),
					},
				}
		        game_cmd:send_user_cmd(user_id, "send_push", push_msg)
		    end
		end
	end
	return true
end

function Union:validate_name( name )
	if not skynet.call('chat', 'lua', 'is_word_valid', name) then
	  return false
	end
	if string.len(name) < 3 then
	  return false
	elseif string.len(name) > 15 then
	  return false
	end
	return true
end

function Union:get_price(config_id)
	for i, config in ipairs(config_alliance_func) do
		if config._id == tonumber(config_id) then
			return {
				type = BasicConst.CURRENCY.GEM,
				amount = tonumber(config.cost),
			}
		end
	end
end

function Union:push_msg_to_user(user_id, push_msg)
    if skynet.call('watchdog', 'lua', 'is_online', user_id) then
        game_cmd:send_user_cmd(user_id, "send_push", push_msg)
        return true
    end

    return false
end

function Union:can_use_name( name )
	return skynet.call('database', 'lua', 'union', 'update_name', name)
end

function Union:get_union_nums(union_id, user_id)
	local union_nums = {}
	local union = Union:get_union_by_id(union_id)
	if union then
		union_nums.war = Union:get_war_count(union_id)
		union_nums.help = Union:get_help_count(union_id, user_id)
		union_nums.gift = Union:get_gift_num(union_id, user_id)
		union_nums.research = Union:get_ready_upgrade_research_num(union_id, user_id)
	end

	return union_nums
end

function Union:send_system_mail( union_name, mail )
	local union = Union:get_union_by_name(union_name)
	local union_member = Union:get_memeber_list(union._id)
	for k, user_id in pairs(union_member) do
		User:send_mail_by_id(user_id, mail)
	end
	return true
end

function Union:set_union_leader(union_id, user_id)
	local union = Union:get_union_by_id(union_id)
	if union then
		local leader_id = union.leader.user_id
		if leader_id ~= user_id and union.guidmember.members[user_id] then
			local leader_join_time = union.leader.join_time
			local member_join_time = union.guidmember.members[user_id].join_time
			local user_pos = UnionConst.PRIME_MINISTER
			union.guidmember.members[leader_id] = {
				user_id = leader_id,
				union_pos = user_pos,
				join_time = leader_join_time,
			}
			game_cmd:exc_user_cmd(leader_id, "update_union_info", { union_pos = user_pos })
			union.guidmember.members[user_id] = nil
			union.leader.user_id = user_id
			union.leader.join_time = member_join_time
			game_cmd:exc_user_cmd(user_id, "update_union_info", { union_pos = UnionConst.LEADER })
		end
	end
	return true
end

Union:create_effects_funcs()


return Union
