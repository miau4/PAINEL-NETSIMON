#!/bin/bash

USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

clear
echo "══════════════════════════════"
echo "     ➕ CRIAR USUÁRIO PRO"
echo "══════════════════════════════"

# ----------------- GARANTIA DE ARQUIVOS -----------------
mkdir -p /etc/xray-manager
[ ! -f "$USERS" ] && touch "$USERS"

# ----------------- INPUT -----------------
read -p "Nome do usuário: " user

if [[ -z "$user" || "$user" =~ [^a-zA-Z0-9_] ]]; then
    echo "Nome inválido! (use apenas letras/números)"
    sleep 2
    exit
fi

if grep -q "^$user|" "$USERS" 2>/dev/null; then
    echo "Usuário já existe!"
    sleep 2
    exit
fi

read -p "Senha: " pass
[ -z "$pass" ] && echo "Senha inválida!" && sleep 2 && exit

read -p "Dias de validade: " dias
[[ ! "$dias" =~ ^[0-9]+$ ]] && echo "Valor inválido!" && sleep 2 && exit

# 🔐 limite de conexões
read -p "Limite de IPs simultâneos (ex: 1,2,3): " limit
[[ ! "$limit" =~ ^[0-9]+$ ]] && limit=1

# ----------------- GERAR -----------------
uuid=$(cat /proc/sys/kernel/random/uuid 2>/dev/null)
[ -z "$uuid" ] && uuid=$(uuidgen 2>/dev/null)

exp_date=$(date -d "+$dias days" +"%Y-%m-%d" 2>/dev/null)

if [ -z "$uuid" ] || [ -z "$exp_date" ]; then
    echo "Erro ao gerar dados do usuário!"
    sleep 2
    exit
fi

# ----------------- CONFIRMAÇÃO -----------------
clear
echo "════════ CONFIRMAÇÃO ════════"
echo "Usuário : $user"
echo "Senha   : $pass"
echo "UUID    : $uuid"
echo "Validade: $exp_date"
echo "Limite  : $limit IP(s)"
echo "═════════════════════════════"
read -p "Confirmar? (s/n): " confirm

[[ "$confirm" != "s" && "$confirm" != "S" ]] && exit

# ----------------- SALVAR -----------------
echo "$user|$uuid|$exp_date|$pass|$limit" >> "$USERS"

# ----------------- XRAY CONFIG -----------------
if [ -f "$CONFIG" ]; then

    command -v jq >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "jq não instalado! usuário criado sem integrar ao Xray."
    else
        tmp=$(mktemp)

        jq --arg uuid "$uuid" --arg user "$user" '
        (.inbounds[] | select(.protocol=="vless" or .protocol=="vmess") | .settings.clients) += [{
            "id": $uuid,
            "email": $user
        }]
        ' "$CONFIG" > "$tmp"

        if [ $? -eq 0 ] && [ -s "$tmp" ]; then
            mv "$tmp" "$CONFIG"
            systemctl restart xray 2>/dev/null
        else
            echo "Erro ao atualizar config.json (JSON inválido)"
            rm -f "$tmp"
        fi
    fi
else
    echo "config.json não encontrado! usuário criado apenas no banco."
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
echo "Limite  : $limit IP(s)"
echo "══════════════════════════════"

read -n1 -r -p "Pressione qualquer tecla..."
