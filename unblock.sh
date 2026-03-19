#!/bin/bash

USERS="/etc/xray-manager/users.xray"
BLOCKED="/etc/xray-manager/blocked.db"
CONFIG="/etc/xray/config.json"

echo "=== UNBLOCK XRAY (AUTO) ==="

[ ! -f "$BLOCKED" ] && touch "$BLOCKED"
[ ! -f "$USERS" ] && touch "$USERS"

# tempo de bloqueio (segundos)
TIME_BLOCK=300

while true; do

    NOW=$(date +%s)
    tmp=$(mktemp)

    while IFS="|" read -r user block_time; do

        [[ -z "$user" ]] && continue

        diff=$((NOW - block_time))

        if [ "$diff" -ge "$TIME_BLOCK" ]; then

            # buscar dados do usuário original
            linha=$(grep "^$user|" "$USERS")

            if [ -n "$linha" ]; then

                uuid=$(echo "$linha" | cut -d'|' -f2)

                # reinserir no Xray
                if [ -f "$CONFIG" ]; then

                    tmp_config=$(mktemp)

                    jq --arg uuid "$uuid" --arg email "$user" '
                    .inbounds[].settings.clients += [{
                        "id": $uuid,
                        "email": $email
                    }]
                    ' "$CONFIG" > "$tmp_config"

                    if [ $? -eq 0 ] && [ -s "$tmp_config" ]; then
                        mv "$tmp_config" "$CONFIG"
                        systemctl restart xray 2>/dev/null
                        echo "🔓 $user desbloqueado"
                    else
                        rm -f "$tmp_config"
                        echo "Erro ao restaurar $user"
                        echo "$user|$block_time" >> "$tmp"
                    fi

                fi

            fi

        else
            # ainda bloqueado → mantém
            echo "$user|$block_time" >> "$tmp"
        fi

    done < "$BLOCKED"

    mv "$tmp" "$BLOCKED"

    sleep 20

done
