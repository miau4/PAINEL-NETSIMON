#!/bin/bash
CONFIG="/etc/xray/config.json"
USERS="/etc/xray-manager/users.xray"
KEYFILE="/etc/xray-manager/reality.key"

# Criar arquivo de usuários se não existir
[ ! -f "$USERS" ] && touch "$USERS"

# Solicitar dados
read -p "Nome do usuário: " user
read -sp "Senha: " password
echo ""
read -p "Validade (dias): " validade

UUID=$(uuidgen)
IP=$(curl -s ifconfig.me)
PUBLIC=$(grep PUBLIC $KEYFILE | cut -d= -f2)
SNI=$(jq -r '.inbounds[2].streamSettings.realitySettings.dest' $CONFIG)
SID="6ba85179e30d4fc2"

# Calcular data de expiração
EXP=$(date -d "+$validade days" +"%Y-%m-%d")

# Adicionar nos inbounds
for i in 1 2 3; do
  jq ".inbounds[$i].settings.clients += [{\"id\":\"$UUID\",\"email\":\"$user\"}]" $CONFIG > /tmp/config.json
  mv /tmp/config.json $CONFIG
done

# Salvar no arquivo exclusivo
echo "$user:$password:$UUID:$EXP" >> $USERS

# Criar usuário SSH com a mesma senha
useradd -M -s /bin/false "$user" 2>/dev/null
echo "$user:$password" | chpasswd

# Reiniciar Xray
systemctl restart xray

# Mostrar links
echo -e "\nUsuário criado com sucesso!"
echo "Nome: $user"
echo "Senha: $password"
echo "UUID: $UUID"
echo "Validade: $EXP"
echo ""
echo "LINK VLESS XHTTP:"
echo "vless://$UUID@$IP:443?encryption=none&type=xhttp&security=tls&path=/#${user}"
echo ""
echo "LINK VLESS REALITY:"
echo "vless://$UUID@$IP:443?encryption=none&security=reality&type=tcp&sni=$SNI&fp=chrome&pbk=$PUBLIC&sid=$SID&flow=xtls-rprx-vision#$user"
