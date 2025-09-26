#!/bin/bash

set -e

REPO_BASE="https://raw.githubusercontent.com/Nevinou/network-tools/main"

echo "[*] Installation des script réseau dans le répertoir $DOSSIER_INSTALL"

curl "$REPO_BASE/$1">$2
sudo chmod +x $2

echo "[✔] Tous les outils ont été installés avec succès."
