#!/bin/bash

BASE="/etc/painel"
CONFIG="/etc/xray/config.json"
USERDB="/etc/xray-manager/users.xray"

clear

# ===============================
# GARANTIA DE ESTRUTURA
# ===============================
mkdir -p "$BASE/services"
mkdir -p /etc/xray-manager

touch "$USERDB"
touch /etc/xray-manager/blocked.db

# ===============================
# CORES
# ===============================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# ===============================
# FUNÇÃO EXECUTAR SERVIÇO (ANTI BUG)
# ===============================
run_service() {
    FILE="$1"

    if [ ! -f "$FILE" ]; then
        echo -e "${RED}Arquivo não encontrado:${NC} $FILE"
        read -p "Enter..."
        return
    fi

    chmod +x "$FILE"

    clear
    echo -e "${CYAN}Executando:${NC} $FILE"
    echo ""

    bash "$FILE"

    echo ""
    read -p "Pressione ENTER para voltar ao menu..."
}

# ===============================
# LOOP
# ===============================
while true; do
clear

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}              🚀 NETSIMON ENTERPRISE PANEL 🚀                ${CYAN}║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════════╣${NC}"

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

1) run_service "$BASE/adduser.sh" ;;
2) run_service "$BASE/adduser.sh" ;;
3) run_service "$BASE/deluser.sh" ;;
4) cat "$USERDB"; read -p "Enter..." ;;
5) run_service "$BASE/online.sh" ;;
6) cat /etc/xray-manager/blocked.db; read -p "Enter..." ;;

7)
read -p "Usuário: " user
sed -i "/^$user|/d" /etc/xray-manager/blocked.db
;;

8) > /etc/xray-manager/blocked.db ;;
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

# 🔥 AGORA 100% FUNCIONAL
14) run_service "$BASE/services/websock.sh" ;;
15) run_service "$BASE/services/slowdns-server.sh" ;;
16) run_service "$BASE/services/xray.sh" ;;

17) watch -n 2 "bash $BASE/online.sh" ;;
18) tail -f /var/log/xray/access.log ;;
19) cp "$CONFIG" /etc/xray/config.backup.json ;;

0|00) exit ;;

*) echo "Opção inválida"; sleep 1 ;;

esac

done
