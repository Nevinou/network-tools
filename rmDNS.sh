#!/bin/bash
sudo rm /etc/bind/db.mon.lan
sudo rm -r /var/cache/bind
#sudo apt remove bind9 -y
sudo apt purge bind9 -y 
