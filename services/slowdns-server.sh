#!/bin/bash

clear

while true; do
echo "======================================="
echo "         SLOWDNS MANAGER"
echo "======================================="
echo "1) Instalar SlowDNS"
echo "2) Status"
echo "3) Reiniciar"
echo "4) Remover"
echo "0) Voltar"
echo "======================================="
read -p "Escolha: " op

case $op in

1)
clear
echo "=== INSTALAÇÃO SERVIDOR SLOWDNS ==="

read -p "Domínio (ex: seudominio.com): " DOMAIN
read -p "Subdomínio NS (ex: ns1): " SUB

NS="${SUB}.${DOMAIN}"

if [[ -z "$DOMAIN" || -z "$SUB" ]]; then
  echo "Dados inválidos!"
  read -p "Enter..."
  continue
fi

apt update -y
apt install git golang curl -y

cd /usr/local || exit
rm -rf dnstt
git clone https://www.bamsoftware.com/git/dnstt.git
cd dnstt/dnstt-server || exit

go build

mkdir -p /etc/slowdns

./dnstt-server -gen-key > /etc/slowdns/key.txt

PRIVATE_KEY=$(grep PRIVATE /etc/slowdns/key.txt | awk '{print $2}')
PUBLIC_KEY=$(grep PUBLIC /etc/slowdns/key.txt | awk '{print $2}')

echo "$PRIVATE_KEY" > /etc/slowdns/private.key
echo "$PUBLIC_KEY" > /etc/slowdns/public.key

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
echo "=== SLOWDNS ATIVO ==="
echo "NS: $NS"
echo "IP: $IP"
echo "PUBLIC KEY:"
echo "$PUBLIC_KEY"

read -p "Enter..."
;;

2)
systemctl status slowdns-server --no-pager
read -p "Enter..."
;;

3)
systemctl restart slowdns-server
echo "Reiniciado!"
read -p "Enter..."
;;

4)
systemctl stop slowdns-server
systemctl disable slowdns-server
rm -f /etc/systemd/system/slowdns-server.service
rm -rf /etc/slowdns
echo "Removido!"
read -p "Enter..."
;;

0)
break
;;

*)
echo "Opção inválida!"
;;

esac
done
