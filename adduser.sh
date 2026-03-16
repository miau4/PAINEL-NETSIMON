#!/bin/bash

read -p "Nome: " user

UUID=$(uuidgen)

IP=$(curl -s ifconfig.me)

jq --arg id "$UUID" '.inbounds[0].settings.clients += [{"id":$id}]' /etc/xray/config.json > /tmp/config.json

mv /tmp/config.json /etc/xray/config.json

systemctl restart xray

echo ""
echo "Usuario criado"
echo ""

echo "vless://$UUID@$IP:443?security=reality&type=tcp&sni=www.cloudflare.com&flow=xtls-rprx-vision#$user"
