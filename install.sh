#!/bin/bash

clear
echo "=== INSTALANDO NETSIMON PANEL ==="

# ===============================
# DEPENDÊNCIAS
# ===============================
apt update -y
apt install curl wget unzip jq -y

# ===============================
# PASTAS
# ===============================
mkdir -p /etc/painel/{core,services,data}
mkdir -p /etc/xray-manager

# ===============================
# ARQUIVOS BASE
# ===============================
touch /etc/xray-manager/users.xray
touch /etc/xray-manager/blocked.db

# ===============================
# MENU LIMPO (SEM MARKDOWN)
# ===============================
cat > /etc/painel/menu.sh << 'EOF'
#!/bin/bash

USERS="/etc/xray-manager/users.xray"
BLOCKED="/etc/xray-manager/blocked.db"

GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
NC='\033[0m'

while true; do
clear
echo -e "${CYAN}==== NETSIMON PANEL ====${NC}"
echo ""
echo -e "${GREEN}1${NC} - Criar usuário teste"
echo -e "${GREEN}2${NC} - Listar usuários"
echo -e "${GREEN}3${NC} - Reiniciar Xray"
echo -e "${GREEN}0${NC} - Sair"
echo ""

read -p "Escolha: " op

case $op in

1)
USER="teste$(date +%s | tail -c 5)"
UUID=$(cat /proc/sys/kernel/random/uuid)
EXP=$(date -d "+1 hour" +"%Y-%m-%d %H:%M")

echo "$USER|$UUID|$EXP" >> $USERS

echo "Usuário criado:"
echo "$USER"
read -p "Enter..."
;;

2)
cat $USERS
read -p "Enter..."
;;

3)
systemctl restart xray
echo "Xray reiniciado"
sleep 2
;;

0) exit ;;

*) echo "Opção inválida"; sleep 1 ;;

esac

done
EOF

# ===============================
# PERMISSÕES
# ===============================
chmod +x /etc/painel/menu.sh

# ===============================
# COMANDO GLOBAL
# ===============================
ln -sf /etc/painel/menu.sh /usr/local/bin/menu
chmod +x /usr/local/bin/menu

# ===============================
# FINAL
# ===============================
clear
echo "==============================="
echo " INSTALAÇÃO CONCLUÍDA"
echo "==============================="
echo ""
echo "Digite: menu"
echo ""
