module("luci.controller.systemup", package.seeall)

function index()
        entry({"admin", "services", "systemup"}, alias("admin", "services", "systemup", "setup"),_("自动升级系统"), 1).dependent = true
        entry({"admin", "services", "systemup", "setup"}, cbi("systemup/setup"),_("设置"), 1).leaf = true
        entry({"admin", "services", "systemup", "log"}, cbi("systemup/log"),_("日志"), 101).leaf = true
end
