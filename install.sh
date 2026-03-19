#!/bin/bash

clear
echo "=== INSTALANDO NETSIMON PANEL (MODULAR) ==="

# ===============================
# VERIFICA ROOT
# ===============================
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root!"
  exit 1
fi

# ===============================
# CORRIGE POSSÍVEL CRLF
# ===============================
sed -i 's/\r$//' "$0" 2>/dev/null

# ===============================
# DEPENDÊNCIAS (SEM WARNING)
# ===============================
echo "[+] Instalando dependências..."
apt-get update -y >/dev/null 2>&1
apt-get install -y curl wget unzip jq >/dev/null 2>&1

# ===============================
# ESTRUTURA
# ===============================
echo "[+] Criando estrutura..."
mkdir -p /etc/painel/{core,services,data}
mkdir -p /etc/xray-manager

# ===============================
# BASE DE DADOS
# ===============================
touch /etc/xray-manager/users.xray
touch /etc/xray-manager/blocked.db

# ===============================
# VALIDAR MENU EXISTENTE
# ===============================
MENU_PATH="/etc/painel/menu.sh"

if [ ! -f "$MENU_PATH" ]; then
  echo ""
  echo "[ERRO] menu.sh NÃO encontrado em $MENU_PATH"
  echo "Envie o menu antes de rodar o install"
  exit 1
fi

# ===============================
# PERMISSÕES
# ===============================
echo "[+] Ajustando permissões..."
chmod +x $MENU_PATH

# ===============================
# COMANDO GLOBAL
# ===============================
echo "[+] Criando comando global..."
ln -sf $MENU_PATH /usr/local/bin/menu
chmod +x /usr/local/bin/menu

# ===============================
# TESTE DE EXECUÇÃO
# ===============================
echo "[+] Testando menu..."

if bash $MENU_PATH >/dev/null 2>&1; then
  echo "[OK] Menu executável"
else
  echo "[AVISO] Menu possui erro interno (verifique manualmente)"
fi

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
