#!/bin/bash

set -euo pipefail

echo "=== [enrich.sh] Enriching the P4Pi-WalT image ==="

echo "[enrich.sh] 1/4 Installing additional tools with apt..."

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
    python3-scapy \
    tshark \
    hping3 \
    nmap

echo "[enrich.sh]      Installing p4runtime-shell with pip..."
pip install --break-system-packages p4runtime-shell

apt-get clean
rm -rf /var/lib/apt/lists/*

echo "[enrich.sh] 2/4 Installing orchestration scripts..."

mkdir -p /usr/local/sbin /usr/local/bin

cat > /usr/local/sbin/p4pi-walt-setup << 'EOF'
#!/bin/bash
set -e

for pair in 0 1; do
    ip link add dev veth${pair} type veth peer name veth${pair}-host
    ip link set veth${pair} address 10:04:00:00:${pair}0:00
    ip link set veth${pair}-host address 10:04:00:00:${pair}0:10
    ip link set veth${pair} up
    ip link set veth${pair}-host up
    ethtool -K veth${pair} tx off rx off 2>/dev/null || true
    ethtool -K veth${pair}-host tx off rx off 2>/dev/null || true
    sysctl -w net.ipv6.conf.veth${pair}.disable_ipv6=1 >/dev/null
    sysctl -w net.ipv6.conf.veth${pair}-host.disable_ipv6=1 >/dev/null
done

echo "P4Pi-WalT setup done: veth0, veth0-host, veth1, veth1-host"
EOF
chmod +x /usr/local/sbin/p4pi-walt-setup

cat > /usr/local/bin/bmv2-start << 'EOF'
#!/bin/bash
BM2_WDIR=/root/bmv2
P4_PROG=l2switch
PROG_FILE=/root/p4pi-switch

if [ -f "${PROG_FILE}" ]; then
    P4_PROG=$(cat "${PROG_FILE}")
else
    echo "${P4_PROG}" > "${PROG_FILE}"
fi

EXAMPLE_SRC="${BM2_WDIR}/examples/${P4_PROG}/${P4_PROG}.p4"
if [ ! -f "${EXAMPLE_SRC}" ]; then
    echo "ERROR: P4 source file not found: ${EXAMPLE_SRC}"
    echo "Available examples:"
    ls ${BM2_WDIR}/examples/ 2>/dev/null
    exit 1
fi

if ! ip link show veth0 >/dev/null 2>&1; then
    /usr/local/sbin/p4pi-walt-setup
fi

rm -rf ${BM2_WDIR}/bin
mkdir -p ${BM2_WDIR}/bin

echo "Compiling P4 code: ${P4_PROG}"
p4c-bm2-ss -I /usr/share/p4c/p4include --std p4-16 \
    --p4runtime-files ${BM2_WDIR}/bin/${P4_PROG}.p4info.txt \
    -o ${BM2_WDIR}/bin/${P4_PROG}.json \
    ${EXAMPLE_SRC}

echo "Launching BMv2 switch (simple_switch_grpc)"
exec simple_switch_grpc -i 0@veth0 -i 1@veth1 \
    ${BM2_WDIR}/bin/${P4_PROG}.json \
    -- --grpc-server-addr 127.0.0.1:50051
EOF
chmod +x /usr/local/bin/bmv2-start

cat > /usr/local/bin/bmv2-p4rtshell << 'EOF'
#!/bin/bash

if [ -z $1 ]
then
        echo "Missing commandline argument!"
        echo "Usage: $(basename $0) <p4-program-name>"
        echo "Example: $(basename $0) l2switch"
        exit -1
fi

DEFAULT_PROG=$1
P4RTDIR="/root/bmv2/bin"

echo "Launching P4Runtime-shell..."

PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python python3 -m p4runtime_sh \
    --grpc-addr localhost:50051 --device-id 0 --election-id 0,1 \
    --config "${P4RTDIR}/${DEFAULT_PROG}.p4info.txt,${P4RTDIR}/${DEFAULT_PROG}.json"
EOF
chmod +x /usr/local/bin/bmv2-p4rtshell

cat > /usr/local/bin/t4p4s-p4rtshell << 'EOF'
#!/bin/bash
if [ -z $1 ]; then
    echo "Usage: $(basename $0) <p4-program-name>"
    echo "Example: $(basename $0) l2switch"
    exit 1
fi
DEFAULT_PROG=$1
T4P4SDIR="/root/t4p4s"
P4RTDIR="${T4P4SDIR}/examples/p4rt_files"

if [ ! -f "${T4P4SDIR}/examples/${DEFAULT_PROG}.p4" ]; then
    echo "P4 source file not found: ${T4P4SDIR}/examples/${DEFAULT_PROG}.p4"
    exit 1
fi

mkdir -p "$P4RTDIR"
pushd "${P4RTDIR}" >/dev/null
p4c-bm2-ss --p4runtime-files "${DEFAULT_PROG}.p4runtime.txt" \
           --toJSON "${DEFAULT_PROG}.json" \
           "${T4P4SDIR}/examples/${DEFAULT_PROG}.p4"
popd >/dev/null

python3 -m p4runtime_sh --grpc-addr localhost:50051 \
    --device-id 1 --election-id 0,1 \
    --config "${P4RTDIR}/${DEFAULT_PROG}.p4runtime.txt,${P4RTDIR}/${DEFAULT_PROG}.json"
EOF
chmod +x /usr/local/bin/t4p4s-p4rtshell

echo "[enrich.sh] 3/4 Creating symlinks to examples..."

mkdir -p /root/bmv2/examples

if [ -d /opt/p4pi/packages/p4pi-examples/bmv2 ]; then
    for ex in /opt/p4pi/packages/p4pi-examples/bmv2/*/; do
        name=$(basename "$ex")
        ln -sf "$ex" "/root/bmv2/examples/$name"
    done
    echo "[enrich.sh]      Linked examples :"
    ls /root/bmv2/examples/ | sed 's/^/        - /'
else
    echo "[enrich.sh]      WARNING : /opt/p4pi/packages/p4pi-examples/bmv2"
    echo "[enrich.sh]                was not found. Les liens d'exemples ne"
    echo "[enrich.sh]                will not be created. check that the"
    echo "[enrich.sh]                Dockerfile layer 5 cloned"
    echo "[enrich.sh]                p4lang/p4pi in /opt/p4pi."
fi

echo "l2switch" > /root/p4pi-switch

echo "[enrich.sh] 4/4 Final checks..."

echo "    Installed scripts :"
ls -l /usr/local/bin/bmv2-* /usr/local/bin/t4p4s-* /usr/local/sbin/p4pi-* \
    2>/dev/null | sed 's/^/        /' || true

echo "    Python tools :"
python3 -c "import scapy; print('        scapy', scapy.__version__)" || true
python3 -c "import p4runtime_sh; print('        p4runtime_sh OK')" || true

echo "    Packet generators / analyzers :"
for tool in tshark hping3 nping; do
    if which $tool >/dev/null 2>&1; then
        echo "        $tool : $(which $tool)"
    else
        echo "        $tool : ABSENT"
    fi
done

echo "=== [enrich.sh] Done. ==="
