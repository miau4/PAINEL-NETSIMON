```bash
#!/bin/bash

source /etc/painel/core/utils.sh

function header(){
clear
echo -e "${CYAN}"
echo "============================================="
echo "        🚀NETSIMON MANAGER🚀"
echo "============================================="
echo -e "${NC}"
}

function menu_services(){
header
echo "[1] Instalar Xray"
echo "[2] Instalar SlowDNS"
echo "[3] Instalar V2Ray"
echo "[4] Instalar Websocket"
echo "[5] Domínio + SSL"
echo "[6] Ver Serviços Ativos"
echo "[0] Voltar"
read -p "Escolha: " op

case $op in
1) bash /etc/painel/services/xray.sh ;;
2) bash /etc/painel/services/slowdns.sh ;;
3) bash /etc/painel/services/v2ray.sh ;;
4) bash /etc/painel/services/Websocket.sh ;;
5) bash /etc/painel/core/domain.sh ;;
6) cat /etc/painel/data/services.conf ;;
0) main ;;
esac
}

function main(){
header

echo "[01] Gerenciar Usuários"
echo "[02] Serviços"
echo "[03] Sistema"
echo "[00] Sair"

read -p "Escolha: " op

case $op in
1) echo "Em construção" ;;
2) menu_services ;;
3) bash /etc/painel/core/system.sh ;;
0) exit ;;
esac
}

main
```
