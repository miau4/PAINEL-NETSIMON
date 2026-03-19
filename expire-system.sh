#!/bin/bash

USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

echo "=== EXPIRADOR AUTOMÁTICO ==="

[ ! -f "$USERS" ] && touch "$USERS"
[ ! -f "$CONFIG" ] && exit

while true; do

    NOW=$(date +%s)
    tmp_users=$(mktemp)
    changed=0

    while IFS="|" read -r user uuid exp pass limit; do

        [[ -z "$user" ]] && continue

        exp_ts=$(date -d "$exp" +%s 2>/dev/null)

        # se data inválida → mantém
        if [[ -z "$exp_ts" ]]; then
            echo "$user|$uuid|$exp|$pass|$limit" >> "$tmp_users"
            continue
        fi

        if [[ "$exp_ts" -lt "$NOW" ]]; then

            echo "⏰ Expirando usuário: $user"

            # remover do config.json com segurança
            if command -v jq >/dev/null 2>&1; then
                tmp_config=$(mktemp)

                jq --arg uuid "$uuid" '
                (.inbounds[].settings.clients) |= map(select(.id != $uuid))
                ' "$CONFIG" > "$tmp_config"

                if [ $? -eq 0 ] && [ -s "$tmp_config" ]; then
                    mv "$tmp_config" "$CONFIG"
                    changed=1
                else
                    rm -f "$tmp_config"
                fi
            fi

        else
            echo "$user|$uuid|$exp|$pass|$limit" >> "$tmp_users"
        fi

    done < "$USERS"

    mv "$tmp_users" "$USERS"

    # reinicia xray se mudou algo
    if [ "$changed" -eq 1 ]; then
        systemctl restart xray 2>/dev/null
    fi

    sleep 60

done
