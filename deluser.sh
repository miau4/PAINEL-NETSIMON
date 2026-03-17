#!/bin/bash

USERS="/etc/xray-manager/users.xray"

read -p "Nome do usuário a remover: " user

if grep -q "^$user|" $USERS; then
    grep -v "^$user|" $USERS > /tmp/users.tmp
    mv /tmp/users.tmp $USERS
    echo "Usuário $user removido com sucesso."
else
    echo "Usuário não encontrado."
fi
read -n1 -r -p "Pressione qualquer tecla para voltar..."
