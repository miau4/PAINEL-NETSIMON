
```bash
#!/bin/bash

clear
echo "=== INSTALAÇÃO SLOWDNS ==="

read -p "IP do servidor: " SERVER
read -p "NS (ex: ns.seudominio.com): " NS

apt install wget unzip -y

mkdir -p /etc/slowdns
cd /etc/slowdns || exit

wget -O slowdns.zip https://github.com/xtaci/kcptun/releases/download/v20240101/client_linux_amd64.zip
unzip -o slowdns.zip
chmod +x client_linux_amd64

KEY=$(openssl rand -hex 8)

cat > /etc/systemd/system/slowdns.service <<EOF
[Unit]
Description=SlowDNS
After=network.target

[Service]
ExecStart=/etc/slowdns/client_linux_amd64 -server ${SERVER}:5300 -key ${KEY} -dns ${NS} -localaddr 127.0.0.1:1080
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable slowdns
systemctl start slowdns

echo "SLOWDNS_ATIVO=1" >> /etc/painel/data/services.conf

echo "Instalado!"
echo "KEY: $KEY"
```
