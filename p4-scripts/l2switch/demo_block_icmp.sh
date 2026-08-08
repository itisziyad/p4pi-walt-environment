#!/bin/bash

set -e

echo "============================================"
echo " P4Pi - L2 Switch ICMP Block Demo"
echo "============================================"

echo "[1/2] Getting MAC address of br1..."
BR1_MAC=$(ip netns exec gigport ip addr show dev br1 | grep "link/ether" | awk '{print $2}')

if [ -z "$BR1_MAC" ]; then
    echo "      ERROR: Could not get MAC of br1. Is l2switch running?"
    exit 1
fi
echo "      br1 MAC address: $BR1_MAC"

echo "[2/2] Inserting drop rule for br1 MAC in P4Runtime..."
bmv2-p4rtshell l2switch << EOF
te = table_entry["ingress.smac"](action="ingress.drop")
te.match["hdr.ethernet.srcAddr"] = "$BR1_MAC"
te.insert()
exit
EOF

echo ""
echo "============================================"
echo " Done! ICMP replies from br1 are now blocked."
echo ""
echo " To verify:"
echo "   ping 192.168.4.150                          <- 100% loss on laptop"
echo "   ip netns exec gigport tcpdump -i br1 icmp   <- replies generated but dropped"
echo "   tcpdump -i br0 icmp                         <- nothing arrives"
echo ""
echo " To reset, restart BMv2:"
echo "   systemctl restart bmv2.service"
echo "============================================"
