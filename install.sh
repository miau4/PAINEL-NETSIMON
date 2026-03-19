#!/bin/bash

clear
echo "=== INSTALANDO PAINEL BASE ==="

# Verificar root
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root!"
  exit 1
fi

# Atualizar sistema
apt update -y || { echo "Erro no apt update"; exit 1; }

# Instalar dependências
apt install curl wget unzip -y

# Criar diretórios
mkdir -p /etc/painel/{core,services,data}

# Repo base
BASE_URL="https://raw.githubusercontent.com/miau4/PAINEL-NETSIMON/main"

# Baixar arquivos
wget -O /etc/painel/menu.sh $BASE_URL/menu.sh
wget -O /etc/painel/core/utils.sh $BASE_URL/core/utils.sh

# Permissões
chmod +x /etc/painel/menu.sh

# Atalho global
ln -sf /etc/painel/menu.sh /usr/bin/painel

# Criar arquivo de serviços
echo "[]" > /etc/painel/data/services.conf

# ===============================
# INSTALAR API
# ===============================

echo "Instalando API..."

mkdir -p /etc/xray-manager

wget -O /etc/xray-manager/api.sh $BASE_URL/api.sh

chmod +x /etc/xray-manager/api.sh

# Iniciar API
nohup bash /etc/xray-manager/api.sh > /dev/null 2>&1 &

echo "API instalada e iniciada!"

echo "INSTALADO! Use: painel"
