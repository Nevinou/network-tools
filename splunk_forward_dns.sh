#!/bin/bash
set -e

# === Variables à personnaliser ===
SPLUNK_VERSION="9.2.0"
SPLUNK_BUILD="a0c72a66db1f"
SPLUNK_DEB="splunkforwarder-${SPLUNK_VERSION}-${SPLUNK_BUILD}-Linux-x86_64.deb"
SPLUNK_URL="https://download.splunk.com/products/universalforwarder/releases/${SPLUNK_VERSION}/linux/${SPLUNK_DEB}"
SPLUNK_HOME="/opt/splunkforwarder"
SPLUNK_ADMIN_PASS="123Soleil%"
SPLUNK_SERVER="10.10.13.5:9997"          # ← IP:port de ton indexer
INDEX="services"                          # ← index cible dans Splunk (crée-le si besoin)
UNIT="named.service"                      # ← nom systemd de BIND (bind9.service par défaut)

echo "[*] Téléchargement de Splunk Forwarder..."
wget -O /tmp/${SPLUNK_DEB} ${SPLUNK_URL}

echo "[*] Installation du paquet..."
sudo dpkg -i /tmp/${SPLUNK_DEB}

echo "[*] Initialisation Splunk Forwarder..."
sudo ${SPLUNK_HOME}/bin/splunk start --accept-license --answer-yes \
  --no-prompt --seed-passwd ${SPLUNK_ADMIN_PASS}

echo "[*] Configuration du forwarder (outputs.conf)..."
sudo tee ${SPLUNK_HOME}/etc/system/local/outputs.conf >/dev/null <<EOF
[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = ${SPLUNK_SERVER}

[forwardedindex.filter.disable]
disabled = true
EOF

echo "[*] Création du scripted input (journalctl -> lignes BIND UP/DOWN uniquement)..."
sudo install -d -m 0755 ${SPLUNK_HOME}/bin
sudo tee ${SPLUNK_HOME}/bin/dns_watch.sh >/dev/null <<'EOS'
#!/usr/bin/env bash
# Émet UNIQUEMENT les lignes intéressantes de bind9 sur la dernière minute.
UNIT="${UNIT:-bind9.service}"
# Si journalctl n'existe pas ou pas de droits, on sort proprement.
command -v journalctl >/dev/null 2>&1 || exit 0
# Sortie au format "time | host | status | message"
HOST=$(hostname -f 2>/dev/null || hostname)
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Récupère les événements de la dernière minute
LOGS=$(journalctl -u "$UNIT" --since "-1 min" --no-pager -o short-iso 2>/dev/null)

# Filtrage des états UP/DOWN/FAILED
# Ajuste les motifs si nécessaire selon tes logs exacts
echo "$LOGS" | awk -v host="$HOST" -v now="$NOW" '
/Started BIND Domain Name Server|named.*(starting|listening on)/ {print now " | " host " | UP | " $0}
/Stopped BIND Domain Name Server|Failed with result|named.*(shutting down|exiting|fatal)/ {print now " | " host " | DOWN | " $0}
'
EOS
sudo sed -i "s/UNIT:-bind9.service/UNIT:-${UNIT}/" ${SPLUNK_HOME}/bin/dns_watch.sh
sudo chmod +x ${SPLUNK_HOME}/bin/dns_watch.sh

echo "[*] Déclare le scripted input (inputs.conf)..."
sudo tee ${SPLUNK_HOME}/etc/system/local/inputs.conf >/dev/null <<EOF
# Script exécuté chaque minute, n’envoie que les lignes UP/DOWN de bind9
[script://${SPLUNK_HOME}/bin/dns_watch.sh]
interval = 60
sourcetype = bind_alert
index = ${INDEX}
EOF

echo "[*] Redémarrage du forwarder..."
sudo ${SPLUNK_HOME}/bin/splunk restart

echo "[*] Fini. Dans Splunk, cherche : index=${INDEX} sourcetype=bind_alert"
