#!/bin/bash

USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

echo "=== REBUILD XRAY CONFIG ==="

[ ! -f "$USERS" ] && echo "Sem banco de usuários!" && exit

tmp=$(mktemp)

# recria apenas os clients
jq '
.inbounds[].settings.clients = []
' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"

while IFS="|" read -r user uuid exp pass limit; do

    [[ -z "$user" ]] && continue

    tmp=$(mktemp)

    jq --arg uuid "$uuid" --arg email "$user" '
    .inbounds[].settings.clients += [{
        "id": $uuid,
        "email": $email
    }]
    ' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"

done < "$USERS"

systemctl restart xray

echo "Rebuild concluído!"
