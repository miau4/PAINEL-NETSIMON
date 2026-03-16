#!/bin/bash

clear

echo "━━━━━━━━━━━━━━━━━━━━━━"
echo " XRAY MANAGER MULT"
echo "━━━━━━━━━━━━━━━━━━━━━━"

echo "1 Criar usuario"
echo "2 Remover usuario"
echo "3 Usuarios online"
echo "4 Definir limite"
echo "5 Definir expiração"
echo "6 Backup"
echo "7 Rebuild config"
echo "8 Verificar JSON"
echo "0 Sair"

read op

case $op in

1) adduser ;;
2) deluser ;;
3) online ;;
4) limit ;;
5) expire ;;
6) backup ;;
7) rebuild ;;
8) checkjson ;;

esac
