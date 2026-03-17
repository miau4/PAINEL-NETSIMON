cat > /etc/xray-manager/monitor.sh << 'EOF'
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
        ss -tnp | grep xray | grep ESTAB
        read -p "Enter..."
        ;;
    2)
        read -p "Usuário: " user
        xray api statsquery --reset --pattern "user>>>$user>>>*" 2>/dev/null
        echo "Derrubado!"
        sleep 2
        ;;
    0) break ;;
    *) echo "Inválido"; sleep 1 ;;
esac
done
EOF
