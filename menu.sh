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
        ws)
            jq -r '.inbounds[] | select(.protocol=="vless" or .protocol=="vmess") | .port' $CONFIG | tr '\n' ',' | sed 's/,$//'
            ;;
        *)
            echo "-"
            ;;
    esac
}

# ----------------- MENU PRINCIPAL -----------------
main_menu() {
    while true; do
        clear
        echo -e "${LILAC}╔══════════════════════════════════════╗${NC}"
        echo -e "${CYAN}   █ P A I N E L  N E T S I M O N █   ${NC}"
        echo -e "${LILAC}╠══════════════════════════════════════╣${NC}"
        echo -e "${LILAC}1) Gerenciar Usuários${NC}"
        echo -e "${LILAC}2) CONEXOES${NC}"
        echo -e "${LILAC}3) Info dos Serviços${NC}"
        echo -e "${LILAC}0) Sair${NC}"
        echo -e "${LILAC}╚══════════════════════════════════════╝${NC}"
        read -p "Escolha uma opção: " opt
        case $opt in
            1) users_menu ;;
            2) conexoes_menu ;;
            3) info_servicos ;;
            0) exit 0 ;;
            *) echo "Opção inválida"; sleep 1 ;;
        esac
    done
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
        echo -e "${LILAC}3) Lista de usuários${NC}"
        echo -e "${LILAC}4) Usuários expirados${NC}"
        echo -e "${LILAC}5) Deletar todos os usuários${NC}"
        echo -e "${LILAC}0) Voltar${NC}"
        echo -e "${LILAC}╚════════════════════════════════╝${NC}"
        read -p "Escolha: " gu
        case $gu in
            1) adduser ;;
            2) deluser ;;
            3) listar_usuarios ;;
            4) usuarios_expirados ;;
            5) del_all_users ;;
            0) break ;;
            *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
        esac
    done
}

listar_usuarios() {
    clear
    echo -e "${CYAN}USUÁRIOS ATIVOS${NC}"
    echo "-------------------------"
    [ -f "$USERS" ] && cat $USERS || echo "Nenhum usuário cadastrado."
    read -n1 -r -p "Pressione qualquer tecla para voltar..."
}

usuarios_expirados() {
    clear
    echo -e "${CYAN}USUÁRIOS EXPIRADOS${NC}"
    echo "-------------------------"
    [ -f "$USERS" ] || { echo "Nenhum usuário cadastrado."; read -n1 -r -p "Pressione qualquer tecla para voltar..."; return; }
    date_now=$(date +%s)
    while IFS="|" read -r user uuid exp pass; do
        exp_ts=$(date -d "$exp" +%s 2>/dev/null || echo 0)
        if [ "$exp_ts" -lt "$date_now" ] && [ "$exp_ts" -ne 0 ]; then
            echo "$user expirado em $exp"
        fi
    done < $USERS
    read -n1 -r -p "Pressione qualquer tecla para voltar..."
}

del_all_users() {
    clear
    if [ -f "$USERS" ]; then
        > $USERS
        echo -e "${RED}Todos os usuários foram deletados!${NC}"
    else
        echo "Nenhum usuário cadastrado."
    fi
    sleep 2
}

# ----------------- CONEXOES -----------------
conexoes_menu() {
    while true; do
        clear
        echo -e "${LILAC}╔════════════════════════════════╗${NC}"
        echo -e "${CYAN}       █ C O N E X Õ E S █       ${NC}"
        echo -e "${LILAC}╠════════════════════════════════╣${NC}"
        echo -e "${LILAC}1) Reiniciar Xray${NC}"
        echo -e "${LILAC}2) Alterar porta XHTTP TLS${NC}"
        echo -e "${LILAC}3) Alterar porta Reality${NC}"
        echo -e "${LILAC}4) Alterar SNI Reality${NC}"
        echo -e "${LILAC}5) Gerenciar WebSocket${NC}"
        echo -e "${LILAC}6) Gerenciar SlowDNS${NC}"
        echo -e "${LILAC}0) Voltar${NC}"
        echo -e "${LILAC}╚════════════════════════════════╝${NC}"
        read -p "Escolha: " gx
        case $gx in
            1)
                systemctl restart xray >/dev/null 2>&1
                echo -e "${GREEN}Xray reiniciado com sucesso${NC}"
                sleep 2
                ;;
            2)
                read -p "Nova porta XHTTP TLS: " nova_porta
                jq ".inbounds[1].port=$nova_porta" $CONFIG > /tmp/config.json
                mv /tmp/config.json $CONFIG
                systemctl restart xray >/dev/null 2>&1
                echo -e "${GREEN}Porta XHTTP TLS alterada para $nova_porta${NC}"
                sleep 2
                ;;
            3)
                read -p "Nova porta Reality: " nova_porta
                jq ".inbounds[2].port=$nova_porta" $CONFIG > /tmp/config.json
                mv /tmp/config.json $CONFIG
                systemctl restart xray >/dev/null 2>&1
                echo -e "${GREEN}Porta Reality alterada para $nova_porta${NC}"
                sleep 2
                ;;
            4)
                read -p "Novo SNI Reality: " novo_sni
                jq ".inbounds[2].streamSettings.realitySettings.dest=\"$novo_sni\"" $CONFIG > /tmp/config.json
                jq ".inbounds[2].streamSettings.realitySettings.serverNames[0]=\"$novo_sni\"" /tmp/config.json > /tmp/config2.json
                mv /tmp/config2.json $CONFIG
                systemctl restart xray >/dev/null 2>&1
                echo -e "${GREEN}SNI alterado para $novo_sni${NC}"
                sleep 2
                ;;
            5) websocket_menu ;;
            6) slowdns_menu ;;
            0) break ;;
            *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
        esac
    done
}

# ----------------- WEBSOCKET MENU -----------------
websocket_menu() {
    while true; do
        clear
        echo -e "${LILAC}╔════════════════════════════════╗${NC}"
        echo -e "${CYAN}       █ W E B S O C K E T █      ${NC}"
        echo -e "${LILAC}╠════════════════════════════════╣${NC}"
        echo -e "${LILAC}1) Iniciar WebSocket${NC}"
        echo -e "${LILAC}2) Parar WebSocket${NC}"
        echo -e "${LILAC}3) Reiniciar WebSocket${NC}"
        echo -e "${LILAC}4) Alterar porta WebSocket${NC}"
        echo -e "${LILAC}0) Voltar${NC}"
        echo -e "${LILAC}╚════════════════════════════════╝${NC}"
        read -p "Escolha: " ws
        case $ws in
            1)
                systemctl start xray >/dev/null 2>&1
                echo -e "${GREEN}WebSocket iniciado${NC}"
                sleep 2
                ;;
            2)
                systemctl stop xray >/dev/null 2>&1
                echo -e "${RED}WebSocket parado${NC}"
                sleep 2
                ;;
            3)
                systemctl restart xray >/dev/null 2>&1
                echo -e "${GREEN}WebSocket reiniciado${NC}"
                sleep 2
                ;;
            4)
                read -p "Nova porta WebSocket: " nova_porta
                jq '.inbounds[] | select(.protocol=="vless" or .protocol=="vmess") | .port='"$nova_porta" $CONFIG > /tmp/config.json
                mv /tmp/config.json $CONFIG
                systemctl restart xray >/dev/null 2>&1
                echo -e "${GREEN}Porta WebSocket alterada para $nova_porta${NC}"
                sleep 2
                ;;
            0) break ;;
            *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
        esac
    done
}

# ----------------- SLOWDNS MENU -----------------
slowdns_menu() {
    if [ ! -f /usr/local/bin/slowdns ]; then
        echo "SlowDNS não encontrado. Instalando..."
        bash <(curl -sL https://raw.githubusercontent.com/miau4/xray-manager-mult-slowdns/main/install.sh)
    fi
    bash /usr/local/bin/slowdns
}

# ----------------- INFO SERVIÇOS -----------------
info_servicos() {
    clear
    echo -e "${LILAC}╔════════════════════════════════╗${NC}"
    echo -e "${CYAN} █ I N F O R M A Ç Õ E S  D O S  S E R V I Ç O S █${NC}"
    echo -e "${LILAC}╠════════════════════════════════╣${NC}"
    for svc in xray slowdns; do
        echo -e "${LILAC}$svc - Status: $(status_service $svc) - Portas: $(port_service $svc)${NC}"
    done
    read -n1 -r -p "Pressione qualquer tecla para voltar..."
}

# ----------------- AUTO MENU AO LOGIN -----------------
PROFILE_FILE="$HOME/.bash_profile"
[ ! -f "$PROFILE_FILE" ] && PROFILE_FILE="$HOME/.profile"
grep -qxF "main_menu" $PROFILE_FILE || echo "main_menu" >> $PROFILE_FILE

# ----------------- INICIAR MENU -----------------
main_menu
