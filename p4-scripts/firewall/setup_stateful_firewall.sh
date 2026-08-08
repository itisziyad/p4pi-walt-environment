#!/bin/bash

echo 'stateful_firewall' > /root/t4p4s-switch
systemctl restart bmv2.service
sleep 5
systemctl is-active bmv2.service && echo "[OK] BMv2 active with stateful_firewall" || { echo "[ERROR] BMv2 did not start"; exit 1; }


bmv2-p4rtshell stateful_firewall << 'P4RT'

te = table_entry["MyIngress.check_ports"](action="MyIngress.set_direction")
te.match["standard_metadata.ingress_port"] = "0"
te.match["standard_metadata.egress_spec"] = "1"
te.action["dir"] = "0"
te.insert()

te = table_entry["MyIngress.check_ports"](action="MyIngress.set_direction")
te.match["standard_metadata.ingress_port"] = "1"
te.match["standard_metadata.egress_spec"] = "0"
te.action["dir"] = "1"
te.insert()

P4RT

echo "[OK] rules inserted — stateful firewall active"
echo ""
echo "=== Run on the Pi ==="
echo "  sudo ip netns exec gigport iperf -s -B 192.168.4.150"
echo ""
echo "=== Run from the laptop ==="
echo "Connexion sortante (doit passer) :"
echo "  iperf -c 192.168.4.150 -t 30 -i 1"
echo "Incoming connection (should be blocked) :"
echo "  sudo ip netns exec gigport iperf -c 192.168.4.12 -t 10"
