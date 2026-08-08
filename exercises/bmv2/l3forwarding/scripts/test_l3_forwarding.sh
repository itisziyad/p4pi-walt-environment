#!/bin/bash
set -e

HOST2_IP="10.10.2.2"

echo "[test] route:"
ip route get "$HOST2_IP"

echo "[test] arp:"
arp -n

echo "[test] ping:"
ping -c 5 "$HOST2_IP"
