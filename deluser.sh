#!/bin/bash
USERS="/etc/xray-manager/users.xray"
CONFIG="/etc/xray/config.json"

if [ ! -f "$USERS" ] || [ ! -s "$USERS" ]; then
    echo "Nenhum usuário cadastrado."
    exit 1
fi

# Mostrar lista numerada
echo "Usuários cadastrados:"
i=1
while IFS=: read -r name pass uuid exp; do
    echo "$i) $name - UUID: $uuid - Expira: $exp"
    usuarios_array[$i]=$name
    ((i++))
done < $USERS

read -p "Escolha o número do usuário a deletar: " n
usuario=${usuarios_array[$n]}

if [ -z "$usuario" ]; then
    echo "Opção inválida!"
    exit 1
fi

# Remover do arquivo de usuários
grep -v "^$usuario:" $USERS > /tmp/users.tmp
mv /tmp/users.tmp $USERS

# Remover dos inbounds
uuid=$(grep "^$usuario:" $USERS | cut -d: -f3)
jq "(.inbounds[].settings.clients) |= map(select(.id != \"$uuid\"))" $CONFIG > /tmp/config.json
mv /tmp/config.json $CONFIG

# Remover usuário SSH
userdel "$usuario" 2>/dev/null

# Reiniciar Xray
systemctl restart xray

echo "Usuário $usuario removido com sucesso!"
read -p "Pressione ENTER para voltar ao menu..."
