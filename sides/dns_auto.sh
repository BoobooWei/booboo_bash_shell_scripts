#!/bin/bash

INSTALL(){
yum install -y bind bind-chroot
}

ETC1(){
#sed -i 's/127.0.0.1/any/;s/::1/any/;s/localhost/any/' /etc/named.conf
sed -i 's/{.*; };/{ any; };/' /etc/named.conf
}


checkdomain (){
[[ $1 =~ \. ]] && echo 0 || echo 1;
}

checkip () {
if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
    IP=(${1//\./ })
    [ ${IP[0]} -gt 0 -a ${IP[0]} -lt 255 ] && [ ${IP[1]} -ge 0 -a ${IP[1]} -le 255 ] && [ ${IP[2]} -ge 0 -a ${IP[2]} -le 255 ] && [ ${IP[3]} -gt 0 -a ${IP[3]} -lt 255 ] && echo 0 || echo 1
 
else
        echo 1
fi
}
		
RFC () {
DOM=${domain#*.}
HO=${domain%%.*}
IP=(${ipadd//./ })
RFC="/etc/named.rfc1912.zones"
#RFC=/tmp/named.rfc1912.zones

if grep "$DOM" $RFC &> /dev/null
then
	read
else 
cat >> $RFC << ENDF
zone "$DOM" IN {
        type master;
        file "named.$DOM";
        allow-update { none; };
};
ENDF
fi

if grep "${IP[2]}.${IP[1]}.${IP[0]}" $RFC &> /dev/null
then
	read
else
cat >> $RFC << ENDF
zone "${IP[2]}.${IP[1]}.${IP[0]}.in-addr.arpa" IN {
        type master;
        file "named.arpa.$DOM";
        allow-update { none; };
};
ENDF
fi

ls /var/named/named.$DOM &> /dev/null || (cp -rp /var/named/named.localhost /var/named/named.$DOM && sed -i '9,10d' /var/named/named.$DOM)
grep -v "SOA" /var/named/named.$DOM|grep "A" &> /dev/null || sed -i "\$a\\\tA\t$ipadd" /var/named/named.$DOM
grep "$HO" /var/named/named.$DOM &> /dev/null || sed -i "\$a$HO\tA\t$ipadd" /var/named/named.$DOM


ls /var/named/named.arpa.$DOM &> /dev/null || (cp -rp /var/named/named.loopback /var/named/named.arpa.$DOM && sed -i '8,$d' /var/named/named.arpa.$DOM)
grep NS /var/named/named.arpa.$DOM &> /dev/null || sed -i "\$a\\\tNS\t$DOM." /var/named/named.arpa.$DOM
grep "PTR     $DOM." /var/named/named.arpa.$DOM &> /dev/null || sed -i "\$a${IP[3]}\tPTR\t$DOM." /var/named/named.arpa.$DOM
grep "${IP[3]}       PTR     $domain." /var/named/named.arpa.$DOM  &> /dev/null || sed -i "\$a${IP[3]}\tPTR\t$domain." /var/named/named.arpa.$DOM



}

SERVICE(){
systemctl start named
}

READ () {
read -p "请输入要设置的正向解析域名:" domain
read -p "请输入要设置的正向解析域名所对应的ip地址:" ipadd
}


# 程序正文
#安装软件
echo "1.开始安装DNS相关程序"
read
INSTALL
#配置文件/etc/named.conf
echo "2.配置文件/etc/named.conf"
read
ETC1
#配置正反解析
echo "3.配置正反解析"
read
until [[ `checkdomain $domain` -eq 0 && `checkip $ipadd` -eq 0 ]]
do
	READ

	
	if [[ `checkdomain $domain` -eq 0 && `checkip $ipadd` -eq 0 ]]
	then
		RFC
	elif [[ `checkdomain $domain` -eq 1 && `checkip $ipadd` -eq 0 ]] 
		then 
			echo "域名不正确"
		elif	[[ `checkdomain $domain` -eq 0 && `checkip $ipadd` -eq 1 ]] 
			then 
				echo "ip地址不正确"
			else 
				echo "域名和ip都不正确"
	fi
done

# 配置结束
echo "4.启动服务"
read
SERVICE

# 查看服务状态
read
systemctl status named
