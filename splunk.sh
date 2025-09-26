#!/bin/bash
set -e
#comm
# Variables (mets la bonne version/build depuis le site Splunk)
VERSION="9.2.1"
BUILD="<build>"   # à remplacer par le vrai numéro de build

URL="https://download.splunk.com/products/splunk/releases/$VERSION/linux/splunk-${VERSION}-${BUILD}-Linux-x86_64.deb"

# Téléchargement
wget "$URL"

# Installation du paquet
sudo dpkg -i splunk-${VERSION}-${BUILD}-Linux-x86_64.deb || sudo apt-get install -f -y

# Acceptation de la licence et démarrage
sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt

# Activer au démarrage
sudo /opt/splunk/bin/splunk enable boot-start
