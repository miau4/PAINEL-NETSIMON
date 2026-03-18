```bash
#!/bin/bash

clear
echo "=== INSTALAÇÃO SERVIDOR SLOWDNS ==="

read -p "Digite seu domínio (ex: seudominio.com): " DOMAIN
read -p "Subdomínio NS (ex: ns1): " SUB

NS="${SUB}.${DOMAIN}"

if [[ -z "$DOMAIN" || -z "$SUB" ]]; then
  echo "Dados inválidos!"
  exit
fi

echo "Instalando dependências..."
apt update -y
apt install git golang curl -y

echo "Baixando dnstt..."
cd /usr/local
git clone https://www.bamsoftware.com/git/dnstt.git
cd dnstt/dnstt-server || exit

echo "Compilando..."
go build

echo "Gerando chave..."
./dnstt-server -gen-key > /etc/slowdns.key

PRIVATE_KEY=$(grep PRIVATE /etc/slowdns.key | awk '{print $2}')
PUBLIC_KEY=$(grep PUBLIC /etc/slowdns.key | awk '{print $2}')

mkdir -p /etc/slowdns

echo "$PRIVATE_KEY" > /etc/slowdns/private.key
echo "$PUBLIC_KEY" > /etc/slowdns/public.key

echo "Criando serviço..."

cat > /etc/systemd/system/slowdns-server.service <<EOF
[Unit]
Description=SlowDNS Server
After=network.target

[Service]
ExecStart=/usr/local/dnstt/dnstt-server/dnstt-server \
-udp :53 \
-privkey-file /etc/slowdns/private.key \
-ns ${NS}

Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable slowdns-server
systemctl start slowdns-server

IP=$(curl -s ifconfig.me)

echo ""
echo "=== SERVIDOR SLOWDNS ATIVO ==="
echo "NS: $NS"
echo "IP: $IP"
echo "PUBLIC KEY (USAR NO CLIENTE):"
echo "$PUBLIC_KEY"

echo ""
echo "Configure no seu DNS:"
echo "$NS -> $IP"
```
