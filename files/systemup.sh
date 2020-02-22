#!/bin/ash
firmware_url=`uci get systemup.base_arg.firmware_url`
firmware_name=`uci get systemup.base_arg.firmware_name`
firmware_sha256sum_name=`uci get systemup.base_arg.firmware_sha256sum`
firwmare_date_file=`uci get systemup.base_arg.firwmare_date_file`
firwmare_date=`uci get systemup.base_arg.firwmare_date`
update_time=`uci get systemup.base_arg.update_time`
push_key=`uci get systemup.base_arg.push_key`

LOG_FILE="/tmp/systemup.log"

printMsg() {
    local time=$(date "+%Y-%m-%d %H:%M:%S")
    local msg="$1"
    local push="$2"
    echo "$time: $msg" >> $LOG_FILE
    if [ -n "$push" ];then
        curl "https://api.day.app/$push_key/路由器更新通知/$1"
    fi
}
printMsg "----------------------------"
printMsg "开始执行脚本.."

Theme=`uci get luci.main.mediaurlbase`
if [ $Theme -eq "/luci-static/argon" ]; then
    uci set luci.main.mediaurlbase="/luci-static/argon"
    uci commit luci
    sleep 5
    printMsg "检测到主题不是指定的argon主题,设置为argon主题完毕.."
fi

cd /root/
rm /tmp/$firmware_sha256sum
rm /tmp/$firmware_name
if [ $firwmare_date -lt '2000' ];then
    new_time=`curl "$firmware_url/$firwmare_date_file"`
    uci set systemup.base_arg.firwmare_date=$new_time
    uci commit systemup
    #添加任务计划
    if [ "0" -ge `grep -c "systemup" /etc/crontabs/root` ] ;then
        echo "*/10 * * * * /usr/sbin/systemup.sh" >> /etc/crontabs/root
    fi
    #重启任务计划
    /etc/init.d/cron restart
    printMsg "第一次启动检查完毕.."
else
    sleep 10 #延迟10秒再执行
    old_time=$firwmare_date
    new_time=`curl "$firmware_url/$firwmare_date_file"`
    if [ -n new_time ];then
        printMsg "old-time:$old_time.."
        printMsg "new-time:$new_time.."
        if [ $old_time -ge $new_time ];then
            printMsg "未检查到固件更新"
        else
            if [ -n $push_key ];then
                printMsg "检查到固件更新,正在下载新固件、固件编译日期:$new_time" "ts"
            else
                printMsg "检查到固件更新,正在下载新固件、固件编译日期:$new_time"
            fi
            cd /tmp/
            wget $firmware_url/$firmware_name
            wget $firmware_url/$firmware_sha256sum_name
            sed -i 's/\*/ /g' $firmware_sha256sum_name
            if [ -n $push_key ];then
                printMsg "固件下载完毕,正在检查固件的sha256sum效验值" "ts"
            else
                printMsg "固件下载完毕,正在检查固件的sha256sum效验值"
            fi
            sha256sumaa=`grep -A 0 "$firmware_name" $firmware_sha256sum_name`
            firmware_sha256sum=`sha256sum "$firmware_name"`
            if [ "$sha256sumaa" == "$firmware_sha256sum" ];then
                uci set systemup.base_arg.firwmare_date=$new_time
                uci commit systemup
                sleep 10
                if [ -n $push_key ];then
                    printMsg "固件效验通过,提交刷机命令.请耐心等待路由器重启..." "ts"
                else
                    printMsg "固件效验通过,提交刷机命令.请耐心等待路由器重启..."
                fi
                # 路由器刷机命令
                sysupgrade -v openwrt-x86-64-combined-squashfs.img.gz
            else
                if [ -n $push_key ];then
                    printMsg "固件效验不通过,请等待下次检查." "ts"
                else
                    printMsg "固件效验不通过,请等待下次检查."
                fi
            fi
        fi
    else
        printMsg "获取最新版固件编译时间失败,请等待下次检查."
    fi
fi