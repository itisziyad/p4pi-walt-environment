# P4Pi WalT Experimentation Environment

Automation and experiment scripts for deploying a P4 experimentation environment on Raspberry Pi 4 nodes managed by WalT.

The project builds on the open-source P4Pi ecosystem and focuses on making P4 experiments easier to reproduce in a teaching lab: image preparation, BMv2 orchestration, P4Runtime setup, and scripted network experiments across multiple Raspberry Pi nodes.

## Features

- WalT-compatible P4Pi image build scripts.
- Image enrichment scripts for BMv2, P4Runtime shell, Scapy, packet generators, and troubleshooting tools.
- P4 examples for BMv2 and p4app.
- L3 forwarding experiment scripts for a multi-Raspberry-Pi WalT topology.
- Demo scripts for L2 switching, ICMP filtering, stateful firewall, Calc, and policy routing.
- Documentation and diagrams for the Raspberry Pi / P4Pi setup.

## Project Context

Initial goal: set up an automated P4 experimentation environment on Raspberry Pi 4 nodes controlled by WalT.

The expected environment had to:

- validate and adapt P4Pi on Raspberry Pi 4;
- build bootable P4Pi images compatible with WalT;
- automate simple P4 network experiments;
- run examples on multiple Raspberry Pi nodes;
- provide scripts and HOWTO-style documentation for reproducible experiments.

This project was developed by a team of three students:

- DERGHAZI Ziyad
- FAKHREI Nizar
- SEGHYAR Moatassem

## Main Contributions

This repository builds on the existing P4Pi ecosystem. The project contribution is not the P4Pi system itself, but the automation and experiment layer added around it.

The main additions are:

- `scripts/`: WalT-oriented image automation.
  - `build.sh`: builds the P4Pi-WalT environment from a base WalT Raspberry Pi image.
  - `enrich.sh`: installs orchestration scripts and experiment tools such as Scapy, P4Runtime shell, hping3, nping, and tshark.
  - `Dockerfile`: provides an automated image build path for WalT.
- `exercises/bmv2/l3forwarding/scripts/`: reproducible multi-node L3 forwarding experiment.
  - source host setup;
  - destination host setup;
  - BMv2/P4 switch interface setup;
  - BMv2 launch script;
  - forwarding rule loading script;
  - end-to-end connectivity test script.
- `p4-scripts/`: Raspberry Pi demo scripts executed over SSH.
  - L2 switch setup;
  - ICMP blocking demo;
  - stateful firewall setup;
  - Calc example setup;
  - policy router P4 program.
- `README.md`: project-level documentation describing the WalT workflow, repository structure, and an example run.

## Repository Structure

```text
.
├── scripts/       # WalT image build and enrichment scripts
├── exercises/     # P4/BMv2 exercises and multi-node experiment scripts
├── p4-scripts/    # Raspberry Pi demo scripts for P4Pi experiments
├── p4app/         # p4app examples and topologies
├── docs/images/   # Setup and experiment diagrams
└── README.md
```

## WalT Image Workflow

The image workflow is located in `scripts/`.

```sh
walt image duplicate waltplatform/rpi-4-b-default p4pi-walt-fresh
walt image shell p4pi-walt-fresh
bash scripts/build.sh
bash scripts/enrich.sh
exit
```

The same build logic is also available as a Dockerfile:

```sh
walt image build --from-dir scripts p4pi-walt
```

## L3 Forwarding Experiment

The L3 forwarding experiment is located in:

```text
exercises/bmv2/l3forwarding/scripts/
```

It configures three WalT-managed Raspberry Pi nodes:

- one source host;
- one BMv2/P4 switch;
- one destination host.

Main scripts:

- `setup_host1.sh`: configures the source host.
- `setup_host2.sh`: configures the destination host.
- `setup_p4_switch_ifaces.sh`: configures switch interfaces.
- `run_l2_bmv2.sh`: compiles the P4 program and starts BMv2.
- `load_l3_rules.sh`: loads forwarding rules.
- `test_l3_forwarding.sh`: validates connectivity with ping.

Example run:

```sh
# On the source host
cd /persist/bmv2/examples/l3switch
./setup_host1.sh

# On the destination host
cd /persist/bmv2/examples/l3switch
./setup_host2.sh

# On the BMv2/P4 switch
cd /persist/bmv2/examples/l3switch
./setup_p4_switch_ifaces.sh
./run_l2_bmv2.sh
./load_l3_rules.sh

# Back on the source host
cd /persist/bmv2/examples/l3switch
./test_l3_forwarding.sh
```

## P4Pi Demo Scripts

The `p4-scripts/` directory contains scripts for running P4Pi demos over SSH:

- L2 switch setup.
- ICMP blocking demo.
- Stateful firewall setup.
- Calc example setup.
- Policy router P4 program.
