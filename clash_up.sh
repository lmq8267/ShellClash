#!/bin/sh
source /etc/storage/script/init.sh
source /etc/storage/script/sh_link.sh
cat /etc/profile | grep -o 'clash' &>/dev/null
if [ $? -ne 0 ]; then
cp -f /etc/profile /etc/storage/profile
rm -rf /etc/profile
cat >> "/etc/storage/profile" <<-OSC
alias clash="bash /etc/storage/clash/clash.sh"
export clashdir="/etc/storage/clash"
export all_proxy=http://127.0.0.1:7890
export ALL_PROXY=$all_proxy
OSC

cat /etc/storage/started_script.sh | grep -o 'profile' &>/dev/null
if [ $? -ne 0 ]; then
cat >> "/etc/storage/started_script.sh" <<-OSC
######shellcalsh环境变量#######
rm /etc/profile
ln -s /etc/storage/profile /etc/profile
source /etc/profile
###############################
OSC
ln -s /etc/storage/profile /etc/profile
source /etc/profile
fi
fi
tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --max-redirect=0 --output-document=-  https://api.github.com/repos/juewuy/ShellClash/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
[ -z "$tag" ] && tag="$( wget -T 5 -t 3 --user-agent "$user_agent" --quiet --output-document=-  https://api.github.com/repos/juewuy/ShellClash/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
[ -z "$tag" ] && tag="$( curl --connect-timeout 3 --user-agent "$user_agent"  https://api.github.com/repos/juewuy/ShellClash/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
[ -z "$tag" ] && tag="$( curl -L --connect-timeout 3 --user-agent "$user_agent" -s  https://api.github.com/repos/juewuy/ShellClash/releases/latest  2>&1 | grep 'tag_name' | cut -d\" -f4 )"
[ -z "$tag" ] && tag="$( curl -k -L --connect-timeout 20 --silent https://api.github.com/repos/juewuy/ShellClash/releases/latest | grep 'tag_name' | cut -d\" -f4 )"
[ -z "$tag" ] && tag="$(curl -k --silent "https://api.github.com/repos/juewuy/ShellClash/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')"
clashver="$(cat /etc/storage/clash/init.sh | grep -E ^version= | head -n 1 | sed 's/version=//'| tr -d "[a-z][A-Z]")"
echo $tag $clashver
if [ ! -z "$tag" ] && [ ! -z "$clashver" ] ; then
   if [ "$tag"x != "$clashver"x ] ; then
[ ! -d /tmp/var/clash ] && mkdir -p /tmp/var/clash
logger -t "【ShellClash】" "最新版ShellClash_$tag ,开始更新..."
wgetcurl_checkmd5 /tmp/var/ShellClash.tar.gz https://fastly.jsdelivr.net/gh/juewuy/ShellClash@$tag/bin/ShellClash.tar.gz
if [ -s /tmp/var/ShellClash.tar.gz ] ; then
tar -xzvf /tmp/var/ShellClash.tar.gz -C /tmp/var/clash
fi
rm -rf /tmp/var/clash/misnap_init.sh

if [ ! -f /tmp/var/clash/clash_websave.sh ] && [ ! -s /tmp/var/clash/clash_websave.sh ] ;then
    cat > "/tmp/var/clash/clash_websave.sh" <<-\EEE
#!/bin/bash
source /etc/storage/script/init.sh
source /etc/storage/script/sh_link.sh
sed -Ei '/【ShellClash】|^$/d' /tmp/script/_opt_script_check
  cat >> "/tmp/script/_opt_script_check" <<-OSC
[ -z "\`pidof clash\`" ] && logger -t "【ShellClash】" "重新启动" &&  /etc/storage/clash/start.sh restart 
[ -z "\`pidof clash_websave.sh\`" ] && /etc/storage/clash/clash_websave.sh & #【ShellClash】
OSC

 while true; do
 sleep 600
/etc/storage/clash/start.sh web_save &
check2=404
check_timeout_network "wget_check" "check"
if [ "$check2" == "404" ] ; then
rm -rf /tmp/var/favicon.ico
curl -L -k -S -o /tmp/var/favicon.ico --connect-timeout 10 --retry 3 https://www.google.com/favicon.ico
[ ! -s /tmp/var/favicon.ico ] && curl --proxy 127.0.0.1:7890 -L -k -S -o /tmp/var/favicon.ico --connect-timeout 10 --retry 3 https://www.google.com/favicon.ico
if [ ! -s /tmp/var/favicon.ico ] ; then
logger -t "【ShellClash】" "访问Google异常，重新启动" 
/etc/storage/clash/start.sh restart
sleep 35
check2=404
check_timeout_network "wget_check" "check"
fi
fi
if [ "$check2" == "200" ] ; then
	echo 访问Google正常
fi

done
EEE
	chmod 755 /tmp/var/clash/clash_websave.sh
fi

if [ ! -f /tmp/var/clash/clash_keep.sh ] && [ ! -s /tmp/var/clash/clash_keep.sh ] ;then
    cat > "/tmp/var/clash/clash_keep.sh" <<-\EEE
#!/bin/bash

sed -Ei '/【ShellClash】|^$/d' /tmp/script/_opt_script_check

EEE
	chmod 755 /tmp/var/clash/clash_keep.sh
fi

cat /tmp/var/clash/clash.sh | grep -o 'db_port=9999' &>/dev/null
if [ $? -eq 0 ]; then
sed -i '/db_port=9999/d' /tmp/var/clash/clash.sh
sed -i '/dns_port=1053/a    [ -z "$db_port" ] && db_port=9090' /tmp/var/clash/clash.sh
else
logger -t "【ShellClash】" "clash.sh中没有db_port=9999"
fi

cat /tmp/var/clash/init.sh | grep -o '#ShellClash初始化脚本" >> $initdir' &>/dev/null
if [ $? -ne 0 ]; then
echo 未找到#ShellClash初始化脚本
else
sed -i '/#ShellClash初始化脚本"/d' /tmp/var/clash/init.sh
sed -i '/chmod a+rx $initdir 2>/i    echo "$clashdir/start.sh start & #ShellClash开机自启" >> $initdir ' /tmp/var/clash/init.sh
fi

cat /tmp/var/clash/start.sh | grep -o 'db_port=9999' &>/dev/null
if [ $? -eq 0 ]; then
sed -i '/db_port=9999/d' /tmp/var/clash/start.sh
sed -i '/dns_port=1053/a    [ -z "$db_port" ] && db_port=9090' /tmp/var/clash/start.sh
else
logger -t "【ShellClash】" "/tmp/var/clash/clash.sh中没有db_port=9999"
fi

cat /tmp/var/clash/start.sh | grep -o '/tmp/syslog.log' &>/dev/null
if [ $? -ne 0 ]; then
sed -i '/echo $log_text >>/a    echo $log_text >> /tmp/syslog.log' /tmp/var/clash/start.sh
else
logger -t "【ShellClash】" "start.sh中有/tmp/syslog.log"
fi

cat /tmp/var/clash/start.sh | grep -o 'date "+%G-%m-%d_%H:%M:%S"' &>/dev/null
if [ $? -eq 0 ]; then
sed -i 's|$(date "+%G-%m-%d_%H:%M:%S")~$1|$(TZ=UTC-8 date "+%G年%m月%d日 %H:%M:%S") 【ShellClash】：$1|g' /tmp/var/clash/start.sh
fi

cat /tmp/var/clash/start.sh | grep -o '每10分钟保存节点配置' &>/dev/null
if [ $? -eq 0 ]; then
sed -i '/每10分钟保存节点配置/d' /tmp/var/clash/start.sh
fi

cat /tmp/var/clash/start.sh | grep -o 'Clash服务已启动' &>/dev/null
if [ $? -eq 0 ]; then
sed -i '/Clash服务已启动/a    logger Clash守护进程启动！' /tmp/var/clash/start.sh
sed -i '/logger Clash守护进程启动/a    /etc/storage/clash/clash_websave.sh &' /tmp/var/clash/start.sh
fi

cat /tmp/var/clash/start.sh | grep -o 'clash保守模式守护进程' &>/dev/null
if [ $? -eq 0 ]; then
sed -i '/clash保守模式守护进程/d' /tmp/var/clash/start.sh
fi

cat /tmp/var/clash/start.sh | grep -o '服务即将关闭' &>/dev/null
if [ $? -eq 0 ]; then
sed -i '/服务即将关闭/i    /etc/storage/clash/clash_keep.sh' /tmp/var/clash/start.sh
sed -i '/服务即将关闭/a    killall clash_websave.sh &' /tmp/var/clash/start.sh
sed -i '/killall clash_websave.sh/a    killall -9 clash_websave.sh &' /tmp/var/clash/start.sh
fi
chmod 755 /tmp/var/clash/*
cp -rf /tmp/var/clash/* /etc/storage/clash/
[ -z "\`pidof clash\`" ] && /etc/storage/clash/start.sh start &
fi
fi
