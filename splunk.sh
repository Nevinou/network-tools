#!/bin/bash
set -e
#comm
# Variables (mets la bonne version/build depuis le site Splunk)

wget -O splunk-10.0.0-e8eb0c4654f8-linux-amd64.deb "https://download.splunk.com/products/splunk/releases/10.0.0/linux/splunk-10.0.0-e8eb0c4654f8-linux-amd64.deb"


# Installation du paquet
sudo dpkg -i splunk-${VERSION}-${BUILD}-Linux-x86_64.deb || sudo apt-get install -f -y

# Acceptation de la licence et démarrage
sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt

# Activer au démarrage
sudo /opt/splunk/bin/splunk enable boot-start
