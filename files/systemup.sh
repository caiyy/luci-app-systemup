#!/bin/ash
firmware_url=`uci get systemup.base_arg.firmware_url 2>/dev/null`
firmware_name=`uci get systemup.base_arg.firmware_name 2>/dev/null`
firmware_sha256sum_name=`uci get systemup.base_arg.firmware_sha256sum 2>/dev/null`
firwmare_date_file=`uci get systemup.base_arg.firwmare_date_file 2>/dev/null`
firwmare_date=`uci get systemup.base_arg.firwmare_date 2>/dev/null`
update_time=`uci get systemup.base_arg.update_time 2>/dev/null`
push_key=`uci get systemup.base_arg.push_key 2>/dev/null`

LOG_FILE="/tmp/systemup.log"

printMsg() {
    local time=$(date "+%Y-%m-%d %H:%M:%S")
    local msg="$1"
	local push="$2"
    echo "$time: $msg"
	if [ -n "$push" ];then
		#echo "$push"
		curl "https://api.day.app/$push_key/路由器更新通知/$1"
	fi
}
printMsg "----------------------------"
printMsg "开始执行脚本.."

#echo "firmware_url:$firmware_url"
#echo "firmware_name:$firmware_name"
#echo "firmware_sha256sum:$firmware_sha256sum"
#echo "firwmare_date_file:$firwmare_date_file"
#echo "firwmare_date:$firwmare_date"
#echo "update_time:$update_time"

cd /root/
rm /tmp/$firmware_sha256sum
rm /tmp/$firmware_name
if [ $firwmare_date -lt '2000' ];then
	new_time=`curl "$firmware_url/$firwmare_date_file"`
    uci set systemup.base_arg.firwmare_date=$new_time
    uci commit systemup
	# echo '*/1 * * * * /usr/sbin/systemup.sh >> /var/log/systemup.log'>>/etc/crontabs/root
	#new_caiyy="*/1 * * * * /usr/sbin/systemup.sh >> /var/log/systemup.log"
	#sed -i 's/^.*systemup.*$/$new_caiyy/g' /etc/crontabs/root
	sed -i 's/^.*systemup.*$/\*\/10\ \*\ \*\ \*\ \*\ \/usr\/sbin\/systemup.sh\ \>\>\ \/var\/log\/systemup.log/g' /etc/crontabs/root
	/etc/init.d/cron restart
	# echo "第一次启动检查完毕"
	printMsg "第一次启动检查完毕.."
else
	#old_time=`cat "date.txt"`
    old_time=$firwmare_date
	new_time=`curl "$firmware_url/$firwmare_date_file"`
	#echo $old_time
	#echo $new_time
	printMsg "old-time:$old_time.."
	printMsg "new-time:$new_time.."
	if [ $old_time -ge $new_time ];then
		#echo "本机固件比线上固件新"
		printMsg "未检查到更新"
	else
		#echo "本机固件比线上固件旧"
		if [ -n $push_key ];then
			printMsg "检查到固件更新,正在下载新固件、固件编译日期:$new_time"
		else
			printMsg "检查到固件更新,正在下载新固件、固件编译日期:$new_time" "ts"
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
		#$sha256sum=${sha256sum/\*/ }
		firmware_sha256sum=`sha256sum "$firmware_name"`
		#echo "A:$firmware_sha256sum"
		#echo "B:$sha256sumaa"
		if [ "$sha256sumaa" == "$firmware_sha256sum" ];then
			uci set systemup.base_arg.firwmare_date="200"
			uci commit systemup
			#echo "固件验证通过,提交刷机命令"
			if [ -n $push_key ];then
				printMsg "固件效验通过,提交刷机命令.请耐心等待路由器重启..." "ts"
			else
				printMsg "固件效验通过,提交刷机命令.请耐心等待路由器重启..."
			fi
			# 路由器刷机命令
			sysupgrade -v openwrt-x86-64-combined-squashfs.img.gz
            #echo "sysupgrade-vopenwrt-x86-64-combined-squashfs.img.gz"
		else
			#echo "固件验证不通过,放弃刷机"
			if [ -n $push_key ];then
				printMsg "固件效验不通过,请等待下次检查." "ts"
			else
				printMsg "固件效验不通过,请等待下次检查."
			fi
		fi
	fi
fi