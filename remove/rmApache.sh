#!/bin/bash
sudo apt remove apache2 -y
sudo rm /etc/apache2/sites-enabled/site1.conf
sudo rm /etc/apache2/sites-enabled/site2.conf
sudo rm /var/www/site1 -R
sudo rm /var/www/site2 -R
sudo apt purge apache2 -y
