#!/bin/bash

USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

# verifica se existe arquivo
[ ! -f "$USERS" ] && echo "Arquivo de usuários não encontrado!" && exit

clear
echo "========== REMOVER USUÁRIO =========="

# lista usuários numerados
mapfile -t lista < <(cut -d'|' -f1 "$USERS" 2>/dev/null)

if [ ${#lista[@]} -eq 0 ]; then
    echo "Nenhum usuário encontrado."
    read -n1 -r -p "Pressione qualquer tecla..."
    exit
fi

for i in "${!lista[@]}"; do
    echo "$((i+1))) ${lista[$i]}"
done

echo ""
read -p "Digite o número do usuário: " num

# valida número
if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#lista[@]}" ]; then
    echo "Opção inválida!"
    read -n1 -r -p "Pressione qualquer tecla..."
    exit
fi

user="${lista[$((num-1))]}"

# pega uuid do usuário
linha=$(grep "^$user|" "$USERS" 2>/dev/null)
uuid=$(echo "$linha" | cut -d'|' -f2)

# segurança: se não achar uuid, aborta
if [ -z "$uuid" ]; then
    echo "Erro ao localizar UUID do usuário!"
    read -n1 -r -p "Pressione qualquer tecla..."
    exit
fi

# remove do arquivo users.xray
tmp_users=$(mktemp)
grep -v "^$user|" "$USERS" > "$tmp_users" && mv "$tmp_users" "$USERS"

# remove do config.json (Xray)
if [ -f "$CONFIG" ]; then

    command -v jq >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "jq não instalado! usuário removido apenas do banco."
    else
        tmp_config=$(mktemp)

        jq --arg uuid "$uuid" '
        (.inbounds[] | select(.protocol=="vless" or .protocol=="vmess") | .settings.clients) |= map(select(.id != $uuid))
        ' "$CONFIG" > "$tmp_config"

        if [ $? -eq 0 ] && [ -s "$tmp_config" ]; then
            mv "$tmp_config" "$CONFIG"
            systemctl restart xray 2>/dev/null
        else
            echo "Erro ao atualizar config.json (JSON inválido)"
            rm -f "$tmp_config"
        fi
    fi
else
    echo "config.json não encontrado! usuário removido apenas do banco."
fi

echo ""
echo "======================================"
echo "Usuário removido com sucesso!"
echo "Usuário: $user"
echo "======================================"

read -n1 -r -p "Pressione qualquer tecla para voltar..."
