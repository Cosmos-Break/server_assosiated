#!/bin/bash

# ====================================================
#	System Request:Debian 8
#	Author:	Chikage
#	Nginx+PHP+Aria2+Rclone+DirectoryLister+AriaNg
# ====================================================
#fonts color
Green="\033[32m" 
Red="\033[31m" 
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

#notification information
Info="${Green}[Info]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[Error]${Font}"

#folder
nginx_conf_dir="/etc/nginx/conf.d"
aria2ng_new_ver="0.3.0"
aria2ng_download_http="https://github.com/mayswind/AriaNg/releases/download/${aria2ng_new_ver}/aria-ng-${aria2ng_new_ver}.zip"
aria2_new_ver="1.34.0"

aria_install(){
echo -e "${GreenBG} 开始安装Aria2 ${Font}"
apt update
apt-get update
apt-get install build-essential cron -y
apt install wget unzip net-tools bc curl sudo -y 
apt install make -y

cd /root
mkdir Download


#下载静态文件
wget https://github.com/q3aql/aria2-static-builds/releases/download/v1.34.0/aria2-1.34.0-linux-gnu-64bit-build1.tar.bz2
#解压文件并进入文件夹
tar jxvf aria2-*.tar.bz2 && rm -rf aria2-*.tar.bz2
Aria2_Name="aria2-1.34.0-linux-gnu-64bit-build1"
mv "${Aria2_Name}" "aria2"
cd "aria2/"
make install
#开始安装

cd /root



mkdir "/root/.aria2" && cd "/root/.aria2"
wget "https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/master/sh/dht.dat"
wget "https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/master/sh/trackers-list-aria2.sh"
echo '' > /root/.aria2/aria2.session
chmod +x /root/.aria2/trackers-list-aria2.sh
chmod 777 /root/.aria2/aria2.session
echo "dir=/root/Download

disk-cache=32M
file-allocation=trunc
continue=true


max-concurrent-downloads=5
max-connection-per-server=5
min-split-size=10M
split=20
max-overall-upload-limit=10K
disable-ipv6=false
input-file=/root/.aria2/aria2.session
save-session=/root/.aria2/aria2.session




follow-torrent=true
listen-port=51413
enable-dht=true
enable-dht6=false
dht-listen-port=6881-6999
bt-enable-lpd=true
enable-peer-exchange=true
peer-id-prefix=-TR2770-
user-agent=Transmission/2.77
seed-time=0
bt-seed-unverified=true
on-download-complete=/root/.aria2/autoupload.sh
allow-overwrite=true
bt-tracker=udp://tracker.coppersurfer.tk:6969/announce,udp://tracker.open-internet.nl:6969/announce,udp://p4p.arenabg.com:1337/announce,udp://tracker.internetwarriors.net:1337/announce,udp://allesanddro.de:1337/announce,udp://9.rarbg.to:2710/announce,udp://tracker.skyts.net:6969/announce,udp://tracker.safe.moe:6969/announce,udp://tracker.piratepublic.com:1337/announce,udp://tracker.opentrackr.org:1337/announce,udp://tracker2.christianbro.pw:6969/announce,udp://tracker1.wasabii.com.tw:6969/announce,udp://tracker.zer0day.to:1337/announce,udp://public.popcorn-tracker.org:6969/announce,udp://tracker.xku.tv:6969/announce,udp://tracker.vanitycore.co:6969/announce,udp://inferno.demonoid.pw:3418/announce,udp://tracker.mg64.net:6969/announce,udp://open.facedatabg.net:6969/announce,udp://mgtracker.org:6969/announce" > /root/.aria2/aria2.conf
echo "0 3 */7 * * /root/.aria2/trackers-list-aria2.sh
*/5 * * * * /usr/sbin/service aria2 start" > bt.cron
crontab bt.cron
rm -rf bt.cron
}

rclone_install(){
echo -e "${GreenBG} 开始安装Rclone ${Font}"
cd /root
apt-get install -y nload htop fuse p7zip-full
cd /tmp
wget -O '/tmp/rclone.zip' "https://downloads.rclone.org/rclone-current-linux-amd64.zip"
7z x /tmp/rclone.zip
cd rclone-*
cp -raf rclone /usr/bin/
chown root:root /usr/bin/rclone
chmod 755 /usr/bin/rclone
mkdir -p /usr/local/share/man/man1
cp -raf rclone.1 /usr/local/share/man/man1/
rm -f rclone_debian.sh
rclone config
stty erase '^H' && read -p "请输入你刚刚输入的Name:" name && read -p "请输入你云盘中需要挂载的文件夹:" folder
}

init_install(){
echo -e "${GreenBG} 开始配置自启 ${Font}"
chmod +x /etc/init.d/aria2
update-rc.d -f aria2 defaults
wget https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/chiakge-patch-1/sh/autoupload.sh
sed -i '4i\name='${name}'' autoupload.sh
sed -i '4i\folder='${folder}'' autoupload.sh
mv autoupload.sh /root/.aria2/autoupload.sh
chmod +x /root/.aria2/autoupload.sh
wget https://raw.githubusercontent.com/chiakge/Aria2-Rclone-DirectoryLister-Aria2Ng/chiakge-patch-1/sh/rcloned
web="/home/wwwroot/${domain}/Cloud"
sed -i '16i\NAME='${name}'' rcloned
sed -i '16i\REMOTE='${folder}'' rcloned
sed -i '16i\LOCALFile='${web}'' rcloned
mv rcloned /etc/init.d/rcloned
chmod +x /etc/init.d/rcloned
update-rc.d -f rcloned defaults
bash /etc/init.d/aria2 start
bash /etc/init.d/rcloned start
}

main(){
			aria_install
			rclone_install
			init_install
}

main
