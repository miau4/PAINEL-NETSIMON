#!/bin/bash

LOG="/var/log/xray/access.log"

echo "Usuarios online"

grep accepted $LOG | awk '{print $3}' | sort | uniq -c
