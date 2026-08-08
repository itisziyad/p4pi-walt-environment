#!/bin/bash
set -e

LEFT_IFACE="eth1"
RIGHT_IFACE="eth4"

LEFT_IP="10.10.1.2/24"
RIGHT_IP="10.10.2.1/24"

echo "[switch] configure interfaces"

ip addr flush dev "$LEFT_IFACE"
ip addr flush dev "$RIGHT_IFACE"

ip addr add "$LEFT_IP" dev "$LEFT_IFACE"
ip addr add "$RIGHT_IP" dev "$RIGHT_IFACE"

ip link set "$LEFT_IFACE" up
ip link set "$RIGHT_IFACE" up

echo "[switch] disable linux forwarding"
sysctl -w net.ipv4.ip_forward=0

echo "[switch] done"
ip -br addr show dev "$LEFT_IFACE"
ip -br addr show dev "$RIGHT_IFACE"
