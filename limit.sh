#!/bin/bash

read -p "Usuario: " user
read -p "Limite de conexoes: " limit

echo "$user:$limit" >> /etc/xray-manager/limit.db

echo "Limite salvo"
