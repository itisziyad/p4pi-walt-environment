#!/bin/bash
set -e

P4_DIR="/root/bmv2/examples/l3switch"
P4_FILE="l3forwarding.p4"
JSON_FILE="l3forwarding.json"

LEFT_IFACE="eth1"
RIGHT_IFACE="eth4"

cd "$P4_DIR"

echo "[bmv2] stop old simple_switch if any"
pkill simple_switch 2>/dev/null || true
sleep 1

echo "[bmv2] compile $P4_FILE"
rm -rf "$JSON_FILE"
p4c-bm2-ss --std p4-16 "$P4_FILE" -o "$JSON_FILE"

echo "[bmv2] start simple_switch"
simple_switch -i 0@"$LEFT_IFACE" -i 1@"$RIGHT_IFACE" "$JSON_FILE" > /tmp/simple_switch.log 2>&1 &

sleep 2

echo "[bmv2] status"
pgrep -a simple_switch || {
    echo "[error] simple_switch did not start"
    echo "---- /tmp/simple_switch.log ----"
    cat /tmp/simple_switch.log
    exit 1
}

echo "[bmv2] log: /tmp/simple_switch.log"
