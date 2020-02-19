f = SimpleForm("logview")
f.reset = false
f.submit = false
t = f:field(TextValue, "conf")
t.rmempty = true
t.rows = 30
function t.cfgvalue()
    local logs = luci.util.execi("cat /tmp/log/systemup.log")
    local s = ""
    for line in logs do
        s = line .. "\n" .. s
    end
    return s
end
t.readonly="readonly"

return f