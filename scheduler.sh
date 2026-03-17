#!/bin/bash

USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

# se não existir arquivo, sai
[ ! -f "$USERS" ] && exit

hora=$(date +%H)

alterou=0

while IFS="|" read -r user uuid exp pass limit start end; do

    # padrão caso não exista horário definido
    [ -z "$start" ] && start=0
    [ -z "$end" ] && end=23

    # verifica se está fora do horário permitido
    if [ "$hora" -lt "$start" ] || [ "$hora" -gt "$end" ]; then

        # verifica se usuário ainda está ativo no config
        if grep -q "$uuid" "$CONFIG"; then
            echo "[$(date)] Bloqueando $user (fora do horário $start-$end)"

            jq --arg uuid "$uuid" '
            (.inbounds[] | select(.protocol=="vless" or .protocol=="vmess") | .settings.clients) |= map(select(.id != $uuid))
            ' "$CONFIG" > /tmp/config.json && mv /tmp/config.json "$CONFIG"

            alterou=1
        fi

    else

        # dentro do horário → garantir que o usuário esteja ativo
        if ! grep -q "$uuid" "$CONFIG"; then
            echo "[$(date)] Reativando $user (dentro do horário)"

            jq --arg uuid "$uuid" --arg email "$user" '
            (.inbounds[] | select(.protocol=="vless" or .protocol=="vmess") | .settings.clients) += [{"id": $uuid, "email": $email}]
            ' "$CONFIG" > /tmp/config.json && mv /tmp/config.json "$CONFIG"

            alterou=1
        fi

    fi

done < "$USERS"

# só reinicia se houve alteração
if [ "$alterou" -eq 1 ]; then
    systemctl restart xray
fi
