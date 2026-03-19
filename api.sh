```bash
#!/bin/bash

PORT=8081
TOKEN="CHANGE_ME_TOKEN"

USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

echo "🚀 API NETSIMON INICIADA NA PORTA $PORT"

while true; do

REQUEST=$(nc -l -p $PORT -q 1)

BODY=$(echo "$REQUEST" | sed -n '/^{/,$p')

ACTION=$(echo "$BODY" | grep -oP '"action":"\K[^"]+')
USER=$(echo "$BODY" | grep -oP '"user":"\K[^"]+')
PASS=$(echo "$BODY" | grep -oP '"pass":"\K[^"]+')
LIMIT=$(echo "$BODY" | grep -oP '"limit":\K[0-9]+')
TOKEN_REQ=$(echo "$BODY" | grep -oP '"token":"\K[^"]+')

# ===============================
# AUTH
# ===============================
if [ "$TOKEN_REQ" != "$TOKEN" ]; then
    echo -e "HTTP/1.1 403 Forbidden\n"
    echo '{"status":"error","msg":"invalid token"}'
    continue
fi

# ===============================
# ADD USER
# ===============================
if [ "$ACTION" == "add_user" ]; then

UUID=$(cat /proc/sys/kernel/random/uuid)
EXP=$(date -d "+1 day" +"%Y-%m-%d")

echo "$USER|$UUID|$EXP|$PASS|$LIMIT" >> $USERS

jq --arg uuid "$UUID" --arg email "$USER" '
.inbounds[].settings.clients += [{"id": $uuid, "email": $email}]
' $CONFIG > /tmp/config.json && mv /tmp/config.json $CONFIG

systemctl restart xray

echo -e "HTTP/1.1 200 OK\n"
echo "{\"status\":\"ok\"}"
continue
fi

# ===============================
# ONLINE
# ===============================
if [ "$ACTION" == "online" ]; then

ONLINE=$(xray api statsquery --pattern "user>>>" 2>/dev/null | grep online | wc -l

echo -e "HTTP/1.1 200 OK\n"
echo "{\"online\":$ONLINE}"
continue
fi

# ===============================
# LIST USERS
# ===============================
if [ "$ACTION" == "list_users" ]; then

DATA=$(cat $USERS | tr '\n' ';')

echo -e "HTTP/1.1 200 OK\n"
echo "{\"users\":\"$DATA\"}"
continue
fi

# ===============================
# DELETE USER
# ===============================
if [ "$ACTION" == "del_user" ]; then

sed -i "/^$USER|/d" $USERS

jq --arg email "$USER" '
.inbounds[].settings.clients |= map(select(.email != $email))
' $CONFIG > /tmp/config.json && mv /tmp/config.json $CONFIG

systemctl restart xray

echo -e "HTTP/1.1 200 OK\n"
echo "{\"status\":\"deleted\"}"
continue
fi

# ===============================
# DEFAULT
# ===============================
echo -e "HTTP/1.1 400 Bad Request\n"
echo '{"status":"invalid action"}'

done
```
