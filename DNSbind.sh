#!/bin/bash

sudo echo 'nameserver 129.20.211.23' > /etc/resolv.conf
sudo apt install bind9 -y

# copy du fichier de /etc/bind/named.conf.option en /etc/bind/named.conf.option_exemple
# sudo cp /etc/bind/named.conf.option /home/user/named.conf.option_exemple
sudo bash -c 'cat > /etc/bind/named.conf.options << EOF
options {
	directory "/var/cache/bind";
	allow-query {any;}; 
	forward first;
	forwarders {
		10.10.0.1;
	};
	listen-on { any;};
};
logging {
	channel query_log {
		file "/var/log/named/query.log";
		severity info;
		print-time yes;
	};
	category queries { query_log; };
};
EOF'
# on peut rajouter de ACL voir IT-connect
sudo bash -c 'cat > /etc/bind/named.conf.local << EOF
zone "b13.lan"{
type master;
file "/etc/bind/db.b13.lan";
};
// ajouter la zone esclave
zone "b14.lan"{
type slave;
file "/etc/bind/db.b14.lan";
masters {10.10.14.1;};
};
EOF'
sudo touch /etc/bind/db.13.lan
sudo bash -c 'cat > /etc/bind/db.b13.lan << EOF

\$TTL 3H
@ IN SOA ns.b13.lan. mailaddress.b13.lan.(
2025051901
6H
1H
5D
1D)
;
@ IN NS ns.b13.lan.
@ IN MX 10 mail.b13.lan.
ns A 10.10.13.1
serveur A 10.10.13.1
mail A 10.10.13.2
debian A 10.10.13.3
w11 A 10.10.13.4
splunk A 10.10.13.5
www.site1 IN CNAME    serveur
www.site2 IN CNAME	serveur
EOF'

sudo systemctl restart bind9
sudo systemctl status bind9
