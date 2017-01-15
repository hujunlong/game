

local M = {
  BUILDING = {
    CityHall = 1, --市政厅
    Barrack = 2, -- 军事大厅
    Angle = 4,
    Hospital = 5,
    Market = 6,
    Depot = 7,
    Embassy = 8,
    Watchtower = 9,
    RallyPoint = 10,
    HeroHall = 11, -- 英雄大厅
    Factory = 12,
    House = 13,  -- 兵营
    Farm = 14, -- 农场11
    Quarry = 15,
    Sawmill = 16,
    Smelter = 17,
    Wall = 18,
    CourierStation = 20,  -- 驿站
    Research = 3,
    BlackMarket = 23,
    GIFT = 22
  },
  PITS = {
    BlackMarket = 244
  },
  BUILDING_STATUS = {
    IDLE = 0,
    WORK = 1,
    BUILDING = 2,
    COLLECT = 3,
    RESEARCH = 4,
    CURE = 5
  },
  SECOND_BUILD_QUEUE = {
    GEM = 300,
    TIME = 86400
  },
  CONVERT_TYPES = {13,14,15,16,17},
  CITY_RESOURCE = {'wood', 'stone', 'ore', 'food'},
  RES = {
    wood = {
      config_id = 16,
      produce = 'get_wood_income'
    }, 
    stone = {
      config_id = 15,
      produce = 'get_stone_income'
    },
    ore = {
      config_id = 17,
      produce = 'get_ore_income'
    },

    food = {
      config_id = 14,
      produce = 'get_food_income'
    }
  },
  RESOURCE_PORTECT = {
      wood =  35,
      food = 35,
      ore = 2,
      stone = 8,
      gold = 20,
  },
  RESOURCE_ROB_PER = {
      wood =  75,
      food = 75,
      ore = 25,
      stone = 50,
      gold = 50,
  },
  MAX_HERO_POS = 4,
  HERO_INIT_MAX_LEVEL = 8,
}

BuildingConst = M

return  M