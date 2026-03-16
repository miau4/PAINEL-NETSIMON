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

chmod +x /usr/local/bin/menu
chmod +x /usr/local/bin/adduser
chmod +x /usr/local/bin/deluser
chmod +x /usr/local/bin/online
chmod +x /usr/local/bin/rebuild

systemctl restart xray

echo ""
echo "Instalado."
echo "Digite: menu"
