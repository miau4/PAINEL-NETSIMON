#!/bin/bash

BASE="/etc/painel"
CONFIG="/etc/xray/config.json"
USERDB="/etc/xray-manager/users.xray"

clear

# ===============================
# GARANTIA DE ARQUIVOS
# ===============================
[ ! -d "$BASE" ] && mkdir -p "$BASE"
[ ! -d "/etc/xray-manager" ] && mkdir -p /etc/xray-manager

[ ! -f "$USERDB" ] && touch "$USERDB"
[ ! -f "/etc/xray-manager/blocked.db" ] && touch /etc/xray-manager/blocked.db

if [ ! -f "$CONFIG" ]; then
    echo "[ERRO] config.json não encontrado!"
    exit 1
fi

# ===============================
# CONFIG
# ===============================
USERS="/etc/xray-manager/users.xray"
BLOCKED="/etc/xray-manager/blocked.db"

# ===============================
# CORES
# ===============================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ===============================
# BARRA
# ===============================
bar() {
    percent=$1

    # proteção contra valor vazio ou inválido
    [[ -z "$percent" ]] && percent=0
    [[ "$percent" -gt 100 ]] && percent=100
    [[ "$percent" -lt 0 ]] && percent=0

    size=20
    filled=$((percent * size / 100))
    empty=$((size - filled))

    printf "["
    for ((i=0;i<filled;i++)); do printf "#"; done
    for ((i=0;i<empty;i++)); do printf "-"; done
    printf "] %d%%" "$percent"
}

# ===============================
# STATUS
# ===============================
get_total() { [[ -f "$USERS" ]] && wc -l < "$USERS" || echo 0; }
get_blocked() { [[ -f "$BLOCKED" ]] && wc -l < "$BLOCKED" || echo 0; }

get_online() {
    command -v xray >/dev/null 2>&1 || echo 0 && return
    xray api statsquery --pattern "user>>>" 2>/dev/null | grep online | wc -l
}

get_cpu() {
    top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print int($2)}' || echo 0
}

get_ram() {
    free 2>/dev/null | awk '/Mem:/ {printf("%d"), $3/$2 * 100}' || echo 0
}

get_disk() {
    df / 2>/dev/null | awk 'NR==2 {gsub("%",""); print $5}' || echo 0
}

get_ip() {
    hostname -I 2>/dev/null | awk '{print $1}'
}

status_xray() {
    systemctl is-active xray 2>/dev/null || echo "inactive"
}

status_limiter() {
    pgrep -f limit.sh > /dev/null && echo "ON" || echo "OFF"
}

status_unblock() {
    pgrep -f unblock.sh > /dev/null && echo "ON" || echo "OFF"
}

# ===============================
# LOOP
# ===============================
while true; do
clear

TOTAL=$(get_total)
ONLINE=$(get_online)
BLOCKED_COUNT=$(get_blocked)

CPU=$(get_cpu)
RAM=$(get_ram)
DISK=$(get_disk)

IP=$(get_ip)

XRAY=$(status_xray)
LIMITER=$(status_limiter)
UNBLOCK=$(status_unblock)

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}              🚀 NETSIMON ENTERPRISE PANEL 🚀                ${CYAN}║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"

printf "${CYAN}║${NC} ${GREEN}Users:${NC} %-5s ${GREEN}Online:${NC} %-5s ${RED}Blocked:${NC} %-5s ${CYAN}║\n" "$TOTAL" "$ONLINE" "$BLOCKED_COUNT"
printf "${CYAN}║${NC} ${GREEN}IP:${NC} %-15s ${GREEN}Xray:${NC} %-8s ${YELLOW}Limiter:${NC} %-3s ${YELLOW}Unblock:${NC} %-3s ${CYAN}║\n" "$IP" "$XRAY" "$LIMITER" "$UNBLOCK"

printf "${CYAN}║${NC} CPU  "; bar "$CPU"; printf "   ${CYAN}║\n"
printf "${CYAN}║${NC} RAM  "; bar "$RAM"; printf "   ${CYAN}║\n"
printf "${CYAN}║${NC} DISK "; bar "$DISK"; printf "   ${CYAN}║\n"

echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"

# ===============================
# MENU (21 OPÇÕES)
# ===============================

printf "${CYAN}║${WHITE} 01) Criar Usuário        ${CYAN}│${WHITE} 11) Ativar Limiter        ${CYAN}║\n"
printf "${CYAN}║${WHITE} 02) Criar Usuário TESTE  ${CYAN}│${WHITE} 12) Parar Limiter         ${CYAN}║\n"
printf "${CYAN}║${WHITE} 03) Remover Usuário      ${CYAN}│${WHITE} 13) Status Limiter        ${CYAN}║\n"
printf "${CYAN}║${WHITE} 04) Listar Usuários      ${CYAN}│${WHITE} 14) WebSocket Manager     ${CYAN}║\n"
printf "${CYAN}║${WHITE} 05) Usuários Online      ${CYAN}│${WHITE} 15) SlowDNS Manager       ${CYAN}║\n"
printf "${CYAN}║${WHITE} 06) Ver Bloqueados       ${CYAN}│${WHITE} 16) Xray Manager          ${CYAN}║\n"
printf "${CYAN}║${WHITE} 07) Desbloquear Usuário  ${CYAN}│${WHITE} 17) Monitor Tempo Real    ${CYAN}║\n"
printf "${CYAN}║${WHITE} 08) Limpar Bloqueios     ${CYAN}│${WHITE} 18) Ver Logs              ${CYAN}║\n"
printf "${CYAN}║${WHITE} 09) Reiniciar Xray       ${CYAN}│${WHITE} 19) Backup Config         ${CYAN}║\n"
printf "${CYAN}║${WHITE} 10) Reparar Sistema      ${CYAN}│${WHITE} 00) Sair                  ${CYAN}║\n"

echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"

echo ""
read -p "Escolha: " op

case $op in

1) bash "$BASE/adduser.sh" ;;

2)

echo "Tempo padrão:"
echo "1) 1 hora"
echo "2) 2 horas"
echo "3) 3 horas"
echo "4) Personalizado"

read -p "Escolha: " t

case $t in
1) H=1 ;;
2) H=2 ;;
3) H=3 ;;
4) read -p "Digite horas: " H ;;
*) H=1 ;;
esac

USER="teste$(date +%s | tail -c 5)"
PASS="123"

UUID=$(cat /proc/sys/kernel/random/uuid)
EXP=$(date -d "+$H hour" +"%Y-%m-%d %H:%M")

echo "$USER|$UUID|$EXP|$PASS|1" >> "$USERS"

jq --arg uuid "$UUID" --arg email "$USER" '
.inbounds[].settings.clients += [{"id": $uuid, "email": $email}]
' "$CONFIG" > /tmp/config.json && mv /tmp/config.json "$CONFIG"

systemctl restart xray

echo "Usuário TESTE criado!"
echo "User: $USER"
echo "Senha: $PASS"
echo "Expira: $EXP"
read -p "Enter..."

;;

3) bash "$BASE/deluser.sh" ;;
4) cat "$USERS"; read -p "Enter..." ;;
5) bash "$BASE/online.sh"; read -p "Enter..." ;;
6) cat "$BLOCKED"; read -p "Enter..." ;;

7)
read -p "Usuário: " user
sed -i "/^$user|/d" "$BLOCKED"
;;

8) > "$BLOCKED" ;;
9) systemctl restart xray ;;
10) bash /etc/xray-manager/repair.sh ;;

11)
nohup bash /etc/xray-manager/limit.sh >/dev/null 2>&1 &
nohup bash /etc/xray-manager/unblock.sh >/dev/null 2>&1 &
;;

12)
pkill -f limit.sh
pkill -f unblock.sh
;;

13)
ps aux | grep -E "limit.sh|unblock.sh"
read -p "Enter..."
;;

14) echo "WebSocket em breve"; sleep 2 ;;
15) echo "SlowDNS em breve"; sleep 2 ;;
16) echo "Xray manager em breve"; sleep 2 ;;

17) watch -n 2 "bash $BASE/online.sh" ;;
18) tail -f /var/log/xray/access.log ;;
19)
cp "$CONFIG" /etc/xray/config.backup.json
;;

0|00) exit ;;

*) echo "Opção inválida"; sleep 1 ;;

esac

done
