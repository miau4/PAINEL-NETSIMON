#!/bin/bash

IP=$(curl -s ifconfig.me)
CONFIG="/etc/xray/config.json"
USERDB="/etc/xray-manager/users.db"
LOG="/var/log/xray/access.log"

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
RAM=$(free -m | awk '/Mem:/ {print $3"MB / "$2"MB"}')
UPTIME=$(uptime -p)

TOTAL_USERS=$(cat $USERDB 2>/dev/null | wc -l)

ONLINE_USERS=$(grep accepted $LOG 2>/dev/null | wc -l)

echo -e "${CYAN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "      XRAY MANAGER MULT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"

echo -e "${GREEN}Status do Servidor${NC}"
echo "CPU: $CPU%"
echo "Memoria: $RAM"
echo "Uptime: $UPTIME"

echo ""

echo -e "${YELLOW}Usuarios${NC}"
echo "Total: $TOTAL_USERS"
echo "Online: $ONLINE_USERS"

echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "1 • Criar usuario"
echo "2 • Remover usuario"
echo "3 • Usuarios online"
echo "4 • Definir limite"
echo "5 • Definir expiração"
echo "6 • Backup"
echo "7 • Rebuild config"
echo "8 • Verificar JSON"
echo "9 • Atualizar script"
echo "0 • Sair"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Escolha: " op

case $op in

1)
adduser
;;

2)
deluser
;;

3)
online
;;

4)
limit
;;

5)
expire
;;

6)
backup
;;

7)
rebuild
;;

8)
checkjson
;;

9)
update-xray
;;

0)
exit
;;

esac
