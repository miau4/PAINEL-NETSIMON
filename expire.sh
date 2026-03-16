#!/bin/bash

read -p "Usuario: " user
read -p "Data de expiracao (AAAA-MM-DD): " date

echo "$user:$date" >> /etc/xray-manager/exp.db

echo "Expiracao registrada"
