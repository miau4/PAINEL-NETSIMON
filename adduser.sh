#!/bin/bash

CONFIG="/etc/xray/config.json"
KEYFILE="/etc/xray-manager/reality.key"

read -p "Nome do usuario: " user

UUID=$(uuidgen)

IP=$(curl -s ifconfig.me)

PUBLIC=$(grep PUBLIC $KEYFILE | cut -d= -f2)

SNI="www.cloudflare.com"
SID="6ba85179e30d4fc2"

jq --arg id "$UUID" '.inbounds[0].settings.clients += [{"id":$id}]' $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG

echo "$user:$UUID" >> /etc/xray-manager/users.db

systemctl restart xray

echo ""
echo "Usuario criado"
echo ""

echo "LINK VLESS REALITY:"
echo ""

echo "vless://$UUID@$IP:443?encryption=none&security=reality&type=tcp&sni=$SNI&fp=chrome&pbk=$PUBLIC&sid=$SID&flow=xtls-rprx-vision#$user"
