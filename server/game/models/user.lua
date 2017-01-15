local UserConst = require 'user_const'
local BasicConst = require 'basic_const'
local skynet = require "skynet"
local cjson = require "cjson"
local I18n = require "i18n"
local log = require 'logger'
local queue = require 'skynet.queue'

local M = {}

local DEFAULT = {
  _id = '',
  user_name = '', -- 玩家名字
  passport = '', -- 玩家通行证
  locale = '',
  device_token = '',
  black = 0, -- 封号的时间
  mute = 0, -- 禁言的时间
  fb_id = '', -- 玩家facebook ID
  sex = UserConst.INIT_SEX, -- 性别
  head = UserConst.INIT_HEAD, -- 头像
  gold = UserConst.INIT_GOLD, -- 金币
  food = UserConst.INIT_FOOD, -- 食物
  wood = UserConst.INIT_WOOD,  -- 木头
  stone = UserConst.INIT_STONE, -- 石头
  ore = UserConst.INIT_ORE, -- 铁矿
  gem = UserConst.INIT_GEM, -- 宝石
  ac = UserConst.INIT_AC,
  max_ac = UserConst.INIT_MAX_AC,
  updated_ac_time = 0,
  ac_recover_time = UserConst.AC_REC_SECONDS_PER_POINT,
  items = {}, -- 道具 item_id = amount
  quests = {}, -- 任务 
  fquests = {}, -- 已经完成的任务ID，是否分表？
  buildings =  {}, -- 主城建筑， 是否放在Map表？
  heroes = {},  -- 英雄
  poss = {},  -- 解锁的英雄职位，职位ID
  arms = {}, -- 解锁的兵种ID
  armies =  {}, -- 主城军队 _id = 兵种ID, amount = 数量, injured = 受伤数量, cure = 正在治疗的数量
  assists = {},    -- 大使馆中援助的军队 _id = 玩家ID, user_name = 玩家名字, head = 玩家头像, armies = {_id = 兵种ID, amount = 数量}
  city = {}, -- 主城信息，看是否只保存在Map中
  might = 0, -- 战斗力
  might_rank = 0, -- 战斗力排名 
  union_reward = true,
  union_id = '', -- 所属联盟ID
  union_pos = 0, -- 所属联盟官职 
  union_name = '', -- 所属联盟名称
  s_union_name = '', -- 所属联盟缩写
  union_contribution = 0, -- 联盟贡献币
  total_contribution = 0, -- 联盟贡献值
  union_tech_cd = 0, -- 联盟科技冷却时间
  union_tech_lock = 0, -- 联盟科技冷却
  contribution_limit = {
    time = 0,       -- 设置限制的时间
    donate = 0,     -- 科技限制
    help = 0,       -- 帮助限制
    rally = 0,      -- 集火限制
    reinforce = 0,  -- 协防限制
    clear_cd = 0,   -- 清除捐赠CD次数
  },
  desc = '', -- 玩家签名
  level = 1, -- 玩家等级
  kill_units = 0, -- 杀死单位数
  bp = 0, -- 战斗点数
  bp_rank = 0, -- 战斗点数排名
  wins = 0, -- 赢下的战斗场次数
  loses = 0, -- 输的战斗场次数
  a_wins = 0, -- 攻击方赢的次数
  a_loses = 0, -- 攻击方输的次数
  d_wins = 0, -- 防守方赢的次数
  d_loses = 0, -- 防守方输的次数
  lose_units = 0, -- 损失单位数量
  c_units = 0, -- 治疗过的单位数量
  scout_times = 0, -- 侦查次数
  win_rate = 0, -- 胜率
  achiv_rate = 0, -- 成就完成率
  vip = 0, -- vip等级
  cb_score = 0, --城建分数
  hero_score = 0, -- 英雄分数
  hero_rank = 0,
  b_free_t = UserConst.INIT_BUILD_FREE_TIME,    -- 免费建造时间
  x = 0, -- 主城坐标X
  y = 0, -- 主城坐标Y
  hero_pos_cd = 0, -- 更换英雄职位cd
  build_events = {}, -- 建筑事件 _id = 建筑队列ID, e_id = 事件ID, end_time = 队列持续事件
  bookmarks = {}, -- 书签，k = 游戏国家ID, x = X坐标, y = Y坐标, t = 书签类型(1,2,3...), desc = 书签描述
  city_broken = {}, -- 城市被破坏的信息
  attack_warnings = {}, -- 
    -- 被攻击预警信息 
    -- uid = 信息ID, 
    -- user_name = 玩家名字, 
    -- s_union_name = 联盟缩写, 
    -- union_name = 联盟名字, 
    -- level = 玩家等级, 
    -- unit_count = 军队数量, 
    -- might = 战力, 
    -- armies = {uid = 兵种ID, amount = 数量}
    -- hero 英雄信息
    -- science = {uid = 科技ID, level = 科技等级}
    -- city
    -- category
    -- start = 开始时间
    -- arrival = 达到时间
    -- from_pos = 出发地点
    -- 
  cave_times = 0,       --每日探索洞穴的次数
  cave_start_time = 0,  --记录探索洞穴次数的起始时间
  keys = {building = 0, skill = 0, equipment = 0, quest = 0, hero = 0, bookmark = 0},  -- buildings 自增ID
  buffs = {},
  d_online = 1,  --每天在线奖励领取次数
  r_online_t = 0, --下次在线奖励领取时间
  r_quest_id = 3612, -- 推荐任务ID
  vip_exp = 0, -- vip经验
  titles = {},  -- 玩家获得的称号
  title = 0, -- 玩家当前称号
  hero_pvp_count = 0,
  kill_monster_count = 0,
  can_attack_monster_level = 1, -- 可攻击的怪物最高等级
  pvp_win_count = 0,
  pre_weather = UserConst.INIT_WEATHER_DAYS,
  researches = {},
  r_life_cd = 0,
  r_updated_at = 0,
  guide = 1,    -- 强制引导
  pending_guide = 0,
  tguide = {},  -- 触发引导
  guide_wild = false,
  pit_groups = {},
  funcs = {},
  main_quest = 1,
  orders = {},
  max_queue = 1,
  cur_queue = 0,
  daily_online_rewards = 0,
  gamble_items = {},
  gamble_times = 0,
  total_gamble_times = 0,
  first_week_card = false,
  card_time = 0,
  extra_card = false,
  card_gifts = {},
  continue_card = false,
  blackmarket = {items = {}, time = 0},
  blackmarket_times = 0,
  time_gift = 0,
  tgift_time = 0,
  buy_time_gift = false,
  buy_daily_gift = false,
  bless_time = 0,
  army_food_up = 0,
  last_login_time = 0,
  login_days = 0,
  acc_gift = false,
  check_ins = {},
  open_online_gift = false,
  check_in_time = 0,
  first_login_time = 0,
  created_at = 0,
  low_ogift_times = 0, -- 低级在线奖励的次数
  mid_ogift_times = 0, -- 中级在线奖励的次数
  high_ogift_times = 0, -- 高级在线奖励的次数
  max_monster_level = 0,
  c_building_up = {}, -- 确认建筑升级
  order_times = {}, -- 购买各个订单次数
  buy_ac_times = 0,
  wild_build = {},
  war_events = {},
  item_status = {},
  mail_count = 0,
  get_binded_reward = false,
  binded = false,
  gc_id = '',
  language = 1, --语言
  send_mail_count = 0,
  consume_wood = 0,
  consume_stone = 0,
  server_name = "",
  chest_detail_expire = 0, -- 细分宝箱过期时间
  detail_chest = 0, -- 细分宝箱商品
  daily_order_times = {}, -- 当日购买的商品
  std_chests = {}, -- 已经随机到的标准宝箱商品
  detail_chests = {}, -- 已经随机到的细分宝箱商品
  std_chests_shop = {}, -- 标准宝箱商品
  next_detail_chest = 0, -- 下一次出现的细分宝箱商品
  next_detail_chest_time = 0, -- 下一次出现的细分宝箱商品的时间
  show_sale_chest = false,
  rating_pop_type = 0, -- type may be 1, 2, 3 is click no
  has_ratinged = false,
  is_need_show_pop_rating = true,
  uresearches = {},
  device_name = '',
  cty_id = '',
  purchase_level = 1,
  purchase = 0, -- 付费总额
  wild_push = true,
  union_push = true,
  person_push = true,
  tcard_checkin = {},
  card_type = 'week',
  rev_tcard = false,
  new_player_shop = BasicConst.NEW_PLAYER_SHOP_1,
}

User = M

M.__CONTAINER = {}


function M:save(land)
  self:update(land)
end

function M:update(land)
  local attr = self:attributes()
  skynet.send('data_cache', 'lua', 'save', self._id, attr)
  if land then
    skynet.send('database', 'lua', 'user', 'update', attr)
  end
  return true
end

function M:attributes(  )
  local attrs = {}
  for i,v in pairs(DEFAULT) do
    if not string.find(i, "__") and type(v) ~= "function" then
      attrs[i] = self[i]
    end
  end
  attrs = Tool:clone(attrs)
  return attrs
end
