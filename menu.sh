```bash
#!/bin/bash

# ================= CORES =================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
NC='\033[0m'

# ================= FUNÇÕES =================

function pause(){
  read -p "Pressione ENTER para continuar..."
}

function header(){
  clear
  echo -e "${CYAN}"
  echo "============================================="
  echo "        XRAY MANAGER MULT - MENU"
  echo "============================================="
  echo -e "${NC}"
}

# ================= USUÁRIOS =================

function menu_users(){
  header
  echo -e "${GREEN}GERENCIAR USUÁRIOS${NC}"
  echo "1) Criar usuário"
  echo "2) Remover usuário"
  echo "3) Listar usuários"
  echo "4) Alterar validade"
  echo "0) Voltar"
  read -p "Escolha: " opt

  case $opt in
    1) bash /etc/xray-manager/adduser.sh ;;
    2) bash /etc/xray-manager/deluser.sh ;;
    3) cat /etc/xray-manager/users.xray ;;
    4) bash /etc/xray-manager/renew.sh ;;
    0) main_menu ;;
  esac
  pause
}

# ================= CONEXÕES =================

function menu_connections(){
  header
  echo -e "${GREEN}CONEXÕES${NC}"
  echo "1) Reiniciar Xray"
  echo "2) Status Xray"
  echo "0) Voltar"
  read -p "Escolha: " opt

  case $opt in
    1) systemctl restart xray ;;
    2) systemctl status xray ;;
    0) main_menu ;;
  esac
  pause
}

# ================= SLOWDNS =================

function install_slowdns(){

  header
  echo -e "${YELLOW}INSTALAÇÃO SLOWDNS${NC}"

  echo "Instalando dependências..."
  apt update -y
  apt install wget curl unzip -y

  echo "Baixando SlowDNS..."
  mkdir -p /etc/slowdns
  cd /etc/slowdns || exit

  wget -O slowdns.zip https://github.com/xtaci/kcptun/releases/download/v20240101/client_linux_amd64.zip

  if [ $? -ne 0 ]; then
    echo -e "${RED}Erro ao baixar SlowDNS${NC}"
    pause
    return
  fi

  unzip slowdns.zip
  chmod +x client_linux_amd64

  echo ""
  read -p "Digite seu NS (ex: ns.seudominio.com): " NS

  if [[ -z "$NS" ]]; then
    echo -e "${RED}NS inválido!${NC}"
    pause
    return
  fi

  echo "Gerando chave..."
  KEY=$(openssl rand -hex 8)

  cat > /etc/slowdns/config.json <<EOF
{
  "ns": "$NS",
  "key": "$KEY"
}
EOF

  echo -e "${GREEN}SlowDNS instalado com sucesso!${NC}"
  echo "NS: $NS"
  echo "KEY: $KEY"

  pause
}

function menu_slowdns(){
  header
  echo -e "${GREEN}SLOWDNS${NC}"
  echo "1) Instalar SlowDNS"
  echo "2) Ver Configuração"
  echo "0) Voltar"
  read -p "Escolha: " opt

  case $opt in
    1) install_slowdns ;;
    2) cat /etc/slowdns/config.json ;;
    0) main_menu ;;
  esac
}

# ================= SISTEMA =================

function menu_system(){
  header
  echo -e "${GREEN}SISTEMA${NC}"
  echo "1) Reiniciar VPS"
  echo "2) Ver uso de RAM"
  echo "3) Ver uso de CPU"
  echo "0) Voltar"
  read -p "Escolha: " opt

  case $opt in
    1) reboot ;;
    2) free -h ;;
    3) top ;;
    0) main_menu ;;
  esac
  pause
}

# ================= MENU PRINCIPAL =================

function main_menu(){
  header
  echo -e "${BLUE}1) Gerenciar Usuários${NC}"
  echo -e "${BLUE}2) Conexões${NC}"
  echo -e "${BLUE}3) Ferramentas${NC}"
  echo -e "${BLUE}4) SlowDNS${NC}"
  echo -e "${BLUE}5) Sistema${NC}"
  echo -e "${RED}0) Sair${NC}"

  read -p "Escolha: " opt

  case $opt in
    1) menu_users ;;
    2) menu_connections ;;
    3) bash /etc/xray-manager/menu_tools.sh ;;
    4) menu_slowdns ;;
    5) menu_system ;;
    0) exit ;;
    *) main_menu ;;
  esac
}

main_menu
```
