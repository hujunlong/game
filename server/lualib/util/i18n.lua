local M = {}
local EnLocale = require 'en_locale'
local CnLocale = require 'cn_locale'

I18n = M

local Locales = {
  en = EnLocale,
  cn = CnLocale,
}

function M:t( key, locale, ... )
  if not locale then return 'en' end
  locale = locale or 'en'
  local value = nil
  if not Locales[locale] then
    locale = 'en'
  end
  Tool:inspect(Tool:split(key, '.'))
  for k, v in ipairs(Tool:split(key, '.')) do
    value = (value or Locales[locale])[v]
    print(value)
  end
  if not value then return false end
  return string.format(value, ...)
end

return M