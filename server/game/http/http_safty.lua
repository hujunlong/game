local http_safty = {}
local valid_module = {
	alipay = true,
	job = true,
	internal_cmd = true,
	test = true,
    huapay = true,
    paypal = true,
    cheat = true,
}

function http_safty.is_valid(name)
	return valid_module[name] ~= nil
end

return http_safty