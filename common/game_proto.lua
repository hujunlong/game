local proto = {}

local types = [[

.equip_bag {
    uid      0 : integer
    amount   1 : integer
}

.package {
    type        0 : integer
    session     1 : integer
}

.account {
    uid         0 : string
    head        1 : integer
    user_name   2 : string
    level       3 : integer
    world       4 : string
}

.gateway_req {
    platform     0 : string
    clientv      1 : string
    country_id   2 : string
}

.bind_req_info {
    id          0 : string
}

.switch_server_req {
    server_id 0 : string
}

.server_info {
    udid    0 : string
    ip      1 : string
    port    2 : integer
    name    3 : string
}

.server {
    uid     0 : string
    name    1 : string
    time    2 : integer
    king    3 : string
    ip      4 : string
    port    5 : integer
    lang    6 : string
}

.skill  {
    uid         0 : integer
    config_id   1 : integer
    level       2 : integer
    cur_t       3 : *string
    next_t      4 : *string
    index       5 : integer
}

.effect  {
    effect_id   0 : integer
    num         1 : string
}

.equip  {
    uid         0 : integer
    config_id   1 : integer
    exp         2 : integer
    level       3 : integer
    valid       4 : boolean
    effects     5 : *effect(effect_id)
}

.position {
    x   0 : integer
    y   1 : integer
    uid 2 : integer
}

.resource {
    gold            0 : integer
    wood            1 : integer
    food            2 : integer
    ore             3 : integer
    stone           4 : integer
    gem             5 : integer
    item            6 : integer
}
.camp_resource {
    gold            0 : integer
    wood            1 : integer
    food            2 : integer
    ore             3 : integer
    stone           4 : integer
    gem             5 : integer
    item            6 : string
}

.reward_info {
    resource    0 : resource
    items       1 : *item_info
}
.army {
    _id             0 : integer
    amount          1 : integer
    uid             2 : integer
    config_id       3 : integer 
    might           4 : integer
    injured         5 : integer
    wild            6 : integer
    resources       7 : resource
    damage          9 : integer
    left            10 : integer
    s_id            11 : string
    id              12 : integer
    lost            13 : integer    # mail for reinforce
}

.hero_poss_info {
    uid         0 : integer
    exist       1 : boolean
    hero_id     2 : integer
}
.hero {
    exist           0 : boolean
    uid             1 : integer 
    config_id       2 : integer
    star            3 : integer 
    quality         4 : integer
    level           5 : integer
    exp             6 : integer
    nexp            7 : integer
    pos             8 : integer         
    skills          9 : *skill
    sp              10 : integer
    equipments      11 : *equip
    status          12 : integer
    talent          13 : integer 
    talent_effects  14 : skill
    effects         15 : *effect(effect_id)
    position        16 : position 
    work            17 : integer
    is_defender     18 : boolean
    equip_bag       19 : *equip_bag
}

.order_info {
    id          0 : integer
    order       1 : integer
    type        2 : string
    price       3 : string
    gems        4 : integer
    gift        5 : integer
    uid         6 : string
    time        7 : integer
    gift_type   8 : integer
    hot         9 : boolean
    buy         10 : boolean
    item_id     11  : integer
    product_id  12  : string
    valid       13  : boolean
}

.buff_info {
    item_id         0 : integer
    start_time      1 : integer
    finish_time     2 : integer
    config_buff_id  3 : integer
    uid             4 : integer
    times           5 : integer
    _del            6 : boolean
}

.key_info {
    building        0 : integer
    skill           1 : integer 
    equipment       2 : integer
    quest           3 : integer 
    hero            4 : integer 
    bookmark        5 : integer
}

.science_info {
    uid         0 : integer
    level       1 : integer
}
.can_scout_info {
    armies      0 : boolean
    hero        1 : boolean
    science     2 : boolean
    city        3 : boolean
    reserches   4 : boolean
    event_type  5 : integer
}
.attack_warning_info {
    uid             0 : string
    user_name       1 : string
    s_union_name    2 : string
    union_name      3 : string
    level           4 : integer
    unit_count      5 : integer
    might           6 : integer
    armies          7 : *army
    hero            8 : hero
    science         9 : *science_info
    city            10 : city_info
    category        11 : integer
    start           12 : integer
    arrival         13 : integer
    from_pos        14 : position
    reserches       15 : *science_info
    can_scout_info  16 : can_scout_info
    _del            17 : boolean
    start_time      18 : integer
    rally_number    19 : integer
}
.time_worth_info {
    _id         0 : integer    
    build       1 : integer
    cure        2 : integer
    level       4 : integer
    max         5 : integer
    min         6 : integer
    research    7 : integer
    train       8 : integer
}

.func_info {
    lock   0 : boolean
    uid    1 : integer
}

.gamble_item_info {
    get     0 : boolean
    item    1 : item_info
    uid     2 : integer
    index   3 : integer
    level   4 : integer
}
.gamble_info {
    coins       0 : integer
    items       1 : *gamble_item_info
    need_coins  2 : integer
    times       3 : integer
}

.proc_info {
    name        0 : string
    time        1 : integer
    item_id     2 : integer
    amount      3 : integer
}
.online_reward_info {
    items       0 : *item_info
    proc        1 : *proc_info  
}

.city_broken_info {
    show            0 : boolean
    user_name       1 : string
    level           2 : integer
    union_name      3 : string
    s_union_name    4 : string
    might           5 : integer
    from_pos        6 : position
    move_pos        7 : position
    start_time      8 : integer
}

.quest_info {
    uid             0 : integer
    config_id       1 : integer
    cur             2 : integer
    max             3 : integer
    deadline        4 : integer
    status          5 : integer
    target          6 : integer
    _del            7 : boolean
}
.server_config_info {
    server_time    0 : integer
    time_zone       1 : integer
    is_test         2 : boolean
    is_line_map     3 : boolean
    enable_cave     4 : boolean
}
.cards_info {
    extra_gems      0 : integer
    extra_item_id   1 : integer
    finish_time     2 : integer
    gems            3 : integer
    is_continue     4 : boolean
    is_first_week   5 : boolean
    item_id         6 : integer
    items           7 : *item_info
    status          8 : integer
    checkin         9 : integer
    max_checkin     10 : integer
    can_checkin     11 : boolean
    card_type       12 : string
}
.achivement_info {
    cur     0 : integer
    max     1 : integer
    uid     2 : integer
    status  3 : integer
}
.vip_info {
    exp         0 : integer
    level       1 : integer
    time        2 : integer
}
.share_mail_info {
    mail_uid    0 : string
    mail_type   1 : string
}

.chat_info {
    content         0 : string
    head            1 : integer
    s_union_name    2 : string
    time            3 : integer
    uid             4 : string
    user_id         5 : string
    user_name       6 : string
    msg_type        7 : string
    title           8 : integer
    type            9 : integer
    share_mail      10: share_mail_info
    union_id        11 : string
}
.all_effects_info {
    Attack  0 : integer
    AttackPercent   1 : integer
    Life    2 : integer
    LifePercent 3 : integer
    Armor   4 : integer
    ArmorPercent    5 : integer
    Crit    6 : integer
    Multistrike 7 : integer
    Resistance  8 : integer
    Tenacity    9 : integer
    Load    10 : integer
    LoadPercent 11 : integer
    MarchSpeed  12 : integer
    GatheringSpeed  13 : integer
    ConstructionSpeed   14 : integer
    ReasearchSpeed  15 : integer
    TrainingSpeed   16 : integer
    SkillHitRate    17 : integer
    SkillProcChance 18 : integer
    Damage  19 : integer
    AmplifyDamage   20 : integer
    Dizzy   21 : integer
    UnitAttackReducePer 22 : integer
    DamageMonsterImprove    23 : integer
    ReduceCureTime  24 : integer
    OfficerSkillGetItem 25 : integer
    IncreaseCureCost    26 : integer
    ReduceResearchTime  27 : integer
    ResourcePlunder 28 : integer
    IncreaseAttributePer    29 : integer
    DamageImmunity  30 : integer
    ChanceFreeBattle    31 : integer
    ExtraResource   32 : integer
    MarchSpeedForMonster    33 : integer
    ChaseDamage 34 : integer
    HeroExpGained   35 : integer
    FoodProduction  36 : integer
    WoodProduction  37 : integer
    StoneProduction 38 : integer
    OreProduction   39 : integer
    GoldProduction  40 : integer
    AllProduction   41 : integer
    PeaceShield 42 : integer
    ReduceUpkeep    43 : integer
    AntiScout   44 : integer
    IncreaseMaxMarch    45 : integer
    FaleseArmy  46 : integer
    BuffAttack  47 : integer
    BuffDefense 48 : integer
    DoubleAttack    49 : integer
    DoubleArmor 50 : integer
    SpeedOfLight    51 : integer
    SpiritProtection    52 : integer
    EnergyRecover   53 : integer
    FoodGatherSpeed 54 : integer
    WoodGatherSpeed 55 : integer
    StoneGatherSpeed    56 : integer
    OreGatherSpeed  57 : integer
    GoldGatherSpeed 58 : integer
    WarehouseResourceProduction 59 : integer
    FootmanAttackPer    60 : integer
    MageAttackPer   61 : integer
    ArcherAttackPer 62 : integer
    CatapultAttackPer   63 : integer
    KnightAttackPer 64 : integer
    FootmanHpPer    65 : integer
    MageHpPer   66 : integer
    ArcherHpPer 67 : integer
    CatapultHpPer   68 : integer
    KnightHpPer 69 : integer
    FootmanArmorPer 70 : integer
    MageArmorPer    71 : integer
    ArcherArmorPer  72 : integer
    CatapultArmorPer    73 : integer
    KnightArmorPer  74 : integer
    FootmanOverkill 75 : integer
    MageOverkill    76 : integer
    ArcherOverkill  77 : integer
    CatapultOverkill    78 : integer
    KnightOverkill  79 : integer
    IncreaseMarchingTroop   80 : integer
    IncreaseBlackAreaMarchSpeed 81 : integer
    ReduceEnemyMagicTowerDamagePer  82 : integer
    ReduceEnemyCatapultDamagePer    83 : integer
    UnlockUnit  84 : integer
    TrainingVolume  85 : integer
    FootmanLoad 86 : integer
    MageLoad    87 : integer
    ArcherLoad  88 : integer
    CatapultLoad    89 : integer
    KnightLoad  90 : integer
    UnitInjuredReduce   91 : integer
    HospitalCapacity    92 : integer
    Energy  93 : integer
    TurretTrainingSpeed 94 : integer
    ArcherTowerTrainingSpeed    95 : integer
    MageTowerTrainingSpeed  96 : integer
    TurretAttackPer 97 : integer
    TurretHpPer 98 : integer
    TurretArmorPer  99 : integer
    ArcherTowerAttackPer    100 : integer
    ArcherTowerHpPer    101 : integer
    ArcherTowerArmorPer 102 : integer
    MageTowerAttackPer  103 : integer
    MageTowerHpPer  104 : integer
    MageTowerArmorPer   105 : integer
    HealCostPer 106 : integer
    CampCanUse  107 : integer
    AllianceMember  108 : integer
    AllianceQuestQuantity   109 : integer
    RallyPlayer 110 : integer
    RallyTroop  111 : integer
    AllianceHelpTime    112 : integer
    ReinforceMarchingSpeed  113 : integer
    ReinforceTroop  114 : integer
    Tax 115 : integer
    IncreaseCatapultDamagePer   116 : integer
    IncreaseTurretDamagePer 117 : integer
    IncreaseArchertowerDamagePer    118 : integer
    IncreaseMagetowerDamagePer  119 : integer
    IncreaseCampVolume  120 : integer
    ReduceTurretDamagePer   121 : integer
    ReduceArchertowerDamagePer  122 : integer
    AllianceResearchSpeedPer    123 : integer
    RallyMarchingSpeed  124 : integer
    IncreaseTradeCapacity   125 : integer
    IncreaseTradeMarchingSpeed  126 : integer
    IncreaseAllianceHelpTime    127 : integer
    IncreaseContributionGainPer 128 : integer
    IncreaseDamageToCitylife    129 : integer
    MaxDefenseUnit  130 : integer
    SkillDamage 131 : integer
    Skill31009Damage    132 : integer
    Skill31012IncreaseDamagePer 133 : integer
    Mark    134 : integer
    Raid    135 : integer
    OracleMark  136 : integer
    CaveExplore 137 : integer
    CaveBattle  138 : integer
    PVPMarchingSpeed    139 : integer
    InfantryInjuredPer  140 : integer
    MageInjuredPer  141 : integer
    ArcherInjuredPer    142 : integer
    CatapultInjuredPer  143 : integer
    CavalryInjuredPer   144 : integer
    CampMarchingSpeed   145 : integer
    TurretOverkill  146 : integer
    ArcherTowerOverkill 147 : integer
    MageTowerOverkill   148 : integer
    CityLife    149 : integer
    CityFireDebuff  150 : integer
    FreeRecoverCityHealth   151 : integer
    Skill31016Mark  152 : integer
    BarracksUnitOverKill    153 : integer
    WeatherForecast 154 : integer
    StorageProtectFood  155 : integer
    InfantryUpkeepReduce    156 : integer
    MageUpkeepReduce    157 : integer
    ArcherUpkeepReduce  158 : integer
    CavalryUpkeepReduce 159 : integer
    CatapultUpkeepReduce    160 : integer
    CityBurningTime 161         : integer
    HealSpeedPer 162         : integer
    HospitalCapacityPer 163  : integer
}

.event_info {
    tag         0 : integer
    uid         1 : string
    start_time  2 : integer
    finish_time 3 : integer
    action      4 : integer
    from_pos    5 : position
    to_pos      6 : position
    pre_uid     7 : string
    is_win      8 : boolean
    status      9 : integer
    gem         10 : integer
    time        11 : integer
    end_time    12 : integer
}
.user {
    user_name                   0 : string
    heroes                      1 : *hero
    uid                         2 : string
    gem                         3 : integer
    head                        4 : integer
    desc                        5 : string
    ac                          6 : integer
    updated_ac_time             7 : integer
    ac_durantion                8 : integer
    fb_id                       9 : string
    sex                         10 : integer
    gold                        11 : integer
    food                        12 : integer
    wood                        13 : integer
    stone                       14 : integer
    ore                         15 : integer
    max_ac                      16 : integer
    items                       17 : *item_info
    quests                      18 : *quest_info
    fquests                     19 : *quest_info
    buildings                   20 : *building_info
    poss                        21 : *integer
    arms                        22 : *integer
    armies                      23 : *army
    assists                     24 : *army
    city                        25 : position      #TODO, maybe will del
    might                       26 : integer
    might_rank                  27 : integer
    union_id                    28 : string
    union_pos                   29 : integer
    union_name                  30 : string
    s_union_name                31 : string
    union_contribution          32 : integer
    union_tech_cd               33 : integer
    level                       34 : integer
    kill_units                  35 : integer
    bp                          36 : integer
    bp_rank                     37 : integer
    wins                        38 : integer
    loses                       39 : integer
    a_wins                      40 : integer
    a_loses                     41 : integer
    d_wins                      42 : integer
    d_loses                     43 : integer
    lose_units                  44 : integer
    c_units                     45 : integer
    scout_times                 46 : integer
    win_rate                    47 : integer
    achiv_rate                  48 : integer
    vip                         49 : integer
    cb_score                    50 : integer
    hero_score                  51 : integer
    hero_rank                   52 : integer
    b_free_t                    53 : integer
    x                           54 : integer
    y                           55 : integer
    hero_pos_cd                 56 : integer
    build_events                57 : *building_event
    bookmarks                   58 : *bookmark_info
    city_broken                 59 : *city_broken_info
    attack_warnings             60 : *attack_warning_info
    keys                        61 : key_info
    buffs                       62 : *buff_info
    d_online                    63 : integer
    r_online_t                  64 : integer
    r_quest_id                  65 : integer
    vip_exp                     66 : integer
    titles                      67 : *integer
    title                       68 : integer 
    hero_pvp_count              69 : integer
    kill_monster_count          70 : integer
    can_attack_monster_level    71 : integer
    pvp_win_count               72 : integer
    pre_weather                 73 : integer
    researches                  74 : *integer
    r_life_cd                   75 : integer
    r_updated_at                76 : integer
    guide                       77 : integer
    pending_guide               78 : integer
    tguide                      79 : *boolean
    guide_wild                  80 : boolean
    pit_groups                  81 : *build_pit_info
    funcs                       82 : *boolean
    main_quest                  83 : integer
    orders                      84 : *order_info
    max_queue                   85 : integer
    cur_queue                   86 : integer
    daily_online_rewards        87 : integer
    gamble_items                88 : *gamble_item_info
    gamble_times                89 : integer
    total_gamble_times          90 : integer
    first_week_card             91 : boolean
    card_time                   92 : integer
    extra_card                  93 : boolean
    card_gifts                  94 : *item_info
    blackmarket                 95 : blackmarket_info
    blackmarket_times           96 : integer
    time_gift                   97 : integer
    buy_time_gift               98 : boolean
    buy_daily_gift              99 : boolean
    can_invite                  100 : boolean
    hero_count                  101 : integer
    tower_count                 102 : integer
    unit_count                  103 : integer
    world                       104 : integer
    online_reward_time          105 : integer
    army_food_up                106 : integer
    last_login_time             107 : integer
    login_days                  108 : integer
    acc_gift                    109 : boolean
    check_ins                   110 : *integer  #maybe have problem, but not send client
    open_online_gift            111 : boolean
    check_in_time               112 : integer
    first_login_time            113 : integer
    created_at                  114 : integer
    low_ogift_times             115 : integer
    mid_ogift_times             116 : integer
    high_ogift_times            117 : integer
    max_monster_level           118 : integer
    tgift_time                  119 : integer
    max_armies                  120 : integer
    buy_ac_times                121 : integer
    max_camps                   122 : integer
    acc_end_time                123 : integer
    cave_pos                    124 : position
    union_reward                125 : boolean
    get_binded_reward           126 : boolean
    binded                      127 : boolean
    temple_pos                  128 : position
    language                    129 : integer
    passport                    130 : string
    show_sale_chest             131 : boolean
    purchase_level              132 : integer
    wild_push                   133 : boolean
    union_push                  134 : boolean
    person_push                 135 : boolean
}

.weather_info {
    type        0 : integer
    time        1 : integer
}
.research_info {
    uid         0 : integer
    level       1 : integer
    time        2 : integer
}
.building_event {
    uid         0 : integer
    start_time  1 : integer
    finish_time 2 : integer
    work        3 : integer
    train       4 : integer
    status      5 : integer
    can_help    6 : boolean
    building_id 7 : integer
    gem         8 : integer
    time        9 : integer
    end_time    10 : integer
    _id         11 : integer
}
.building_arms_info {
    uid         0 : integer
    level       1 : integer
    category    2 : integer
    lock        3 : boolean
}
.building_spec_info {
    income          0 : integer
    capacity        1 : integer
    updated_time    2 : integer
    amount          3 : integer
    res             4 : string
    arms            5 : *building_arms_info
}
.pit_info  {
    level       0 : integer
    lock        1 : boolean
    pits        2 : *integer
    resources   3 : resource
    uid         4 : integer
}
.build_pit_info {
    uid             0 : integer
    exist           1 : boolean
    b_id            2 : string
    lock            3 : boolean
}

.hero_pos_info {
    uid             0 : integer
    exist           1 : boolean
    lock            2 : boolean
    hero_id         3 : integer
}
.speed_info {
    item_id         0 : integer
    start_time      1 : integer
    finish_time     2 : integer
    num             3 : integer
}
.building_info {
    uid             0 : integer
    config_id       1 : integer
    level           2 : integer
    status          3 : integer
    work            4 : integer
    start_time      5 : integer
    finish_time     6 : integer
    specs           7 : building_spec_info
    train           8 : integer
    speed_num       9 : integer
    can_help        10 : boolean
    max_train       11 : integer
    hit             12 : boolean
    pit             13 : integer
    armies          14 : *army
    event_id        15 : string
    help_times      16 : integer
    _del            17 : boolean
    has_survice     18 : boolean
    speed           19 : speed_info
    survive         20 : *army
    once_train      21 : integer
    work_time       22 : integer
    speed_up_gems   23 : integer
    
}
.city_fire_info {
    start           0 : integer
    finish          1 : integer
    lose            2 : integer
    lose_time       3 : integer
}
.city_info {
    build_queue     0 : integer
    march_queue     1 : integer
    max_life        2 : integer
    life            3 : integer
    recover         4 : integer
    updated_at      5 : integer
    r_life_cd       6 : integer
    item_id         7 : integer
    fire            8 : city_fire_info
    name            9 : string
    level           10 : integer 
    pos             11 : position
    fix             12 : integer
}


.bonus_info {
    num     0 : integer
    rate    1 : integer
}
.city_overview_info {
    uid                 0 : string
    produce             1 : integer
    consume             2 : integer
    config_id           3 : integer
    vip_bonus           4 : bonus_info
    science_bonus       5 : bonus_info
    officer_bonus       6 : bonus_info
    buff_bonus          7 : bonus_info
    consume_updated_at  8 : integer
}

.assist_info {
    uid         0 : string
    user_name   1 : string
    head        2 : integer
    armies      3 : *army
    _del        4 : boolean
}

# -----------------battle result ---------------
.battle_user_info {
    kills       0 : integer
    total       1 : integer
    injured     2 : integer
    uid         3 : integer
    damage      4 : integer
    might       5 : integer
    lost        6 : integer
    amount      7 : integer
    survive     8 : integer
    lostMight   9 : integer
    totalMight  10 : integer
    rally_num   11 : integer

}
.battle_skill {
    uid         0 : integer
    num         1 : integer
    whether_damage 2 : integer
}
.battle_hero {
    ori_level       0 : integer
    quality         1 : integer
    cur_level       2 : integer
    star            3 : integer
    damage          4 : integer
    uid             5 : integer
    skills          6 : *battle_skill
    get_xp          7 : integer
    cur_xp          8 : integer
    damgePercent    9 : integer
    skill_hurt      10 : *bl_hero_info
    ori_xp          11 : integer
}
.allies_info {
    damage  0 : integer
    total   1 : integer
    amount  2 : integer
    injured 3 : integer
    survive 4 : integer
    lost    5 : integer
    hero_id 6 : integer
}

.bl_hero_info {
    skill_id  0 : integer
    kill_num  1 : integer
    damage    2 : integer
    whether_damage 3 : integer
    success        4 : boolean
    effect_target   5 : integer
}
.bl_hero {
    attacker  0 : *bl_hero_info(skill_id)
    defender  1 : *bl_hero_info(skill_id)
}

.bl_units_info {
    uid         0 : integer
    left        1 : integer
    kill_num    2 : integer
}
.battle_log_info {
    hero        0 : bl_hero
    defender    1 : *bl_units_info
    attacker    2 : *bl_units_info
}

.battle_buff_log {
    category        0 : integer
    buff_type       1 : integer
    effect          2 : integer
}
.battle_user_total_info {
    armies  0 : *battle_user_info
    allies  1 : allies_info 
    hero    2 : *battle_hero
}

.battle {
    attacker        0 : battle_user_total_info
    defender        1 : battle_user_total_info
    attacker_grade  2 : string
    defender_grade  3 : string
    win             4 : boolean
    battle_log      5 : *battle_log_info
    atk_buff_log    6 : *battle_buff_log
    def_buff_log    7 : *battle_buff_log
    has_battle_log  8 : boolean
}

# ------------------mail data ------------------
.mail_list_info_detail_battle {
    win 0 : boolean
}
.buff_id {
    id 0 : integer
}

.mail_list_info_detail_union {
    union_action    0 : integer
    union_name      1 : string
    banner          2 : integer
    s_union_name    3 : string
    members         4 : integer
    max_members     5 : integer
    might           6 : integer
    leader          7 : string
    language        8 : integer
    union_id        9 : string
    union_pos       10 : integer
    logo            11 : integer
}

.mail_list_info_detail {
    gold            0 : integer
    wood            1 : integer
    food            2 : integer
    ore             3 : integer
    stone           4 : integer
    def_id          5 : integer
    level           6 : integer
    battle          7 : mail_list_info_detail_battle
    subtype         8 : integer
    atk_user_id     9 : string
    atk_name        10 : string
    defer_user_id   11 : string
    def_name        12 : string
    user_name       13 : string
    logid           14 : integer
    content         15 : string
    pos             16 : position
    count           17 : integer
    is_suc          18 : boolean
    buf_id          19 : buff_id
    is_get          20 : boolean
    winner          21 : string
    depth           22 : integer
    can_collecte_gift 23 : boolean
    union           24 : mail_list_info_detail_union
    target_name     25 : string
    gem             26 : integer
    total_lost      27 : integer
    tile_type       28 : integer
    tile_level      29 : integer
    is_fly          30 : boolean
    total_injured   31 : integer
    is_anit_scout   32 : boolean
    is_join         33 : boolean
}

.mail_list_info {
    uid             0 : string
    time            1 : integer
    gift            2 : integer
    new_count       3 : integer
    mail_count      4 : integer
    link_mail_id    5 : string 
    mail_type       6 : integer
    title           7 : string
    detail          8 : mail_list_info_detail
    is_have_gift    9 : boolean
    sender          10 : string
    _del            11 : boolean
}   

.item_info {
    item_id      0 : integer
    amount      1 : integer
    uid         2 : integer
    get         3 : boolean
    price_t     4 : string
    price_a     5 : string
    best        6 : boolean
    id          7 : integer
    num         8 : integer
    is_new      9 : boolean
}

.scout_hero {
    hero_id     0 : integer
}
.scout_hero_detail {
    hero_id     0 : integer
    star        1 : integer
    level       2 : integer
}
.scour_tech_detail {
    research_id     0 : integer
    level           1 : integer
}
.scout_building_detail {
    building_id     0 : integer
    level           1 : integer
}

.scout_battle_effect {
    effect_id       0 : integer
    num             1 : integer
}

.scout_shield_info {
    defer_count     0 : integer
    defer_type      1 : *integer
    defer_detail    2 : *army
}
.scout_res_info {
    total_res       0 : integer
    detail_res      1 : resource
}
.scout_garrison_info {
    armies_count    0 : integer
    armies_type     1 : *integer
    armies_deail    2 : *army
}
.scout_allies_info {
    allies_amount   0 : integer
    allies_type     1 : *integer
    allies_detail   2 :  *army
}
.scout_hero_info {
    hero_info       0 : scout_hero
    hero_detail     1 : scout_hero_detail
}
.scout_build_info {
    build_detail        0 : *scout_building_detail
}
.scout_tech_info {
    type            0 : *integer
    battle_tech_detail  1 : *scour_tech_detail
}

.scout_battle_info {
     battle_effect       0 : *scout_battle_effect
}
.scout_detail_list {
    is_anit_scout       0 : boolean
    shield              1 : scout_shield_info
    res                 2 : scout_res_info
    garrison            3 : scout_garrison_info
    allies              4 : scout_allies_info 
    hero                5 : scout_hero_info
    build_info          6 : scout_build_info
    tech                7 : scout_tech_info
    gain                8 : scout_battle_info
}
.cave_floor_info {
    item        0 : *item_info
    resources   1 : resource

}
.cave_reward {
    res         0 : *cave_floor_info
    floor_count 1 : integer
}

.cave_user_info {
    user_name   0 : string
    head        1 : integer
    union_name  2 : string
    s_union_name 3 : string
}
.cave_explore_times {
    current     0 : integer
    max         1 : integer
}
.pvp_info {
    attacker        0 : cave_user_info
    defender        1 : cave_user_info
}

.cave_results {
    battle      0 : battle
    depth       1 : integer
    injures     2 : integer
    time        3 : integer
    pvpInfo     4 : pvp_info
    rob_gold    5 : integer
}
.mail_content {
    uid             0 : string
    title           1 : string
    time            2 : integer
    detail          3 : string
    gift            4 : *item_info
    type            5 : integer
    pos             6 : position
    level           7 : integer
    resource        8 : resource
    item            9 : *item_info
    reward          10 : cave_reward
    result          11 : cave_results            #expolre content
    buf_id          12 : integer            #temple buf
    subtype         13 : integer
    count           14 : integer
    is_suc          15 : boolean
    user_id         16 : string   # chat
    logid           17 : integer
    user_name       18 : string
    union_name      19 : string
    content         20 : string
    atk_home_city   21 : position           #pvp info
    atk_user_id     22 : string
    atk_logid       23 : integer
    atk_name        24 : string
    atk_title       25 : string  
    def_home_city   26 : position
    def_user_id     27 : string
    def_logid       28 : integer
    def_name        29 : string
    def_title       30 : string
    atk_type        31 : integer
    target_name     32 : string
    battle          33 : battle
    mail_type       34 : integer
    target          35 : string
    battle_point    36 : integer
    target_pos      37 : position
    s_union_name    38 : string         #scout
    server          39 : string
    build_type      40 : integer        # this is tile category
    info            41 : scout_detail_list
    grade           42 : string         #pve
    def_id          43 : string
    is_winner       44 : boolean
    read_status     45 : integer
    is_get          46 : boolean        #trade
    _del            47 : boolean
    armies          48 : *army          #reinforce
    sender          49 : string
    can_collecte_gift 50 : boolean
    tile_type       51 : integer
    tile_level      52 : integer
    responsed       53 : boolean
    total_lost      54 : integer
    is_fly          55 : boolean
    total_injured   56 : integer
    is_anit_scout   57 : boolean
    is_join         58 : boolean
}

.mail_detail_content {
    mail_content    0 : *mail_content
    uid             1 : string
    new_count       2 : integer
    _del            3 : boolean
    gift            4 : integer
    responsed       5 : boolean
    detail          6 : mail_list_info_detail
    time            7 : integer
}

# ---------------------wild -----------------------
.map_tile_info {
    id          0 : string
    category    1 : integer
    level       2 : integer
    life        3 : integer
    total_life  4 : integer
    protected   5 : boolean
    tag         6 : integer
    name        7 : string
    owner       8 : string
    camp_index  9 : integer
    start_time  10 : integer
    speed       11 : string
    x           12 : integer
    y           13 : integer
    _id         14 : string
    might       15 : integer
    armies      16 : *army
    amount      17 : integer
    build_index 18 : integer
    owner_id    19 : string
    user_id     20 : string
    uid         21 : string
    owner_name  22 : string
    delay       23 : boolean
    hero_id     24 : integer
    hero        25 : integer
    type        26 : integer
    _del        27 : boolean
    fire_end_time   28 : integer
    flag        29 : integer    #联盟旗帜bg
    capacity    30 : integer
    origin_x    31 : integer
    origin_y    32 : integer
    pos         33 : integer    #ally union_pos
    _replace    34 : boolean
    heroes      35 : *integer
    max_hero    36 : integer
    logo        37 : integer    #联盟旗帜logo
}

.war_event_detail {
    uid         0 : string
    armies      1 : *army
    hero_id     2 : integer
}

.pre_skill_info {
    id          0 : integer
    damage      1 : integer
    fail        2 : boolean
}
.pre_results_user_info {
    total       0 : integer
    lost        1 : integer
    armies      2 : *army(s_id)
    skills      3 : *pre_skill_info
    level_up    4 : boolean      
}
.pre_result_info {
    atk         0 : pre_results_user_info
    def         1 : pre_results_user_info
    items       2 : *integer      
}
.back_pos       {   #召回集火部队
    x           0 : string
    y           1 : string
}
.war_events_info {
    tag         0 : integer
    uid         1 : string
    start_time  2 : integer
    finish_time 3 : integer
    action      4 : integer
    from_pos    5 : position
    to_pos      6 : position
    pre_uid     7 : string
    is_win      8 : boolean
    hero_id     9 : integer
    soldiers    10 : *integer
    pre_result  11 : pre_result_info
    _del        12 : boolean
    is_buff_activated   13 : boolean
    is_level_limit      14 : boolean
    from_dec    15 : integer    #from decoration type
    to_dec      16 : integer    #to decoration type
    join        17 : boolean
    back_pos    18 : back_pos
    alpha       19 : integer
}
.map_hero_info {
    uid         0 : integer
    position    1 : position
    work        2 : integer
}
.guide_info {
    uid         0 : integer
    active      1 : boolean
    x           2 : integer
    y           3 : integer
}
.wild_march_info {
    map         0 : *map_tile_info
    war_events  1 : *war_events_info
    heroes      3 : *map_hero_info
    guide       4 : *guide_info
}
.camp_upgrade_info {
    level           0 : integer
    capacity        1 : build_upgrade_info
    hp              2 : build_upgrade_info
    requirements    3 : camp_resource
    heroes          4 : build_upgrade_info
}

.user_ac_info {
    ac              0 : integer
    uid             1 : string
    ac_duration     2 : integer
    updated_ac_time 3 : integer   
}

.build_upgrade_info {
    current     0 : integer
    next        1 : integer
    extra       2 : integer
}
.bookmark_info {
    uid         0 : integer
    _del        1 : boolean
    k           2 : integer
    x           3 : integer
    y           4 : integer
    t           5 : integer
    desc        6 : string
    time        7 : integer
}

.temple_info {
    last_rune       0 : string
    reaver          1 : string
    cool_down       2 : integer
}
.march_error {
    info            0 : string
    max             1 : integer
    vip_max         2 : integer
}

.wild_reinforce_info {
    name        0 : string
    amount      1 : integer
    capacity    2 : integer
    x           3 : integer
    y           4 : integer
}

.wild_scout_info {
    cost        0 : integer
    time        1 : integer
    head        2 : integer
    name        3 : string
    x           4 : integer
    y           5 : integer
}

.rank_info {
    uid             0 : string
    has_union       1 : boolean
    union_name      2 : string
    s_union_name    3 : string
    umight_rank     4 : integer
    ubp_rank        5 : integer
    might_rank      6 : integer
    bp_rank         7 : integer
    hero_c_rank     8 : integer
    building_rank   9 : integer
    title           10 : integer
    head            11 : integer
    user_name       12 : string
    bp              13 : integer
    rank            14 : integer
    might           15 : integer
    cb_score        16 : integer
    hero_score      17 : integer
    flag            18 : integer
    leader          19 : string
    user_id         20 : string
    logo            21 : integer
}

# this now use for user and build handler
.request_msg {
    pit                 0 : integer
    c_building_id       1 : integer
    reqid               2 : integer
    building_id         3 : integer
    army_id             4 : integer
    amount              5 : integer
    id                  6 : integer
    group               7 : string
    to_build_id         8 : integer
    armies              9 : *army
    user_id             10 : string
    pos                 11 : *position         # unused now
    top                 12 : position
    rowNum              13 : integer
    colNum              14 : integer
    title_id            15 : integer
    fb_id               16 : string
    index               17 : integer
    res                 18 : resource
    token               19 : string            # token received from the login server
    acc_id              20 : integer
    item_type           21 : *integer
    platform            22 : string
    clientv             23 : string
    country_id          24 : string
    server_name         25 : string
    rating_pop_type     26 : integer
    device_id           27 : string
    res_ver             28 : string
    device_token        29 : string
    locale              30 : string
    device_name         31 : string
    cty_id              32 : string
    event_id            33 : string
    push_opt            34 : integer
    is_open             35 : boolean
    center              36 : position
}

.equip_req_msg {
    hero_id         0 : integer
    equip_index     1 : integer
    equip_id        2 : integer
    items           3 : *item_info
    id              4 : integer
    reqid           5 : integer
}

.hero_req_msg {
    hero_id         0 : integer
    skill_id        1 : integer
    pos             2 : integer
    id              3 : integer
    level           4 : integer
    reqid           5 : integer
}

.opts_info {
    building_id     0 : integer
    user_name       1 : string
    head            2 : integer
    desc            3 : string
    hero_id         4 : integer
}
.item_req_msg {
    shop        0 : integer
    id          1 : integer
    opts        2 : opts_info
    reqid       3 : integer
    amount      4 : integer
}

.quest_req_msg {
    id          0 : integer
    reqid       1 : integer
}

.research_req_msg {
    reqid       0 : integer
    cr_id       1 : integer
}

.wild_req_msg {
    reqid           0 : integer
    armies          1 : *army
    from_pos        2 : position
    to_pos          3 : position
    hero            4 : integer
    is_attack       5 : boolean
    uid             6 : string
    item_id         7 : integer
    x               8 : integer
    y               9 : integer
    explore_time    10 : integer
    id              11 : integer
    bookmark        12 : bookmark_info
    time            13 : integer
    res             14 : resource
    level           15 : integer
}
.rank_req_msg {
    reqid           0 : integer
    offset          1 : integer
    limit           2 : integer
    rank_name       3 : string
}

.search_union_req_msg {
    reqid           0 : integer
    name            1 : string
    rank_name       2 : string
}   

.search_user_req_msg {
    reqid           0 : integer
    name            1 : string
    rank_name       2 : string
    rank_value      3 : string
}

.chat_req_msg {
    reqid           0 : integer
    uid             1 : string
    content         2 : string
    channel         3 : integer
    msg_type        4 : string
    mail_uid        5 : string
    mail_type       6 : string
}

.mail_req_msg {
    reqid           0 : integer
    uid             1 : string
    mail_list       2 : *string
    mail_type       3 : string
    content         4 : string
    union_id        5 : string
    mail_uid        6 : string
    uid_list        7 : *string
    user_name       8 : string
    is_join         9 : boolean
    user_id         10 : string
    mail_index      11 : integer
    mail_offset     12 : integer
}

.helpme_info {
    helper          0 : string
    help_type       1 : integer
    build_type      2 : integer
    build_level     3 : integer
}

.city_event_info {
    type        0 : integer
    amount      1 : integer
    level       2 : integer
    config_id   3 : integer
    items       4 : *item_info
}

.mail_notice_info {
    new_mail_num    0 : integer
    is_new_mail     1 : boolean
    chat_user_id    2 : string
}

.hero_skill_trigger_info {
    config_id       0 : integer
    skill_id        1 : integer
    resources       2 : resource
    type            3 : integer
    item_id         4 : integer
    item_num        5 : integer
    effect_value    6 : string
}

.acc_check_in_gifts_info {
    items           0 : *item_info
    hero            1 : hero
    uid             2 : integer
    day             3 : integer
    type            4 : integer
    status          5 : integer
}

.blackmarket_info {
    items           0 : *item_info
    time            1 : integer
    max_times       2 : integer
    times           3 : integer
    gems            4 : integer
    refresh_time    5 : integer
}

.config_resource_worths_info {
    _id         0 : integer
    food        1 : string
    gold        2 : string
    ore         3 : string
    stone       4 : string
    wood        5 : string
}

.fb_info {
    uid                0 : string
    fb_id              1 : string
    user_name          2 : string
    level              3 : integer
    world              4 : integer
}

#--------------------union--------------------
.union_req_info {
    name        0 : string
    short_name  1 : string
    slogan      2 : string
    verify      3 : integer
    type        4 : integer
    value       5 : string
    building_id 6 : integer
    help_id     7 : string
    today       8 : integer
    id          9 : integer     # research uid
    ratio       10 : integer
    gems        11 : integer
    union_id    12 : string
    list        13 : *string    # help id
    uid         14 : string     # user uid
    pattern     15 : string
    limit       16 : integer
    num         17 : integer
    union_pos   18 : integer
}

.union_member {
    user_id         0 : string
    union_pos       1 : integer
    name            3 : string
    logid           4 : integer
    might           5 : integer
    online          6 : integer
    last_login_time 7 : integer
    language        8 : integer
    uid             9 : string
    _del            10 : boolean
    level           11 : integer
    _id             12 : string   # for sorted list
}

.union_members {
    leader      0 : union_member
    members     1 : *union_member(user_id)
}

.union_notice {
    time        0 : integer
    event       1 : integer
    user        2 : string
    manager     3 : string
    item_id     4 : integer
    item_num    5 : integer
    position    6 : integer
}

.union_info {
    uid             0 : string
    name            1 : string
    short_name      2 : string
    might           3 : integer
    might_rank      4 : integer
    bp              5 : integer
    bp_rank         6 : integer
    banner          7 : integer
    language        8 : integer
    member_count    9 : integer
    max_member      10 : integer
    leader          11 : union_member
    slogan          12 : string
    bulletin        13 : string
    notices         14 : *union_notice
    war_count       15 : integer
    help_count      16 : integer
    gift_count      17 : integer
    verify          18 : integer
    _del            19 : boolean
    logo            20 : integer
}

.union_atk_member {
    logid           0 : integer
    name            1 : string
    armies          2 : *army
    user_id         3 : string
}

.union_war_event {
    uid             0 : string
    atk_name        1 : string
    atk_pos         2 : position
    atk_log_id      3 : integer
    def_name        4 : string
    def_pos         5 : position
    def_log_id      6 : integer
    start_time      7 : integer
    end_time        8 : integer
    _del            9 : boolean
    atk_member      10 : *union_atk_member
    is_atker        11 : integer
    def_level       12 : integer
    is_march        13 : boolean
}

.union_war_history {
    time            0 : integer
    is_atk_win      1 : integer
    atk_name        2 : string
    atk_union       3 : string
    atk_pos         4 : position
    def_name        5 : string
    def_union       6 : string
    def_pos         7 : position
}

.order_buy_req {
    product_id 0 : string
    receipt    1 : string
    channel    2 : string
    xml        3 : string
}

.rally_target {
    dec             0 : integer
    level           1 : integer
}

.rally_detail {
    event_info      0 : string
    atk_name        1 : string
    atk_pos         2 : position
    atk_log_id      3 : integer
    def_name        4 : string
    def_pos         5 : position
    def_log_id      6 : integer
    start_time      7 : integer
    end_time        8 : integer
    hero            9 : hero
    target          10 : rally_target
    atk_member      11 : *union_atk_member
    max_amount      12 : integer
}

.rally_limit {
    amount          0 : integer
    players         1 : integer
}

.member_contribution {
    rank            0 : integer
    logid           1 : integer
    name            2 : string
    contribution    3 : integer
    title           4 : integer
}

.union_contribution_rank {
    history         0 : *member_contribution
    today           1 : *member_contribution
    weekly          2 : *member_contribution
    my_history_rank 3 : integer
    my_today_rank   4 : integer
    my_weekly_rank  5 : integer
}

.union_research_info {
    level           0 : integer
    exp             1 : integer
    need_exp        2 : integer
    last_24h_exp    3 : integer
    uid             4 : string
    upgrade_time    5 : integer
    add_exp         6 : integer
    add_contribution 7 : integer
}

.union_researches {
    union_contribution  0 : integer # self contribution
    researches          1 : *union_research_info(uid)
    union_tech_cd       2 : integer
    union_tech_lock     3 : integer
    clear_cd_times      4 : integer
}

.union_gift {
    gift_id             0 : integer
    gift_from           1 : string
    items               2 : *item_info
    uid                 3 : string
    _del                4 : boolean
    contribution        5 : integer
}

.union_help {
    uid                 0 : string
    user_id             1 : string
    head                2 : integer
    name                3 : string
    helped              4 : integer
    help_count          5 : integer
    build_id            6 : integer
    help_type           7 : integer
    users               8 : *string
    build_level         9 : integer
    logid               10 : integer
    build_type          11 : integer
    _del                12 : boolean
}

.help_contribution {
    contribution        0 : integer
    max                 1 : integer
    add                 2 : integer
}

.union_items {
    basic               0 : *integer
    allies_store        1 : *integer
    store               2 : *item_info(item_id)
    my_coin             3 : integer
    union_coin          4 : integer
    total_contribution  5 : integer
    my_contribution     6 : integer
}

.union_coordinates {
    leader              0 : position
    members             1 : *position
}

.union_numbers {
    help                0 : integer
    research            1 : integer
    war                 2 : integer
    gift                3 : integer
}

]]

local c2s = [[
    login 1 {
        request {
            msg             0 : request_msg
        }
        response {
            status                  0 : integer      # see the error code consts
            error                   1 : string
            error_type              2 : integer
            achivements             3 : *achivement_info
            all_effects             4 : all_effects_info
            armies                  5 : *army
            assists                 6 : *assist_info
            bookmarks               7 : *bookmark_info
            buffs                   9 : *buff_info
            build_events            10 : *building_event
            buildings               11 : *building_info
            camps                   12 : *map_tile_info
            city                    13 : city_info
            city_broken             14 : city_broken_info
            config_hero_stars       15 : *integer  # this is need?
            config_resource_worths  16 : config_resource_worths_info
            config_time_worths      17 : *time_worth_info
            funcs                   18 : *func_info
            gamble                  19 : gamble_info
            guide                   20 : *guide_info
            has_uhelp               21 : boolean
            hero_pos_cd             22 : integer
            heroes                  23 : *hero
            items                   24 : *item_info(uid)
            mail_notice            25 : mail_notice_info
            online_reward           26 : online_reward_info
            pit_groups              27 : *pit_info
            poss                    28 : *hero_pos_info
            quests                  29 : *quest_info
            r_quest_id              30 : integer
            researches              31 : *research_info(uid)
            resources               32 : resource
            server_config           33 : server_config_info
            tcards                  34 : cards_info
            union_quest_t           35 : integer
            users                   36 : *user
            vip                     37 : vip_info
            war_events              38 : *war_events_info
            world_chats             39 : *chat_info
            pits                    40 : *build_pit_info(uid)
            city_overview           41 : *city_overview_info
            acc_check_in_gifts      42 : *acc_check_in_gifts_info
            blackmarket             43 : blackmarket_info
            weather                 44 : *weather_info
            attack_warnings         45 : *attack_warning_info
            alliance_messages       46 : *chat_info
            orders                  47 : *order_info
            url                     48 : string
            union_nums              49 : union_numbers
            skip_story              50 : boolean
        }
    }

    gatewayserver_login 2 {
        request {
            msg 0 : request_msg
        }

        response {
            token       1 : string
            gs_info     2 : server_info
            status      3 : integer
            error       4 : string
        }
    }

    heartbeat 3 {
        request {
        }
        response {
            success 0 : boolean
        }
    }

    gatewayserver_list 4 {
        request {
            msg 0 : request_msg
        }

        response {
            servers     0 : *server
            status      1 : integer
            error       2 : string
        }
    }

    switch_server 5 {
        request {
            msg 0 : switch_server_req
        }

        response {
            reset_account 0 : string
            status      1 : integer
            error       2 : string
        }
    }

    #---------------------------mail 100~299------------------------
    mail_mailHandler_read_mail 101 {
        request {
            msg             0 : mail_req_msg
        }
        response {
            status          0 : integer
            new_mail_num    1 : integer
            error           2 : string
            error_type      3 : integer
            mail_list       4 : *mail_detail_content
            mail_notice     5 : mail_notice_info
        }
    }
    
    mail_mailHandler_list 102 {
        request {

        }
        response {
            status          0 : integer
            mail_list       1 : *mail_list_info(uid)
            error           2 : string
            error_type      3 : integer
        }
    }
    
    mail_mailHandler_detail 103 {
        request {
            msg             0 : mail_req_msg
        }
        response {
            status          0 : integer
            new_mail_num    1 : integer
            mail_list       2 : *mail_detail_content
            error           3 : string
            error_type      4 : integer
            mail_notice     5 : mail_notice_info
        }
    }
    mail_mailHandler_del_mail 104 {
        request {
            msg             0 : mail_req_msg
        }
        response {
            status 0 : integer
            error           1 : string
            error_type      2 : integer
            mail_list       3 : *mail_detail_content
            mail_notice     4 : mail_notice_info
        }   
    }

    mail_mailHandler_chat 105 {
        request {
            msg             0 : mail_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
        }
    }

    mail_mailHandler_union_chat 106 {
        request {
            msg             0 : mail_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
        }
    }

    mail_mailHandler_collect_gift 107 {
        request {
            msg             0 : mail_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            mail_list       3 : *mail_detail_content
        }
    }

    mail_mailHandler_get_mail_battle_log 108 {
        request {
            msg             0 : mail_req_msg
        }
        response {
            status          0 : integer
            new_mail_num    1 : integer
            mail_list       2 : *mail_detail_content
            error           3 : string
            error_type      4 : integer
            mail_notice     5 : mail_notice_info
        }
    }

    mail_mailHandler_single_mail 109 {
        request {
            msg             0 : mail_req_msg
        }
        response {
            status          0 : integer
            new_mail_num    1 : integer
            chat_mail_content 2 : *mail_content
            error           3 : string
            error_type      4 : integer
            mail_notice     5 : mail_notice_info
        }
    }

    mail_mailHandler_response_invitation 110 {
        request {
            msg             0 : mail_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            mail_list       3 : *mail_detail_content
            users           4 : *user
        }
    }

    mail_mailHandler_recent_user 111 {
        request {
            msg             0 : mail_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            mail_recent     3 : *user
        }
    }

    # -------------------wild  300 ~ 599-----------------------------
    wild_handler_start_mining 300 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            guide           4 : *guide_info
            error           5 : string
            error_type      6 : integer
            march_error     7 : march_error
            camps           8 : *map_tile_info
        }
    }

    wild_handler_return_march 301 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
        }
    }

    wild_handler_attack_monster 302 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            guide           4 : *guide_info
            users           5 : *user_ac_info
            error           6 : string
            error_type      7 : integer
            march_error     8 : march_error
            camps           9 : *map_tile_info
        }
    }

    wild_handler_get_monster_detail 303 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status                      0 : integer
            wild_monsters               1 : *army
            wild_items                  2 : *item_info
            can_attack_monster_level    3 : integer
            error                       4 : string
            error_type                  5 : integer
            is_boss                     6 : boolean
            drop_gold                   7 : integer
        }
    }

    wild_handler_get_army_info 304 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status                      0 : integer
            army_info                   1 : war_event_detail
            error                       2 : string
            error_type                  3 : integer
        }
    }

    wild_handler_use_speed_item 305 {
        request {
            msg             0 : wild_req_msg

        }
        response {
            status          0 : integer
            items           1 : *item_info
            war_events      2 : *war_events_info
            error           3 : string
            error_type      4 : integer
        }
    }

    wild_handler_callback_marching_troops 306 {
        request {
            msg             0 : wild_req_msg
        }
        
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            guide           4 : *guide_info
            users           5 : *user_ac_info
            items           6 : *item_info
            error           7 : string
            error_type      8 : integer
            resources       9 : resource
        }
    }

    wild_handler_transfer_city 307 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            users           1 : *user
            map             2 : *map_tile_info
            error           3 : string
            error_type      4 : integer
            resources       5 : resource
            items           6 : *item_info
        }
    }

    wild_handler_occupation_area 308 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            error           4 : string
            error_type      5 : integer
            march_error     6 : march_error
            camps           7 : *map_tile_info
        }
    }
    wild_handler_camp_detail 309 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            camp_detail     1 : map_tile_info
            error           2 : string
            error_type      3 : integer
        }
    }

    wild_handler_get_camp_upgrade_info 310 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            camp_upgrade_info 3 : camp_upgrade_info
        }
    }

    wild_handler_upgrade_camp 311 {
        request {
            msg             0 : wild_req_msg
        }

        response {
            status          0 : integer
            error           1 : string
            map             2 : *map_tile_info
            resources       3 : resource
            error_type      4 : integer
            camps           5 : *map_tile_info
        }
    }

    wild_handler_camp_callback_unit 312 {
        request {
            msg             0 : wild_req_msg
        }

        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            march_error     3 : march_error
            camps           4 : *map_tile_info
            heroes          5 : *map_hero_info
            war_events      6 : *war_events_info
        }
    }

    wild_handler_atk_camp 313 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            error           4 : string
            error_type      5 : integer
            march_error     6 : march_error
            camps           7 : *map_tile_info
        }
    }

    wild_handler_get_self_camp 314 {
        request {
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            camps           3 : *map_tile_info
        }
    }

    wild_handler_reinforce_camp 315 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            error           4 : string
            error_type      5 : integer
            march_error     6 : march_error
            camps           7 : *map_tile_info
        }
    }

    wild_handler_atk_city 316 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            error           4 : string
            error_type      5 : integer
            march_error     6 : march_error
            camps           7 : *map_tile_info
        }
    }

    wild_handler_start_expore_hole 317 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            error           4 : string
            error_type      5 : integer
            march_error     6 : march_error
            camps           7 : *map_tile_info
        }
    }

    wild_handler_add_bookmark 318 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            bookmarks       3 : *bookmark_info
        }
    }

    wild_handler_del_bookmark 319 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            bookmarks       3 : *bookmark_info
        }
    }

    wild_handler_temple_expore 320 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            error           4 : string
            error_type      5 : integer
            march_error     6 : march_error
            camps           7 : *map_tile_info
        }
    }

    wild_handler_get_temple_expore 321 {
        request {
             msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            temple_info     3 : temple_info
        }
    }

    wild_handler_set_rally_point 322 {
        request {
             msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            error           4 : string
            error_type      5 : integer
            march_error     6 : march_error
            camps           7 : *map_tile_info
        }
    }

    wild_handler_parter_atk_send_troops 323 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            error           4 : string
            error_type      5 : integer
            march_error     6 : march_error
            camps           7 : *map_tile_info
        }
    }

    wild_handler_dismiss_rally 324 {
        request {
             msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            map             1 : *map_tile_info
            war_events      2 : *war_events_info
            heroes          3 : *map_hero_info
            error           4 : string
            error_type      5 : integer
            camps           6 : *map_tile_info
        }
    }
    wild_handler_trade 325 {
        request {
            msg         0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            map             4 : *map_tile_info
            war_events      5 : *war_events_info
            heroes          6 : *map_hero_info
            march_error     7 : march_error
            camps           8 : *map_tile_info
        }
    }

    wild_handler_destory_camp 326 {
        request {
            msg         0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            map             4 : *map_tile_info
            war_events      5 : *war_events_info
            heroes          6 : *map_hero_info
            march_error     7 : march_error
            camps           8 : *map_tile_info
        }
    }
    
    wild_handler_detect_enemies 327 {
        request {
            msg         0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            map             4 : *map_tile_info
            war_events      5 : *war_events_info
            heroes          6 : *map_hero_info
            march_error     7 : march_error
            camps           8 : *map_tile_info
        }
    }

    wild_handler_reinforce_ally 328 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            march_error     3 : march_error
            war_events      4 : *war_events_info
            map             5 : *map_tile_info
            heroes          6 : *map_hero_info
            camps           7 : *map_tile_info
        }
    }

    wild_handler_search_gold_mine 329 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            gold_pos        3 : position
        }
    }

    wild_handler_search_cave 330 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            cave_pos        3 : position
        }
    }

    wild_handler_get_reinforce_info 331 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            reinforce_info  3 : wild_reinforce_info
        }
    }

    wild_handler_get_scout_info 332 {
        request {
            msg             0 : wild_req_msg
        }

        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            scout_info      3 : wild_scout_info
        }
    }

    wild_handler_search_monster_for_gold 333 {
        request {
            msg             0 : wild_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            monster_pos     3 : position
        }
    }

    #----------------------army handle 600 ~ 899----------------
    user_armyHandler_train 600 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_event
            resources       4 : resource
            guide           5 : *guide_info

        }
    }

    user_armyHandler_speed_up_train_army 601 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_event
            resources       4 : resource
            guide           5 : *guide_info
            armies          6 : *army

        }
    }
    user_armyHandler_collect_army 602 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_event
            resources       4 : resource
            guide           5 : *guide_info
            incr_might      6 : integer
            armies          7 : *army

        }
    }
    
    user_armyHandler_cure 603 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_event
            resources       4 : resource
            guide           5 : *guide_info
            armies          6 : *army

        }
    }
    
    user_armyHandler_fire_army 604 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            armies          3 : *army
        }
    }

    user_armyHandler_buy_army 605 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_event
            resources       4 : resource
            guide           5 : *guide_info
            armies          6 : *army
        }
    }
    user_armyHandler_cancel_train 606 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            buildings       4 : *building_info
        }
    }
    user_armyHandler_collect_survice 607 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_info
            resources       4 : resource
            guide           5 : *guide_info
            incr_might      6 : integer
            armies          7 : *army

        }
    }

    user_armyHandler_army_stop_info 608 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            army_stop       3 : *map_tile_info
        }
    }

    user_armyHandler_buy_cure_army 609 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_event
            resources       4 : resource
            guide           5 : *guide_info
            incr_might      6 : integer
            armies          7 : *army

        }
    }

    speed_up_cure 610 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_event
            resources       4 : resource
            armies          6 : *army
        }
    }

    user_armyHandler_r_assists 611 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            assists         3 : *assist_info
        }
    }

    user_armyHandler_get_assists 612 {
        request {}
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            assists         3 : *assist_info
        }
    }

    #---------------building handle 900 ~1199----------------------
    user_buildingHandler_build 900 {
        request {
            msg                 0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            pits            3 : *build_pit_info(uid)
            buildings       4 : *building_info
            guide           5 : *guide_info
            build_events    6 : *building_event
        }
    }

    end_building 901 {
        request {
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
        }
    }

    user_buildingHandler_remove 902 {
        request {
            msg                 0 : request_msg

        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_info
            pits            4 : *build_pit_info(uid)
        }
    }

    user_buildingHandler_upgrade 903 {
        request {
            msg                 0 : request_msg

        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_info
            resources       4 : resource
            build_events    5 : *building_event
        }
    }

    user_buildingHandler_free_build 904 {
        request {
            msg                 0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_info
            build_events    4 : *building_event
        }
    }
    user_buildingHandler_buy_build_queue 905 {
        request {
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            build_events    4 : *building_event
        }
    }

    user_buildingHandler_collect_res 906 {
        request {
            msg                 0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            inc_res         4 : resource
            guide           5 : *guide_info
            buildings       6 : *building_info
        }
    }

    user_buildingHandler_free_repair_wall 907 {
        request {
            msg                 0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            city            3 : city_info
            city_broken     4 : city_broken_info
        }
    }

    user_buildingHandler_confirm_city_hall 908 {
        request {

        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            tguide          3 : string
            success         4 : boolean
            items           5 : *item_info
        }
    }

    user_buildingHandler_unlock_pit 909 {
        request {
            msg                 0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            pit_groups      3 : *build_pit_info
            resources       4 : resource
        }
    }

    user_buildingHandler_convert 910 {
        request {
            msg                 0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_info
            resources       4 : resource
        }
    }

    user_buildingHandler_speed_up_upgrade 911 {
        request {
            msg                 0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_info
            resources       4 : resource
            build_events    5 : *building_event
        }
    }
    user_buildingHandler_instant_upgrade 912 {
        request {
            msg                 0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_info
            resources       4 : resource
            build_events    5 : *building_event
        }
    }

    speed_up_res 913 {
        request {
            msg                 0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_info
            resources       4 : resource
            build_events    5 : *building_event
        }
    }

    #-------------------city handle 1200 ~ 1499---------
    user_cityHandler_overview 1200 {
        request {
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            city_overview   3 : *city_overview_info
        }
    }

    #-----------------equipment_handler 1500 ~ 1799------
    user_equipmentHandler_wear 1500 {
        request {
            msg         0 : equip_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            guide           3 : *guide_info
            tguide          4 : string
            heroes          5 : *hero
            items           6 : *item_info
        }
    }

    user_equipmentHandler_composite 1501 {
        request {
            msg         0 : equip_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            items           3 : *item_info
            heroes          4 : *hero
        }
    }

    user_equipmentHandler_upgrade 1502 {
        request {
            msg         0 : equip_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            items           3 : *item_info
            heroes          4 : *hero
        }
    }

    # ------------------hero handle 1800 ~ 2099--------------------
    user_heroHandler_upgrade_star 1800 {
        request {
            msg             0 : hero_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            items           3 : *item_info
            heroes          4 : *hero
        }
    }

    user_heroHandler_upgrade_quality 1801 {
        request {
            msg             0 : hero_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            heroes          4 : *hero
        }
    }

    user_heroHandler_upgrade_skill 1802 {
        request {
            msg             0 : hero_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            heroes          4 : *hero
        }
    }

    user_heroHandler_appoint 1803 {
        request {
            msg             0 : hero_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            poss            3 : *hero_poss_info
            hero_pos_cd     4 : integer
        }
    }

    user_heroHandler_fire  1804 {
        request {
            msg             0 : hero_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            poss            3 : *hero_poss_info
        }
    }

    user_heroHandler_summon_hero 1805 {
        request {
            msg             0 : hero_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            guide           3 : *guide_info
            heroes          4 : *hero
            items           5 : *item_info
        }
    }
    user_heroHandler_search_equipment 1806 {
        request {
            msg             0 : hero_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            equipment_pos   3 : position
        }
    }

    set_hero_defender 1807 {
        request {
            msg             0 : hero_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            heroes          3 : *hero
        }
    }

    #-------------------item handle 2100 - 2399------------------
    user_itemHandler_buy 2100 {
        request {
            msg         0 : item_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            items           4 : *item_info
            amount          5 : integer
        }
    }

    user_itemHandler_use 2101 {
        request {
            msg         0 : item_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            items           4 : *item_info
            buildings       5 : *building_info
            resource        6 : resource
            build_events    7 : *building_event
            users           8 : *user
            city_broken     9 : city_broken_info
            city            10 : city_info
            heroes          11 : *hero
        }
    }
    user_itemHandler_buy_and_use 2102 {
        request {
            msg         0 : item_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            items           4 : *item_info
            buildings       5 : *building_info
            resource        6 : resource
            build_events    7 : *building_event
            users           8 : *user
            city_broken     9 : city_broken_info
            city            10 : city_info
            amount          11 : integer
            heroes          12 : *hero
        }
    }

    #--------------------quest handle 2400 ~ 2699------------
    user_questHandler_receive 2400 {
        request {
            msg             0 : quest_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            quests          3 : *quest_info
        }
    }
    user_questHandler_complete 2401 {
        request {
            msg             0 : quest_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            quests          3 : *quest_info
            r_quest_id      4 : integer
            resources       5 : resource
            guide           6 : *guide_info
            armies          7 : *army
            achivements     8 : *achivement_info
        }
    }

    user_questHandler_find_pos 2402 {
        request {
            msg             0 : quest_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            pos             3 : position
        }
    }

    #-------------------rank handle 2700 ~2999-------------
    rank_rankHandler_entry 2700 {
        request {
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            own_rank        3 : *rank_info
        }
    }

    rank_rankHandler_user_might_rank 2701 {
        request {
            msg             0 : rank_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rank_lists      3 : *rank_info
            tmp_count       4 : integer
            tmp_offset      5 : integer
        }
    }

    rank_rankHandler_user_city_building_rank 2702 {
        request {
            msg             0 : rank_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rank_lists      3 : *rank_info
            tmp_count       4 : integer
            tmp_offset      5 : integer
        }
    }

    rank_rankHandler_user_hero_rank 2703 {
        request {
            msg             0 : rank_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rank_lists      3 : *rank_info
            tmp_count       4 : integer
            tmp_offset      5 : integer
        }
    }

    rank_rankHandler_user_bp_rank 2704 {
        request {
            msg             0 : rank_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rank_lists      3 : *rank_info
            tmp_count       4 : integer
            tmp_offset      5 : integer
        }
    }

    rank_rankHandler_union_bp_rank 2705 {
        request {
            msg             0 : rank_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rank_lists      3 : *rank_info
            tmp_count       4 : integer
            tmp_offset      5 : integer
        }
    }

    rank_rankHandler_union_might_rank 2706{
        request {
            msg             0 : rank_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rank_lists      3 : *rank_info
            tmp_count       4 : integer
            tmp_offset      5 : integer
        }
    }

    my_rank 2707{
        request {
            msg             0 : rank_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rank_lists      3 : *rank_info
            tmp_count       4 : integer
            tmp_offset      5 : integer
        }
    }

    search_union_rank 2708{
        request {
            msg             0 : search_union_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rank_lists      3 : *rank_info
            tmp_count       4 : integer
            tmp_offset      5 : integer
        }
    }

    search_user_rank 2709{
        request {
            msg             0 : search_user_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rank_lists      3 : *rank_info
            tmp_count       4 : integer
            tmp_offset      5 : integer
        }
    }

    # ---------------research 3000 - 3299---------------------
    user_researchHandler_upgrade 3000 {
        request {
            msg           0 : research_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_info
            resources       4 : resource
        }
    }
    user_researchHandler_speed_up 3001 {
        request {
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
        }
    }
    user_researchHandler_instant 3002 {
        request {
            msg           0 : research_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            researches      3 : *research_info
            resources       4 : resource
        }
    }
    #--------------chat 3300 - 3599-----------------
    user_chatHandler_send 3300 {
        request {
            msg         0 : chat_req_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
        }
    }

    send_world_chat 3301 {
        request {
            msg         0 : chat_req_msg
        }
        response {
            status      0 : integer
            error       1 : string
            error_type  2 : integer
        }
    }

    # ------------------------------user  handler 3600 ~ 3899---------------
    user_userHandler_public_info 3600 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            user_public     3 : *user
        }
    }

    user_userHandler_receive_online_reward 3601 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            online_reward   3 : online_reward_info
            users           4 : *user
        }
    }

    user_userHandler_change_title 3602 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            users           3 : *user
        }
    }
    
    user_userHandler_bind_fb 3603 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            users           3 : *user
            fb              4 : *fb_info
        }
    }

    user_userHandler_get_orders 3604 {
        request {
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            orders          3 : *order_info
        }
    }

    user_userHandler_gamble_person 3605 {
        request {

        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            gamble          3 : gamble_info
            items           4 : *item_info
        }
    }
    user_userHandler_receive_tcard_gift 3606 {
        request {
            msg         0 : request_msg
        }

        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            items           4 : *item_info
            tcards          5 : cards_info
        }
    }
    
   user_userHandler_blackmarket 3607 {
        request {
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            blackmarket     3 : blackmarket_info
        }
    }

    user_userHandler_buy_in_blackmarket 3608 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            blackmarket     3 : blackmarket_info
            resources       4 : resource
        }
    }
    user_userHandler_refresh_blackmarket 3609 {
        request {
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            blackmarket     3 : blackmarket_info
            resources       4 : resource
        }
    }

    user_userHandler_buy_res 3610 {
        request {
           msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
        }
    }

    get_map_data 3611 {
        request {
            msg         0 : request_msg
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            map             3 : *map_tile_info
        }
    }

    user_userHandler_check_in 3612 {
        request {
            msg         0 : request_msg
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
            users               3 : *user
            acc_check_in_gifts  4 : *acc_check_in_gifts_info
            check_in_gift       5 : item_info
        }
    }

    user_userHandler_receive_acc 3613 {
        request {
            msg         0 : request_msg
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
            acc_check_in_gifts  3 : *acc_check_in_gifts_info
            items               4 : *item_info
            heroes              5 : *hero
        }
    }
    user_userHandler_mark_item 3614 {
        request {
            msg         0 : request_msg
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
            items               3 : *item_info
        }
    }

    bind_fb 3615 {
        request {
            msg                 0 : bind_req_info
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
            users               3 : *user
        }
    }

    bind_gc 3616 {
        request {
            msg                 0 : bind_req_info
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
            users               3 : *user
        }
    }

    swich_fb 3617 {
        request {
            msg                 0 : bind_req_info
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
            account             3 : *account
        }
    }

    swich_gc 3618 {
        request {
            msg                 0 : bind_req_info
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
            account             3 : *account
        }
    }


    unbind_account 3619 {
        request {
            msg                 0 : bind_req_info
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
            users               3 : *user
        }
    }

    get_expore_cave_times 3620 {
        request { }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
            cave_explore_times  3 : cave_explore_times
        }
    }

    user_userHandler_click_yes 3621 {
        request {
            msg         0 : request_msg
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
        }
    }

    user_userHandler_click_rating 3622 {
        request {
            msg         0 : request_msg
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
        }
    }

    update_device_token 3623 {
        request {
            msg         0 : request_msg
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
        }
    }

    set_push_opts 3624 {
        request {
            msg         0 : request_msg
        }
        response {
            status              0 : integer
            error               1 : string
            error_type          2 : integer
            users               3 : *user
        }
    }

    #--------------------union handler 3900 ~ 4199------------------
    get_self_union_info 3900 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            users           3 : *user
            unions          4 : *union_info(uid)
        }
    }

    get_guid_wars 3901 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            guidwar         3 : *union_war_event(uid)
        }
    }

    get_battle_history 3902 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            battlehistory   3 : *union_war_history
        }
    }

    get_alllance_gift 3903 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            union_gifts     3 : *union_gift
        }
    }

    get_alllance_help 3904 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            help            3 : *union_help(uid)
            help_contribution 4 : help_contribution
        }
    }

    request_alllance_help 3905 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            buildings       3 : *building_info
        }
    }

    help_other 3906 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            has_uhelp       3 : boolean
            help            4 : *union_help
            help_contribution 5 : help_contribution
        }
    }

    help_all 3907 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            has_uhelp       3 : boolean
            help            4 : *union_help
            help_contribution 5 : help_contribution
        }
    }

    get_alllance_store 3908 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            union_items     3 : union_items
            member_levels   4 : *integer
        }
    }

    get_mail 3909 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
        }
    }

    get_guid_member 3910 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            users           3 : *user
            guid_member     4 : union_members
        }
    }

    get_contribution_rank 3911 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rank            3 : union_contribution_rank
        }
    }

    change_alliance 3912 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            unions          3 : *union_info(uid)
            resources       4 : resource
        }
    }

    create_alliance 3913 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            users           3 : *user
            resources       4 : resource
        }
    }

    exit_unions 3914 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            users           3 : *user
            has_uhelp       4 : boolean
        }
    }

    get_alliances 3915 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            unions          3 : *union_info(uid)
        }
    }

    search_alliance_by_name 3916 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            unions          3 : *union_info
        }
    }

    get_alliances_by_id 3917 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            unions          3 : *union_info(uid)
        }
    }

    dismiss_alliances 3918 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            users           3 : *user
            has_uhelp       4 : boolean
        }
    }

    send_union_invitation_mail 3919 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            invited         3 : *string
        }
    }

    get_union_coordinates 3920 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            union_member_coordinates 3 : union_coordinates
        }
    }

    union_gamble 3921 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            items           3 : *item_info
        }
    }

    union_join 3922 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            users           3 : *user
            resources       4 : resource
        }
    }

    buy_alllance_item 3923 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            union_items     3 : union_items
            items           4 : *item_info
        }
    }

    manage_member 3924 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            guid_member     3 : union_members
        }
    }

    union_kick 3925 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            guid_member     3 : union_members
        }
    }

    member_contribution 3926 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            tech            3 : union_researches
            resources       4 : resource
        }
    }

    unlock_contribution 3927 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            tech            3 : union_researches
        }
    }

    union_get_tech 3928 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            tech            3 : union_researches
        }
    }

    get_rally_detail 3929 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rally_detail    3 : rally_detail
        }
    }

    union_upgrade_research 3930 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            tech            3 : union_researches
        }
    }

    add_member 3931 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            guid_member     4 : union_members
        }
    }

    get_person_not_in_union 3932 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            person          4 : *union_member
        }
    }

    union_replenish_stock 3933 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            union_items     3 : union_items
            member_levels   4 : *integer
        }
    }

    invite_all 3934 {
        request { }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
        }
    }

    get_rally_limit 3935 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            rally_limit     3 : rally_limit
        }
    }

    collect_union_gift 3936 {
        request {
            msg             0 : union_req_info
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            union_gifts     3 : *union_gift
        }
    }

    #----------order 4200 ~ 4299---------------

    orderHandler_buy 4200 {
        request {
            msg             0 : order_buy_req
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            orders          4 : *order_info
            tcards          5 : cards_info
        }
    }

    create_order 4201 {
        request {
            msg             0 : order_buy_req
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            order_id        3 : string
        }
    }

    verify_wp 4202 {
        request {
            msg             0 : order_buy_req
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            orders          4 : *order_info
            tcards          5 : cards_info
        }
    }

    create_wp_huapay_order 4203 {
        request {
            msg             0 : order_buy_req
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            order_id        3 : string
        }
    }

    check_in_card_gift 4204 {
        request {
            msg             0 : order_buy_req
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            orders          4 : *order_info
            tcards          5 : cards_info
        }
    }

    receive_checkin_card_gift 4205 {
        request {
            msg             0 : order_buy_req
        }
        response {
            status          0 : integer
            error           1 : string
            error_type      2 : integer
            resources       3 : resource
            orders          4 : *order_info
            tcards          5 : cards_info
        }
    }

    #--------------------test 10000------------------
    test_call_online_user_from_other_service 10000 {
        request { }
        response {
            ok              0 : boolean
        }
    }

    test_user_offline_interactive 10001 {
        request {
            offline_user_id     0 : string
        }
        response {
            status              0 : integer
            offline_user_name   1 : string 
        }
    }

    test_user_database_simple_set 10002 {
        request { 

        }
        response { 
            ok              0 : boolean
        }
    }

]]

local s2c = [[
    heartbeat 1 {

    }
    
    skynet_push 302 {
        request {
            items               0 : *item_info
            heroes              1 : *hero
            resources           2 : resource 
            users               3 : *user
            mail_notice         4 : mail_notice_info
            guide               5 : *guide_info
            poss                6 : *hero_pos_info
            helped_me           7 : helpme_info
            tguide              8 : string
            buildings           9 : *building_info
            funcs               10 : *func_info
            city_broken         11 : city_broken_info
            vip                 12 : vip_info
            quests              13 : *quest_info
            city_events         14 : *city_event_info
            attack_warnings     15 : *attack_warning_info
            hero_skill_trigger  16 : hero_skill_trigger_info
            map                 17 : *map_tile_info
            war_events          18 : *war_events_info
            march_error         19 : march_error
            push                20 : integer
            pits                21 : *build_pit_info(uid)
            build_events        22 : *building_event
            r_quest_id          23 : integer
            buffs               24 : *buff_info
            new_mail_num        25 : integer
            is_new_mail         26 : boolean
            incr_vip_exp        27 : integer
            city_overview       28 : *city_overview_info
            armies              29 : *army
            unions              30 : *union_info
            camps               31 : *map_tile_info
            world_chats         32 : *chat_info
            reset_account       33 : string
            reward              34 : reward_info
            has_uhelp           35 : boolean
            alliance_messages   36 : *chat_info
            researches          37 : *research_info
            all_effects         38 : all_effects_info
            city                39 : city_info
            show_rating_pop     40 : integer
            union_nums          41 : union_numbers
            union_level_up      42 : science_info
            tech                43 : union_researches
        }
    }
]]

proto.c2s = types .. c2s
proto.s2c = types .. s2c

return proto
