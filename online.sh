```bash
#!/bin/bash

USERS="/etc/xray-manager/users.xray"
LOG="/var/log/xray/access.log"

echo "=== ONLINE REAL (últimos 60s) ==="

NOW=$(date +%s)

while IFS='|' read -r user uuid exp pass limit; do

    online=0

    grep "$uuid" $LOG | tail -n 20 | while read line; do
        log_time=$(echo "$line" | awk '{print $1" "$2}')
        log_ts=$(date -d "$log_time" +%s 2>/dev/null)

        diff=$((NOW - log_ts))

        if [ "$diff" -le 60 ]; then
            online=1
        fi
    done

    if [ "$online" -eq 1 ]; then
        echo "$user - ONLINE"
    else
        echo "$user - OFFLINE"
    fi

done < "$USERS"
```
