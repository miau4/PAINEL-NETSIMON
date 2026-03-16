#!/bin/bash
# Menu Principal - Painel Xray + SSH + SlowDNS
CONFIG="/etc/xray/config.json"
USERS="/etc/xray-manager/users.xray"

# Cores
RESET="\e[0m"
LILAC="\e[35m"
CYAN="\e[36m"
GREEN="\e[32m"
YELLOW="\e[33m"

# Função para desenhar borda
border() { printf "${LILAC}==================================================${RESET}\n"; }

# Função menu principal
main_menu() {
    clear
    border
    echo -e "${CYAN}      █ P A I N E L  X R A Y - N E T S I M O N █${RESET}"
    border
    echo -e "${LILAC}1) Gerenciar Usuários${RESET}"
    echo -e "${LILAC}2) Gerenciar Serviços${RESET}"
    echo -e "${LILAC}0) Sair${RESET}"
    border
    read -p "Escolha uma opção: " opt
    case $opt in
        1) users_menu ;;
        2) services_menu ;;
        0) exit 0 ;;
        *) echo "Opção inválida"; sleep 1; main_menu ;;
    esac
}

# Submenu de usuários
users_menu() {
    clear
    border
    echo -e "${CYAN}      █ G E R E N C I A R  U S U Á R I O S █${RESET}"
    border
    echo -e "${LILAC}1) Criar usuário${RESET}"
    echo -e "${LILAC}2) Lista de usuários${RESET}"
    echo -e "${LILAC}3) Ver tempo conectado${RESET}"
    echo -e "${LILAC}4) Expiração de usuários${RESET}"
    echo -e "${LILAC}5) Deletar usuário${RESET}"
    echo -e "${LILAC}0) Voltar${RESET}"
    border
    read -p "Escolha uma opção: " uopt
    case $uopt in
        1) /usr/local/bin/adduser.sh; read -p "Pressione ENTER para voltar..."; users_menu ;;
        2) /usr/local/bin/listusers.sh; read -p "Pressione ENTER para voltar..."; users_menu ;;
        3) /usr/local/bin/online.sh; read -p "Pressione ENTER para voltar..."; users_menu ;;
        4) /usr/local/bin/expire-users.sh; read -p "Pressione ENTER para voltar..."; users_menu ;;
        5) /usr/local/bin/deluser.sh; read -p "Pressione ENTER para voltar..."; users_menu ;;
        0) main_menu ;;
        *) echo "Opção inválida"; sleep 1; users_menu ;;
    esac
}

# Submenu de serviços
services_menu() {
    clear
    border
    echo -e "${CYAN}      █ G E R E N C I A R  S E R V I Ç O S █${RESET}"
    border
    echo -e "${LILAC}1) Xray${RESET}"
    echo -e "${LILAC}2) SSH${RESET}"
    echo -e "${LILAC}3) SlowDNS${RESET}"
    echo -e "${LILAC}0) Voltar${RESET}"
    border
    read -p "Escolha uma opção: " sopt
    case $sopt in
        1) xray_menu ;;
        2) ssh_menu ;;
        3) /usr/local/bin/slowdns-manager.sh; read -p "Pressione ENTER para voltar..."; services_menu ;;
        0) main_menu ;;
        *) echo "Opção inválida"; sleep 1; services_menu ;;
    esac
}

# Submenu Xray
xray_menu() {
    clear
    border
    echo -e "${CYAN}      █ G E R E N C I A R  X R A Y █${RESET}"
    border
    echo -e "${LILAC}1) Status Xray${RESET}"
    echo -e "${LILAC}2) Reiniciar Xray${RESET}"
    echo -e "${LILAC}3) Trocar porta interna/externa${RESET}"
    echo -e "${LILAC}4) Editar SNI${RESET}"
    echo -e "${LILAC}0) Voltar${RESET}"
    border
    read -p "Escolha uma opção: " xopt
    case $xopt in
        1) systemctl status xray; read -p "Pressione ENTER para voltar..."; xray_menu ;;
        2) systemctl restart xray; echo "Xray reiniciado!"; read -p "Pressione ENTER para voltar..."; xray_menu ;;
        3) echo "Função trocar porta ainda não implementada"; read -p "Pressione ENTER para voltar..."; xray_menu ;;
        4) echo "Função editar SNI ainda não implementada"; read -p "Pressione ENTER para voltar..."; xray_menu ;;
        0) services_menu ;;
        *) echo "Opção inválida"; sleep 1; xray_menu ;;
    esac
}

# Submenu SSH
ssh_menu() {
    clear
    border
    echo -e "${CYAN}      █ G E R E N C I A R  S S H █${RESET}"
    border
    echo -e "${LILAC}1) Status SSH${RESET}"
    echo -e "${LILAC}2) Reiniciar SSH${RESET}"
    echo -e "${LILAC}0) Voltar${RESET}"
    border
    read -p "Escolha uma opção: " sopt
    case $sopt in
        1) systemctl status ssh; read -p "Pressione ENTER para voltar..."; ssh_menu ;;
        2) systemctl restart ssh; echo "SSH reiniciado!"; read -p "Pressione ENTER para voltar..."; ssh_menu ;;
        0) services_menu ;;
        *) echo "Opção inválida"; sleep 1; ssh_menu ;;
    esac
}

# Executar menu automaticamente ao login
if [[ $- == *i* ]]; then
    main_menu
fi
