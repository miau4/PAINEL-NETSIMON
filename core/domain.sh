```bash id="m3r9vs"
#!/bin/bash

source /etc/painel/core/utils.sh

function instalar_ssl(){

clear
echo "=== CONFIGURAR DOMÍNIO + SSL ==="

read -p "Digite seu domínio (ex: vpn.seudominio.com): " DOMAIN

if [[ -z "$DOMAIN" ]]; then
  error "Domínio inválido!"
  return
fi

echo "Verificando DNS..."

IP=$(curl -s ifconfig.me)
DNS=$(ping -c1 $DOMAIN | head -1 | awk '{print $3}' | tr -d '()')

if [[ "$DNS" != "$IP" ]]; then
  error "DNS não apontado para este servidor!"
  echo "IP esperado: $IP"
  echo "IP encontrado: $DNS"
  return
fi

msg "DNS OK!"

echo "Instalando nginx + certbot..."
apt update -y
apt install nginx certbot python3-certbot-nginx -y

systemctl enable nginx
systemctl start nginx

echo "Gerando certificado SSL..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN --redirect

if [[ $? -ne 0 ]]; then
  error "Erro ao gerar SSL!"
  return
fi

echo "$DOMAIN" > /etc/painel/data/domain.conf

msg "SSL instalado com sucesso!"
echo "Domínio: $DOMAIN"

}

function ver_dominio(){
clear

if [ -f /etc/painel/data/domain.conf ]; then
  DOMAIN=$(cat /etc/painel/data/domain.conf)
  msg "Domínio atual: $DOMAIN"
else
  error "Nenhum domínio configurado"
fi

read -p "ENTER para voltar"
}

function menu_domain(){
clear
echo "=== DOMÍNIO E SSL ==="
echo "[1] Configurar domínio + SSL"
echo "[2] Ver domínio atual"
echo "[0] Voltar"

read -p "Escolha: " op

case $op in
1) instalar_ssl ;;
2) ver_dominio ;;
0) return ;;
esac
}

menu_domain
```
