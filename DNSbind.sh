#!/bin/bash
sudo apt autoremove -y
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
	listen-on { any; };
};
EOF'

sudo bash -c 'cat > /etc/bind/named.conf.local << EOF
zone "lan"{
	type forward;
	forwarders { 10.10.0.1; };
};

zone "b13.lan"{
	type primary;
	file "/etc/bind/db.b13.lan";
	allow-transfer { 10.10.14.1; };
};

zone "b12.lan"{
	type slave;
	file "/var/cache/bind/db.b12.lan";
	masters { 10.10.12.1; };
};
EOF'

sudo touch /etc/bind/db.b13.lan
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
