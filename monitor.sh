#!/bin/bash

while true; do
clear
echo "════════ MONITOR AVANÇADO ════════"
echo "1) Ver conexões"
echo "2) Derrubar usuário"
echo "0) Voltar"
echo "══════════════════════════════════"

read -p "Escolha: " op

case $op in
    1)
        echo "Conexões ativas:"

        if command -v ss >/dev/null 2>&1; then
            ss -tnp 2>/dev/null | grep xray | grep ESTAB
        else
            echo "Comando ss não disponível!"
        fi

        read -p "Enter..."
        ;;

    2)
        read -p "Usuário: " user

        if ! command -v xray >/dev/null 2>&1; then
            echo "Xray não instalado!"
            sleep 2
            continue
        fi

        xray api statsquery --reset --pattern "user>>>$user>>>*" 2>/dev/null

        if [ $? -eq 0 ]; then
            echo "Derrubado!"
        else
            echo "Falha ao derrubar usuário!"
        fi

        sleep 2
        ;;

    0) break ;;

    *) echo "Inválido"; sleep 1 ;;

esac
done
