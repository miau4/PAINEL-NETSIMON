
#!/bin/bash

echo "Usuarios conectados:"

grep tcp /var/log/xray/access.log | awk '{print $3}' | sort | uniq
