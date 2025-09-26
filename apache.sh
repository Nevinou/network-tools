#!/bin/bash

sudo apt install apache2 -y

# copy du fichier de /etc/apache2/sites-enabled/000-default.conf en /etc/apache2/sites-enabled/000-default.conf_exemple
#sudo cp /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf_exemple

# écrase le fichier de conf (/etc/apache2/sites-enabled/000-default.conf) pour mettre la conf que l'on veut 

sudo bash -c 'cat > /etc/apache2/sites-enabled/site1.conf << EOF
<VirtualHost *:80>
	ServerName www.site1.b13.lan
	DocumentRoot /var/www/site1 
#	ErrorLog "/var/log/error_site.log" 
#	CustomLog "/var/log/access_site.log" combined 
</VirtualHost>
EOF'


sudo bash -c 'cat > /etc/apache2/sites-enabled/site2.conf << EOF
<VirtualHost *:80>
	ServerName www.site2.b13.lan
	DocumentRoot /var/www/site2 
#	ErrorLog "/var/log/error_site.log" 
#	CustomLog "/var/log/access_site.log" combined 
</VirtualHost>
EOF'

sudo bash -c 'cat > /etc/apache2/sites-enabled/000-default.conf << EOF
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/site1 
#	ErrorLog "/var/log/error_site.log" 
#	CustomLog "/var/log/access_site.log" combined 
</VirtualHost>
EOF'
sudo a2ensite site1.conf
sudo a2ensite site2.conf


#Ajout de l'écoute d'un port
sudo bash -c 'cat > /etc/apache2/ports.conf << EOF
Listen 80

#<IfModule ssl_module>
#	Listen 443
#</IfModule>

#<IfModule mod_gnutls.c>
#	Listen 443
#</IfModule>
EOF'

# Création du dossier site1
sudo mkdir /var/www/site1

sudo echo '<html><body><h1>Serveur web site 1</h1><p>Bienvenue sur le site web du site 1.</p></body></html>site1' > /var/www/site1/index.html 

# Création du dossier site2
sudo mkdir /var/www/site2

sudo echo '<html><body><h1>Serveur web site 2</h1><p>Bienvenue sur le site web du site 2.</p></body></html>site2' > /var/www/site2/index.html 


sudo systemctl restart apache2
sudo systemctl status apache2
