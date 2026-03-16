#!/bin/bash

clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "     TESTE DE VELOCIDADE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if ! command -v speedtest &> /dev/null
then
echo "Instalando Speedtest..."
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
apt install speedtest -y
fi

speedtest

echo ""
read -p "Pressione ENTER para voltar"
menu
