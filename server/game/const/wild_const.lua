
require 'map_const'

WildConst = {
	-- wild action
	MARCH_MARCHING 			= 0,
	MARCH_DIG_MINE 			= 1,
	MARCH_CAMPING 			= 2,
	MARCH_RALLY_MARCH 		= 3,
	MARCH_EXPLORING 		= 4,
	MARCH_MINE 				= 5,
	MARCH_RETURN_MARCH 		= 6,
	MARCH_SCOUT 			= 7,
	MARCH_SCOUT_RETURN 		= 8,
	MARCH_OCCUPATION 		= 9,
	MARCH_TRADE_RETURN		= 10,
	MARCH_EXPLORING_MARCH 	= 11,
	MARCH_TEMPLE_MARCH 		= 12,
	MARCH_RALLY_WAITING 	= 13,
	MARCH_RALLY_SUPPORT_MARCH = 14,
	MARCH_ATTACK			= 15,
	MARCH_TRADE 			= 16,
	MARCH_REINFORCE    		= 17,
	MARCH_REINFORCE_MARCH	= 18,

	-- march types
	MARCH_TYPE_PVE 			= 1,
	MARCH_TYPE_PVP 			= 2,
	MARCH_TYPE_CAMP 		= 3,
	MARCH_TYPE_ALLY			= 4,
	MARCH_TYPE_TRADE		= 5,

	-- war_events tags
	TAG_NONE      = 0,
	TAG_SELF      = 1,
	TAG_ALLY      = 2,
	TAG_ENEMY     = 3,

	-- owner
	OWNER_NONE 	= 0;
	OWNER_SELF 	= 1;
	OWNER_ALLY 	= 2;
	OWNER_ENEMY = 3;

	-- attack monster
	ATTACK_MONSTER_AC = 1,
	DROP_GOLD_MIN_MONSTER_LEVEL = 4,

	MINE_NAMES = {
		[MapConst.WOOD] = "wood",
		[MapConst.FOOD] = "food",
		[MapConst.GOLD] = "gold",
		[MapConst.STONE] = "stone",
		[MapConst.ORE] = "ore",
		[MapConst.GEM] = "gem",
	},

	AREA_TOP_LEFT = {
		[1] = {x = 1, y = 1},
		[2] = {x = 5, y = 5},
		[3] = {x = 9, y = 9},
		[4] = {x = 13, y = 13},
		[5] = {x = 17, y = 17},
		[6] = {x = 20, y = 20},
	},

	TILE_IDX = {
		id 			= "id",
		category 	= "category",
		level 		= "level",
		life 		= "life",
		total_life 	= "total_life",
		protected 	= "protected",
		tag 		= "tag",
		name 		= "name",
		owner 		= "owner",
		camp_index 	= "camp_index",
		delay 		= "delay",

		--resource
		start_time 	= "start_time",
		speed 		= "speed",
	},

	--city life
	CITY_DEFAUT_LIFE = 1000,
	CAMP_DEFAUT_LIFE = 1000,

	CREATE_BOSS_NEED_USER_COUNT = 1,	-- 8,
	CREATE_MORE_BOSS_NEED_USER_LEVEL = 13,

	NEIGHBOR_OFFSET = {
        [1] = { x = 0,  y = -1 },
        [2] = { x = 0,  y = 1 },
        [3] = { x = -1, y = 0 },
        [4] = { x = 1,  y = 0 },
        [5] = { x = -1, y = -1 },
        [6] = { x = 1,  y = -1 },
        [7] = { x = -1, y = 1 },
        [8] = { x = 1,  y = 1 },
    },

    --lost temple
    TEMPLE_MIN_ACTIVE_USER_COUNT 	= 4,	--需要活跃玩家数量
    ACTIVE_USER_LOGIN_TIME 			= 3 * 3600 * 24, --活跃玩家判定条件
};
