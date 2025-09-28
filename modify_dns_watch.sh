sudo tee /opt/splunkforwarder/bin/dns_watch.sh >/dev/null <<'EOS'
#!/usr/bin/env bash
UNIT="${UNIT:-named.service}"
HOST=$(hostname -f 2>/dev/null || hostname)
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STATE_FILE="/var/tmp/${UNIT}.state"

state="$(systemctl is-active "$UNIT" 2>/dev/null || echo unknown)"

prev=""; [ -f "$STATE_FILE" ] && prev="$(cat "$STATE_FILE" 2>/dev/null || true)"

# N'émet que si l'état a changé (évite le bruit toutes les minutes)
if [ "$state" != "$prev" ]; then
  case "$state" in
    active)   echo "$NOW | $HOST | UP | systemctl is-active $UNIT = active" ;;
    failed|inactive|deactivating)
              echo "$NOW | $HOST | DOWN | systemctl is-active $UNIT = $state" ;;
    *)        echo "$NOW | $HOST | UNKNOWN | systemctl is-active $UNIT = $state" ;;
  esac
fi

echo -n "$state" > "$STATE_FILE"
EOS
sudo chmod +x /opt/splunkforwarder/bin/dns_watch.sh
