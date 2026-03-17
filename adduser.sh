#!/bin/bash

USERS="/etc/xray-manager/users.xray"

read -p "Nome do usuário: " user
read -p "Senha do usuário: " pass
read -p "Dias de validade: " dias

uuid=$(uuidgen)
exp_date=$(date -d "+$dias days" +"%Y-%m-%d")

echo "$user|$uuid|$exp_date|$pass" >> $USERS

echo "======================================"
echo "Usuário criado com sucesso!"
echo "Usuário: $user"
echo "Senha: $pass"
echo "UUID: $uuid"
echo "Validade: $exp_date"
echo "======================================"
read -n1 -r -p "Pressione qualquer tecla para voltar..."
