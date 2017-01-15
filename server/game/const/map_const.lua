local M = {
  -- deco types
  SPACE     = 0,
  CITY      = 1,
  MONSTER   = 2,
  RESOURCE  = 3,
  CAVE      = 4,
  TEMPLE    = 5,
  TERRAIN   = 6,
  GOLD      = 7,
  WOOD      = 8,
  STONE     = 9,
  ORE       = 10,
  FOOD      = 11,
  GEM       = 12,
  CAMP      = 13,
  PALACE    = 14,
  FAKE      = 15,

  MAP = {
    ZONE_WIDTH = 40,
    ZONE_HEIGHT = 40,
    ZONE_SIZE = 30,
    ZONE_GAP = 5,
    AREA_1 = 1,
    AREA_2 = 2,
    AREA_3 = 3,
    AREA_4 = 4,
    AREA_5 = 5,
    AREA_6 = 6,
    ZOOM = 100000,
    MAX_MONSTER = 50,
    MAX_RESOURCE = 40,
    MAX_CITY = 20,
    STATUS = {
      SAVETY = 0,
      OCCUPIED = 1,
      UNION_OCCUPIED = 2,
      ENEMY_OCCUPIED = 3
    },
  },
  ZONE = {
    WIDTH = 15,
    HEIGHT = 15
  },
  RESOURCE = {
    TYPES = {'gold', 'wood', 'stone', 'ore', 'food', 'gem'}
  },
  TEMPLE_STATE = {
    ACTIVE = 1,
    IDLE = 2,
    DISABLE = 3,
  },
  TEMPLE_POSITIONS = {
    {x = 7, y = 15},
    {x = 15, y = 7},
    {x = 22, y = 15},
    {x = 15, y = 22},
  },

  PALACE_SIZE = 4,
}

MapConst = M

MapConst.MAP.WIDTH = MapConst.MAP.ZONE_SIZE * MapConst.MAP.ZONE_WIDTH + MapConst.MAP.ZONE_GAP * (MapConst.MAP.ZONE_WIDTH - 1);
MapConst.MAP.HEIGHT = MapConst.MAP.ZONE_SIZE * MapConst.MAP.ZONE_HEIGHT + MapConst.MAP.ZONE_GAP * (MapConst.MAP.ZONE_HEIGHT - 1);

return  M
