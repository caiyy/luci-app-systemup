module("luci.controller.systemup", package.seeall)

function index()
        entry({"admin", "services", "systemup"}, alias("admin", "services", "systemup", "client"),_("自动升级系统"), 100).dependent = true
        entry({"admin", "services", "systemup", "client"}, cbi("systemup/client"),_("设置"), 10).leaf = true
        entry({"admin", "services", "systemup", "log"}, cbi("systemup/log"),_("日志"), 101).leaf = true
end
