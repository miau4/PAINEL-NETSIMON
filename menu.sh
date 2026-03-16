#!/bin/bash

clear

echo "XRAY MANAGER"

echo "1 Criar usuario"
echo "2 Remover usuario"
echo "3 Usuarios online"
echo "4 Rebuild config"
echo "0 Sair"

read op

case $op in

1)
adduser
;;

2)
deluser
;;

3)
online
;;

4)
rebuild
;;

esac
