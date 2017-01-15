local skynet = require "skynet"
local timer = require "timer_proxy"
local Tool = require 'tool'
local ip_config = require('ip_config')
local ConfigStat = require 'config_stat'
local loadstring = rawget(_G, "loadstring") or load

function Union:get_researches(user_id)
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	if union == nil then return end

	local need_info = {"union_tech_cd", "union_tech_lock"}
	local researches = game_cmd:exc_user_cmd(user_id, "get", need_info)
	researches.clear_cd_times = game_cmd:exc_user_cmd(user_id, "get_clear_cd_times")
	researches.union_contribution = Union:get_user_contribution(user_id)
	researches.researches = {}

	for k, v in pairs(union.tech) do
		researches.researches[k] = Union:get_research_info(union, k)
	end

	return researches
end

function Union:donate_research(user_id, research_id, ratio, gems)
	local id = tostring(research_id)
	local current_time = os.time();
	local tech_config = ConfigUnionResearch:find_by_id(tonumber(id))
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = Union:get_union_by_id(union_id)
	local add_exp = 0
	local add_contribution = 0

	if union ~= nil and game_cmd:exc_user_cmd(user_id, "get_union_tech_lock") ~= 1 then
		union.tech = union.tech or {};
		union.tech[id] = union.tech[id] or {	
			level = 0,
			exp = 0,
			need_exp = tech_config:get_exp(1),
		};

		local tech = union.tech[id];
		if tech.level < tech_config:max_level() and tech.exp < tech.need_exp then
			if tech.exp == 0 then
				tech.start_time = current_time
				tech.members = {}
				tech.last_24h = {}
				tech.last_24h_exp = 0
			end
			
			add_exp = tech_config:exp_per_time() * ratio;
			if ip_config.is_debug then
				add_exp = add_exp * 500
			end
			tech.exp = tech.exp + add_exp;
			if tech.exp >= tech.need_exp then
				Union:push_upgrade_research_nums(union_id)
			end

			local record = {
				time = current_time,
				exp = add_exp,
			}

			for i = #tech.last_24h, 1, -1 do
				if tech.last_24h[i].time + BasicConst.DAY_SECS < current_time then
					tech.last_24h_exp = tech.last_24h_exp - tech.last_24h[i].exp
					table.remove(tech.last_24h, i)
				end
			end
			table.insert(tech.last_24h, record)
			tech.last_24h_exp = tech.last_24h_exp + record.exp
			tech.members[user_id] = 1

			if gems > 0 then
				game_cmd:exc_user_cmd(user_id, "use_gems", gems)
			else
				local tech = union.tech[id];
				local next_level = tech.level + 1;
				local costs = {
					gold = tech_config:get_gold(next_level),
					food = tech_config:get_food(next_level),
					wood = tech_config:get_wood(next_level),
					stone = tech_config:get_stone(next_level),
					ore  = tech_config:get_ore(next_level),
				}
				game_cmd:exc_user_cmd(user_id, "use_resources", costs)
			end

			if Union.is_line_map == nil then
				Union.is_line_map = game_cmd:exc_server_cmd("server_info_mgr", "is_line_map")
			end
			local increase_time = Union.is_line_map and math.floor(tech_config.increase_cd / 2) or tech_config.increase_cd
			game_cmd:exc_user_cmd(user_id, "add_union_tech_cd", increase_time)
			local contribution = tech_config.contribution * ratio
			add_contribution = Union:add_contribution(union, user_id, contribution, "donate")
			Union:save(union)

			local push_msg = {
				tech = {
					researches = {
						[id] = Union:get_research_info(union, id),
					}
				}
			}
			local excluded = {
				[user_id] = true,
			}
			Union:push_msg_to_union(union_id, push_msg, excluded)
		end
	end
		
	local u_info = {"union_tech_cd", "union_tech_lock"}
	local research = game_cmd:exc_user_cmd(user_id, "get", u_info)
	research.clear_cd_times = game_cmd:exc_user_cmd(user_id, "get_clear_cd_times")
	research.union_contribution = Union:get_user_contribution(user_id)
    research.researches = {
    	[id] = {
    		uid = id,
	    	level = union.tech[id] and union.tech[id].level or 0,
			exp = union.tech[id] and union.tech[id].exp or 0,
			need_exp = union.tech[id] and union.tech[id].need_exp,
			add_exp = add_exp,
			last_24h_exp = union.tech[id] and union.tech[id].last_24h_exp or 0,
			add_contribution = add_contribution,
		},
	}

	return research
end

function Union:has_enough_resources_to_donate(user_id, tech_config, level)
	local costs = {
		gold = tech_config:get_gold(level),
		food = tech_config:get_food(level),
		wood = tech_config:get_wood(level),
		stone = tech_config:get_stone(level),
		ore  = tech_config:get_ore(level),
	}
	
	return game_cmd:exc_user_cmd(user_id, "has_resources", costs)
end

function Union:upgrade_research(user_id, uid)
	uid = tostring(uid)
	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = union_id and Union:get_union_by_id(union_id) or nil
	if union then
		local member = union.guidmember.members[user_id]
		if union.leader.user_id == user_id
				or (member and member.union_pos <= UnionConst.PRIME_MINISTER) then
			local tech = union.tech[uid];
			if tech and tech.exp >= tech.need_exp and tech.upgrade_time == nil then
				local tech_config = ConfigUnionResearch:find_by_id(tonumber(uid))
				local time = math.ceil(tech_config:get_upgrade_time(tech.level + 1) * (1 - Union:get_AllianceResearchSpeedPer_effect(union_id) / 100))
				timer:add_timer(nil, time, 0, function()
					Union:research_levelup(union_id, uid)
				end)
				tech.upgrade_time = os.time() + time;
				Union:push_upgrade_research_nums(union_id)
			end
			Union:save(union)
		end
	end

	local msg = {
		tech = {
			researches = {
	    		[uid] = Union:get_research_info(union, uid),
			},
		},
	}

	return msg;
end

function Union:get_research_info(union, uid)
	uid = tostring(uid)
	local research = union and union.tech[uid]
	local tech_config = ConfigUnionResearch:find_by_id(tonumber(uid))
	local info = {
		level = research and research.level or 0,
		exp = research and research.exp or 0,
		need_exp = research and research.need_exp or tech_config:get_exp(1),
		last_24h_exp = research and research.last_24h_exp or 0,
		uid = uid,
		upgrade_time = research.upgrade_time and math.ceil(research.upgrade_time),
	}

	return info
end

function Union:research_levelup(union_id, uid)
	local union = Union:get_union_by_id(union_id)
	uid = tostring(uid)
	local research = union and union.tech[uid]
	local tech_config = ConfigUnionResearch:find_by_id(tonumber(uid))
	local current_time = os.time()

	if research and research.upgrade_time then
		research.level = math.min(research.level + 1, tech_config:max_level());
		research.exp = research.exp - research.need_exp;
		local nextLevel = math.min(research.level + 1, tech_config:max_level());
		research.need_exp	= tech_config:get_exp(nextLevel)
		research.upgrade_time = nil;
		research.last_24h = {};
		research.last_24h_exp = 0;
		Union:sync_researches(union._id)
		Union:save(union)
		Union:push_research_level_up(union_id, uid, research.level)
	end
end

function Union:set_research_upgrade_timer(union_id)
	local union = Union:get_union_by_id(union_id)
	local current_time = os.time()
	if union and union.tech then
		for uid, research in pairs(union.tech) do
			if research.upgrade_time then
				timer:add_timer(nil, research.upgrade_time - current_time, 0, function()
					Union:research_levelup(union_id, uid)
				end)
			end
		end
	end
end

-- type_name: "help", "donate"
function Union:add_contribution(union, user_id, contribution, type_name)
	contribution = contribution * (1 + Union:get_IncreaseContributionGainPer_effect(union._id) / 100)
	if type_name == "help" then	--目前只对help做限制
		contribution = game_cmd:exc_user_cmd(user_id, "limit_contribution", type_name, contribution)
	end

	game_cmd:exc_user_cmd(user_id, "add_union_contribution", contribution)
	local honor = contribution
	union.contribution = union.contribution and (union.contribution + honor) or honor
	union.total_contribution = union.total_contribution and (union.total_contribution + honor) or honor

	local total = union.contributions.total
	total[user_id] = total[user_id] and (total[user_id] + honor) or honor

	local last_day = union.contributions["7"]
	last_day[user_id] = last_day[user_id] and (last_day[user_id] + honor) or honor
	local week_contribution = union.contributions.week
	week_contribution[user_id] = week_contribution[user_id] and (week_contribution[user_id] + honor) or honor

	if type_name == "donate" then
		local donate_total = union.contributions.donate.total
		donate_total[user_id] = donate_total[user_id] and (donate_total[user_id] + honor) or honor
		local donate_last_day = union.contributions.donate["7"]
		donate_last_day[user_id] = donate_last_day[user_id] and (donate_last_day[user_id] + honor) or honor
	end

	return math.floor(contribution)
end

function Union:refresh_union_contribution(union)
	local current_time = os.time()
	local today_start_time = current_time - (current_time % BasicConst.DAY_SECS);
	local contributions = union.contributions

	if today_start_time > contributions.last_day_time then
		local start_time = today_start_time
		while start_time > contributions.last_day_time do
			for user_id, contribution in pairs(contributions["1"]) do
				contributions.week[user_id] = contributions.week[user_id] - contribution
			end
			for i = 1, 6 do
				contributions[tostring(i)] = contributions[tostring(i + 1)]
				contributions.donate[tostring(i)] = contributions.donate[tostring(i + 1)]
			end
			contributions["7"] = {}
			contributions.donate["7"] = {}
			start_time = start_time - BasicConst.DAY_SECS
		end

		contributions.last_day_time = today_start_time
	end
	return true
end

function Union:refresh_contributions()
	for k, union in pairs(Union.union_list) do
		Union:refresh_union_contribution(union)
	end

	Union:add_refresh_contributions_timer()
end

function Union:add_refresh_contributions_timer()
	local current_time = os.time()
	local time = BasicConst.DAY_SECS - (current_time % BasicConst.DAY_SECS);
	timer:add_timer(nil, time, 0, function()
		Union:refresh_contributions()
	end)
end

function Union:get_contribution_rank(user_id, today)
	local msg = {
		rank = {
			history = {

			},
		},
	};

	if today then
		msg.rank.today = {}
	else
		msg.rank.weekly = {}
	end

	local union_id = game_cmd:exc_user_cmd(user_id, "get", "union_id")
	local union = union_id and Union:get_union_by_id(union_id) or nil
	if union then
		local member_list = Union:get_memeber_list(union_id)
		local get_rank_info = function(src_table, des_table)
			local t = {}
			for i, user_id in pairs(member_list) do
				table.insert(t, {
					user_id = user_id,
					contribution = src_table[user_id] and math.floor(src_table[user_id]) or 0,
				})
			end

			table.sort(t, function(a, b)
				return a.contribution > b.contribution
			end)

			local rank = 0
			local m_info = {"head", "user_name", "title"}
			for i, v in ipairs(t) do
				local member = game_cmd:exc_user_cmd(v.user_id, "get", m_info)
				if member then
					rank = rank + 1;
					table.insert(des_table, {
						rank = rank,
						logid = member.head,
						name = member.user_name,
						contribution = math.floor(v.contribution),
						title = member.title,
					});

					if v.user_id == user_id then
						des_table.my_rank = rank
					end
				end
			end
		end

		if today then
			get_rank_info(union.contributions.donate.total, msg.rank.history)
			get_rank_info(union.contributions.donate["7"], msg.rank.today)
			msg.rank.my_today_rank = msg.rank.today.my_rank
		else
			get_rank_info(union.contributions.total, msg.rank.history)
			get_rank_info(union.contributions.week, msg.rank.weekly)
			msg.rank.my_weekly_rank = msg.rank.weekly.my_rank
		end
		msg.rank.my_history_rank = msg.rank.history.my_rank
	end

	return msg
end

function Union:unlock_contribution(user_id)
	local currentTime = os.time();
	local msg = nil
	local price = self:get_price(2105) --解除捐献cd需要的宝石
	local gems = price and price.amount or 80;

	if not game_cmd:exc_user_cmd(user_id, "has_gems", gems) then --钻石捐赠
		msg = {
			error_code = 'not_enough_gems'
		}
		return msg
	end

	local tech = game_cmd:exc_user_cmd(user_id, "unlock_contribution", gems)
	if tech then
		msg = game_cmd:exc_user_cmd(user_id, "get_resources_info")
		msg.tech = tech
	else
		msg = {}
	end

	return msg
end

function Union:get_research_levels(union_id)
	local list = {}
	local union = Union:get_union_by_id(union_id)
	if union and union.tech then
		for k, v in pairs(union.tech) do
			table.insert(list, {
				config_id = tonumber(k),
				level = v.level,
			})
		end
	end

	return list
end

function Union:sync_researches(union_id)
	local union = Union:get_union_by_id(union_id)
	if union then
		local researches = Union:get_research_levels(union_id)
		local member_list = Union:get_memeber_list(union_id)
		for k, user_id in pairs(member_list) do
			game_cmd:exc_user_cmd(user_id, "sync_union_researches", researches) --同步researches到所有成员
		end
	end
end

function Union:get_ready_upgrade_research_num(union_id, user_id)
	local count = 0
	local union = Union:get_union_by_id(union_id)
	if union and union.tech then
		if user_id and union.leader.user_id ~= user_id
				and (union.guidmember.members[user_id] == nil or union.guidmember.members[user_id].union_pos > UnionConst.POS_UPGRADE_RESEARCH)
				then
			return count
		end

		for uid, research in pairs(union.tech) do
			local tech_config = ConfigUnionResearch:find_by_id(tonumber(uid))
			if research.exp >= research.need_exp
					and research.upgrade_time == nil
					and research.level < tech_config:max_level() then
				count = count + 1
			end
		end
	end

	return count
end

function Union:push_research_level_up(union_id, uid, level)
	local union = Union:get_union_by_id(union_id)
	if union then
		local push_msg = {
			union_level_up = {
				uid = tonumber(uid),
				level = tonumber(level),
			},
			tech = {
				researches = {
		    		[tostring(uid)] = Union:get_research_info(union, uid),
				},
			},
		}

		local config = ConfigUnionResearch:find_by_id(tonumber(uid))
		local name = config and config:get_effect_name()
		if name == 'AllianceMember' then
			local max_member = config_variable.get('alliance_member') + Union:get_AllianceMember_effect(union_id)
			union.max_member = max_member
			Union:save(union)
			push_msg.unions = {
				[1] = {
					uid = union_id,
					max_member = union.max_member,
				},
			}
		elseif name == 'IncreaseCampVolume' then
			Union:push_generated_msg_to_union(union_id, function(union_id, user_id)
				return game_cmd:exc_user_cmd(user_id, "get_camps")
			end)
		end

		Union:push_msg_to_union(union_id, push_msg)
	end
end

function Union:push_upgrade_research_nums(union_id)
	local union = Union:get_union_by_id(union_id)
	if union then
		local push_msg = {
			union_nums = {
				research = Union:get_ready_upgrade_research_num(union_id),
			}
		}

		local members = {
			union.leader.user_id
		}
		for k, v in pairs(union.guidmember.members) do
			if v.union_pos <= UnionConst.POS_UPGRADE_RESEARCH then
				table.insert(members, v.user_id)
			end
		end

		for k, user_id in pairs(members) do
			if skynet.call('watchdog', 'lua', 'is_online', user_id) then
	        	game_cmd:send_user_cmd(user_id, "send_push", push_msg)
	        end
	    end
	end
end

function Union:get_research_effect(union_id, effect_id)
	local union = Union:get_union_by_id(union_id)
	if not union then return 0 end
	local effects = {}

	for k, v in pairs(union.tech) do
		local config_id = tonumber(k)
		local level = v.level
		local cr = ConfigUnionResearch:find_by_id(config_id)
		if cr then
		  effects = Tool:add(effects, cr:get_effects(level)) 
		end
	end

	return effects[effect_id] or 0
end

function Union:create_effects_funcs( )
  for i,v in pairs(ConfigStat:all()) do
    --print("function User:get_"..v.name.."_effect( ) return self:get_all_effects()["..v._id.."] or 0 end")
    loadstring("function Union:get_"..v.name.."_effect( union_id ) return self:get_research_effect(union_id, "..v._id..") end")()
  end
  return true
end

function Union:get_contribution(union_id)
	local contribution = 0
	local union = Union:get_union_by_id(union_id)
	if union then
		contribution = math.floor(union.contribution)
	end
	return contribution
end

function Union:get_total_contribution(union_id)
	local total_contribution = 0
	local union = Union:get_union_by_id(union_id)
	if union then
		total_contribution = math.floor(union.total_contribution)
	end
	return total_contribution
end

function Union:get_user_contribution(user_id)
	return math.floor(game_cmd:exc_user_cmd(user_id, "get", "union_contribution"))
end

function Union:get_user_total_contribution(user_id)
	return math.floor(game_cmd:exc_user_cmd(user_id, "get", "total_contribution"))
end

function Union:on_server_start()
	Union:refresh_contributions()

	for k, union in pairs(Union.union_list) do
		Union:set_research_upgrade_timer(union._id)
	end
end

