#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "[Error] The system version was not detected, please check\n" && exit 1
fi

if ! command -v wget >/dev/null 2>&1; then 
    if [[ x"${release}" == x"centos" ]]; then
        yum install -y wget
    elif [[ x"${release}" == x"ubuntu" ]]; then
        apt install -y wget
    elif [[ x"${release}" == x"debian" ]]; then
        apt install -y wget
    fi
fi

get_ip(){
    local IP=$( ip addr | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | egrep -v "^192\.168|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[0-2]\.|^10\.|^127\.|^255\.|^0\." | head -n 1 )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipv4.icanhazip.com )
    [ -z ${IP} ] && IP=$( wget -qO- -t1 -T2 ipinfo.io/ip )
    echo ${IP}
}

if  [ -n "$1" ] ;then
    if ! command -v dig >/dev/null 2>&1; then 
        if [[ x"${release}" == x"centos" ]]; then
            yum install -y bind-utils
        elif [[ x"${release}" == x"ubuntu" ]]; then
            apt install -y dnsutils
        elif [[ x"${release}" == x"debian" ]]; then
            apt install -y dnsutils
        fi
    fi
    ddns="$@"
    newip=`dig -t A +noquestion +noadditional +noauthority +tcp @8.8.8.8 ${ddns} | awk '/IN[ \t]+A/{print $NF}'`
else
    newip=$(get_ip)
fi

file=/etc/dnsmasq.d/custom_mich.conf
[ ! -e ${file} ] && echo "[Error] The dnsmasq configuration file does not exist, please check" && exit 1
IPREX='([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
time=`date +"%Y-%m-%d-%H:%M"`
oldip=`grep xbox.com ${file}|grep -Eo "$IPREX"|tail -n1`

if [ $oldip != $newip ]; then
    sed -i "s/$oldip/$newip/g" ${file}
    systemctl restart dnsmasq
    [ -e /tmp/autochangeip.log ] || touch /tmp/autochangeip.log
    echo "${time} - ${oldip} updated to ${newip}" >> /tmp/autochangeip.log
    tail -n 100 /tmp/autochangeip.log > /tmp/tmpautochangeip.log
    mv -f /tmp/tmpautochangeip.log /tmp/autochangeip.log
fi

#Description
#This script is designed to facilitate some dynamic IP unlocking hosts and automatically update dnsmasq resolution records
#Without parameters: bash autochangeip.sh automatically updates to the local public IP
#With parameters: bash autochangeip.sh ddns.example.com automatically updates to the IP resolved by the ddns domain name
#Use crontab to execute regularly, run the command crontab -e to add a schedule, for example:
# */5 * * * * bash autochangeip.sh
#The above example is executed every 5 minutes. In the actual configuration, do not add the # symbol in front. Pay attention to modify the correct script file path