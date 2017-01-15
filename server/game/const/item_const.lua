local M = {
  TYPES = {
    CHEST = 3
  },

  SUB_TYPES = {
    AC = 1
  },
  

  PERSON_GAMBLE_COIN = 19034,
  UNION_GAMBLE_COIN = 19034,

  GEM_ID = 19036,
  FOOD_ID = 19041,
  WOOD_ID = 19042,
  GOLD_ID = 19043,
  STONE_ID = 19044,
  IRON_ID = 19045,

  SPEED_UP_ITEM_ID = 19504,

  CURRENCY = {
    GEM = 'gem',
    GOLD = 'gold'
  },

  TIME_GIFTS = {
    18506,
    18507,
    18508
  },
  DAILY_GIFT_ID = 18505,
  SUPER_UNION_TIME_GIFT = 18509,
  DAILY_GIFT = 1,
  SALE_GIFT = 2,

  WEEK_CARD_ORDER_ID = 6,
  MONTH_CARD_ORDER_ID = 7,

  --wild
  ITEM_MOVE_CITY_RANDOM     = 19001, --随机迁城
  ITEM_MOVE_CITY_SENIOR     = 19002, --高级迁城
  ITEM_MOVE_CITY_T3         = 19048, --T3迁城
  ITEM_MOVE_CITY_T4         = 19049, --T4迁城
  ITEM_MARCH_RECALL         = 19005, --行军召回
  ITEM_MARCH_RECALL_SENIOR  = 19006, --高级行军召回

  --shop
  SHOP_NONE         = 0, --不属于商店
  SHOP_RESOURCE     = 1, --资源道具商店
  SHOP_WAR          = 2, --战争道具商店
  SHOP_BUFF         = 3, --BUFF道具商店
  SHOP_FUNCTION     = 4, --功能道具商店
  SHOP_UNION        = 5, --联盟购买商店
  SHOP_UNION_MEMBER = 6, --联盟个人购买商店
  SHOP_CITY         = 7, --城内资源点专用道具
  SHOP_DUAL_POP     = 8, --双线道具弹窗

  --item type
  TYPE_ITEMS = 1,
  TYPE_EQUPMENTS = 2,
  TYPE_SCORLL = 3,

  ITEM_STATUS_READ = 1,
  ITEM_STATUS_NEW = 2,

  EQUP_ID_START = 24001,
  EQUP_ID_END = 25000,
  SCROLL_ID_START = 25001,
  SCROLL_ID_END = 26000,

  SPEED_RES_ITEM_ID = 18016,
}

ItemConst = M

return  M

