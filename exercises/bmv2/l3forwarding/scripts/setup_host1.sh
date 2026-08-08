#!/bin/bash
set -e

IFACE="eth1"
MY_IP="10.10.1.1/24"
HOST2_IP="10.10.2.2"
HOST2_MAC="00:e0:4c:68:01:93"

echo "[host1] configure $IFACE"

ip addr flush dev "$IFACE"
ip addr add "$MY_IP" dev "$IFACE"
ip link set "$IFACE" up

ip route del 10.10.2.0/24 2>/dev/null || true
ip route add 10.10.2.0/24 dev "$IFACE"

arp -d "$HOST2_IP" 2>/dev/null || true
arp -s "$HOST2_IP" "$HOST2_MAC"

echo "[host1] done"
ip -br addr show dev "$IFACE"
ip route
arp -n
