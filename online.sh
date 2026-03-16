#!/bin/bash

LOG="/var/log/xray/access.log"
DB="/etc/xray-manager/users.db"

echo "Usuarios online:"
echo ""

while IFS=: read USER UUID
do

COUNT=$(grep $UUID $LOG | wc -l)

if [ "$COUNT" -gt 0 ]; then
echo "$USER - $COUNT conexao(oes)"
fi

done < $DB
