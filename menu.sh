#!/bin/bash
clear

# ----------------- CORES -----------------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
NC='\033[0m'

CONFIG="/etc/xray/config.json"
USERS="/etc/xray-manager/users.xray"
KEYFILE="/etc/xray-manager/reality.key"

# ----------------- FUNÇÃO MENU -----------------
menu() {
    clear
    echo -e "${CYAN}============================================${NC}"
    echo -e "${GREEN}          XRAY MANAGER - MENU PRINCIPAL     ${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo -e "${YELLOW}| ${NC} ${BLUE}1${NC} • Adicionar Usuário           ${YELLOW}|${NC}"
    echo -e "${YELLOW}| ${NC} ${BLUE}2${NC} • Gerenciar Usuários           ${YELLOW}|${NC}"
    echo -e "${YELLOW}| ${NC} ${BLUE}3${NC} • Usuários Online             ${YELLOW}|${NC}"
    echo -e "${YELLOW}| ${NC} ${BLUE}4${NC} • Limite de Conexões          ${YELLOW}|${NC}"
    echo -e "${YELLOW}| ${NC} ${BLUE}5${NC} • Expiração de Usuários       ${YELLOW}|${NC}"
    echo -e "${YELLOW}| ${NC} ${BLUE}6${NC} • Backup Configuração          ${YELLOW}|${NC}"
    echo -e "${YELLOW}| ${NC} ${BLUE}7${NC} • Gerenciar Xray               ${YELLOW}|${NC}"
    echo -e "${YELLOW}| ${NC} ${BLUE}8${NC} • Atualizar Xray               ${YELLOW}|${NC}"
    echo -e "${YELLOW}| ${NC} ${BLUE}9${NC} • SlowDNS                      ${YELLOW}|${NC}"
    echo -e "${YELLOW}| ${NC} ${BLUE}0${NC} • Sair                         ${YELLOW}|${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo -ne "Escolha uma opção: "
}

# ----------------- FUNÇÃO GERENCIAR USUÁRIOS -----------------
gerenciar_usuarios() {
    while true; do
        clear
        echo -e "${GREEN}========= GERENCIAR USUÁRIOS =========${NC}"
        echo "1) Adicionar usuário"
        echo "2) Remover usuário"
        echo "3) Ver tempo conectado"
        echo "0) Voltar"
        read -p "Escolha uma opção: " gu
        case $gu in
            1) adduser ;;
            2) deluser ;;
            3)
                if [ -f "$USERS" ]; then
                    echo -e "${CYAN}Tempo conectado por usuário:${NC}"
                    # Usando log de acesso para calcular tempo
                    awk '{print $3}' /var/log/xray/access.log | sort | uniq -c
                else
                    echo "Nenhum usuário cadastrado."
                fi
                read -p "Pressione ENTER para voltar..."
                ;;
            0) break ;;
            *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
        esac
    done
}

# ----------------- FUNÇÃO GERENCIAR XRAY -----------------
gerenciar_xray() {
    while true; do
        clear
        echo -e "${GREEN}========= GERENCIAR XRAY =========${NC}"
        echo "1) Alterar porta xHTTP TLS"
        echo "2) Alterar porta Reality"
        echo "3) Alterar SNI"
        echo "0) Voltar"
        read -p "Escolha uma opção: " gx
        case $gx in
            1)
                read -p "Nova porta xHTTP TLS: " nova_porta
                jq ".inbounds[1].port=$nova_porta" $CONFIG > /tmp/config.json
                mv /tmp/config.json $CONFIG
                systemctl restart xray
                echo "Porta xHTTP alterada para $nova_porta"
                read -p "ENTER para voltar..."
                ;;
            2)
                read -p "Nova porta Reality: " nova_porta
                jq ".inbounds[2].port=$nova_porta" $CONFIG > /tmp/config.json
                mv /tmp/config.json $CONFIG
                systemctl restart xray
                echo "Porta Reality alterada para $nova_porta"
                read -p "ENTER para voltar..."
                ;;
            3)
                read -p "Novo SNI: " novo_sni
                jq ".inbounds[2].streamSettings.realitySettings.dest=\"$novo_sni\"" $CONFIG > /tmp/config.json
                jq ".inbounds[2].streamSettings.realitySettings.serverNames[0]=\"$novo_sni\"" /tmp/config.json > /tmp/config2.json
                mv /tmp/config2.json $CONFIG
                systemctl restart xray
                echo "SNI alterado para $novo_sni"
                read -p "ENTER para voltar..."
                ;;
            0) break ;;
            *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
        esac
    done
}

# ----------------- LOOP PRINCIPAL -----------------
while true; do
    menu
    read option
    case $option in
        1) adduser ; read -p "Pressione ENTER para voltar..." ;;
        2) gerenciar_usuarios ;;
        3) online ; read -p "Pressione ENTER para voltar..." ;;
        4) limit ; read -p "Pressione ENTER para voltar..." ;;
        5) expire ; read -p "Pressione ENTER para voltar..." ;;
        6) backup ; read -p "Pressione ENTER para voltar..." ;;
        7) gerenciar_xray ;;
        8) update-xray ; read -p "Pressione ENTER para voltar..." ;;
        9) slowdns ; read -p "Pressione ENTER para voltar..." ;;
        0) echo -e "${RED}Saindo...${NC}"; exit 0 ;;
        *) echo -e "${RED}Opção inválida!${NC}"; sleep 1 ;;
    esac
done

# ----------------- AUTO MENU AO LOGIN -----------------
PROFILE_FILE="$HOME/.bash_profile"
if [ ! -f "$PROFILE_FILE" ]; then
    PROFILE_FILE="$HOME/.profile"
fi

grep -qxF "menu" $PROFILE_FILE || echo "menu" >> $PROFILE_FILE
