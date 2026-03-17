#!/bin/bash
set -e

clear

echo "================================="
echo "     INSTALANDO PAINEL NETSIMON"
echo "================================="

apt update -y
apt install -y curl jq uuid-runtime ufw

echo "Instalando Xray..."

bash <(curl -Ls https://github.com/XTLS/Xray-install/raw/main/install-release.sh)

mkdir -p /etc/xray
mkdir -p /etc/xray-manager
mkdir -p /var/log/xray

echo "Gerando chave Reality..."

KEYS=$(xray x25519)

PRIVATE=$(echo "$KEYS" | grep Private | awk '{print $3}')
PUBLIC=$(echo "$KEYS" | grep Public | awk '{print $3}')

echo "PRIVATE=$PRIVATE" > /etc/xray-manager/reality.key
echo "PUBLIC=$PUBLIC" >> /etc/xray-manager/reality.key

echo "Criando config do Xray..."

cat > /etc/xray/config.json <<EOF
{
"log": {
"access": "/var/log/xray/access.log",
"error": "/var/log/xray/error.log",
"loglevel": "warning"
},

"api": {
"services": [
"HandlerService",
"LoggerService",
"StatsService"
],
"tag": "api"
},

"stats": {},

"policy": {
"levels": {
"0": {
"statsUserDownlink": true,
"statsUserUplink": true,
"statsUserOnline": true
}
}
},

"inbounds": [

{
"tag": "api",
"listen": "127.0.0.1",
"port": 10085,
"protocol": "dokodemo-door",
"settings": {
"address": "127.0.0.1"
}
},

{
"port": 443,
"protocol": "vless",
"settings": {
"clients": [],
"decryption": "none"
},
"streamSettings": {
"network": "xhttp",
"security": "tls",
"tlsSettings": {
"alpn": ["http/1.1"],
"certificates": [
{
"certificateFile": "/etc/xray/fullchain.pem",
"keyFile": "/etc/xray/privkey.pem"
}
]
},
"xhttpSettings": {
"path": "/",
"host": ""
}
}
},

{
"port": 8443,
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
},

{
"port": 80,
"protocol": "vless",
"settings": {
"clients": []
},
"streamSettings": {
"network": "ws",
"security": "none",
"wsSettings": {
"path": "/vless"
}
}
},

{
"port": 8080,
"protocol": "vmess",
"settings": {
"clients": []
},
"streamSettings": {
"network": "ws",
"security": "none",
"wsSettings": {
"path": "/vmess"
}
}
},

{
"port": 8880,
"protocol": "vless",
"settings": {
"clients": []
},
"streamSettings": {
"network": "tcp",
"security": "none"
}
}

],

"outbounds": [
{
"protocol": "freedom"
}
],

"routing": {
"rules": [
{
"type": "field",
"protocol": ["bittorrent"],
"outboundTag": "blocked"
}
]
}
}
EOF


echo "Baixando scripts do painel..."

curl -o /usr/local/bin/menu https://raw.githubusercontent.com/miau4/xray-manager-mult/main/menu.sh
curl -o /usr/local/bin/adduser https://raw.githubusercontent.com/miau4/xray-manager-mult/main/adduser.sh
curl -o /usr/local/bin/deluser https://raw.githubusercontent.com/miau4/xray-manager-mult/main/deluser.sh
curl -o /usr/local/bin/online https://raw.githubusercontent.com/miau4/xray-manager-mult/main/online.sh
curl -o /usr/local/bin/rebuild https://raw.githubusercontent.com/miau4/xray-manager-mult/main/rebuild.sh
curl -o /usr/local/bin/limit https://raw.githubusercontent.com/miau4/xray-manager-mult/main/limit.sh
curl -o /usr/local/bin/expire https://raw.githubusercontent.com/miau4/xray-manager-mult/main/expire.sh
curl -o /usr/local/bin/backup https://raw.githubusercontent.com/miau4/xray-manager-mult/main/backup.sh
curl -o /usr/local/bin/checkjson https://raw.githubusercontent.com/miau4/xray-manager-mult/main/checkjson.sh
curl -o /usr/local/bin/limit-monitor https://raw.githubusercontent.com/miau4/xray-manager-mult/main/limit-monitor.sh
curl -o /usr/local/bin/expire-check https://raw.githubusercontent.com/miau4/xray-manager-mult/main/expire-check.sh
curl -o /usr/local/bin/slowdns https://raw.githubusercontent.com/miau4/xray-manager-mult/main/slowdns.sh
curl -o /usr/local/bin/speedtest https://raw.githubusercontent.com/miau4/xray-manager-mult/main/speedtest.sh
curl -o /usr/local/bin/ssh-manager https://raw.githubusercontent.com/miau4/xray-manager-mult/main/ssh-manager.sh
curl -o /usr/local/bin/uninstall-xray https://raw.githubusercontent.com/miau4/xray-manager-mult/main/uninstall.sh

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
chmod +x /usr/local/bin/slowdns
chmod +x /usr/local/bin/speedtest
chmod +x /usr/local/bin/ssh-manager
chmod +x /usr/local/bin/uninstall-xray
chmod +x /etc/xray-manager/monitor.sh
chmod +x /etc/xray-manager/*.sh

echo "Configurando tarefas automáticas..."

(crontab -l 2>/dev/null; echo "0 3 * * * expire") | crontab -

echo "Abrindo portas..."

ufw allow 53
ufw allow 5300
ufw allow 80
ufw allow 443
ufw allow 8443
ufw allow 8080
ufw allow 8880

systemctl restart xray
systemctl enable xray

clear

echo "================================="
echo " INSTALAÇÃO CONCLUÍDA"
echo "================================="
echo ""
echo "Digite no terminal:"
echo ""
echo "menu"
echo ""
