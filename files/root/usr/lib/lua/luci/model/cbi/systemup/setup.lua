require("luci.sys")

m = Map("systemup", translate("自动升级系统 V5.0.7.3"))

s = m:section(TypedSection, "base_arg", "")
s.addremove = false
s.anonymous = true
print(m)
-- make package/openwrt-packages/luci-app-systemup/compile -j5
s:option(Value, "firmware_url", translate("固件服务器地址"), "格式:http://domain/xxx,不要有/结尾")
s:option(Value, "firmware_name", translate("固件的文件名字"), "比如 openwrt-x86-64-combined-squashfs.img.gz")
s:option(Value, "firmware_sha256sum", translate("固件sha256sum"), "固件的sha256sum名字")
s:option(Value, "firwmare_date_file", translate("固件版本信息文件"), "date.txt")
s:option(Value, "firwmare_date", translate("当前版本编译时间"), "当前版本编译时间")
s:option(Value, "push_key", translate("信息推送key"), "一个消息推送软件的Key,AppStore搜索Bark下载即可,不填写即不推送")

local apply = luci.http.formvalue("cbi.apply")
if apply then
    io.popen("/etc/init.d/systemup restart &")
end

return m
