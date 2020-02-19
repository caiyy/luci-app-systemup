--[[
LuCI - Lua Configuration Interface

Copyright 2010 Jo-Philipp Wich <xm@subsignal.org>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0
]]--

require("luci.sys")

m = Map("systemup", translate("自动升级系统"), translate("自动升级系统"))

s = m:section(TypedSection, "base_arg", "")
s.addremove = false
s.anonymous = true

email = s:option(Value, "firmware_url", translate("固件服务器地址"), "格式:http://domain/xxx,不要有/结尾")
main = s:option(Value, "firmware_name", translate("固件的文件名字"), "比如 openwrt-x86-64-combined-squashfs.img.gz")
sub = s:option(Value, "firmware_sha256sum", translate("固件sha256sum"), "固件的sha256sum名字")
date_file = s:option(Value, "firwmare_date_file", translate("固件版本信息文件"), "date.txt")
date = s:option(Value, "firwmare_date", translate("当前版本编译时间"), "当前版本编译时间")
wait = s:option(Value, "update_time", translate("更新周期(m)"), "请填写数字，默认为1440")
--command = s:option(Value, "command_to_get_ip", translate("外网ip获取命令"), "默认为 curl -s whatismyip.akamai.com")

local apply = luci.http.formvalue("cbi.apply")
if apply then
    io.popen("/etc/init.d/systemup restart &")
end

return m
