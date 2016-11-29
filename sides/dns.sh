#!/bin/bash
INSTALL(){
yum install -y bind bind-chroot
}

ETC1(){
#sed -i 's/127.0.0.1/any/;s/::1/any/;s/localhost/any/' /etc/named.conf
sed -i 's/{.*; };/{ any; };/' /etc/named.conf
}
ETC2(){
cat >> /etc/named.rfc1912.zones << ENDF
zone "uplooking.com" IN {
        type master;
        file "named.uplooking.com";
        allow-update { none; };
};
zone "0.25.172.in-addr.arpa" IN {
        type master;
        file "named.arpa.uplooking.com";
        allow-update { none; };
};
ENDF
}

ZONE(){
cp -rp /var/named/named.localhost /var/named/named.uplooking.com
cat > /var/named/named.uplooking.com <<ENDF
\$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      @
	A	172.25.0.11
www	A	172.25.0.11
ENDF
cp -rp /var/named/named.loopback /var/named/named.arpa.uplooking.com
cat > /var/named/named.arpa.uplooking.com <<ENDF
\$TTL 1D
@       IN SOA  @ rname.invalid. (
                                        0       ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
        NS      uplooking.com.
        PTR	uplooking.com.
11	PTR	www.uplooking.com.
ENDF

}

SERVICE(){
systemctl start named
}

INSTALL
#ETC1
#ETC2
#ZONE
#SERVICE

