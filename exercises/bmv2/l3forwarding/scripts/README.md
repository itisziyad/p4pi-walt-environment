# P4Pi L3 Forwarding Experiment with BMv2

This experiment configures simple IPv4 forwarding with P4Pi and BMv2 on three Raspberry Pi nodes managed by WalT.

Traffic starts from `p4pi-test1`, crosses the P4 switch `papi51-5505bd`, and reaches `papi52-5506d1`.

The P4 switch program:

- parses Ethernet and IPv4 headers;
- selects the output port according to the destination IPv4 address;
- rewrites source and destination MAC addresses;
- decrements the IPv4 TTL;
- forwards the packet.

## Topology

```text
p4pi-test1              papi51-5505bd                 papi52-5506d1
Host 1                  BMv2 P4 switch                Host 2
eth1                    eth1      eth4                 eth4
10.10.1.1/24 ---------  10.10.1.2  10.10.2.1 --------  10.10.2.2/24
```

## Scripts

- `setup_host1.sh`: configure the source host.
- `setup_host2.sh`: configure the destination host.
- `setup_p4_switch_ifaces.sh`: configure the P4 switch interfaces.
- `run_l2_bmv2.sh`: compile the P4 program and start BMv2.
- `load_l3_rules.sh`: load forwarding rules into BMv2.
- `test_l3_forwarding.sh`: test end-to-end connectivity.

## Run the Experiment

On `p4pi-test1`:

```sh
cd /persist/bmv2/examples/l3switch
./setup_host1.sh
```

On `papi52-5506d1`:

```sh
cd /persist/bmv2/examples/l3switch
./setup_host2.sh
```

On `papi51-5505bd`:

```sh
cd /persist/bmv2/examples/l3switch
./setup_p4_switch_ifaces.sh
./run_l2_bmv2.sh
./load_l3_rules.sh
```

Test from `p4pi-test1`:

```sh
cd /persist/bmv2/examples/l3switch
bash test_l3_forwarding.sh
```

## WalT Persistence

Experiment files are stored in:

```sh
/persist/bmv2/examples/l3switch
```

After a reboot, files persist, but IP addresses, routes, ARP entries, P4 rules, and BMv2 processes must be recreated by running the scripts again.
