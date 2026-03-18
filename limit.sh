```bash
#!/bin/bash

USERS="/etc/xray-manager/users.xray"
LOG="/var/log/xray/access.log"
BLOCKED="/etc/xray-manager/blocked.db"

touch $BLOCKED

echo "=== LIMITER XRAY INICIADO ==="

while true; do

    NOW=$(date +%s)

    while IFS="|" read -r user uuid exp pass limit; do

        # padrão caso não tenha limite
        [[ -z "$limit" ]] && limit=1

        # ===============================
        # 🔥 PEGAR CONEXÕES ATIVAS VIA API
        # ===============================
        connections=$(xray api statsquery --pattern "user>>>$user>>>online" 2>/dev/null | grep -o '[0-9]*$')

        [[ -z "$connections" ]] && connections=0

        # ===============================
        # 🔥 PEGAR IPs RECENTES (últimos 60s)
        # ===============================
        ips=$(grep "$user" $LOG | tail -n 100 | while read line; do
            log_time=$(echo "$line" | awk '{print $1" "$2}')
            log_ts=$(date -d "$log_time" +%s 2>/dev/null)

            diff=$((NOW - log_ts))

            if [ "$diff" -le 60 ]; then
                echo "$line" | awk '{print $3}' | cut -d: -f1
            fi
        done | sort | uniq)

        total_ips=$(echo "$ips" | grep -c .)

        # ===============================
        # 🔥 VERIFICA LIMITE
        # ===============================
        if [ "$connections" -gt "$limit" ] || [ "$total_ips" -gt "$limit" ]; then

            echo "[$(date)] $user EXCEDEU LIMITE ($connections conexões / $total_ips IPs / limite=$limit)"

            # ===============================
            # 🔥 EVITAR BLOQUEIO DUPLICADO
            # ===============================
            if grep -q "^$user|" "$BLOCKED"; then
                continue
            fi

            # ===============================
            # 🔥 BLOQUEIO REAL (REMOVER DO XRAY)
            # ===============================
            jq --arg email "$user" '
            .inbounds[].settings.clients |= map(select(.email != $email))
            ' /etc/xray/config.json > /tmp/config.json && mv /tmp/config.json /etc/xray/config.json

            systemctl restart xray

            # ===============================
            # 🔥 REGISTRAR BLOQUEIO
            # ===============================
            echo "$user|$(date)" >> $BLOCKED

            echo "🔒 $user FOI BLOQUEADO POR COMPARTILHAMENTO"

        fi

    done < "$USERS"

    sleep 15

done
```
