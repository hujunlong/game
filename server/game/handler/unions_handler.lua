require "tool"
require "config_alliacne_shop"
require "union"
local handler = require "handler"
local skynet = require "skynet"
local ip_config = require('ip_config')
local class = class or require "class"
local m = class("unions_handler", handler)

function m:create_alliance(params)
	local name = params.msg.name
	local short_name = params.msg.short_name
	local slogan = params.msg.slogan
	local verify = params.msg.verify
	local user = params.current_user_id
	if not Union:validate_name(name) then return self:error_code('invalid_union_name') end
	if not Union:validate_name(short_name) then return self:error_code('invalid_union_short_name') end
	if not Union:can_use_name(name) then return self:error_code('repeated_name') end
	local union = Union:create_union(user, name, short_name, slogan, verify)

	local msg = {
		users = {
			[1] = game_cmd:exc_user_cmd(user, "get_union_info"),
		},
		resources = game_cmd:exc_user_cmd(user, "get_updated_resources", {gem = 1}),
	}

	return self:render(msg)
end

function m:dismiss_alliances(params)
	local user = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user, "get", "union_id")
	local union  = Union:get_union_by_id(union_id)
	if not union then
		return self:error_code('union_not_exist')
	end

	if union.leader.user_id ~= user then
		return self:error_code('dismiss_no_rights')
	end

	if Union:get_member_count(union) > 1 then
		return self:error_code('cannot_disband_union')
	end

	Union:remove_union(union)
	game_cmd:exc_user_cmd(user, "exit_unions")
	-- 有盟友时不能解散联盟
	-- for k, v in pairs(union.guidmember.members) do
	-- 	game_cmd:exc_user_cmd(v.user_id, "exit_unions")
	-- 	local info = {
	-- 		uid = v.user_id,
	-- 		union_id = "",
	-- 		union_name = "",
	-- 		s_union_name = "",
	-- 		union_pos = 0,
	-- 	}
	-- 	local push_msg = {
	-- 		users = {
	-- 			[1] = info,
	-- 		},
	-- 		has_uhelp = false,
	-- 	};
	-- 	self:push_msg_to_user(v.user_id, push_msg)
	-- end
	
	local msg = {
		users = {
			[1] = {
				uid = user,
				union_id = "",
				union_name = "",
				s_union_name = "",
				union_pos = 0,
			},
		},
		has_uhelp = false,
	};
	return self:render(msg)
end

function m:get_alliances(params)
	local msg = {
		unions = {},
	}

	for union_id, union in pairs(Union:get_union_list()) do
		msg.unions[union_id] = Union:get_union_info(union)
	end

	return self:render(msg)
end

function m:search_alliance_by_name(params)
	local name = params.msg.name 
	local unions = {}
	for k,v in pairs(Union:get_union_list()) do
		if string.find(string.lower(v.name),string.lower(name))~=nil then
			unions[v._id] = Union:get_union_info(v)
		end
	end

	local msg = {
		unions = unions,
	}

	return self:render(msg)
end

function m:get_alliances_by_id(params)
	local union_id = params.msg.union_id
	local union = Union:get_union_by_id(union_id)
	if union == nil then
		return self:error_code('union_not_exist')
	end

	local msg = {
		unions = {
			[union_id] = Union:get_union_info(union),
		}
	}

	return self:render(msg)
end

function m:change_alliance(params)
	local type = params.msg.type
	local value = params.msg.value
	local user = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	local info = {
		uid = union_id,
	}
 
	if union ~= nil then 
		if type == UnionConst.LEAGUE_CHANGE_SLOGAN then
			if not Union:user_has_rights(union, user, UnionConst.POS_EDIT_SLOGAN) then
				return self:error_code('edit_slogan_no_rights')
			end

			local slogan = string.gsub(value, "%s*$", "")	--去末尾空白
			if string.len(slogan) > UnionConst.SLOGAN_LENGTH_MAX then
				return self:error_code('slogan_too_long')
			end
			
			union.slogan = slogan
			info.slogan  = slogan
		elseif type == UnionConst.LEAGUE_CHANGE_RECRUIT then
			if not Union:user_has_rights(union, user, UnionConst.POS_EDIT_RECRUITMENT) then
				return self:error_code('edit_recruitment_no_rights')
			end
			union.verify = tonumber(value)
			info.verify  = union.verify
			--print("verify" .. v.verify)
		elseif type == UnionConst.LEAGUE_CHANGE_NAME then
			if not Union:user_has_rights(union, user, UnionConst.POS_CHANGE_NAME) then
				return self:error_code('change_name_no_rights')
			end

            local name = string.gsub(value, "%s", "")
            if string.len(name) < UnionConst.NAME_LENGTH_MIN then
            	return self:error_code('name_too_short')
            elseif string.len(name) > UnionConst.NAME_LENGTH_MAX then
            	return self:error_code('name_too_long')
            end

			local price = Union:get_price(2101)
			local has_enough_currency = game_cmd:exc_user_cmd(user, "use_currency", price)
			if not has_enough_currency then
        return self:error_price(price)
      end

			union.name = name
			info.name  = name
			Union:update_member_union_info(union_id, {union_name = name})
			game_cmd:exc_wild_cmd("map", "update_union_info", union_id, {name = union.name})
		elseif type == UnionConst.LEAGUE_CHANGE_NICKNAME then
			if not Union:user_has_rights(union, user, UnionConst.POS_CHANGE_NAME) then
				return self:error_code('change_name_no_rights')
			end

			local name = string.gsub(value, "%s", "")
            if string.len(name) ~= UnionConst.SHORT_NAME_LENGTH then
            	return self:error_code('invalid_name')
            end

			local price = Union:get_price(2102)
			local has_enough_currency = game_cmd:exc_user_cmd(user, "use_currency", price)
			if not has_enough_currency then
        return self:error_price(price) 
      end

			union.short_name = name
			info.short_name  = name
			Union:update_member_union_info(union_id, {s_union_name = name})
			game_cmd:exc_wild_cmd("map", "update_union_info", union_id, {short_name = union.short_name})
		elseif type == UnionConst.LEAGUE_CHANGE_LANGUAGE then
			if not Union:user_has_rights(union, user, UnionConst.POS_EDIT_LANGUAGE) then
				return self:error_code('edit_language_no_rights')
			end
			union.language = tonumber(value)
			info.language  = union.language
			game_cmd:exc_wild_cmd("map", "update_union_info", union_id, {language = union.language})
		elseif type == UnionConst.LEAGUE_CHANGE_BANNER then
			if not Union:user_has_rights(union, user, UnionConst.POS_EDIT_BANNER) then
				return self:error_code('edit_banner_no_rights')
			end
			local price = Union:get_price(2103)
			local has_enough_currency = game_cmd:exc_user_cmd(user, "use_currency", price)
			if not has_enough_currency then
        return self:error_price(price) 
      end
            local args = Tool:split(value, ',')
            union.logo = tonumber(args[1])
			union.banner = tonumber(args[2])
			info.banner  = union.banner
			info.logo = union.logo
			local updated_info = {banner = union.banner, logo = union.logo}
			Union:update_member_union_info(union_id, updated_info)
			game_cmd:exc_wild_cmd("map", "update_union_info", union_id, updated_info)
		elseif type == UnionConst.LEAGUE_CHANGE_ANNOUNCEMENT then
			if not Union:user_has_rights(union, user, UnionConst.POS_EDIT_ANNOUNCEMENT) then
				return self:error_code('edit_announcement_no_rights')
			end

			local announcement = string.gsub(value, "%s*$", "")	--去末尾空白
			if string.len(announcement) > UnionConst.ANNOUNCEMENT_LENGTH_MAX then
				return self:error_code('announcement_too_long')
			end

			union.bulletin = announcement
			info.bulletin  = announcement
		end

		Union:save(union)
	end

	local msg = {
		unions = {
			[1] = info,
		},
	    resources = {
            gem = game_cmd:exc_user_cmd(user, "get", "gem"),
        },
	}

	return self:render(msg)
end

function m:exit_unions(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)

	if union and union.guidmember.members[user_id] then
		union.guidmember.members[user_id] = nil
		union.member_count = union.member_count - 1
		local user = game_cmd:exc_user_cmd(user_id, "get", {"might", "bp"})
		Union:add_might(union_id, -user.might)
		Union:add_bp(union_id, -user.bp)
		Union:add_union_event(union, os.time(), user_id, UnionConst.NOTICE_QUIT)
		Union:remove_gift(union_id, user_id)
		Union:remove_helps(union_id, user_id)
		Union:save(union)
	end
	game_cmd:exc_user_cmd(user_id, "exit_unions")
	local msg = {
		users = {
			[1] = {
				uid = user_id,
				union_id = "",
				union_name = "",
				s_union_name = "",
				union_pos = 0,
			},
		},
		has_uhelp = false,
	}

	return self:render(msg)
end

function m:get_self_union_info(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	local msg = nil

	if union == nil then
		msg = {
			unions = {},
			users = {
				[1] = {
					uid = user,
					union_id = "",
					union_name = "",
					s_union_name = "",
					union_pos = 0,
				},
			},
		}
	else
		msg = {
			unions = {
				[union._id] = Union:get_union_detail(union, user_id),
			},
		}
	end

	return self:render(msg)
end

function m:get_guid_wars(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local msg = {
		guidwar = Union:get_war_list(union_id),
	}
	
	return self:render(msg)
end

function m:get_rally_detail(params)
	local event_id = params.msg.uid
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local msg = {
		rally_detail = Union:get_rally_detail(union_id, event_id),
	}
	
	return self:render(msg)
end

function m:get_rally_limit(params)
	local event_id = params.msg.uid
	local user_id = params.current_user_id
	local event = game_cmd:exc_event_cmd("get", event_id)
	if event == nil then
		return self:error_code("event_not_exist")
	end

	local ally_id = event.user_id
	local msg = {
		rally_limit = {
			amount = game_cmd:exc_user_cmd(ally_id, "get_max_rally_armies_amount"),
			players = game_cmd:exc_user_cmd(ally_id, "get_max_rally_players"),
		}
	}

	return self:render(msg)
end

function m:get_battle_history(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local msg = {
		battlehistory = Union:get_war_history(union_id),
	}
	
	return self:render(msg)
end

function m:get_alllance_gift(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	
	if union == nil then
		return self:error_code('union_not_exist')
	end
  		
	local msg = {
		union_gifts = Union:get_gifts(union, user_id),
	}

	return self:render(msg)
end

function m:collect_union_gift(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	
	if union == nil then
		return self:error_code('union_not_exist')
	end
  	
  	local gift_id = params.msg.uid
	local msg = Union:collect_gift(union, user_id, gift_id)
	if msg.error_code then
		return self:error_code(msg.error_code)
	end

	return self:render(msg)
end

function m:request_alllance_help(params)
	local user_id = params.current_user_id
	local need_info = {"union_id", "head", "user_name"}
	local user = game_cmd:exc_user_cmd(user_id, "get", need_info)
	local union_id = user.union_id
	local union = Union:get_union_by_id(union_id)
	if not union then return self:error_code('union_not_exist') end
	local building_id = params.msg.building_id
  	local building = game_cmd:exc_user_cmd(user_id, "find_building_by_id", building_id)
  	if not building then return self:error_code('building_not_exist') end

	local ret = game_cmd:exc_user_cmd(user_id, "building_send_help", building_id)
	local help = ret.help
	Union:add_help(user.union_id, help)
	Union:save(union)
	self:send_all(user.union_id, {has_uhelp = true}, {[user_id] = true})
	return self:render({buildings = {ret.building_info}})
end

function m:has_help( user_id, user_union_id)
	local union = Union:get_union_by_id(user_union_id)
	if not union then return false end
	local help = Tool:find(union.help, function ( t )
		if t.user_id ~= user_id then
			if t.users then
				return not t.users[user_id]
			end
		end
		return false
	end)

	if help then
		return true
	else
		return false
	end
end

function m:help_other(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	if not union then return self:error('union_not_exist') end
	local help_id = params.msg.help_id
	local help = union.help[help_id]
	if not help then return self:error_code('not_the_help') end
	if help.users[user_id] then return self:error_code('you_helped') end
	local other = help.user_id
	if not other then return self:error_code('user_not_exist') end
	local building_id = help.build_id
	local building = game_cmd:exc_user_cmd(help.user_id, "find_building_by_id", building_id)
	if not building then return self:error_code('building_not_exist') end
	local add_contribution = nil
	
	if building.help_times > 0 then
		add_contribution = Union:add_help_contribution(union_id, user_id, 1)
		help.users[user_id] = true
		help.helped = help.helped + 1

		local can_help = game_cmd:exc_user_cmd(help.user_id, "building_receive_help", building_id)
		if not can_help then
			Union:remove_help(union_id, user_id, building_id)
		end
		Union:save(union)

		local push_msg = {
			helped_me = {
				helper = game_cmd:exc_user_cmd(user_id, "get", "user_name"),
				help_type = help.help_type,
				build_type = help.build_type,
				build_level = help.build_level,
			},
		};
		self:push_msg_to_user(help.user_id, push_msg)
	end

	local help_num = Union:get_help_count(union_id, user_id)
	self:push_msg_to_user(user_id, {
		union_nums = {
			help = help_num,
		},
	})

	local help_contribution = game_cmd:exc_user_cmd(user_id, "get_daily_help_contribution_info")
	help_contribution.add = add_contribution
	return self:render({
		has_uhelp = help_num > 0,
		help = {
			{
				uid = help.uid,
				_del = true,
			},
		},
		help_contribution = help_contribution,
	})
end

function m:help_all( params )
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	if not union then return self:error_code('union_not_exist') end

	local list = nil
	if params.msg and params.msg.list then
		list = {}
		for i, help_id in pairs(params.msg.list) do
			list[help_id] = true
		end
	end
	
	local push_msg = {
		helped_me = {
			helper = game_cmd:exc_user_cmd(user_id, "get", "user_name"),
		},
	}
	
	local info = {}
	local help_num = 0
	local help_times = 0
	for uid, help in pairs(union.help) do
		if list == nil or list[uid] then
			info[uid] = {
				uid = uid,
				_del = true,
			}

			if help.user_id ~= user_id and not help.users[user_id] then
				local building_id = help.build_id
				local building = game_cmd:exc_user_cmd(help.user_id, "find_building_by_id", building_id)
				if building and building.help_times > 0 then
					help_times = help_times + 1
					help.users[user_id] = true
					local can_help = game_cmd:exc_user_cmd(help.user_id, "building_receive_help", building_id)
					if not can_help then
						union.help[uid] = nil
					end

					push_msg.helped_me.help_type = help.help_type
					push_msg.helped_me.build_type = help.build_type
					push_msg.helped_me.build_level = help.build_level
					self:push_msg_to_user(help.user_id, push_msg)
				else
					union.help[uid] = nil --清除残留的错误数据
				end		
			end
		elseif help.user_id ~= user_id and not help.users[user_id] then
			help_num = help_num + 1
		end
	end

	local add_contribution = nil
	if help_times > 0 then
		add_contribution = Union:add_help_contribution(union_id, user_id, help_times)
	end
	Union:save(union)

	self:push_msg_to_user(user_id, {
		union_nums = {
			help = help_num,
		},
	})
	
	local help_contribution = game_cmd:exc_user_cmd(user_id, "get_daily_help_contribution_info")
	help_contribution.add = add_contribution
	local msg = {
		has_uhelp = help_num > 0,
		help = info,
		help_contribution = help_contribution,
	}
	return self:render(msg)
end

function m:send_all(union_id, t, excceed)
	local union = Union:get_union_by_id(union_id)
	if	union then
		for k, user_id in pairs(Union:get_memeber_list(union_id)) do
			if type(excceed) ~= 'table' or not excceed[user_id] then
				self:push_msg_to_user(user_id, t)
			end
		end
	end
	return true
end


function m:get_alllance_help(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	local info = {}
	
	if union ~= nil then
		local help_list = {}
		for uid, help in pairs(union.help) do
			if help.user_id ~= user_id
					and (help.users == nil or help.users[user_id] == nil) then
				help_list[uid] = {
					build_id = help.build_id,
					build_level = help.build_level,
					help_type = help.help_type,
					logid = game_cmd:exc_user_cmd(help.user_id, "get", "head"),
					help_count = help.help_count,
					uid = help.uid,
					build_type = help.build_type,
					user_id = help.user_id,
					name = game_cmd:exc_user_cmd(help.user_id, "get", "user_name"),
					helped = help.helped,
				}
			end
		end

		info.help = help_list
		info.help_contribution = game_cmd:exc_user_cmd(user_id, "get_daily_help_contribution_info")
	end

	return self:render(info)
end

function m:get_alllance_store(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	Union:init_store(union)

	local items = Union:get_store_items(union)
	items.my_coin = Union:get_user_contribution(user_id)
	items.my_contribution = Union:get_user_total_contribution(user_id)
	items.union_coin = Union:get_contribution(union_id)
	items.total_contribution = Union:get_total_contribution(union_id)
	
	local info = {
		union_items = items,
		member_levels = Union:get_member_level_list(union_id),
	}
	return self:render(info)

end

function m:union_replenish_stock(params)
	local id = params.msg.id
	local num = params.msg.num 
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	local config = ConfigUnionStore:find_by_id(id)
	if union == nil or config == nil or not config:can_replenish_stock(union) then
		return self:error_code('cannot_buy_item')
	end

	if not Union:user_has_rights(union, user_id, UnionConst.POS_BUY_ITEMS) then
		return self:error_code('buy_item_no_rights')
	end

	local price = config.price * num
	if price > union.contribution then
		return self:error_code('not_enough_contribution')
	end

	Union:replenish_stock(union, id, num)
	Union:save(union)
	Union:add_union_event(union, os.time(), user_id, UnionConst.NOTICE_RESTOCK, nil, id, num)

	local info = {
		union_items = {
			store = union.items.store,
			union_coin = Union:get_contribution(union_id),
			total_contribution = Union:get_total_contribution(union_id),
		},
		member_levels = Union:get_member_level_list(union_id),
	}

	return self:render(info)
end

function m:buy_alllance_item(params)
	local   id = params.msg.id
	local	num = params.msg.num 
	
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	local config = ConfigUnionStore:find_by_id(id)
	if union == nil or config == nil then
		return self:error_code('item_not_exist')
	end

	if config.type == UnionConst.ITEM_STORE then
		local key = tostring(id)
		if union.items.store[key] == nil or union.items.store[key].amount < num then
			return self:error_code('not_enough_item')
		end
	end

	local price = config.contribution * num
	local union_contribution = Union:get_user_contribution(user_id)
	if price > union_contribution then
		return self:error_code('not_enough_contribution')
	end

	union_contribution = Union:buy_item(union, user_id, id, num)
	Union:save(union)

	local info = {
		union_items = {
			store = union.items.store,
			my_coin = union_contribution,
		},
		items = {
			[1] = {
				uid = id,
				amount = game_cmd:exc_user_cmd(user_id, "get_item_amount", id),
			}
		},
	}

	return self:render(info)
end

-- function m:add_mail(logid,name,content)
-- 	local user = self:current_user() 
-- 	local union = Union:get_union_by_id(user.union_id)
-- 	if	union~= nil then
-- 		local t = {}
-- 		t.mail = union.mail
-- 		t.mail[#t.mail + 1] = {logid = logid,name = name,content = content,time = os.time()}
-- 	 end
-- end

function m:get_mail(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)

	if	union~= nil then
		local t = {}
		t.mail = union.mail
		return self:render(t)
	end
	return {}
end

function m:get_union_coordinates(params )
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	local coordinates = {
		members = {},
	};

	if union ~= nil then
		local getCoordinate = function(user_id)
			local info = game_cmd:exc_user_cmd(user_id, "get", {"x", "y"})
			return info
		end

		if union.leader then
			coordinates.leader = getCoordinate(union.leader.user_id);
		end

		for k, member in pairs(union.guidmember.members) do
			table.insert(coordinates.members, getCoordinate(member.user_id));
		end
	end

	local msg = {union_member_coordinates = coordinates};
	return self:render(msg);
end

function m:join( params)
	local user_id = params.current_user_id
	local union_id = params.msg.union_id
	local union = Union:get_union_by_id(union_id)
	if union == nil then
		return self:error_code('union_not_exist')
	end

	if not Union:can_add_more_member(union_id) then
		return self:error_code('join_max_members')
	end
	
	local msg = {}

	if Union:need_approval_to_join(union, user_id) then
		Union:add_member(union_id, user_id, UnionConst.APPLICATION)
	else
		Union:add_member(union_id, user_id, UnionConst.MEMBER)
		msg.users = {
			[1] = game_cmd:exc_user_cmd(user_id, "get_union_info")
		};
		msg.resources = game_cmd:exc_user_cmd(user_id, "get_updated_resources", {gem = 1})
	end

	return self:render(msg);
end

function m:add_member(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local member_id = params.msg.uid
	local union = Union:get_union_by_id(union_id)
	if union == nil then
		return self:error_code("union_not_exist")
	end

	if not Union:user_has_rights(union, user_id, UnionConst.POS_INVITE) then
		return self:error_code('add_member_no_rights')
	end

	if not Union:can_add_more_member(union_id) then
		return self:error_code('add_member_max_members')
	end

	local ret = Union:add_member(union_id, member_id, UnionConst.MEMBER)
	if type(ret) == "string" then
		return self:error_code(ret)
	end

	--发送申请成功邮件
	local info = {"head", "user_name"}
	local user_info = game_cmd:exc_user_cmd(user_id, "get", info)
	local param = Union:get_union_info_for_mail(union)
	param.logid = user_info.head
	param.user_name = user_info.user_name
	param.action = UnionConst.ACTION_APPROVE_JOIN
	game_cmd:exc_mail_cmd("mail", "send_union_mail", member_id, param)

	local push_msg = {
		users = {
			[1] = game_cmd:exc_user_cmd(member_id, "get_union_info"),
		},
		resources = game_cmd:exc_user_cmd(member_id, "get_updated_resources", {gem = 1}),
	};
	self:push_msg_to_user(member_id, push_msg)

	return self:get_guid_member({
		current_user_id = user_id,
	});
end

function m:get_guid_member(params)
	local user_id = params.current_user_id
	local union_id = params.msg and params.msg.union_id or game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	local msg = {
		unions = {
			{uid = union_id, member_count = union.member_count},
		},	
	};
	if union ~= nil then
		msg.guid_member = {
			members = Union:get_members_info(union),
			leader = Union:get_memeber_info(union.leader),
		}
	elseif union_id ~= params.msg.union_id then 	-- 自己的联盟不存在
		game_cmd:exc_user_cmd(user_id, "exit_unions")
		msg.users = {
			[1] = {
				uid = user_id, 
				union_id = "",
				union_name = "",
				s_union_name = "",
				union_pos = 0
			},
		};
	end

	return self:render(msg);
end

function m:get_contribution_rank(params)
	local user_id = params.current_user_id
	local today = params.msg.today
	local msg = Union:get_contribution_rank(user_id, today)
	return self:render(msg)
end

function m:kick(params)
	local user_id = params.current_user_id
	local member_id = params.msg.uid
	if member_id then
		local user = game_cmd:exc_user_cmd(user_id, "get", {"union_id", "head", "user_name"})
		local union_id = user.union_id
		local union = Union:get_union_by_id(union_id)

		if union.guidmember.members[member_id].union_pos <= game_cmd:exc_user_cmd(user_id, "get", "union_pos")
				or not Union:user_has_rights(union, user_id, UnionConst.POS_KICK) then
			return self:error_code('kick_no_rights')
		end

		local member_info = union and union.guidmember.members[member_id]
		if member_info and member_info.union_pos == UnionConst.APPLICATION then --拒绝申请
			union.guidmember.members[member_id] = nil;
			local param = Union:get_union_info_for_mail(union)
			param.logid = user.head
			param.user_name = user.user_name
			param.action = UnionConst.ACTION_REFUSE_JOIN
			game_cmd:exc_mail_cmd("mail", "send_union_mail", member_id, param)
		elseif member_info then 	--踢掉成员
			union.guidmember.members[member_id] = nil;
			union.member_count = union.member_count - 1;
			local member = game_cmd:exc_user_cmd(member_id, "get", {"union_id", "might", "bp"})
			if member.union_id == union_id then
				Union:add_might(union_id, -member.might)
				Union:add_bp(union_id, -member.bp)
				Union:remove_gift(union_id, member_id)
				Union:remove_helps(union_id, member_id)
				game_cmd:exc_user_cmd(member_id, "exit_unions")

				local push_msg = {
					users = {
						[1] = {
							uid = member_id, 
							union_id = "",
							union_name = "",
							s_union_name = "",
							union_pos = 0
						},
					},
					has_uhelp = false,
				};

				Union:add_union_event(union, os.time(), member_id, UnionConst.NOTICE_KICK, user_id)
				self:push_msg_to_user(member_id, push_msg)

				local param = Union:get_union_info_for_mail(union)
				param.logid = user.head
				param.user_name = user.user_name
				param.action = UnionConst.ACTION_KICK
				game_cmd:exc_mail_cmd("mail", "send_union_mail", member_id, param)
			end
			Union:save(union)
		end
	end

	return self:get_guid_member({
		current_user_id = params.current_user_id,
	});
end

function m:manage_member(params)
	local member_id = params.msg.uid
	local union_pos = params.msg.union_pos
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	if union == nil then
		return self:error_code('union_not_exist')
	end

	local member = union.guidmember.members[member_id];
	if member == nil then
		return self:error_code('member_not_exist')
	end

	local user_info = game_cmd:exc_user_cmd(user_id, "get", {"head", "user_name"})
	local param = Union:get_union_info_for_mail(union)
	param.logid = user_info.head
	param.user_name = user_info.user_name
	param.union_pos = union_pos

	if member.union_pos > union_pos then
		if member.union_pos <= game_cmd:exc_user_cmd(user_id, "get", "union_pos")
				or not Union:user_has_rights(union, user_id, UnionConst.POS_PROMOTE) then
			return self:error_code('premote_no_rights')
		end
		param.action = UnionConst.ACTION_PROMOTE
		Union:add_union_event(union, os.time(), member_id, UnionConst.NOTICE_PROMOTE, user_id, nil, nil, union_pos)
	elseif member.union_pos < union_pos then
		if union_pos > UnionConst.MEMBER then	-- 已是最低职位
			return self:error_code('cannot_demote')
		end

		if member.union_pos <= game_cmd:exc_user_cmd(user_id, "get", "union_pos")
				or not Union:user_has_rights(union, user_id, UnionConst.POS_DEMOTE) then
			return self:error_code('demote_no_rights')
		end
		param.action = UnionConst.ACTION_DEMOTE
		Union:add_union_event(union, os.time(), member_id, UnionConst.NOTICE_DEMOTE, user_id, nil, nil, union_pos)
	end
	game_cmd:exc_mail_cmd("mail", "send_union_mail", member_id, param)

	if union_pos == UnionConst.LEADER then
		local leader_join_time = union.leader.join_time
		local member_join_time = union.guidmember.members[member_id].join_time
		local user_pos = UnionConst.PRIME_MINISTER
		union.guidmember.members[user_id] = {
			user_id = user_id,
			union_pos = user_pos,
			join_time = leader_join_time,
		}
		game_cmd:exc_user_cmd(user_id, "update_union_info", { union_pos = user_pos })
		local push_msg = {
			users = {
				[1] = game_cmd:exc_user_cmd(user_id, "get_union_info"),
			},
		};
		self:push_msg_to_user(user_id, push_msg)

		union.guidmember.members[member_id] = nil
		union.leader.user_id = member_id
		union.leader.join_time = member_join_time
	else
		member.union_pos = union_pos;
	end
	game_cmd:exc_user_cmd(member_id, "update_union_info", { union_pos = union_pos })

	local push_msg = {
		users = {
			[1] = game_cmd:exc_user_cmd(member_id, "get_union_info"),
		},
	};
	self:push_msg_to_user(member_id, push_msg)

	Union:save(union)

	return self:get_guid_member({
		current_user_id = params.current_user_id,
	});
end

function m:union_get_tech(params)
	local user = params.current_user_id
	local msg = {
		tech = Union:get_researches(user),
	}

	return self:render(msg)
end

function m:member_contribution(params)
	local research_id = params.msg.id
	local ratio = params.msg.ratio;
	local gems = params.msg.gems
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	if union == nil then
		return self:error_code('union_not_exist')
	end

	-- 入盟一定时间才能捐献
	local join_time = 0
	if union.leader.user_id == user_id then
		join_time = union.leader.join_time or 0
	elseif union.guidmember.members[user_id] then
		join_time = union.guidmember.members[user_id].join_time or 0
	end

	if not ip_config.is_debug and os.time() - join_time < UnionConst.RESEARCH_TIME_LIMIT then
		return self:error_code('cannot_contribute_in_8h')
	end

	local tech = union.tech and union.tech[research_id]
	local tech_config = ConfigUnionResearch:find_by_id(research_id)
	if tech and tech.level >= tech_config:max_level() then
		return self:error_code('research_reaches_max_level')
	end

	-- 检测资源是否够
	local level = tech and (tech.level + 1) or 1
	if gems > 0 then
		if not game_cmd:exc_user_cmd(user_id, "has_gems", gems) then --钻石捐赠
			return self:error_code('not_enough_gems')
		end
	elseif not Union:has_enough_resources_to_donate(user_id, tech_config, level) then --资源捐赠
		return self:error_code('resource_not_enough')
	end

	local research_info = Union:donate_research(user_id, research_id, ratio, gems)
    local msg = game_cmd:exc_user_cmd(user_id, "get_resources_info")
	msg.tech = research_info

	return self:render(msg);
end

function m:unlock_contribution(params)
	local user_id = params.current_user_id
	local msg = Union:unlock_contribution(user_id)
	if msg.error_code then
		return self:error_code(msg.error_code)
	end

	return self:render(msg)
end

function m:upgrade_research(params)
	local user_id = params.current_user_id
	local uid = params.msg.uid
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	if union == nil then
		return self:error_code('union_not_exist')
	end

	if not Union:user_has_rights(union, user_id, UnionConst.POS_UPGRADE_RESEARCH) then
		return self:error_code('upgrade_research_no_rights')
	end
	local msg = Union:upgrade_research(user_id, uid)

	return self:render(msg)
end

function m:get_person_not_in_union(params)
	local offset = params.msg.offset or 0
	local limit = params.msg.limit or 20
	local name = params.msg.pattern or ""
	local attrs = {_id = 1, head = 1, user_name = 1, might = 1, language = 1, }
	local user_id = params.current_user_id
	local user = game_cmd:exc_user_cmd(user_id, "get", {"language", "union_id"})
	local union = Union:get_union_by_id(user.union_id)
	if union == nil then
		return self:error_code("union_not_exist")
	end

	local language = name ~= "" and user.language or nil
	local msg = {
		person = {},
	}
	local exclude = {}
	for user_id, v in pairs(union.invitation) do
		table.insert(exclude, user_id)
	end
	local users = skynet.call('database', 'lua', 'user', 'find_no_union_by_name', name, attrs, offset, limit, exclude)
	for k,v in pairs (users) do
		local info = {}
		info._id = v._id
		info.logid = v.head
		info.name = v.user_name
		info.might = math.floor(v.might)
		info.language = v.language
		table.insert(msg.person, info)
	end
	return self:render(msg)
end

function m:send_union_invitation_mail(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	local invitation_uid  = params.msg.uid
	if union == nil then
		return self:error_code("union_not_exist")
	end

	if not Union:user_has_rights(union, user_id, UnionConst.POS_INVITE) then
		return self:error_code('invite_no_rights')
	end

	local msg = {invited = {}};
	if not Union:is_invited(union, invitation_uid) then
		union.invitation = union.invitation or {};
		union.invitation[invitation_uid] = 1;
		Union:save(union)
		table.insert(msg.invited, invitation_uid);
		local info = {"head", "user_name"}
		local user_info = game_cmd:exc_user_cmd(user_id, "get", info)
		local param = Union:get_union_info_for_mail(union)
		param.logid = user_info.head
		param.user_name = user_info.user_name
		param.action = UnionConst.ACTION_INVITE
		
		game_cmd:exc_mail_cmd("mail", "send_union_mail", invitation_uid, param)
	end

	return self:render(msg);
end

function m:invite_all(params)
	local user_id = params.current_user_id
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	if union == nil then
		return self:error_code("union_not_exist")
	end

	local limit = 200	--最多邀请200
	local user_list = skynet.call('database', 'lua', 'user', 'find_users_to_invite', limit)
	if next(user_list) == nil then
		return self:error_code("no_user_to_invite")
	end

	--检测使用宝石
	local price = Union:get_price(2104)
	local has_enough_currency = game_cmd:exc_user_cmd(user_id, "use_currency", price)
	if not has_enough_currency then
   	return self:error_price(price)
  end

	--邮件信息
	local info = {"head", "user_name"}
	local user_info = game_cmd:exc_user_cmd(user_id, "get", info)
	local param = Union:get_union_info_for_mail(union)
	param.logid = user_info.head
	param.user_name = user_info.user_name
	param.action = UnionConst.ACTION_INVITE

	for k, user in pairs(user_list) do
		local invitation_uid = user._id
		if not Union:is_invited(union, invitation_uid) then
			union.invitation = union.invitation or {};
			union.invitation[invitation_uid] = 1;
			game_cmd:exc_mail_cmd("mail", "send_union_mail", invitation_uid, param)
		end
	end

	Union:save(union)

	return self:render({});
end

function m:gamble( params )
	local  user_id = params.current_user_id
	local  union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local  union = Union:get_union_by_id(union_id)
	if not Union:gamble(user_id) then return self:error('gamble_failed') end
	return self:render(Tool:merge({
		Union:get_gamble_info(user_id),
		{
			items = {
			  {uid = ItemConst.UNION_GAMBLE_COIN, amount = game_cmd:exc_user_cmd(user_id, "get_gamble_coins")},
			  {uid = prize.item_id, amount = game_cmd:exc_user_cmd(user_id, "get_item_amount", prize.item_id)}
			}
		}
	}))
end

function m:push_msg_to_user(user_id, push_msg)
    if skynet.call('watchdog', 'lua', 'is_online', user_id) then
        game_cmd:send_user_cmd(user_id, "send_push", push_msg)
        return true
    end

    return false
end

return m
