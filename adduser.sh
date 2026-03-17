#!/bin/bash

USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

clear
echo "══════════════════════════════"
echo "     ➕ CRIAR USUÁRIO"
echo "══════════════════════════════"

# ----------------- INPUT -----------------
read -p "Nome do usuário: " user

# valida nome
if [[ -z "$user" ]]; then
    echo "Nome inválido!"
    sleep 2
    exit
fi

# verifica duplicado
if grep -q "^$user|" "$USERS" 2>/dev/null; then
    echo "Usuário já existe!"
    sleep 2
    exit
fi

read -p "Senha: " pass

if [[ -z "$pass" ]]; then
    echo "Senha inválida!"
    sleep 2
    exit
fi

read -p "Dias de validade: " dias

if ! [[ "$dias" =~ ^[0-9]+$ ]]; then
    echo "Valor inválido!"
    sleep 2
    exit
fi

# ----------------- GERAR DADOS -----------------
uuid=$(uuidgen)
exp_date=$(date -d "+$dias days" +"%Y-%m-%d")

# ----------------- CONFIRMAÇÃO -----------------
clear
echo "════════ CONFIRMAÇÃO ════════"
echo "Usuário : $user"
echo "Senha   : $pass"
echo "Validade: $exp_date"
echo "═════════════════════════════"
read -p "Confirmar? (s/n): " confirm

[[ "$confirm" != "s" && "$confirm" != "S" ]] && exit

# ----------------- SALVAR USUÁRIO -----------------
mkdir -p /etc/xray-manager
echo "$user|$uuid|$exp_date|$pass" >> $USERS

# ----------------- ADICIONAR NO XRAY -----------------
if [ -f "$CONFIG" ]; then
    tmp=$(mktemp)

    jq --arg uuid "$uuid" --arg user "$user" '
    (.inbounds[] | select(.tag=="vless-tls" or .tag=="vless-ws") | .settings.clients) += [{
        "id": $uuid,
        "email": $user
    }]
    ' "$CONFIG" > "$tmp" && mv "$tmp" "$CONFIG"

    systemctl restart xray
fi

# ----------------- RESULTADO -----------------
clear
echo "══════════════════════════════"
echo "     ✅ USUÁRIO CRIADO"
echo "══════════════════════════════"
echo "Usuário : $user"
echo "Senha   : $pass"
echo "UUID    : $uuid"
echo "Expira  : $exp_date"
echo "══════════════════════════════"

read -n1 -r -p "Pressione qualquer tecla..."
