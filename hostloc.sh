#!/usr/bin/env bash

#原作者：zdszf
##原 https://raw.githubusercontent.com/mixool/script/debian-9/hostloc.sh
#
#Auth：逸笙
#用法1：bash hostloc.sh username password
#用法2：bash hostloc.sh accountfile

#微信开发者服务wxpusher，不用就留空
we_no_id=""

declare -A userpsw
declare -A getcredit
# get user info
if [ $# -eq 2 ]; then
  userpsw["$1"]="$2"
fi
if [ $# -eq 1 ]; then
  if [ -s "$1" ]; then
    usrarry=(`cat $1 | awk '{print $1}'`)
    pswarry=(`cat $1 | awk '{print $2}'`)
    for((u=0;u<${#usrarry[*]};u++))
    do
      userpsw["${usrarry[$u]}"]="${pswarry[$u]}"
    done
  else
    echo 文件 $1 不存在
    exit 1
  fi
fi

# workdir
workdir="/tmp"
[[ ! -d "${workdir}" ]] && mkdir ${workdir}

UA="Mozilla/5.0+(Windows+NT+6.2;+Win64;+x64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/74.0.3729.131+Safari/537.36"

delaytime=25

function login() {
  echo -n $(date "+%Y-%m-%d %H:%M:%S %A") ${username} 登陆... 
  data="mod=logging&action=login&loginsubmit=yes&infloat=yes&lssubmit=yes&inajax=1&fastloginfield=username&username=$username&cookietime=$(shuf -i 1234567-7654321 -n 1)&password=$password&quickforward=yes&handlekey=ls"
  curl -s -H "$UA" -c ${workdir}/${cookiefile} --data "$data" "https://www.hostloc.com/member.php" | grep -o "www.hostloc.com" && echo -n $(date "+%Y-%m-%d %H:%M:%S %A") 成功 || status="1"
  [[ $status -eq 1 ]] && echo 失败 && continue
  youruid=(`curl -s -H "$UA" -b ${workdir}/${cookiefile} "https://www.hostloc.com/home.php?mod=spacecp&ac=credit" | grep -oE "uid=\w*" | awk -F '[=]' '{print $2}'`)
  echo "(UID为：${youruid})"
}

function randuid() {
  newuserspace=`curl -s https://www.hostloc.com/forum.php | grep -oE "欢迎新会员: <em><a href=".*" " | awk -F'"' '{print $2}'`
  maxuid=`curl -s https://www.hostloc.com/${newuserspace} | grep "空间首页" | awk -F'uid=' '{print $2}' | awk -F '&' '{print $1}'`
  tmpuid=$((maxuid-200))
  
  startuid=0
  enduid=${maxuid}
  while [ $youruid -gt $startuid -a $youruid -lt $enduid ]
  do
    #随机数
    r=`head -200 /dev/urandom | cksum | cut -f1 -d" "`
    startuid=$((r%tmpuid+100))
    enduid=$((startuid+100))
  done

  #随机间隔时间
  delaytime=$((r%50+10))
  #delaytime=3
}

function credit() {
  creditall=$(curl -s -H "$UA" -b ${workdir}/${cookiefile} "https://www.hostloc.com/home.php?mod=spacecp&ac=credit&op=base" | grep -oE "积分: </em>\w*" | awk -F'[>]' '{print $2}')
  echo $(date "+%Y-%m-%d %H:%M:%S %A") 目前积分为：${creditall}
}

function view() {
  a=0
  echo -n $(date "+%Y-%m-%d %H:%M:%S %A") 访问空间：
  echo 从$startuid开始，间隔${delaytime}s...
  for((i = $startuid; i <= $enduid; i++))
  do
    p=0 
    sleep ${delaytime}
    echo -n $(date "+%Y-%m-%d %H:%M:%S %A") ${i}
    curl -s -H "$UA" -b ${workdir}/${cookiefile} "https://www.hostloc.com/space-uid-$i.html" | grep -o "最近访客" >/dev/null && p=1 || echo " banlist"
    if [ $p -eq 1 ]; then
      ((a++))
      echo -e " ok，\t$a"
    fi
    [[ $a -eq 10 ]] && break
  done
  echo $(date "+%Y-%m-%d %H:%M:%S %A") 完成
}

function notice() {
  if [ $2 -lt 20 ]; then
    data1='{"userIds":["'${we_no_id}
    data1=${data1}'"],"template_id":"lpO9UoVZYGENPpuND3FIofNueSMJZs0DMiU7Bl1eg2c","data":{"first":{"value":"'
    data1=${data1}'HostLoc访问空间'
    data1=${data1}'","color":"#ff0000"},"keyword1":{"value":"'
    data1=${data1}$2
    data1=${data1}'","color":"#ff0000"},"keyword2":{"value":"'
    data1=${data1}$1
    data1=${data1}'","color":"#ff0000"},"keyword3":{"value":"'
    data1=${data1}$(date "+%F %T %A")
    data1=${data1}'","color":"#009900"},"remark":{"value":"'
    remark1="不到20分。"
    [ $2 -eq 0 ] && remark1="居然0分，请检查帐号状态。"
    data1=${data1}${remark1}
    data1=${data1}'","color":"#000099"}}}'
    curl -X POST "http://wxmsg.dingliqc.com/send" -d "$data1" -H "Content-Type:application/json"
    echo
  fi
}

function main() {
  echo '~START~'
  for user1 in ${!userpsw[*]}
  do
    username=${user1}
    password=${userpsw[$user1]}
    cookiefile=${username}.cookie
    creditall=0
    
    login
    randuid
    credit
    precredit=${creditall}
    view
    credit
    aftcredit=${creditall}
    getcredit["$username"]=$((aftcredit-precredit))
    [ -n "${we_no_id}" ] && notice ${username} ${getcredit[$user1]}
    
    # clean
    rm -rf ${workdir}/${cookiefile}
    # exit
    echo $(date "+%Y-%m-%d %H:%M:%S %A") ${username} Accomplished.
    echo 
    sleep ${delaytime}
  done
  
  echo
  for user1 in ${!getcredit[*]}
  do
    echo ${user1} 获得 ${getcredit[$user1]}
  done
  echo '~END~'
}

main
