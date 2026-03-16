#!/bin/bash

clear

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "     REMOVER XRAY MANAGER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Deseja realmente remover tudo? (s/n): " op

if [[ "$op" = "s" ]]; then

systemctl stop xray 2>/dev/null
systemctl stop badvpn 2>/dev/null

rm -rf /etc/xray
rm -rf /etc/xray-manager
rm -rf /var/log/xray

rm -f /usr/local/bin/menu
rm -f /usr/local/bin/adduser
rm -f /usr/local/bin/deluser
rm -f /usr/local/bin/online
rm -f /usr/local/bin/rebuild
rm -f /usr/local/bin/limit
rm -f /usr/local/bin/expire
rm -f /usr/local/bin/backup
rm -f /usr/local/bin/checkjson
rm -f /usr/local/bin/limit-monitor
rm -f /usr/local/bin/expire-check
rm -f /usr/local/bin/update-xray
rm -f /usr/local/bin/slowdns

echo ""
echo "Script removido completamente."

fi
