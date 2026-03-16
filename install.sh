#!/bin/bash

echo "Instalando XRAY MANAGER..."

apt update -y
apt install curl jq uuid-runtime -y

mkdir -p /etc/xray
mkdir -p /etc/xray-manager
mkdir -p /var/log/xray

echo "Gerando chave Reality..."

KEYS=$(xray x25519)

PRIVATE=$(echo "$KEYS" | grep Private | awk '{print $3}')
PUBLIC=$(echo "$KEYS" | grep Public | awk '{print $3}')

mkdir -p /etc/xray-manager

echo "PRIVATE=$PRIVATE" > /etc/xray-manager/reality.key
echo "PUBLIC=$PUBLIC" >> /etc/xray-manager/reality.key

cat > /etc/xray/config.json <<EOF
{
"log": {
"access": "/var/log/xray/access.log",
"error": "/var/log/xray/error.log",
"loglevel": "warning"
},
"inbounds": [
{
"port": 443,
"protocol": "vless",
"settings": {
"clients": []
},
"streamSettings": {
"network": "tcp",
"security": "reality",
"realitySettings": {
"dest": "www.cloudflare.com:443",
"serverNames": [
"www.cloudflare.com"
],
"privateKey": "$PRIVATE",
"shortIds": [
"6ba85179e30d4fc2"
]
}
}
}
],
"outbounds": [
{
"protocol": "freedom"
}
]
}
EOF

curl -o /usr/local/bin/menu https://raw.githubusercontent.com/miau4/xray-manager-mult/main/menu.sh
curl -o /usr/local/bin/adduser https://raw.githubusercontent.com/miau4/xray-manager-mult/main/adduser.sh
curl -o /usr/local/bin/deluser https://raw.githubusercontent.com/miau4/xray-manager-mult/main/deluser.sh
curl -o /usr/local/bin/online https://raw.githubusercontent.com/miau4/xray-manager-mult/main/online.sh
curl -o /usr/local/bin/rebuild https://raw.githubusercontent.com/miau4/xray-manager-mult/main/rebuild.sh
curl -o /usr/local/bin/limit https://raw.githubusercontent.com/miau4/xray-manager-mult/main/limit.sh
curl -o /usr/local/bin/expire https://raw.githubusercontent.com/miau4/xray-manager-mult/main/expire.sh
curl -o /usr/local/bin/backup https://raw.githubusercontent.com/miau4/xray-manager-mult/main/backup.sh
curl -o /usr/local/bin/checkjson https://raw.githubusercontent.com/miau4/xray-manager-mult/main/checkjson.sh
curl -o /usr/local/bin/limit-monitor https://raw.githubusercontent.com/SEUUSUARIO/xray-manager-mult/main/limit-monitor.sh
curl -o /usr/local/bin/expire-check https://raw.githubusercontent.com/SEUUSUARIO/xray-manager-mult/main/expire-check.sh
curl -o /usr/local/bin/update-xray https://raw.githubusercontent.com/SEUUSUARIO/xray-manager-mult/main/update.sh

chmod +x /usr/local/bin/menu
chmod +x /usr/local/bin/adduser
chmod +x /usr/local/bin/deluser
chmod +x /usr/local/bin/online
chmod +x /usr/local/bin/rebuild
chmod +x /usr/local/bin/limit
chmod +x /usr/local/bin/expire
chmod +x /usr/local/bin/backup
chmod +x /usr/local/bin/checkjson
chmod +x /usr/local/bin/limit-monitor
chmod +x /usr/local/bin/expire-check
chmod +x /usr/local/bin/*
chmod +x /usr/local/bin/update-xray

systemctl restart xray

echo ""
echo "Instalado."
echo "Digite: menu"

(crontab -l 2>/dev/null; echo "0 3 * * * expire") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * limit-monitor") | crontab -
(crontab -l 2>/dev/null; echo "0 3 * * * expire-check") | crontab -
