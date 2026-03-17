#!/bin/bash
clear

# ----------------- CORES -----------------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
NC='\033[0m'

CONFIG="/etc/xray/config.json"
USERS="/etc/xray-manager/users.xray"

# ----------------- ANIMAÇÃO -----------------
loading() {
    echo -ne "${CYAN}Carregando"
    for i in {1..3}; do
        echo -ne "."
        sleep 0.3
    done
    echo -e "${NC}"
}

# ----------------- PORTA EM USO -----------------
check_port() {
    porta=$1
    if lsof -i:$porta >/dev/null 2>&1; then
        proc=$(lsof -i:$porta | awk 'NR==2 {print $1}')
        echo -e "${RED}Porta $porta já está em uso pelo processo: $proc${NC}"
        return 1
    fi
    return 0
}

# ----------------- MENU PRINCIPAL -----------------
main_menu() {
    while true; do
        clear
        echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}        ⚡ PAINEL NETSIMON ⚡               ${NC}"
        echo -e "${BLUE}╠════════════════════════════════════════════╣${NC}"
        echo -e "${GREEN} 1) Gerenciar Usuários${NC}"
        echo -e "${GREEN} 2) Conexões${NC}"
        echo -e "${GREEN} 3) Info Serviços${NC}"
        echo -e "${RED} 0) Sair${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
        read -p "Escolha: " opt

        case $opt in
            1) users_menu ;;
            2) conexoes_menu ;;
            3) info_servicos ;;
            0) exit ;;
            *) echo "Inválido"; sleep 1 ;;
        esac
    done
}

# ----------------- USUÁRIOS -----------------
users_menu() {
    while true; do
        clear
        echo -e "${BLUE}══════ USUÁRIOS ══════${NC}"
        echo "1) Adicionar"
        echo "2) Remover"
        echo "3) Listar"
        echo "0) Voltar"
        read -p "Escolha: " op

        case $op in
            1) echo "Função adicionar aqui"; sleep 2 ;;
            2) deluser ;;
            3) listar_usuarios ;;
            0) break ;;
        esac
    done
}

listar_usuarios() {
    clear
    echo "USUÁRIOS:"
    nl -w2 -s') ' $USERS 2>/dev/null || echo "Nenhum usuário."
    read -p "Enter para voltar"
}

deluser() {
    clear

    if [ ! -f "$USERS" ]; then
        echo "Nenhum usuário."
        sleep 2
        return
    fi

    echo -e "${CYAN}Selecione o usuário para remover:${NC}"
    nl -w2 -s') ' $USERS

    read -p "Número: " num

    total=$(wc -l < $USERS)

    if [[ ! "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "$total" ]; then
        echo -e "${RED}Opção inválida${NC}"
        sleep 2
        return
    fi

    user=$(sed -n "${num}p" $USERS | cut -d '|' -f1)

    sed -i "${num}d" $USERS

    echo -e "${GREEN}Usuário $user removido com sucesso!${NC}"
    sleep 2
}

# ----------------- CONEXÕES -----------------
conexoes_menu() {
    while true; do
        clear
        echo -e "${BLUE}══════ CONEXÕES ══════${NC}"
        echo "1) Reiniciar Xray"
        echo "5) WebSocket"
        echo "6) SlowDNS"
        echo "0) Voltar"

        read -p "Escolha: " op

        case $op in
            1)
                systemctl restart xray
                echo "Reiniciado!"
                sleep 2
                ;;
            5) websocket_menu ;;
            6) slowdns_menu ;;
            0) break ;;
        esac
    done
}

# ----------------- WEBSOCKET -----------------
websocket_menu() {
    while true; do
        clear
        echo -e "${BLUE}══════ WEBSOCKET ══════${NC}"
        echo "1) Iniciar"
        echo "2) Parar"
        echo "0) Voltar"

        read -p "Escolha: " op

        case $op in
            1)
                read -p "Digite a porta: " porta

                check_port $porta || { sleep 2; continue; }

                jq ".inbounds[] |= if (.protocol==\"vless\" or .protocol==\"vmess\") then .port=$porta else . end" $CONFIG > /tmp/config.json
                mv /tmp/config.json $CONFIG

                systemctl restart xray
                echo -e "${GREEN}Iniciado na porta $porta${NC}"
                sleep 2
                ;;
            2)
                systemctl stop xray
                echo "Parado"
                sleep 2
                ;;
            0) break ;;
        esac
    done
}

# ----------------- SLOWDNS -----------------
slowdns_menu() {
    clear
    if [ ! -f /usr/local/bin/slowdns ]; then
        echo "Instalando SlowDNS..."
        bash <(curl -sL https://raw.githubusercontent.com/miau4/xray-manager-mult-slowdns/main/install.sh)
    fi

    echo "Abrindo menu SlowDNS..."
    sleep 1
    bash /usr/local/bin/slowdns
}

# ----------------- INFO -----------------
info_servicos() {
    clear
    echo "Status:"
    systemctl status xray | grep Active
    read -p "Enter..."
}

# ----------------- AUTO START -----------------
PROFILE_FILE="$HOME/.bash_profile"
[ ! -f "$PROFILE_FILE" ] && PROFILE_FILE="$HOME/.profile"
grep -qxF "main_menu" $PROFILE_FILE || echo "main_menu" >> $PROFILE_FILE

main_menu
