#!/bin/bash

set -e

REPO_BASE="https://raw.githubusercontent.com/Nevinou/network-tools/refs/heads/main"
DOSSIER_INSTALL="/usr/local/bin"

TOOLS=("DHCPkea" "DNSbind" "apache")

echo "[*] Installation des script réseau dans le répertoir $DOSSIER_INSTALL"

for tool in "${TOOLS[@]}";do
    echo "  ↪ Téléchargement de $tool..."
    curl -sSL "$REPO_BASE/$tool.sh" -o "$tool"
    chmod +x "$tool"
    #echo "  ↪ Installation dans $INSTALL_DIR..."
    #mv "$tool" "$INSTALL_DIR/$tool"
done

echo "[✔] Tous les outils ont été installés avec succès."
