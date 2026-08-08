#!/bin/bash

set -e

echo "============================================"
echo " P4Pi - L2 Switch Setup (BMv2)"
echo "============================================"

echo "[1/4] Switching to BMv2 backend..."
systemctl stop t4p4s.service   2>/dev/null || true
systemctl disable t4p4s.service 2>/dev/null || true
echo "l2switch" > /root/t4p4s-switch
systemctl enable bmv2.service
systemctl restart bmv2.service
echo "      Done."

echo "[2/4] Waiting for BMv2 switch to be ready..."
for i in $(seq 1 20); do
    if nc -z localhost 9090 2>/dev/null; then
        echo "      Switch is ready."
        break
    fi
    if [ $i -eq 20 ]; then
        echo "      ERROR: Timed out waiting for port 9090."
        echo "      Check logs: journalctl -u bmv2.service"
        exit 1
    fi
    sleep 2
done

echo "[3/4] Configuring multicast group for broadcasting..."
simple_switch_CLI << 'EOF'
mc_mgrp_create 1
mc_node_create 0 0 1
mc_node_associate 1 0
EOF
echo "      Multicast group 1 configured (ports 0 and 1)."

echo "[4/4] Checking BMv2 is running..."
if systemctl is-active --quiet bmv2.service; then
    echo "      BMv2 is running."
else
    echo "      ERROR: BMv2 service is not active."
    exit 1
fi

echo ""
echo "============================================"
echo " Setup complete!"
echo " Test: ping 192.168.4.150 from your laptop"
echo "============================================"
