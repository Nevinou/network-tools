#!/bin/bash

sudo apt install kea-dhcp4-server -y
# copy du fichier de /etc/kea/kea-dhcp4.conf en /etc/kea/kea-dhcp4.conf_exemple
sudo cp /etc/kea/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf_exemple
sudo bash -c 'cat > /etc/kea/kea-dhcp4.conf << EOF 
{ 
"Dhcp4": {
	"interfaces-config": {
		"interfaces": [ "ens18" ]
	}, 
	"valid-lifetime" : 600,
	"max-valid-lifetime":7200, 
	"renew-timer": 3400, 
	"rebind-timer": 6000, 
	"authoritative": true, 
	"lease-database": {
		"type": "memfile", 
		"persist": true, 
		"name": "/var/lib/kea/kea-leases4.csv", 
		"lfc-interval": 3600 
	}, 
		"subnet4": [ 
			{ 
				"subnet": "10.10.0.0/16", 

				"option-data": [ 
					{
						"name": "domain-name-servers", 
						"data": "10.10.13.1"
					}, 
					{
						"name": "domain-search",
						"data": "b13.lan"
					},
					{ 
						"name": "routers", 
						"data": "10.10.0.254" 
					} 
				], 
				"reservations": [
					{
                        "hw-address": "bc:24:11:8b:6a:87",
                        "ip-address": "10.10.13.2",
                        "hostname": "ServeurMail"
                    },
					{
                        "hw-address": "bc:24:11:7c:e1:d6",
                        "ip-address": "10.10.13.3",
                        "hostname": "W11"
                    },
                    {
                        "hw-address": "bc:24:11:58:83:2a",
                        "ip-address": "10.10.13.4",
                        "hostname": "ClientLinux"
                    },
					{
                        "hw-address": "bc:24:11:88:f5:32",
                        "ip-address": "10.10.13.5",
                        "hostname": "ServeurSplunk"
                    }
					
                ]
			} 
		],
		"loggers": [
			{
			"name": "kea-dhcp4",
			"output_options":[
				{
				"output": "/var/log/kea/kea-dhcp4.log"
				}
				],
			"severity": "INFO",
			"debuglevel": 0
			}
		]

	} 
}
EOF' 
sudo systemctl restart kea-dhcp4-server.service
sudo systemctl status kea-dhcp4-server.service
