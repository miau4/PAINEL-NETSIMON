#!/bin/bash

CONFIG="/etc/xray/config.json"

echo "Reconstruindo config..."

cat > $CONFIG <<EOF
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
"privateKey": "$(grep PRIVATE /etc/xray-manager/reality.key | cut -d= -f2)",
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

systemctl restart xray

echo "Config reconstruido"
