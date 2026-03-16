#!/bin/bash
clear

# ----------------- CORES -----------------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
PURPLE='\033[1;35m'  # lilás para contornos
NC='\033[0m'

CONFIG="/etc/xray/config.json"
USERS="/etc/xray-manager/users.xray"
KEYFILE="/etc/xray-manager/reality.key"

# ----------------- FUNÇÃO DE STATUS -----------------
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

# ----------------- FUNÇÃO DE MENU PRINCIPAL -----------------
menu() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}              ${CYAN}XRAY MANAGER - MENU PRINCIPAL${NC}              ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠══════════════════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}1${NC}  • Adicionar Usuário                            ${PURPLE}║${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}2${NC}  • Gerenciar Usuários                            ${PURPLE}║${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}3${NC}  • Usuários Online                               ${PURPLE}║${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}4${NC}  • Limite de Conexões                             ${PURPLE}║${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}5${NC}  • Expiração de Usuários                          ${PURPLE}║${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}6${NC}  • Backup Configuração                             ${PURPLE}║${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}7${NC}  • Gerenciar Xray                                 ${PURPLE}║${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}8${NC}  • Atualizar Xray                                 ${PURPLE}║${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}9${NC}  • SlowDNS                                       ${PURPLE}║${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}10${NC} • Informações dos Serviços                        ${PURPLE}║${NC}"
    echo -e "${PURPLE}║ ${NC} ${YELLOW}0${NC}  • Sair                                          ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════╝${NC}"
    echo -ne "Escolha uma opção: "
}

# ----------------- FUNÇÃO GERENCIAR USUÁRIOS -----------------
gerenciar_usuarios() {
    while true; do
        clear
        echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║${NC}         ${CYAN}GERENCIAR USUÁRIOS${NC}              ${PURPLE}║${NC}"
        echo -e "${PURPLE}╠════════════════════════════════════════╣${NC}"
        echo -e "${PURPLE}║ 1) Adicionar usuário                     ║${NC}"
        echo -e "${PURPLE}║ 2) Remover usuário                        ║${NC}"
        echo -e "${PURPLE}║ 3) Ver tempo conectado                     ║${NC}"
        echo -e "${PURPLE}║ 0) Voltar                                 ║${NC}"
        echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
        read -p "Escolha uma opção: " gu
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
        echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║${NC}          ${CYAN}GERENCIAR XRAY${NC}                 ${PURPLE}║${NC}"
        echo -e "${PURPLE}╠════════════════════════════════════════╣${NC}"
        echo -e "${PURPLE}║ 1) Alterar porta xHTTP TLS              ║${NC}"
        echo -e "${PURPLE}║ 2) Alterar porta Reality                 ║${NC}"
        echo -e "${PURPLE}║ 3) Alterar SNI                           ║${NC}"
        echo -e "${PURPLE}║ 0) Voltar                                ║${NC}"
        echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"
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
            0) break ;;
            *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
        esac
    done
}

# ----------------- FUNÇÃO INFO SERVIÇOS -----------------
info_servicos() {
    clear
    echo -e "${PURPLE}╔════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}         ${CYAN}INFORMAÇÕES DOS SERVIÇOS${NC}         ${PURPLE}║${NC}"
    echo -e "${PURPLE}╠════════════════════════════════════════╣${NC}"
    for svc in xray ssh slowdns; do
        echo -e "${PURPLE}║ ${YELLOW}$svc${NC} - Status: $(status_service $svc) - Portas: $(port_service $svc) ${PURPLE}║${NC}"
    done
    echo -e "${PURPLE}╠════════════════════════════════════════╣${NC}"
    echo -e "${PURPLE}║ 1) Reiniciar Xray                          ║${NC}"
    echo -e "${PURPLE}║ 2) Reiniciar SSH                           ║${NC}"
    echo -e "${PURPLE}║ 3) Reiniciar SlowDNS                        ║${NC}"
    echo -e "${PURPLE}║ 0) Voltar                                  ║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════╝${NC}"

    read -p "Escolha: " sopt
    case $sopt in
        1) systemctl restart xray ; echo "Xray reiniciado!" ; read -p "ENTER" ;;
        2) systemctl restart ssh ; echo "SSH reiniciado!" ; read -p "ENTER" ;;
        3) pkill -f slowdns-server ; /usr/local/bin/slowdns-server & echo "SlowDNS reiniciado!" ; read -p "ENTER" ;;
        0) return ;;
        *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
    esac
}

# ----------------- LOOP PRINCIPAL -----------------
while true; do
    menu
    read option
    case $option in
        1) adduser ; read -p "ENTER" ;;
        2) gerenciar_usuarios ;;
        3) online ; read -p "ENTER" ;;
        4) limit ; read -p "ENTER" ;;
        5) expire ; read -p "ENTER" ;;
        6) backup ; read -p "ENTER" ;;
        7) gerenciar_xray ;;
        8) update-xray ; read -p "ENTER" ;;
        9) slowdns ; read -p "ENTER" ;;
        10) info_servicos ;;
        0) echo -e "${RED}Saindo...${NC}" ; exit 0 ;;
        *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
    esac
done

# ----------------- AUTO MENU AO LOGIN -----------------
PROFILE_FILE="$HOME/.bash_profile"
[ ! -f "$PROFILE_FILE" ] && PROFILE_FILE="$HOME/.profile"
grep -qxF "menu" $PROFILE_FILE || echo "menu" >> $PROFILE_FILE
