config_errors =
{
	-- wild
	event_not_exist 		= { _id=300,	 text="LC_ERROR_EVENT_NOT_EXIST",		description="事件不存在",	},
	temple_not_ready 		= { _id=301,	 text="LC_ERROR_TEMPLE_NOT_READY",		description="神庙冷却中",	},
	not_enough_ac 			= { _id=302,	 text="LC_ERROR_NOT_ENOUGH_AC",			description="体力不足",	},
	cannot_find_monster 	= { _id=303,	 text="LC_ERROR_CANNOT_FIND_MONSTER",	description="找不到掉落该装备的怪物",	},
	mine_not_exist 			= { _id=304,	 text="LC_ERROR_MINE_NOT_EXIST",			description="该矿不存在",	},
	mine_seized 			= { _id=305,	 text="LC_ERROR_MINE_SEIZED",			description="该矿已被占领",	},
	item_not_exist 			= { _id=306,	 text="LC_ERROR_ITEM_NOT_EXIST",			description="物品不存在",	},
	not_enough_item 		= { _id=307,	 text="LC_ERROR_NOT_ENOUGH_ITEM",		description="你没有该物品",	},
	not_city 				= { _id=308,	 text="LC_ERROR_NOT_CITY",				description="不是城堡",	},
	not_camp 				= { _id=309,	 text="LC_ERROR_NOT_CAMP",				description="不是帐篷",	},
	not_monster 			= { _id=310,	 text="LC_ERROR_NOT_MONSTER",			description="不是怪物",	},
	not_cave 				= { _id=311,	 text="LC_ERROR_NOT_CAVE",				description="不是洞穴",	},
	no_army_info 			= { _id=312,	 text="LC_ERROR_NO_ARMY_INFO",			description="没有军队信息",	},
	troop_not_exist 		= { _id=313,	 text="LC_ERROR_TROOP_NOT_EXIST",		description="部队不存在",	},
	can_not_transfer 		= { _id=314,	 text="LC_ERROR_CAN_NOT_TRANSFER",		description="只能迁城到空地上",	},
	camp_max_level 			= { _id=315,	 text="LC_ERROR_CAMP_MAX_LEVEL",			description="帐篷已升到最高等级",	},
	not_your_camp 			= { _id=316,	 text="LC_ERROR_NOT_YOUR_CAMP",			description="不是自己的帐篷",	},
	camp_no_army 			= { _id=317,	 text="LC_ERROR_CAMP_NO_ARMY",			description="帐篷中已无部队",	},
	mine_has_comer 			= { _id=318,	 text="LC_ERROR_TARGET_SEIZED",			description="有其他玩家前往此矿",	},
	land_has_comer 			= { _id=319,	 text="LC_ERROR_TARGET_SEIZED",			description="有其他玩家前往此处",	},
	cannot_find_gold_mine 	= { _id=320,	 text="LC_ERROR_CANNOT_FIND_GOLD_MINE",	description="找不到金矿",	},
	cannot_find_cave 		= { _id=321,	 text="LC_ERROR_CANNOT_FIND_CAVE",		description="找不到洞穴",	},
	cannot_set_rally_point  = { _id=322,	 text="LC_WORD_NEED_POSTHOUSE_TO_RALLY_ATTACK",		description="需要修建驿站后才可发起集结进攻",	},
	cave_disabled 			= { _id=323,	 text="LC_WORD_CAVE_LOCK_INFO_1",		description="洞穴没开",	},
	can_not_protect_when_attacked = { _id=324,	 text="LC_WORD_CANNOT_ACTIVE_PROTECT",		description="被进攻行军途中开不了保护",	},
	already_join 			= { _id=325,	 text="LC_WORD_RALLY_ATTACK_ONLY_ONE_TROOP",		description="只能有一支部队参与集结进攻",	},
	monster_changed 		= { _id=326,	 text="LC_ERROR_MONSTER_REFRESH",		description="怪物已刷新",	},

	-- union
	union_not_exist 		= { _id=350,	 text="LC_ERROR_UNION_NOT_EXIST",		description="联盟不存在",	},
	not_the_help 			= { _id=351,	 text="LC_ERROR_NOT_THE_HELP",			description="帮助不存在",	},
	you_helped 				= { _id=352,	 text="LC_ERROR_YOU_HELPED",				description="只能帮助一次",	},
	ally_not_exist 			= { _id=353,	 text="LC_ERROR_ALLY_NOT_EXIST",			description="该盟友不存在",	},
	help_times_max 			= { _id=354,	 text="LC_ERROR_HELP_TIMES_MAX",			description="该请求的帮助次数已达最大值",	},
	edit_banner_no_rights 	= { _id=355,	 text="LC_ERROR_EDIT_BANNER_NO_RIGHTS",	description="没用权限修改联盟旗帜",	},
	change_name_no_rights 	= { _id=356,	 text="LC_ERROR_CHANGE_NAME_NO_RIGHTS",	description="没用权限修改联盟名称",	},
	dismiss_no_rights 		= { _id=357,	 text="LC_ERROR_DISMISS_NO_RIGHTS",		description="没用权限解散联盟",	},
	transfer_leader_no_rights 	= { _id=358,	text="LC_ERROR_TRANSFER_LEADER_NO_RIGHTS",		description="没有权限转让盟主",	},
	kick_no_rights 			= { _id=359,	 text="LC_ERROR_KICK_NO_RIGHTS",			description="没有权限踢人",	},
	edit_slogan_no_rights 	= { _id=360,	 text="LC_ERROR_EDIT_SLOGAN_NO_RIGHTS",	description="没有权限修改联盟宣言",	},
	edit_announcement_no_rights = { _id=361,	text="LC_ERROR_EDIT_ANNOUNCEMENT_NO_RIGHTS",	description="没有权限修改联盟公告",	},
	edit_recruitment_no_rights 	= { _id=362,	text="LC_ERROR_EDIT_RECRUITMENT_NO_RIGHTS",	description="没有权限修改无需申请入盟",	},
	edit_language_no_rights 	= { _id=363,	text="LC_ERROR_EDIT_LANGUAGE_NO_RIGHTS",		description="没有权限修改联盟语言",	},
	buy_items_no_rights 		= { _id=364,  	text="LC_ERROR_BUY_ITEMS_NO_RIGHTS",			description="没有权限进货",	},
	upgrade_research_no_rights 	= { _id=365,  	text="LC_ERROR_UPGRADE_RESEARCH_NO_RIGHTS",	description="没有权限升级联盟科技",	},
	premote_no_rights 			= { _id=366,  	text="LC_ERROR_PREMOTE_NO_RIGHTS",			description="没有权限提升成员阶级",	},
	demote_no_rights 		= { _id=367,  	text="LC_ERROR_DEMOTE_NO_RIGHTS",		description="没有权限降低成员阶级",	},
	invite_no_rights 		= { _id=368,  	text="LC_ERROR_INVITE_NO_RIGHTS",		description="没有权限邀请玩家",	},
	not_enough_contribution = { _id=369,  	text="LC_ERROR_NOT_ENOUGH_CONTRIBUTION",		description="没有足够的贡献值",	},
	cannot_disband_union    = { _id=370,  	text="LC_WORD_ALLIANCE_DISBAND_FAIL",	description="不能解散有盟友的盟",	},
	cannot_contribute_in_8h = { _id=371,  	text="LC_WORD_CANNOT_DONATE_IN_8_HOURS",	description="入盟8小时内不能捐赠",	},
	add_member_max_members 	= { _id=372,  	text="LC_WORD_ALLIANCE_ACCEPT_FAIL",	description="联盟人数满，点击ACCEPT弹出提示",	},
	join_max_members 		= { _id=373,  	text="LC_WORD_ALLIANCE_FULL_JOIN_FAIL",	description="联盟人数满，点击加入联盟或者申请加入联盟弹出提示",	},
	repeated_name 			= { _id=374,  	text="LC_WORD_INPUT_WORD_REPETITION",	description="联盟名字重复",	},
	user_joined_union		= { _id=375,  	text="LC_WORD_ALLIANCE_APPLICATION_TARGET_NOT_EXIST",	description="该领主已加入其他联盟",	},

	-- gamble
	gamble_failed 			= { _id=400,	 text="LC_ERROR_GAMBLE_FAILED",			description="赌博失败",	},

	-- building
	building_not_exist 		= { _id=450,	 text="LC_ERROR_BUILDING_NOT_EXIST",		description="建筑不存在",	},

	-- resources
	not_enough_gems			= { _id=500,	 text="LC_ERROR_NOT_ENOUGH_GEMS",		description="宝石不足",	},

}