#!/bin/bash

sudo apt install kea-dhcp4-server -y
# copy du fichier de /etc/kea/kea-dhcp4.conf en /etc/kea/kea-dhcp4.conf_exemple
sudo cp /etc/kea/kea-dhcp4.conf /home/user/kea-dhcp4.conf_exemple
sudo bash -c 'cat > /etc/kea/kea-dhcp4.conf << EOF 
{ 
"Dhcp4": {
	"interfaces-config": {
		"interfaces": [ "ens192" ]
	}, 
	"valid-lifetime" : 600,
	"max-valid-lifetime":7200, 
	"renew-timer": 345600, 
	"rebind-timer": 604800, 
	"authoritative": true, 
	"lease-database": {
		"type": "memfile", 
		"persist": true, 
		"name": "/var/lib/kea/kea-leases4.csv", 
		"lfc-interval": 3600 
	}, 
		"subnet4": [ 
			{ 
				"subnet": "10.10.13.0/16", 
				"pools": [ 
					{ 
						"pool": "10.10.13.0 - 10.10.13.0" 
					} 
				], 
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
                        "hw-address": "",
                        "ip-address": "10.200.13.2",
                        "hostname": ""
                    },
					{
                        "hw-address": "",
                        "ip-address": "10.200.13.3",
                        "hostname": ""
                    },
					{
                        "hw-address": "",
                        "ip-address": "10.200.13.4",
                        "hostname": ""
                    },
					{
                        "hw-address": "",
                        "ip-address": "10.200.13.5",
                        "hostname": ""
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
