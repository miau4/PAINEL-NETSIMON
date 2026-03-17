#!/bin/bash

USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

# verifica se existe arquivo
[ ! -f "$USERS" ] && echo "Arquivo de usuários não encontrado!" && exit

clear
echo "========== REMOVER USUÁRIO =========="

# lista usuários numerados
mapfile -t lista < <(cut -d'|' -f1 "$USERS")

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
linha=$(grep "^$user|" "$USERS")
uuid=$(echo "$linha" | cut -d'|' -f2)

# remove do arquivo users.xray
grep -v "^$user|" "$USERS" > /tmp/users.tmp && mv /tmp/users.tmp "$USERS"

# remove do config.json (Xray)
jq --arg uuid "$uuid" '
(.inbounds[] | select(.protocol=="vless" or .protocol=="vmess") | .settings.clients) |= map(select(.id != $uuid))
' "$CONFIG" > /tmp/config.json && mv /tmp/config.json "$CONFIG"

# reinicia serviço
systemctl restart xray

echo ""
echo "======================================"
echo "Usuário removido com sucesso!"
echo "Usuário: $user"
echo "======================================"

read -n1 -r -p "Pressione qualquer tecla para voltar..."
