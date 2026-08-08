# P4Pi BMv2 Demo Scripts

This directory contains Bash scripts for deploying, configuring, and testing P4 programs on a Raspberry Pi 4 running P4Pi with the BMv2 software switch.

## Prerequisites

- A Raspberry Pi 4 flashed with a P4Pi image.
- A workstation connected to the Raspberry Pi network.
- SSH access to the Pi.

The scripts are designed to be launched from the workstation and streamed to the Raspberry Pi over SSH.

## L2 Switch and ICMP Blocking Demo

Start the L2 switch:

```sh
ssh pi@192.168.4.1 'sudo -i bash -s' < l2switch/setup_l2switch_pi.sh
```

Block ICMP traffic after the L2 switch is running:

```sh
ssh pi@192.168.4.1 'sudo -i bash -s' < l2switch/demo_block_icmp.sh
```

Validation:

```sh
ping 192.168.4.150
```

The ping should fail after the drop rule is installed.

## Stateful Firewall Demo

Deploy the stateful firewall:

```sh
ssh pi@192.168.4.1 'sudo -i bash -s' < firewall/setup_stateful_firewall.sh
```

Start an iperf server on the Pi-side namespace:

```sh
sudo ip netns exec gigport iperf -s -B 192.168.4.150
```

Test an outgoing connection from the workstation:

```sh
iperf -c 192.168.4.150 -t 30 -i 1
```

Test an incoming connection from the Pi to the workstation:

```sh
sudo ip netns exec gigport iperf -c 192.168.4.12 -t 10
```

Replace `192.168.4.12` with the workstation IP address on the P4Pi network.

## Calc Demo

Deploy the Calc example:

```sh
ssh pi@192.168.4.1 'sudo -i bash -s' < calc/setup_calc.sh
```
