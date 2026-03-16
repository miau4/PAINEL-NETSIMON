#!/bin/bash

clear

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "     GERENCIADOR SSH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "1 • Criar usuario SSH"
echo "2 • Remover usuario SSH"
echo "3 • Listar usuarios"
echo "0 • Voltar"

read -p "Escolha: " op

case $op in

1)

read -p "Usuario: " user
read -p "Senha: " pass
read -p "Dias: " dias

useradd -e $(date -d "$dias days" +"%Y-%m-%d") -M -s /bin/false $user
echo "$user:$pass" | chpasswd

echo ""
echo "Usuario criado"

;;

2)

read -p "Usuario: " user
userdel $user

echo "Usuario removido"

;;

3)

cut -d: -f1 /etc/passwd

;;

0)

menu

;;

esac
