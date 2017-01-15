local M = {
    TYPE_SYSTEM = 1,
    TYPE_RESOURCE = 2,
    TYPE_PVP = 3,
    TYPE_PVE = 4,
    TYPE_TEMPLE = 5,
    TYPE_CHAT = 6,
    TYPE_CAVE = 7,
    TYPE_UNION = 8,

    SUBTYPE_ATTACK      = 1,
    SUBTYPE_TRADE       = 2,
    SUBTYPE_SCOUT       = 3,
    SUBTYPE_GET_SCOUTED = 4,
    SUBTYPE_CAMP        = 5,
    SUBTYPE_REINFORCE   = 6,
    SUBTYPE_JOIN_RALLY  = 7,
    SUBTYPE_PVE_FAIL    = 8,
    SUBTYPE_RAIN_BOSS   = 9,
    SUBTYPE_MISS_MONSTER = 10,
    SUBTYPE_MISS_USER   = 11,
    SUBTYPE_REINFORCEMENT_DISMISSED = 12,
    SUBTYPE_REINFORCEMENT_BATTLE    = 13,
    SUBTYPE_HOSIPTAL_LOST    = 14,
    SUBTYPE_MISS_SCOUT      = 15,
    SUBTYPE_PVP_LOWER      = 16,

    MAIL_LIST_UID = 
        {
            "mail_list_system_uid", --system
            "mail_list_mining_uid", -- mining
            "mail_list_pvp_uid", --pvp
            "mail_list_pve_uid", --pve
            "mail_list_temple_uid", --temple
            "mail_list_chat_uid", --chat
            "mail_list_cave_uid", --cave
            "mail_list_union_uid", --union
            "mail_list_union_chat_uid", --union chat
        },

    STATUS_NEW = 1,
    STATUS_READ = 0,
    MAX_MAIL_NUM = 100,
}

MailConst = M

return  M