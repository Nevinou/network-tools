#!/bin/bash
set -euo pipefail

# Usage: sudo ./install_dovecot.sh user1 user2 ...
# Si aucun utilisateur n'est passé, la partie Maildir est ignorée.

# --- Variables ---
CERT_DAYS=365
CERT_KEY="/etc/ssl/private/dovecot.pem"
CERT_CRT="/etc/ssl/certs/dovecot.pem"
LOCAL_CONF="/etc/dovecot/local.conf"

# --- Root check ---
if [[ $EUID -ne 0 ]]; then
  echo "Veuillez exécuter ce script en root (sudo)." >&2
  exit 1
fi

echo "[1/7] Mise à jour des paquets"
apt update -y

echo "[2/7] Installation de Dovecot (IMAP/POP3) et OpenSSL"
apt install -y dovecot-imapd dovecot-pop3d openssl

# --- Préparation Maildir pour chaque utilisateur argument ---
if [[ $# -gt 0 ]]; then
  echo "[3/7] Création des Maildir pour: $*"
  for u in "$@"; do
    H=$(getent passwd "$u" | cut -d: -f6 || true)
    if [[ -z "${H:-}" ]]; then
      echo "  - Utilisateur introuvable: $u (ignoré)"
      continue
    fi
    install -d -m 700 -o "$u" -g "$u" "$H/Maildir"/{cur,new,tmp}
    echo "  - Maildir créé/ok: $u -> $H/Maildir"
  done
else
  echo "[3/7] Aucun utilisateur fourni, étape Maildir ignorée"
fi

# --- Certificat auto-signé (si absent) ---
echo "[4/7] Génération du certificat auto-signé (si absent)"
if [[ ! -f "$CERT_KEY" || ! -f "$CERT_CRT" ]]; then
  openssl req -x509 -nodes -days "$CERT_DAYS" -newkey rsa:2048 \
    -keyout "$CERT_KEY" -out "$CERT_CRT" \
    -subj "/C=FR/ST=NA/L=NA/O=LocalMail/OU=IT/CN=$(hostname -f)/emailAddress=postmaster@$(hostname -d || echo localdomain)"
  chmod 600 "$CERT_KEY"
  chown root:root "$CERT_KEY"
  echo "  - Certificat créé: $CERT_CRT"
else
  echo "  - Certificat déjà présent: $CERT_CRT"
fi

# --- Configuration Dovecot (local.conf) ---
echo "[5/7] Configuration de Dovecot"
# Sauvegarde légère si un ancien local.conf existe
if [[ -f "$LOCAL_CONF" && ! -f "${LOCAL_CONF}.bak" ]]; then
  cp -a "$LOCAL_CONF" "${LOCAL_CONF}.bak"
fi

cat > "$LOCAL_CONF" <<'EOF'
# ---- Dovecot local overrides ----
# Protocoles activés
protocols = imap pop3

# Emplacement boîtes
mail_location = maildir:~/Maildir

# Authentification
disable_plaintext_auth = yes
auth_mechanisms = plain login

# TLS/SSL
ssl = required
ssl_cert = </etc/ssl/certs/dovecot.pem
ssl_key  = </etc/ssl/private/dovecot.pem
EOF

# --- Pare-feu (ouvre IMAPS/POP3S si UFW présent) ---
echo "[6/7] Configuration du pare-feu (si UFW est installé)"
if command -v ufw >/dev/null 2>&1; then
  ufw allow 993/tcp || true
  ufw allow 995/tcp || true
  # Décommentez ci-dessous en labo si besoin des ports non chiffrés
  # ufw allow 143/tcp || true
  # ufw allow 110/tcp || true
else
  echo "  - UFW non installé, étape pare-feu ignorée"
fi

# --- Démarrage & vérifications ---
echo "[7/7] (Re)Démarrage de Dovecot et vérifications"
systemctl enable dovecot >/dev/null
systemctl restart dovecot
systemctl --no-pager --full status dovecot || true

echo "Ports à l'écoute :"
ss -tlnp | grep -E ':110|:143|:993|:995' || true

echo
echo "Test rapide TLS IMAP (bannière) :"
echo "A1 LOGOUT" | openssl s_client -connect localhost:993 -quiet || true

echo
echo "Configuration effective (extrait) :"
doveconf -n

cat <<'EONOTE'

Notes:
- En production, exposez uniquement 993 (IMAPS) et 995 (POP3S).
- Pour SMTP (envoi de mails), installez et configurez Postfix en complément.
- Certificat Let's Encrypt (conseillé en prod):
    apt install -y certbot
    certbot certonly --standalone -d mail.exemple.com
  Puis dans /etc/dovecot/local.conf :
    ssl_cert = </etc/letsencrypt/live/mail.exemple.com/fullchain.pem
    ssl_key  = </etc/letsencrypt/live/mail.exemple.com/privkey.pem
  Et redémarrez Dovecot.

Terminé.
EONOTE
