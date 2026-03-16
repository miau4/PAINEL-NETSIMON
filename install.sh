#!/bin/bash
set -e

echo "Instalando XRAY MANAGER..."

apt update -y
apt install -y curl jq uuid-runtime badvpn ufw

mkdir -p /etc/xray
mkdir -p /etc/xray-manager
mkdir -p /var/log/xray

echo "Gerando chave Reality..."

KEYS=$(xray x25519)

PRIVATE=$(echo "$KEYS" | grep Private | awk '{print $3}')
PUBLIC=$(echo "$KEYS" | grep Public | awk '{print $3}')

echo "PRIVATE=$PRIVATE" > /etc/xray-manager/reality.key
echo "PUBLIC=$PUBLIC" >> /etc/xray-manager/reality.key

echo "Configurando BadVPN..."

cat > /etc/systemd/system/badvpn.service <<EOF
[Unit]
Description=BadVPN UDPGW Service
After=network.target

[Service]
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 0.0.0.0:7300
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable badvpn
systemctl start badvpn

echo "Criando config do Xray..."

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
]
}
EOF

echo "Baixando scripts..."

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
curl -o /usr/local/bin/update-xray https://raw.githubusercontent.com/miau4/xray-manager-mult/main/update.sh
curl -o /usr/local/bin/slowdns https://raw.githubusercontent.com/miau4/xray-manager-mult/main/slowdns.sh
curl -o /usr/local/bin/speedtest https://raw.githubusercontent.com/miau4/xray-manager-mult/main/speedtest.sh
curl -o /usr/local/bin/ssh-manager https://raw.githubusercontent.com/miau4/xray-manager-mult/main/ssh-manager.sh
curl -o /usr/local/bin/uninstall-xray https://raw.githubusercontent.com/miau4/xray-manager-mult/main/uninstall.sh

chmod +x /usr/local/bin/*

echo "Configurando tarefas automáticas..."

(crontab -l 2>/dev/null; echo "0 3 * * * expire") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * limit-monitor") | crontab -
(crontab -l 2>/dev/null; echo "0 3 * * * expire-check") | crontab -

echo "Abrindo portas..."

ufw allow 53
ufw allow 5300
ufw allow 7300
ufw allow 80
ufw allow 443
ufw allow 8080
ufw allow 8880

systemctl restart xray

echo ""
echo "INSTALAÇÃO CONCLUÍDA"
echo "Digite: menu"
