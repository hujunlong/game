local ip_config = require('ip_config')

function User:get_new_building_key()
  return self.keys.building + 1
end