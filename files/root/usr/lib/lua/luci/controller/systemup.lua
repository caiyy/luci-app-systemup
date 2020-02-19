module("luci.controller.systemup", package.seeall)

function index()
        entry({"admin", "services", "systemup"}, cbi("systemup"), _("自动升级系统"), 100)
end
