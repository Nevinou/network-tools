#!/usr/bin/env bash
UNIT="named.service"   # → le service à surveiller (BIND = named.service)
HOST=$(hostname -f 2>/dev/null || hostname)  # → nom du serveur (FQDN si dispo)
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")        # → timestamp en format ISO (UTC)

STATUS=$(systemctl is-active "$UNIT" 2>/dev/null)  
# → lance la commande `systemctl is-active named.service`
#   et met le résultat dans STATUS (ex: active, inactive, failed, etc.)
# → si `systemctl` échoue, rien ne sera affiché

if [ "$STATUS" = "active" ]; then
    # → si le service est actif, on log un event UP
    echo "$NOW | $HOST | UP | systemctl is-active $UNIT = $STATUS"
else
    # → sinon, on log un event DOWN avec l’état réel
    echo "$NOW | $HOST | DOWN | systemctl is-active $UNIT = $STATUS"
fi
