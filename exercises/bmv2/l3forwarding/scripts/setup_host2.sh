#!/bin/bash
set -e

IFACE="eth4"
MY_IP="10.10.2.2/24"
HOST1_IP="10.10.1.1"
HOST1_MAC="10:11:01:00:01:03"

echo "[host2] configure $IFACE"

ip addr flush dev "$IFACE"
ip addr add "$MY_IP" dev "$IFACE"
ip link set "$IFACE" up

ip route del 10.10.1.0/24 2>/dev/null || true
ip route add 10.10.1.0/24 dev "$IFACE"

arp -d "$HOST1_IP" 2>/dev/null || true
arp -s "$HOST1_IP" "$HOST1_MAC"

echo "[host2] done"
ip -br addr show dev "$IFACE"
ip route
arp -n
