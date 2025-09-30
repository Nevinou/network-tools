#!/bin/bash
sudo rm /etc/bind/db.b12.lan
sudo rm /etc/bind/db.b13.lan
sudo rm -r /var/cache/bind
#sudo apt remove bind9 -y
sudo apt purge bind9 -y 
