local ConfigCityOverview = require 'config_overview'

function User:get_city_info  () 
  local city = self:get_city_tile()
  return {
    city = {
      build_queue = 1,
      march_queue = 1,
      max_life = city.total_life,
      life = city.life,
      recover = 1,
      updated_at = os.time(),
      r_life_cd = self.r_life_cd,
      item_id = 19024,
      fix = self:get_free_fix_wall_life(),
      fire = {start = city.fire_up_time, finish = city.fire_end_time, lose = UserConst.CITY_FIRE_LIFE, lose_time = UserConst.CITY_FIRE_PER},
    }
  }
end

function User:update_city_life(  )
  game_cmd:exc_wild_cmd("map", "update_max_life", self.x, self.y, self:get_city_life())
  self:send_push(self:get_city_info())
  return true
end

function User:repaire_city( life )
  game_cmd:exc_wild_cmd("map", "add_life", self.x, self.y, life)
  self:update_city_broken_info()
  return true
end

function User:get_city_life(  )
  local factory = self:find_building_by_config_id(BuildingConst.BUILDING.Factory)
  local life = WildConst.CITY_DEFAUT_LIFE + self:get_CityLife_effect()
  if factory then
    life = life + factory:get_detail().hp
  end
  return life
end

function User:get_city_tile( )
  local r = game_cmd:exc_wild_cmd("map", "get_tile_by_xy", self.x, self.y)
  return r
end

function User:create_city(life) 
  local pos = game_cmd:exc_wild_cmd("map", "create_user_city", self._id, self.user_name, self.last_login_time)
  self.x = pos.x
  self.y = pos.y
  game_cmd:exc_wild_cmd("map", "update_city_level", self.x, self.y, self.level)
  return true
end

function User:get_city_res_produce  (type) 
  local c = BuildingConst.RES[type]
  return Tool:sum(self.buildings, function ( b )
    b:set_user(self)
    return b[c.produce](b)
  end)
end

function User:update_city_broken_info()
  if self.city_broken and self.city_broken.show then
    if self.city_broken.start_time and os.time() - self.city_broken.start_time >= 3600 * 6 then
      self.city_broken = {show = false}
    else
      local city = self:get_city_tile()
      if city.life >= city.total_life * 2 / 3 then
        self.city_broken = {show = false}
      end
    end

    if not self.city_broken.show then
      self:send_push(self:get_city_broken_info())
    end
  end
end

function User:get_city_broken_info  ()
  self:update_city_broken_info()
  local msg = {city_broken = self.city_broken}
  return msg
end

function User:add_city_broken_info (attacker, from_pos, to_pos) 
  self.city_broken = {
      show = true,
      user_name = attacker.user_name,
      level = attacker.level,
      union_name = attacker.union_name,
      s_union_name = attacker.s_union_name,
      might = attacker.might,
      from_pos = from_pos,
      move_pos = to_pos,
      start_time = os.time(),
    }
  self:send_push(self:get_city_broken_info())
  self:send_push(self:get_city_info())
  return self.city_broken
end

function User:add_protect_buff()
  --被打飞后添加8小时保护
  local item_id = 18001
  local ci = ConfigItem:find_by_id(item_id)
  local cb = ConfigBuff:find_by_id(ci.buff)
  local time = cb.time
  self:add_buff(item_id, cb.buff, cb.time, cb._id)
end

function User:move_to(x, y)
  local msg = {}
  local hero_list = {}
  for i, hero in pairs(self.heroes) do
    if hero.position.x == self.x and hero.position.y == self.y then
      hero.position.x, hero.position.y = x, y
      table.insert(hero_list, hero)
    end
  end

  self.x = x
  self.y = y
  local cave_pos = self:get_nearest_cave_pos()
  if cave_pos then
    msg.users = {
      [1] = {
        cave_pos = cave_pos,
        uid = self:get_uid(),
      }
    }
  end

  local temple_pos = game_cmd:exc_wild_cmd("wild", "get_nearest_temple_pos", x, y)
  if temple_pos then
    msg.users = msg.users or {
      [1] = {
        uid = self:get_uid(),
      }
    }
    msg.users[1].temple_pos = temple_pos
  end

  self:update()

  if #hero_list > 0 then  --push hero position
    local heroes = {}
    for i, hero in pairs(hero_list) do
      table.insert(heroes, {
        position = hero.position,
        uid = hero.config_id,
      })
    end

    msg.heroes = heroes
  end

  if next(msg) then
    self:send_push(msg)
  end
  return true
end

function User:save_city_title()
  game_cmd:exc_wild_cmd("map", "save_by_xy", self.x, self.y)
  return true
end

function User:get_city_overview_info(  )
  local info = {}
  if self.army_food_up == 0 then self.army_food_up = os.time() end
  for k,t in pairs(BuildingConst.CITY_RESOURCE) do
    local effect_id = UserConst.ADD_INCOME_EFFECTS[t]
    local all_effect_id = UserConst.ADD_INCOME_EFFECTS.all
    local vip_num = (self:get_vip_effects()[effect_id] or 0) + (self:get_vip_effects()[all_effect_id] or 0)
    local research_num = (self:get_resarch_effects()[effect_id] or 0) + (self:get_resarch_effects()[all_effect_id] or 0)
    local union_num = (self:get_uresearch_effects()[effect_id] or 0) + (self:get_uresearch_effects()[all_effect_id] or 0)
    local buff_num = (self:get_buff_effects()[effect_id] or 0) + (self:get_buff_effects()[all_effect_id] or 0)
    local produce = self:get_city_res_produce(t)
    local i = {
      uid = t,
      produce = produce,
      consume = 0,
      consume_updated_at = 0,
      config_id = BuildingConst.RES[t].config_id,
      vip_bonus = {num = math.floor(produce * vip_num / 100), rate = ConfigCityOverview:vip():rate(vip_num, t)},
      science_bonus = {num = math.floor(produce * research_num / 100), rate = ConfigCityOverview:research():rate(research_num, t)},
      officer_bonus = {num = math.floor(produce * union_num / 100), rate = ConfigCityOverview:union():rate(union_num, t)},
      buff_bonus = {num = math.floor(produce * buff_num / 100), rate = ConfigCityOverview:buff():rate(buff_num, t)}
    }
    if t == 'food' then
      i.consume = self:get_army_consume()
      i.consume_updated_at = self.army_food_up
    end
    table.insert(info, i)
  end
  return {city_overview = info}
end

function User:fire_city( city )
  if os.time() - city.city_fire_up_time < 15 * 60 then
    city.city_fire_end_time = city.city_fire_end_time + UserConst.CITY_FIRE_DURATION
  end
  return true
end

--------------------------------------------------------
function User:add_attack_warning  (event_id)
  local is_need_insert = true
  for k, v in pairs(self.attack_warnings) do
    if v == event_id then
      is_need_insert = false
    end
  end 
  if is_need_insert then
    table.insert(self.attack_warnings, event_id)
  end

  local msg = {}
  msg.attack_warnings = {}
  local results = self:get_attack_warning_by_event_id(event_id)
  if results then
    msg.attack_warnings[1] = results
    self:send_push(msg)
  end
end 

function User:remove_attack_warning( event_id)
  for k, v in pairs(self.attack_warnings) do
    if v and v == event_id then
      self.attack_warnings[k] = nil
      local msg = {
        attack_warnings = {
          [1] = {
            uid = event_id,
            _del = true
          }
        }
      }
      self:send_push(msg)
      return
    end
  end
end

function User:remove_attack_warnings()
  local warnings = {}
  
  for k, v in pairs(self.attack_warnings) do
    self.attack_warnings[k] = nil
    table.insert(warnings, {
      uid = v,
      _del = true,
    })
  end
  
  if next(warnings) then
    self:send_push({
      attack_warnings = warnings,
    })
    return true
  end

  return false
end 

function User:get_city_attack_warning_info  () 
  local attack_warnings = {}
  for k, v in pairs(self.attack_warnings) do
    local info = self:get_attack_warning_by_event_id(v)
    if info then
      table.insert(attack_warnings, info)
    end
  end
  return {attack_warnings = attack_warnings }
end

function User:get_attack_warning_by_event_id(event_id)
    local event = game_cmd:exc_event_cmd("get", event_id)
    if not event then
      return nil
    end
    local defender_id = event.defender_user_id
    local attacker_id = event.user_id
    local d_tower = self:find_building_by_config_id(BuildingConst.BUILDING.Watchtower)
    local tower_level = d_tower.level 
    local t = game_cmd:exc_wild_cmd("map", "get_tile_by_xy", event.to_pos.x, event.to_pos.y)

    local attack_warning = {}
    local attker_hero = nil
    if event.hero_id then
        attker_hero = game_cmd:exc_user_cmd(attacker_id, "get_hero_info_by_config_id", event.hero_id)
    end
    local info = {
        "x", "y", "head", "user_name",
        "s_union_name", "union_name",

    }
    local attacker = game_cmd:exc_user_cmd(attacker_id, "get", info)
    for i = 1, 25 do
      attack_warning[i] = {}
    end
    attack_warning[1] = {
            user_name = attacker.user_name, 
            head = attacker.head,
            from_pos = {
                x = attacker.x, 
                y = attacker.y
            }
        }

    attack_warning[3] = {
        target = {
            name = t.name,
            pos = event.to_pos,
            }
        }
    attack_warning[5] = {arrival = event.finish_time}
    attack_warning[7] = {
            s_union_name = attacker.s_union_name,
            union_name = attacker.union_name,
            rally_number = 0,
    }
    if event.rallyer_list then
      for k, v in pairs(event.rallyer_list) do
        attack_warning[7].rally_number = attack_warning[7].rally_number + 1
      end
    end

    local unit_count = 0
    local t_might = 0
    attack_warning[11] = {}
    attack_warning[11].armies = {}
    attack_warning[13] = {}
    attack_warning[13].armies = {}
    for k, v in pairs(event.armies or {}) do
        unit_count = unit_count + v.amount
        t_might = t_might + ConfigMonster:find_by_id(v._id).might * v.amount
        table.insert(attack_warning[11].armies, {uid = v._id})
        table.insert(attack_warning[13].armies, {uid = v._id, amount = v.amount})
    end
    
    attack_warning[9] = {
        unit_count = unit_count,
        might = math.floor(t_might),
    }

    if attker_hero then
        attker_hero.uid = nil
        attack_warning[15] = {
            -- hero_id, name
            hero = {config_id = attker_hero.config_id},
        }

        attack_warning[17] = {
            -- level and star
                hero = {
                    config_id = attker_hero.config_id, 
                    level = attker_hero.level, 
                    star = attker_hero.star
                    },
        }

        attack_warning[19] = {
            hero = {
                    config_id = attker_hero.config_id, 
                    level = attker_hero.level, 
                    star = attker_hero.star, 
                    quality = attker_hero.quality
                    },
        }
    
    end

    

    local reserch = game_cmd:exc_user_cmd(attacker_id, "get_battle_research_info")
    attack_warning[21] = {
        reserches = {}
    }
    attack_warning[23] = {
        reserches = {}
    }
    if reserch then
        for k, v in pairs(reserch) do
            if v and v.level and v.level >= 1 then
                table.insert(attack_warning[21].reserches, {uid = v.uid})
                table.insert(attack_warning[23].reserches, {uid = v.uid, level = v.level})
            end
        end
    end

    local s_t = game_cmd:exc_user_cmd(attacker_id, "get_city_tile")
    attack_warning[25] = {
        city = {
            name = s_t.name, 
            level = s_t.level, 
            pos = {x = s_t.x, y = s_t.y}
            },
    }

    local results = {}
    results.can_scout_info = {
        armies = false,
        hero = false,
        science = false,
        city = false,
        reserches = false
    }
    results.can_scout_info.event_type = event.action
    for k, v in ipairs(attack_warning) do
        if k <= tower_level then
            for tk, tv in pairs(v) do
                results.can_scout_info[tk] = true
                results[tk] = tv
            end
        end
    end

    results.uid = event._id
    results.start_time = event.start_time
    return results
end

function User:put_out_fire( sec )
  game_cmd:exc_wild_cmd("map", "add_fire_end_time", self.x, self.y, -sec)
end

function User:being_attacked(  )
  return #self.attack_warnings > 0
end

function User:get_free_fix_wall_life(  )
  return UserConst.FREE_REPAIRE_CITY_LIFE + self:get_FreeRecoverCityHealth_effect()
end


