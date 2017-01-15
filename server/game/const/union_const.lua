local M = {
	-- change alliance
	LEAGUE_CHANGE_SLOGAN          = 1,
	LEAGUE_CHANGE_RECRUIT         = 2,
	LEAGUE_CHANGE_NAME            = 3,
	LEAGUE_CHANGE_NICKNAME        = 4,
	LEAGUE_CHANGE_LANGUAGE        = 5,
	LEAGUE_CHANGE_BANNER          = 6,
	LEAGUE_CHANGE_ANNOUNCEMENT    = 7,

	--notices
	NOTICE_CREATE 	= 1,
	NOTICE_JOIN 	= 2,
	NOTICE_QUIT 	= 3,
	NOTICE_KICK 	= 4,
	NOTICE_PROMOTE 	= 5,
	NOTICE_DEMOTE 	= 6,
	NOTICE_RESTOCK 	= 7,
	NOTICE_MAX_COUNT = 20,

	--positions
	LEADER 			= 1,
	PRIME_MINISTER 	= 2,
	GENERAL 		= 3,
	MEMBER 			= 4,
	APPLICATION 	= 5,

	--rights position
	POS_EDIT_BANNER			= 1,
	POS_CHANGE_NAME			= 1,
	POS_DISMISS				= 1,
	POS_TRANSFER_LEADER		= 1,
	POS_KICK 				= 2,
	POS_EDIT_SLOGAN			= 2,
	POS_EDIT_ANNOUNCEMENT	= 2,
	POS_EDIT_RECRUITMENT	= 2,
	POS_EDIT_LANGUAGE		= 2,
	POS_BUY_ITEMS			= 2,
	POS_UPGRADE_RESEARCH	= 2,
	POS_PROMOTE				= 2,
	POS_DEMOTE				= 2,
	POS_INVITE				= 2,

	--store
	ITEM_BASIC 				= 1,
	ITEM_STORE 				= 2,

	--research
	RESEARCH_TIME_LIMIT 	= 3600 * 8,	--8小时

	--action for mail
	ACTION_INVITE 			= 1,
	ACTION_REFUSE_JOIN 		= 2,
	ACTION_PROMOTE 			= 3,
	ACTION_DEMOTE 			= 4,
	ACTION_KICK 			= 5,
	ACTION_APPROVE_JOIN		= 6,

	--text length
	NAME_LENGTH_MIN 		= 3,
	NAME_LENGTH_MAX 		= 15,
	SHORT_NAME_LENGTH 		= 5, --加[]
	ANNOUNCEMENT_LENGTH_MAX = 55,
	SLOGAN_LENGTH_MAX  		= 100,

	RANDOM_LOGO = {1, 2, 3, 11},
	RANDOM_BANNER = {1, 3, 7, 9},
}

UnionConst = M

return  M