```bash
#!/bin/bash

clear
echo "=== INSTALANDO PAINEL BASE ==="

apt update -y
apt install curl wget unzip -y

mkdir -p /etc/painel/{core,services,data}

# Baixar arquivos do GitHub (ajuste seu repo)
BASE_URL="https://raw.githubusercontent.com/miau4/PAINEL-NETSIMON/main"

wget -O /etc/painel/menu.sh $BASE_URL/menu.sh
wget -O /etc/painel/core/utils.sh $BASE_URL/core/utils.sh

chmod +x /etc/painel/menu.sh

# Atalho global
ln -sf /etc/painel/menu.sh /usr/bin/painel

echo "[] > /etc/painel/data/services.conf" > /dev/null

```bash
# ===============================
# INSTALAR API
# ===============================

echo "Instalando API..."

wget -O /etc/xray-manager/api.sh https://raw.githubusercontent.com/miau4/PAINEL-NETSIMON/main/api.sh

chmod +x /etc/xray-manager/api.sh

# iniciar api
nohup bash /etc/xray-manager/api.sh > /dev/null 2>&1 &

echo "API instalada e iniciada!"
```


echo "INSTALADO! Use: painel"
```
