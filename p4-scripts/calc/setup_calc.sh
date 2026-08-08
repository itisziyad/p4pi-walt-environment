#!/bin/bash
echo 'calc' > /root/t4p4s-switch
systemctl restart bmv2.service
sleep 5
systemctl is-active bmv2.service && echo "[OK] BMv2 active with calc" || echo "[ERROR] BMv2 did not start"
