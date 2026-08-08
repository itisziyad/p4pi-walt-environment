#!/bin/bash

set -euo pipefail

echo "=== [build.sh] Building the P4Pi-WalT image ==="

export DEBIAN_FRONTEND=noninteractive
export PIP_BREAK_SYSTEM_PACKAGES=1   # PEP 668: allow global pip installs

echo "[build.sh] 1/5 Installing system dependencies..."

apt-get update
apt-get install -y --no-install-recommends \
    git cmake g++ automake libtool pkg-config make screen \
    libboost-dev libboost-program-options-dev libboost-system-dev \
    libboost-filesystem-dev libboost-thread-dev libboost-iostreams-dev \
    libgmp-dev libpcap-dev libssl-dev \
    python3 python3-pip python3-setuptools python3-pyelftools \
    protobuf-compiler libprotobuf-dev \
    libgrpc-dev libgrpc++-dev protobuf-compiler-grpc \
    dpdk dpdk-dev \
    iproute2 tcpdump net-tools iperf3

echo "[build.sh] 2/5 Building PI..."

git clone --depth=1 --recursive https://github.com/p4lang/PI.git /opt/PI
cd /opt/PI
./autogen.sh
./configure --with-proto --with-fe-cpp
make -j"$(nproc)"
make install
ldconfig

echo "[build.sh] 3/5 Building bmv2..."

git clone --depth=1 https://github.com/p4lang/behavioral-model.git /opt/bmv2
cd /opt/bmv2
./install_deps.sh
pip install --break-system-packages -r requirements.txt || true
./autogen.sh
./configure --with-pi
make -j"$(nproc)"
make install
ldconfig

echo "[build.sh] 4/5 Building p4c, this is the longest step..."

git clone --depth=1 --recursive https://github.com/p4lang/p4c.git /opt/p4c

sed -i 's/\[this\](flow_join_points_t::value_type &el)/[this](const flow_join_points_t::value_type \&el)/g' \
    /opt/p4c/ir/visitor.cpp

mkdir -p /opt/p4c/build
cd /opt/p4c/build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j"$(nproc)"
make install
ldconfig

echo "[build.sh] 5/5 Cloning t4p4s and p4pi..."

git clone --depth=1 --recursive https://github.com/P4ELTE/t4p4s.git /opt/t4p4s
git clone --depth=1 https://github.com/p4lang/p4pi.git /opt/p4pi

apt-get clean
rm -rf /var/lib/apt/lists/*

echo "[build.sh] Final checks :"

simple_switch --version 2>&1     | sed 's/^/    /' || true
simple_switch_grpc --version 2>&1 | sed 's/^/    /' || true
p4c --version 2>&1               | sed 's/^/    /' || true
ls /usr/local/lib/libpi*         2>/dev/null | sed 's/^/    /' || true
echo "    /opt/p4pi   : $(ls /opt/p4pi 2>/dev/null | wc -l) files"
echo "    /opt/t4p4s  : $(ls /opt/t4p4s 2>/dev/null | wc -l) files"

echo "=== [build.sh] Done. ==="
echo ""
echo "Next step: run enrich.sh to add orchestration scripts"
echo "for P4Pi-WalT (bmv2-start, p4pi-walt-setup, etc.)"
echo "and Python tools (scapy, p4runtime-shell, hping3, ...)."
