#!/bin/bash
set -e

HOST1_IP="10.10.1.1"
HOST1_MAC="10:11:01:00:01:03"
HOST1_PORT="0"

HOST2_IP="10.10.2.2"
HOST2_MAC="00:e0:4c:68:01:93"
HOST2_PORT="1"

cat > /tmp/l3_commands.txt << RULES
table_add MyIngress.ipv4_lpm MyIngress.ipv4_forward $HOST1_IP/32 => $HOST1_MAC $HOST1_PORT
table_add MyIngress.ipv4_lpm MyIngress.ipv4_forward $HOST2_IP/32 => $HOST2_MAC $HOST2_PORT
RULES

echo "[rules] loading:"
cat /tmp/l3_commands.txt

simple_switch_CLI < /tmp/l3_commands.txt
