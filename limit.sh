#!/bin/bash

USERS="/etc/xray-manager/users.xray"
LOG="/var/log/xray/access.log"

while true; do
    [ ! -f "$USERS" ] && sleep 10 && continue
    [ ! -f "$LOG" ] && sleep 10 && continue

    while IFS="|" read -r user uuid exp pass limit; do

        # padrão se não tiver limite
        [[ -z "$limit" ]] && limit=1

        # pega IPs únicos desse usuário via email
        ips=$(grep "$user" $LOG | tail -n 200 | awk '{print $3}' | cut -d: -f1 | sort | uniq)

        total=$(echo "$ips" | grep -c .)

        if [ "$total" -gt "$limit" ]; then
            echo "[$(date)] $user excedeu limite ($total/$limit)"

            # derruba conexões do usuário
            xray api statsquery --reset --pattern "user>>>$user>>>*" 2>/dev/null
        fi

    done < "$USERS"

    sleep 20
done
