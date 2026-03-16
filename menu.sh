#!/bin/bash
clear

# ----------------- CORES -----------------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
LILAC='\033[1;35m'
NC='\033[0m'

CONFIG="/etc/xray/config.json"
USERS="/etc/xray-manager/users.xray"
KEYFILE="/etc/xray-manager/reality.key"

# ----------------- FUNÇÕES -----------------
status_service() {
    local svc=$1
    if systemctl is-active --quiet "$svc"; then
        echo -e "${GREEN}ATIVO${NC}"
    else
        echo -e "${RED}INATIVO${NC}"
    fi
}

port_service() {
    local svc=$1
    case $svc in
        xray)
            jq -r '.inbounds[].port' $CONFIG | tr '\n' ',' | sed 's/,$//'
            ;;
        ssh)
            echo "22"
            ;;
        slowdns)
            echo "5300"
            ;;
        *)
            echo "-"
            ;;
    esac
}

# ----------------- MENU PRINCIPAL -----------------
main_menu() {
    clear
    echo -e "${LILAC}╔══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}   █ P A I N E L  X R A Y - NETSIMON █   ${NC}"
    echo -e "${LILAC}╠══════════════════════════════════════╣${NC}"
    echo -e "${LILAC}1) Gerenciar Usuários${NC}"
    echo -e "${LILAC}2) Gerenciar Xray${NC}"
    echo -e "${LILAC}3) Info dos Serviços${NC}"
    echo -e "${LILAC}0) Sair${NC}"
    echo -e "${LILAC}╚══════════════════════════════════════╝${NC}"
    read -p "Escolha uma opção: " opt
    case $opt in
        1) users_menu ;;
        2) xray_menu ;;
        3) info_servicos ;;
        0) exit 0 ;;
        *) echo "Opção inválida"; sleep 1; main_menu ;;
    esac
}

# ----------------- GERENCIAR USUÁRIOS -----------------
users_menu() {
    while true; do
        clear
        echo -e "${LILAC}╔════════════════════════════════╗${NC}"
        echo -e "${CYAN} █ G E R E N C I A R  U S U Á R I O S █${NC}"
        echo -e "${LILAC}╠════════════════════════════════╣${NC}"
        echo -e "${LILAC}1) Adicionar usuário${NC}"
        echo -e "${LILAC}2) Remover usuário${NC}"
        echo -e "${LILAC}3) Ver tempo conectado${NC}"
        echo -e "${LILAC}0) Voltar${NC}"
        echo -e "${LILAC}╚════════════════════════════════╝${NC}"
        read -p "Escolha: " gu
        case $gu in
            1) adduser ;;
            2) deluser ;;
            3)
                if [ -f "$USERS" ]; then
                    echo -e "${CYAN}Tempo conectado por usuário:${NC}"
                    awk '{print $3}' /var/log/xray/access.log | sort | uniq -c
                else
                    echo "Nenhum usuário cadastrado."
                fi
                read -p "ENTER para voltar..."
                ;;
            0) break ;;
            *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
        esac
    done
}

# ----------------- GERENCIAR XRAY -----------------
xray_menu() {
    while true; do
        clear
        echo -e "${LILAC}╔════════════════════════════════╗${NC}"
        echo -e "${CYAN}   █ G E R E N C I A R  X R A Y █  ${NC}"
        echo -e "${LILAC}╠════════════════════════════════╣${NC}"
        echo -e "${LILAC}1) Alterar porta xHTTP TLS${NC}"
        echo -e "${LILAC}2) Alterar porta Reality${NC}"
        echo -e "${LILAC}3) Alterar SNI${NC}"
        echo -e "${LILAC}4) Reiniciar Xray${NC}"
        echo -e "${LILAC}0) Voltar${NC}"
        echo -e "${LILAC}╚════════════════════════════════╝${NC}"
        read -p "Escolha: " gx
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
            4)
                systemctl restart xray
                echo "Xray reiniciado!"
                read -p "ENTER para voltar..."
                ;;
            0) break ;;
            *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
        esac
    done
}

# ----------------- INFO SERVIÇOS -----------------
info_servicos() {
    clear
    echo -e "${LILAC}╔════════════════════════════════╗${NC}"
    echo -e "${CYAN} █ I N F O R M A Ç Õ E S  D O S  S E R V I Ç O S █${NC}"
    echo -e "${LILAC}╠════════════════════════════════╣${NC}"
    for svc in xray ssh slowdns; do
        echo -e "${LILAC}$svc - Status: $(status_service $svc) - Portas: $(port_service $svc)${NC}"
    done
    echo -e "${LILAC}╚════════════════════════════════╝${NC}"
    read -p "Pressione ENTER para voltar..."
}

# ----------------- AUTO MENU AO LOGIN -----------------
PROFILE_FILE="$HOME/.bash_profile"
[ ! -f "$PROFILE_FILE" ] && PROFILE_FILE="$HOME/.profile"
grep -qxF "main_menu" $PROFILE_FILE || echo "main_menu" >> $PROFILE_FILE

# ----------------- INICIAR MENU -----------------
main_menu
