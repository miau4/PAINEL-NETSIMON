#!/bin/bash
clear

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

SLOWDNS_BIN="/usr/local/bin/slowdns-server"
SLOWDNS_STATUS=$(pgrep -f slowdns-server)

menu_slowdns() {
    clear
    echo -e "${CYAN}================ SLOWDNS =================${NC}"
    if [ -n "$SLOWDNS_STATUS" ]; then
        echo -e "${GREEN}Status: ATIVO${NC}"
        echo "PID: $SLOWDNS_STATUS"
    else
        echo -e "${RED}Status: INATIVO${NC}"
    fi
    echo ""
    echo "1 • Instalar SlowDNS"
    echo "2 • Desinstalar SlowDNS"
    echo "3 • Ver informações"
    echo "0 • Voltar"
    echo -ne "Escolha: "
}

while true; do
    menu_slowdns
    read opc
    case $opc in
        1)
            if [ -f "$SLOWDNS_BIN" ]; then
                echo -e "${YELLOW}SlowDNS já instalado.${NC}"
            else
                echo -e "${GREEN}Instalando SlowDNS...${NC}"
                # Baixar binário confiável
                curl -Lo /usr/local/bin/slowdns-server https://raw.githubusercontent.com/angristan/slowdns/master/server/slowdns-server
                chmod +x /usr/local/bin/slowdns-server
                echo -e "${GREEN}Instalação concluída!${NC}"
            fi
            ;;
        2)
            if [ -f "$SLOWDNS_BIN" ]; then
                echo -e "${YELLOW}Desinstalando SlowDNS...${NC}"
                pkill -f slowdns-server
                rm -f "$SLOWDNS_BIN"
                echo -e "${GREEN}Desinstalação concluída!${NC}"
            else
                echo -e "${RED}SlowDNS não está instalado.${NC}"
            fi
            ;;
        3)
            if [ -f "$SLOWDNS_BIN" ]; then
                echo -e "${GREEN}Informações do SlowDNS:${NC}"
                echo "Local do binário: $SLOWDNS_BIN"
                echo "PID ativo: $(pgrep -f slowdns-server)"
                echo "Porta padrão: 5300"
            else
                echo -e "${RED}SlowDNS não está instalado.${NC}"
            fi
            ;;
        0) break ;;
        *) echo -e "${RED}Opção inválida!${NC}" ; sleep 1 ;;
    esac
done
