function User:add_hero( config_hero_id )
  local hero = self:find_hero_by_config_id(config_hero_id)
  if hero then
    self:add_item(hero:get_config().soul, hero:get_config().summon)
  else
    hero = Hero:factory({config_id = config_hero_id}, self)
    table.insert(self.heroes, hero)
  end
  return hero
end

function User:get_hero_count(  )
  return #self.heroes
end