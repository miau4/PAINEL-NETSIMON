#!/bin/bash
USERS="/etc/xray-manager/users.xray"
echo "Status de expiração dos usuários:"

while IFS=: read -r name pass uuid exp; do
    if [[ $(date -d "$exp" +%s) -lt $(date +%s) ]]; then
        status="Expirado"
    else
        status="Válido"
    fi
    echo "$name - $status - Expira em: $exp"
done < $USERS
