#!/bin/bash

EXPDB="/etc/xray-manager/exp.db"
USERDB="/etc/xray-manager/users.db"
CONFIG="/etc/xray/config.json"

TODAY=$(date +%F)

while IFS=: read USER DATE
do

if [[ "$TODAY" > "$DATE" ]]; then

UUID=$(grep $USER $USERDB | cut -d: -f2)

jq --arg id "$UUID" '(.inbounds[0].settings.clients) |= map(select(.id != $id))' $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG

sed -i "/$USER/d" $USERDB
sed -i "/$USER/d" $EXPDB

echo "Usuario $USER expirado removido"

fi

done < $EXPDB

systemctl restart xray
